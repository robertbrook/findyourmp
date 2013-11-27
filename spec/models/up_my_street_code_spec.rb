require './spec/spec_helper'

describe UpMyStreetCode do
  
  describe "when asked for constituency url slug" do
    it "should return nil when passed a blank code" do
      UpMyStreetCode.find_constituency_url_slug("").should == nil
    end
    
    it "should return nil when passed an invalid code" do
      UpMyStreetCode.find_constituency_url_slug("rubbish").should == nil
    end
    
    it "should return 'spelthorne' when passed '436'" do
      UpMyStreetCode.find_constituency_url_slug("436").should == "spelthorne"
    end
  end

end