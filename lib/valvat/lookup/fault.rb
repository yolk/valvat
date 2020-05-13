class Valvat
  class Lookup
    class Fault < Response
      private

      def self.cleanup_hash(hash)
        {error: hash[:fault][:faultstring]}
      end
    end
  end
end