require 'rubygems'
require 'bundler/setup'

require 'mechanize'
require 'pry'

agent = Mechanize.new

class Ravelrite
  attr_accessor :number_of_posts, :number_of_friends, :number_of_projects
  attr_accessor :friend_list
end


# LOGIN
agent.get "http://www.ravelry.com/"

agent.page.form["user[login]"]    = 'zeroeth'
agent.page.form["user[password]"] = 'w333333'
agent.page.form.submit

ralvelrites  = []
seed_users   = ["zeroeth"]
search_depth = 1


# GET PROFILE
page = agent.get "http://www.ravelry.com/people/zeroeth"
doc = page.parser

ravelrite = Ravelrite.new
ravelrite.number_of_projects = doc.css(".projects_option a").last.text.match(/\d+/)
ravelrite.number_of_friends  = doc.css(".friends_option a").last.text.match(/\d+/)
ravelrite.number_of_posts    = doc.css(".forum_posts_option a").last.text.match(/\d+/)


# GO THROUGH ALL FRIENDS
page = agent.get "http://www.ravelry.com/people/zeroeth/friends"


binding.pry


