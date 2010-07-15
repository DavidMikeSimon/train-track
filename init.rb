# Used by tar2rubyscript

require 'forwardable'

old_verbose, $VERBOSE = $VERBOSE, nil
ARGV = ["-e", "production"]
$VERBOSE = old_verbose

load 'script/server'
