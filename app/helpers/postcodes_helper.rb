module PostcodesHelper

  def postcode_format_links
    link_to('JSON', url_for(:action=>:show, :format=>:json))
    link_to('XML', url_for(:action=>:show, :format=>:xml))
    link_to('JS', url_for(:action=>:show, :format=>:js))
    link_to('CSV', url_for(:action=>:show, :format=>:csv))
    link_to('TEXT', url_for(:action=>:show, :format=>:txt))
    link_to('YAML', url_for(:action=>:show, :format=>:yaml))
  end
end
