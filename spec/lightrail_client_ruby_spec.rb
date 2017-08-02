require "spec_helper"

RSpec.describe LightrailClientRuby do
  it "has a version number" do
    expect(LightrailClientRuby::VERSION).not_to be nil
  end

  it "stores the base URL for the Lightrail API" do
    expect(LightrailClientRuby.api_base).to eq('https://dev.lightrail.com/v1' || 'https://api.lightrail.com/v1')
  end

  it "stores a string for the API key" do
    expect(LightrailClientRuby.api_key).to match(/[A-Z0-9]+/)
  end

end
