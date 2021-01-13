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
      # E' un'alias per human_attribute_name di active record
      # @param [Symbol,String] attr
      # @param [Hash] options
      # @return [String]
      def han(attr, options = {})
        self.human_attribute_name(attr, options)
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

