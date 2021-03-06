class Faq::Agents::Parts::SearchController < ApplicationController
  include Cms::PartFilter::View
  include Cms::PublicFilter::Layout
  include Mobile::PublicFilter
  helper Cms::ListHelper

  public
    def index
      @search_node = @cur_part.search_node.present? ?  @cur_part.search_node : @cur_part.parent
      @url = mobile_path? ? "/mobile#{@search_node.url}" : @search_node.url
      @search_node.blank? ? "" : render
    end
end
