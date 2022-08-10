# frozen_string_literal: true

warn "Rack::Server is deprecated and replaced by Rackup::Server"
require_relative '../rackup/server'
module Rack
	Server = ::Rackup::Server
end
