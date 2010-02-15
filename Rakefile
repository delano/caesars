require 'rubygems'
require 'rake/clean'
require 'rake/gempackagetask'
require 'fileutils'
include FileUtils
 
begin
  require 'hanna/rdoctask'
rescue LoadError
  require 'rake/rdoctask'
end

task :default => :package
 
# SPECS ===============================================================
 
# PACKAGE =============================================================

name = "caesars"
load "#{name}.gemspec"

version = @spec.version

Rake::GemPackageTask.new(@spec) do |p|
  p.need_tar = true if RUBY_PLATFORM !~ /mswin/
end

task :release => [ :rdoc, :package ]

task :install => [ :rdoc, :package ] do
	sh %{sudo gem install pkg/#{name}-#{version}.gem}
end

task :uninstall => [ :clean ] do
	sh %{sudo gem uninstall #{name}}
end


# Rubyforge Release / Publish Tasks ==================================

desc 'Publish website to rubyforge'
task 'publish:rdoc' => 'doc/index.html' do
  sh "scp -rp doc/* rubyforge.org:/var/www/gforge-projects/#{name}/"
end

task 'publish:gem' => [:package] do |t|
  sh <<-end
    rubyforge add_release -o Any -a CHANGES.txt -f -n README.rdoc #{name} #{name} #{@spec.version} pkg/#{name}-#{@spec.version}.gem &&
    rubyforge add_file -o Any -a CHANGES.txt -f -n README.rdoc #{name} #{name} #{@spec.version} pkg/#{name}-#{@spec.version}.tgz 
  end
end


Rake::RDocTask.new do |t|
	t.rdoc_dir = 'doc'
	t.title    = @spec.summary
	t.options << '--line-numbers' << '--inline-source' << '-A cattr_accessor=object'
	t.options << '--charset' << 'utf-8'
	t.rdoc_files.include('LICENSE.txt')
	t.rdoc_files.include('README.rdoc')
	t.rdoc_files.include('CHANGES.txt')
	t.rdoc_files.include('bin/*')
	t.rdoc_files.include('lib/*.rb')
end

CLEAN.include [ 'pkg', '*.gem', '.config', 'doc' ]



