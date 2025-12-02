module IconHelper
  def svg_icon(name, options = {})
    file = "#{Rails.root}/app/assets/images/#{name}.svg"
    return "(missing icon)" unless File.exist?(file)
    svg = File.read(file)
    # add classes if passed
    if options[:class]
      svg.sub!('<svg ', "<svg class=\"#{options[:class]}\" ")
    end
    svg.html_safe
  end
end
