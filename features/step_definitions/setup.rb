Before do
  Postcode.delete_all
  Constituency.delete_all
  Constituency.connection.execute('delete from slugs;')
  PostcodeDistrict.delete_all

  Given 'there is a postcode "AB101AA" in constituency "Aberdeen North", ons id "801"'
  Given 'there is an MP "Frank Doran" in constituency "Aberdeen North"'

  Given 'there is a postcode "ML14BW" in constituency "Motherwell and Wishaw", ons id "846"'
  Given 'there is an MP "Mr Frank Roy" in constituency "Motherwell and Wishaw"'

  Given 'there is a postcode "AB101BE" in constituency "Aberdeen South", ons id "802"'
  Given 'there is an MP "Miss Anne Begg" in constituency "Aberdeen South"'

  Given 'there is a postcode "KY8 5XY" in constituency "Glenrothes", ons id "835"'
  Given 'there is no MP in constituency "Glenrothes"'

  Given 'there is a postcode "GY1 1AB" with no constituency'
  
  Given 'there is a postcode "BT35 8DL" in constituency "Newry & Armagh", ons id "711"'
  Given 'there is an MP "Conor Murphy" in constituency "Newry & Armagh"'
  
  Given 'there is a postcode "BT35 6QY" in constituency "Upper Bann", ons id "717"'
  Given 'there is an MP "David Simpson" in constituency "Upper Bann"'
  
  Given 'there is a postcode district "BT35" that links to constituencies "upper-bann" and "newry-armagh"'

  unless User.find_by_login('admin')
    user = User.new(:login => 'admin', :password => 'admin', :password_confirmation => 'admin', :email=>'example@bogus.com')
    user.save!
  end
  
  Message.delete_all
  message = Message.new({
      :message => 'test',
      :sender_email => 'x@y.co.uk',
      :postcode => 'AB101AA',
      :constituency_id => Constituency.find('aberdeen-north').id,
      :sender_is_constituent => '1',
      :sender => 'x',
      :subject => 'test'
  })
  message.save!
  message.mailer_error = "535 5.7.8 Error: authentication failed: authentication failure" 
  message.attempted_send = true
  message.created_at = Date.new(2009,1,1)
  message.save!

  message = Message.new({
      :message => 'test',
      :sender_email => 'x@y.co.uk',
      :postcode => 'AB101AA',
      :constituency_id => Constituency.find('aberdeen-north').id,
      :sender_is_constituent => '1',
      :sender => 'x',
      :subject => 'test'
  })
  message.save!
  message.sent = true
  message.created_at = Date.new(2009,2,1)
  message.save!
end

Given /^there is a postcode "(.*)" with no constituency$/ do |postcode_code|
  Postcode.find_or_create_by_code_and_constituency_id_and_ons_id(postcode_code.gsub(' ','').strip, nil, 900)
end

Given /^there is a postcode "(.*)" in constituency "(.*)", ons id "(.*)"$/ do |postcode_code, constituency_name, ons_id|
  constituency = Constituency.find_or_create_by_name_and_ons_id(constituency_name, ons_id)
  postcode = Postcode.find_or_create_by_code_and_constituency_id_and_ons_id(postcode_code.gsub(' ','').strip, constituency.id, ons_id)
end

Given /^there is a postcode district "(.*)" that links to constituencies "(.*)" and "(.*)"$/ do |district, constituency1, constituency2|
  constituency_id = Constituency.find(constituency1).id
  PostcodeDistrict.find_or_create_by_district_and_constituency_id(district, constituency_id)
  constituency_id = Constituency.find(constituency2).id
  PostcodeDistrict.find_or_create_by_district_and_constituency_id(district, constituency_id)
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
