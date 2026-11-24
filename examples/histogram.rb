g = SVG::Graph::Histogram.new(
  :width => 640,
  :height => 400,
  :graph_title => 'Measurements',
  :show_graph_title => true,
  :bin_count => 4,
  :key => true
)
g.add_data(:data => [1, 2, 2, 3, 5, 6, 8, 9], :title => 'First')
g.add_data(:data => [1, 3, 4, 4, 7, 8, 9], :title => 'Second')

output_filename = File.basename(__FILE__, '.rb')
if defined?(USE_FOR_TESTING)
  File.open(File.join(OUTPUT_FOLDER, "#{output_filename}.html"), 'w') { |f| f.write(g.burn) }
else
  File.open(File.expand_path("#{output_filename}.svg", __dir__), 'w') { |f| f.write(g.burn_svg_only) }
end
