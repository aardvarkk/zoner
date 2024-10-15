require './stations'

def get_urls(body, station)
  case station
  when CJZN_FM
    body.scan(/\/\/([\w\/.]+CJZN-[\w-]+\.aac)/).flatten.map { "http://#{_1}" }
  when CFUV_FM
    body.lines.filter { |s| s.include? 'cdnstream' }.map(&:strip)
  end
end
