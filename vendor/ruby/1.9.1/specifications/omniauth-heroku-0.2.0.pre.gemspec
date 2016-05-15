# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "omniauth-heroku"
  s.version = "0.2.0.pre"

  s.required_rubygems_version = Gem::Requirement.new("> 1.3.1") if s.respond_to? :required_rubygems_version=
  s.authors = ["Pedro Belo"]
  s.date = "2014-09-11"
  s.description = "OmniAuth strategy for Heroku."
  s.email = ["pedro@heroku.com"]
  s.homepage = "https://github.com/heroku/omniauth-heroku"
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.23"
  s.summary = "OmniAuth strategy for Heroku."

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<omniauth>, ["~> 1.2"])
      s.add_runtime_dependency(%q<omniauth-oauth2>, ["~> 1.2"])
    else
      s.add_dependency(%q<omniauth>, ["~> 1.2"])
      s.add_dependency(%q<omniauth-oauth2>, ["~> 1.2"])
    end
  else
    s.add_dependency(%q<omniauth>, ["~> 1.2"])
    s.add_dependency(%q<omniauth-oauth2>, ["~> 1.2"])
  end
end
