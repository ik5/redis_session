# Redis Session 

Redis\_session is a ruby based library that allow every ruby application to 
store information using Redis.

The design of the library was for disconnected non web based applications, but
it can be used for web based applications just as well.

By providing unique prefix for each session, you can distinguish between each 
request.

## Current features

 * Adding prefix to each session instance
 * Expiring keys globally or specific keys
 * Saving keys with values, and possible to add expire time in seconds
 * Set expire time to existing keys (updating time for already expiring keys)
 * Restoring values, and giving default values (by default if no value, 
   it returns an empty hash)
 * Checking the remaining time of keys
 * Checking if key exists
 * Checking if key has a value
 * Removing keys
 * Changing the prefix using the prefix= method
 * find key and value based on custom lookup

### Documentation

 The source code is using rdoc.

Example:
--------
    require 'redis_session'

    session = Session::SessionClient.new(:prefix => 'example')

    session.save('key', 'value') # save key with the value of value 
                                 # without expire, return true if successful
    puts session.restore('key')  # will return "value"

    session.save('self_destruct', 'in', 10) # save the key self_destruct with 
                                            # the value of 'in', and will 
                                            # terminates in 10 seconds
    sleep 10.1
    session.restore('self_destruct')      # returns empty hash
    session.restore('self_destruct', nil) # returns default value of nil

    session.save('boom', { :bomb => 'ball' }, 10) # saving a ruby object
    puts session.ttl('boom') # should return the seconds left to the key to live
                             # or -1

    session.expire('key', 60)   # the key will be gone in 60 seconds
    puts session.restore('key') # prints 'value'

    puts 'has value' if session.value? 'key' # check if key has a value

    session.delete('key')       # deleted it before time :)
                                # it's alias to remove

    puts 'still here' if session.key? 'key' # do we have the key ?
    ret = session.scan_by do |x|
       next unless x.kind_of? Hash
       next unless x.key? :click
   
       x[:click] == true
    end

LICENSE
-------
The following library is brought to you using MIT license.

