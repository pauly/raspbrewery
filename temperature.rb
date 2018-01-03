#!/usr/bin/ruby
require 'json'
require_relative 'OneWire.rb'
wire = OneWire.new :logDir => '/home/pi/', :maxLogEntries => 1000
STDERR.puts wire.read.to_json
wire.writeLog
intro = <<-eos
  <p>Woodford Old Nog didn't work, went down the sink! <a href="http://rover.ebay.com/rover/1/710-53481-19255-0/1?type=4&campid=5335822550&toolid=10001&customid=23257&mpre=http%3A//www.ebay.co.uk/itm/5pcs-DS18B20-Waterproof-Digital-Probe-Temperature-Sensor-Thermometer-Thermal-/281216572924">temperature probe</a> is back outside the bedroom window. Sure the <a href="http://rover.ebay.com/rover/1/710-53481-19255-0/1?type=4&campid=5335822550&toolid=10001&customid=23786&mpre=http%3A//www.ebay.co.uk/itm/Aquarium-Tropical-Marine-Fish-Tank-Submersible-Adjustable-Temp-Water-Heater-/400582226471%3Fvar%3D%26hash%3Ditem5d448fb227:m:mzLZPdOQp_NOq2NAxHXIHOA">aquarium heater</a> is broken now.</p>
eos

puts wire.graph intro
