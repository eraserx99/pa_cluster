#! /usr/bin/env ruby
# This script writes the outputs of a Yahoo! LDA run to mysql
#

require 'active_record'
require 'yaml'

ROOT_DIR = File.expand_path('../', File.dirname(__FILE__))

def process_args
	abort("write_to_mysql <input_dir>") unless ARGV.length == 1
	@input_dir = ARGV[1] 
end

def initialize
	dbconfig = YAML::load_file( File.join( ROOT_DIR , 'db' , 'database.yml' ) )
	ActiveRecord::Base.establish_connection(dbconfig)
	Dir[ROOT_DIR + '/db/classes/*.rb'].each {|file| require file}
end

def store_run
	@log_file = File.join(@input_dir, 'lda_yahoo.log')

	File.open(@log_file).each_line do |line|
		if line.include? "RUN_ID = "
			run_name = line.split(' = ').last.strip
		elsif line.include? "NUM_TOPICS = "
			num_topics = line.split(' = ').last.strip.to_i
		elsif line.include? "NUM_ITER = "
			num_iter = line.split(' = ').last.strip.to_i
		elsif line.include? "MAX_DF = "
			max_df = line.split(' = ').last.strip.to_f
		elsif line.include? "MIN_DF = "
			min_df = line.split(' = ').last.strip.to_f
		elsif line.include? "FILTER = "
			filter = line.split(' = ').last.strip
		elsif line.include? "Total num of docs found:"
			num_docs = line.split(':').last.strip.to_i
		elsif line.include? "Total number of unique words found:"
			num_uniq_terms = line.split(':').last.strip.to_i
		elsif line.include? "Dictionary Initialized"
			break
		end
	end
end

def store_docs

end

def store_topics

end

process_args
initialize

store_run
