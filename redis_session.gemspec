# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'redis_session/version'

Gem::Specification.new do |spec|
  spec.name          = 'redis_session'
  spec.version       = Session::VERSION
  spec.authors       = ['Ido Kanner']
  spec.email         = ['idokan@gmail.com']

  spec.summary       = 'A session handler using Redis DB'
  spec.description   = <<-EOF
                          A session like handler of data using the Redis Database.
                          The session is built with mindset that non web applications
                          can use it just as well as web applications.
                          EOF
  spec.homepage      = 'https://github.com/ik5/redis_session'
  spec.license       = 'MIT'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  # if spec.respond_to?(:metadata)
  #   spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  # else
  #   raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  # end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'bin'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency             'redis'
  spec.add_development_dependency 'bundler', '~> 1.12'
  spec.add_development_dependency 'rake',    '>= 12.3.3'
  spec.add_development_dependency 'rspec',   '~> 3.0'
end
