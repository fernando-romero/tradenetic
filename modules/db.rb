require 'mysql2'
require_relative './providers/google.rb'

module Tradenetic
  module DB

    def self.create_database
      client = Mysql2::Client.new(:host => "localhost", :username => "root")
      query = 'DROP DATABASE tradenetic;'
      client.query(query)
      query = 'CREATE DATABASE tradenetic;'
      client.query(query)
    end

    def self.create_tables
      client = Mysql2::Client.new(:host => "localhost", :username => "root", :database => 'tradenetic')
      query = <<-sql
        CREATE TABLE IF NOT EXISTS target (
          id INT NOT NULL AUTO_INCREMENT,
          symbol VARCHAR(30) NOT NULL,
          type CHAR(3) NOT NULL,
          timeframe VARCHAR(3) NOT NULL,
          PRIMARY KEY (id),
          UNIQUE (symbol, type, timeframe)
        );
      sql
      client.query(query)
      query = <<-sql
        CREATE TABLE IF NOT EXISTS bar (
          id INT NOT NULL AUTO_INCREMENT,
          target_id INT NOT NULL,
          open DECIMAL(13, 2),
          high DECIMAL(13, 2),
          low DECIMAL(13, 2),
          close DECIMAL(13, 2),
          volume INT,
          time TIMESTAMP,
          PRIMARY KEY (id),
          UNIQUE (target_id, time),
          FOREIGN KEY (target_id) REFERENCES target(id)
        );
      sql
      client.query(query)
    end

    def self.add_initial_targets
      client = Mysql2::Client.new(:host => "localhost", :username => "root", :database => 'tradenetic')
      query = <<-sql
        INSERT INTO target (symbol, type, timeframe) VALUES ('AAPL', 'STK', '1M');
      sql
      client.query(query)
      query = <<-sql
        INSERT INTO target (symbol, type, timeframe) VALUES ('GOOG', 'STK', '1M');
      sql
      client.query(query)
      query = <<-sql
        INSERT INTO target (symbol, type, timeframe) VALUES ('MSFT', 'STK', '1M');
      sql
      client.query(query)
    end

    def self.populate
      client = Mysql2::Client.new(:host => "localhost", :username => "root", :database => 'tradenetic')
      targets = client.query('SELECT * FROM target')
      targets.each do |target|
        bars = Tradenetic::Providers::Google.bars(target)
        save_bars(target, bars)
      end
    end

    def self.save_bars(target, bars)
      client = Mysql2::Client.new(:host => "localhost", :username => "root", :database => 'tradenetic')
      bars.each do |bar|
        query = <<-sql
          INSERT IGNORE INTO bar (target_id, open, high, low, close, volume, time) 
          VALUES (#{target['id']}, #{bar[:open]}, #{bar[:high]}, #{bar[:low]}, #{bar[:close]},
            #{bar[:volume]}, '#{bar[:time].strftime('%F %T')}');
        sql
        client.query(query)
      end
    end

  end
end