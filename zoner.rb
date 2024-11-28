# https://en.wikipedia.org/wiki/M3U

require 'faraday'
require './get_urls'
require './stations'

# Stations are defined in get_urls.rb
STATION = CFUV_FM

<<-sh
ruby zoner.rb 1800
sh

recordingDurationSecs = ARGV[0].to_i
targetDuration = nil

def to_format(time)
  return time.utc.strftime('%Y%m%dT%H%M%SZ')
end

# Get a URL including session ID
sessionIdResponse = Faraday.get(STATION)
sessionIdUrl = sessionIdResponse.body.lines.last
puts sessionIdUrl

# Determine recording duration
startTime = Time.now
endTime   = startTime + recordingDurationSecs
puts "Recording from #{to_format(startTime)} to #{to_format(endTime)}"

# Make a directory to store the temporary files
dateStr = Date.today.iso8601
dirName = dateStr
Dir.mkdir(dirName)

filenames = []

# Keep going until we've recorded enough
while Time.now <= endTime
  # Get the block info
  blockResponse = Faraday.get(sessionIdUrl)
  puts blockResponse.body

  # Get target duration
  targetDuration = blockResponse.body.scan(/TARGETDURATION:(\d+)/).flatten.first.to_i
  puts "Target Duration: #{targetDuration}"

  # Get the relevant URLs
  urls = get_urls(blockResponse.body, STATION)
  puts "Found URLS: #{urls}"

  # Walk through URLs and save ones we don't have
  urls.each do |url|
    basename = File.basename(url)
    puts basename

    filename = File.join(dirName, basename)
    if File.exist?(filename)
      puts "Already have #{filename}, skipping"
    else
      puts "Getting #{filename}"

      File.write(filename, Faraday.get(url).body)
      filenames << filename
    end
  end

  # Wait the target duration to check for a new file
  # Go to sleep for a fraction of target duration so we don't miss segments if phase is off
  sleep targetDuration/4
end

puts "Done recording!"

# Make a filelist.txt containing all the files
# For each filename, add a line in filelist.txt with `file 'filename'`
File.open('filelist.txt', 'w') do |f|
  filenames.each do |filename|
    f.puts("file '#{filename}'")
  end
end

outputFile = "#{File.join('output', dateStr)}.m4a"
cmd = %{ffmpeg -f concat -i filelist.txt -c copy #{outputFile}}
system(cmd)

# Remove the temorary directory with all of its files
cmd = %{rm -rf #{dirName}}
system(cmd)

puts "Done assembly and cleanup!"
