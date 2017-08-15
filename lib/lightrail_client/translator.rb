module LightrailClient
  class Translator

    def self.translate (stripe_object, is_value_positive=false)
      lightrail_object = stripe_object.clone
      lightrail_object[:value] ||= lightrail_object.delete(:amount) if lightrail_object[:amount]
      lightrail_object[:pending] ||= lightrail_object[:capture] === nil ? false : !lightrail_object.delete(:capture)
      lightrail_object[:userSuppliedId] ||= SecureRandom::uuid

      lightrail_object[:value] && is_value_positive ? lightrail_object[:value] = lightrail_object[:value].abs : lightrail_object[:value] = -lightrail_object[:value].abs

      lightrail_object
    end

  end
end