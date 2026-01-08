module MessageStatusCallbackNotifier
  module Response
    class Base
      def initialize(raw_response)
        @raw_response = raw_response        
      end

      def success?
        (200..299).cover?(@raw_response.code)
      end
    end
  end
end
