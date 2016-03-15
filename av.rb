require 'mechanize'
require 'pry'
require 'colorize'

agent = Mechanize.new

page = Nokogiri::HTML(agent.get('http://av.by/public/search.php', {'name_form' => "search_form", 'event' => "Search", 'country_id' => "1", 'body_type_id' => "5", 'class_id' => "0", 'engine_type_all' => "0", 
								'volume_value' => "2200", 'volume_value_max' => "3000", 'cylinders_number' => "0", 'run_value' => "", 'run_value_max' => "", 'run_unit' => "-1", 'transmission_id' => "0", 
								'year_id' => "2002", 'year_id_max' => "0", 'price_value' => "4000", 'price_value_max' => "7000", 'currency_id' => "USD", 'door_id' => "", 'region_id' => "0", 'city_id' => "Array", 
								'public_pass_rf' => "0", 'public_new' => "0", 'public_exchange' => "0", 'public_image' => "0", 'public_show_id' => "0", 'order_id' => "0", 'engine_type_id_search[]' => "1", 
								'privod_id[]' => "2", 'category_parent[0]' => "8", 'category_id[0]' => "0", 'page' => "1"}).content)

cars_num = page.css('h1.b-header-title').text.split(" ")[1].to_i
puts "Total cars on av.by:" + " " + cars_num.to_s.yellow

cars = []
links = []
costs = []
(cars_num/20.0).ceil.times do |page_num|
	page = Nokogiri::HTML(agent.get('http://av.by/public/search.php', {'name_form' => "search_form", 'event' => "Search", 'country_id' => "1", 'body_type_id' => "5", 'class_id' => "0", 'engine_type_all' => "0", 
								'volume_value' => "2200", 'volume_value_max' => "3000", 'cylinders_number' => "0", 'run_value' => "", 'run_value_max' => "", 'run_unit' => "-1", 'transmission_id' => "0", 
								'year_id' => "2002", 'year_id_max' => "0", 'price_value' => "4000", 'price_value_max' => "7000", 'currency_id' => "USD", 'door_id' => "", 'region_id' => "0", 'city_id' => "Array", 
								'public_pass_rf' => "0", 'public_new' => "0", 'public_exchange' => "0", 'public_image' => "0", 'public_show_id' => "0", 'order_id' => "0", 'engine_type_id_search[]' => "1", 
								'privod_id[]' => "2", 'category_parent[0]' => "8", 'category_id[0]' => "0", 'page' => (page_num + 1).to_s}).content)

	cars_on_page = page.css('div.b-listing-item')
	
	cars.push(cars_on_page.map { |x| x.css("div.b-listing-item-main").css("a").text.split(' ').join(' ')}).flatten!
	links.push(cars_on_page.map{ |x| " http://av.by/public/#{x.css("div.b-listing-item-image").css("a").attr("href").value}	"}).flatten!
	costs.push(cars_on_page.map{ |x| x.css('strong').text}).flatten!
end

cars_num.times do |i|
	puts (cars[i].green + links[i] + costs[i].blue)
end

Pry.start(binding)