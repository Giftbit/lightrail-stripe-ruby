module LightrailClientRuby
  class Ping
    def self.ping
      resp = Connection.connection.get do |req|
        req.url "ping"
      end
      resp
      JSON.parse(resp.body)
    end
  end
end