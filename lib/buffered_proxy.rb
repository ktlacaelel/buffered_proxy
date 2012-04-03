class BufferedProxy

  def initialize object, proxy_methods, alias_methods = { :flush_method => :flush, :clear_method => :clear }
    @object       = object
    @instructions = []

    self.class.send :define_method, :add_0df791f42fefd98158a0d1f1b8e52dcd do |*target_arguments, &block|
      method = target_arguments.shift
      unless method.is_a?(Symbol)
        raise "Target method is not a symbol: #{method.inspect}"
      end
      unless @object.respond_to? method
        raise "Target does not respond to method: #{method}"
      end

      instruction = [method, target_arguments]
      instruction << block if block
      @instructions << instruction
    end

    proxy_methods.each do |method|
      self.class.send :define_method, method do |*arguments, &block|
        add_0df791f42fefd98158a0d1f1b8e52dcd method, *arguments, &block
      end
    end

    self.class.send :define_method, alias_methods[:flush_method] do
      @instructions.each do |instruction|
        method, arguments, block = instruction
        if block
          @object.send(method, *arguments, &block)
        else
          @object.send(method, *arguments)
        end
      end
      @instructions = []
    end

    self.class.send :define_method, alias_methods[:clear_method] do
      @instructions = []
    end

  end

end
