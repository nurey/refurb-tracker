# frozen_string_literal: true

class Tracker
  USER_AGENT = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 12_5_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/105.0.0.0 Safari/537.36'
  REFURB_URL = 'https://www.apple.com/ca/shop/refurbished/iphone'
  THRESHOLD_PRICE = 700

  def initialize(logger:)
    @browser = _init_browser
    @logger = logger
    @notifier = -> {} # init as a NullObject proc in case notifier isn't injected
  end

  def notify(&block)
    @notifier = block
  end

  def run
    @browser.go_to(REFURB_URL)
    @logger.info("Browser received status #{@browser.network.status}")
    return _handle_network_error if @browser.network.status != 200

    prices = @browser.css('.as-price-currentprice')
      .map { |node| node.text.strip.gsub(/[$,]/, '').to_i }

    @logger.info("Parsed prices: #{prices}")

    low_prices = prices.select { |price| price < THRESHOLD_PRICE }

    @notifier.call("Found items below $#{THRESHOLD_PRICE}", REFURB_URL) if low_prices.any?

    @browser.reset
  end

  private

  def _init_browser
    Ferrum::Browser.new.tap do |b|
      b.headers.set('User-Agent' => USER_AGENT)
    end
  end

  def _handle_network_error
    @browser.screenshot(path: 'browser_screenshot.png')

    @browser.quit

    @browser = _init_browser
  end
end
