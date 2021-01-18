module KonoUtils
  class Configuration
    attr_accessor :google_api_key
    attr_accessor :application_helper_includes
    attr_accessor :base_editing_helper_includes
    attr_accessor :pagination_proxer

    #@return [KonoUtils::SearchFormBuilder]
    attr_accessor :search_form_builder

    def initialize
      @application_helper_includes = []
      @base_editing_helper_includes = []
      @pagination_proxer = PaginateProxer
      @search_form_builder = SearchFormBuilder
    end
  end
end