class BsLabelWithContainerInput < Formtastic::Inputs::StringInput
  include FormtasticBootstrap::Inputs::Base
  include FormtasticBootstrap::Inputs::Base::Collections
  include ActionView::Helpers::TagHelper
  include ActionView::Context


  ##
  # Passare nelle opzioni la chiave :content con una proc che richiamo per generare il buffer
  #
  def to_html

    bootstrap_wrapping do
      content_tag(:div, class: 'input-group bs_label_with_content') do
        buff = ActiveSupport::SafeBuffer.new
        buff<< content_tag(:p, options[:content].call, class: 'form-control-static',id:"#{form_control_input_html_options[:id]}_container")
        buff
      end
    end
  end

end
