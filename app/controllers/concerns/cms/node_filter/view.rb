module Cms::NodeFilter::View
  extend ActiveSupport::Concern
  include SS::AgentFilter
  include Cms::RssFilter

  included do
    helper Cms::PublicHelper
  end

  module ClassMethods
    def model(cls)
      self.model_class = cls if cls
    end
  end

  private
    def set_model
      @model = self.class.model_class
      controller.instance_variable_set :@model, @model
    end

    def render_with_pagination(items)
      raise "404" if params[:page].to_i > 1 && items.empty?
      render
    end
end