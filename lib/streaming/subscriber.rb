require 'faye'

module Streaming
  class Subscriber < Salesforce::Base

    attr :stream_topic_name

    def initialize(stream_topic_name)
      super()
      @stream_topic_name = stream_topic_name
    end

    def subscribe
      begin
        subscribe_push_topic
      rescue Restforce::AuthenticationError => e
        puts e
      end
    end

    private

    def subscribe_push_topic
      EM.run do
        @client.subscribe @stream_topic_name do |message|
          begin
            Streaming::Parser.new(@stream_topic_name, message['sobject']).parse_response
          rescue Exception => e
            puts e
          end
        end
      end
    end
  end
end

# Streaming::Parser.new(@stream_topic_name, response).parse_response