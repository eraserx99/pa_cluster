require 'active_record'
require 'yaml'
require 'logger'

#task :default => :migrate

namespace :db do

	desc "Migrate the database through scripts in db/migrate. Target specific version with VERSION=x"
	task :migrate => :environment do
		ActiveRecord::Migration.verbose = true
		ActiveRecord::Migrator.migrate('db/migrate', ENV["VERSION"] ? ENV["VERSION"].to_i : nil )
	end

	task :create do
		config = YAML::load_file('db/database.yml')
		ActiveRecord::Base.establish_connection(config.merge('database' => nil))
		ActiveRecord::Base.connection.create_database(config['database'])
	end

	task :drop => :environment do
		config = YAML::load_file('db/database.yml')
		ActiveRecord::Base.connection.drop_database(config['database'])
	end


	task :environment do
		ActiveRecord::Base.establish_connection(YAML::load_file('db/database.yml'))
		ActiveRecord::Base.logger = Logger.new(File.open('log/database.log', 'a'))
	end

end

task :console do
	sh "irb -rubygems -I db -r environment.rb"
end
