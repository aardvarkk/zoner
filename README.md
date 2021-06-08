# Zoner

This is a tool to record a streaming radio broadcast. There's a daily mixtape I like but I'm not always around when it's airing so I wanted to get a copy of it.

I peeked at the requests being made when listening in the browser and wrote this script to automate the process of downloading the stream segments (they're comprised of 12-second AAC-encoded files, for some reason) and assembling them into a single AAC file. I've hooked it up to a cron job so it will automatically record the segment at the appropriate time each day.

Feel free to try tweaking it to point at some other radio stream if you'd like!

## Example

`ruby zoner.rb 1800 # Records the stream for 1800 seconds (30 minutes)`

## Dependencies

* Ruby
* faraday
* ffmpeg
