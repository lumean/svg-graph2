require 'test/unit'
require_relative '../lib/svggraph'

class TestGraph < Test::Unit::TestCase
  class DummyGraph < SVG::Graph::Graph
    def get_css; end
    def draw_data; end

    def get_x_labels
      []
    end
    def get_y_labels
      []
    end
  end
  
  def test_to_iruby
    graph = DummyGraph.new({})
    graph.add_data({ data: [1,2,3] })
    assert_equal graph.to_iruby, ["text/html", graph.burn_svg_only]
  end

  def test_accessible_title_and_description_are_emitted_and_escaped
    graph = DummyGraph.new(:accessible_title => 'Revenue & costs',
                           :accessible_description => 'A < B')
    graph.add_data(:data => [1])
    root = REXML::Document.new(graph.burn_svg_only).root
    assert_equal('img', root.attributes['role'])
    assert_equal('Revenue & costs', root.elements['title'].text)
    assert_equal('A < B', root.elements['desc'].text)
  end

  def test_accessible_description_requires_a_title
    graph = DummyGraph.new(:accessible_description => 'Description')
    graph.add_data(:data => [1])
    assert_raise(ArgumentError) { graph.burn }

    graph = DummyGraph.new(:accessible_title => '')
    graph.add_data(:data => [1])
    assert_raise(ArgumentError) { graph.burn }
  end
end