module KonoUtils
  class Engine < ::Rails::Engine

    # require 'bootstrap3-datetimepicker-rails'
    require 'font-awesome-rails'
    require 'will_paginate'
    require 'will_paginate-bootstrap'
    require 'rdiscount'
    require 'underscore-rails'

    require 'pundit'
    # require 'trailblazer/cells'
    # require 'cell/erb'
    # require 'cell/rails'


    initializer 'kono_utils.append_views', :group => :all do |app|
      ActionController::Base.append_view_path KonoUtils::Engine.root.join("app", "views", "kono_utils")
    end


    initializer 'kono_utils.append_helpers', :group => :all do |app|
      KonoUtils.configure do |c|
        c.application_helper_includes << KonoUtils::ApplicationCoreHelper
        c.base_editing_helper_includes << KonoUtils::BaseEditingCoreHelper
      end
    end

  end
end
