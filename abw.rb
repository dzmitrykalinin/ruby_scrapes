require 'mechanize'
require 'pry'
require 'colorize'

agent = Mechanize.new

page = Nokogiri::HTML(agent.get('http://www.abw.by/index.php', {'set_small_form_1' => "1", 'act' => "public_search", 'do' => "search", 'index' => "1", 'adv_type' => "1", 'adv_group' => "", 'marka[]' => "2", 'model[]' => "", 
				'type_engine' => "2", 'transmission'=> "", 'vol1' => "2200", 'vol2' => "3000", 'year1' => "2002", 'year2' => "2016", 'cost_val1' => "4000", 'cost_val2' => "7000", 'u_country' => "1", 'u_city' => "", 
				'period' => "", 'sort' =>"", 'na_rf' => "", 'type_body' => "", 'privod' => "", 'probeg_col1' => "", 'probeg_col2' => "", 'key_word_a' => "", 'page' => "20"}).content)

cars_num = page.css('div.n700').css('span').text.to_i
puts "Total cars on abw.by:" + " " + cars_num.to_s.yellow

cars = []
links = []
costs = []
(cars_num/20.0).ceil.times do |i|
	page_num = (i + 1) * 20
	page = Nokogiri::HTML(agent.get('http://www.abw.by/index.php', {'set_small_form_1' => "1", 'act' => "public_search", 'do' => "search", 'index' => "1", 'adv_type' => "1", 'adv_group' => "", 'marka[]' => "2", 'model[]' => "", 
				'type_engine' => "2", 'transmission'=> "", 'vol1' => "2200", 'vol2' => "3000", 'year1' => "2002", 'year2' => "2016", 'cost_val1' => "4000", 'cost_val2' => "7000", 'u_country' => "1", 'u_city' => "", 
				'period' => "", 'sort' =>"", 'na_rf' => "", 'type_body' => "", 'privod' => "", 'probeg_col1' => "", 'probeg_col2' => "", 'key_word_a' => "", 'page' => page_num.to_s}).content)

	cars.push(page.css("div.a_m_o").map{ |x| x.css('h3').children.text.split(',').first}).flatten!
	links.push(page.css("div.a_m_o").map{ |x| " http://www.abw.by/#{x.css("a").attr("href").value} "}).flatten!
	costs.push(page.css("div.a_m_o").map{ |x| (x.css('div.cost-usd').text.split('$').first + "$").gsub(/\s+/, "")}).flatten!
end

cars_num.times do |i|
	puts (cars[i].green + links[i] + costs[i].blue)
end

Pry.start(binding)