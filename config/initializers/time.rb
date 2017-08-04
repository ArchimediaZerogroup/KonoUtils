# NOTE: Apparently, this initializer is not necessary with Rails 4.2.5 and up.
# It just works with the correct database type DATETIME(6).

# Where 6N is the number of places after the decimal (.)
# For less precision (eg. miliseconds), change 6N to 3N
if defined?(ActiveRecord)
  rails_version = Rails.gem_version
  max_version = Gem::Version.new('4.2.5')
  if rails_version<max_version
    if ActiveRecord::Base.connection.instance_of? ActiveRecord::ConnectionAdapters::Mysql2Adapter
      version = Gem::Version.new(Mysql2::Client.info.fetch(:version))
      min_vresion = Gem::Version.new('5.6.4')
      if version>=min_vresion
        Time::DATE_FORMATS[:db] = '%Y-%m-%d %H:%M:%S.%6N'
      end
    end
  end
end