def get_urls(body)
  return body.scan(/\/\/([\w\/.]+CJZN-[\w-]+\.aac)/).flatten.map { "http://#{_1}" }
end
