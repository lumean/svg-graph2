# executes all examples

require File.expand_path("#{__FILE__}/../../lib/svggraph.rb")

puts SVG::Graph::VERSION

list = Dir.glob(File.expand_path("*.rb", __dir__))
list.delete File.expand_path(__FILE__)

list.each {|file|
  eval(File.read(file), binding, file)
}

