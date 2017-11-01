# Load the Rails application.
require File.expand_path('../application', __FILE__)

# Initialize the Rails application.
Rails.application.initialize!
require "lib"
require "person_service"
require "csv"
require "bean"
