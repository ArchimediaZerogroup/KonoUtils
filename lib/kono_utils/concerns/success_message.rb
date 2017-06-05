require 'active_support/concern'
module KonoUtils::Concerns
  module SuccessMessage

    extend ActiveSupport::Concern

    included do
      private
      def success_create_message(model)
        t('activerecord.successful.messages.created', :model => model.mn)
      end

      def success_update_message(model)
        t('activerecord.successful.messages.updated', :model => model.mn)
      end

      def success_destroy_message(model)
        t('activerecord.successful.messages.destroyed', :model => model.mn)
      end

    end


  end
end