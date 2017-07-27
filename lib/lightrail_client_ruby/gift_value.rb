module LightrailClientRuby
  class GiftValue
    def self.retrieve (code)
      LightrailClientRuby::Connection.make_get_request_and_parse_response("codes/#{code}/balance/details")
    end
  end
end