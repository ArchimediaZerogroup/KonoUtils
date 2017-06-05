module KonoUtils
  module ApplicationHelper


    def will_paginate_bst(collection)
      will_paginate collection, renderer: BootstrapPagination::Rails
    end


    def namespace_content(&block)
      content_tag :div, class: "#{(controller.class.name.split("::") + [action_name]).join(" ")}" do
        yield
      end

    end

    def true_false_label(val)

      if val
        icon =fa_icon(:check)
        classe='success'
      else
        classe='danger'
        icon =fa_icon(:times)
      end

      content_tag(:span, icon, class: "label label-#{classe}")

    end


    ##
    # Genera una modal da riutilizzare per far aspettare determinate operazioni al client
    def bootstrap_please_wait
      content_tag(:div,
                  class: 'modal fade',
                  id: 'processing_wait',
                  tabindex: "-1",
                  role: "dialog",
                  "aria-hidden".to_sym => "true") do
        content_tag :div, class: 'modal-dialog modal-sm' do
          content_tag :div, class: 'modal-content' do

            buff = ActiveSupport::SafeBuffer.new

            buff << content_tag(:div, class: 'modal-header') do
              content_tag(:h4, "Processing...", class: "modal-title")
            end

            buff << content_tag(:div, class: 'modal-body') do
              content_tag :div, class: "progress" do
                content_tag :div, ' ', class: "progress-bar progress-bar-striped active", role: "progressbar", style: "width: 100%"
              end
            end

            buff
          end
        end
      end
    end


    ##
    # Genera la form di ricerca
    # * *Args*    :
    #   - search_model  -> KonoUtils::BaseSearch
    #   - args          -> Hash with configurations:
    #                       - attributes      -> array of symbols for the search, if empty used from search_model
    #                       - reset_path      -> path per cui resettare la ricerca, nil
    #                       - form_opts       -> opzioni da aggiungere per la form
    #                       - buttons_editor  -> Proc chiamata, con il passaggio dell'oggetto della form e
    #                                            del ActiveSupport::SafeBuffer con all'interno dei bottoni
    #                                            come parametro, deve ritornare
    #                                             un ActiveSupport::SafeBuffer a sua volta
    # * *Returns* :
    #   -
    #
    def search_form(search_model, args={})

      args = {
          :attributes => [],
          :reset_path => nil,
          :form_opts => {},
          :field_option => {:wrapper_html => {:class => "col-xs-12 col-sm-6 col-md-4 col-lg-3"}},
          :buttons_editor => Proc.new { |form_obj, sb| sb }
      }.merge(args)

      reset_path = args[:reset_path]

      field_option = args[:field_option]

      base_search_form_wrapper(search_model, {:attributes => args[:attributes], :form_opts => args[:form_opts]}) do |f|
        content_tag :div, class: "panel panel-default search_panel" do

          buffer = ActiveSupport::SafeBuffer.new

          buffer<< content_tag(:div, class: 'panel-heading') do
            content_tag :h3, class: "panel-title collapse_search" do
              header = ActiveSupport::SafeBuffer.new

              header<< content_tag(:span, t(:search))

              header<<content_tag(:div, fa_icon("search") + content_tag(:span, nil, class: 'caret'), class: 'pull-right icon-search')

              header
            end
          end

          buffer<< content_tag(:div, class: "collapsible_panel #{(search_model.data_loaded? ? 'uncollapsed' : '')}") do
            fb_collapse = ActiveSupport::SafeBuffer.new

            fb_collapse << content_tag(:div, class: "panel-body") do
              f.fields_builder(:field_options => field_option)
            end


            fb_collapse << content_tag(:div, class: 'panel-footer text-right') do
              form_buffer = ActiveSupport::SafeBuffer.new

              form_buffer<< button_tag(t(:search), type: "submit", class: "btn btn-primary")

              if search_model.data_loaded? and !reset_path.nil?
                form_buffer<< link_to(content_tag(:span, nil, class: 'glyphicon glyphicon-remove'), reset_path, class: 'btn btn-info')
              end

              args[:buttons_editor].call(f, form_buffer)
            end

            fb_collapse
          end

          buffer
        end
      end


    end

    class BaseSearchFormWrapper < Struct.new(:formtastic_form, :attributes, :current_user)

      def fields_builder(cfgs={field_options: {}})
        form_buffer = ActiveSupport::SafeBuffer.new

        self.attributes.each do |field|

          form_options = field.form_options
          if form_options.is_a?(Proc)
            form_options = form_options.call(current_user, self.formtastic_form)
          end

          form_buffer << self.formtastic_form.input(field.field, cfgs[:field_options].merge(form_options))
        end

        form_buffer
      end
    end

    ##
    # Utility interna che si occupa della logica minima per generare la il form di ricerca
    def base_search_form_wrapper(search_model, args={:attributes => [], :form_opts => {}})
      attributes = args[:attributes] || {}
      form_opts = args[:form_opts] || {}
      if attributes.length==0
        attributes = search_model.search_attributes
      end

      form_opts = {method: :get, :html => {autocomplete: 'off'}}.merge(form_opts)

      semantic_form_for search_model, form_opts do |f|
        yield BaseSearchFormWrapper.new(f, attributes, @current_user)
      end
    end


    def title_mod(model)
      "#{t(:edit)} #{model.mn}"
    end

    def title_new(model)
      "#{t(:new)} #{model.mn}"
    end

    def title_newa(model)
      "#{t(:newa)} #{model.mn}"
    end

    def title_del(model)
      "#{t(:del)} #{model.mn}"
    end


    ##
    # Genera l'hash da passare come collection alle selectbox, esegue anche la traduzione con locale
    #
    #   <%= f.input :usage, :as => :select,
    #                :collection => enum_collection(Logo, :usage), :input_html => {:include_blank => true} %>
    #
    # * *Args*    :
    #   - model     -> ActiveRecord model contenente l'enum
    #   - attribute -> Symbol che identifica l'attributo dell'enum
    #   - variant   -> se c'è la variante questa viene inserite _#{variant} dopo il nome del valore
    # * *Returns* :
    #   - Hash
    #
    def enum_collection(model, attribute, variant=nil)

      model.send(attribute.to_s.pluralize(2).to_sym).collect { |key, val|
        [enum_translation(model, attribute, key, variant), key]
      }.to_h
    end


    ##
    # Si occupa di tradurre un determinato valore di un enum
    #   - model     -> ActiveRecord model contenente l'enum
    #   - attribute -> Symbol che identifica l'attributo dell'enum
    #   - variant   -> se c'è la variante questa viene inserite _#{variant} dopo il nome del valore
    #
    # * *Returns* :
    #   - String
    #
    def enum_translation(model, attribute, value, variant=nil)
      ApplicationHelper.enum_translation(model, attribute, value, variant)
    end


    ##
    # Le traduzioni dentro al locale devono essere fatte in questo modo:
    # it:
    #   activerecord:
    #     attributes:
    #       estimate_before/value:
    #         na: NA
    #         very_insufficient: 1
    #         insufficient: 2
    #         sufficient: 3
    #         excellent: 4
    #
    # dove in questo caso  estimate_before è il modello e value è il nome del campo enum
    #
    def self.enum_translation(model, attribute, value, variant=nil)
      return '' if value.nil?
      variant = "_#{variant}" unless variant.nil?
      model.human_attribute_name("#{attribute}.#{value}#{variant}")
    end


    ##
    # Helper per generare una modal con all'interno un form
    # Utilizzare passando un block il quale riceve come parametro la form di formtastic
    # possibile passare anche una proc in buttons_proc per scrivere in modo differente i bottoni nella modal,
    # alla proc viene passato il solito form di formtastic e il bottone standard di chiusura
    #
    def modal_form_generator(args = {})

      args = {
          id: 'modal',
          class: '',
          title: 'Titolo',
          form_cfgs: [],
          buttons_proc: Proc.new do |f, default_close_btn|
            default_close_btn +
                f.action(:submit, button_html: {class: 'btn btn-primary'}, :label => :save_and_close)
          end
      }.merge(args)

      raise 'Passare le configurazioni per la form' if args[:form_cfgs]==[]

      default_close_btn = content_tag(:button, 'Chiudi', type: 'button', class: 'btn btn-default', data: {dismiss: "modal"})

      content_tag(:div,
                  class: "modal fade kono_modal_form",
                  id: args[:id],
                  tabindex: "-1",
                  role: "dialog",
                  "aria-hidden".to_sym => "true") do
        content_tag :div, class: 'modal-dialog' do
          semantic_form_for(*args[:form_cfgs]) do |f|
            content_tag :div, class: 'modal-content' do

              buff = ActiveSupport::SafeBuffer.new

              buff << content_tag(:div, class: 'modal-header') do
                content_tag(:button, raw("&times;"), type: "button", class: "close", data: {dismiss: 'modal'}, "aria-hidden".to_sym => "true") +
                    content_tag(:h4, args[:title], class: "modal-title")
              end

              buff << content_tag(:div, class: 'modal-body') do
                yield f
              end

              buff << content_tag(:div, class: 'modal-footer') do
                args[:buttons_proc].call(f, default_close_btn)
              end

              buff
            end
          end
        end
      end

    end


    ##
    # Genera il bottone per editazione con una modal del contenuto,
    # gli viene passato un block contenente la modal da lanciare per l'editazione,
    # solitamente generata con modal_form_generator.
    # come parametri viene passato l'id del target che si aspetta di richiamare
    #
    # ES:
    #  modal_edit_button do |id|
    #    render 'tikal_core/people/person_contacts/modal_form', :contact => contact, :id => id %>
    #  end
    #
    # Attributes:
    #   align: left|rigth
    #   updatable_content: elemento da rimpiazzare con il partial restituito
    #   class: classi aggiuntive per selezionare meglio il bottone
    #   btn_class: classi aggiuntive del bottone
    #   bnt_icon: Symbol che identifica che icona utilizzare per il bottone
    #
    #
    def modal_edit_button(*args, &block)

      options = {
          align: 'left',
          updatable_content: '',
          class: '',
          btn_class: '',
          bnt_icon: :edit
      }.merge(args.extract_options!)

      id = "#{SecureRandom.hex}"


      content_tag :div, class: "kono_edit_button align-#{options[:align]} #{options[:class]}", :data => {updatable_content: options[:updatable_content]} do
        buffer = ActiveSupport::SafeBuffer.new

        buffer << button_tag(data: {toggle: 'modal', target: "##{id}"}, class: "btn btn-default btn-xs #{options[:btn_class]}") { fa_icon(options[:bnt_icon]) }

        buffer << capture do
          block.call(id)
        end

        buffer
      end
    end


    ##
    # Genera il bottone per la cancellazione di un elemento
    #
    # modal_delete_button(path, [options])
    # path -> resource to delete
    # options:
    #  *  confirm         : Text to display in modal
    #  *  align           : left|right
    #  *  callback_remove : id dell'elemento da rimuove una volta avuto successo il javascript di cancellazione
    #  *  bnt_icon        : Symbol che identifica che icona utilizzare per il bottone
    def modal_delete_button(*args)
      options = {
          confirm: 'Sicuri di voler eliminare il record? L\'azione non è annullabile.',
          align: 'left',
          callback_remove: nil,
          bnt_icon: :times
      }.merge(args.extract_options!)
      path = args[0]

      id = "#{SecureRandom.hex}"

      content_tag :div, class: "tk_delete_button align-#{options[:align]}" do

        buffer = ActiveSupport::SafeBuffer.new

        buffer<<button_tag(data: {toggle: 'modal', target: "##{id}"}, class: 'btn btn-danger btn-xs') { fa_icon(options[:bnt_icon]) }

        buffer<< content_tag(:div,
                             class: 'modal fade',
                             id: id,
                             tabindex: "-1",
                             role: "dialog",
                             "aria-hidden".to_sym => "true") do
          form_tag(path, method: :delete, data: {callback_remove: options[:callback_remove]}) do
            content_tag :div, class: 'modal-dialog' do
              content_tag :div, class: 'modal-content' do

                buff = ActiveSupport::SafeBuffer.new

                buff << content_tag(:div, class: 'modal-header') do
                  tmp_buff = ActiveSupport::SafeBuffer.new
                  tmp_buff<<button_tag(fa_icon(:times), type: "button", class: "close", data: {dismiss: "modal"}, "aria-hidden".to_sym => true)
                  tmp_buff<<content_tag(:h4, "Attenzione", class: "modal-title")
                  tmp_buff
                end

                buff << content_tag(:div, options[:confirm], class: 'modal-body text-danger')

                buff << content_tag(:div, class: 'modal-footer') do
                  button_tag('Annulla', type: "button", class: "btn btn-default", data: {dismiss: "modal"})+
                      button_tag('Conferma', type: 'submit', class: "btn btn-danger")
                end

                buff
              end

            end
          end
        end

        buffer << content_tag(:script, raw("$('##{id} form').kono_delete_button();"), :type => 'text/javascript')

        buffer
      end
    end

    ##
    # Colleziona i mesi per la select box
    def month_collection
      (1..12).collect { |m| [t('date.month_names')[m].capitalize, m] }
    end


    ##
    # Genera una collection degli anni per la select box
    # parte da -8 a +1
    #
    def year_collection(start=-8, last=1)
      ((Time.now.year+start)..(Time.now.year+last)).to_a.reverse
    end

    module_function :year_collection


    ##
    # Si occupa di generare la visualizzazione dell'exception passata, con informazioni
    # aggiuntive se utente è super admin
    # * *Args*    :
    #   - exception   -> Exception
    def bs_rescue_printer(exception)
      bff = ActiveSupport::SafeBuffer.new

      bff<< content_tag(:div, class: "alert alert-warning") do
        button_tag(raw("&times;"), data: {dismiss: "alert", hidden: "true"}, class: 'close') +
            content_tag(:strong, 'Errore') +
            " Attenzione, il codice eseguito non è valido, contattare l'amministratore."
      end

      if @current_user.is_super_admin?

        bff<<content_tag(:div, class: "panel panel-info") do
          tmp = ActiveSupport::SafeBuffer.new
          tmp<<content_tag(:div, class: "panel-heading") do
            content_tag :h3, "Messagio di Errore: #{exception.message} "
          end
          tmp<<content_tag(:div, class: "panel-body") do
            content_tag :pre, exception.backtrace.join("\n")
          end

          tmp
        end
      end

      bff
    end

    ##
    #
    # * *Args*    :
    #   - int   -> Valore intero per definire
    #   - class -> optional classi aggiuntive
    # * *Returns* :
    #   - content
    #
    def bs_spacer(space, classe='')
      content_tag :div, nil, class: "v-spacer space-x#{space} #{classe}"
    end


    ##
    # Costruisce una tabella con i campi utili alla creazione di elementi multipli
    #
    # Attributes:
    # form -> la form proveniente da formtastic
    # field -> il campo referente dell'associazione
    # fields -> elenco di campi su cui costruire le varie colonne
    # options -> Hash di opzioni:
    #             :disable_duplication => [false]    : server per disabilitare il bottone della duplicazione
    #
    # se gli si passa un blocco allora possiamo elaborare la costruzione dei differenti campi in modo personale
    # al blocco viene passato la classe di formtastic della form, il campo, e un blocco contenente la proc per
    # elaborare i campi in modo standard
    #
    #   multiple_elements_table(form, :campo_has_many, [:label, :string_value, :number_value]) do |field, form|
    #     case field
    #       when :string_value, :number_value
    #         form.input field, label: false, input_html: {:autocomplete => 'off', class: 'toggle_value'}
    #       else
    #         form.input field, label: false, input_html: {:autocomplete => 'off'}
    #     end
    #   end
    #
    # Traduzioni delle colonne:
    #
    #   modello_iniziale/campo_has_many:
    #     campo_del_has_many
    #
    #
    def multiple_elements_table(*params)
      options = params.extract_options!

      options = {:disable_duplication => false}.merge(options)

      form = params[0]
      field = params[1]
      fields = params[2]

      semantic_form_nested=[field]

      #inserimento logiche per scope su elenco elementi multipli
      unless options[:scope].nil?
        semantic_form_nested<<options[:scope]
      end

      content_tag :table, class: "table table-bordered" do

        b = ActiveSupport::SafeBuffer.new

        b<< content_tag(:thead) do
          content_tag :tr do
            c = ActiveSupport::SafeBuffer.new

            fields.each do |f|
              ::Rails.logger.debug { form.object.class.inspect }
              ::Rails.logger.debug { field }
              ::Rails.logger.debug { f.inspect }
              c<<content_tag(:th, form.object.class.human_attribute_name("#{field}.#{f}"),class:"multi_tab_#{f}")
            end
            unless options[:disable_duplication]
              c<<content_tag(:td, nil)
            end

            c
          end
        end

        b<<content_tag(:tbody) do
          form.semantic_fields_for(*semantic_form_nested) do |measure|

            default_execution = Proc.new { |field| measure.input field, :label => false }

            content_tag :tr, class: "form-inline list riga_misura" do

              d = ActiveSupport::SafeBuffer.new

              fields.each do |f|
                d<<content_tag(:td,class:"multi_tab_#{f}") do

                  if block_given?
                    yield(f, measure, default_execution)
                  else
                    default_execution.call(f)
                  end

                end
              end

              unless options[:disable_duplication]
                d << content_tag(:td) do

                  link_to "#", class: 'btn btn-xs btn-default add_one_more' do

                    h = ActiveSupport::SafeBuffer.new
                    h<< fa_icon(:plus)
                    h<< measure.input(:_destroy, as: :hidden)

                    h
                  end

                end
              end

              d
            end
          end
        end

        b
      end
    end


    ##
    # Genera un'albero con bootstrap-tree
    # deve ricevere un array di dati da trasformare in json.
    # per come scrivere il parametro data vedi
    # https://github.com/jonmiles/bootstrap-treeview
    #
    def bs_tree(data)

      id_div = SecureRandom.hex(10)

      tmp = ActiveSupport::SafeBuffer.new

      tmp<< content_tag(:div, nil, id: id_div, class: 'bs_tree_list')

      tmp<< javascript_tag do
        raw "$('##{id_div}').treeview({data: #{data.to_json}});"
      end

    end

    ##
    # Stampa una data con il default delle date se questa non è nil
    #
    def print_rescue_date(date)
      unless date.nil?
        return l date.to_date
      end
      ''
    end


  end
end
