require 'sinatra'
require 'net/http'
require 'json'
require 'pry'
require 'crack'

get '/' do
  @params = {
    "address" => "",
    "city" => "",
    "state" => "",
    "zip" => ""
  }
  @param_errors = nil
  erb :index
end

post '/calculator' do
  my_response = request.body.read
  @params = get_params(my_response)
  @param_errors = validate_params(@params)

  if @param_errors
    erb :index
  else
    query = get_query(@params)

    uri = URI("http://www.zillow.com/webservice/GetSearchResults.htm"+query)
    res = Net::HTTP.get_response(uri)
    data = Crack::XML.parse(res.body)

    if data["SearchResults:searchresults"]["message"]["text"].include?("Error")
      @error = "There were no results for that address."
      @zillowData = nil
    else
      @error = nil
      @zillowData = data["SearchResults:searchresults"]["response"]["results"]["result"]
    end
    erb :results
  end
end

def get_params(data)
  data_array = data.split("&")
  my_params = Hash.new

  data_array.each do |element|
    element_array = element.split("=")
    key = element_array[0]
    value = element_array[1] ? element_array[1] : ""
    my_params[key] = value
  end

  return my_params
end

def validate_params(params)
  errors = nil

  proto_errors = []

  if params["address"] === ""
    proto_errors.push "Address cannot be empty."
  end

  params["address"] = params["address"].gsub("+"," ")

  if !/^\d{5}(-\d{4})?$/.match(params["zip"])
    if params["city"] === "" || params["state"] === ""
      proto_errors.push "Zip Code must be five digits."
    end
    if params["city"] === ""
      proto_errors.push "City cannot be empty."
    end
    if params["state"] === ""
      proto_errors.push "State cannot be empty."
    end
  end

  if proto_errors.size > 0
    errors = proto_errors
  end

  return errors
end

def get_query(params)
  address = params["address"]
  city = params["city"]
  state = params["state"]
  zip = params["zip"]

  addressQuery = address
  cityStateZipQuery = /^\d{5}(-\d{4})?$/.match(zip) ? zip : "#{city}%2C+#{state}"

  query = "?zws-id=X1-ZWz198oaiq7qq3_7x5fi&address=#{addressQuery}&citystatezip=#{cityStateZipQuery}"
end
