Gem::Specification.new do |s|
  s.name = "backgroundrb_merb"
  s.version = "1.0.3"
  s.platform = Gem::Platform::RUBY
  s.has_rdoc = true
  s.extra_rdoc_files = ["README", "LICENSE", 'TODO']
  s.summary = "BackgroundRB for Merb"
  s.description = s.summary
  s.author = "Josip Lisec"
  s.email = "josiplisec@gmail.com"
  s.homepage = "http://github.com/josip/backgroundrb_merb/tree/master"
  s.add_dependency('merb', '>= 0.9.2')
  s.add_dependency('packet', '>= 0.1.5')
  s.add_dependency('chronic', '>= 0.2.3')
  s.require_path = 'lib'
  s.files = %w(LICENSE README Rakefile TODO) + Dir.glob("{config,generators,lib,pids,server,specs}/**/*")
end
