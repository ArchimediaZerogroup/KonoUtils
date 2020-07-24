require 'active_support/concern'
module KonoUtils

  module BaseSearchFormPolicyConcern
    extend ActiveSupport::Concern

    included do

      ##
      # elenco degli attributi filtrati alla ricezione nel controller
      def permitted_attributes
        record.search_attributes.collect(&:field)
      end

      alias_method :editable_attributes, :permitted_attributes

    end


#  module ClassMethods

#  end
  end
end

