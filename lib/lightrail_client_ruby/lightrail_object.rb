module LightrailClientRuby
  class LightrailObject

    def initialize(hash)
      values = Marshal.load(Marshal.dump(hash))
      values.each {|key, value| instance_variable_set("@#{key}", value)}
    end

  end
end