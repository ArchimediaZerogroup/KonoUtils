require 'active_support/concern'
module KonoUtils::Concerns
  module ActiveRecordTranslation

    extend ActiveSupport::Concern

    included do

      def han(attr)
        self.class.han(attr)
      end

      def mnp
        self.class.mnp
      end

      def mn
        self.class.mn
      end

    end

    class_methods do

      ##
      # E' un'alias per il TikalCore::Registration.human_attribute_name(:isee)
      def han(attr)
        self.human_attribute_name(attr)
      end

      ##
      # E' un alias di model_name.human(count:2)
      def mnp
        self.model_name.human(count: 2)
      end

      ##
      # E' un alias di model_name.human
      def mn
        self.model_name.human
      end


    end

  end
end

if defined?(::ApplicationRecord)
  ::ApplicationRecord.include KonoUtils::Concerns::ActiveRecordTranslation
else
  # per i vecchi rails
  ActiveRecord::Base.include KonoUtils::Concerns::ActiveRecordTranslation
end
