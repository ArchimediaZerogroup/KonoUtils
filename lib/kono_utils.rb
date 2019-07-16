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
  autoload :BaseEditingHelper
  autoload :BaseSearch
  autoload :Concerns

  class Configuration
    attr_accessor :google_api_key
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