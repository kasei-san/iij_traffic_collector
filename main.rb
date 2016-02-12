require 'rubygems'
require 'mechanize'
require 'json'
require "slack-notifier"

agent = Mechanize.new
agent.get('https://www.iijmio.jp/auth/login.jsp') do |page|
  page.form_with(action: '/j_security_check') do |form|
    form['j_username'] = ENV['IIJ_ID']
    form['j_password'] = ENV['IIJ_PASS']
    form.click_button
  end
end

now_month = Time.now.month
usage = 0

agent.get('https://www.iijmio.jp/service/setup/hdd/viewdata/execute.do') do |page|
  page.form_with(name: 'lteViewDataForm').click_button.tap do |response|
    response.search('table.base2 tr')[3..-1].each do |tr|
      date, datasize = tr.search('td')[0..1].map(&:inner_text).map(&:strip)
      date = Time.parse(date.split(/[年月日]/).join('/'))
      datasize = datasize.to_i
      usage += datasize if date.month == now_month
    end
  end
end

uri = URI.parse(ENV['MACKEREL_POST_URI'])
Net::HTTP.new(uri.host, uri.port).tap do |http|
  http.use_ssl = true
  Net::HTTP::Post.new(
    uri.request_uri,
    'Content-Type' =>'application/json',
    'X-Api-Key' => ENV['MACKEREL_API_KEY']
  ).tap do |request|
    request.body = [{
      name:  'transfer.usage',
      time:  Time.now.to_i,
      value: usage * 1000 * 1000
    }].to_json
    response = http.request(request)
  end
end

if ENV['WEBHOOK_URL']
  # 5GBプラン固定
  Slack::Notifier.new(ENV['WEBHOOK_URL']).ping("今月の通信量 : #{usage/1000.0}/5GB")
end
