require 'rubygems'
require 'mechanize'
require 'nokogiri'
require 'open-uri'

$agent = Mechanize.new
page = $agent.get('http://yellowpages.com')
forms = page.forms
searchform = forms.first
#searchform.search_terms = gets.chomp!
searchform.search_terms = "Veternary Services"
#searchform.geo_location_terms = gets.chomp!
searchform.geo_location_terms = "Detroit, MI"
results = $agent.submit(searchform)
start_pg = results.uri # this is the page to start scraping from

## name, after <h3 class="business-name fn org" + bunch of other stuff before end tag
## address, within <span class="street-address">, below the former mess
## and then there is:

## <span class="city-state"><span class="locality">Detroit</span>,
##<span class="region">MI</span>
##<span class="postal-code">48227</span>
##</span>
##</span>

## for each

## then to go to the next page,

## original url is something like
## http://www.yellowpages.com/detroit-mi/places-of-worship?g=Detroit%2C+MI&q=places+of+worship
## next page url adds param as such:
## http://www.yellowpages.com/detroit-mi/places-of-worship?g=Detroit%2C+MI&page=2&q=places+of+worship

pg = Nokogiri::HTML(open(start_pg))
#p pg.css("span[class='locality']").text #City names (all)
#p pg.css("span[class='region']").text # State abbrv (all)
#p pg.css("span[class='postal-code']").text # zip code (all)
#p pg.css("h3[class='business-name fn org']").text.gsub!(/\s+/, "") #names without spaces (all) -- but note that this is not an iterable..

#citynames = pg.css("span").select{|nm| nm["class"] == "locality"}
#citynames.each{|nm| puts nm.text}

$place_names = pg.css("h3").select{|xc| xc["class"] == "business-name fn org"}
$addresses = pg.css("span.street-address")
$citynames = pg.css("span.locality")
$statenames = pg.css("span.region")
$zipcodes = pg.css("span.postal-code")
#citynames.each {|nm| puts nm.text}

# so this works. want to collect all the information into an array doc each time

places_info = []

#h3_string = "business-name fn org"
#place_names = pg.css("h3").select{|xc| xc["class"] == "business-name fn org"}

#place_names.each {|x| puts x.text.strip!}

$baseurl = "http://yellowpages.com"
$doc_hashes = []
#while pg.css("li.next")
  
  
def create_hashes(page)
  $place_names = page.css("h3").select{|xc| xc["class"] == "business-name fn org"}
  $addresses = page.css("span.street-address")
  $citynames = page.css("span.locality")
  $statenames = page.css("span.region")
  $zipcodes = page.css("span.postal-code")
  count = 0
  while count < 30 do #30 results per page default on yellowpages.com
    a = Hash.new
    begin
    a['name'] = $place_names[count].text.strip! 
    a['addr'] = $addresses[count].text.strip! # this is where it goes nil when there's nothing
    a['city'] = $citynames[count].text
    a['state'] = $statenames[count].text
    a['zip'] = $zipcodes[count].text
    # NB. don't use .strip! if not needed, or will break -> nil where there actually is info
  rescue Exception => e
    break
  else
    count += 1
    $doc_hashes << a
    pp a
  end
  end
  #p $doc_hashes
  if page.css("li.next")
    sel = page.css("li.next a").map {|link| link['href']}
    #pp sel
    n_url = sel[0]
    if n_url
      n_pg = Nokogiri::HTML(open($baseurl + n_url))
      create_hashes(n_pg)
    end
  end
  #p $doc_hashes
end

create_hashes(pg)

# YAY

## create CSVs -- how to handle?
## in CSVs -- want to remove duplicate addresses (yes?)


#test_stuff.each do |yz|
#  c_name = test_stuff.css("span.locality")
#  s_name = test_stuff.css("span.region")
#  c_name.each {|x| p x.text}
#  s_name.each {|y| p y.text}
#end

