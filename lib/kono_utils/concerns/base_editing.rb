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

        rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

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
            if @object.update(clean_params)
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

        def user_not_authorized
          flash[:alert] = t('.user_not_authorized', :model => @object.mn,
                            default: t('kono_utils.user_not_authorized', :model => @object.mn, default: "You are not authorized to perform this action."))
          redirect_to(request.referrer || root_path)
        end

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
          permitted = policy(@search).permitted_attributes
          dati = require_params_for(search_class).permit(permitted)
          ::Rails.logger.info { "Permitted Attributes: #{permitted.inspect}" }
          ::Rails.logger.info { "Parametri puliti: #{dati.inspect}" }
          @search.update_attributes(dati)

        end

        def clean_params
          permitted = policy(base_class.new).permitted_attributes
          dati = require_params_for!(base_class).permit(permitted)
          ::Rails.logger.info { "Permitted Attributes: #{permitted.inspect}" }
          ::Rails.logger.info { "Parametri puliti: #{dati.inspect}" }
          dati
        end

        ##
        # Estrapola i parametri dalla classe in questione, partendo da params, fancendo un require
        def require_params_for!(klass)
          required_params_name = klass.name.underscore.gsub('/', '_').to_sym
          Rails.logger.info { "Required attibute: #{required_params_name}" }
          params.required(required_params_name)
        end

        ##
        # Come sopra. ma fallendo su un ActionController::Parameters vuoto
        def require_params_for(klass)
          require_params_for!(klass) rescue ActionController::Parameters.new({})
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
          format.html do
            flash.now[:error] = @object.errors.full_messages.join(',')
            render :action => :new
          end
          format.xml { render :xml => @object.errors, :status => :unprocessable_entity }
          format.inject { render :action => :edit, :layout => false }
        end

        def _successful_create(format)
          format.html { redirect_to edit_custom_polymorphic_path(@object), :notice => success_create_message(@object) }
          format.xml { render :xml => @object, :status => :created, :location => @object }
          format.inject { render :action => :success_create_show, :layout => false }
        end

        def _failed_update(format)
          format.html do
            flash.now[:error] = @object.errors.full_messages.join(',')
            render :action => :edit
          end
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

          install_search_class(search_class)
          development_search_setup_checks

          before_action :load_search, only: [:index]
        end


        def setup_search_controller(search_class: nil)
          install_search_class(search_class)
          development_search_setup_checks

          # Sul controller della ricerca, ridefiniamo la classe base, im modo che vada a trovare il modello della
          # classe di ricerca
          redefine_method :base_class do
            self.search_class.search_model
          end

        end

        protected

        def install_search_class(search_class_name = nil)
          # se passata la classe,
          if search_class_name
            define_singleton_method :search_class do
              search_class_name.to_s.constantize
            end
            delegate :search_class, to: :class
          end
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
                            namespace :#{self.search_class.search_model.name.to_s.pluralize.downcase } do
                              resources :searches, :only => [:index, :create]
                            end
                          ATTENZIONE deve essere sopra alla rotta della risorsa, altrimenti verrà mechata prima la
                          show del controller principale
                          ------------------
                          Oppure la classe specializzata del search_form_builder non ritorna correttamente una path"
              end
              #controlliamo pundit
              policy = Pundit::PolicyFinder.new(self.search_class).policy
              if policy
                unless policy.included_modules.include?(KonoUtils::BaseSearchFormPolicyConcern)
                  out << "- Nella policy #{policy.name} non hai incluso il concern: KonoUtils::BaseSearchFormPolicyConcern"
                end
              else
                out << "- Non hai definito la policy per la classe #{self.search_class.name}"
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
