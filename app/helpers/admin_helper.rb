module AdminHelper

  def link_to_sent_in_month month
    link_to month.to_s(:month_year), url_for(:action=>'sent_by_month',:yyyy_mm=>month.strftime('%Y-%m') )
  end

  def link_to_edit_constituency constituency_name
    constituency = Constituency.find_by_name(constituency_name)
    if constituency
      link_to h(constituency_name), edit_constituency_path(constituency)
    else
      h(constituency_name)
    end
  end
end
