# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{capistrano-provisioning}
  s.version = "0.0.7"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Sam Phillips"]
  s.date = %q{2010-06-30}
  s.description = %q{Capistrano Provisioning is an extension to Capistrano that allows you to define clusters of servers and run provisioning tasks on them, such as installing users. It is a replacement for the fabric gem (http://rubygems.org/gems/fabric).}
  s.email = %q{sam@samdanavia.com}
  s.extra_rdoc_files = [
    "LICENSE",
     "README.mdown"
  ]
  s.files = [
    ".document",
     "LICENSE",
     "README.mdown",
     "Rakefile",
     "VERSION",
     "capistrano-provisioning.gemspec",
     "lib/capistrano-provisioning.rb",
     "lib/capistrano-provisioning/cluster.rb",
     "lib/capistrano-provisioning/namespaces.rb",
     "lib/capistrano-provisioning/recipes.rb",
     "lib/capistrano-provisioning/user.rb",
     "pkg/capistrano-provisioning-0.0.0.gem",
     "pkg/capistrano-provisioning-0.0.1.gem",
     "pkg/capistrano-provisioning-0.0.3.gem",
     "pkg/capistrano-provisioning-0.0.4.gem",
     "pkg/capistrano-provisioning-0.0.6.gem",
     "spec/cluster_spec.rb",
     "spec/namespaces_spec.rb",
     "spec/recipes_spec.rb",
     "spec/spec.opts",
     "spec/spec_helper.rb",
     "spec/user_spec.rb"
  ]
  s.homepage = %q{http://github.com/setfire/capistrano-provisioning}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.6}
  s.summary = %q{Provision clusters of servers with Capistrano}
  s.test_files = [
    "spec/cluster_spec.rb",
     "spec/namespaces_spec.rb",
     "spec/recipes_spec.rb",
     "spec/spec_helper.rb",
     "spec/user_spec.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<capistrano>, [">= 2.5.18"])
      s.add_development_dependency(%q<rspec>, [">= 1.2.9"])
    else
      s.add_dependency(%q<capistrano>, [">= 2.5.18"])
      s.add_dependency(%q<rspec>, [">= 1.2.9"])
    end
  else
    s.add_dependency(%q<capistrano>, [">= 2.5.18"])
    s.add_dependency(%q<rspec>, [">= 1.2.9"])
  end
end

