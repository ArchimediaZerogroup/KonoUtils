class BsReadonlyInput < Formtastic::Inputs::StringInput
  include FormtasticBootstrap::Inputs::Base
  include FormtasticBootstrap::Inputs::Base::Collections
  include ActionView::Helpers::TagHelper
  include ActionView::Context
  include FontAwesome::Rails::IconHelper
  include ActionView::Helpers::JavaScriptHelper


  ##
  # Nel caso di collection si può definire con
  # :show_hidden => [true] per stampare il campo hidden o meno con il vero valore
  # :display_field come options quale campo usare per stampare
  # :value_renderer => Proc da aggiungere, a cui passiamo
  #              campo, valore , se passato nulla viene
  #             renderizzato standard un p contenente il valore
  #
  def to_html

    field_name = method
    show_value = object.send(method)
    if show_value.is_a?(ActiveRecord::Base) and !options[:display_field].blank?
      #vuol dire che siamo in una collection
      show_value = show_value.send(options[:display_field])
      field_name = input_name
    end

    if !options[:value_renderer].is_a?(Proc)
      options[:value_renderer]=Proc.new { |field, value|
        buff = ActiveSupport::SafeBuffer.new
        buff<<content_tag(:p, value, class: 'form-control-static', id: "#{field.form_control_input_html_options[:id]}_container")
        buff
      }
    end


    bootstrap_wrapping do
      content_tag(:div, class: 'input-group date') do

        buff = ActiveSupport::SafeBuffer.new

        buff<< options[:value_renderer].call(self, show_value)

        buff<< builder.hidden_field(field_name, form_control_input_html_options)

        buff

      end
    end
  end

end
