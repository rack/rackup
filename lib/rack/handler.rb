# frozen_string_literal: true

warn "Rack::Handler is deprecated and replaced by Rackup::Handler"
require_relative '../rackup/handler'
module Rack
	Handler = ::Rackup::Handler
end
