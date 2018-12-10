require 'sr/jimson/router/map'
require 'forwardable'

module Sr::Jimson
  class Router
    extend Forwardable

    ROUTER_DELEGATORS = [
      :handler_for_method, :root, :namespace,
      :jimson_methods, :strip_method_namespace
    ]

    def_delegators :@map, *ROUTER_DELEGATORS

    def initialize
      @map = Map.new
    end

    def draw(&block)
      @map.instance_eval(&block)
      self
    end

  end
end
