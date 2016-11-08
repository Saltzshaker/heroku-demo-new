require 'active_support/all'
require 'sinatra'
require 'sinatra/activerecord'
require 'json'
require 'sequel'
require 'sqlite3'
require_relative './models/class_info_point.rb'
require_relative './models/course_link.rb'
# require "active_support/core_ext"
require 'haml'
require 'builder'
# require 'annotate_models'

# enable sessions for this project
enable :sessions

set :database, "sqlite3:db/class_info_db.db"


configure do
  set :slack, "http://onlineprototypes2016.slack.com/"
  set :site, 'https://daraghbyrne.github.io/onlineprototypes2016/'
  set :repo, 'https://github.com/daraghbyrne/onlineprototypes2016repo'

  set :class_time_tuesday_start, Time.new( 2016, 10, 25, 12, 00 )
  set :class_time_tuesday_end, Time.new( 2016, 10, 25, 14, 50 )
  set :office_hours_start, Time.new(2016, 10, 27, 12, 00)
  set :office_hours_end, Time.new(2016, 10, 27,  14, 00)

  set :links, ["https://medium.com/ideo-stories/chatbots-ultimate-prototyping-tool-e4e2831967f3#.3pif99l08", "http://www.bloomberg.com/news/articles/2015-09-17/who-needs-an-interface-anyway-", "https://digit.co", "https://getmagic.com", "https://hirepeter.com", "http://callfrank.org", "https://twitter.com/slashgif", "http://pentametron.com", "https://twitter.com/NYTMinusContext", "https://slack.getbirdly.com", "https://developer.amazon.com/alexa", "https://www.producthunt.com/@rrhoover/collections/invisible-apps"]

end


# For the root path / return a 422 error
# Alternatively redirect it to the title endpoint
# i.e. don’t allow a response from this route (see below)


get "/course_links" do
  CourseLink.all.to_json
end

# not working
# curl -X POST --data http://localhost:8080/course_links
post "/course_links" do
  link = CourseLink.new
  link.title = "Slash gif"
  link.url = "https://twitter.com/slashgif"
  new_link = CourseLink.last.to_json
  new_link
end

get "/course_links/:id" do

  id = params[:id]
  CourseLink.find(id).to_json

end

### question: is it ok to customize the param names? or is there another way to access based on the HTTP method? ###
# put "/course_links/:url/:title" do
  # will update the url and title of the link

    ### question: does this need to be the link from the previous endpoint?###
    # link_to_update = CourseLink.find(id) ?

    # url = params[:url]
    # title = params[:title]
    # link_to_update.update(url: url)
    # link_to_update.update(title: title)

# end
#
# delete "/course_links/:id" do
  # id = params[:id]
  # link_to_destroy = CourseLink.find(id)
  # link_to_destroy.destroy
# end

get "/" do

  redirect to('/title')

end


# Define an endpoint called title that returns
#a string that matches the full title of this course

get "/title" do

  { title: "Programming for Online Prototypes"}.to_json
end

# Define an endpoint called catalog_description that
# returns a full catalog description of the course

get "/catalog_description" do

  { catalog_description: "An introduction to rapidly prototyping web-based products and services.\
 This 7-week experience will teach students the basics of web development for online services.\
 Specifically, well focus on lightweight,<br/>minimal UI, microservices\
 (e.g. bots, conversational interfaces, platform integrations, designing micro-interactions, etc.)\
 We'll introduce and examine these new web service trends and interactive experiences.\
 Students will learn through instructor led workshops and hands-on experimentation.\
 As an intro level course, no knowledge of programming is needed.\
 By the end of the course, students will be able to design, prototype and deploy their own web-delivered services.\
" }.to_json
end

#Define an endpoint called units that
#returns the number of units of the course

get "/units" do
  {units: 6.to_s}.to_json
end

#Define an endpoint called instructor that
#returns the name of the instructor, email address and Slack id
#Suggested: Explore objects as a
# better way to return this information

get "/instructor" do

  name = "Daragh Byrne"
  email = "daragh@daraghbyrne.me"
  slack_str = "@daragh"

  #or

  { name: name, email: email, slack: slack_str }.to_json

end


# Parameters and Conditions
#
# Hint You’ll need to use conditional logic
# (if elsif else end statements) to make this bit work.
#
# Add a configuration block and provide settings that
# defines three links (to the course slack, the main site
# and the github repository). Then,
#
# Define a endpoint called link_to that takes one parameter
# named item and that will return one of the three links.
# It should respond with the appropriate url
# if the paramter equals “slack”, “site”, or “repo”.
# If it doesn’t receive any of these,
# it should return a default message.


get "/link_to/:item" do

  if params[:item] == "slack"
    slack = settings.slack
    { slack:slack }.to_json
  elsif params[:item] == "site"
    site = settings.site
    { site:site}.to_json
  elsif params[:item] == "repo"
    repo = settings.repo
    { repo:repo}.to_json
  else
    400
  end
end


# Add an endpoint to look up meeting times for the course.
#
# Define an endpoint called meeting_times that takes one parameter
# If the parameter is a string matching “class”, it will return the class times
# If the parameter is a string matching “officehours”, it will return the office hour times
# Explore: If you’re feeling adventurous try working with date and time objects in Ruby for this part.

get "/meeting_times/:item" do

  if params[:item] == "class"
    #"Tueday 12:00PM-02:50PM"

    # Using StrfTime we can format a date time
    # http://apidock.com/ruby/DateTime/strftime
    #settings.class_time_tuesday_start.strftime( "%A %H:%M" ) + " - " + settings.class_time_tuesday_end.strftime( "%H:%M" )

    start_str = settings.class_time_tuesday_start.strftime( "%A %H:%M" )
    end_str = settings.class_time_tuesday_end.strftime( "%A %H:%M" )
    duration = ( settings.class_time_tuesday_end - settings.class_time_tuesday_start  ) / 60

    { start: start_str, end: end_str, duration_mins: duration }.to_json

  elsif params[:item] == "officehours"
    #"Thursday 12:00PM-02:00PM"
    #settings.office_hours_start.strftime( "%A %H:%M" ) + " - " + settings.office_hours_end.strftime( "%H:%M" )

    start_str = settings.office_hours_start.strftime( "%A %H:%M" )
    end_str = settings.office_hours_end.strftime( "%A %H:%M" )
    duration = (settings.office_hours_end - settings.office_hours_start ) / 60

    { start: start_str, end: end_str, duration_mins: duration }.to_json

  else
    400
  end
end

# Dynamic
#
# We’ll explore some more advanced but richer ways to add some interactivity and dynamic data through date and time, conditions and arrays.
#
# Create an endpoint that lets someone know if we’re in class or not.
#
# Define a endpoint called in_session that takes no paramters
# Use Time.now * to look up the time on the server
# Use Time.new * to create a time instance for the beginning and end of each meeting times
# Use conditions (if statements) to test if the course is meeting
# Respond with “Yes” or “No”


get "/in_session" do

	session_start_time = Time.new( 2016, 11, 1, 12, 00 )
  session_end_time = session_start_time + 2.hour + 50.minutes


  #1_hour = 24 * 60 * 60 * 2
  #2.hours + 56.minutes + 3.days


  is_in_session = false
  time_now = Time.now


  (1..8).each do |i|

    if time_now >= session_start_time and time_now <= session_end_time
      is_in_session = true
      #eturn "YES"
    end

    session_start_time = session_start_time + 7.days
    session_end_time = session_end_time + 7.days

  end

  if is_in_session == true
      "Yes"
  else
      "No"
  end

  { now: time_now, in_session: is_in_session, in_session_string: ( is_in_session ? "YES" : "NO" ) }.to_json

end

# 2) Return a random link
#
# Create an array that contains a list of strings. Each string is a URL to a link from the Resources page of the site.
# Add this array to the setting configuration for the site.
# Define an endpoint called interesting_link that returns one of those links each time it’s called
# Hint: .sample is a useful method on array that will pick an item from it at random.

get "/interesting_link" do
  # get a random link

  # link = CourseLink.order("RANDOM()").first
  link = CourseLink.all.sample(1).first.to_json

  # get the last three links viewed
  # viewed = last_three_views
  #
  return_string = "Try this link: #{link}<br/>"
  # return_string += "<br/>Recently Viewed"
  # viewed.each_with_index do |view, index|
  #   return_string += "<br/>#{index+1}. #{view}"
  # end
  #
  # # add the link to the list of viewed
  viewed link.to_json
  return_string
  # display the links

end



def viewed link


  session[:viewed] ||= []

  # if session[:viewed].nil?
  #   session[:viewed] = []
  # end

  session[:viewed] << link

end

def last_three_views
  session[:viewed] ||= []
  session[:viewed].last( 3 )
end


# handle a 403 error
# See: http://www.restapitutorial.com/httpstatuscodes.html

error 403 do
  halt 403, {error: "Access forbidden"}.to_json
end

error 400 do
  halt 400, {error: "Bad Request. The parameters you provided are invalid"}.to_json
end

error 422 do
   {error: "Bad Request. The parameters you provided are invalid"}.to_json
end

get "/italics" do
  {italics: "<i>This is in italics</i>"}.to_json
end

get "/getmax/:num/:num2/:num3" do
  nums = [params["num"],params["num2"],params["num3"]]
  nums.max.to_json

end
