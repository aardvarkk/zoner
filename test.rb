require './get_urls'

TEST_FAILURE = "Test failure!"

urls = get_urls(File.read('test_files/playlist.m3u8'))
# puts urls
raise TEST_FAILURE unless urls.size == 8

urls = get_urls(File.read('test_files/ad_butler.m3u8'))
# puts urls
raise TEST_FAILURE unless urls.size == 3

puts "Test success!"
