module ApplicationHelper
  # Renders the first error message for a field below an input
  def field_error(object, field)
    errors = object.errors[field]
    return if errors.empty?

    content_tag(:p, errors.first, class: "mt-1.5 text-xs text-red-400")
  end

  # Returns extra border classes when a field has errors
  def field_border(object, field)
    object.errors[field].any? ? "border-red-400/50" : "border-white/10"
  end
end
