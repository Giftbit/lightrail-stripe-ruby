module LightrailClientRuby
  class GiftValue
    def self.retrieve (code)
      resp = Connection.connection.get do |req|
        req.url "#{Connection.api_base}/codes/#{code}/balance/details"
      end
      JSON.parse(resp.body)
    end
  end
end