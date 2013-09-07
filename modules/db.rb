require 'mysql2'

module Tradenetic
  module DB

    def self.create_database
      client = Mysql2::Client.new(:host => "localhost", :username => "root")
      query = 'CREATE DATABASE IF NOT EXISTS tradenetic;'
      client.query(query)
    end

    def self.create_tables
      client = Mysql2::Client.new(:host => "localhost", :username => "root", :database => 'tradenetic')
      query = <<-sql
        CREATE TABLE IF NOT EXISTS targets (
          id INT NOT NULL AUTO_INCREMENT,
          symbol VARCHAR(30) NOT NULL,
          type CHAR(3) NOT NULL,
          timeframe VARCHAR(3) NOT NULL,
          PRIMARY KEY (id)
        );
      sql
      client.query(query)
      query = <<-sql
        CREATE TABLE IF NOT EXISTS bars (
          id INT NOT NULL AUTO_INCREMENT,
          target_id INT NOT NULL,
          open DECIMAL(13, 2),
          high DECIMAL(13, 2),
          low DECIMAL(13, 2),
          close DECIMAL(13, 2),
          volume INT,
          time TIMESTAMP,
          PRIMARY KEY (id),
          FOREIGN KEY (target_id) REFERENCES targets(id)
        );
      sql
      client.query(query)
    end

    def self.add_initial_targets
      client = Mysql2::Client.new(:host => "localhost", :username => "root", :database => 'tradenetic')
      query = <<-sql
        INSERT INTO targets (symbol, type, timeframe)
        VALUES ('AAPL', 'STK', '1M');
      sql
      client.query(query)
    end

  end
end