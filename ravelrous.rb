require 'rubygems'
require 'bundler/setup'

require 'mechanize'
require 'pry'


# Step 1: Visit each friend (and their friends) in a nested loop, storing all
# in ravelrites (by only visiting <name>/friends/people
#
# Step 2: (optional) gather profile information


### Login ################################


class Ravelry
  @@site = nil

  def self.site
    @@site ||= Mechanize.new
  end

  def self.login
    site.get "http://www.ravelry.com/"

    site.page.form["user[login]"]    = 'zeroeth'
    site.page.form["user[password]"] = 'w333333'
    site.page.form.submit
  end
end



### Individual ###########################

class Ravelrite
  attr_accessor :name
  attr_accessor :number_of_posts, :number_of_friends, :number_of_projects
  attr_accessor :friends

  attr_accessor :profile_retrieved

  @@ravelrites = {}


  def initialize
    self.profile_retrieved = false
    self.friends = []
  end


  def self.find_or_initialize(username)
    @@ravelrites[username] ||= Ravelrite.new
  end


  def self.find(username)
    @@ravelrites[username] || raise("Can't find #{username} in list")
  end


  def self.list
    @@ravelrites.values
  end
end



### Friend ###############################

class FriendCollector
  attr_accessor :seeds, :search_depth

  def initialize
    self.seeds = ["CodeCrafter"]
    self.search_depth = 1
  end


  def friends_of(username, current_depth = 0)
    puts "#{'-'*(current_depth+1)} getting friends of #{username}"

    page = Ravelry.site.get "http://www.ravelry.com/people/#{username}/friends/people"
    friend_links = page.parser.css("#friends_panel .avatar_bubble a")

    ravelrite = Ravelrite.find_or_initialize(username)
    ravelrite.name = username


    friend_links.each do |friend_link|
      name = friend_link["href"].gsub("/people/","")

      friend = Ravelrite.find_or_initialize(name)
      friend.name = name

      ravelrite.friends << friend

      # RECURSION ZONE
      friends_of(friend.name, current_depth + 1) if current_depth < search_depth
    end
  end


  def go
    self.seeds.each do |username|
      friends_of username
    end
  end
end



### Profile ##############################

class ProfileCollector
  def profile_of(username)
    page = Ravelry.site.get "http://www.ravelry.com/people/zeroeth"
    doc  = page.parser

    ravelrite = Ravelrite.find_or_initialize(username)
    ravelrite.number_of_projects = doc.css(".projects_option a"   ).last.text.match(/\d+/)
    ravelrite.number_of_friends  = doc.css(".friends_option a"    ).last.text.match(/\d+/)
    ravelrite.number_of_posts    = doc.css(".forum_posts_option a").last.text.match(/\d+/)
  end
end



### Graph ################################

class GraphvizDotfile
  attr_accessor :file

  def initialize
    self.file = File.open("friendships.dot", "w")
  end

  def friendship_of(username)
    ravelrite = Ravelrite.find username

    ravelrite.friends.each do |friend|
      file.puts "#{ravelrite.name} -> #{friend.name}"
    end
  end


  def generate
    file.puts "digraph {"

    Ravelrite.list.each do |ravelrite|
      puts "#{ravelrite.name} (#{ravelrite.friends.count})" if ravelrite.friends.count > 0
      friendship_of(ravelrite.name)
    end

    file.puts "}"

    file.close

    puts "friendship.dot written"
  end
end



### Run ##################################

Ravelry.login

FriendCollector.new.go

GraphvizDotfile.new.generate

# binding.pry
