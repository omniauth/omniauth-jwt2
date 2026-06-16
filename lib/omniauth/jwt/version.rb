# frozen_string_literal: true

require_relative "../jwt2/version"

module Omniauth
  module JWT
    Version = JWT2::Version unless const_defined?(:Version, false)
    VERSION = JWT2::VERSION unless const_defined?(:VERSION, false)
  end
end
