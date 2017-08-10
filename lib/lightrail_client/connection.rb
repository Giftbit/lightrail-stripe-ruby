module LightrailClient
  class Connection

    def self.connection
      conn = Faraday.new LightrailClient.api_base, ssl: {version: :TLSv1_2}
      conn.headers['Content-Type'] = 'application/json; charset=utf-8'
      conn.headers['Authorization'] = "Bearer #{LightrailClient.api_key}"
      conn
    end

    def self.make_post_request_and_parse_response (url, body)
      resp = LightrailClient::Connection.connection.post do |req|
        req.url url
        req.body = JSON.generate(body)
      end
      self.handle_response(resp)
    end

    def self.make_get_request_and_parse_response (url)
      resp = LightrailClient::Connection.connection.get do |req|
        req.url url
      end
      self.handle_response(resp)
    end

    def self.handle_response(response)
      body = JSON.parse(response.body) || {}
      message = body['message'] || ''
      case response.status
        when 200...300
          JSON.parse(response.body)
        when 400
          if (message =~ /insufficient value/i)
            raise LightrailClient::InsufficientValueError.new(message, response)
          else
            raise LightrailClient::BadParameterError.new(message, response)
          end
        when 401, 403
          raise LightrailClient::AuthorizationError.new(message, response)
        when 404
          raise LightrailClient::CouldNotFindObjectError.new(message, response)
        when 409
          raise LightrailClient::BadParameterError.new(message, response)
        else
          raise LightrailError.new("Server responded with: (#{response.status}) #{message}", response)
      end
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