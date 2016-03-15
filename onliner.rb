require 'mechanize'
require 'pry'
require 'colorize'

agent = Mechanize.new;

page = JSON.parse(agent.post('http://ab.onliner.by/search', {'currency' => "USD", 'sort[]' => "last_time_up", 'car[0][5]' => "", 
																	'min-price' => "4000", 'max-price' => "7000", 'body_type[]' => "1", 'min-year' => "2002", 
																	'fuel[]' => "1", 'min-capacity' => "2.2", 'max-capacity' => "3", 'drivetrain[]' => "2"}).body)

cars_num = page['result']['counters']['total']
puts "Total cars on onliner.by:" + " " + cars_num.to_s.yellow

cars = []
links = []
costs = []
(cars_num/50.0).ceil.times do |page_num|

	page = JSON.parse(agent.post('http://ab.onliner.by/search', {'currency' => "USD", 'sort[]' => "last_time_up", 'page' => (page_num + 1).to_s, 'car[0][5]' => "", 
																	'min-price' => "4000", 'max-price' => "7000", 'body_type[]' => "1", 'min-year' => "2002", 
																	'fuel[]' => "1", 'min-capacity' => "2.2", 'max-capacity' => "3", 'drivetrain[]' => "2"}).body)
	
	cars.push(page['result']['advertisements'].map{|i| i.last["title"]}).flatten!
	links.push(page['result']['advertisements'].map{|i| " http://ab.onliner.by/car/#{i.last["id"]} "}).flatten!
	costs.push(Nokogiri::HTML(page['result']['content']).css('tr.carRow').map{|x| x.css('p.small').children.first.text.to_i.to_s}).flatten!
end

cars.count.times do |i|
	puts (cars[i].green + links[i] + costs[i].blue + "$".blue)
end

Pry.start(binding)