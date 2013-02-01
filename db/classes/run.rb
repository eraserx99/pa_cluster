class Run < ActiveRecord::Base
	has_many :docs
	has_many :topics

	def self.with_name(nm)
		self.where(name: nm).first
	end

	def num_topics_above(prob)
		Topic.where(run_id: self.id).where("prob >= :prob", :prob => prob.to_f).count
	end

end
