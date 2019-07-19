module KonoUtils
  ##
  # Simple PORO to proxyng the pagination operations
  class PaginateProxer

    attr_accessor :collection

    def initialize(collection)
      @collection = collection
    end

    def paginate(params={})
      raise "TO Override with the correct pagination method of the gem used"
    end

  end
end