require 'kono_utils/engine' if defined?(::Rails)

module KonoUtils
  extend ActiveSupport::Autoload

  # Classi helpers provenienti dalla gemma KonoUtilsHelper
  autoload :VirtualModel
  autoload :Encoder
  autoload :ParamsHashArray
  autoload :Percentage
  autoload :FiscalCode
  autoload :TmpFile

  autoload :ApplicationHelper
  autoload :ApplicationCoreHelper
  autoload :BaseEditingHelper
  autoload :BaseEditingCoreHelper
  autoload :BaseSearch
  autoload :Concerns

  class Configuration
    attr_accessor :google_api_key
    attr_accessor :application_helper_includes
    attr_accessor :base_editing_helper_includes

    def initialize
      @application_helper_includes = []
      @base_editing_helper_includes = []
    end
  end

  class << self
    attr_writer :configuration
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configure
    yield configuration
  end


end


if defined?(::Rails)
  if Rails.gem_version > Gem::Version.new('4.2.0')
    require 'kono_utils/concerns/active_record_translation'
  end
end