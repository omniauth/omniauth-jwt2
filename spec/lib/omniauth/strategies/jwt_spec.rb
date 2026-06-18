require "spec_helper"

RSpec.describe OmniAuth::Strategies::JWT do
  def generate_ec_private_key(curve_name)
    return OpenSSL::PKey::EC.generate(curve_name) if OpenSSL::PKey::EC.respond_to?(:generate)

    key = OpenSSL::PKey::EC.new(curve_name)
    key.generate_key
    key
  end

  let(:response_json) { JSON.parse(last_response.body) }
  let(:rand_secret) { SecureRandom.hex(10) }
  let(:args) { [rand_secret, {auth_url: "http://example.com/login"}] }

  let(:app) {
    the_args = args
    Rack::Builder.new do |b|
      b.use Rack::Session::Cookie, secret: SecureRandom.hex(32)
      b.use OmniAuth::Strategies::JWT, *the_args
      b.run lambda { |env|
        [200, {}, [(env["omniauth.auth"] || {}).to_json]]
      }
    end
  }

  describe "omniauth-jwt2 require path" do
    it "loads through the gem-name require path" do
      expect(require("omniauth-jwt2")).to be(false).or be(true)
    end
  end

  it "aliases the historical version namespace to the gem-name namespace" do
    expect(Omniauth::JWT::Version).to equal(Omniauth::JWT2::Version)
    expect(Omniauth::JWT::VERSION).to eq(Omniauth::JWT2::VERSION)
  end

  context "request phase" do
    it "redirects to the configured login url" do
      # TODO: Figure out how to write this test without using the deprecated
      #       and unsafe, "get" method for the request phase.
      get "/auth/jwt"
      expect(last_response.status).to eq(302)
      expect(last_response.headers["Location"]).to eq("http://example.com/login")
    end
  end

  context "callback phase" do
    it "decodes the response" do
      encoded = JWT.encode({name: "Bob", email: "steve@example.com"}, rand_secret)
      get "/auth/jwt/callback?jwt=" + encoded
      expect(response_json["info"]["email"]).to eq("steve@example.com")
    end

    it "does not work without required fields" do
      encoded = JWT.encode({name: "Steve"}, rand_secret)
      get "/auth/jwt/callback?jwt=" + encoded
      expect(last_response.status).to eq(302)
    end

    it "assigns the uid" do
      encoded = JWT.encode({name: "Steve", email: "dude@awesome.com"}, rand_secret)
      get "/auth/jwt/callback?jwt=" + encoded
      expect(response_json["uid"]).to eq("dude@awesome.com")
    end

    context "with a non-default encoding algorithm" do
      let(:args) { [rand_secret, {auth_url: "http://example.com/login", decode_options: {algorithms: ["HS512", "HS256"]}}] }

      it "decodes the response with an allowed algorithm" do
        encoded = JWT.encode({name: "Bob", email: "steve@example.com"}, rand_secret, "HS512")
        get "/auth/jwt/callback?jwt=" + encoded
        expect(JSON.parse(last_response.body)["info"]["email"]).to eq("steve@example.com")

        encoded = JWT.encode({name: "Bob", email: "steve@example.com"}, rand_secret, "HS256")
        get "/auth/jwt/callback?jwt=" + encoded
        expect(JSON.parse(last_response.body)["info"]["email"]).to eq("steve@example.com")
      end

      it "fails decoding the response with a different algorithm" do
        encoded = JWT.encode({name: "Bob", email: "steve@example.com"}, rand_secret, "HS384")
        get "/auth/jwt/callback?jwt=" + encoded
        expect(last_response.headers["Location"]).to include("/auth/failure")
      end
    end

    context "with a :valid_within option set" do
      let(:args) { [rand_secret, {auth_url: "http://example.com/login", valid_within: 300}] }

      it "works if the iat key is within the time window" do
        encoded = JWT.encode({name: "Ted", email: "ted@example.com", iat: Time.now.to_i}, rand_secret)
        get "/auth/jwt/callback?jwt=" + encoded
        expect(last_response.status).to eq(200)
      end

      it "does not work if the iat key is outside the time window" do
        encoded = JWT.encode({name: "Ted", email: "ted@example.com", iat: Time.now.to_i + 500}, rand_secret)
        get "/auth/jwt/callback?jwt=" + encoded
        expect(last_response.status).to eq(302)
      end

      it "does not work if the iat key is missing" do
        encoded = JWT.encode({name: "Ted", email: "ted@example.com"}, rand_secret)
        get "/auth/jwt/callback?jwt=" + encoded
        expect(last_response.status).to eq(302)
      end
    end
  end

  describe "#decoded" do
    subject { described_class.new({}) }

    let(:timestamp) { Time.now.to_i }
    let(:claims) do
      {
        id: 123,
        name: "user_example",
        email: "user@example.com",
        iat: timestamp
      }
    end

    let(:algorithm) { "HS256" }
    let(:secret) { rand_secret }
    let(:private_key) { secret }
    let(:payload) { JWT.encode(claims, private_key, algorithm) }
    let(:expect_request_params) { true }

    before do
      subject.options[:secret] = secret
      subject.options[:algorithm] = algorithm

      # We use Rack::Request instead of ActionDispatch::Request because
      # Rack::Test::Methods enables testing of this module.
      if expect_request_params
        expect_next_instance_of(Rack::Request) do |rack_request|
          expect(rack_request).to receive(:params).and_return("jwt" => payload)
        end
      end
    end

    ecdsa_named_curves = {
      "ES256" => "prime256v1",
      "ES384" => "secp384r1",
      "ES512" => "secp521r1"
    }.freeze

    algos = {
      OpenSSL::PKey::RSA => %w[RS256 RS384 RS512],
      String => %w[HS256 HS384 HS512]
    }
    supports_ecdsa_jwt = OpenSSL::PKey::EC.method_defined?(:dsa_sign_asn1) &&
      OpenSSL::PKey::EC.method_defined?(:dsa_verify_asn1)
    if supports_ecdsa_jwt && !["2.2.10", "2.3.8"].include?(RubyVersion.to_s)
      algos.merge!(OpenSSL::PKey::EC => %w[ES256 ES384 ES512])
    end
    algos.each do |private_key_class, algorithms|
      algorithms.each do |algorithm|
        context "when the #{algorithm} algorithm is used" do
          let(:algorithm) { algorithm }
          let(:ecdsa_private_key) { generate_ec_private_key(ecdsa_named_curves[algorithm]) }
          let(:secret) do
            # rubocop:disable Style/CaseLikeIf
            if private_key_class == OpenSSL::PKey::RSA
              private_key_class.generate(2048)
                .to_pem
            elsif private_key_class == OpenSSL::PKey::EC
              ecdsa_private_key
            else
              private_key_class.new(rand_secret)
            end
            # rubocop:enable Style/CaseLikeIf
          end

          let(:private_key) do
            if private_key_class == OpenSSL::PKey::EC
              ecdsa_private_key
            else
              private_key_class.new(secret)
            end
          end

          it "decodes the user information" do
            result = subject.decoded

            expect(result).to eq(claims.stringify_keys)
          end
        end
      end
    end

    context "when OpenSSL is unavailable" do
      before do
        hide_const("OpenSSL")
      end

      it "uses the configured secret before JWT decoding fails without OpenSSL" do
        expect { subject.decoded }.to raise_error(
          OmniAuth::Strategies::Jwt::BadJwt,
          /uninitialized constant JWT::(?:JWA|Algos)::Hmac::OpenSSL/
        )
      end
    end

    context "when the configured algorithm is unsupported" do
      let(:algorithm) { "NOPE" }
      let(:payload) { JWT.encode(claims, private_key, "HS256") }
      let(:expect_request_params) { false }

      it "raises a bad JWT error" do
        expect { subject.decoded }.to raise_error(OmniAuth::Strategies::Jwt::BadJwt, /Unsupported algorithm: NOPE/)
      end
    end

    context "required claims is missing" do
      let(:claims) do
        {
          id: 123,
          email: "user@example.com",
          iat: timestamp
        }
      end

      it "raises error" do
        expect { subject.decoded }.to raise_error(OmniAuth::Strategies::Jwt::ClaimInvalid)
      end
    end

    context "when valid_within is specified but iat attribute is missing in response" do
      let(:claims) do
        {
          id: 123,
          name: "user_example",
          email: "user@example.com"
        }
      end

      before do
        # Omniauth config values are always strings!
        subject.options[:valid_within] = (60 * 60 * 24 * 2).to_s # 2 days
      end

      it "raises error" do
        expect { subject.decoded }.to raise_error(OmniAuth::Strategies::Jwt::ClaimInvalid)
      end
    end

    context "when timestamp claim is too skewed from present" do
      let(:claims) do
        {
          id: 123,
          name: "user_example",
          email: "user@example.com",
          iat: timestamp - (60 * 60 * 10) # minus ten minutes
        }
      end

      before do
        # Omniauth config values are always strings!
        subject.options[:valid_within] = "2" # 2 seconds
      end

      it "raises error" do
        expect { subject.decoded }.to raise_error(OmniAuth::Strategies::Jwt::ClaimInvalid)
      end
    end
  end

  describe "#ec_key" do
    subject { described_class.new({}) }

    let(:ec_private_key) { generate_ec_private_key("prime256v1") }

    it "accepts EC key objects directly" do
      expect(subject.ec_key(ec_private_key)).to be_a(OpenSSL::PKey::EC)
    end

    it "reads EC keys with the generic OpenSSL reader when available" do
      allow(OpenSSL::PKey).to receive(:read).with("ec-key-pem").and_return(ec_private_key)

      expect(subject.ec_key("ec-key-pem")).to be_a(OpenSSL::PKey::EC)
    end

    it "falls back to the EC constructor when the generic OpenSSL reader is unavailable" do
      allow(OpenSSL::PKey).to receive(:respond_to?).and_call_original
      allow(OpenSSL::PKey).to receive(:respond_to?).with(:read).and_return(false)

      expect(subject.ec_key("prime256v1")).to be_a(OpenSSL::PKey::EC)
    end
  end

  describe "#ec_public_key" do
    subject { described_class.new({}) }

    it "leaves legacy EC keys without private-key predicates unchanged" do
      key = Object.new

      expect(subject.ec_public_key(key)).to equal(key)
    end

    it "leaves public EC keys unchanged" do
      key = double("public EC key", private?: false)

      expect(subject.ec_public_key(key)).to equal(key)
    end
  end
end
