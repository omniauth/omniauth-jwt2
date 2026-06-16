# External gems
require "version_gem"
require_relative "jwt/version"

# This gem
require "omniauth/jwt/version"
require "omniauth/strategies/jwt"

Omniauth::JWT2::Version.class_eval do
  extend VersionGem::Basic
end
