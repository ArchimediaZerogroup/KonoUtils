# require "zeitwerk"
# loader = Zeitwerk::Loader.for_gem
# loader.ignore("#{__dir__}/generators")

if defined?(::Rails)
  require "kono_utils/engine"
  # if Rails.gem_version <= Gem::Version.new('4.2.0')
  #   # Non facciamo eager load nel caso di nuovi rails
  #   translations_concerns = "#{__dir__}/kono_utils/concerns/active_record_translation"
  #   loader.do_not_eager_load(translations_concerns)
  # end
else
  # non carichiamo l'engine se non presente rails
  # loader.do_not_eager_load("#{__dir__}/kono_utils/engine")
  # require "kono_utils/engine"
end

# loader.enable_reloading # you need to opt-in before setup
# loader.setup

module KonoUtils
  extend ActiveSupport::Autoload

  autoload :ApplicationCoreHelper
  autoload :ApplicationEnumHelper
  autoload :ApplicationHelper
  autoload :BaseEditingCoreHelper
  autoload :BaseEditingHelper
  autoload :BaseSearch
  autoload :Concerns
  autoload :Configuration
  autoload :PaginateProxer
  autoload :SearchAttribute
  autoload :SearchFormBuilder
  autoload :VERSION

  class << self
    attr_writer :configuration
  end

  # @return [Configuration]
  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configure
    yield configuration
  end

end

# loader.eager_load