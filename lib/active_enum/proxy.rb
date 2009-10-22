module ActiveEnum

  # Borrowed and modified from the Roxy gem by Ryan Daigle.
  class Proxy
    alias :proxy_extend :extend
    
    instance_methods.each { |m| undef_method m unless m =~ /(^__|^proxy_)/ }
    
    def initialize(owner, target, args, enum)
      @owner, @target, @args, @enum = owner, target, args, enum
      proxy_extend EnumMethods
    end

    def proxy_target
      bound_method = @target.bind(@owner)
      bound_method.arity == 0 ? bound_method.call : bound_method.call(*@args)
    end
  
    # Delegate all method calls we don't know about to target object
    def method_missing(sym, *args, &block)
      if ActiveEnum.use_name_as_value
        self.name.__send__(sym, *args, &block)
      else
        proxy_target.__send__(sym, *args, &block)
      end
    end

  end
end
