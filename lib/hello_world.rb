require 'rack'
require 'rack/server'

class HelloWorld
  def response
    [200, {}, ['Hello world']]
  end
end

class Logger
  
  def initialize(app)
    @app = app
  end

  def call(env)
    p env.inspect
    @app.call(env)
  end

end

class HelloWorldApp
  def self.call(env)
    request = Rack::Request.new(env)
    message = request.params['message'] || 'nothing!'

    response = Rack::Response.new
    response.write("Hello world! You said #{message}")
    response.status = 202
    response.finish
  end
end
