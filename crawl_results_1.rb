require 'rubygems'
require 'open-uri'
require 'nokogiri'
require 'mechanize'
require 'cgi'

# INPUT: list of mechanize link objects


$agent = Mechanize.new
$useful_links = []


def fixlist(inplist)
  # remove spaces, remove nils, remove non-essential pieces
  #remove duplicates that don't make sense
  ## (maybe fix for unicode??)
  # return list without previously stated problems
  n = inplist.select {|x| x != " "}
  n = n.select {|x| x != ""}
  n = n.select {|x| x != nil}
  n.each do |f|
    f.strip!
  end
  n = n.uniq
  n
end


def submit_query(query_tag)
  baseurl = "https://www.google.com/search?q="
  if query_tag == "pow"
    query = %w{places of worship near detroit}.map { |w| CGI.escape(w) }.join("+")
  end # for right now only places of worship, not even an else
  page = $agent.get(baseurl+query)
  page
end

def get_results(mechanize_page)
  if $useful_links.length >= 400
  #if $useful_links.length >= 10 # test line
    return $useful_links
  end
  
  t = mechanize_page.links_with(:text => /(church|temple|worship|mosque|synagogue|hindu|islam|m(u|o)slim|lord|sanctuary|ministry)/i)
  puts t
  $useful_links += t
  puts $useful_links.length

  #useful_links.each {|l| puts l}

  if mechanize_page.link_with(:text => /Next/)
    n_pg = mechanize_page.link_with(:text => /Next/).click
  else
    return $useful_links
  end
  get_results(n_pg)
end

a = submit_query("pow")
tr = get_results(a)

####################


crawl_pgs = []
begin
tr.each do |l|
  crawl_pgs << l.click
end
rescue  Exception => e
  puts "Exception happened, called #{e}"
  # crawl page stuff for the combinations of address information and store each, or print each
end

#crawl_pgs.each do |c|
  #addr = /\d{1,3}.?\d{0,3}\s[a-zA-Z]{2,30}\s[a-zA-Z]{2,15}/
#  addr = /\b(\d{2,5}\s+)(?![a|p]m\b)(NW|NE|SW|SE|north|south|west|east|n|e|s|w)?([\s|\,|.]+)(([a-zA-Z|\s+]{1,30}){1,4})(court|ct|street|st|drive|dr|lane|ln|road|rd|blvd|ave|avenue|place|plc)/i # this works, but it doesn't get enough cos html etc
#  a = c.body.match(addr)
#  p a
#end

addr_texts = []
crawl_pgs.each do |pg|
  #p pg.uri.to_s
  url = pg.uri.to_s
  page = Nokogiri::HTML(open(url))
  #p page
  a = page.css('span').text 
  reg = /\b(\d{2,5}\s+)(?![a|p]m\b)(NW|NE|SW|SE|north|south|west|east|n|e|s|w)?([\s|\,|.]+)(([a-zA-Z|\s+]{1,30}){1,4})(court|ct|street|st|drive|dr|lane|ln|road|rd|blvd|boulevard|ave|avenue|place|plc)/i
  if a =~ reg
    ab = a.scan(reg)
    #p a.split("\n") # not the split, but this looks like good info! yay!
    #p ab # this gets me lists that are indiv word-segments of what looks like all/enough of the relevant addresses, but no names and also the format is bad b/c the st addrs themselves are split up
    ab.each do |ls|
      #lst = fixlist(ls)
      lst = fixlist(ls)
      quest = lst.map { |w| CGI.escape(w) }.join(" ")
      p quest # closer, need to take out extra spaces in the lists first and find out why error (see console)
    end
  end
  
end