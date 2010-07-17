# Used by tar2rubyscript

require 'forwardable'
require 'iconv'

old_verbose, $VERBOSE = $VERBOSE, nil
ARGV = ["-e", "production"]
$VERBOSE = old_verbose

load 'script/server'
