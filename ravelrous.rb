require 'rubygems'
require 'bundler/setup'

require 'mechanize'
require 'pry'

agent = Mechanize.new

class Ravelrite
  attr_accessor :name
  attr_accessor :number_of_posts, :number_of_friends, :number_of_projects
  attr_accessor :friends

  attr_accessor :processed

  def initialize
    self.processed = false
    self.friends = []
  end
end


# LOGIN
agent.get "http://www.ravelry.com/"

agent.page.form["user[login]"]    = 'zeroeth'
agent.page.form["user[password]"] = 'w333333'
agent.page.form.submit

ravelrites  = {}
seed_users   = ["zeroeth"]
search_depth = 1


# GET PROFILE
page = agent.get "http://www.ravelry.com/people/zeroeth"
doc = page.parser

ravelrite = Ravelrite.new
ravelrite.name = "zeroeth"
ravelrite.number_of_projects = doc.css(".projects_option a").last.text.match(/\d+/)
ravelrite.number_of_friends  = doc.css(".friends_option a").last.text.match(/\d+/)
ravelrite.number_of_posts    = doc.css(".forum_posts_option a").last.text.match(/\d+/)

ravelrites[ravelrite.name] = ravelrite


# GO THROUGH ALL FRIENDS
page = agent.get "http://www.ravelry.com/people/CodeCrafter/friends/people"
friend_links = page.parser.css("#friends_panel .avatar_bubble a")

friend_links.each do |friend_link|
  name = friend_link["href"].gsub("/people/","")

  friend = ravelrites[name]
  if friend == nil
    friend = Ravelrite.new
    friend.name = name
    ravelrites[name] = friend
    ravelrite.friends << friend
  end
end

binding.pry


