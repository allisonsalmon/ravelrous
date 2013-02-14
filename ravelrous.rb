require 'rubygems'
require 'bundler/setup'

require 'mechanize'
require 'pry'


# Step 1: Visit each friend (and their friends) in a nested loop, storing all
# in ravelrites (by only visiting <name>/friends/people
#
# Step 2: (optional) gather profile information


### Login ################################

agent = Mechanize.new
agent.get "http://www.ravelry.com/"

agent.page.form["user[login]"]    = 'zeroeth'
agent.page.form["user[password]"] = 'w333333'
agent.page.form.submit



### Individual ###########################

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



### List #################################

class RavelriteList
  @@ravelrites = {}

  def self.find_or_initialize(username)
    @@ravelrites[username] ||= Ravelrite.new
  end
end



### Friend ###############################

class FriendCollector
  attr_accessor :seeds, :search_depth

  def initialize
    self.seeds = ["CodeCrafter"]
    self.search_depth = 1
  end

  def friends_of(username, current_depth = 1)
    page = agent.get "http://www.ravelry.com/people/#{username}/friends/people"
    friend_links = page.parser.css("#friends_panel .avatar_bubble a")

    friend_links.each do |friend_link|
      name = friend_link["href"].gsub("/people/","")

      friend = ravelrites[name]
      if friend == nil
        friend = Ravelrite.new
        friend.name = name

        ravelrites[name] = friend
      end
    end

  end
end



### Profile ##############################

class ProfileCollector
  def profile_of(username)
    page = agent.get "http://www.ravelry.com/people/zeroeth"
    doc  = page.parser

    ravelrite = Ravelrite.find_or_initialize(username)
    ravelrite.number_of_projects = doc.css(".projects_option a"   ).last.text.match(/\d+/)
    ravelrite.number_of_friends  = doc.css(".friends_option a"    ).last.text.match(/\d+/)
    ravelrite.number_of_posts    = doc.css(".forum_posts_option a").last.text.match(/\d+/)
  end
end


binding.pry
