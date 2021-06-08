# https://en.wikipedia.org/wiki/M3U

require 'faraday'

<<-sh
ruby zoner.rb 1800
sh

recordingDurationSecs = ARGV[0].to_i
targetDuration = nil

def toFormat(time)
  return time.utc.strftime('%Y%m%dT%H%M%SZ')
end

def getUrls(body)
  return body.scan(/^(.*Z\.aac)$/).flatten
end

# Get a URL including session ID
sessionIdResponse = Faraday.get('https://stream.jpbgdigital.com/CJZN/HEAAC/48k/playlist.m3u8')
sessionIdUrl = sessionIdResponse.body.lines.last
puts sessionIdUrl

# Determine recording duration
startTime = Time.now
endTime   = startTime + recordingDurationSecs
puts "Recording from #{toFormat(startTime)} to #{toFormat(endTime)}"

# Make a directory to store the files
dirName = toFormat(startTime)
Dir.mkdir(dirName)

# Keep going until we've recorded enough
while Time.now <= endTime
  # Get the block info
  blockResponse = Faraday.get(sessionIdUrl)

  # Get target duration
  targetDuration = blockResponse.body.scan(/TARGETDURATION:(\d+)/).flatten.first.to_i
  puts "Target Duration: #{targetDuration}"

  # Get the relevant URLs
  urls = getUrls(blockResponse.body)
  puts urls

  # Walk through URLs and save ones we don't have
  urls.each do |url|
    basename = url.scan(/CJZN-\w+\.aac/)
    puts basename

    filename = File.join(dirName, basename)
    if File.exist?(filename)
      puts "Already have #{filename}, skipping"
    else
      puts "Getting #{filename}"

      File.write(filename, Faraday.get(url).body)
    end
  end

  # Wait the target duration to check for a new file
  sleep targetDuration
end

puts "Done recording!"

# Assemble everything into a single file
filenames = Dir.glob(File.join(dirName, '*.aac'))
outputFile = File.join(dirName, 'output.aac')
cmd = %{ffmpeg -i "concat:#{filenames.join('|')}" -c copy #{outputFile}}
system(cmd)

# Delete the parts that made up the whole
filenames.each { |f| File.delete(f) }

puts "Done assembly and cleanup!"
