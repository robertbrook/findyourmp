require File.dirname(__FILE__) + '/../spec_helper'

describe ConstituenciesController do

  before do
    @constituency_id = 801
    @constituency_name_part = 'Islington'
    @constituency_name = 'Islington South'
    @member_name = 'Hon Biggens'
    @constituency = mock_model(Constituency, :name => @constituency_name, :id => @constituency_id, :member_name => @member_name)
  end

  # describe "when asked for 'mail to constituency MP' page" do
    # def do_get
      # get :mail, :id => @constituency_id
    # end
#
    # describe 'and constituency is found' do
      # before do
        # Constituency.stub!(:find).and_return @constituency
      # end
#
      # get_request_should_be_successful
      # should_render_template 'mail'
#
      # it 'should find constituency by id' do
        # Constituency.should_receive(:find).with(@constituency_id.to_s).and_return @constituency
        # do_get
      # end
      # it 'should assign constituency to view' do
        # do_get
        # assigns[:constituency].should == @constituency
      # end
      # it 'should assign constituency member_name to view' do
        # do_get
        # assigns[:member_name].should == @member_name
      # end
    # end
  # end
end
