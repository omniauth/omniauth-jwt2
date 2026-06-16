require "omniauth"
require "jwt"

module OmniAuth
  module Strategies
    class JWT
      class ClaimInvalid < StandardError; end
      class BadJwt < StandardError; end

      include OmniAuth::Strategy

      args [:secret]

      option :secret, nil
      option :decode_options, {}
      option :jwks_loader
      option :algorithm, "HS256" # overridden by options.decode_options[:algorithms]
      option :decode_options, {}
      option :uid_claim, "email"
      option :required_claims, %w[name email]
      option :info_map, {name: "name", email: "email"}
      option :auth_url, nil
      option :valid_within, nil

      def request_phase
        redirect options.auth_url
      end

      def decoded
        begin
          secret = if defined?(OpenSSL)
            case options.algorithm
            when "RS256", "RS384", "RS512"
              OpenSSL::PKey::RSA.new(options.secret).public_key
            when "ES256", "ES384", "ES512"
              ec_key(options.secret)
            when "HS256", "HS384", "HS512"
              options.secret
            else
              raise NotImplementedError, "Unsupported algorithm: #{options.algorithm}"
            end
          else
            options.secret
          end

          # JWT.decode can handle either algorithms or algorithm, but not both.
          default_algos = options.decode_options.key?(:algorithms) ? options.decode_options[:algorithms] : [options.algorithm]
          @decoded ||= ::JWT.decode(
            request.params["jwt"],
            secret,
            true,
            options.decode_options.merge(
              {
                algorithms: default_algos,
                jwks: options.jwks_loader
              }.delete_if { |_, v| v.nil? }
            )
          )[0]
        rescue Exception => e
          raise BadJwt.new("#{e.class}: #{e.message}")
        end
        (options.required_claims || []).each do |field|
          raise ClaimInvalid.new("Missing required '#{field}' claim.") if !@decoded.key?(field.to_s)
        end
        raise ClaimInvalid.new("Missing required 'iat' claim.") if options.valid_within && !@decoded["iat"]
        if options.valid_within && (Time.now.to_i - @decoded["iat"]).abs > options.valid_within.to_i
          raise ClaimInvalid, "'iat' timestamp claim is too skewed from present"
        end

        @decoded
      end

      def ec_key(secret)
        key = if secret.is_a?(OpenSSL::PKey::EC)
          secret
        elsif OpenSSL::PKey.respond_to?(:read)
          OpenSSL::PKey.read(secret)
        else
          OpenSSL::PKey::EC.new(secret)
        end

        ec_public_key(key)
      end

      def ec_public_key(key)
        return key unless key.respond_to?(:private?)
        return key unless key.private?

        public_key = OpenSSL::PKey::EC.new(key.group)
        public_key.public_key = key.public_key
        public_key
      rescue OpenSSL::PKey::PKeyError
        key
      end

      def callback_phase
        super
      rescue BadJwt => e
        fail! "bad_jwt", e
      rescue ClaimInvalid => e
        fail! :claim_invalid, e
      end

      uid { decoded[options.uid_claim] }

      extra do
        {raw_info: decoded}
      end

      info do
        options.info_map.each_with_object({}) do |(k, v), h|
          h[k.to_s] = decoded[v.to_s]
        end
      end
    end

    class Jwt < JWT; end
  end
end
