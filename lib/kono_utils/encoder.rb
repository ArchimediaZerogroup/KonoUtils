module KonoUtils
  ##
  # Classe che si occupa di decodificare una qualsiasi stringa in formato utf8,
  # cercando di trovare l'encoding iniziale a tentativi.
  class Encoder
    attr_accessor :string

    ##
    # * *Attributes*  :
    #   - string -> Stringa da elaborare
    def initialize(string)
      self.string = string
    end

    ##
    # Funcione di rimozione del carattere BOM http://en.wikipedia.org/wiki/Byte_order_mark
    # e encoding normale
    def remove_bom
      string_encoder.gsub("\xEF\xBB\xBF".force_encoding('UTF-8'), '')
    end

    ##
    # Funzione di encoding semplice
    def string_encoder
      return string if string.valid_encoding?
      str = string
      Encoding.list.each do |e|
        begin
          str.force_encoding(e.name)
          tmp_string = str.encode('UTF-8')
          return tmp_string if tmp_string.valid_encoding?
        rescue
          Rails.logger.debug { "Rescue -> #{e.name}" } if defined?(::Rails)
        end
      end

      impossible_encoding

      string
    end

    ##
    # Metodo placeholder, volendo si può estendere la funzione e sovrascrivere questa funzione
    # per essere notificati in caso di mancata decodifica
    def impossible_encoding; end
  end
end
