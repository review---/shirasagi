module Cms::PublicFilter::Node
  extend ActiveSupport::Concern
  include Cms::PublicFilter::Layout

  private
    def find_node(path)
      node = Cms::Node.site(@cur_site).in_path(path).sort(depth: -1).first
      return unless node
      @preview || node.public? ? node.becomes_with_route : nil
    end

    def render_node(node)
      rest = @cur_path.sub(/^\/#{node.filename}/, "")#.sub(/\/index\.html$/, "")
      path = "/.#{@cur_site.host}/nodes/#{node.route}#{rest}"
      spec = recognize_agent path
      return unless spec

      @cur_node = node
      controller = node.route.sub(/\/.*/, "/agents/#{spec[:cell]}/view")

      agent = new_agent controller
      agent.controller.params.merge! spec
      agent.render spec[:action]
    end

  public
    def generate_node(node, opts = {})
      return if Cms::Page.site(node.site).public.where(filename: "#{node.filename}/index.html").first

      @cur_path   = node.url
      @cur_site   = node.site
      @csrf_token = false

      params.merge! opts[:params] if opts[:params]

      begin
        @exists = true
        response.body = render_node node
        response.content_type ||= "text/html"
      rescue StandardError => e
        @exists = false
        return if e.to_s == "404"
        return if e.is_a? Mongoid::Errors::DocumentNotFound
        raise e unless Rails.env.producton?
      end

      if response.content_type == "text/html" && node.layout
        html = render_to_string inline: render_layout(node.layout), layout: "cms/page"
      else
        html = response.body
      end

      file = opts[:file] || "#{node.path}/index.html"
      write_file node, html, file: file
    end

    def generate_node_with_pagination(node)
      if generate_node node
        @task.log "#{node.url}index.html" if @task
      end

      max = 9999
      num = max

      2.upto(max) do |i|
        file = "#{node.path}/index.p#{i}.html"

        if generate_node node, file: file, params: { page: i }
          @task.log "#{node.url}index.p#{i}.html" if @task
        end

        if !@exists
          num = i
          break
        end
      end

      num.upto(max) do |i|
        file = "#{node.path}/index.p#{i}.html"
        break unless Fs.exists?(file)
        Fs.rm_rf file
      end
    end
end
