module LightrailClientRuby
  class LightrailError < StandardError
    attr_reader :message
    attr_accessor :response

    def initialize (message=nil,response)
      @message = message
      @response = response
    end
  end
end