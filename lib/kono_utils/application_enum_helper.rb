module KonoUtils

  ##
  # Racchiudo helpers per gestire gli enum
  module ApplicationEnumHelper

    ##
    # Genera l'hash da passare come collection alle selectbox, esegue anche la traduzione con locale
    #
    #   <%= f.input :usage, :as => :select,
    #                :collection => enum_collection(Logo, :usage), :input_html => {:include_blank => true} %>
    #
    # @param [ActiveRecord] model -> ActiveRecord model contenente l'enum
    # @param [Symbol] attribute   -> Symbol che identifica l'attributo dell'enum
    # @param [nil,String] variant -> se c'è la variante questa viene inserite _#{variant} dopo il nome del valore
    # @return [Hash]
    def enum_collection(model, attribute, variant=nil)

      model.send(attribute.to_s.pluralize(2).to_sym).collect {|key, val|
        [enum_translation(model, attribute, key, variant), key]
      }.to_h
    end


    ##
    # Si occupa di tradurre un determinato valore di un enum
    #
    # Le traduzioni dentro al locale devono essere fatte in questo modo:
    # it:
    #   activerecord:
    #     attributes:
    #       estimate_before/value:
    #         na: NA
    #         very_insufficient: 1
    #         insufficient: 2
    #         sufficient: 3
    #         excellent: 4
    # dove in questo caso  estimate_before è il modello e value è il nome del campo enum
    #
    # @param [ActiveRecord] model class contenente l'enum
    # @param [Symbol] attribute   che identifica l'attributo dell'enum
    # @param [nil,String] variant se c'è la variante questa viene inserite _#{variant} dopo il nome del valore
    # @return [String]
    def enum_translation(model, attribute, value, variant=nil)
      return '' if value.nil?
      variant = "_#{variant}" unless variant.nil?
      model.human_attribute_name("#{attribute}.#{value}#{variant}")
    end


  end
end