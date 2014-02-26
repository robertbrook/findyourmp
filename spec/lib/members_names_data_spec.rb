require './spec/spec_helper'
require './lib/members_names_data'

describe MembersNamesData do
  context 'when creating the object' do
    before do
      @fake_response = mock("Response")
      @fake_response.stub!(:body).and_return("<xml>sample</xml>")
    end
    
    it 'should use RestClient to fetch data from the web' do
      RestClient.should_receive(:get).and_return(@fake_response)
      MembersNamesData.new
    end
    
    it 'should default to the hardcoded url if none is supplied' do
      data_url = "http://data.parliament.uk/membersdataplatform/services/mnis/members/query/House=Commons/Addresses"
      RestClient.should_receive(:get).with(data_url).and_return(@fake_response)
      MembersNamesData.new
    end
    
    it 'should use the url param if one is supplied' do
      data_url = "http://www.theyworkforyou.com/"
      RestClient.should_receive(:get).with(data_url).and_return(@fake_response)
      MembersNamesData.new(data_url)
    end
  end
  
  context 'when asked for the TSV' do
    before do
      @fake_response = mock("Response")
      @fake_response.stub!(:body).and_return(%Q|
      <Members>
      <Member Member_Id="172" Dods_Id="25790" Pims_Id="3572">
      <DisplayAs>Ms Diane Abbott</DisplayAs>
      <ListAs>Abbott, Diane</ListAs>
      <FullTitle>Ms Diane Abbott MP</FullTitle>
      <DateOfBirth>1953-09-27T00:00:00</DateOfBirth>
      <DateOfDeath xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:nil="true"/>
      <Gender>F</Gender>
      <Party Id="15">Labour</Party>
      <House>Commons</House>
      <MemberFrom>Hackney North and Stoke Newington</MemberFrom>
      <HouseStartDate>1987-06-11T00:00:00</HouseStartDate>
      <HouseEndDate xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:nil="true"/>
      <CurrentStatus Id="0" IsActive="True">
      <Name>Current Member</Name>
      <Reason/>
      <StartDate>1987-06-11T00:00:00</StartDate>
      </CurrentStatus>
      <Addresses>
      <Address Type_Id="6">
      <Type>Website</Type>
      <IsPreferred>False</IsPreferred>
      <IsPhysical>False</IsPhysical>
      <Note/>
      <Address1>http://www.dianeabbott.org.uk</Address1>
      </Address>
      <Address Type_Id="1">
      <Type>Parliamentary</Type>
      <IsPreferred>False</IsPreferred>
      <IsPhysical>True</IsPhysical>
      <Note/>
      <Address1>House of Commons</Address1>
      <Address2/>
      <Address3/>
      <Address4/>
      <Address5>London</Address5>
      <Postcode>SW1A 0AA</Postcode>
      <Phone>000 0000 0000</Phone>
      <Fax>000 0000 0000</Fax>
      <Email>me@here.com</Email>
      <OtherAddress/>
      </Address>|)
    end
    
    it 'should format the member data properly' do
      RestClient.should_receive(:get).and_return(@fake_response)
      data = MembersNamesData.new()
      data.to_tsv.should == %Q|"Hackney North and Stoke Newington"\t"Ms Diane Abbott"\t"Labour"\t"http://www.parliament.uk/biographies/commons/Ms-Diane-Abbott/172"\t"me@here.com"\t"http://www.dianeabbott.org.uk"\t"True"|
    end
  end
end