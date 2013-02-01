class Doc < ActiveRecord::Base
	belongs_to :run
	has_many :topics

	scope :for_run, lambda {|run_name|
		where(run_id: Run.where(name: run_name).first.id)
	}

	scope :with_num, lambda {|num|
		where(num: num)
	}

	def terms
		ret = []
		self.topics.each do |topic|
			ret = ret | topic.terms
		end
		return ret
	end

	def print_topics
		self.topics.each do |topic|
			puts "#{topic.num} - #{topic.prob} : #{topic.terms.collect{|term| term.stem}.join(',')}"
		end
		return nil
	end
end
