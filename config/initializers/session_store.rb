# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_train-track_session',
  :secret      => '3ded24c69af10c6dde81b89682725fd0e740771e433e3f96f4f7aa67004c235c736a38613d1e410510a05d62f77ba0acf277a66571464253dfd09b10dce906b1'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
