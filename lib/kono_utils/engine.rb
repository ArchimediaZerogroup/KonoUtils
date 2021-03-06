module KonoUtils
  class Engine < ::Rails::Engine

    require 'rdiscount'
    require 'pundit'
    require 'kono_utils_helpers'


    initializer 'kono_utils.append_views', :group => :all do |app|
      ActionController::Base.append_view_path KonoUtils::Engine.root.join("app", "views", "kono_utils")
    end


    initializer 'kono_utils.append_helpers', :group => :all do |app|
      KonoUtils.configure do |c|
        c.application_helper_includes << KonoUtils::ApplicationCoreHelper
        c.application_helper_includes << KonoUtils::ApplicationEnumHelper
        c.base_editing_helper_includes << KonoUtils::BaseEditingCoreHelper
      end
    end

    initializer 'kono_utils.appen_custom_format', :group => :all do |app|
      Mime::Type.register Mime[:js].to_s, :inject
    end

  end
end
