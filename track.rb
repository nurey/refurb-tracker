# frozen_string_literal: true

require 'ferrum'

USER_AGENT = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 12_5_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/105.0.0.0 Safari/537.36'
REFURB_URL = 'https://www.apple.com/ca/shop/refurbished/iphone'
THRESHOLD_PRICE = 700

browser = Ferrum::Browser.new
browser.headers.set('User-Agent' => USER_AGENT)
browser.go_to(REFURB_URL)
low_prices = browser.css('.as-price-currentprice')
  .map { |node| node.text.strip.gsub(/[$,]/, '').to_i }
  .select { |price| price < THRESHOLD_PRICE }

puts low_prices
