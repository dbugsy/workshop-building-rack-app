require 'rack'
require 'rack/server'

class HelloWorld
  def response
    [200, {}, ['Hello world']]
  end
end

class HelloWorldApp
  def self.call(env)
    request = Rack::Request.new(env)
    message = request.params['message'] || 'nothing!'
      [200, {}, ["Hello world! You said #{message}"]]
  end
end
