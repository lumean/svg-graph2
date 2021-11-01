# executes all examples
require_relative '../lib/svggraph'
require_relative '../lib/svg_graph/version'
puts SvgGraph::VERSION

list = Dir.glob(File.expand_path("../examples/*.rb", __dir__))
list.delete_if {|x| x.include?("run_all.rb")}

list += Dir.glob(File.expand_path("percy.io_tests/*.rb", __dir__))

# run all examples and stored
USE_FOR_TESTING=true
OUTPUT_FOLDER=File.expand_path('percy.io_staticpages', __dir__)
list.each {|file|
  puts file
  eval(File.read(file), binding, file)
}

