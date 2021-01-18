class ApplicationRecord < ActiveRecord::Base
include KonoUtils::Concerns::ActiveRecordTranslation

  self.abstract_class = true
end