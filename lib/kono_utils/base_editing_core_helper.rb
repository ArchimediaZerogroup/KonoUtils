module KonoUtils
  module BaseEditingCoreHelper

    def self.included(mod)
      if ::Rails.application.config.action_controller.include_all_helpers!=false
        raise "Devi definire in config/application.rb config.action_controller.include_all_helpers=false
                in modo da far funzionare correttamente l'override degli helper come per i controller"
      end
    end

    ##
    # Serie di metodi che identificano i titoli generati automaticamente
    # Viene utilizzato i18n per identificare se un determinato modello è di tipo F o M
    # é presente quindi una chiave in YML che identifica ogni modello(default M)
    # def title_mod_g(model)
    #   "#{t("edit_title_#{model_gender(model)}", default: 'Modifica')} #{model.mn}"
    # end
    #
    # def title_new_g(model)
    #   "#{t("new_title_#{model_gender(model)}", default: 'Nuovo')} #{model.mn}"
    # end
    #
    # def title_del_g(model)
    #   "#{t("del_title_#{model_gender(model)}", default: 'Cancella')} #{model.mn}"
    # end
    #
    # def model_gender(model)
    #   t("activerecord.modelgender.#{model.name.underscore.to_sym}", :default => :m).to_sym
    # end

    # def new_button(path, base_class=nil)
    #   options = {class: 'btn btn-success btn-xs'}
    #   options[:title] = title_new(base_class) unless base_class.nil?
    #
    #   link_to fa_icon("plus fw"), path, options
    # end
    #
    # def edit_button(path)
    #   link_to fa_icon("pencil fw"), path, class: 'btn btn-primary btn-xs'
    # end
    #
    # def delete_button(path)
    #   link_to fa_icon("trash fw"), path, method: :delete, data: {confirm: t(:are_you_sure)}, class: 'btn btn-danger btn-xs'
    # end

    # def form_submit(f)
    #   f.actions do
    #     f.action :submit, :button_html => {:class => "btn btn-primary", :disable_with => t('wait', default: 'Wait...')}
    #   end
    # end

    ##
    # Questa funzione serve per essere sovrascritta nell'helper specializzato del controller
    def index_print_column(record, field)
      record.send(field)
    end

    ##
    # Questa funzione serve per stampare il contenuto dell'header
    def index_print_column_head(field)
      block_given? ? yield(field) : base_class.han(field)
    end

    ##
    # Questa funzione serve per generare la colonna della tabella
    #
    # * *Attributes*  :
    #   - colonna
    #   - tipo di colonna td|th
    #   - opzionali     : hash{record} per fare altro
    def index_column_builder(field, column, record: nil)
      column_class = "column_#{field}"
      column_id=''
      if record
        column_id = "#{column_class}-#{dom_id(record)}"
      end
      content_tag column, class: column_class, id: column_id do
        yield column_class, column_id
      end
    end

    # def list_button(path)
    #   link_to fa_icon("list fw"), path, class: 'btn btn-default btn-xs'
    # end

    ##
    # Questa funzione serve per essere sovrascritta nell'helper specializzato del controller
    # e quindi stampare un determinato campo in modo differente
    # si occupa anche di gestire i campi provenienti dalla policy nel caso siano a più livelli con i nested
    # prendiamo in considerazione la situazione con has_many :campo=>[] o con :campo=>[:ciao,:pippo,:pluto]
    def editing_form_print_field(form, field)
      if field.is_a?(Hash)
        #devo nestarlo
        bf = ActiveSupport::SafeBuffer.new

        field.each do |k, v|
          if v.length==0
            #caso in cui è un elemento normale, ma che ha una selezione multipla
            bf<< editing_form_print_field(form, k)
          else
            #caso in cui potremmo essere in un campo di multipli elementi con vari valori ognuno
            bf<< nest_editing_form_print_field(form, k, v)
          end
        end
        bf
      else
        form.input field
      end
    end

    ##
    # Questa funzione può essere sovrascritta per gestire in modo personale la renderizzazine dei nested attributes
    # * *Attributes*  :
    #   - form              -> form di formtastic
    #   - contenitore       -> campo principale
    #   - campi             -> i campi interni
    def nest_editing_form_print_field(form, contenitore, campi)
      form.semantic_fields_for contenitore do |item|
        item.inputs :name => t(".#{form.object.mn}.#{contenitore}", :default => contenitore.to_s.camelcase) do
          bf = ActiveSupport::SafeBuffer.new
          campi.each do |c|
            bf<<editing_form_print_field(item, c)
          end
          bf
        end
      end
    end

    ##
    # Per divisione in celle della form
    #
    # def cell_column_class(field)
    #   "col-md-12"
    # end


    ##
    # Funzione che visualizza il caricamento e l'immagine caricata precedente se presente
    #
    # * *Args*    :
    #   - form
    #   - attribute
    # * *Returns* :
    #   - ActiveSupport:SafeBuffer
    #
    # def image_show_upload(form, attribute)
    #
    #   buff = ActiveSupport::SafeBuffer.new
    #
    #   buff<<form.label(attribute)
    #
    #   buff<<content_tag(:div, class: 'row') do
    #     tmp = ActiveSupport::SafeBuffer.new
    #
    #
    #     tmp << content_tag(:div, class: "col-md-5") do
    #       form.input attribute, :label => false
    #     end
    #
    #     if form.object.send(attribute).exists?
    #       tmp << content_tag(:div, class: "col-md-2 col-lg-5") do
    #         link_to image_tag(form.object.send(attribute).url(:original), class: 'img-thumbnail logo-original'), form.object.send(attribute).url
    #       end
    #     end
    #
    #     tmp
    #   end
    #
    #
    # end


    # def semantic_form_attributes(obj)
    #   obj
    # end


    ##
    # Helper per visualizzare l'alert del destroy
    # def destroy_link_to(path, options)
    #   link_to t('.destroy'), path,
    #           :method => :delete,
    #           :class => "btn",
    #           :confirm => t('.destroy_confirm.body', :item => options[:item]),
    #           "data-confirm-fade" => true,
    #           "data-confirm-title" => t('.destroy_confirm.title', :item => options[:item]),
    #           "data-confirm-cancel" => t('.destroy_confirm.cancel', :item => options[:item]),
    #           "data-confirm-cancel-class" => "btn-cancel",
    #           "data-confirm-proceed" => t('.destroy_confirm.proceed', :item => options[:item]),
    #           "data-confirm-proceed-class" => "btn-danger"
    # end

  end
end