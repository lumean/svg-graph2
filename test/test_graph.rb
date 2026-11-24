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

  def test_horizontal_bottom_legend_wraps_items_and_long_names
    graph = DummyGraph.new(:width => 220, :height => 300, :key_position => :bottom,
                           :key_layout => :horizontal)
    ['First', 'Second', 'A very long legend label that must wrap'].each do |title|
      graph.add_data(:data => [1], :title => title)
    end
    root = REXML::Document.new(graph.burn_svg_only).root
    boxes = REXML::XPath.match(root, "//*[local-name()='rect' and starts-with(@class,'key')]")
    texts = REXML::XPath.match(root, "//*[local-name()='text' and @class='keyText']")
    assert_equal(3, boxes.length)
    assert_equal(boxes[0].attributes['y'], boxes[1].attributes['y'])
    assert_operator(boxes[2].attributes['y'].to_f, :>, boxes[1].attributes['y'].to_f)
    assert_equal('A very long legend label that must wrap', texts.drop(2).map(&:text).join)
    assert_operator(texts.length, :>, 3)
  end

  def test_horizontal_legend_uses_pie_keys
    graph = SVG::Graph::Pie.new(:width => 300, :height => 300,
                                :fields => %w[First Second Third],
                                :key_position => :bottom, :key_layout => :horizontal)
    graph.add_data(:data => [1, 2, 3])
    root = REXML::Document.new(graph.burn_svg_only).root
    assert_equal(3, REXML::XPath.match(root, "//*[local-name()='text' and @class='keyText']").length)
  end

  def test_horizontal_legend_rejects_insufficient_chart_height
    graph = DummyGraph.new(:width => 120, :height => 60, :key_position => :bottom,
                           :key_layout => :horizontal)
    graph.add_data(:data => [1], :title => 'A legend that will occupy more space than the chart')
    assert_raise(ArgumentError) { graph.burn }
  end
end