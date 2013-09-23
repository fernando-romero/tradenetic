require 'rest_client'

module Tradenetic
  module Providers
    module Google

      def self.bars(options)
        url = "http://www.google.com/finance/getprices" +
              "?q=#{options['symbol']}" +
              "&i=60" +
              "&p=1d" +
              "&f=d,o,h,l,c,v"
        response = RestClient.get(url)
        process_response(response)
      end

    private

      def self.process_response(response)
        i = 0
        time = Time.now
        bars = []
        response.each_line do |line|
          i += 1
          data = line.split(',')
          if i == 8
            time = Time.at(data[0][1..-1].to_i)
            bars << build_bar(time, data)
          elsif i > 8
            bars << build_bar(time + 60 * data[0].to_i, data)
          end
        end
        bars
      end

      def self.build_bar(time, data)
        {
          :time => time,
          :close => data[1].to_f,
          :high => data[2].to_f,
          :low => data[3].to_f,
          :open => data[4].to_f,
          :volume => data[5].to_i
        }
      end

    end
  end
end