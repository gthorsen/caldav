  class CaseController < ApplicationController
   require 'net/http'
   require 'net.rb'
   require 'socket'
   require 'uri'
   require 'securerandom'

   def index
    path = "/"
    begin
    Net::HTTP.start('localhost', 3500) do |http|
      request = Net::HTTP::Get.new("localhost:3500#{path}", initheader = {'Content-Type' => 'text/html'})
      request.body = ""
      stream = []
      http.request request do |response|
        response.read_body do |chunk|
          stream << chunk
        end
      end # Net::HTTPResponse object
      @response = stream.join("")
    end
    rescue Exception => e
     @response = e.message
    end
     @cases = @response.split(",")
   end


   def create
     first_name = params[:first_name]
     last_name = params[:last_name]
     email = params[:email]
     phone = params[:phone]
     question = params[:question]
     assigned_to = ["Graham", "Kevin", "Josh", "Joe", "David"].sample
  	path = "/"
    begin
    Net::HTTP.start('localhost', 3500) do |http|
      request = Net::HTTP::Put.new("localhost:3500#{path}", initheader = {'Content-Type' => 'text/html'})
      request.body = \
"BEGIN:VCALENDAR
PRODID:-//Hydro//NONSGML Hydro Server//EN
VERSION:2.0
X-PATRON-FIRST-NAME: #{first_name}
X-PATRON-LAST-NAME: #{last_name}
X-PATRON-EMAIL: #{email}
X-PATRON-PHONE: #{phone}
X-QUESTION: #{question}
X-DATE-CREATED: #{DateTime.new}
X-STATUS: New
X-ASSIGNED-TO: #{assigned_to}
X-CASE-TYPE: Submission
END:VCALENDAR"
      stream = []
      http.request request do |response|
        response.read_body do |chunk|
          stream << chunk
        end
      end # Net::HTTPResponse object
      @response = stream.join("")
    end
    rescue Exception => e
     @response = e.message
    end
    redirect_to :action => "index"
   end

   def show
    path = "/"  
    begin
    Net::HTTP.start('localhost', 3500) do |http|
      request = Net::HTTP::Get.new("localhost:3500#{path}", initheader = {'Content-Type' => 'text/html'})
      request.body = "uuid: #{params[:uuid]}"
      stream = [] 
      http.request request do |response|
        response.read_body do |chunk|
          stream << chunk
        end
      end # Net::HTTPResponse object
      @response = stream.join("")
    end
    rescue Exception => e
     @response = e.message
    end
     @response = @response.split("\n\r\n")
     @case_content = Hash.new
     @response.each do |property|
      unless property.split(': ')[1].blank?
        @case_content["#{(property.split(':')[0]).gsub(/X-/, '').downcase}"] = property.split(': ')[1]
      end
     end
      respond_to do |format|
        format.json  { render :json => @case_content }
     end
   end

   def find
    cal_name = params[:cal]	
    port = 3500
    host = "localhost"
    path = "/"

    req = Net::HTTP::Propfind.new(path, initheader = { 'Depth' => '0', 'Prefer' => 'return-minimal', 'Content-Type' => 'application/xml'})
    req.body = \
    '<d:propfind xmlns:d="DAV:" xmlns:cs="http://calendarserver.org/ns/" xmlns:c="urn:ietf:params:xml:ns:caldav">
    <d:prop>
    <d:displayname />
    <cs:getctag />
    </d:prop>
    </d:propfind>'
    response = Net::HTTP.new(host, port).start {|http| http.request(req) }
    @response = response.body
    respond_to do |format|
    		format.html # index.html.erb
    		format.xml  { render :xml => @response }
     end
   end
   def report
    uuid = params[:uuid]
    summary = params[:summary]	
    port = 3500
    host = "localhost"
    path = "/"

    req = Net::HTTP::Report.new(path, initheader = { 'Depth' => '1', 'Prefer' => 'return-minimal', 'Content-Type' => 'application/xml; charset=utf-8'})
    req.body = \
    "<C:calendar-query xmlns:D='DAV:' xmlns:C='urn:ietf:params:xml:ns:caldav'>
    <D:prop>
    <D:getetag/>
    <C:calendar-data/>
    </D:prop>
    <C:filter>
    <C:comp-filter name='VCALENDAR'>
    <C:comp-filter name='VEVENT'>

    </C:comp-filter>
    </C:comp-filter>
    </C:filter>
    </C:calendar-query>"
    response = Net::HTTP.new(host, port).start {|http| http.request(req) }
    @response = response.body
    respond_to do |format|
    		format.html # index.html.erb
    		format.xml  { render :xml => @response }
     end
   end

   def options
    cal_name = params[:cal] 
    port = 5232
    host = "localhost"
    path = "/#{cal_name}.ics/"

    req = Net::HTTP::Options.new(path, initheader = { 'Depth' => '1', 'Prefer' => 'return-minimal', 'Content-Type' => 'application/xml; charset=utf-8'})
    response = Net::HTTP.new(host, port).start {|http| http.request(req) }
    @response = response.get_fields "Allow"
    respond_to do |format|
        format.html # index.html.erb
        format.xml  { render :xml => @response }
      end
    end

    def create_content
      cal_name = params[:cal] 
      port = 3500
      host = "localhost"
      path = "/"

      req = Net::HTTP::Mkcontent.new(path, initheader = { 'Depth' => '0', 'Prefer' => 'return-minimal', 'Content-Type' => 'application/xml; charset=utf-8'})
      response = Net::HTTP.new(host, port).start {|http| http.request(req) }
      @response = response.body
      respond_to do |format|
        format.html # index.html.erb
        format.xml  { render :xml => @response }
      end
    end
  end
