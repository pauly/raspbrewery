#!/usr/bin/ruby

dir = File.expand_path( File.dirname( __FILE__ ))
executable = dir + '/temperature.rb'
crontab = `crontab -l`.split( /\n/ ) || [ ]
crontab = crontab.reject do | line |
  line =~ /#{dir}/
end
crontab << '# new crontab added for ' + dir
default = '/var/www/index.html'
puts "Where to write graph? Default #{default} (ok to just hit enter)"
outFile = STDIN.gets.chomp.to_s
outFile = default if outFile.empty?
default = outFile.gsub 'html', 'json'
if default === outFile
  default = '/tmp/temperature.err'
end
puts "here to simple data output? Default #{default} (ok to just hit enter)"
errFile = STDIN.gets.chomp.to_s
errFile = default if errFile.empty?
crontab << "*/5 * * * * #{executable} > #{outFile} 2> #{errFile}"
File.open( '/tmp/cron.tab', 'w' ) do | handle |
  handle.write crontab.join( "\n" ) + "\n"
end
puts `crontab /tmp/cron.tab`
puts 'Success!'
