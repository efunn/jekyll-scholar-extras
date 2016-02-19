require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jekyll/scholar/version'

require 'cucumber/rake/task'
Cucumber::Rake::Task.new(:features)

task :default => [:features]

require 'coveralls/rake/task'
Coveralls::RakeTask.new
task :test_with_coveralls => [:features, 'coveralls:push']


