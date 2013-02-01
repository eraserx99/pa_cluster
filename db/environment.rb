require 'active_record'

unless defined?(ROOT_DIR)
	ROOT_DIR = File.expand_path('../', File.dirname(__FILE__))
end

dbconfig = YAML::load_file( File.join( ROOT_DIR , 'db' , 'database.yml' ) )
ActiveRecord::Base.establish_connection(dbconfig)
Dir[ROOT_DIR + '/db/classes/*.rb'].each {|file| require file}
