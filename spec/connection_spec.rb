require "spec_helper"

RSpec.describe LightrailClientRuby::Connection do

  describe ".connection" do
    it "has the right base URL" do
      expect(LightrailClientRuby::Connection.connection.url_prefix.to_s).to eq(LightrailClientRuby::Connection.api_base)
    end

    it "has the right headers" do
      expect(LightrailClientRuby::Connection.connection.headers['Content-Type']).to include('application/json'), "expected Content-Type header to include 'application/json'"
      expect(LightrailClientRuby::Connection.connection.headers['Content-Type']).to include('charset=utf-8'), "expected Content-Type header to include 'charset=utf-8'"
      expect(LightrailClientRuby::Connection.connection.headers['Authorization']).to include('Bearer'), "expected Authorization header to include 'Bearer'"
    end
  end

end