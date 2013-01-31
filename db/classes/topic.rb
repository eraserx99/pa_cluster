class Topic < ActiveRecord::Base
	belongs_to :run
	belongs_to :doc

end
