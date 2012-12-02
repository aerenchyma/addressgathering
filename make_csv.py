import urllib, urllib2, json, time
from googlemaps import GoogleMaps

# 1 - food (for testing)
# 2 - place of worship
## other categories To Be Added later, when these are reliably working, that's testing

# keeping everything type str in case

class OnePartCSV(object):
    def __init__(self, filename):
        self.addresses = ["660 Woodward, Detroit, MI 48226","6544 Highland Road, Waterford Township, MI","33222 Groespeck Hwy, Fraser, MI, 48026", "26 mile and Broughton Rd, Macomb, MI", "Inkster and Van Born Road, Dearborn Heights, MI, 48125"]
        self.categories = ["1","2"]
        self.api_key = "AIzaSyCLjDkQ2ChRBpduwgJScAZyd4ZGvKrY124"
        self.baseurl = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?"
        self.gmaps = GoogleMaps(self.api_key) # for full access -- if doesn't work do it later
        self.params = {'radius':'50000','sensor':'false'} # if doesn't work change false->true
        self.csv = open("%s" % filename, 'w+') #hmm is this a good idea?
    
    def create_req_res(self):
        url_params = urllib.urlencode(params)
        request = self.baseurl + url_params + "&key=%s&sensor=true" % (self.api_key)
        # print request
        result = urllib2.urlopen(request).read()
        return json.loads(result)
    
    def add_data(self, data_dict): # data_dict is what self.create_req_res returns.. (this smells like bad OO design)
        places = data_dict["results"]
        places_list = []
        for place in places:
            # still need some data correction, e.g. for state and zip
            tmp_list = []
            tmp_list.append(place["name"])
            tmp_list.append(place["vicinity"])
            #tmp_list.append(str(place["geometry"]["location"]["lat"]))
            #tmp_list.append(str(place["geometry"]["location"]["lng"]))
            places_list.append(tmp_list)
        for l in places_list:
            tmpstr = ",".join(l) + '\n'
            tmpstr = tmpstr.encode('utf8')
            self.csv.write(tmpstr)
    
    def set_up_get(self, category):
        print self.categories
        inp = raw_input("Enter category to create csv\n")
        if inp == "1":
            params['types'] = "food|grocery_or_supermarket|bakery|cafe|meal_delivery|meal_takeaway|restaurant|shopping_mall"
        elif inp == "2":
            params['types'] = "place_of_worship|church|mosque|synagogue|hindu_temple"
                       
    # this is the tough one :\
    def do_each_address(self): # this may need refactoring
        for addr in self.addresses:
            lat, lng = gmaps.address_to_latlng(address)
            params['location'] = '%s,%s' % (lat,lng)
    
    def loop_pages(self):
        # before this happens need to set up the params, like did in the non-OO script
        n_data = self.create_req_res()
        while True:
            try: 
                #if data["next_page_token"] != None: # loop later if it works
                params["pagetoken"] = n_data["next_page_token"]
                time.sleep(3)
                n_data = self.create_req_res()
                self.add_data(n_data, f)
            except KeyError:
                print "try again"
            try: n_data["next_page_token"]
            except KeyError: break