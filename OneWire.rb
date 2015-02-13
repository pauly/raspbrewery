# @todo put this in a gem

class OneWire

  @deviceRoot = nil
  @logFile = nil
  @maxLogEntries = nil

  def initialize options = { }
    @deviceRoot = '/sys/bus/w1/devices/'
    if options[ :deviceRoot ]
      @deviceRoot = options[ :deviceRoot ]
    end
    @logFile = '/tmp/temperature.log'
    if options[ :logDir ]
      @logFile = options[ :logDir ] + '/temperature.log'
    end
    @maxLogEntries = 1000
    if options[ :maxLogEntries ]
      @maxLogEntries = options[ :maxLogEntries ]
    end
  end

  def read
    data = { }
    Dir[ @deviceRoot + '*-*' ].each_with_index do | path, i |
      id = path.sub @deviceRoot, ''
      file_contents = File.read( path + '/w1_slave' )
      data[ id ] = file_contents.split( 't=' ).last.to_f / 1000
    end
    data
  end

  def writeLog
    logEntry = [ Time.now.to_i ]
    self.read.each do | reading |
      logEntry.push reading.last # the temperature
    end
    open( @logFile, 'a' ) do | f |
      f.puts logEntry.join( "\t" )
    end
  end

  def readLog
    header = [ 'time' ]
    data = [ ]
    self.read.each { | reading |
      header.push reading.first # the id
    }
    open( @logFile, 'r' ) do | f |
      f.each_line do | line |
	data.push line.strip.split( "\t" )
      end
    end
    data = data[ @maxLogEntries * -1, @maxLogEntries ]
    data.unshift header
    data
  end

  def graph intro = ''
    data = self.readLog
    data = data.inspect.to_s.gsub /"([\d.]+)"/, '\1'
    data = data.gsub /\[([\d]+)/, '[d(\1)'
    html = <<-eos
      <div id="curveChart" style="width: 800px; height: 600px"></div>
      #{intro}
      <script type="text/javascript" src="https://www.google.com/jsapi?autoload={ 'modules':[{ 'name':'visualization', 'version':'1', 'packages':['corechart'] }] }"></script>
      <script type="text/javascript">
	var drawChart = function ( ) {
	  var d = function ( t ) {
	    return new Date( t * 1000 );
	  };
	  var data = google.visualization.arrayToDataTable( #{data} );
	  var options = {
	    title: 'Beer temperatures',
	    curveType: 'function',
	    legend: { position: 'bottom' }
	  };
	  var chart = new google.visualization.LineChart( document.getElementById( 'curveChart' ));
	  chart.draw( data, options );
	};
	google.setOnLoadCallback( drawChart );
      </script>
    eos
    html.strip.gsub /[\n\r\s]+/, ' '
  end

end
