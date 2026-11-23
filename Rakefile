# -*- ruby -*-
# -*- coding: utf-8 -*-

# TODO
#
#require 'rubygems'
#require 'hoe'
#
#Hoe.plugin :git
#
#require_relative 'lib/svggraph'
#
#Hoe.spec 'svg-graph' do
#  self.version=SVG::Graph::VERSION
#  self.developer('Sean Russell', 'ser_AT_germane-software.com')
#  self.developer('Claudio Bustos', 'clbustos_AT_gmail.com')
#  self.developer('Liehann Loots','liehhanl_AT_gmail.com')
#  self.developer('Piergiuliano Bossi','pgbossi_AT_gmail.com')
#  self.developer('Manuel Widmer','m-widmer_AT_gmx.com')
#  self.rubyforge_name = 'ruby-statsample' # if different than 'svg_graph'
#  self.remote_rdoc_dir = 'svg-graph'
#end

# by default run all unit tests with 'rake test'
task default: [:test]

task :test do
  [
    "test/test_data_point.rb",
    "test/test_plot.rb",
    "test/test_svg_graph.rb",
    "test/test_graph.rb",
    "test/test_histogram.rb",
    "test/run_examples_and_percy.io.rb"
  ].each do |file|
    # exec all above scripts (with simplecov if env is set)
    args = file
    if ENV['COVERAGE']
      args = '-r ./test/simplecov ' + file
    end
    ruby args
  end
end
