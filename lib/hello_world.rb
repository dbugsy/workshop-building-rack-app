require 'rack'
require 'rack/server'

class HelloWorld
  def response
    [200, {}, ['Hello world']]
  end
end

class HelloWorldApp
  def self.call(env)
    HelloWorld.new.response
  end
end
