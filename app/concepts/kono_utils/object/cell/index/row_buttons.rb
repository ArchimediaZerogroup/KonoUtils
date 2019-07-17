module KonoUtils::Object::Cell # namespace
  class Index::RowButtons < Base # class

    def show
      bf = ActiveSupport::SafeBuffer.new
      bf << edit_button(edit_custom_polymorphic_path(model)) if policy(model).edit?
      bf << delete_button(index_custom_polymorphic_path(model)) if policy(model).destroy?
      bf
    end


  end
end