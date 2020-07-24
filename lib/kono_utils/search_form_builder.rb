module KonoUtils
  ##
  # PORO che si occupa di fare da proxy nella generazione della form della ricerca.
  # Questa classe è designata a staccare la logica del modello della ricerca dalla logica del controller e view
  class SearchFormBuilder

    #@return [KonoUtils::BaseSearch] o una classe derivata
    attr_reader :search

    # @param [KonoUtils::BaseSearch] search
    def initialize(search)
      @search = search
    end


    ##
    # Costruisce la path per fare le richieste, oppure false nel caso non sia stata configurata
    # @return [String,FalseClass]
    def search_path
      Rails.application.routes.url_helpers.polymorphic_path(search) rescue false
    end

  end
end