require 'test/unit'
require_relative '../lib/svggraph'
require_relative '../lib/SVG/Graph/DataPoint'

class TestSvgGraphPlot < Test::Unit::TestCase

  def setup
    DataPoint.reset_shape_criteria
    @output_folder = File.expand_path("percy.io_staticpages", __dir__)
  end

  def teardown
    DataPoint.reset_shape_criteria
  end

  def test_point_rows_keep_metadata_aligned_and_do_not_mutate_input
    points = [[3, 30, 'third', 'square', '/three'], [1, 10, 'first', nil, '/one']]
    graph = SVG::Graph::Plot.new(:add_popups => true)
    graph.add_data(:points => points, :title => 'Series')

    data = graph.instance_variable_get(:@data).first
    assert_equal([[1, 3], [10, 30]], data[:data])
    assert_equal(['first', 'third'], data[:description])
    assert_equal([nil, 'square'], data[:shape])
    assert_equal(['/one', '/three'], data[:url])
    assert_equal(3, points[0][0])
    assert_match(/first/, graph.burn)
  end

  def test_timeseries_accepts_point_rows_without_changing_subclass_data_layout
    graph = SVG::Graph::TimeSeries.new({})
    points = [['2020-01-02', 2, 'later'], ['2020-01-01', 1, 'earlier']]
    graph.add_data(:points => points, :title => 'Series')
    data = graph.instance_variable_get(:@data).first
    assert_equal([1, 2], data[:data][1])
    assert_equal(['earlier', 'later'], data[:description])
    assert_equal('2020-01-02', points[0][0])
    assert_match(/<svg/, graph.burn)
  end

  def test_point_rows_reject_ambiguous_or_incomplete_input
    graph = SVG::Graph::Plot.new({})
    assert_raise(ArgumentError) { graph.add_data(:points => [[1, 2]], :data => [1, 2]) }
    assert_raise(ArgumentError) { graph.add_data(:points => [[1, nil]]) }
    assert_raise(ArgumentError) { graph.add_data(:points => [[1, 2]], :shape => ['square']) }
  end

  def test_named_symbols_are_reused_and_other_shapes_keep_legacy_behavior
    DataPoint.configure_shape_criteria([/custom/, lambda { |x, y, line|
      ['circle', { 'cx' => x, 'cy' => y, 'r' => 7, 'class' => "dataPoint#{line}" }]
    }])
    graph = SVG::Graph::Plot.new(:point_symbols => {
      :square => :square,
      :star => ['path', { 'd' => 'M0 -3 L3 3 L-3 3 Z' }]
    })
    graph.add_data(:title => 'Series', :points => [[1, 1, nil, 'square'], [2, 2, nil, 'square'],
                                                   [3, 3, nil, 'star'], [4, 4, nil, 'custom']])
    svg = REXML::Document.new(graph.burn_svg_only)
    uses = REXML::XPath.match(svg, "//*[local-name()='use']")
    assert_equal(3, uses.length)
    assert_equal(uses[0].attributes['xlink:href'], uses[1].attributes['xlink:href'])
    assert_not_equal(uses[0].attributes['xlink:href'], uses[2].attributes['xlink:href'])
    assert_equal(2, REXML::XPath.match(svg, "//*[local-name()='defs']/*[local-name()='g']").length)
    assert_equal(1, REXML::XPath.match(svg, "//*[local-name()='circle' and @r='7']").length)
  end

  def test_line_charts_can_reuse_symbols
    graph = SVG::Graph::Line.new(:fields => ['a', 'b'], :point_symbols => { :diamond => :diamond })
    graph.add_data(:title => 'Series', :data => [1, 2], :shape => ['diamond', 'diamond'])
    svg = REXML::Document.new(graph.burn_svg_only)
    assert_equal(2, REXML::XPath.match(svg, "//*[local-name()='use']").length)
  end

  def test_plot

      projection = [
       6, 11,    0, 5,   18, 7,   1, 11,   13, 9,   1, 2,   19, 0,   3, 13,
       7, 9
      ]
      actual = [
       0, 18,    8, 15,    9, 4,   18, 14,   10, 2,   11, 6,  14, 12,
       15, 6,   4, 17,   2, 12
      ]

      graph = SVG::Graph::Plot.new({
        :height => 500,
        :width => 300,
        :key => true,
        :scale_x_integers => true,
        :scale_y_integers => true,
      })

      graph.add_data({
        :data => projection,
        :title => 'Projected',
      })

      graph.add_data({
        :data => actual,
        :title => 'Actual',
      })

      out=graph.burn()
      assert(out=~/Created with SVG::Graph/)
  end

  def test_plot_axis_too_short
    graph = SVG::Graph::Plot.new({
      :height => 500,
      :width => 300,
      :key => true,
      :scale_x_integers => true,
      :scale_y_integers => true,
      :max_x_value => 9,
      :max_y_value => 9,
      :min_x_value => 6,
      :min_y_value => 6,
      :scale_x_divisions => 3,
      :scale_y_divisions => 3
    })

    graph.add_data({
      :data => [5,5,  12,12,  6,6,  9,9,  7,7,  10,10],
      :title => '10',
    })

    out = graph.burn()
    File.write(File.expand_path("plot_#{__method__}.html", @output_folder), out)
  end

  def test_default_plot_emits_polyline_connecting_data_points
    actual = [
      0, 18,    8, 15,    9, 4,   18, 14,   10, 2,   11, 6,  14, 12,
      15, 6,   4, 17,   2, 12
    ]

    graph = SVG::Graph::Plot.new({
      :height => 500,
      :width => 300,
      :key => true,
      :scale_x_integers => true,
      :scale_y_integers => true,
    })

    graph.add_data({
      :data => actual,
      :title => 'Actual',
    })
    out=graph.burn()
    assert_match(/path.*class='line1'/, out)
  end

  def test_disabling_show_lines_does_not_emit_polyline_connecting_data_points
    actual = [
      0, 18,    8, 15,    9, 4,   18, 14,   10, 2,   11, 6,  14, 12,
      15, 6,   4, 17,   2, 12
    ]

    graph = SVG::Graph::Plot.new({
      :height => 500,
      :width => 300,
      :key => true,
      :scale_x_integers => true,
      :scale_y_integers => true,
      :show_lines => false,
    })

    graph.add_data({
      :data => actual,
      :title => 'Actual',
    })

    out=graph.burn()
    assert_no_match(/path class='line1' d='M.* L.*'/, out)
  end

  def test_popup_values_round_to_integer_by_default_in_popups
    actual = [
      0.1, 18,    8.55, 15.1234,    9.09876765, 4,
    ]

    graph = SVG::Graph::Plot.new({
      :height => 500,
      :width => 300,
      :key => true,
      :scale_x_integers => true,
      :scale_y_integers => true,
      :add_popups => true,
      :number_format => "%s"
    })

    graph.add_data({
      :data => actual,
      :title => 'Actual',
    })

    out=graph.burn()
    File.write(File.expand_path("plot_#{__method__}.html", @output_folder), out)
    assert_no_match(/\(0.1, 18\)/, out)
    assert_match(/\(0, 18\)/, out)
    assert_no_match(/\(8.55, 15.1234\)/, out)
    assert_match(/\(9, 15\)/, out) # round up
    assert_no_match(/\(9.09876765, 4\)/, out)
    assert_match(/\(9, 4\)/, out)
  end

  def test_do_not_round_popup_values_shows_decimal_values_in_popups
    actual = [
      0.1, 18,    8.55, 15.1234,    9.09876765, 4,
    ]

    graph = SVG::Graph::Plot.new({
      :height => 500,
      :width => 300,
      :key => true,
      :scale_x_integers => true,
      :scale_y_integers => true,
      :add_popups => true,
      :round_popups => false,
      :number_format => "%s"
    })

    graph.add_data({
      :data => actual,
      :title => 'Actual',
    })

    out=graph.burn()
    File.write(File.expand_path("plot_#{__method__}.html", @output_folder), out)
    assert_match(/\(0.1, 18\)/, out)
    assert_no_match(/\(0, 18\)/, out)
    assert_match(/\(8.55, 15.1234\)/, out)
    assert_no_match(/\(8, 15\)/, out)
    assert_match(/\(9.09876765, 4\)/, out)
    assert_no_match(/\(9, 4\)/, out)
  end

  def test_description_is_shown_in_popups_if_provided
    actual = [
      8.55, 15.1234,    9.09876765, 4,     0.1, 18,
    ]
    description = [
     'first',    'second',          'third',
    ]

    graph = SVG::Graph::Plot.new({
      :height => 500,
      :width => 300,
      :key => true,
      :scale_x_integers => true,
      :scale_y_integers => true,
      :add_popups => true,
      :round_popups => false,
      :number_format => "%s"
    })

    graph.add_data({
      :data => actual,
      :title => 'Actual',
      :description => description,
    })

    out=graph.burn()
    File.write(File.expand_path("plot_#{__method__}.html", @output_folder), out)
    assert_match(/\(8.55, 15.1234, first\)/, out)
    assert_no_match(/\(8.55, 15.1234\)/, out)
    assert_match(/\(9.09876765, 4, second\)/, out)
    assert_no_match(/\(9.09876765, 4\)/, out)
    assert_match(/\(0.1, 18, third\)/, out)
    assert_no_match(/\(0.1, 18\)/, out)
  end

  def test_combine_different_shapes_based_on_description
    actual = [
     8.55, 15.1234,         9.09876765, 4,                  2.1, 18,
    ]
    description = [
     'one is a circle',     'two is a rectangle',           'three is a rectangle with strikethrough',
    ]

    # multiple array of the form
    # [ regex ,
    #   lambda taking three arguments (x,y, line_number for css)
    #     -> return value of the lambda must be an array: [svg tag name,  Hash with keys "points" and "class"]
    # ]
    DataPoint.configure_shape_criteria(
      [/^t.*/, lambda{|x,y,line| ['polygon', {
          "points" => "#{x-1.5},#{y+2.5} #{x+1.5},#{y+2.5} #{x+1.5},#{y-2.5} #{x-1.5},#{y-2.5}",
          "class" => "dataPoint#{line}"
        }]
      }],
      [/^three.*/, lambda{|x,y,line| ['line', {
          "x1" => "#{x-4}",
          "y1" => y.to_s,
          "x2" => "#{x+4}",
          "y2" => y.to_s,
          "class" => "axis"
        }]
      },"OVERLAY"],
    )
    graph = SVG::Graph::Plot.new({
      :height => 500,
      :width => 300,
      :key => true,
      :scale_x_integers => true,
      :scale_y_integers => true,
      :add_popups => true,
      :round_popups => false,
    })

    graph.add_data({
      :data => actual,
      :title => 'Actual',
      :shape => description,
    })

    out=graph.burn()
    File.write(File.expand_path("plot_#{__method__}.html", @output_folder), out)
    assert_match(/polygon.*points/, out)
    assert_match(/line.*axis/, out)
  end

  def test_popup_radius_is_10_by_default
    actual = [
     1, 1,    5, 5,     10, 10,
    ]
    description = [
     'first',    'second',          'third',
    ]

    graph = SVG::Graph::Plot.new({
      :height => 500,
      :width => 300,
      :key => true,
      :scale_x_integers => true,
      :scale_y_integers => true,
      :add_popups => true,
      :round_popups => false,
    })

    graph.add_data({
      :data => actual,
      :title => 'Actual',
      :description => description,
    })

    out=graph.burn()
    assert_match(/circle .*r='10'/, out)
    assert_match(/circle .*onmouseover=.*/, out)

  end

  def test_popup_radius_is_overridable
    actual = [
     1, 1,    5, 5,     10, 10,
    ]
    description = [
     'first',    'second',          'third',
    ]

    graph = SVG::Graph::Plot.new({
      :height => 500,
      :width => 300,
      :key => true,
      :scale_x_integers => true,
      :scale_y_integers => true,
      :add_popups => true,
      :round_popups => false,
      :popup_radius => 1.23
    })

    graph.add_data({
      :data => actual,
      :title => 'Actual',
      :description => description,
    })

    out=graph.burn()
    assert_match(/circle .*r='1.23'/, out)
    assert_match(/circle .*onmouseover=.*/, out)

  end
end
