class BsAceeditorInput < Formtastic::Inputs::StringInput
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
  #
  def to_html

    theme = options[:theme] || 'twilight'
    mode = options[:mode] || 'ruby'
    height = options[:height] || '300px'

    bootstrap_wrapping do
      content_tag(:div) do

        id = SecureRandom.hex

        buff = ActiveSupport::SafeBuffer.new

        buff<< content_tag(:div, :class => "container_editor clearfix", :style => 'width:100%;') do
          content_tag(:div, object.send(method), id: id, style: "height:#{height};width:100px;")
        end

        id_hidden = SecureRandom.hex
        buff<< builder.hidden_field(method, form_control_input_html_options.merge(:id => id_hidden))

        buff<< content_tag(:script, :type => "text/javascript") do
          raw "var editor = ace.edit('#{id}');\n
             editor.setTheme('ace/theme/#{theme}');\n
             editor.getSession().setMode('ace/mode/#{mode}');\n
             $('##{id}').width($('##{id}').closest('.container_editor').width());\n
             editor.resize();\n
             editor.getSession().on('change', function(e) {
                  $('##{id_hidden}').val(editor.getValue());
             });
             "
        end

        buff

      end
    end
  end

end
