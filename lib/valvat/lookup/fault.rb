class Valvat
  class Lookup
    class Fault < Response
      private

      def self.cleanup_hash(hash)
        fault = hash[:fault][:faultstring]
        {fault: fault, valid: fault == "INVALID_INPUT" ? false : nil}
      end
    end
  end
end