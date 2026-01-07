module Retryable
  def self.call(options = {})
    opts = { tries: 1, on: Exception }.merge(options)

    retry_exception = opts[:on]
    retries = opts[:tries]

    begin
      yield retries
    rescue *retry_exception
      if (retries -= 1) > 0
        sleep 2
        retry
      else
        raise
      end
    end
  end
end