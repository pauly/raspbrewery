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
    @maxLogEntries = 400
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
    if logEntry.length > 1
      open( @logFile, 'a' ) do | f |
        f.puts logEntry.join( "\t" )
      end
    end
  end

  def readLog decimalPlaces=1
    header = [ 'time' ]
    data = [ ]
    self.read.each { | reading |
      header.push reading.first # the id
    }
    open( @logFile, 'r' ) do | f |
      previousLine = [ ]
      f.each_line do | line |
        row = line.strip.split( "\t" )
        ok = false
      	header.each_with_index do | column, i |
	  if i > 0
            row[i] = row[i].to_f.round(decimalPlaces)
            row[i] = nil if row[i].zero?
            ok = true if previousLine[i] != row[i]
          end
        end
	# puts row.to_s + ' looks same as ' + previousLine.to_s unless ok
        if ok
          previousLine = row
          data.push row
        end
      end
    end
    if data.length > @maxLogEntries
      data = data[ @maxLogEntries * -1, @maxLogEntries ]
    end
    firstTime = nil
    data.each_with_index do |row, i|
      if firstTime == nil
        firstTime = row.first.to_i
      else
        data[i][0] = row.first.to_i - firstTime
      end
    end
    data.unshift header
    data
  end

  def graph intro = ''
    data = self.readLog
    data = data.inspect.to_s.gsub /"([\d.]+)"/, '\1'
    data = data.gsub /\[([\d]+)/, '[d(\1)'
    html = <<-eos
      <div id="curveChart" style="width: 800px; height: 800px"></div>
      #{intro}
      <script type="text/javascript" src="https://www.google.com/jsapi?autoload={ 'modules':[{ 'name':'visualization', 'version':'1', 'packages':['corechart'] }] }"></script>
      <script type="text/javascript">
        var drawChart = function() {
          var first = null;
          var d = function(t) {
            if (first === null) first = t;
            if (t < first) t += first;
            return new Date(t * 1000);
          };
	  var nil = null;
          var data = google.visualization.arrayToDataTable(#{data});
          var options = {
            title: 'Temperatures',
            curveType: 'function',
            legend: { position: 'bottom' }
          };
          var chart = new google.visualization.LineChart(document.getElementById('curveChart'));
          chart.draw(data, options);
        };
        google.setOnLoadCallback(drawChart);
      </script>
    eos
    html.strip.gsub /[\n\r\s]+/, ' '
  end

end
