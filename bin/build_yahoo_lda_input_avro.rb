#! /usr/bin/env ruby
# This script builds a single concatenated file of all the input documents
# build_yahoo_lda_input <input_dir> <output_file> <filter>

require "rubygems"
require "bundler/setup"
require 'fileutils'
require 'patent_source'
require 'avro'

SCHEMA = <<-JSON
{ 
	"namespace": "com.patentagility",
	"type": "record",
  	"name": "document",
  	"fields" : [
    		{ "name": "id", "type": "string" },
    		{ "name": "id_aux", "type": "string" },
    		{ "name": "import_timestamp", "type": "string" },
    		{ "name": "contents", "type": "string" }
  	]
}
JSON

abort("build_yahoo_lda_input <input_dir> <output_dir> <filter>") unless ARGV.length == 3

input_dir = ARGV[0]
output_file = ARGV[1]
filter = ARGV[2].to_sym

# prepare output
FileUtils::mkdir_p File.dirname(output_file)
File.open(output_file, 'wb') do |out_f|

	schema = Avro::Schema.parse(SCHEMA)
	writer = Avro::IO::DatumWriter.new(schema)
	dw = Avro::DataFile::Writer.new(out_f, writer, schema)

	Dir.glob("#{input_dir}/**/*.txt") do |file_name|
		basename = File.basename(file_name, '.txt')
		parts = basename.split('-')
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
			dw << { "id" => basename, 
					"id_aux" => cls, 
					"import_timestamp" => Time.now.to_s,
					"contents" => File.read(file_name) }
		end
	end

end
