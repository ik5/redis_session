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

   ##
   #
   # A session module
   # 
   
module Session

    ##
    #
    # == Example:
    #   
    #   require 'redis_session'
    #   session = Session::SessionClient.new(:prefix => 'example', :host => '10.0.0.31')
    #   
    #   session.save('key', 'value') # save key with the value of value without expire, return true if successful
    #   puts session.restore('key')  # will return "value"
    #   
    #   session.save('self_destruct', 'in', 10) # save the key self_destruct with the value of 'in', and will terminates in 10 seconds
    #   sleep 10.1
    #   session.restore('self_destruct')      # returns empty hash
    #   session.restore('self_destruct', nil) # returns default value of nil
    #   
    #   session.save('boom', { :bomb => 'ball' }, 10) # saving a ruby object
    #   puts session.ttl('boom') # should return the seconds left to the key to live or -1
    #   
    #   session.expire('key', 60)   # the key will be gone in 60 seconds
    #   puts session.restore('key') # prints 'value'
    #   
    #   puts 'has value' if session.value? 'key' # check if key has a value
    #   
    #   session.delete('key')       # deleted it before time :)
    #                               # it's alias to remove
    #   
    #   puts 'still here' if session.key? 'key' # do we have the key ?
    #

  class SessionClient
    
    ##
    #
    # Creates an object of SessionClient
    #
    # ==== Parameters
    # :host:: the ip address or host name of the redis server default localhost
    # :path:: the path to unix socket of redis (instead of :host)
    # :port:: the port number for the host - default 6379
    # :db:: the Redis database number - default 0
    # :prefix:: a prefix string for storing and retriving information
    # :expire:: global expiry of keys in seconds
    #

    def initialize(options={})
      raise ArgumentError, 'options must be Hash' unless options.kind_of? Hash

      options[:host]   ||= 'localhost' unless options[:path]
      options[:port]   ||= 6379
      options[:db]     ||= 0
      options[:prefix] ||= ''
      options[:expire] ||= 0

      @options = options
      @redis   = Redis.new(@options)
    end

    ##
    #
    # Saving a key with a value
    #
    # key:: the name of the key to be saved
    # value:: the value to save. Can be any Ruby object
    # ttl:: expiry time to the key. Default nil.
    #
    # returns:: true if successful or false otherwise 
    #
    # *Note*:: If expire was set and ttl is nil, then the key will have expire by the :expire option
    #

    def save(key, value, ttl = nil)
      a_key  = make_key(key)
      a_data = Marshal.dump(value)
      ttl ||= @options[:expire]
      if ttl > 0
        @redis.setex(a_key, ttl, a_data)
      else
        @redis.set(a_key, a_data)
      end
      true
    rescue
      false
    end

    ##
    #
    # Restoring a key's value or providing a default value instead
    #
    # key:: The name of the key to restore
    # default:: The value to provide if no value was given. Default empty Hash
    #
    # returns:: The value of the key or default value
    #

    def restore(key, default={})
      a_key = make_key(key)
      data  = @redis.get(a_key)
      data.nil? ? default : Marshal.load(data)
    rescue
      default
    end

    ##
    #
    # Set an expire time in seconds to a key. If the key already has an expire time, it reset it to a new time.
    #
    # key:: The name of the key to set the expire time
    # ttl:: The time in seconds to expire the key
    #
    # returns:: true if successful or false if not
    #

    def expire(key, ttl)
      a_key = make_key(key)
      @redis.expire(a_key, ttl)
    rescue
      false
    end

    ##
    #
    # Examines how much time left to a key in seconds
    #
    # key:: The name of a key to check the ttl
    # 
    # returns:: Returns the number of seconds left, or -1 if key does not exists or no ttl exists for it
    #

    def ttl(key)
      a_key = make_key(key)
      @redis.ttl(a_key)
    rescue
      -1
    end

    ##
    #
    # Deleting a key from the session
    #
    # key:: The name of the key to be removed
    #
    # returns:: true if successful or false otherwise
    #

    def remove(key)
      a_key = make_key(key)
      @redis.del(a_key)
    rescue
      false
    end

    ##
    #
    # Check to see if a key exists
    #
    # key:: The name of the key to check
    #
    # returns:: true if it exists or false otherwise
    #

    def key?(key)
      a_key = make_key(key)
      @redis.exists a_key
    rescue
      false
    end
    
    ##
    #
    # Check if a key has a value
    #
    # key:: The name of the key to check
    #
    # returns:: true if exists or false otherwise
    #

    def value?(key)
      a_key = make_key(key)
      @redis.get(a_key) != nil
    rescue
      false
    end

    ##
    #
    # Deleting a key from the session
    #
    # key:: The name of the key to be removed
    #
    # returns:: true if successful or false otherwise
    #

    alias :delete :remove

    private
      ##
      #
      # Generate a key with a prefix string
      #
      # key:: The name of the key to generate
      #
      # returns:: the key with the prefix
      #
      
      def make_key(key)
        "#{@options[:prefix]}#{key}"
      end
  end
end

