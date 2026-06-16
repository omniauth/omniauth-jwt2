# frozen_string_literal: true

require "version_gem"
require_relative "jwt2/version"

require_relative "jwt"

Omniauth::JWT2::Version.class_eval do
  extend VersionGem::Basic
end
