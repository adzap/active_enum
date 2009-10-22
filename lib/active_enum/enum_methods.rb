module ActiveEnum
  module EnumMethods

    def id
      # only return id value if exists in enum
      proxy_target if @enum.find_by_id(proxy_target)
    end

    def name
      @enum[proxy_target]
    end

    def enum
      @enum
    end

    def values
      @enum.values
    end

  end
end
