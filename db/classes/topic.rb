class Topic < ActiveRecord::Base
	belongs_to :run
	belongs_to :doc

	def terms
		Term.where(run_id: self.run_id, topic_num: self.num).all
	end

end
