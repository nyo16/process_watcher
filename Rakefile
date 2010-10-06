#-- -*-ruby-*-
# Copyright: Copyright (c) 2010 RightScale, Inc.
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# 'Software'), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
# CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
# TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#++

require 'rubygems'
require 'fileutils'
require 'rake'
require 'spec/rake/spectask'
require 'rake/rdoctask'
require 'rake/gempackagetask'
require 'rake/clean'

task :default => 'spec'

# == Gem packaging == #

Dir['right_scraper*.gemspec'].each do |file|
  Rake::GemPackageTask.new(Gem::Specification.load(file)) do |package|
    package.need_zip = true
    package.need_tar = true
  end
end

task :gem => :populate_staging

CLEAN.include('pkg')

directory "fulllib"
CLEAN.include('fulllib')

task "fulllib/right_scraper_all.rb" => ["fulllib", "lib/right_scraper.rb"] do
  # need to translate absolute gem requires to relative requires, so I use sed.
  sh %Q{sed "s/require '\\([a-z0-9_]*\\)'/\
require File.expand_path(File.join(File.dirname(__FILE__), '\\1'))/"\
 < 'lib/right_scraper.rb' > 'fulllib/right_scraper_all.rb'}
end

desc "Populate staging directory"
task :populate_staging => ["fulllib/right_scraper_all.rb"] do
  intermediate_dir = File.join(File.dirname(__FILE__), 'fulllib')
  Dir.glob('right_scraper_*') do |file|
    next unless File.directory?(file)
    FileUtils.cp_r(Dir.glob("#{file}/lib/*"), intermediate_dir)
  end
end

# == Unit Tests == #

task :specs => :spec

desc "Run unit tests"
Spec::Rake::SpecTask.new do |t|
  t.spec_files = Dir['*/spec/**/*_spec.rb']
  t.spec_opts = lambda do
    IO.readlines(File.join(File.dirname(__FILE__), 'spec', 'spec.opts')).map {|l| l.chomp.split " "}.flatten
  end
end

desc "Run unit tests with RCov"
Spec::Rake::SpecTask.new(:rcov) do |t|
  t.spec_files = Dir['*/spec/**/*_spec.rb']
  t.rcov = true
  t.rcov_opts = lambda do
    IO.readlines(File.join(File.dirname(__FILE__), 'spec', 'rcov.opts')).map {|l| l.chomp.split " "}.flatten
  end
end

desc "Print Specdoc for unit tests"
Spec::Rake::SpecTask.new(:doc) do |t|
   t.spec_opts = ["--format", "specdoc", "--dry-run"]
   t.spec_files = Dir['*/spec/**/*_spec.rb']
end

# == Documentation == #

desc "Generate API documentation to doc/rdocs/index.html"
Rake::RDocTask.new do |rd|
  rd.rdoc_dir = 'doc/rdocs'
  rd.main = 'README.rdoc'
  rd.rdoc_files.include 'README.rdoc', '*/README.rdoc', "*/lib/**/*.rb"

  rd.options << '--inline-source'
  rd.options << '--line-numbers'
  rd.options << '--all'
  rd.options << '--fileboxes'
  rd.options << '--diagram'
end

# == Emacs integration == #
# This requires exuberant ctags.
desc "Rebuild TAGS file"
task :tags do
  sh "ctags-exuberant -a -e -f TAGS --tag-relative -R */lib"
end
