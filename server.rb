require 'sinatra'
require 'net/http'
require 'json'
require 'pry'
require 'crack'

get '/' do
  erb :index
end

post '/calculator' do
  query = get_query(request.body.read)

  uri = URI("http://www.zillow.com/webservice/GetSearchResults.htm"+query)
  res = Net::HTTP.get_response(uri)
  data = Crack::XML.parse(res.body)

  @zillowData = data["SearchResults:searchresults"]["response"]["results"]["result"]
  erb :results
end

def get_query (data)
  data_array = data.split("&")

  my_params = Hash.new

  data_array.each do |element|
    element_array = element.split("=")
    key = element_array[0]
    value = element_array[1]? element_array[1] : ""
    my_params[key] = value
  end

  address = my_params["address"]
  city = my_params["city"]
  state = my_params["state"]
  zip = my_params["zip"]

  addressQuery = address

  cityStateZipQuery = if zip
      zip
    else
      "#{city}%2+#{state}"
    end

  query = "?zws-id=X1-ZWz198oaiq7qq3_7x5fi&address=#{addressQuery}&citystatezip=#{cityStateZipQuery}"
end
