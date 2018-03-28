
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'firebase_id_token/version'

Gem::Specification.new do |spec|
  spec.name          = 'firebase_id_token'
  spec.version       = FirebaseIdToken::VERSION
  spec.authors       = ['shunwitter']

  spec.summary       = %q{Ruby implementation to verify Google firebase ID token}
  spec.description   = %q{Retrieved UID on server side using ID token sent from client}
  spec.homepage      = 'https://github.com/shunwitter/firebase_id_token'
  spec.license       = 'MIT'
  spec.require_paths = ['lib']

  spec.add_dependency 'jwt', '~> 2.1'
  spec.add_development_dependency 'bundler', '~> 1.16'
  spec.add_development_dependency 'rake', '~> 10.0'
end
