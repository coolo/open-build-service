# rubocop:disable Metrics/ModuleLength
module Webui::UserHelper
  def user_actions(user)
    safe_join(
      [
        link_to(user_edit_path(user.login)) do
          content_tag(:i, nil, class: 'fas fa-edit text-secondary pr-1', title: 'Edit User')
        end,
        mail_to(user.email) do
          content_tag(:i, nil, class: 'fas fa-envelope text-secondary pr-1', title: 'Send Email to User')
        end,
        link_to(user_delete_path(user: { login: user.login }), method: :delete, data: { confirm: 'Are you sure?' }) do
          content_tag(:i, nil, class: 'fas fa-times-circle text-danger pr-1', title: 'Delete User')
        end
      ]
    )
  end

  # This method is migrated to Webui2 (and refactored) with the name: image_tag_for
  # @param [User] user object
  def user_image_tag(user, opt = {})
    alt = opt[:alt] || user.try(:realname)
    alt = user.try(:login) if alt.empty?
    size = opt[:size] || 20
    if user.try(:email) && ::Configuration.gravatar
      url = "https://www.gravatar.com/avatar/#{Digest::MD5.hexdigest(user.email.downcase)}?s=#{size}&d=wavatar"
    else
      url = 'default_face.png'
    end
    image_tag(url, width: size, height: size, alt: alt, class: opt[:css_class])
  end

  def _optional_icon(user, opt)
    if opt[:no_icon]
      ''
    else
      # user_icon returns an ActiveSupport::SafeBuffer and not a String
      user_image_tag(user)
    end
  end

  def _printed_name(user, role, opt)
    real_name = user.try(:realname)
    if real_name.empty? || opt[:short]
      printed_name = user.login.dup
    else
      printed_name = "#{real_name} (#{user.login})"
    end
    printed_name << " as #{role}" if role
    printed_name
  end

  # @param [String] user login of the user
  # @param [String] role title of the login
  # @param [Hash]   options boolean flags :short, :no_icon
  def user_and_role(user, role = nil, options = {})
    opt = { short: false, no_icon: false }.merge(options)
    user = User.not_deleted.find_by(login: user)

    icon = _optional_icon(user, opt)
    printed_name = _printed_name(user, role, opt)

    # It's necessary to concat icon and $variable and don't use string interpolation!
    # Otherwise we get a new string and not an ActiveSupport::SafeBuffer
    if !User.session
      icon + printed_name
    else
      icon + link_to(printed_name, user_show_path(user))
    end
  end

  def user_with_realname_and_icon(user, opts = {})
    defaults = { short: false, no_icon: false }
    opts = defaults.merge(opts)

    user = User.find_by_login(user) unless user.is_a?(User)
    return '' unless user

    Rails.cache.fetch([user, 'realname_and_icon', opts, ::Configuration.first]) do
      realname = user.realname

      if opts[:short] || realname.empty?
        printed_name = user.login
      else
        printed_name = "#{realname} (#{user.login})"
      end

      if opts[:no_icon]
        link_to(printed_name, user_show_path(user))
      else
        user_image_tag(user) + ' ' + link_to(printed_name, user_show_path(user))
      end
    end
  end

  def requester_str(creator, requester_user, requester_group)
    # we don't need to show the requester if he is the same as the creator
    return if creator == requester_user
    if requester_user
      "the user #{user_with_realname_and_icon(requester_user, no_icon: true)}".html_safe
    elsif requester_group
      "the group #{requester_group}"
    end
  end

  def user_is_configurable(configuration, user)
    configuration.ldap_enabled? && !user.ignore_auth_services?
  end

  def max_activity_items(max_items, items_array)
    max_items += 1 if items_array.size == (max_items + 1)
    max_items
  end

  def activity_date_commits_project(commit_line)
    project, packages, count = commit_line

    if packages.size == 1
      single_package = packages.first.first
      return capture do
        concat pluralize(count, 'commit')
        concat ' in '
        concat link_to("#{project} / #{single_package}", package_show_path(project, single_package))
      end
    end

    max_packages = max_activity_items(3, packages)
    capture do
      concat pluralize(count, 'commit')
      concat ' in '
      concat link_to(project, project_show_path(project))
      content_tag(:ul, class: 'mt-1') do
        packages = packages.sort_by { |_, c| -c }
        packages[0..(max_packages - 1)].each do |package, pcount|
          content_tag(:li) do
            concat pluralize(pcount, 'commit')
            concat ' in '
            concat link_to package, package_show_path(project, package)
          end
          count -= pcount
        end
      end
      diff = packages.size - max_packages
      content_tag(:li, "and #{pluralize(count, 'commit')} in #{pluralize(diff, 'package')} more") if diff > 0
    end
  end

  def activity_date_commits(projects)
    return content_tag('h6', activity_date_commits_project(projects.first), class: 'mt-3') if project.size == 1

    max_projects = max_activity_items(3, projects)

    content_tag('h6', class: 'mt-3') do
      concat pluralize(projects.map(&:last).sum, 'commit')
      content_tag('ul') do
        projects[0..(max_projects - 1)].each do |commit_row|
          content_tag('li', activity_date_commits_project(commit_row), class: 'mt-1')
        end
        diff = projects.size - max_projects
        content_tag('li', "and in #{pluralize(diff, 'project')} more", class: 'mt-1') if diff > 0
      end
    end
  end
end
# rubocop:enable Metrics/ModuleLength
