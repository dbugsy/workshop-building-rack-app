require 'rack'
require 'rack/server'

class HelloWorld
  def response
    [200, {}, ['Hello world']]
  end
end

class HelloWorldApp
  def self.call(env)
    [200, {}, ["Hello world, you said #{env['QUERY_STRING']}"]]
  end
end
