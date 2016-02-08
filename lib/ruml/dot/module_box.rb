require 'active_support/inflector'
require 'ruml/dot/association'

module Ruml::Dot
  class ModuleBox
    attr_reader :name

    def initialize(name)
      @members = Hash.new { |hash, key| hash[key] = [] }
      @name = name
    end

    def module(action, module_name)
      module_name = module_name == 'self' ? @name : module_name
      @members[action] << module_name
      self
    end

    def attribute(attribute, type)
      @members[:attributes] << [attribute.gsub(':', ''), type]
      self
    end

    def method(method_name, params, type = :instance)
      @members[:methods] << [method_name, params, type]
      self
    end

    def build(objects = [])
      build_box
      build_associations(objects)
      @content
    end

    protected

    def assoc
      Ruml::Dot::Association
    end

    def append_assoc(assoc)
      @content += "\s\s#{assoc}\n"
    end

    def build_associations(objects)
      append_inclusion(:include)
      append_inclusion(:extend)
      append_compositions(objects)
    end

    private

    def append_compositions(objects)
      objects.each do |object|
        associations = @members[:attributes].map do |attr, _type|
          [ attr.singular? ? :one : :many, object.name ] if attr.singularize == object.name.downcase
        end.compact
        associations.each { |type, object_name| append_assoc(assoc.composition(@name, type, object_name)) }
      end
    end

    def build_box
      begin_box
      append_attributes
      append_methods
      end_box
    end

    def begin_box
      @content = "\s\s\"#{@name}\"[label = \"{#{@name} (Mod)"
    end

    def end_box
      @content += "}\"]\n"
    end

    def append_attributes
      separator(:attributes)
      @content = @members[:attributes].inject(@content) do |content, (member, type)|
        content + "(#{type.to_s}) #{member}\\l"
      end
    end

    def append_methods
      separator(:methods)
      @content = @members[:methods].inject(@content) do |content, (name, params, type)|
       signature = type == :class ? '.' : '#'
       signature += name
       signature += "(#{params.join(', ')})" if params.any?
       content + "#{signature}\\l"
     end
    end

    def separator(member)
      @content += "|" if @members[member].any?
    end

    def append_inclusion(member)
      @members[member].each { |module_name| append_assoc(assoc.inclusion(member, @name, module_name)) }
    end
  end
end
