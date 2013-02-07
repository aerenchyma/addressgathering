

post "/" do
	query = params["query"]

	haml :index
end


get "/search" do
	query = params["query"]
	haml :search

end