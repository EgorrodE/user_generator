require "test/unit"
Dir[File.expand_path('./../../generators/*.rb', __FILE__)].each { |f|
 require(f) unless f.include? "ts_gen"}
