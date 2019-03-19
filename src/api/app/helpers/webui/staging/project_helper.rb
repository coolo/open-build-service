module Webui::Staging::ProjectHelper
  def icon_for_checks(checks, missing_checks)
    return 'fa-eye text-info' if missing_checks.present?
    return 'fa-check-circle text-primary' if checks.blank?
    return 'fa-eye text-info' if checks.any?(&:pending?)
    return 'fa-check-circle text-primary' if checks.all?(&:success?)
    'fa-exclamation-circle text-danger'
  end

  def unstaged_staged_request_history(history)
    capture do
      concat(link_to("##{history.bs_request.number}", request_path(history.bs_request.number)))
      concat(' for package ')
      concat(content_tag(:b, history.package_name))
      concat(' submitted by ')
      concat(content_tag(:b, history.user_name))
    end
  end

  def staging_project_created_history(history)
    capture do
      concat(content_tag(:b, "#{time_ago_in_words(Time.at(history.datetime.to_i))} ago"))
      concat(' by ')
      concat(content_tag(:b, history.user_name))
    end
  end
end
