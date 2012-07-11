
begin
  require 'redis'
rescue
  require 'rubygems'
  require 'redis'
end

module Session
  class SessionClient
    def initialize(options={})
      raise ArgumentError, 'options must be Hash' unless options.class == Hash

      options[:host]   ||= 'localhost' unless options[:path]
      options[:port]   ||= 6379
      options[:db]     ||= 0
      options[:prefix] ||= ''
      options[:expire] ||= 0

      @options = options
      @redis   = Redis.new(@options)
    end

    def save(key, value)
      a_key  = "#{@options[:prefix]}#{key}"
      a_data = Marshal.dump(value)
      if @options[:expire] > 0
        @redis.setex(a_key, @options[:expire], a_data)
      else
        @redis.set(a_key, a_data)
      end
      true
    rescue
      false
    end

    def restore(key)
      a_key = "#{@options[:prefix]}#{key}"
      data  = @redis.get(a_key)
      data.nil? ? {} : Marshal.load(data)
    rescue
      {}
    end

    def expire=(key, expire)
      a_key = "#{@options[:prefix]}#{key}"
      @redis.expire(a_key, expire) == 1
    rescue
      false
    end

    def ttl(key)
      a_key = "#{@options[:prefix]}#{key}"
      @redis.ttl(a_key, key)
    rescue
      -1
    end

    def remove(key)
      a_key = "#{@options[:prefix]}#{key}"
      @redis.del(a_key)
    rescue
      false
    end
  end
end

