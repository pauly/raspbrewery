#!/usr/bin/ruby

dir = File.expand_path( File.dirname( __FILE__ ))
executable = dir + '/temperature.rb'
crontab = `crontab -l`.split( /\n/ ) || [ ]
crontab = crontab.reject do | line |
  line =~ /#{dir}/
end
crontab << '# new crontab added for ' + dir
puts 'Where to write graph? Default /var/www/index.html'
outFile = STDIN.gets.chomp.to_s
outFile = '/var/www/index.html' if outFile.empty?
crontab << "*/5 * * * * #{executable} > #{outFile} 2> /tmp/temperature.err"
File.open( '/tmp/cron.tab', 'w' ) do | handle |
  handle.write crontab.join( "\n" ) + "\n"
end
puts `crontab /tmp/cron.tab`
puts 'Success!'
