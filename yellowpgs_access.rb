require 'rubygems'
require 'mechanize'
require 'nokogiri'
require 'open-uri'
require 'cgi'



$agent = Mechanize.new
query = "places of worship" # PICK QUERY HERE
location = "Wayne County, MI" # PICK LOCATION SEARCH HERE

page = $agent.get('http://yellowpages.com')
forms = page.forms
searchform = forms.first
#searchform.search_terms = gets.chomp!
searchform.search_terms = query 
#searchform.geo_location_terms = gets.chomp!
searchform.geo_location_terms = location
results = $agent.submit(searchform)
start_pg = results.uri # this is the page to start scraping from
pg = Nokogiri::HTML(open(start_pg)) # Nokogiri document of the start page

$baseurl = "http://yellowpages.com"
$doc_hashes = []
  
def create_hashes(page)
  $place_names = page.css("h3").select{|xc| xc["class"] == "business-name fn org"}
  $addresses = page.css("span.street-address")
  $citynames = page.css("span.locality")
  $statenames = page.css("span.region")
  $zipcodes = page.css("span.postal-code")
  $phonenums = page.css("span.phone") # addition!
  count = 0
  while count < 30 do # 30 results per page default on yellowpages.com
    a = Hash.new
    begin
    a['name'] = $place_names[count].text.strip! 
    a['addr'] = $addresses[count].text.strip!.gsub!(",","") 
    a['city'] = $citynames[count].text
    a['state'] = $statenames[count].text
    a['zip'] = $zipcodes[count].text
    a['phone'] = $phonenums[count].text.strip! 
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
  s = "#{hn['name']}, #{hn['addr']}, #{hn['city']}, #{hn['state']}, #{hn['zip']}, #{hn['phone']}\n"
  s
end

$fname = "20130305_tricounty2_POW-try" # PICK FILE NAME HERE
csv_header = %w{Name Address City State Zip Phone}.map {|w| CGI.escape(w) }.join(", ") + "\n"

hashed_infos = create_hashes(pg)

begin
  f = File.open($fname+".csv", 'a+') 
  f.readline
rescue
  f.close
  f = File.open($fname+".csv", 'w+')
  f.write(csv_header)
end

if hashed_infos.length < 1000
  hashed_infos.each do |h|
    f.write(transform_hash(h))
  end
else
  add_num = 2
  hashed_infos[0..990].each do |h|
    f.write(transform_hash(h))
  end
  while hashed_infos.drop(991) != []
      hashed_infos = hashed_infos.drop(990)
      fnt = File.open($fname+"_#{add_num}.csv", 'a+')
      add_num += 1
      fnt.write(csv_header)
      hashed_infos[0..990].each do |h|
        fnt.write(transform_hash(h))
      end
  end

end

f.close
if fnt
  fnt.close
end


#### TODOS
## profile and improve
## better filters and information entry
## automatic deduping
## appification


