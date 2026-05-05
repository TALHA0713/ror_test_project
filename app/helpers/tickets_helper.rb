module TicketsHelper
  def ticket_status_classes(status)
    case status
    when "open"
      "bg-blue-400/10 text-blue-300 border border-blue-400/20"
    when "in_progress"
      "bg-yellow-400/10 text-yellow-300 border border-yellow-400/20"
    when "resolved"
      "bg-green-400/10 text-green-300 border border-green-400/20"
    when "closed"
      "bg-gray-400/10 text-gray-300 border border-gray-400/20"
    else
      "bg-gray-400/10 text-gray-300 border border-gray-400/20"
    end
  end

  def ticket_priority_classes(priority)
    case priority
    when "urgent"
      "bg-red-400/10 text-red-300 border border-red-400/20"
    when "high"
      "bg-orange-400/10 text-orange-300 border border-orange-400/20"
    when "medium"
      "bg-indigo-400/10 text-indigo-300 border border-indigo-400/20"
    when "low"
      "bg-gray-400/10 text-gray-300 border border-gray-400/20"
    else
      "bg-gray-400/10 text-gray-300 border border-gray-400/20"
    end
  end

  def ticket_assigned_name(ticket)
    ticket.assigned_to_user&.name.presence || "Unassigned"
  end

  def ticket_due_date(ticket)
    ticket.due_date.present? ? ticket.due_date.strftime("%d %b %Y") : "Not set"
  end

  def user_initials(user)
    user.name.to_s.split.map { |part| part[0] }.join.first(2).upcase
  end
end
