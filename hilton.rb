require 'mechanize'
require 'pry'

LINES_FOR_JOB = 27
JOBS_PER_PAGE = 5

def transform_page(page)
	page = page.split('!|!')
	page.delete_if{|str| str == "false" || str == "true" || str == "" || str == "?" || str == ""}
	page.slice!(0, 2)
	return page
end

def check_last_page(page_num, all_pages, jobs_num)
	last_page_jobs = (jobs_num % JOBS_PER_PAGE).to_i
	if page_num == all_pages - 1 && last_page_jobs != 0
		return last_page_jobs
	else
		return JOBS_PER_PAGE
	end
end

def create_hash(description_page, string_jobs, job_lines)
	
	location = string_jobs[11 + job_lines].split('-').slice(0, 3)
	four_desc_chars = string_jobs[13 + job_lines][0..3]
	if four_desc_chars =~ /[A-Z][A-Z][A-Z][0-9]/
		description = description_page.at('input#initialHistory')['value'].split('!|!')[24..25].join
	end
	url = string_jobs[25 + job_lines]
	title = string_jobs[1 + job_lines]
	job_reference = string_jobs[0 + job_lines]
	return Hash[ 
							title: title, 
							country: location.first, 
							state: location[1], 
							city: location.last, 
							url: url, 
							job_reference: job_reference, 
							description: description
						]
end

def process_array(label,jobs,xml)
 	jobs.each do |hash|
    xml.send(label) do
    	hash.each do |key,value|
     		if value.is_a?(Array)
         	process_array(key,value,xml)
 		    else
     			xml.send(key,value)
     		end
   		end
   	end
  end
end

agent = Mechanize.new

hilton_url = 'https://hilton.taleo.net/careersection/hww_external/joblist.ajax'
http_data = {"ftlpageid" => "reqListAllJobsPage", "ftlinterfaceid" => "requisitionListInterface", "ftlcompid" => "validateTimeZoneId", "jsfCmdId" => "validateTimeZoneId", 
							"ftlcompclass" => "InitTimeZoneAction", "tz" => "GMT%2b03:00", "lang" => "en", "radiusSiteListPagerId.nbDisplayPage" => "5",  "rlPager.currentPage" => "1", 
							"listRequisition.size" => "5","rlPager.nbDisplayPage" => "5", "languageSelect" => "en", "dropListSize" => JOBS_PER_PAGE.to_s, "dropSortBy" => "0"}

page = agent.post(hilton_url, http_data).content
string_jobs = transform_page(page)

jobs_num = string_jobs[string_jobs.index("listRequisition.nbElements") + 1].to_f
all_pages = (jobs_num / JOBS_PER_PAGE).ceil
jobs = []

all_pages.times do |page_num|
	http_data["rlPager.currentPage"] = (page_num + 1).to_s
	page = agent.post(hilton_url, http_data).content
	string_jobs = transform_page(page)
	
	jobs_per_page = check_last_page(page_num, all_pages, jobs_num)

	jobs_per_page.times do |i|
		job_lines = LINES_FOR_JOB * i

		description_page = agent.get('https://hilton.taleo.net/careersection/jobdetail.ftl', {"job" => string_jobs[13 + job_lines], "lang"=>"en"})
		
		jobs << create_hash(description_page, string_jobs, job_lines)
	end
end

builder = Nokogiri::XML::Builder.new do |xml|
  xml.jobs do
    process_array('vacancy',jobs,xml)
  end
end

file = File.open("hilton_jobs.xml", "w")
	file.write(CGI.unescapeHTML(CGI.unescape(builder.to_xml).force_encoding('UTF-8').tr('\\', '')))
file.close