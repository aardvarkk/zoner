require './get_urls'

TEST_FAILURE = "Test failure!"

urls = get_urls(File.read('test_files/playlist.m3u8'))
puts urls
raise TEST_FAILURE unless urls.size == 8

puts "Test success!"
