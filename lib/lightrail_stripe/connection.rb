module Lightrail
  class Connection

    def self.code_drawdown(charge_params)
      self.post_transaction(charge_params)
    end

    def self.code_pending(charge_params)
      self.post_transaction(charge_params)
    end

    def self.card_id_drawdown(charge_params)
      self.post_transaction(charge_params)
    end

    def self.card_id_pending(charge_params)
      self.post_transaction(charge_params)
    end

    def self.card_id_fund(fund_params)
      self.post_transaction(fund_params)
    end

    def self.post_transaction(transaction_params)
      response = {}
      if (transaction_params[:code])
        code = transaction_params.delete(:code)
        response = self.send :make_post_request_and_parse_response, "codes/#{code}/transactions", transaction_params
      elsif (transaction_params[:cardId])
        card_id = transaction_params.delete(:cardId)
        response = self.send :make_post_request_and_parse_response, "cards/#{card_id}/transactions", transaction_params
      else
        raise Lightrail::LightrailArgumentError.new("Lightrail code or cardId required to post a transaction: #{transaction_params.inspect}")
      end
      response['transaction']
    end

    def self.ping
      self.send :make_get_request_and_parse_response, "ping"
    end

    def self.get_code_balance(code)
      self.send :make_get_request_and_parse_response, "codes/#{code}/balance/details"
    end

    def self.get_card_id_balance(card_id)
      self.send :make_get_request_and_parse_response, "cards/#{card_id}/balance"
    end

    def self.make_code_transaction(code, charge_params)
      self.send :make_post_request_and_parse_response, "codes/#{code}/transactions", charge_params
    end

    def self.make_card_id_transaction(card_id, charge_params)
      self.send :make_post_request_and_parse_response, "cards/#{card_id}/transactions", charge_params
    end

    def self.handle_pending(card_id, transaction_id, void_or_capture, request_body)
      self.send :make_post_request_and_parse_response, "cards/#{card_id}/transactions/#{transaction_id}/#{void_or_capture}", request_body
    end

    def self.post_refund(card_id, transaction_id, request_body)
      self.send :make_post_request_and_parse_response, "cards/#{card_id}/transactions/#{transaction_id}/refund", request_body
    end


    private

    def self.connection
      conn = Faraday.new Lightrail.api_base, ssl: {version: :TLSv1_2}
      conn.headers['Content-Type'] = 'application/json; charset=utf-8'
      conn.headers['Authorization'] = "Bearer #{Lightrail.api_key}"
      conn
    end

    def self.make_post_request_and_parse_response (url, body)
      resp = Lightrail::Connection.connection.post do |req|
        req.url url
        req.body = JSON.generate(body)
      end
      self.handle_response(resp)
    end

    def self.make_get_request_and_parse_response (url)
      resp = Lightrail::Connection.connection.get {|req| req.url url}
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
            raise Lightrail::InsufficientValueError.new(message, response)
          else
            raise Lightrail::BadParameterError.new(message, response)
          end
        when 401, 403
          raise Lightrail::AuthorizationError.new(message, response)
        when 404
          raise Lightrail::CouldNotFindObjectError.new(message, response)
        when 409
          raise Lightrail::BadParameterError.new(message, response)
        else
          raise LightrailError.new("Server responded with: (#{response.status}) #{message}", response)
      end
    end

  end
end