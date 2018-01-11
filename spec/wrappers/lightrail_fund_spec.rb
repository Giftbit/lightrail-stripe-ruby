require "spec_helper"

RSpec.describe Lightrail::LightrailFund do
  subject(:lightrail_fund) {Lightrail::LightrailFund}

  let(:lightrail_connection) {Lightrail::Connection}

  let(:example_card_id) {'this-is-a-card-id'}
  let(:example_contact_id) {'this-is-a-contact-id'}
  let(:example_shopper_id) {'this-is-a-shopper-id'}
  let(:example_user_supplied_id) {'123-abc-456-def'}

  let(:card_fund_params) {{
      amount: 1,
      currency: 'USD',
      card_id: example_card_id,
      userSuppliedId: example_user_supplied_id,
  }}

  let(:contact_fund_params) {{
      amount: 1,
      currency: 'USD',
      contact_id: example_contact_id,
      userSuppliedId: example_user_supplied_id,
  }}

  let(:shopper_fund_params) {{
      amount: 1,
      currency: 'USD',
      shopper_id: example_shopper_id,
      userSuppliedId: example_user_supplied_id,
  }}

  let(:card_fund_params_no_user_supplied_id) {{
      amount: 1,
      currency: 'USD',
      card_id: example_card_id
  }}

  describe ".create" do
    context "when given valid params" do
      before(:each) do
        expect(lightrail_connection).to receive(:make_post_request_and_parse_response).with(/cards\/#{example_card_id}\/transactions/, hash_including(:userSuppliedId)).and_return({"transaction" => {}})
      end

      it "funds a gift card with minimum required params: card_id" do
        lightrail_fund.create(card_fund_params)
      end

      it "funds a gift card with minimum required params: contact_id" do
        allow(Lightrail::Account).to receive(:retrieve).with({contact_id: example_contact_id, currency: 'USD'}).and_return({'cardId' => example_card_id})

        lightrail_fund.create(contact_fund_params)
      end

      it "funds a gift card with minimum required params: shopper_id" do
        allow(Lightrail::Contact).to receive(:get_contact_id_from_id_or_shopper_id).with(hash_including({shopper_id: example_shopper_id})).and_return(example_contact_id)
        allow(Lightrail::Account).to receive(:retrieve).with({contact_id: example_contact_id, currency: 'USD'}).and_return({'cardId' => example_card_id})
        lightrail_fund.create(shopper_fund_params)
      end

      it "uses userSuppliedId if supplied in param hash" do
        lightrail_fund.create(card_fund_params)
      end

      it "generates userSuppliedId if not supplied in param hash" do
        lightrail_fund.create(card_fund_params_no_user_supplied_id)
      end
    end

    context "when given bad/missing params" do
      it "throws an error when required params are missing" do
        expect {lightrail_fund.create()}.to raise_error(ArgumentError), "called LightrailFund.create with no params"
        expect {lightrail_fund.create({})}.to raise_error(Lightrail::LightrailArgumentError), "called LightrailFund.create with empty object"
        expect {lightrail_fund.create({card: example_card_id})}.to raise_error(Lightrail::LightrailArgumentError), "called LightrailFund.create with '{card: example_card_id}'"
        expect {lightrail_fund.create([])}.to raise_error(Lightrail::LightrailArgumentError), "called LightrailFund.create with empty array"
      end
    end
  end

end