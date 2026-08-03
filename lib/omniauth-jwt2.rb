# frozen_string_literal: true

require "omniauth/jwt2"
require "version_gem"
require_relative "omniauth/jwt2/version"

Omniauth::JWT2::Version.class_eval do
  extend VersionGem::Basic
end
