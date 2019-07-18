module KonoUtils
  module ApplicationHelper

    def self.included(base)
      KonoUtils.configuration.application_helper_includes.each do |m|
        base.send :include, m
      end
    end

  end
end