require 'mongo'
require 'json'

module TobiasRandom
  module Config

    CONFIG_FILE = File.join(File.dirname(__FILE__), '..', '..', 'conf', 'app.json')
    CONFIG = JSON.parse(File.read(CONFIG_FILE))

    def self.mongo
      Mongo::Connection.new(CONFIG['mongo_host'])
    end

    def self.dois
      mongo[CONFIG['mongo_db']]['dois']
    end

  end
end
