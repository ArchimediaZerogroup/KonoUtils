module KonoUtils
  module ParamsHashArray
    extend ActiveSupport::Concern

    included do
      ##
      # Si occupa di trasformare un hash con elementi che sono chiramente array in un hash con elementi array:
      #
      # {"DatiOrdineAcquisto"=>{"0"=>{"RiferimentoNumeroLinea"=>{"0"=>""}, "IdDocumento"=>"", "Data"=>"", "NumItem"=>"", "CodiceCommessaConvenzione"=>"", "CodiceCUP"=>"", "CodiceCIG"=>""}}}
      # {"DatiOrdineAcquisto"=>[{"RiferimentoNumeroLinea"=>[""], "IdDocumento"=>"", "Data"=>"", "NumItem"=>"", "CodiceCommessaConvenzione"=>"", "CodiceCUP"=>"", "CodiceCIG"=>""}]}
      #
      def elaborate_params_to_hash_array(params)

        out = params
        ##Controllo se abbiamo solamente chiavi che rappresentano numeri
        if params.is_a?(Hash)

          if params.keys.select { |k| !(k.to_s.match(/\A[+-]?\d+?(\.\d+)?\Z/) == nil ? false : true) }.length==0
            out = []
            params.each_value do |v|
              out << elaborate_params_to_hash_array(v)
            end
          else
            out={}
            params.keys.each do |k|
              out[k.to_sym] = elaborate_params_to_hash_array(params[k])
            end
          end
        end

        Rails.logger.debug "DEBUG #{out.inspect}"
        out
      end
    end

  end
end