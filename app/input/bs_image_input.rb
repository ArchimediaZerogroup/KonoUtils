class BsImageInput < Formtastic::Inputs::StringInput
  include FormtasticBootstrap::Inputs::Base
  include FormtasticBootstrap::Inputs::Base::Collections
  include ActionView::Helpers::TagHelper
  include ActionView::Context
  include ActionView::Helpers::AssetTagHelper


  ##
  # Passare nelle opzioni la chiave :content con una proc che richiamo per generare il buffer
  #
  def to_html

    bootstrap_wrapping do
      content_tag(:div, class: 'input-group bs_label_with_content') do
        content_tag(:div, class: 'row') do
          tmp = ActiveSupport::SafeBuffer.new

          tmp << content_tag(:div, class: "col-md-6  col-lg-6") do
            builder.input method, :label => false
          end

          if object.send(method).exists?
            tmp << content_tag(:div, class: "col-md-6 col-lg-6") do
              image_tag object.send(method).url,class:'img-responsive img-thumbnail',style:'max-height:200px;'
            end
          end

          tmp
        end
      end
    end
  end

end
