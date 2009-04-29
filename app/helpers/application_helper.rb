# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def link_to_admin_home
    link_to('Admin', admin_path)
  end

  def meta_description constituency
    if constituency
      if constituency.no_sitting_member?
        "No sitting member for #{h(constituency.name)} - UK Parliament"
      else
        "#{h(constituency.member_name)} is the sitting member for #{constituency.name} - UK Parliament"
      end
    else
      nil
    end
  end

  def sort_constituencies constituencies
    constituencies.sort! do |a,b|
      if a.name == 'Example'
        -1
      elsif b.name == 'Example'
        +1
      else
        a.name <=> b.name
      end
    end
    constituencies
  end
end
