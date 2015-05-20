#!/usr/bin/ruby
require 'json'
require_relative 'OneWire.rb'
wire = OneWire.new :logDir => '/home/pi/'
STDERR.puts wire.read.to_json
wire.writeLog
intro = <<-eos
  <p>The brew is now finished so 28-0004784c24ff (the blue line) is a <a href="http://rover.ebay.com/rover/1/710-53481-19255-0/1?type=4&campid=5335822550&toolid=10001&customid=23257&mpre=http%3A//www.ebay.co.uk/itm/5pcs-DS18B20-Waterproof-Digital-Probe-Temperature-Sensor-Thermometer-Thermal-/281216572924">temperature probe</a> is the room temperature, and 28-00044a7b9fff (the red line) is inside the drinks fridge (which I turn off at off peak times).</p>
  <p>Hesitant to put <a href="http://rover.ebay.com/rover/1/710-53481-19255-0/1?type=4&campid=5335822550&toolid=10001&customid=23257&mpre=http%3A//www.ebay.co.uk/itm/5pcs-DS18B20-Waterproof-Digital-Probe-Temperature-Sensor-Thermometer-Thermal-/281216572924">the probe</a> actually in the beer yet, though it's waterproof, think I need a well or something to keep it sterile.</p>
eos

puts wire.graph intro
