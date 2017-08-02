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

end