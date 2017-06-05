module KonoUtils
  ##
  # Classe che mi rappresenta un attributo di ricerca
  # Di default utilizza il tipo string come renderizzazione
  #
  # * *Args* :
  #   - form_options   -> Hash con opzioni da passare a formtastic
  #   - field_options  -> Hash con opzioni:
  #                       cast -> Proc per eseguire il cast del valore
  class SearchAttribute

    attr_accessor :field, :form_options, :field_options

    def initialize(field, options = {})
      self.field = field

      self.field_options = {}
      unless options.is_a? Proc
        if options[:field_options]
          self.field_options = options[:field_options]
          options.delete(:field_options)
        end
      end

      self.form_options = options
    end

    ##
    # Esegue un casting dei valori rispetto al tipo di campo da utilizzare per formtastic
    def cast_value(value)
      return value if value.blank?
      return value if form_options.is_a? Proc
      return field_options[:cast].call(value) if field_options[:cast].is_a? Proc
      case form_options[:as]
        when :bs_datetimepicker
          if value.is_a? String
            DateTime.parse(value)
          elsif value.is_a? Date
            value.to_time
          else
            value
          end
        when :bs_datepicker
          if value.is_a? String
            DateTime.parse(value).to_date
          elsif value.is_a? DateTime
            value.to_date
          else
            value
          end
        else
          value
      end

    end
  end
end