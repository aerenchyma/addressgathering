require 'rubygems'
require 'cgi'

fname = "20130321-WayneCountyMIcommunitycenter.csv" # change this to whatever the FULL FILE name is you want to search in
f = File.open(fname, 'r+')

category_word_lines = []
cat_word = "romulus" # change this to whatever word you want to search for

f.each do |ln|
  if ln.downcase.split(",")[2].include?(cat_word.downcase) # 'if the cat_word is in the name of the place'
    # change the 2 to a 0 for searching the place name (in above line)
    # change the 0 to a 2 for searching the city
    # etc!
    category_word_lines << ln
  end
end

new_name = "#{fname[0..-5]}-#{cat_word}.csv"
p new_name
newt = File.new(new_name, "w") 
# filename will be [previousfilename]-[new category word].csv
csv_header = %w{Name Address City State Zip Phone}.map {|w| CGI.escape(w) }.join(", ") + "\n"
newt.write(csv_header)

category_word_lines.each do |n|
  newt.write(n)
end

f.close
newt.close
