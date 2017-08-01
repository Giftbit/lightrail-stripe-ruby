require "spec_helper"

RSpec.describe LightrailClientRuby::Connection do
  subject(:connection) {LightrailClientRuby::Connection}

  describe ".connection" do
    let(:conn) {LightrailClientRuby::Connection.connection}

    it "has the right base URL" do
      expect(conn.url_prefix.to_s).to eq(LightrailClientRuby.api_base)
    end

    it "has the right headers" do
      expect(conn.headers['Content-Type']).to include('application/json'), "expected Content-Type header to include 'application/json'"
      expect(conn.headers['Content-Type']).to include('charset=utf-8'), "expected Content-Type header to include 'charset=utf-8'"
      expect(conn.headers['Authorization']).to include('Bearer'), "expected Authorization header to include 'Bearer'"
    end
  end


  describe ".make_get_request_and_parse_response" do
    context "when given good params" do
      # ...
    end


    context "bad API response" do
      it "should throw a LightrailError with response details when status is not 200" do
        bad_response = Faraday::Response.new(status: 418, body: "{\"status\":418,\"message\":\"I'm a teapot\"}")
        allow(connection).to receive_message_chain('connection.get').and_return(bad_response)
        expect {connection.make_get_request_and_parse_response('ping')}.to raise_error(LightrailClientRuby::LightrailError, /teapot/)
      end

      it "should throw an AuthorizationError when status is 401 or 403" do
        response_401 = Faraday::Response.new(status: 401, body: "{\"status\":401,\"message\":\"Unauthorized\"}")
        allow(connection).to receive_message_chain('connection.get').and_return(response_401)
        expect {connection.make_get_request_and_parse_response('ping')}.to raise_error(LightrailClientRuby::AuthorizationError)
      end

      it "should throw a CouldNotFindObjectError when status is 404" do
        response_404 = Faraday::Response.new(status: 404, body: "{\"status\":404,\"message\":\"Could not find object\"}")
        allow(connection).to receive_message_chain('connection.get').and_return(response_404)
        expect {connection.make_get_request_and_parse_response('ping')}.to raise_error(LightrailClientRuby::CouldNotFindObjectError)
      end

      it "should throw a BadParameterError when status is 409" do
        response_409 = Faraday::Response.new(status: 409, body: "{\"status\":409,\"message\":\"Bad parameter\"}")
        allow(connection).to receive_message_chain('connection.get').and_return(response_409)
        expect {connection.make_get_request_and_parse_response('ping')}.to raise_error(LightrailClientRuby::BadParameterError)
      end

    end
  end

end