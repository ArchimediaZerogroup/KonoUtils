class BsFileDownloadInput < Formtastic::Inputs::StringInput
  include FormtasticBootstrap::Inputs::Base
  include FormtasticBootstrap::Inputs::Base::Collections
  include ActionView::Helpers::TagHelper
  include ActionView::Context
  include ActionView::Helpers::UrlHelper


  ##
  # Passare nelle opzioni la chiave :content con una proc che richiamo per generare il buffer
  #
  def to_html

    bootstrap_wrapping do
      content_tag(:div, class: 'input-group bs_label_with_content') do
        content_tag(:div, class: 'row') do
          tmp = ActiveSupport::SafeBuffer.new

          tmp << content_tag(:div, class: "col-md-6") do
            builder.input method, :label => false
          end

          if object.send(method).exists?
            tmp << content_tag(:div, class: "col-md-6 col-lg-6") do
              link_to I18n.t('formtastic.inputs.bs_file_download.download'), object.send(method).url, class: 'btn btn-default'
            end
          end

          tmp
        end
      end
    end
  end

end
