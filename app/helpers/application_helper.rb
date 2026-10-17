module ApplicationHelper
  STATUS_LABELS = {
    "draft" => "Taslak",
    "pending" => "Onay bekliyor",
    "approved" => "Onaylandı",
    "rejected" => "Reddedildi"
  }.freeze

  def approval_status_label(document)
    label = STATUS_LABELS.fetch(document.status, document.status.humanize)
    document.overdue? ? "#{label} (gecikmiş)" : label
  end

  def approval_status_class(document)
    "status-badge status-#{document.status}"
  end

  def next_action_label(document, at: Time.current)
    {
      overdue: "Gecikmiş",
      urgent: "Acil",
      normal: "Normal"
    }.fetch(document.next_action_priority(at: at))
  end

  def next_action_class(document, at: Time.current)
    "priority-badge priority-#{document.next_action_priority(at: at)}"
  end

  def due_time_label(document, at: Time.current)
    seconds = document.seconds_until_due(at: at)
    return "—" unless seconds

    duration = compact_duration(seconds.abs)
    seconds.negative? ? "#{duration} gecikti" : "#{duration} kaldı"
  end

  def onayflow_datetime(time)
    return "—" unless time

    I18n.l(time.in_time_zone(onayflow_time_zone), format: :onayflow, locale: :tr)
  end

  def onayflow_time_zone_label
    "Türkiye saati (UTC#{onayflow_time_zone.now.formatted_offset})"
  end

  def role_label(user)
    user.manager? ? "Yönetici" : "Çalışan"
  end

  private

  def onayflow_time_zone
    Time.find_zone!(Rails.configuration.time_zone)
  end

  def compact_duration(seconds)
    total_minutes = [ (seconds / 60.0).ceil, 1 ].max
    days, remaining_minutes = total_minutes.divmod(24 * 60)
    hours, minutes = remaining_minutes.divmod(60)

    parts = []
    parts << "#{days} g" if days.positive?
    parts << "#{hours} sa" if hours.positive?
    parts << "#{minutes} dk" if minutes.positive? && days.zero?
    parts.any? ? parts.join(" ") : "1 dk"
  end
end
