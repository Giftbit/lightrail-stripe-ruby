module LightrailClientRuby
  class Ping
    def self.ping
      resp = Connection.connection.get do |req|
        req.url "#{Connection.api_base}/ping"
      end
      JSON.parse(resp.body)
    end
  end
end