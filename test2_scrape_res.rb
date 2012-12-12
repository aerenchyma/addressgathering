require 'rubygems'
require 'open-uri'
require 'nokogiri'
require 'mechanize'
require 'cgi'
require 'sqlite3'

$agent = Mechanize.new
$useful_links = []


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
  #if $useful_links.length >= 15 # test line
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


def to_something(str)
  duck = (Integer(str) rescue Float(str) rescue Time.parse(str) rescue nil)
  duck.nil? ? str : duck
end


$db = SQLite3::Database.open "links_test.db"
a = submit_query("pow")
tr = get_results(a)

$db.execute "DROP TABLE IF EXISTS Links"
$db.execute "CREATE TABLE IF NOT EXISTS Links(Link TEXT)"
begin
tr.each do |l|

  #st = l.to_s[1]
  st = l.uri.to_s

  if st
    $db.execute "INSERT INTO Links VALUES('" + st + "')" #Exception "unrecognized character '#'" every time...
  end
  puts "got past a db command"
end
  rescue SQLite3::Exception => e
    puts "Exception, #{e}"
end
  
#  puts "Exception occurred"
#  puts e
#ensure
#  $db.close if $db 
#end

#begin
 # stm = $db.execute "SELECT * FROM LINKS"
#  puts stm
#end

puts "END"#tr
puts "length #{tr.length}"

# get addresses from these links
# take out the ones that aren't in MI
# for that may want to check if "Detroit" is actually on the page near the address
# then take out duplicates

### POSSIBLE REGEX

## street address: /\d{1,3}.?\d{0,3}\s[a-zA-Z]{2,30}\s[a-zA-Z]{2,15}/
