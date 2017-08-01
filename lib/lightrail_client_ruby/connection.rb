module LightrailClientRuby
  class Connection

    def self.connection
      conn = Faraday.new LightrailClientRuby.api_base
      conn.headers['Content-Type'] = 'application/json; charset=utf-8'
      conn.headers['Authorization'] = "Bearer #{LightrailClientRuby.api_key}"
      conn
    end

    def self.make_post_request_and_parse_response (url, body)
      resp = LightrailClientRuby::Connection.connection.post do |req|
        req.url url
        req.body = JSON.generate(body)
      end
      resp.status == 200 ? JSON.parse(resp.body) : self.raise_error_from_response(resp)
    end

    def self.make_get_request_and_parse_response (url)
      resp = LightrailClientRuby::Connection.connection.get do |req|
        req.url url
      end
      resp.status == 200 ? JSON.parse(resp.body) : self.raise_error_from_response(resp)
    end

    def self.raise_error_from_response(response)
      body = JSON.parse(response.body) || {}
      message = body['message'] || ''
      case response.status
        when 400
          if (message =~ /insufficient value/i)
            raise LightrailClientRuby::InsufficientValueError.new(message, response)
          else
            raise LightrailClientRuby::BadParameterError.new(message, response)
          end
        when 401, 403
          raise LightrailClientRuby::AuthorizationError.new(message, response)
        when 404
          raise LightrailClientRuby::CouldNotFindObjectError.new(message, response)
        when 409
          raise LightrailClientRuby::BadParameterError.new(message, response)
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