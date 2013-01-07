require 'rubygems'
require 'mechanize'
require 'nokogiri'
require 'open-uri'
require 'cgi'

$agent = Mechanize.new
page = $agent.get('http://yellowpages.com')
forms = page.forms
searchform = forms.first
#searchform.search_terms = gets.chomp!
searchform.search_terms = "muslim"
#searchform.geo_location_terms = gets.chomp!
searchform.geo_location_terms = "Detroit, MI"
results = $agent.submit(searchform)
start_pg = results.uri # this is the page to start scraping from
pg = Nokogiri::HTML(open(start_pg)) # Nokogiri document of the start page


$place_names = pg.css("h3").select{|xc| xc["class"] == "business-name fn org"}
$addresses = pg.css("span.street-address")
$citynames = pg.css("span.locality")
$statenames = pg.css("span.region")
$zipcodes = pg.css("span.postal-code")


$baseurl = "http://yellowpages.com"
$doc_hashes = []
  
def create_hashes(page)
  $place_names = page.css("h3").select{|xc| xc["class"] == "business-name fn org"}
  $addresses = page.css("span.street-address")
  $citynames = page.css("span.locality")
  $statenames = page.css("span.region")
  $zipcodes = page.css("span.postal-code")
  count = 0
  while count < 30 do # 30 results per page default on yellowpages.com
    a = Hash.new
    begin
    a['name'] = $place_names[count].text.strip! 
    a['addr'] = $addresses[count].text.strip!.gsub!(",","") 
    a['city'] = $citynames[count].text
    a['state'] = $statenames[count].text
    a['zip'] = $zipcodes[count].text
    # NB. don't use .strip! if not needed, or will break -> nil where there actually is info
  rescue Exception => e
    break
  else
    count += 1
    $doc_hashes << a
  end
  end
  #pp $doc_hashes
  if page.css("li.next")
    sel = page.css("li.next a").map {|link| link['href']}
    n_url = sel[0]
    if n_url
      n_pg = Nokogiri::HTML(open($baseurl + n_url))
      create_hashes(n_pg)
    end
  end
  $doc_hashes
end

def transform_hash(hn) # addrs is a list of hashes
  s = "#{hn['name']}, #{hn['addr']}, #{hn['city']}, #{hn['state']}, #{hn['zip']}\n"
  s
end

$fname = "test_pow_3.csv"
csv_header = %w{Name Address City State Zip}.map {|w| CGI.escape(w) }.join(", ") + "\n"

hashed_infos = create_hashes(pg)

f = File.open($fname, 'a+') 
if f.readline != %w{Name Address City State Zip}.map {|w| CGI.escape(w) }.join(", ") + "\n"
  f.write(csv_header)
end


hashed_infos.each do |h|
  f.write(transform_hash(h))
end

f.close


#### TODOS
## in CSVs -- filters
## easy option to add to csv with command? -- this is an issue for Sinatra app
## other problem: functional without access to command line? --> Sinatra
## could be faster -- profile and improve

## FILTERS:
## no duplicates (remove duplicate addresses, but not other duplicates)
## nothing (?) if state is not MI
## other filters desired that could be done programtically/by Excel macro?
## ways of making human check easier? (bolding unusual entries? def'n of unusual?)

