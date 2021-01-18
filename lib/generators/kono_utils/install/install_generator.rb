require 'rails/generators'
module KonoUtils
  class InstallGenerator < Rails::Generators::Base
    desc "Installa l'inizializzatore"

    # Commandline options can be defined here using Thor-like options:
    # class_option :my_opt, :type => :boolean, :default => false, :desc => "My Option"

    # I can later access that option using:
    # options[:my_opt]


    def self.source_root
      @source_root ||= File.expand_path('../../../templates', __FILE__)
    end

    # Generator Code. Remember this is just suped-up Thor so methods are executed in order
    def copy_files
      copy_file 'initializer.rb', 'config/initializers/kono_utils.rb'
    end

    def install_pundit
      run "rails g pundit:install"
    end

    def install_helper_on_application_helper
      inject_into_file 'app/helpers/application_helper.rb', "\n  include KonoUtils::ApplicationHelper", after: "module ApplicationHelper"
    end

    def install_active_record_traslation_on_application_record
      inject_into_file 'app/models/application_record.rb', "\n  include KonoUtils::Concerns::ActiveRecordTranslation\n", after: "ActiveRecord::Base"
      inject_into_file 'app/models/application_record.rb', "\n  include KonoUtils::Concerns::ActiveStorageRemoverHelper\n", after: "ActiveRecord::Base"
    rescue Exception => e
      puts "Attenzione, includere a mano:
               - KonoUtils::Concerns::ActiveRecordTranslation
               - KonoUtils::Concerns::ActiveStorageRemoverHelper
            nel modello da cui darivano i modelli del base editing - #{e.message}"
    end

    def append_gem_dependency
      append_to_file 'Gemfile', "# gem 'codice_fiscale'"
    rescue Exception => e
      puts e.message
    end



    def install_node_dependency
      pacchetti_yarn = ["underscore"]#"wolfy87-eventemitter",

      run "yarn add #{pacchetti_yarn.join(" ")}"
    end

    def base_editing_install
      resp = ask "Vuoi che installi la struttura base del controller e base editing? y/n"
      if resp=='y'
        @controller_da_cui_derivare = ask("Controller da cui derivare il BaseEditingController?[RestrictedAreaController]")
        @controller_da_cui_derivare = "RestrictedAreaController" if @controller_da_cui_derivare.blank?
        template('base_editing_controller.template','app/controllers/base_editing_controller.rb')
        template('base_editing_helper.template','app/helpers/base_editing_helper.rb')
        template('base_editing_policy.template','app/policies/base_editing_policy.rb')
        say "Tutti i Controller che dovranno lavorare con il base editing dovranno derivare da BaseEditingController"
        say "Tutte le policy che dovranno lavorare con il base editing dovranno derivare da BaseEditingPolicy"
      end
    end

  end
end