#The MIT License (MIT)
#
# Copyright (c) 2012 Ido Kanner
#
# Permission is hereby granted, free of charge, to any person obtaining a copy 
# of  this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights 
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell 
# copies of the Software, and to permit persons to whom the Software is 
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE 
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

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

    alias :delete :remove
  end
end

