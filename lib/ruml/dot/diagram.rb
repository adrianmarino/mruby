require 'ruml/dot/options'
require 'ruml/dot/helper'
require 'ruml/dot/shape'
require 'ruml/extensions'

module Ruml::Dot
  class Diagram
    include Ruml::Dot::Helper

    def initialize(options = Ruml::Dot::Options.default)
      @shapes = []
      @options = options
    end

    def add_shape(type, name)
      shape = Ruml::Dot::Shape.class_from(type).new(name, @options)
      @shapes << shape
      shape
    end

    def build
      body = @shapes.map { |shape| shape.build(@shapes) }.join
      diagram(body)
    end

    private

    def diagram(content)
      dot_options = to_options(@options[:diagram])
      <<-DOT
digraph g {
  graph[#{dot_options}]
#{content}
}
DOT
    end
  end
end
