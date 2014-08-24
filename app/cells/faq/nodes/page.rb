# coding: utf-8
module Faq::Nodes::Page
  class EditCell < Cell::Rails
    include Cms::NodeFilter::EditCell
    model Faq::Node::Page
  end

  class ViewCell < Cell::Rails
    include Cms::NodeFilter::ViewCell
    helper Cms::ListHelper

    public
      def pages
        Faq::Page.site(@cur_site).public.
          where(@cur_node.condition_hash)
      end

      def index
        @items = pages.
          order_by(@cur_node.sort_hash).
          page(params[:page]).
          per(@cur_node.limit)

        @items.empty? ? "" : render
      end

      def rss
        @items = pages.
          order_by(released: -1).
          limit(@cur_node.limit)

        render_rss @cur_node, @items
      end
  end
end
