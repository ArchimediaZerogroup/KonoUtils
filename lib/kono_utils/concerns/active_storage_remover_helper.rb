require 'active_support/concern'


module KonoUtils::Concerns
  ##
  # Includendo questo modulo nell'application record, possiamo andare injettare metodi necessari per la gestione
  # dell'attributo virtuale per cancellare il file allegato
  # Usage:
  #
  # class Test < ApplicationRecord
  #
  #    has_one_attached :doc
  #    has_one_attached_remover :doc
  #
  # end
  #
  # Ricordarsi di aggiungere anche nella policy il nome del campo da ritornare dalla form, il nome dell'attributo
  # è  kono_utils_purge_NOME_ATTRIBUTO
  #
  #
  #
  module ActiveStorageRemoverHelper
    extend ActiveSupport::Concern
    #
    # included do
    #
    # end

    module ClassMethods

      ##
      # Costruisce i metodi e attributi necessari al modello per gestire la rimozione attraverso l'interfaccia del
      # file allegato
      # @param [String,Symbol] field_name
      def has_one_attached_remover(field_name)

        attr = attribute_purger_name(field_name)
        callback = "make_#{attr}".to_sym
        attr_accessor attr

        after_save callback, if: attr

        define_method(callback) do
          if self.send(field_name.to_sym).attached?
            self.send(field_name.to_sym).purge_later
          end
        end

      end

      ##
      # Nome dell'attributo da generare
      # @param [String] field
      # @return [Symbol]
      def attribute_purger_name(field)
        "kono_utils_purge_#{field}".to_sym
      end

    end
  end
end
