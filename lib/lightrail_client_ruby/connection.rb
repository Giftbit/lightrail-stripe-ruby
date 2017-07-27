module LightrailClientRuby
  class Connection
    class << self
      attr_accessor :api_base, :api_key
    end

    @api_base = 'https://dev.lightrail.com/v1'
    @api_key = ENV['LIGHTRAIL_API_KEY']

    def self.connection
      conn = Faraday.new self.api_base
      conn.headers['Content-Type'] = 'application/json; charset=utf-8'
      conn.headers['Authorization'] = "Bearer #{self.api_key}"
      conn
    end

    def self.make_post_request_and_parse_response (url, body)
      resp = LightrailClientRuby::Connection.connection.post do |req|
        req.url url
        req.body = JSON.generate(body)
      end
      JSON.parse(resp.body)
    end

    def self.make_get_request_and_parse_response (url)
      resp = LightrailClientRuby::Connection.connection.get do |req|
        req.url url
      end
      JSON.parse(resp.body)
    end

    def self.api_endpoint_ping
      "ping"
    end

    def self.api_endpoint_code_balance (code)
      "codes/#{code}/balance/details"
    end

    def self.api_endpoint_code_transaction (code)
      "codes/#{code}/transactions"
    end

    def self.api_endpoint_handle_pending (card_id, transaction_id, void_or_capture)
      "cards/#{card_id}/transactions/#{transaction_id}/#{void_or_capture}"
    end

    def self.api_endpoint_card_transaction (card_id)
      "cards/#{card_id}/transactions"
    end

    def self.api_endpoint_refund_transaction (card_id, transaction_id)
      "cards/#{card_id}/transactions/#{transaction_id}/refund"
    end

  end
end