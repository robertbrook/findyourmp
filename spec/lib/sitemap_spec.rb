require File.dirname(__FILE__) + '/../spec_helper'
require File.dirname(__FILE__) + '/../../lib/sitemap'

describe SiteMapEntry, 'when created' do

  it 'should set last modification' do
    entry = SiteMapEntry.new 'location', 'date', 'hostname'
    entry.last_modification.should == 'date'
  end

  it 'should set location by adding protocal and host' do
    entry = SiteMapEntry.new 'location', 'date', 'hostname'
    entry.location.should == "http://hostname/location"
  end

  it 'should leave location unaltered if it already has http protocol and host' do
    url = 'http://findyourmp.parliament.uk/location'
    entry = SiteMapEntry.new url, 'date', 'hostname'
    entry.location.should == url
  end

end

describe SiteMap do

  it 'should return empty? with value of empty attribute' do
    map = SiteMap.new 'hostname'
    map.stub!(:empty).and_return true
    map.empty?.should be_true
    map.stub!(:empty).and_return false
    map.empty?.should be_false
  end

  describe 'when populating sitemap xml text' do
    before do
      @map = SiteMap.new 'hostname'
    end
    describe 'when empty array of pages are passed in' do
      it 'should set empty? to true' do
        @map.populate_sitemap 'name', []
        @map.empty?.should be_true
      end
    end

    describe 'when non-array of pages are passed in' do
      before do
        @date = 'last_modification'
        @location = 'location'
        @entry = SiteMapEntry.new @location, @date, 'hostname'
        @name = 'name'
        @map.populate_sitemap @name, [@entry]
      end
      it 'should set most_recent_modification date' do
        @map.most_recent_modification.should == @date
      end
      it 'should set location' do
        @map.location.should == "public/sitemap.xml.gz"
      end
      it 'should set sitemap xml text' do
        @map.site_map.should == %Q|<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
<url><loc>http://hostname/#{@location}</loc><lastmod>#{@date}</lastmod></url>
</urlset>\n|
      end
    end

    describe 'when sitemap is for a model class' do
      it 'should create map based on model instance urls' do
        map = ConstituencySiteMap.new 'hostname'

        date = Date.new(2009,1,1)
        resource = mock('resource', :friendly_id => 'islington', :name => 'Islington', :updated_at => date, :id => 1)
        Constituency.should_receive(:find).with(:all).and_return [resource]

        entry0 = mock('entry')
        entry = mock('entry')

        map.should_receive(:new_entry).with('').and_return entry0
        map.should_receive(:url_for).with({:controller => "constituencies", :action => "show", :id => 1, :host=>"hostname"}).and_return 'constituencies/islington'
        map.should_receive(:new_entry).with('constituencies/islington',date).and_return entry

        map.should_receive(:populate_sitemap).with('constituencies', [entry0, entry])
        map.create_sitemap
      end
    end
  end
  
  describe 'when initializing in subclass' do
    it 'should set a model type' do
      [ConstituencySiteMap].each do |type|
        map = type.new 'hostname'
        map.model.name.should == type.name.sub('SiteMap','')
      end
    end
  end
  
  describe 'when creating entry representing sitemap' do
    it 'should create entry with location and modification date' do
      most_recent = mock('most_recent_modification')
      
      map = SiteMap.new 'hostname'
      map.stub!(:location).and_return 'public/location'
      map.stub!(:most_recent_modification).and_return most_recent
      
      entry = mock('entry', :stub => "foo")
      SiteMapEntry.should_receive(:new).with('location', most_recent, 'hostname').and_return entry
      map.entry.should == entry
    end
  end
  
  describe 'when writing out sitemap' do
    before do
      @map = SiteMap.new 'hostname'
      @map.stub!(:empty?).and_return false
      @sitemap_text = 'sitemap text'
      @map.stub!(:site_map).and_return mock('site_map', :site_map=> @sitemap_text, :location => 'public/sitemap.xml.gz')
    end
    
    it 'should raise exception if there are no entries' do
      @map.stub!(:empty?).and_return true
      lambda { @map.write_to_file! }.should raise_error(Exception)
    end
    
    it 'should write_to_zip the file' do
      file = mock('file')
      file.should_receive(:write).with @sitemap_text
      Zlib::GzipWriter.should_receive(:open).with('public/sitemap.xml.gz').and_yield file
      
      @map.write_to_file!
    end
  end

end