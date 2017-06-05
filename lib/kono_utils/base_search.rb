require 'kono_utils/search_attribute'
module KonoUtils
  ##
  # Classe base per i form di ricerca nel sistema
  class BaseSearch < VirtualModel

    class UndefinedSearchModel < StandardError
      def initialize(msg = 'Definire nella classe, attraverso set_search_model, il modello da utilizzare come base per la ricerca')
        super(msg)
      end
    end

    class_attribute :_search_model, :_search_attributes, instance_writer: false
    attr_accessor :scope

    define_model_callbacks :set_scope, :make_query

    ##
    # Definisce per la classe quale modello utilizzare per la ricerca
    #
    def self.set_search_model(model)
      self._search_model = model
    end

    ##
    # Definisce gli attributi da utilizzare per la ricerca
    # passandogli un hash finale si possono passare parametri di default
    # per ognuno dei campi settati a formtastic per renderizzare il campo
    # ES:
    #   set_search_attributes :nome,:cognome,:as=>:string
    #   renderizzerà nome e cognome come stringhe
    #
    #   set_search_attributes :datadinascita, :as=>:datetimepicker
    #   renderizzerà un campo predisposto per attivare il datetimepicker
    #
    #   Possiamo anche passare una Proc come ultimo elemento per la generazione degli attributi per la form,
    #   come argomento è presente il current_user
    #   set_search_attributes :datadinascita, Proc.new { |current_user,form| funzione da lanciare per eseguire la generazione
    #                                             degli attibuti da passare alla form per generare il campo }
    #
    #   come hash di opzioni possiamo anche passargli una chiave :field_options
    #   con dentro configurazioni vedi TikalCore::SearchAttribute
    #
    # CALLBACKS
    # Quando vengono creati gli attributi, vengono anche creati gli eventi per ogni attributi, sia per la
    # chiamata del getter (nome_metodo) sia per setter (nome_metodo=), ogni callback ha un prefisso
    # per avere quindi un namespace specifico per questa funzionalità:
    # ES:
    #   set_search_attributes :datadinascita....
    #
    #  genererà:
    #         - before_search_attr_datadinascita
    #         - before_search_attr_datadinascita_set  => relativo al setter
    #         - around_search_attr_datadinascita
    #         - around_search_attr_datadinascita_set  => relativo al setter
    #         - after_search_attr_datadinascita
    #         - after_search_attr_datadinascita_set   => relativo al setter
    #
    def self.set_search_attributes(*attributes)
      options = attributes.extract_options!
      options = {:as => :string}.merge(options)

      if attributes.last.is_a?(Proc)
        options = attributes.pop
      end

      self._search_attributes = self._search_attributes || []
      attributes.each do |a|

        attr_accessor(a.to_sym)

        # instance_variable_set "@#{a}".to_sym, nil
        #
        # unless method_defined? a.to_sym
        define_method(a.to_sym) do
          run_callbacks "search_attr_#{a}" do
            # logger.debug { "Chiamata a metodo virtuale #{a} " }
            instance_variable_get "@#{a}".to_sym
          end
        end
        # end
        #
        # unless method_defined? "#{a}=".to_sym
        define_method("#{a}=".to_sym) do |*args|
          run_callbacks "search_attr_#{a}_set" do
            # logger.debug { "Chiamata a metodo virtuale #{a}= -> #{args.inspect}" }
            instance_variable_set "@#{a}".to_sym, *args
          end
        end
        # end


        #Definisco delle callbacks per ogni attributo
        define_model_callbacks "search_attr_#{a}".to_sym, "search_attr_#{a}_set".to_sym
        self._search_attributes += [KonoUtils::SearchAttribute.new(a, options)]
      end
      self._search_attributes.uniq!
    end

    ##
    # Restituisce il modello di ricerca
    def search_model
      self.class._search_model
    end

    ##
    # Attributi di ricerca
    def search_attributes
      self.class._search_attributes
    end

    def initialize
      raise UndefinedSearchModel if search_model.nil?
      super
      self.scope = self.class._search_model
    end


    ##
    #  deve indicarmi se i dati della ricerca sono stati inseriti
    def data_loaded?
      get_query_params.length>0
    end

    ##
    # Setta lo scope iniziale del modello
    def set_scope(scope)
      run_callbacks :set_scope do
        self.scope = scope
      end
    end


    ##
    # Genera la query di ricerca, passando i parametri da
    # ricercare nello scoper di ricerca del modelo
    def make_query
      run_callbacks :make_query do
        self.scope.search(get_query_params)
      end
    end


    ##
    # Restituisce un hash con tutti i parametri da implementare sulla ricerca
    #
    def get_query_params
      out = {}
      search_attributes.each do |val|
        out[val.field]=self.send(val.field) unless self.send(val.field).blank?
      end

      out
    end

    ##
    # Si occupa di aggiornare i valori interni di ricerca
    def update_attributes(datas)
      search_attributes.each do |val|
        self.send("#{val.field}=", val.cast_value(datas[val.field]))
      end
    end

    def method_missing(m, *args, &block)
      if self.search_attributes.collect(&:field).include?(m.to_s.gsub(/=$/, ''))
        self.send(m, *args)
      else
        super
      end
    end

  end
end