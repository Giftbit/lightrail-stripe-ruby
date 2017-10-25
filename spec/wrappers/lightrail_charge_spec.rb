require "spec_helper"

RSpec.describe Lightrail::LightrailCharge do
  subject(:lightrail_charge) {Lightrail::LightrailCharge}

  let(:lightrail_connection) {Lightrail::Connection}

  let(:example_code) {'this-is-a-code'}
  let(:example_card_id) {'this-is-a-card-id'}
  let(:example_contact_id) {'this-is-a-contact-id'}
  let(:example_shopper_id) {'this-is-a-shopper-id'}

  let(:code_charge_params) {{
      amount: 1,
      currency: 'USD',
      code: example_code,
  }}

  let(:card_id_charge_params) {{
      amount: 1,
      currency: 'USD',
      cardId: example_card_id,
  }}

  let(:contact_id_charge_params) {{
      amount: 1,
      currency: 'USD',
      contact_id: example_contact_id,
  }}

  let(:shopper_id_charge_params) {{
      amount: 1,
      currency: 'USD',
      shopper_id: example_shopper_id,
  }}

  let(:translated_code_charge_params) {
    Lightrail::Translator.charge_params_stripe_to_lightrail(code_charge_params)
  }

  let(:pending_charge_object_details) {{
      cardId: 'card-123456',
      codeLastFour: 'TEST',
      currency: 'USD',
      transactionId: 'transaction-123456',
      transactionType: 'PENDING_CREATE',
      userSuppliedId: '123-abc-456-def',
      value: -1,
  }}

  let(:faraday_code_charge_response) {
    Faraday::Response.new(
        status: 200,
        body: "{\"transaction\":{\"transactionId\":\"transaction-abc123\",\"value\":-1,\"userSuppliedId\":\"d9daba61\",\"dateCreated\":\"2017-08-25T17:24:55.767Z\",\"transactionType\":\"DRAWDOWN\",\"transactionAccessMethod\":\"RAWCODE\",\"giftbitUserId\":\"user-123456-TEST\",\"cardId\":\"card-12345\",\"currency\":\"USD\",\"codeLastFour\":\"QRST\"}}")
  }

  let(:faraday_card_id_charge_response) {
    Faraday::Response.new(
        status: 200,
        body: "{\"transaction\":{\"transactionId\":\"transaction-abc123\",\"value\":-1,\"userSuppliedId\":\"c7675b6c\",\"dateCreated\":\"2017-08-25T17:28:17.044Z\",\"transactionType\":\"DRAWDOWN\",\"transactionAccessMethod\":\"CARDID\",\"giftbitUserId\":\"user-123456-TEST\",\"cardId\":\"card-12345\",\"currency\":\"USD\",\"codeLastFour\":\"QRST\"}}")
  }


  describe ".new" do
    it "creates a new charge object from valid API response" do
      allow(lightrail_connection).to receive_message_chain(:connection, :post).and_return(faraday_code_charge_response)

      charge_response = lightrail_charge.create(code_charge_params)
      expect(charge_response).to be_a(lightrail_charge)
    end
  end


  describe ".create" do
    context "when given valid params" do
      it "creates a drawdown code transaction with minimum required params" do
        expect(lightrail_connection).to receive(:make_post_request_and_parse_response).with(/codes\/#{code_charge_params[:code]}\/transactions/, hash_including(:value, :currency, :userSuppliedId)).and_return({"transaction" => {}})

        lightrail_charge.create(code_charge_params)
      end

      it "creates a drawdown card transaction with minimum required params" do
        expect(lightrail_connection).to receive(:make_post_request_and_parse_response).with(/cards\/#{card_id_charge_params[:cardId]}\/transactions/, hash_including(:value, :currency, :userSuppliedId)).and_return({"transaction" => {}})

        lightrail_charge.create(card_id_charge_params)
      end

      it "creates a drawdown contactId transaction with minimum required params" do
        allow(Lightrail::Contact).to receive(:get_account_card_id_by_contact_id).with(example_contact_id, 'USD').and_return(example_card_id)
        expect(lightrail_connection).to receive(:make_post_request_and_parse_response).with(/cards\/#{card_id_charge_params[:cardId]}\/transactions/, hash_including(:value, :currency, :userSuppliedId)).and_return({"transaction" => {}})

        lightrail_charge.create(contact_id_charge_params)
      end

      it "creates a drawdown shopperId transaction with minimum required params" do
        allow(Lightrail::Contact).to receive(:get_contact_id_from_id_or_shopper_id).with(hash_including({shopper_id: example_shopper_id})).and_return(example_contact_id)
        allow(Lightrail::Contact).to receive(:get_account_card_id_by_contact_id).with(example_contact_id, 'USD').and_return(example_card_id)
        expect(lightrail_connection).to receive(:make_post_request_and_parse_response).with(/cards\/#{card_id_charge_params[:cardId]}\/transactions/, hash_including(:value, :currency, :userSuppliedId)).and_return({"transaction" => {}})

        lightrail_charge.create(shopper_id_charge_params)
      end

      it "creates a pending code transaction when 'pending=true'" do
        code_charge_params[:pending] = true
        expect(lightrail_connection).to receive(:make_post_request_and_parse_response).with(/codes\/#{code_charge_params[:code]}\/transactions/, hash_including(:value, :currency, :userSuppliedId, pending: true)).and_return({"transaction" => {}})

        lightrail_charge.create(code_charge_params)
      end

      it "creates a pending card transaction when 'pending=true'" do
        card_id_charge_params[:pending] = true
        expect(lightrail_connection).to receive(:make_post_request_and_parse_response).with(/cards\/#{card_id_charge_params[:cardId]}\/transactions/, hash_including(:value, :currency, :userSuppliedId, pending: true)).and_return({"transaction" => {}})

        lightrail_charge.create(card_id_charge_params)
      end

      it "uses userSuppliedId if supplied in param hash" do
        code_charge_params[:userSuppliedId] ='test-charge-' + rand().to_s

        expect(lightrail_connection).to receive(:make_post_request_and_parse_response).with(/codes/, hash_including(userSuppliedId: code_charge_params[:userSuppliedId])).and_return({"transaction" => {}})

        lightrail_charge.create(code_charge_params)
      end

      it "uses 'value' instead of 'amount' if supplied in param hash" do
        code_charge_params[:value] = -2

        expect(lightrail_connection).to receive(:make_post_request_and_parse_response).with(String, hash_including(value: -2)).and_return({"transaction" => {}})

        lightrail_charge.create(code_charge_params)
      end

      it "set 'pending=true' when 'capture=false' in params" do
        code_charge_params[:capture] = false

        expect(lightrail_connection).to receive(:make_post_request_and_parse_response).with(String, hash_including(pending: true)).and_return({"transaction" => {}})

        lightrail_charge.create(code_charge_params)
      end

      context "when an error response comes back from the API anyway" do
        it "should produce a meaningful error" do
          bad_faraday_response = Faraday::Response.new(status: 404, body: "{\"status\":404,\"message\":\"Could not find object\"}")

          allow(lightrail_connection).to receive_message_chain(:connection, :post).and_return(bad_faraday_response)

          expect {lightrail_charge.create(code_charge_params)}.to raise_error(Lightrail::LightrailError, /Could not find object/)
        end
      end
    end

    context "when given bad/missing params" do
      it "throws an error when required params are missing" do
        expect {lightrail_charge.create()}.to raise_error(ArgumentError), "called LightrailCharge.create with no params"
        expect {lightrail_charge.create({})}.to raise_error(Lightrail::LightrailArgumentError), "called LightrailCharge.create with empty object"
        expect {lightrail_charge.create({code: example_code})}.to raise_error(Lightrail::LightrailArgumentError), "called LightrailCharge.create with '{code: example_code}'"
        expect {lightrail_charge.create([])}.to raise_error(Lightrail::LightrailArgumentError), "called LightrailCharge.create with empty array"
      end
    end

  end

  describe "#cancel" do
    before(:each) do
      @pending_to_void = lightrail_charge.new(pending_charge_object_details)
    end

    context "called on a valid pending transaction" do
      it "voids a pending transaction" do
        expect(lightrail_connection).
            to receive(:make_post_request_and_parse_response).
                with(/cards\/#{@pending_to_void.cardId}\/transactions\/#{@pending_to_void.transactionId}\/void/, Hash).
                and_return({"transaction" => {}})
        @pending_to_void.cancel!
      end
    end

    context "when called on an invalid pending transaction" do
      it "throws an error when required vars are missing or in the wrong format" do
        @pending_to_void.remove_instance_variable(:@transactionId)
        expect {@pending_to_void.cancel!}.to raise_error(Lightrail::LightrailArgumentError)
      end
    end
  end

  describe "#capture" do
    before(:each) do
      @pending_to_capture = lightrail_charge.new(pending_charge_object_details)
    end

    context "called on a valid pending transaction" do
      it "captures a pending transaction" do
        expect(lightrail_connection).
            to receive(:make_post_request_and_parse_response).
                with(/cards\/#{@pending_to_capture.cardId}\/transactions\/#{@pending_to_capture.transactionId}\/capture/, Hash).
                and_return({"transaction" => {}})
        @pending_to_capture.capture!
      end
    end

    context "when called on an invalid pending transaction" do
      it "throws an error when required vars are missing or in the wrong format" do
        @pending_to_capture.remove_instance_variable(:@transactionId)
        expect {@pending_to_capture.capture!}.to raise_error(Lightrail::LightrailArgumentError)
      end
    end
  end


end