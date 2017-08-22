require "spec_helper"

RSpec.describe Lightrail do
  it "has a version number" do
    expect(Lightrail::VERSION).not_to be nil
  end

  it "stores the base URL for the Lightrail API" do
    expect(Lightrail.api_base).to eq('https://dev.lightrail.com/v1').or(eq('https://api.lightrail.com/v1'))
  end

  it "stores a string for the API key" do
    expect(Lightrail.api_key).to match(/[A-Z0-9]+/)
  end

end
