require 'test/unit'
require_relative '../lib/SVG/Graph/Histogram'

class TestHistogram < Test::Unit::TestCase
  class CapturingHistogram < SVG::Graph::Histogram
    attr_reader :rendered_series, :rendered_fields

    protected

    def draw_data
      @rendered_series = @data.map { |series| series[:data].dup }
      @rendered_fields = @config[:fields].dup
      super
    end
  end

  def test_shared_bins_include_boundaries_and_last_maximum
    graph = CapturingHistogram.new(:bin_count => 2, :key => false)
    graph.add_data(:data => [0, 1, 2, 4], :title => 'A')
    graph.add_data(:data => [0, 2, 4], :title => 'B')
    svg = graph.burn
    assert_equal([[2, 2], [1, 2]], graph.rendered_series)
    assert_equal(['0.00 - 2.00', '2.00 - 4.00'], graph.rendered_fields)
    assert_match(/class='fill1'/, svg)
    assert_match(/class='fill2'/, svg)
    assert_equal([[0, 1, 2, 4], [0, 2, 4]], graph.instance_variable_get(:@data).map { |d| d[:data] })
  end

  def test_equal_values_and_repeated_rendering
    graph = CapturingHistogram.new(:key => false, :bin_count => 2)
    graph.add_data(:data => [5, 5])
    graph.burn
    assert_equal([[0, 2]], graph.rendered_series)
    graph.add_data(:data => [6])
    graph.burn
    assert_equal([[2, 0], [0, 1]], graph.rendered_series)
  end

  def test_decimal_boundary_goes_into_following_bin
    graph = CapturingHistogram.new(:key => false, :bin_count => 10)
    graph.add_data(:data => [0.0, 0.3, 1.0])
    graph.burn
    assert_equal(1, graph.rendered_series.first[3])
    assert_equal(0, graph.rendered_series.first[2])
    assert_equal(1, graph.rendered_series.first[9])
  end

  def test_rejects_bad_samples_and_bin_counts
    graph = CapturingHistogram.new(:key => false)
    [[], [nil], [Float::INFINITY], [Complex(1, 2)], ['1']].each do |data|
      assert_raise(ArgumentError) { graph.add_data(:data => data) }
    end
    graph.add_data(:data => [1])
    graph.bin_count = 0
    assert_raise(ArgumentError) { graph.burn }
  end
end
