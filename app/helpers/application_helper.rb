# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def link_to_admin_home
    link_to('Admin', admin_path)
  end

end
