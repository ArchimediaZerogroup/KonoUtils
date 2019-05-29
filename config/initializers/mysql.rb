# Creates DATETIME(6) column types by default which support microseconds.
#
# Without it, only regular (second precise) DATETIME columns are created.
if defined?(ActiveRecord)
  module ActiveRecord::ConnectionAdapters
    if defined?(Mysql2Adapter)
      if ActiveRecord::Base.connection_config[:adapter].downcase == Mysql2Adapter::ADAPTER_NAME.downcase
        version = Gem::Version.new(Mysql2::Client.info.fetch(:version))
        min_vresion = Gem::Version.new('5.6.4')
        if version >= min_vresion
          AbstractMysqlAdapter::NATIVE_DATABASE_TYPES[:datetime][:limit] = 6
        end
      end
    end
  end
end