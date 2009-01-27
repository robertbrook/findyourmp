Before do
  Postcode.delete_all
  Constituency.delete_all
  Constituency.connection.execute('delete from slugs;')

  Given 'there is a postcode "AB101AA" in constituency "Aberdeen North", ons id "801"'
  Given 'there is an MP "Frank Doran" in constituency "Aberdeen North"'

  Given 'there is a postcode "ML14BW" in constituency "Motherwell and Wishaw", ons id "846"'
  Given 'there is an MP "Mr Frank Roy" in constituency "Motherwell and Wishaw"'

  Given 'there is a postcode "AB101BE" in constituency "Aberdeen South", ons id "802"'
  Given 'there is an MP "Miss Anne Begg" in constituency "Aberdeen South"'

  Given 'there is a postcode "KY8 5XY" in constituency "Glenrothes", ons id "835"'
  Given 'there is no MP in constituency "Glenrothes"'

  Given 'there is a postcode "GY1 1AB" with no constituency'
end

Given /^there is a postcode "(.*)" with no constituency$/ do |postcode_code|
  Postcode.find_or_create_by_code_and_constituency_id_and_ons_id(postcode_code.gsub(' ','').strip, nil, 900)
end

Given /^there is a postcode "(.*)" in constituency "(.*)", ons id "(.*)"$/ do |postcode_code, constituency_name, ons_id|
  constituency = Constituency.find_or_create_by_name_and_ons_id(constituency_name, ons_id)
  postcode = Postcode.find_or_create_by_code_and_constituency_id_and_ons_id(postcode_code.gsub(' ','').strip, constituency.id, ons_id)
end

Given /^there is an MP "(.*)" in constituency "(.*)"$/ do |member_name, constituency_name|
  constituency = Constituency.find_by_name(constituency_name)
  constituency.member_name = member_name
  constituency.member_email = member_name.tr(' ','').tableize.singularize + '@parl.uk'
  constituency.member_visible = true
  constituency.save
end

Given /^there is no MP in constituency "(.*)"$/ do |constituency_name|
  constituency = Constituency.find_or_create_by_name(constituency_name)
  if constituency.member_name
    constituency.member_name = nil
    constituency.save
  end
end
