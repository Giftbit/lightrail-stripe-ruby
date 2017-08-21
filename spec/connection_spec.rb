require "spec_helper"

RSpec.describe Lightrail::Connection do
  subject(:connection) {Lightrail::Connection}

  describe ".connection" do
    let(:conn) {Lightrail::Connection.connection}

    it "has the right base URL" do
      expect(conn.url_prefix.to_s).to eq(Lightrail.api_base)
    end

    it "has the right headers" do
      expect(conn.headers['Content-Type']).to include('application/json'), "expected Content-Type header to include 'application/json'"
      expect(conn.headers['Content-Type']).to include('charset=utf-8'), "expected Content-Type header to include 'charset=utf-8'"
      expect(conn.headers['Authorization']).to include('Bearer'), "expected Authorization header to include 'Bearer'"
    end
  end


  describe ".handle_response" do
    context "API responds with 200" do
      it "should return the JSON-parsed response body" do
        happy_response = Faraday::Response.new(status: 200, body: "{\"transaction\":{\"transactionId\":\"transaction-ac11917b94c64c84b082c865b7\"}}")
        handled_response = connection.handle_response(happy_response)
        expect(handled_response).to have_key('transaction'), "expected to have key 'transaction', got #{handled_response}"
      end
    end


    context "API responds with 400" do
      it "should throw an InsufficientValueError when message includes 'Insufficient Value'" do
        response_400 = Faraday::Response.new(status: 400, body: "{\"status\":400,\"message\":\"Insufficient Value\"}")
        expect {connection.handle_response(response_400)}.to raise_error(Lightrail::InsufficientValueError)
      end

      it "should throw an BadParameterError for other messages" do
        response_400 = Faraday::Response.new(status: 400, body: "{\"status\":400,\"message\":\"Missing required parameter 'value'\"}")
        expect {connection.handle_response(response_400)}.to raise_error(Lightrail::BadParameterError)
      end
    end

    context "API responds with 401 or 403" do
      it "should throw an AuthorizationError" do
        response_401 = Faraday::Response.new(status: 401, body: "{\"status\":401,\"message\":\"Unauthorized\"}")
        expect {connection.handle_response(response_401)}.to raise_error(Lightrail::AuthorizationError)
      end
    end

    context "API responds with 404" do
      it "should throw a CouldNotFindObjectError" do
        response_404 = Faraday::Response.new(status: 404, body: "{\"status\":404,\"message\":\"Could not find object\"}")
        expect {connection.handle_response(response_404)}.to raise_error(Lightrail::CouldNotFindObjectError)
      end
    end

    context "API responds with 409" do
      it "should throw a BadParameterError" do
        response_409 = Faraday::Response.new(status: 409, body: "{\"status\":409,\"message\":\"Bad parameter\"}")
        expect {connection.handle_response(response_409)}.to raise_error(Lightrail::BadParameterError)
      end
    end

    context "API responds any other status that is not 200" do
      it "should throw a LightrailError with response details when status is not 200" do
        bad_response = Faraday::Response.new(status: 418, body: "{\"status\":418,\"message\":\"I'm a teapot\"}")
        expect {connection.handle_response(bad_response)}.to raise_error(Lightrail::LightrailError, /teapot/)
      end
    end
  end

end