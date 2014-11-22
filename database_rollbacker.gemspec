# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'database_rollbacker/version'

Gem::Specification.new do |spec|
  spec.name          = "database_rollbacker"
  spec.version       = DatabaseRollbacker::VERSION
  spec.authors       = ["Shinsuke Nishio"]
  spec.email         = ["nishio@densan-labs.net"]
  spec.summary       = %q{Rollback to savepoint your database}
  spec.description   = %q{Rollback to savepoint your database}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "activerecord-mysql2-adapter"
  spec.add_development_dependency "mysql2"

  # ORM
  spec.add_development_dependency "activerecord"
end
