# -*- encoding: utf-8 -*-
# For now the Gemspec is maintained manually
# EDIT THIS FILE DIRECTLY
# currently there are no Jeweler::Tasks in the rake file Rakefile,
# setup of the dev toolchain including rake and juwelier will be done at a later stage.


require_relative 'lib/svggraph'

Gem::Specification.new do |s|
  s.name = %q{svg-graph}
  s.version = SVG::Graph::VERSION

  #s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = [%q{Sean Russell}, %q{Claudio Bustos}, %q{Liehann Loots}, %q{Piergiuliano Bossi}, %q{Manuel Widmer}]
  s.date = Time.now.strftime("%Y-%m-%d")
  s.description = %q{Gem version of SVG:::Graph. SVG:::Graph is a pure Ruby library for generating charts,
which are a type of graph where the values of one axis are not scalar. SVG::Graph has a verry similar API to
the Perl library SVG::TT::Graph, and the resulting charts also look the same. This isn't surprising,
because SVG::Graph started as a loose port of SVG::TT::Graph, although the internal code no longer resembles
the Perl original at all.
  }
  s.email = [ %q{ser_AT_germane-software.com},
              %q{clbustos_AT_gmail.com},
              %q{liehannl_AT_gmail_DOT_com},
              %q{pgbossi_AT_gmail_DOT_com},
              %q{m-widmer_AT_gmx_DOT_ch} ]
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.md",
    "README.txt"
  ]
  s.files = [
    "GPL.txt",
    "History.txt",
    "LICENSE.txt",
    "README.txt",
    "README.md",
    "Rakefile",
    "lib/SVG/Graph/Bar.rb",
    "lib/SVG/Graph/BarBase.rb",
    "lib/SVG/Graph/BarHorizontal.rb",
    "lib/SVG/Graph/C3js.rb",
    "lib/SVG/Graph/DataPoint.rb",
    "lib/SVG/Graph/ErrBar.rb",
    "lib/SVG/Graph/Graph.rb",
    "lib/SVG/Graph/Line.rb",
    "lib/SVG/Graph/Pie.rb",
    "lib/SVG/Graph/Plot.rb",
    "lib/SVG/Graph/Schedule.rb",
    "lib/SVG/Graph/TimeSeries.rb",
    "lib/svggraph.rb",
    "test/test_svg_graph.rb"
  ]
  s.homepage = %q{https://github.com/lumean/svg-graph2}
  s.licenses = [%q{GPL-2.0}]
  s.require_paths = [%q{lib}]
  #s.rubyforge_project = %q{ruby-statsample}
  #s.rubygems_version = %q{1.8.6}
  s.summary = %q{SVG:::Graph is a pure Ruby library for generating charts, which are a type of graph where the values of one axis are not scalar.}

  s.add_dependency("rexml")

  #if s.respond_to? :specification_version then
  #  s.specification_version = 3
  #
  #  if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
  #    s.add_development_dependency(%q<jeweler>, ["~> 1.6.4"])
  #  else
  #    s.add_dependency(%q<jeweler>, ["~> 1.6.4"])
  #  end
  #else
  #  s.add_dependency(%q<jeweler>, ["~> 1.6.4"])
  #end
end
