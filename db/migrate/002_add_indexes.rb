class AddIndexes < ActiveRecord::Migration

	def change
		add_index :docs, :num
		add_index :docs, :run_id
		add_index :topics, :run_id
		add_index :topics, :doc_id
		add_index :terms, :run_id
		add_index :terms, :topic_num
	end

end
