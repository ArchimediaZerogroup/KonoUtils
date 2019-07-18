module KonoUtils
  module BaseEditingHelper

    def self.included(mod)
      KonoUtils.configuration.base_editing_helper_includes.each do |m|
        mod.send :include, m
      end
    end

  end
end