require File.expand_path(File.dirname(__FILE__) + '/timer')

module FindYourMP; end

module FindYourMP::CacheWriter

  def make_cache
    total = Postcode.count.to_f
    index = 0
    group_size = 1000

    include ActionView::Helpers::DateHelper

    offset = index * group_size

    TEMPLATE = %Q|<html>
  <head>
    <title>Find your constituency</title>
    <style>body {font-size:2em;margin: 5% 10%;} #search input {font-size:1.5em;} a {text-decoration:none;}</style>
  </head>
  <body>
    <div id='search'>
      <form action="/" method="get">
        <input id="postcode" name="postcode" type="text" value="" />
        <input name="commit" type="submit" value="SEARCH" />
      </form>
    </div>|
TEMPLATE2 = %Q|    <p style='float: right'>|
TEMPLATE3 = %Q|    </p>
  </body>
</html>|

    Dir.mkdir("public/postcodes") unless File.exist?("public/postcodes")
    start_timing
    while offset < total
      postcodes = Postcode.find(:all, :offset => offset, :limit => group_size, :include => {:constituency => :member})
      postcodes.each do |postcode|
        dir = "public/postcodes/#{postcode.code_prefix}"
        filename = "#{dir}/#{postcode.code}.html"
        html = []

        unless File.exist?(filename) || postcode.constituency_id == 800 || postcode.constituency_id == 900
          begin
            write_to_file html, postcode, dir, filename
          rescue Exception => e
            $stderr.puts e.to_s
          end
        end
      end
      index = index.next
      offset = index * group_size
      percentage_complete = offset / total
      log_duration percentage_complete
    end
  end

  def write_to_file html, postcode, dir, filename
    html << TEMPLATE
    html << %Q|    <p>POSTCODE<br/><strong>#{postcode.code_with_space}</strong></p>|
    html << %Q|    <p>CONSTITUENCY<br/><strong>#{postcode.constituency_name} (#{postcode.constituency_id})</strong></p>|
    if postcode.member_name
      html << "<p>MEMBER<br/><strong>#{postcode.member_name}</strong></p>"
    else
      html << "<p>NO RECORDED MEMBER</p>"
    end
    html << TEMPLATE2
    html << %Q|      <a href="/postcodes/#{postcode.code}.xml">XML</a>|
    html << %Q|      <a href="/postcodes/#{postcode.code}.json">JSON</a>|
    html << %Q|      <a href="/postcodes/#{postcode.code}.js">JS</a>|
    html << %Q|      <a href="/postcodes/#{postcode.code}.csv">CSV</a>|
    html << %Q|      <a href="/postcodes/#{postcode.code}.txt">TEXT</a>|
    html << %Q|      <a href="/postcodes/#{postcode.code}.yaml">YAML</a>|
    html << TEMPLATE3
    Dir.mkdir(dir) unless File.exist?(dir)
    File.open(filename, 'w') { |f| f.write(html.join("\n")) }
    html.clear
  end

end
