# -*- encoding: utf-8 -*-
# stub: blockchain 0.1.pre20171222114157 ruby lib

Gem::Specification.new do |s|
  s.name = "blockchain".freeze
  s.version = "0.1.pre20171222114157"

  s.required_rubygems_version = Gem::Requirement.new("> 1.3.1".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Michael Granger".freeze]
  s.cert_chain = ["certs/ged.pem".freeze]
  s.date = "2017-12-22"
  s.description = "".freeze
  s.email = ["ged@FaerieMUD.org".freeze]
  s.extra_rdoc_files = ["README.md".freeze, "History.md".freeze, "README.md".freeze]
  s.files = [".simplecov".freeze, "ChangeLog".freeze, "History.md".freeze, "README.md".freeze, "Rakefile".freeze, "lib/blockchain.rb".freeze, "lib/blockchain/currency.rb".freeze, "lib/blockchain/ledger.rb".freeze, "lib/blockchain/proof_of_work.rb".freeze, "spec/blockchain/proof_of_work_spec.rb".freeze, "spec/blockchain_spec.rb".freeze, "spec/spec_helper.rb".freeze]
  s.homepage = "http://repo.deveiate.org/Block-Chain".freeze
  s.licenses = ["BSD-3-Clause".freeze]
  s.rdoc_options = ["--main".freeze, "README.md".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.5.0".freeze)
  s.rubygems_version = "2.7.3".freeze
  s.summary = "".freeze

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<loggability>.freeze, ["~> 0.14"])
      s.add_runtime_dependency(%q<msgpack>.freeze, ["~> 1.2"])
      s.add_runtime_dependency(%q<uuid>.freeze, ["~> 2.3"])
      s.add_development_dependency(%q<hoe-mercurial>.freeze, ["~> 1.4"])
      s.add_development_dependency(%q<hoe-deveiate>.freeze, ["~> 0.9"])
      s.add_development_dependency(%q<hoe-highline>.freeze, ["~> 0.2"])
      s.add_development_dependency(%q<rdoc>.freeze, ["~> 6.0"])
      s.add_development_dependency(%q<simplecov>.freeze, ["~> 0.7"])
      s.add_development_dependency(%q<rdoc-generator-fivefish>.freeze, ["~> 0.3"])
      s.add_development_dependency(%q<hoe>.freeze, ["~> 3.16"])
    else
      s.add_dependency(%q<loggability>.freeze, ["~> 0.14"])
      s.add_dependency(%q<msgpack>.freeze, ["~> 1.2"])
      s.add_dependency(%q<uuid>.freeze, ["~> 2.3"])
      s.add_dependency(%q<hoe-mercurial>.freeze, ["~> 1.4"])
      s.add_dependency(%q<hoe-deveiate>.freeze, ["~> 0.9"])
      s.add_dependency(%q<hoe-highline>.freeze, ["~> 0.2"])
      s.add_dependency(%q<rdoc>.freeze, ["~> 6.0"])
      s.add_dependency(%q<simplecov>.freeze, ["~> 0.7"])
      s.add_dependency(%q<rdoc-generator-fivefish>.freeze, ["~> 0.3"])
      s.add_dependency(%q<hoe>.freeze, ["~> 3.16"])
    end
  else
    s.add_dependency(%q<loggability>.freeze, ["~> 0.14"])
    s.add_dependency(%q<msgpack>.freeze, ["~> 1.2"])
    s.add_dependency(%q<uuid>.freeze, ["~> 2.3"])
    s.add_dependency(%q<hoe-mercurial>.freeze, ["~> 1.4"])
    s.add_dependency(%q<hoe-deveiate>.freeze, ["~> 0.9"])
    s.add_dependency(%q<hoe-highline>.freeze, ["~> 0.2"])
    s.add_dependency(%q<rdoc>.freeze, ["~> 6.0"])
    s.add_dependency(%q<simplecov>.freeze, ["~> 0.7"])
    s.add_dependency(%q<rdoc-generator-fivefish>.freeze, ["~> 0.3"])
    s.add_dependency(%q<hoe>.freeze, ["~> 3.16"])
  end
end
