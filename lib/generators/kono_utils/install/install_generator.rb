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


  end
end