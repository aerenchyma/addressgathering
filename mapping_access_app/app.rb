

get "/" do
	
	haml :search
end


post "/search" do
	query = params["query"]
	location = params["location"]
	params["apb"] = query.length + location.length
	haml :index
end