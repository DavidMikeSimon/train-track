# This file defines the offline envrionment
# "Offline" means that the application is running on a local network, with only a subset of the real online app's data
# It is implemented by the gem Offroad 

# Settings specified here will take precedence over those in config/environment.rb

# Use the offline database configuration file instead of the regular one
config.database_configuration_file = "config/offline_database.yml"

# In the development environment your application's code is reloaded on
# every request.  This slows down response time but is perfect for development
# since you don't have to restart the webserver when you make code changes.
config.cache_classes = false

# Log error messages when you accidentally call methods on nil.
config.whiny_nils = true

# Show full error reports and disable caching
config.action_controller.consider_all_requests_local = true
config.action_view.debug_rjs                         = true
config.action_controller.perform_caching             = false

# Don't care if the mailer can't send
config.action_mailer.raise_delivery_errors = false

require 'offroad'
Offroad::config_app_online(false)
