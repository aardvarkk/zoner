require './get_urls'
require './stations'

TEST_FAILURE = "Test failure!"

urls = get_urls(File.read('test_files/playlist.m3u8'), CJZN_FM)
# puts urls
raise TEST_FAILURE unless urls.size == 8

urls = get_urls(File.read('test_files/ad_butler.m3u8'), CJZN_FM)
# puts urls
raise TEST_FAILURE unless urls.size == 3

urls = get_urls(File.read('test_files/cfuv.m3u8'), CFUV_FM)
# puts urls
raise TEST_FAILURE unless urls.size == 1

puts "Test success!"
