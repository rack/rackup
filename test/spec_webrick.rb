# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2022-2023, by Samuel Williams.

require_relative 'helper'

require 'thread'
require 'webrick'

require 'rack/lint'
require 'rack/response'

require_relative 'test_request'

separate_testing do
  require_relative '../lib/rackup/handler'
end

require_relative '../lib/rackup/handler/webrick'

Thread.abort_on_exception = true

describe Rackup::Handler::WEBrick do
  include TestRequest::Helpers

  before do
  @server = WEBrick::HTTPServer.new(Host: @host = 'localhost',
                                    Port: @port = 9202,
                                    Logger: WEBrick::Log.new(nil, WEBrick::BasicLog::WARN),
                                    AccessLog: [])
  @server.mount "/test", Rackup::Handler::WEBrick,
    Rack::Lint.new(TestRequest.new)
  @thread = Thread.new { @server.start }
  trap(:INT) { @server.shutdown }
  @status_thread = Thread.new do
    seconds = 10
    wait_time = 0.1
    until is_running? || seconds <= 0
      seconds -= wait_time
      sleep wait_time
    end
    raise "Server never reached status 'Running'" unless is_running?
  end
  end

  def is_running?
    @server.status == :Running
  end

  it "respond" do
    GET("/test")
    status.must_equal 200
  end

  it "be a WEBrick" do
    GET("/test")
    status.must_equal 200
    response["SERVER_SOFTWARE"].must_match(/WEBrick/)
    response["SERVER_PROTOCOL"].must_equal "HTTP/1.1"
    response["SERVER_PORT"].must_equal "9202"
    response["SERVER_NAME"].must_equal "localhost"
  end

  it "have CGI headers on GET" do
    GET("/test")
    response["REQUEST_METHOD"].must_equal "GET"
    response["SCRIPT_NAME"].must_equal "/test"
    response["REQUEST_PATH"].must_equal "/test"
    response["PATH_INFO"].must_equal ""
    response["QUERY_STRING"].must_equal ""
    response["test.postdata"].must_equal ""

    GET("/test/foo?quux=1")
    response["REQUEST_METHOD"].must_equal "GET"
    response["SCRIPT_NAME"].must_equal "/test"
    response["REQUEST_PATH"].must_equal "/test/foo"
    response["PATH_INFO"].must_equal "/foo"
    response["QUERY_STRING"].must_equal "quux=1"

    GET("/test/foo%25encoding?quux=1")
    response["REQUEST_METHOD"].must_equal "GET"
    response["SCRIPT_NAME"].must_equal "/test"
    response["REQUEST_PATH"].must_equal "/test/foo%25encoding"
    response["PATH_INFO"].must_equal "/foo%25encoding"
    response["QUERY_STRING"].must_equal "quux=1"
  end

  it "have CGI headers on POST" do
    POST("/test", { "rack-form-data" => "23" }, { 'X-test-header' => '42' })
    status.must_equal 200
    response["REQUEST_METHOD"].must_equal "POST"
    response["SCRIPT_NAME"].must_equal "/test"
    response["REQUEST_PATH"].must_equal "/test"
    response["PATH_INFO"].must_equal ""
    response["QUERY_STRING"].must_equal ""
    response["HTTP_X_TEST_HEADER"].must_equal "42"
    response["test.postdata"].must_equal "rack-form-data=23"
  end

  it "support HTTP auth" do
    GET("/test", { user: "ruth", passwd: "secret" })
    response["HTTP_AUTHORIZATION"].must_equal "Basic cnV0aDpzZWNyZXQ="
  end

  it "set status" do
    GET("/test?secret")
    status.must_equal 403
    response["rack.url_scheme"].must_equal "http"
  end

  it "correctly set cookies" do
    @server.mount "/cookie-test", Rackup::Handler::WEBrick,
    Rack::Lint.new(lambda { |req|
                     res = Rack::Response.new
                     res.set_cookie "one", "1"
                     res.set_cookie "two", "2"
                     res.finish
                   })

    Net::HTTP.start(@host, @port) { |http|
      res = http.get("/cookie-test")
      res.code.to_i.must_equal 200
      res.get_fields("set-cookie").must_equal ["one=1", "two=2"]
    }
  end

  it "provide a .run" do
    queue = Queue.new

    t = Thread.new do
      Rackup::Handler::WEBrick.run(lambda {},
                                   Host: 'localhost',
                                   Port: 9210,
                                   Logger: WEBrick::Log.new(nil, WEBrick::BasicLog::WARN),
                                   AccessLog: []) { |server|
        assert_kind_of WEBrick::HTTPServer, server
        queue.push(server)
      }
    end

    server = queue.pop

    # The server may not yet have started: wait for it
    seconds = 10
    wait_time = 0.1
    until server.status == :Running || seconds <= 0
      seconds -= wait_time
      sleep wait_time
    end

    raise "Server never reached status 'Running'" unless server.status == :Running

    server.shutdown
    t.join
  end

  it "return repeated headers" do
    @server.mount "/headers", Rackup::Handler::WEBrick,
    Rack::Lint.new(lambda { |req|
        [
          401,
          { "content-type" => "text/plain",
            "www-authenticate" => ["Bar realm=X", "Baz realm=Y"] },
          [""]
        ]
      })

    Net::HTTP.start(@host, @port) { |http|
      res = http.get("/headers")
      res.code.to_i.must_equal 401
      res["www-authenticate"].must_equal "Bar realm=X, Baz realm=Y"
    }
  end

  it "support Rack partial hijack" do
    io_lambda = lambda{ |io|
      5.times do
        io.write "David\r\n"
      end
      io.close
    }

    @server.mount "/partial", Rackup::Handler::WEBrick,
    Rack::Lint.new(lambda{ |req|
      [
        200,
        { "rack.hijack" => io_lambda },
        [""]
      ]
    })

    Net::HTTP.start(@host, @port){ |http|
      res = http.get("/partial")
      res.body.must_equal "David\r\nDavid\r\nDavid\r\nDavid\r\nDavid\r\n"
    }
  end

  it "produce correct HTTP semantics with upgrade response" do
    app = proc do |env|
      body = proc do |io|
        io.write "hello"
        io.close
      end

      [101, {"connection" => "upgrade", "upgrade" => "text"}, body]
    end

    @server.mount "/app", Rackup::Handler::WEBrick, Rack::Lint.new(app)

    TCPSocket.open(@host, @port) do |socket|
      socket.write "GET /app HTTP/1.1\r\n"
      socket.write "Host: #{@host}\r\n\r\n"

      response = socket.read
      response.must_match(/HTTP\/1.1 101 Switching Protocols/)
      response.must_match(/Connection: upgrade/)
      response.must_match(/Upgrade: text/)
      response.must_match(/hello/)
    end
  end

  it "handle OPTIONS * requests through the Rack app" do
    app = proc do |env|
      if env["REQUEST_METHOD"] == "OPTIONS" && env["PATH_INFO"] == "*"
        [200, {"allow" => "GET,HEAD,POST,PUT,DELETE,OPTIONS"}, [""]]
      else
        [404, {"content-type" => "text/plain"}, ["Not Found"]]
      end
    end

    server = Rackup::Handler::WEBrick::Server.new(
      Rack::Lint.new(app),
      Host: @host,
      Port: 9203,
      Logger: WEBrick::Log.new(nil, WEBrick::BasicLog::WARN),
      AccessLog: []
    )

    thread = Thread.new { server.start }

    # Wait for server to start
    seconds = 10
    wait_time = 0.1
    until server.status == :Running || seconds <= 0
      seconds -= wait_time
      sleep wait_time
    end

    begin
      TCPSocket.open(@host, 9203) do |socket|
        socket.write "OPTIONS * HTTP/1.1\r\n"
        socket.write "Host: #{@host}\r\n"
        socket.write "Connection: close\r\n\r\n"

        response = socket.read
        response.must_match(/HTTP\/1.1 200/)
        # The Rack app should set the Allow header, not WEBrick's default
        response.must_match(/Allow: GET,HEAD,POST,PUT,DELETE,OPTIONS/i)
      end
    ensure
      server.shutdown
      thread.join
    end
  end

  after do
    @status_thread.join
    @server.shutdown
    @thread.join
  end
end
