$:.unshift File.dirname(__FILE__)

require "bundler"
Bundler.setup(:default, ENV["RACK_ENV"] || "development")

require "web"
run Web
