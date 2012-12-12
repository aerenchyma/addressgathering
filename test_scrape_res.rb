## get addresses from google results

require 'rubygems'
require 'cgi'
require 'open-uri'
require 'hpricot'

#inp = gets.chomp!
q = %w{places of worship near detroit}.map { |w| CGI.escape(w) }.join("+")
url = "http://www.google.com/search?q=#{q}" #hmm
doc = Hpricot(open(url).read)
res_url = (doc/"div[@class='g'] a").first["href"]
system 'open #{res_url}'