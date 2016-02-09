module Ruml::Dot::Helper
  protected

  def to_options(options)
    options.map {|key, value| "#{key}=\"#{value}\"" }.join(' ') if options.any?
  end
end
