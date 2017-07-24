module LightrailClientRuby
  class Connection
    class << self
      attr_accessor :api_base, :api_key
    end

    @api_base = 'https://dev.lightrail.com/v1'
    @api_key = ENV['LIGHTRAIL_API_KEY']

    def self.connection
      conn = Faraday.new
      conn.headers['Content-Type'] = 'application/json; charset=utf-8'
      conn.headers['Authorization'] = "Bearer #{self.api_key}"
      conn
    end

  end
end