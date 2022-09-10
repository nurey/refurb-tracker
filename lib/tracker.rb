# frozen_string_literal: true

class Tracker
  USER_AGENT = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 12_5_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/105.0.0.0 Safari/537.36'
  REFURB_URL = 'https://www.apple.com/ca/shop/refurbished/iphone'
  THRESHOLD_PRICE = 700

  def initialize(logger:)
    @browser = Ferrum::Browser.new
    @browser.headers.set('User-Agent' => USER_AGENT)
    @logger = logger
    @notifier = -> {} # init as a NullObject proc in case notifier isn't injected
  end

  def notify(&block)
    @notifier = block
  end

  def run
    @browser.go_to(REFURB_URL)
    @logger.info("Browser received status #{@browser.network.status}")
    prices = @browser.css('.as-price-currentprice')
      .map { |node| node.text.strip.gsub(/[$,]/, '').to_i }

    @logger.info("Parsed prices: #{prices}")

    low_prices = prices.select { |price| price < THRESHOLD_PRICE }

    @notifier.call("Found items below $#{THRESHOLD_PRICE}", REFURB_URL) if low_prices.any?

    @browser.reset
  end
end
