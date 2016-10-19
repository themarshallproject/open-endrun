# https://github.com/yappbox/render_anywhere/blob/master/lib/render_anywhere/rendering_controller.rb
class OfflineTemplate < AbstractController::Base
  include AbstractController::Logger
  include AbstractController::Rendering
  include ActionView::Layouts
  include AbstractController::Helpers
  include AbstractController::Translation
  include AbstractController::AssetPaths
  include ActionController::Caching
  include Rails.application.routes.url_helpers

  helper_method :protect_against_forgery?
 
  layout 'public'
  
  def initialize(*args)
      super()

      #self.class.send :include, Rails.application.routes.url_helpers

      # this is you normal rails application helper
      self.class.send :helper, ApplicationHelper

      lookup_context.view_paths = ApplicationController.view_paths
      config.javascripts_dir = Rails.root.join('public', 'javascripts')
      config.stylesheets_dir = Rails.root.join('public', 'stylesheets')
      config.assets_dir = Rails.root.join('public')
      config.cache_store = ActionController::Base.cache_store

      # same asset host as the controllers
      self.asset_host = ActionController::Base.asset_host
      
  end
  
  def set_instance_vars(args={})
    args.each do |k, v|
      puts "setting @#{k} to #{v}"
      self.instance_variable_set("@#{k}", v)
    end
    self
  end

  # we are not in a browser, no need for this
  def protect_against_forgery?
    false
  end
  
  # so that your flash calls still work
  def flash
    {}
  end
 
  def params
    {}
  end
  
  def current_user
    nil
  end

  # and nil request to differentiate between live and offline
  def request
    nil
  end

end