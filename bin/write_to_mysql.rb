#! /usr/bin/env ruby
# This script writes the outputs of a Yahoo! LDA run to mysql
#

abort("write_to_mysql <input_dir>") unless ARGV.length == 1

input_dir = ARGV[1] 


