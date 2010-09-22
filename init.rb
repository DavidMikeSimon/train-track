# Used by tar2rubyscript

require 'forwardable'
require 'iconv'
require 'ftools'

old_verbose, $VERBOSE = $VERBOSE, nil
ARGV = ["-e", "production"]
$VERBOSE = old_verbose

Dir.chdir(File.dirname($0))

load 'script/server'
