# Be sure to restart your server when you modify this file.

# Monkey patch remove those annoying log entries about the 'sqlite_master' table
module SqliteCleaningLogAdder
  def add(severity, message = nil, progname = nil, &block)
    corpus = ""
    corpus += message if message
    corpus += program if progname
    val = yield if block_given?
    corpus += val if val
    
    taboo = "WHERE type = 'table' AND NOT name = 'sqlite_sequence'"
    super unless corpus.include? taboo
  end
end

ActiveRecord::Base.logger.extend SqliteCleaningLogAdder