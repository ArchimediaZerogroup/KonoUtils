##
#  <%= f.input :city,
#                :as => :bs_autocomplete,
#                :url => tikal_core.autocomplete_city_nome_autoclts_cities,
#                :display_field => :nome,
#                :value_field => :city_id %>
#
#
# -- display_field
#     serve per indicare quale campo utilizzare come metodo per estrapolare i dati dal record associato
#     può anche essere una proc a cui passiamo l'oggetto
# -- value_field
#     indica quale campo utilizzare per estrapolare il dato del valore del record associato
#     e quale nome dare al campo per creare una form corretta
#
#se è presente il Formtastic::Inputs::AutocompleteInput
begin
  class BsAutocompleteInput < Formtastic::Inputs::AutocompleteInput

    include FormtasticBootstrap::Inputs::Base

    def input_html_options
      id = super[:id]

      opts = {class: "form-control", id: "autocomplete_#{id}"}

      ##Setto valore utilizzando le impostazioni di identificativo del campo per autocomplete  :display_field
      unless options[:display_field].nil?
        opts[:value] = object.send(method).try(options[:display_field])
      end

      super.merge(opts)
    end

    def to_html
      bootstrap_wrapping do
        buffer = ActiveSupport::SafeBuffer.new

        html_options = input_html_options

        hidden_field = nil
        unless options[:value_field].nil?
          hidden_id = "hidden_#{html_options[:id]}_#{SecureRandom.hex}"
          html_options[:id_element] = "##{hidden_id}"
          hidden_field =  builder.hidden_field(options[:value_field], id: hidden_id)
        end

        buffer << builder.autocomplete_field(method, options.delete(:url), html_options)

        buffer << hidden_field unless hidden_field.nil?

        buffer
      end
    end
  end
rescue Exception => e
  if defined?(Rails)
    Rails.logger.debug {"Non riesco a caricare questa input BsAutocompleteInput #{__FILE__}"}
  end
end
