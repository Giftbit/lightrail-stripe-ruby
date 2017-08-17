module LightrailClient
  class Constants

    LIGHTRAIL_CODE_KEYS = [:code, :lightrail_code]
    LIGHTRAIL_CARD_ID_KEYS = [:cardId, :card_id, :lightrail_card_id]
    LIGHTRAIL_USER_SUPPLIED_ID_KEYS = [:user_supplied_id, :lightrail_user_supplied_id, :idempotency_key]

    LIGHTRAIL_PAYMENT_METHODS = self::LIGHTRAIL_CODE_KEYS + self::LIGHTRAIL_CARD_ID_KEYS

  end
end