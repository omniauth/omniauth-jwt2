# frozen_string_literal: true

require "anonymous_loader"
require "omniauth-jwt2"
RSpec.describe Omniauth::JWT2::Version do
  it_behaves_like "a Version module", described_class

  it "executes the version file for coverage without redefining constants" do
    dir = File.expand_path("../../../lib/omniauth/jwt2", __dir__)
    paths = %w[version.rb version_gem.rb].map { |file| File.join(dir, file) }.select { |path| File.file?(path) }
    anonymous_namespace = AnonymousLoader.load(files: paths)

    expect(anonymous_namespace::Omniauth::JWT2::Version::VERSION).to eq(described_class::VERSION)
  end
end
