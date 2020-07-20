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
        after_action :check_errors, only: [:create, :update]

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
        # Scope iniziale per index, sovrascrivibile per poter inizializzare ricerca,
        # viene passato al policy_scope in index
        def base_scope
          base_class
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
        end

        def _successful_destroy(format)
          format.html { redirect_to index_custom_polymorphic_path(base_class),
                                    :notice => success_destroy_message(@object) }
          format.xml { head :ok }
        end

        def _failed_create(format)
          format.html { render :action => :new }
          format.xml { render :xml => @object.errors, :status => :unprocessable_entity }
        end

        def _successful_create(format)
          format.html { redirect_to edit_custom_polymorphic_path(@object), :notice => success_create_message(@object) }
          format.xml { render :xml => @object, :status => :created, :location => @object }
        end

        def _failed_update(format)
          format.html { render :action => :edit }
          format.xml { render :xml => @object.errors, :status => :unprocessable_entity }
          format.inject { render :action => :edit, :layout => false }
        end

        def _successful_update(format)
          format.html { redirect_to edit_custom_polymorphic_path(@object), :notice => success_update_message(@object) }
          format.xml { head :ok }
          format.inject { render :action => :update, :layout => false }
        end
      end

      # module ClassMethods
      #
      #
      # end
    end
  end
end
