import urllib, urllib2, json
from googlemaps import GoogleMaps

api_key = "AIzaSyCLjDkQ2ChRBpduwgJScAZyd4ZGvKrY124"
gmaps = GoogleMaps(api_key)

#places_key = "AIzaSyAsBT4zcSEKzm_oZO5jSBHA3cyoD9T2Rt8"

baseurl = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?"
inp = raw_input("Enter food or pow\n")

address = raw_input("enter address\n")

params = {'radius':'50000','sensor':'true' }
#'key': api_key,

lat, lng = gmaps.address_to_latlng(address)
params['location'] = '%s,%s' % (lat,lng)

if inp == "pow":
    params['types'] = "place_of_worship|church|mosque|synagogue|hindu_temple"
elif inp == "food":
    params['types'] = "food|grocery_or_supermarket|bakery|cafe|meal_delivery|meal_takeaway|restaurant|shopping_mall"

def make_url_params(params):   
    api_key = "AIzaSyCLjDkQ2ChRBpduwgJScAZyd4ZGvKrY124" 
    url_params =  urllib.urlencode(params)
    request = baseurl + url_params + "key=%s&sensor=true" % (api_key)
    print request
    result = urllib2.urlopen(request).read()
    return json.loads(result)
    
#data = json.loads(result)
data = make_url_params(params)
print data
#print "request is", request
#print "HERE DATA"
#print data


### spreadsheet
f = open("test_sheet.csv", 'w+')

def add_data(data, fname):
    places = data["results"]
    places_list = []

    for place in places:
        tmp_list = []
        tmp_list.append(place["name"])
        tmp_list.append(place["vicinity"])
        tmp_list.append("ZIPHERE")
        places_list.append(tmp_list)
    
    for l in places_list:
        #tmpstr = l.join(",") + '\n'
        tmpstr = ",".join(l) + '\n'
        fname.write(tmpstr)


add_data(data, f)
#more_data = ""
#while True:
#try: 
#    #if data["next_page_token"] != None: # loop later if it works
#    params["pagetoken"] = data["next_page_token"]
#    n_data = make_url_params(params)
#    add_data(n_data, f)
#except KeyError:
#    print "try again"



# works, but when zip is included it goes with the state
# some don't include state or zip
# some include state but not zip
# some include both (few)
## so, need to check and take care of that