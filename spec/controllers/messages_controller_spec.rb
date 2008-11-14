require File.dirname(__FILE__) + '/../spec_helper'

describe MessagesController do

  before do
    @constituency_id = 801
    @constituency_name_part = 'Islington'
    @constituency_name = 'Islington South'
    @member_name = 'Hon Biggens'
    @constituency = mock_model(Constituency, :name => @constituency_name, :id => @constituency_id, :member_name => @member_name)
  end


end
