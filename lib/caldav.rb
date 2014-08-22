class CalDav
 require 'net/http'
 require 'net'

  def make_cal
  	uri = URI('http://localhost:8888/SabreDAV/server.php/cases/')
	Net::HTTP.start(uri.host, 8888) do |http|
	  request = Net::HTTP::Mkcalendar.new uri

	  response = http.request request # Net::HTTPResponse object
  end
  
end