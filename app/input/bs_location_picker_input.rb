class BsLocationPickerInput < Formtastic::Inputs::StringInput
  include FormtasticBootstrap::Inputs::Base
  include FormtasticBootstrap::Inputs::Base::Collections
  include ActionView::Helpers::TagHelper
  include ActionView::Context
  include FontAwesome::Rails::IconHelper
  include ActionView::Helpers::JavaScriptHelper

  class ZoomInvalid < StandardError
    def initialize(msg="Zoom non valido, deve essere intero")
      super
    end
  end


  ##
  # Stampa Una Mappa di Google Maps, che rende possibile la selezione di un punto sulla mappa
  # e di salvarlo nei due campi Lat Lng della form.
  #
  # Necessario aver aggiunto anche l'asset kono_utils/utilities
  # per avere il javascript necessario alla generazione della mappa
  #
  # Nell'inizializzatore di kono_utils installato con il generatore impostare la chiave di google:
  # google_api_key
  #
  # La mappa ha un contenitore
  #
  # Options:
  #     -  default_center         -> Array con [lat,lng] nel caso non siano impostati i valori iniziali
  #     -  height                 -> [300px] Altezza da mettere nello stile della canvas di google maps
  #     -  fields                 -> Array[:lat,:lng]  campi che identificano la Latitudine e Longitudine
  #                                  nel record
  #     -  zoom_level             -> [5] Integer livello zoom della mappa, se passo una Proc viene elaborata
  #                                  passando il record, deve tornare un Integer
  #
  def to_html

    default_center = options[:default_center] || [42.90887521920127, 12.303765624999983]
    center = default_center

    height = options[:height] || '300px'
    fields = options[:fields] || [:lat, :lng]
    zoom_level = options[:zoom_level] || 5

    if zoom_level.is_a?(Proc)
      zoom_level = zoom_level.call(object)
    end

    raise ZoomInvalid unless zoom_level.is_a?(Integer)


    bootstrap_wrapping do
      content_tag(:div) do

        id = SecureRandom.hex

        callback_name = "initMap#{id}"

        buff = ActiveSupport::SafeBuffer.new

        buff<< content_tag(:div, :class => "container_google_maps clearfix", :style => 'width:100%;') do
          content_tag(:div, nil, id: id, style: "height:#{height}")
        end

        id_hidden_lat = SecureRandom.hex
        buff<< builder.hidden_field(fields[0], form_control_input_html_options.merge(:id => id_hidden_lat))
        id_hidden_lng = SecureRandom.hex
        buff<< builder.hidden_field(fields[1], form_control_input_html_options.merge(:id => id_hidden_lng))

        unless object.send(fields[0]).blank? or object.send(fields[1]).blank?
          center = [object.send(fields[0]), object.send(fields[1])]
        end

        buff<< content_tag(:script, :type => "text/javascript") do
          raw "function #{callback_name}(){
                $('##{id}').kono_util_location_picker({
                  center:{lat:#{center[0]},lng:#{center[1]}},
                  zoom_level:#{zoom_level},
                  selector_field_lat:'##{id_hidden_lat}',
                  selector_field_lng:'##{id_hidden_lng}'
                });
            }"
        end

        buff<< content_tag(:script, nil,
                           src: "https://maps.googleapis.com/maps/api/js?key=#{KonoUtils.configuration.google_api_key}&callback=#{callback_name}",
                           :type => "text/javascript", async: '', defer: '')

        buff

      end
    end
  end

end