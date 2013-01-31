#! /usr/bin/env ruby
# This script builds a single concatenated file of all the input documents
# build_yahoo_lda_input <input_dir> <output_file> <filter>

require 'fileutils'
require 'patent_source'

abort("build_yahoo_lda_input <input_dir> <output_dir> <filter>") unless ARGV.length == 3

input_dir = ARGV[0]
output_file = ARGV[1]
filter = ARGV[2].to_sym

# prepare output
FileUtils::mkdir_p File.dirname(output_file)
File.open(output_file, 'w') do |out_f|

	Dir.glob("#{input_dir}/**/*.txt") do |file_name|
		parts = File.basename(file_name, '.txt').split('-')
		id = parts[0]
		cls = parts[1]

		# check filter
		should_write = false
		if filter == :all
			should_write = true
		elsif filter == :cpr
			should_write = PatentSource::COMPUTER_CLASSES.include? cls.strip
		end

		if should_write
			out_f.write "#{id} #{cls} #{File.read(file_name)}\n"
		end
	end

end
