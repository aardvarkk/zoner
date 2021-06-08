require 'faraday'

recordingDurationSecs = ARGV[0].to_i

# Get a session ID
sessionIdResponse = Faraday.get('https://stream.jpbgdigital.com/CJZN/HEAAC/48k/playlist.m3u8')
sessionId = sessionIdResponse.body.scan(/session_id=([\w-]+)/)
