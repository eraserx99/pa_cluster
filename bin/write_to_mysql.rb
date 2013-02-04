#! /usr/bin/env ruby
# This script writes the outputs of a Yahoo! LDA run to mysql
#

ROOT_DIR = File.expand_path('../', File.dirname(__FILE__))

def process_args
	abort("write_to_mysql <input_dir>") unless ARGV.length == 1
	@input_dir = ARGV[0] 
end

def init
	require File.join(ROOT_DIR , 'db', 'environment.rb')
end

def store_run
	@run = Run.new
	@log_file = File.join(@input_dir, 'lda_yahoo.log')

	File.open(@log_file).each_line do |line|
		if line.include? "RUN_ID = "
			@run.name = line.split(' = ').last.strip
		elsif line.include? "NUM_TOPICS = "
			@run.num_topics = line.split(' = ').last.strip.to_i
		elsif line.include? "NUM_ITER = "
			@run.num_iter = line.split(' = ').last.strip.to_i
		elsif line.include? "MAX_DF = "
			@run.max_df = line.split(' = ').last.strip.to_f
		elsif line.include? "MIN_DF = "
			@run.min_df = line.split(' = ').last.strip.to_f
		elsif line.include? "FILTER = "
			@run.filter = line.split(' = ').last.strip
		elsif line.include? "Total num of docs found:"
			@run.num_docs = line.split(':').last.strip.to_i
		elsif line.include? "Total number of unique words found:"
			@run.num_uniq_terms = line.split(':').last.strip.to_i
		elsif line.include? "Dictionary Initialized"
			break
		end
	end
	puts @run.inspect
	puts "looks good? [ENTER to continue, otherwise CTRL-C]"
	ret = STDIN.gets

	clean_run
	@run.save
end

def clean_run
	puts 'cleaning run.'
	runs = Run.where(name: @run.name)
	runs.each do |run|
		run_id = run.id

		puts '+ removing docs...'
		Doc.where(run_id: run_id).delete_all
		puts '+ removing topics...'
		Topic.where(run_id: run_id).delete_all
		puts '+ removing terms...'
		Term.where(run_id: run_id).delete_all
		run.destroy

		puts "run cleaned."
	end

end

def store_docs
	@doc_file = File.join(@input_dir, 'lda.docToTop.txt')

	File.open(@doc_file).each_line do |line|
		@doc = Doc.new
		@doc.run = @run
		parts = line.split(' ')
		@doc.num = parts[0].strip
		@doc.aux = parts[1].strip
		top_count = 0
		parts[2..-1].each do |part|
			top_num, prob = part.gsub(/[\(\)]/, '').split(',')
			topic = Topic.new
			topic.run = @run
			topic.doc = @doc
			topic.num = top_num.strip.to_i
			topic.prob = prob.to_f
			topic.save
			top_count += 1
		end
		puts "Added #{top_count} topics for #{@doc.num}"
	end
end

def store_topics
	@top_file = File.join(@input_dir, 'lda.topToWor.txt')

	File.open(@top_file).each_line do |line|
		parts = line.split(' ')
		top_num = parts[1].gsub(':', '').to_i
		term_count = 0
		parts[2..-1].each do |part|
			stem, prob = part.gsub(/[\(\)]/, '').split(',')
			term = Term.new
			term.run = @run
			term.topic_num = top_num
			term.stem = stem.strip
			term.prob = prob.strip.to_f
			term.save
			term_count += 1
		end
		puts "Added #{term_count} terms for #{top_num}"
	end
end

process_args
init

store_run
store_docs
store_topics
