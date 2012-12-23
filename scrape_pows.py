from bs4 import BeautifulSoup
import sys, os, urllib, urllib2, requests, json, pprint

api_key = "AIzaSyA9ozdIh2lFfp73XmWBJxjtfGY0NjGRMoQ" #changeable
baseurl = "https://www.googleapis.com/customsearch/v1?"

query = raw_input("Enter query")

params = {'q':query,'safe':'high','key':api_key,'client':'google-csbe','output':'xml_no_dtd'}
# this won't work, this is 
request = baseurl + urllib.urlencode(params)
print request
response = urllib2.urlopen(request).read()
result = json.dumps(response)


print pprint(result)

## !! v interesting
## http://ajax.googleapis.com/ajax/services/search/web?v=1.0&q=places+of+worship+near+detroit



