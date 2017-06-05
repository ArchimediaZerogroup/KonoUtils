require 'active_support/concern'
module KonoUtils

  module BaseEditingPolicyConcern
    extend ActiveSupport::Concern

    included do
      def permitted_attributes
        # [:descrizione]
        record.class.column_names.collect { |s| s.to_sym } - [:id, :created_at, :updated_at]
      end
    end

    if defined? ::Application::Scope
      class Scope < ::Application::Scope
        def resolve
          scope
        end
      end
    end

#  module ClassMethods

#  end
  end
end

