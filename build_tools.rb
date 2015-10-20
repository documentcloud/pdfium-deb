#!/usr/bin/env ruby

require 'rubygems'
require 'pathname'
begin
  require 'thor'
rescue
  puts "Please install thor (`gem install thor`)"
end

class PDFiumBuildTools < Thor
  HERE = File.dirname(__FILE__)
  CHANGELOG_PATH = File.join HERE, 'debian-config', 'changelog'
  
  UBUNTU_VERSION = "trusty"
  URGENCY = "low"
  
  desc "build PDFium package", "build PDFium package"
  def build(path_string = nil, target=:deb)
    puts `./BUILD.sh #{path_string}`
  end
  
  desc "update", "update"
  option :name
  option :email
  option :urgency
  def update(path_string=nil, target=:deb)
    @now             = Time.now.utc
    @committer_name  = options[:name]
    @committer_email = options[:email]
    @urgency         = options[:urgency]

    puts update_changelog
    #build(path_string, target)
  end
  
  private
  
  def update_changelog
    raise "Can't find changelog at #{CHANGELOG_PATH} so something's broken" unless File.exists? CHANGELOG_PATH
    contents = File.read(CHANGELOG_PATH)
    contents = generate_update + contents
    File.write(CHANGELOG_PATH, contents)
    "Changelog updated"
  end
  
  def generate_update
    update = <<-UPDATE
pdfium (#{version}) #{UBUNTU_VERSION}; urgency=#{urgency}

  * Pull latest source from upstream git repo

 -- #{committer}  #{timestamp}

UPDATE
  end
  
  def version
    # keep in sync with BUILD.sh
    @version ||= @now.strftime("%Y%m%d.%H%M%S")
  end
  
  def urgency
    @urgency || URGENCY
  end
  
  def committer_name
    @committer_name ||= `git config --global user.name`.chomp
  end
  
  def committer_email
    @committer_email ||= `git config --global user.email`.chomp
  end
  
  def committer_error_message(field)
    message = "unable to find user #{field} (either in your git config or via the commandline)."
    case field
    when :email
      message + %(  Set --email="your@email.address")
    when :name
      message + %(  Set --name="Your Name")
    end
  end
  
  def committer
    raise ArgumentError, committer_error_message(:name) unless committer_name and not committer_name.empty?
    raise ArgumentError, committer_error_message(:email) unless committer_email and not committer_email.empty?
    "#{committer_name} <#{committer_email}>"
  end
  
  def timestamp
    @now.strftime("%a, %d %b %Y %H:%M:%S %z")
  end
end

PDFiumBuildTools.start(ARGV)
