module AdminHelper

  def link_to_edit_constituency constituency_name
    constituency = Constituency.find_by_name(constituency_name)
    if constituency
      link_to h(constituency_name), edit_constituency_path(constituency)
    else
      h(constituency_name)
    end
  end
end
