##
# Classe per la stampa del DatetimePicker con bootstrap
#
# * *Opzioni*  :
#   - inject_js => True|False|Hash per ozioni js
#
class BsDatetimepickerInput < Formtastic::Inputs::StringInput
  include FormtasticBootstrap::Inputs::Base
  include ActionView::Helpers::TagHelper
  include ActionView::Context
  include FontAwesome::Rails::IconHelper
  include ActionView::Helpers::JavaScriptHelper
  include ActionView::Helpers::OutputSafetyHelper

  ##
  # Serve per avere icone differenti nell'interfaccia
  def icon
    fa_icon(:calendar)
  end

  def to_html

    bootstrap_wrapping do
      tmp = ActiveSupport::SafeBuffer.new

      tmp<< content_tag(:div, class: 'input-group date tk_date_time_picker', id: picker_container_id) do
        builder.text_field(method, form_control_input_html_options)<<
            content_tag(:span, icon, class: 'input-group-addon')

      end

      if options[:inject_js]
        tmp << javascript_initializations
      end
      tmp
    end
  end

  def picker_container_id
    if @_container_id.nil?
      @_container_id = "date_time_picker_#{form_control_input_html_options[:id]}_#{Random.new_seed}"
    end
    @_container_id
  end

  def javascript_initializations

    opt = options[:inject_js]
    unless opt.is_a?(Hash)
      opt ={}
    end

    opt=default_javascript_options.merge(opt)

    if block_given?
      yield opt
    else
      content_tag(:script, :type => "text/javascript") do
        raw "(function(){var data_picker = new Kn.utilities.DateTimePicker({
              selector: $('##{picker_container_id}'),
              server_format: \"#{opt[:server_format]}\",
              server_match: #{opt[:server_match]},
              format: \"#{opt[:format]}\"
            })                        ;
            data_picker.initialize() ;
          })();
           "
      end
    end
  end

  def default_javascript_options
    {
        server_format: 'YYYY-MM-DD',
        server_match: '/^[0-9]{4}-[0-9]{2}-[0-9]{2}$/',
        format: 'DD/MM/YYYY HH:mm'
    }
  end

end
