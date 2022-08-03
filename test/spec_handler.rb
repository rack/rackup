# frozen_string_literal: true

require_relative 'helper'

separate_testing do
  require_relative '../lib/rackup/handler'
end

class Rackup::Handler::Lobster; end
class RockLobster; end

describe Rackup::Handler do
  it "has registered default handlers" do
    Rackup::Handler.get('cgi').must_equal Rackup::Handler::CGI
    Rackup::Handler.get('webrick').must_equal Rackup::Handler::WEBrick
  end

  it "raise LoadError if handler doesn't exist" do
    lambda {
      Rackup::Handler.get('boom')
    }.must_raise(LoadError)

    lambda {
      Rackup::Handler.get('Object')
    }.must_raise(LoadError)
  end

  it "get unregistered, but already required, handler by name" do
    Rackup::Handler.get('Lobster').must_equal Rackup::Handler::Lobster
  end

  it "register custom handler" do
    Rackup::Handler.register('rock_lobster', RockLobster)
    Rackup::Handler.get('rock_lobster').must_equal RockLobster
  end

  it "not need registration for properly coded handlers even if not already required" do
    begin
      $LOAD_PATH.push File.expand_path('../unregistered_handler', __FILE__)
      Rackup::Handler.get('Unregistered').must_equal Rackup::Handler::Unregistered
      lambda { Rackup::Handler.get('UnRegistered') }.must_raise LoadError
      Rackup::Handler.get('UnregisteredLongOne').must_equal Rackup::Handler::UnregisteredLongOne
    ensure
      $LOAD_PATH.delete File.expand_path('../unregistered_handler', __FILE__)
    end
  end

  it "allow autoloaded handlers to be registered properly while being loaded" do
    path = File.expand_path('../registering_handler', __FILE__)
    begin
      $LOAD_PATH.push path
      Rackup::Handler.get('registering_myself').must_equal Rackup::Handler::RegisteringMyself
    ensure
      $LOAD_PATH.delete path
    end
  end
end
