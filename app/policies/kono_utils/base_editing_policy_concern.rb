require 'active_support/concern'
module KonoUtils

  module BaseEditingPolicyConcern
    extend ActiveSupport::Concern

    included do

      ##
      # elenco degli attributi filtrati alla ricezione nel controller
      # @return [Array<Symbol>]
      def permitted_attributes
        cleard_columns+virtual_appended_attributes
      end

      ##
      # elenco attributi editabili nella form
      # @return [Array<Symbol>]
      def editable_attributes
        cleard_columns
      end

      ##
      # elenco attributi visualizzabili nella show
      # @return [Array<Symbol>]
      def displayable_attributes
        editable_attributes
      end

      ##
      # Elenco attributi da visualizzare, utilizzati nella vista della index
      # @return [Array<Symbol>]
      def show_attributes
        cleard_columns
      end

      private

      def cleard_columns
        record.class.column_names.collect { |s| s.to_sym } - [:id, :created_at, :updated_at]
      end

      ##
      # Elenco di attributi generati dinamicamente da KonoUtils.
      # Come ad esempio l'attributo per la cancellazione del file allegato
      # @return [Array<Symbol>]
      def virtual_appended_attributes
        out = []
        if record.class.respond_to?(:attribute_purger_name)
          record.class.instance_methods.each do |c|
            next if c.match(/=$/) #skippiamo per i writers
            if record.respond_to?(record.class.attribute_purger_name(c))
              Rails.logger.debug c.inspect
              out << record.class.attribute_purger_name(c)
            end
          end
        end
        out
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

