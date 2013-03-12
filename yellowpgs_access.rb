require 'rubygems'
require 'mechanize'
require 'nokogiri'
require 'open-uri'
require 'cgi'



$agent = Mechanize.new
query = "community center" # PICK QUERY HERE
location = "Wayne County, MI" # PICK LOCATION SEARCH HERE

page = $agent.get('http://yellowpages.com')
forms = page.forms
searchform = forms.first
searchform.search_terms = query 
searchform.geo_location_terms = location
results = $agent.submit(searchform)
start_pg = results.uri # this is the page to start scraping from
pg = Nokogiri::HTML(open(start_pg)) # Nokogiri document of the start page

$baseurl = "http://yellowpages.com"
$doc_hashes = []
$addrs_check = []

def dedupe_addrs(hash_list)
  unique_hashes = []
  check_addrs = Hash.new
  hash_list.each do |h|
    if !check_addrs.has_key?(h['addr'])
      unique_hashes << h
      check_addrs[h['addr']] = 1
    end
  end
  unique_hashes
end


  
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
  dedupe_addrs($doc_hashes)
  #p ded_a
end

def transform_hash(hn) # addrs is a list of hashes
  s = "#{hn['name']}, #{hn['addr']}, #{hn['city']}, #{hn['state']}, #{hn['zip']}, #{hn['phone']}\n"
  s
end

def today_string()
  t = Time.new
  yr = t.year
  mon = t.month
  day = t.day
  if t.month < 10
    mon = "0#{t.month}"
  end
  if t.day < 10
    day = "0#{t.day}"
  end
  yyyymmdd = "#{yr}#{mon}#{day}"
end

# filename happens below
# replace commented-out line with something else for TEMP_NAME if you want to call your query something else
#$fname = "TEMP_NAME"
$fname = today_string() + "-" + location.gsub!(",","").split(' ').map {|w| CGI.escape(w)}.join("") + query.split(' ').map {|w| CGI.escape(w)}.join("")
csv_header = %w{Name Address City State Zip Phone}.map {|w| CGI.escape(w) }.join(", ") + "\n"

hashed_infos = create_hashes(pg)

# due to following, may not overwrite file if it's readable -- will just add to it. Careful!
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
  file_num = 2
  hashed_infos[0..990].each do |h|
    f.write(transform_hash(h))
  end
  while hashed_infos.drop(991) != []
      hashed_infos = hashed_infos.drop(991) # redundant bad
      fnt = File.open($fname+"_#{file_num}.csv", 'a+')
      file_num += 1
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
## better and easier filters & information entry
## deduping across files (non-memory storage/other caching necessary)
## (another script? -- to take a set of .csv files, create one csv file with only unique entries
##       and then separate THAT out into individual <1000-len files) -- bash script? considering.
## appification


