require 'active_support/concern'
module KonoUtils

  module BaseEditingPolicyConcern
    extend ActiveSupport::Concern

    included do

      ##
      # elenco degli attributi filtrati alla ricezione nel controller
      def permitted_attributes
        # [:descrizione]
        cleard_columns
      end

      ##
      # elenco attributi editabili nella form
      def editable_attributes
        cleard_columns
      end

      ##
      # elenco attributi visualizzabili nella show
      def displayable_attributes
        editable_attributes
      end

      ##
      # Elenco attributi da visualizzare, utilizzati nella vista della index
      def show_attributes
        cleard_columns
      end

      private
      def cleard_columns
        record.class.column_names.collect {|s| s.to_sym} - [:id, :created_at, :updated_at]
      end


    end

    if defined? ::Application::Scope
      class Scope < ::Application::Scope
        def resolve
          scope
        end
      end
    end

#  module ClassMethods

#  end
  end
end

