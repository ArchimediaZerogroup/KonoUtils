require 'active_support/concern'

module KonoUtils
  module Concerns
    module BaseEditing
      extend ActiveSupport::Concern


      included do

        include Pundit
        include KonoUtils::Concerns::SuccessMessage

        after_action :verify_authorized, except: :index
        after_action :verify_policy_scoped, only: :index

        before_action :load_object, except: [:index, :new, :create]
        helper_method :base_class
        helper_method :form_attributes
        helper_method :table_columns
        helper_method :new_custom_polymorphic_path
        helper_method :edit_custom_polymorphic_path
        helper_method :index_custom_polymorphic_path
        after_action :check_errors, only: [:create, :update], if: -> { ::Rails.env.development? }

        ##
        # E' possibile passare una callback per poter
        # renderizzare ulteriori formati oppure cambiare la normale
        # renderizzazione. La callback riceve il format della respond_to
        # GET /utenti
        # GET /utenti.xml
        def index(respond_to_call: nil)
          @objects = policy_scope(base_scope).all
          @objects = yield(@objects) if block_given?
          @objects = KonoUtils.configuration.pagination_proxer.new(@objects).paginate(params)

          respond_to do |format|
            format.html # index.html.erb
            format.xml { render :xml => @objects }
            unless respond_to_call.nil?
              respond_to_call.call(format)
            end
          end
        end

        # GET /utenti/new
        # GET /utenti/new.xml
        # GET /utenti/new.inject -> javascript che si occupa di avere un js che injetta il risultato in un
        #                           determinato target che deve essere passato tramite params,
        #                           se non presente il target viene scritto un warning in console
        def new
          @object = base_class.new
          authorize @object
          @object = yield(@object) if block_given?
          logger.debug { "Nuovo oggetto #{@object.inspect}" }

          respond_to do |format|
            format.html
            format.xml { render :xml => @object }
            format.inject { render :layout => false }
          end
        end

        # GET /utenti/1/edit
        def edit
          @object = yield(@object) if block_given?
        end

        # PUT /utenti/1
        # PUT /utenti/1.xml
        def update
          @object = yield(@object) if block_given?
          respond_to do |format|
            if @object.update_attributes(clean_params)
              _successful_update(format)
            else
              _failed_update(format)
            end
          end
        end

        # POST /utenti
        # POST /utenti.xml
        def create
          @object = base_class.new(clean_params)
          authorize @object
          @object = yield(@object) if block_given?
          logger.debug { "Nuovo oggetto #{@object.inspect}" }

          respond_to do |format|
            if @object.save
              _successful_create(format)
            else
              _failed_create(format)
            end
          end
        end

        # DELETE /utenti/1
        # DELETE /utenti/1.xml
        def destroy
          @object = yield(@object) if block_given?


          respond_to do |format|
            if @object.destroy
              _successful_destroy(format)
            else
              _failed_destroy(format)
            end
          end
        end

        ##
        # Elenco degli attributi da visualizzare nella form
        def form_attributes(model = base_class.new)
          ActiveSupport::Deprecation.warn('Utilizzato solo nel vecchio sistema')
          policy(model).permitted_attributes
        end

        ##
        # Elenco ordinato dei campi da utilizzare nella visualizzazione della tabella index
        def table_columns
          ActiveSupport::Deprecation.warn('Utilizzato solo nel vecchio sistema')
          policy(base_class.new).permitted_attributes
        end

        protected

        def base_class
          return @_base_class if @_base_class
          controller = controller_name
          modello = controller.singularize.camelize.safe_constantize
          logger.debug { "Editazione del controller:#{controller} per modello: #{modello.to_s}" }

          raise "Non riesco a restituire la classe base per il controller #{controller}" if modello.nil?

          @_base_class = modello
        end

        private

        def load_object
          @object = base_class.find(params[:id])
          authorize @object
          logger.debug { "Oggetto #{@object.inspect}" }

        end


        ##
        # Scope iniziale per index, viene passato al policy_scope in index.
        # nel caso sia stata attivata la ricerca, lo scope viene filtrato
        def base_scope
          if @search
            @search.make_query
          else
            base_class
          end
        end

        ##
        # Metodo per il load della ricerca, precaricherà la classe per la ricerca
        # e andrà a modificare il comportamento di base_scope in modo che sia utilizzato
        # la ricerca come scope iniziale dei records
        def load_search
          # search_class non esiste, deve essere implementata dall'utente o settata durante il settaggio della classe
          #@type [KonoUtils::BaseSearch]
          #noinspection RubyResolve
          @search = search_class.new
        end

        def clean_params
          permitted = policy(base_class.new).permitted_attributes
          dati = params.required(base_class.name.underscore.gsub('/', '_').to_sym).permit(permitted)
          ::Rails.logger.info { "Permitted Attributes: #{permitted.inspect}" }
          ::Rails.logger.info { "Parametri puliti: #{dati.inspect}" }
          dati
        end

        def check_errors
          unless @object.valid?
            logger.debug { "Invalid Obj:" }
            logger.debug { @object.errors.inspect }
          end
        end


        def new_custom_polymorphic_path(*base_class)
          new_polymorphic_path(*base_class)
        end

        def edit_custom_polymorphic_path(*rec)
          edit_polymorphic_path(*rec)
        end

        def index_custom_polymorphic_path(*rec)
          polymorphic_path(*rec)
        end

        def destroy_custom_polymorphic_path(*rec)
          polymorphic_path(*rec)
        end

        def _failed_destroy(format)
          format.html { redirect_to index_custom_polymorphic_path(base_class),
                                    :flash => {:error => @object.errors.full_messages.join(',')} }
          format.xml { head :ko }
          format.json { render json: {success: false, errors: @object.errors.to_json}, status: 422 }
        end

        def _successful_destroy(format)
          format.html { redirect_to index_custom_polymorphic_path(base_class),
                                    :notice => success_destroy_message(@object) }
          format.xml { head :ok }
          format.json { render json: {success: true} }
        end

        def _failed_create(format)
          format.html { render :action => :new }
          format.xml { render :xml => @object.errors, :status => :unprocessable_entity }
          format.inject { render :action => :edit, :layout => false }
        end

        def _successful_create(format)
          format.html { redirect_to edit_custom_polymorphic_path(@object), :notice => success_create_message(@object) }
          format.xml { render :xml => @object, :status => :created, :location => @object }
          format.inject { render :action => :success_create_show, :layout => false }
        end

        def _failed_update(format)
          format.html { render :action => :edit }
          format.xml { render :xml => @object.errors, :status => :unprocessable_entity }
          format.inject { render :action => :edit, :layout => false }
        end

        def _successful_update(format)
          format.html { redirect_to edit_custom_polymorphic_path(@object), :notice => success_update_message(@object) }
          format.xml { head :ok }
          format.inject { render :action => :success_update_show, :layout => false }
        end
      end

      module ClassMethods

        #@!attribute search_class
        # @return [KonoUtils::BaseSearch]

        # @param [String] search_class
        def setup_search(search_class: nil)

          # se passata la classe,
          if search_class
            self.class_attribute :search_class
            self.search_class = search_class.to_s.constantize
          end

          development_search_setup_checks

          self.before_action :load_search, only: [:index]
        end

        ##
        # Funzione che esegue un check generale sulle configurazioni del setup della ricerca
        # per semplificare la vita allo sviluppatore.
        # Vengono fatti i controlli solamente nell'env di sviluppo
        def development_search_setup_checks
          if ::Rails.env.development?
            out = []
            if self.respond_to?(:search_class)
              # controlliamo le rotte:
              unless self.search_class.new.search_form_builder.search_path
                out << "- Non hai definito la rotta per il controller della ricerca, inserisci nelle rotte del progetto:
                            namespace :#{self.search_class._search_model.name.to_s.pluralize.downcase } do
                              resources :searches, :only => [:index, :create]
                            end
                          "
              end
            else
              out << "- Il controller deve rispondere al methodo search_class ritornando una classe figlia di
                        KonoUtils::BaseSearch oppure configurarlo con il setup passato il valore al parametro
                        search_class"
            end

            raise out.join("\n") unless out.empty?
          end
        end

      end
    end
  end
end
