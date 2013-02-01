class CreateTables < ActiveRecord::Migration

	def self.up

		create_table :runs do |t|
			t.column :name, :string
			t.column :num_topics, :integer
			t.column :num_docs, :integer
			t.column :num_iter, :integer
			t.column :num_uniq_terms, :integer
			t.column :max_df, :float
			t.column :min_df, :float
			t.column :filter, :string
		end

		create_table :docs do |t|
			t.references :run
			t.column :num, :string
			t.column :aux, :string
			t.column :category, :integer
		end

		create_table :topics do |t|
			t.references :run
			t.references :doc
			t.column :num, :integer
			t.column :prob, :float
		end

		create_table :terms do |t|
			t.references :run
			t.column :topic_num, :integer
			t.column :stem, :string
			t.column :prob, :float
		end

	end

	def self.down

		drop_table :runs
		drop_table :docs
		drop_table :topics
		drop_table :terms

	end
end
