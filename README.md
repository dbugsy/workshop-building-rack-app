#Skills Workshop: Building a Rack App

This workshop will cover the basics of building and running a Rack application. At the end of the workshop, you should be able to define the terms 'Rack', 'Middleware', 'Request', 'Response' in the context of an HTTP server. The documentation for rack can be found [here](https://github.com/rack/rack)

In order to demonstrate these concepts, we will build a small 'hello world' application.

##Hello world

Rack is a library that provides a simplified interface between your ruby application and your server. We'll start by building an application that displays the words 'Hello world' in the client's browser window.

* start by setting up a project with `bundle init`
* add the gems 'rack' and 'thin' and then bundle install
* now we'll write our first Rack application:
```ruby
require 'rack'
require 'rack/server'

class HelloWorldApp
  def self.call(env)
    [200, {}, ['Hello world']]
  end
end

Rack::Server.start app: HelloWorldApp
```
You should see the following response:
```
Thin web server (v1.6.4 codename Gob Bluth)
Maximum connections set to 1024
Listening on localhost:8080, CTRL+C to stop
```

You can see that we are injecting our HelloWorldApp class into the Server object. The Rack::Server utilises polymorphism - it will work with any object that responds to `#call`. A rack app is simply an object that responds to `#call` and returns a response.

We are providing the response in the form of an array containing three elements. This is known as the 'triplet', and will be converted into an HTTP response. The triplet consists of the status code, a hash of the headers and an enumerable containing the contents of the body, in that order.

If you now go to http://localhost:8080, you should see the message 'Hello world'. Congratulations - you have just written your first Rack app!

##rackup

One issue with our current code is that it contains a line of code that will be executed immediately if you require the file - we wouldn't write code like this in a real application. Rack provides a CLI to start a server from the command line - `rackup`. Let's get that set up.

* remove the two `require`s from the top of the file, and the entire last line (we don't want to start a server from within our code).
* make a new file `config.ru` - the file extension stands for 'rackup'
* from within the config.ru, require your application code
* add the line `run HelloWorldApp` and save
* try to run the code from your command line. Navigate to the correct folder, and run `rackup`.

You should now be able to open your application in the browser as you did before (bear in mind the default port for rackup is 9393).

##Return a query string

So this is great, but we haven't really done anything very useful yet. It would be better if we could respond to input from a user, maybe in the form of some [params](https://github.com/makersacademy/course/blob/master/pills/params.md). We can practice that by returning the contents of some query string parameters. If we type in `http://localhost:9393?message=foo`, we want to see the word 'foo' appear in the browser window.

* change the HelloWorldApp class to actually make use of the env parameter:
```ruby
class HelloWorldApp
  def call(env)
    [200, {}, ["Hello world, you said #{env['QUERY_STRING']}"]]
  end
end
```
* run `rackup`
* In your browser, navigate to `http://localhost:9393?message=foo`. You should see the word 'foo' on the page, although the format is a little strange!
* what can you infer about the contents of the env parameter that Rack is passing into your application? 
* Can you display the entire contents of the env to the page?

##Using a Request object

So far, we have seen that Rack is receiving request data from the server and passing it into our application through an argument on the `.call` method. The raw data passed in from the HTTP request is unwieldy - a large hash containing all sorts of information that we may or may not need. That is why Rack also provides an abstraction in the form of the Request class, that helps us to encapsulate the raw data and provides a simple interface for us to use. Let's use an instance of Request to tidy up our message:

* start by amending your call method to make a new Request object, and then use that object to extract the correct params:
```ruby
class HelloWorldApp
  def self.call(env)
    request = Rack::Request.new(env)
    message = request.params['message'] || 'nothing!'
    [200, {}, ["Hello world! You said #{message}"]]
  end
end
```
* This allows much better control of the params - we can now access them like a ruby hash without any parsing. 
* can you print the contents of the request header on the page? howabout the entire contents of the body?
* using the [documentation](http://www.rubydoc.info/gems/rack/Rack/Request), can you check whether the request was a GET or POST request?

##Using a Response object

We are beginning to see some of the convenience provided by the Rack library - HTTP requests can now be presented as Ruby objects with simple interfaces. We are currently compiling our response in the form of a triplet. This is fine for our simple application, but you can imagine that once we have filled out the headers and the body, this will also become large and unwieldy. Happily, Rack provides an object for this, too. Let's use an instance of Response to return a different status code:

* amend your call method to make a new Response object, and then use that object to return a different status code:
```ruby
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
```
* using the [documentation](http://www.rubydoc.info/gems/rack/Rack/Response), explain what the `.finish` method is doing here.
* what is the difference between `response.write("text")` and `response.body = ("text")`?
* the current `.call` method is becoming complicated - refactor to adhere to SRP.

##Building a stack of middleware

We have seen that we can use rack to simplify the interface between our ruby code and our server. We have built a rack application that responds to `.call`, and so can be injected into Rack::Server. Now let's imagine that we have more tasks we would like to do with the information in the request - for example, we may want to log the request, or cache it. Rack provides for this in the form of middleware. We will now create a class that logs any request to stdout.

* create a new class called Logger, that `puts` the request data:
```ruby
class Logger
  
  def initialize(app)
    @app = app
  end

  def call(env)
    p env.inspect
    @app.call(env)
  end

end
```
* This class follows a pattern that allows multiple Rack applications to be chained together. Each application is initialized with the following application, and when it is finished processing, it passes control to the next app in the chain. 
* We can create a stack of middleware by using Rack::Builder:
```ruby
app = Rack::Builder.new do
  use Logger
  use Cacher
  use Compressor # etc - this stack can become many layers deep!
  run HelloWorldApp
end

Rack::Server.start app: app
```
* As we have a config.ru, we can avoid generating instances of Builder in our codebase, we can simply do the following:
```ruby
require './lib/hello_world'

use Logger
run HelloWorldApp
```
* now run `rackup`. 
* What can you infer that rackup is doing, under the hood?
* What other uses can you think of that may utilize the middleware stack?

##Frameworks supported by Rack

If rack provides the space to hang a stack of middleware, frameworks can extend its functionality with complex routing systems and MVC server structures. Checkout the [rack github](https://github.com/rack/rack) for a list of supported frameworks. Let's examine how rack provides the tools for more complex frameworks:
* run `rackup` in your hello_world directory.
* In your browser, go to `http://localhost:9393/messages/new`
* Does the new routing make any difference to the message you see on the screen?
* Could you output the new path to the browser window?
* How does a framework like sinatra make use of the Rack library?
