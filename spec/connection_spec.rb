require "spec_helper"

RSpec.describe LightrailClientRuby::Connection do

  describe ".connection" do
    let(:connection) {LightrailClientRuby::Connection.connection}

    it "has the right base URL" do
      expect(connection.url_prefix.to_s).to eq(LightrailClientRuby.api_base)
    end

    it "has the right headers" do
      expect(connection.headers['Content-Type']).to include('application/json'), "expected Content-Type header to include 'application/json'"
      expect(connection.headers['Content-Type']).to include('charset=utf-8'), "expected Content-Type header to include 'charset=utf-8'"
      expect(connection.headers['Authorization']).to include('Bearer'), "expected Authorization header to include 'Bearer'"
    end
  end

  describe ".make_get_request_and_parse_response" do
    context "bad API response" do
      it "should throw an error" do
        response_401 = Faraday::Response.new(status: 401, body: "{\"status\":401,\"message\":\"Unauthorized\"}")
        allow(LightrailClientRuby::Connection).to receive_message_chain('connection.get').and_return(response_401)
        expect {LightrailClientRuby::Connection.make_get_request_and_parse_response('ping')}.to raise_error(LightrailClientRuby::AuthenticationError)
      end
    end
  end

end