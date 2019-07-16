module KonoUtils
  class Engine < ::Rails::Engine

    # require 'bootstrap3-datetimepicker-rails'
    require 'momentjs-rails'
    require 'font-awesome-rails'
    require 'will_paginate'
    require 'will_paginate-bootstrap'
    require 'rdiscount'
    require 'underscore-rails'
    require 'formtastic-bootstrap'
    require 'pundit'


    initializer 'kono_utils.append_views', :group => :all do |app|
      ActionController::Base.append_view_path KonoUtils::Engine.root.join("app", "views", "kono_utils")
    end

  end
end
