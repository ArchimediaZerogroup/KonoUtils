require 'active_support/concern'
module KonoUtils::Concerns
  module BaseModals
    extend ActiveSupport::Concern

    def create
      authorize @obj if defined? Pundit
      save_response
    end

    def destroy
      authorize @obj if defined? Pundit
      @obj.destroy
      respond_to do |f|
        f.json { render json: {success: true} }
      end
    end


    def update
      authorize @obj if defined? Pundit
      @obj.assign_attributes(update_params)
      save_response
    end

    included do
      before_action :load_parent_assoc
      before_action :load_obj, :only => [:destroy, :update]

      private
      ##
      # Metodo promemoria per caricare il modello padre
      def load_parent_assoc
        @parent_model = nil
        raise 'Sovrascrivi funzione "load_parent_assoc" nei figli la definizione di questa variabile: @parent_model'
      end

      ##
      # Metodo promemoria per caricare l'oggetto dell'aggiornamento
      # ES:
      #    @obj = @person.person_contacts.find(params[:id])
      def load_obj
        @obj=nil
        raise 'Sovrascrivi funzione "load_obj" in figli la definizione di questa variabile: @obj'
      end

      ##
      # Metodo promemoria per pulire i parametri
      # ES:
      #   params.require(:person_contact).permit(:contacttype_id, :contact)
      def update_params
        raise 'Sovrascrivi in figli'
      end


      def render_part_to_json(partial, locals, status=200)
        render json: {
            partial: (
            render_to_string(
                :partial => partial,
                :layout => false, :locals => locals)
            )
        }, status: status
      end

      def save_response
        raise "Sovrascrivere:
              def save_response
                    respond_to do |f|
                      if @obj.valid?
                        @obj.save
                        f.json do
                          render_part_to_json('tikal_core/people/person_contacts/panel.html', {:contact => @obj})
                        end
                      else
                        f.json do
                          render_part_to_json('tikal_core/people/person_contacts/modal_form.html', {:contact => @obj, :id => ''}, 400)
                        end
                      end
                    end
                  end

              ed aggiungere se non già fatto:
              def create
                @obj = @person.person_contacts.build(update_params)
                super
              end
              def update_params
                params.require(:person_contact).permit(:contacttype_id, :contact)
              end
              "
      end
    end


  end
end