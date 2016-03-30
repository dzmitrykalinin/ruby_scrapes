#title+
#url+
#description
#job reference
#location => Country, State, City+
#если это не US => Country, City
#output => XML

require 'mechanize'
require 'pry'

LINES_FOR_JOB = 27
agent = Mechanize.new

page = agent.post('https://hilton.taleo.net/careersection/hww_external/joblist.ajax', 
						{"ftlpageid" => "reqListAllJobsPage", "ftlinterfaceid" => "requisitionListInterface", "ftlcompid" => "validateTimeZoneId", "jsfCmdId" => "validateTimeZoneId", "ftlcompclass" => "InitTimeZoneAction", 
							"tz" => "GMT%2b03:00", "lang" => "en", "radiusSiteListPagerId.nbDisplayPage" => "5",  "rlPager.currentPage" => "1", "listRequisition.size" => "100","rlPager.nbDisplayPage" => "5", "languageSelect" => "en", 
							"dropListSize" => "100", "dropSortBy" => "0"}).content

page = page.split('!|!')
page.delete_if{|str| str == "false" || str == "true" || str == "" || str == "?" || str == ""}
page.delete_at(0)
page.delete_at(0)
jobs_per_page = page[page.index("listRequisition.size") + 1].to_i
jobs_num = page[page.index("listRequisition.nbElements") + 1].to_i

need_lines = LINES_FOR_JOB * jobs_per_page
page.slice!(need_lines, page.count - need_lines)
jobs = Array.new
(jobs_num/jobs_per_page).ceil.times do |page_num|
	page = agent.post('https://hilton.taleo.net/careersection/hww_external/joblist.ajax', 
						{"ftlpageid" => "reqListAllJobsPage", "ftlinterfaceid" => "requisitionListInterface", "ftlcompid" => "validateTimeZoneId", "jsfCmdId" => "validateTimeZoneId", "ftlcompclass" => "InitTimeZoneAction", 
							"tz" => "GMT%2b03:00", "lang" => "en", "radiusSiteListPagerId.nbDisplayPage" => "5",  "rlPager.currentPage" => (page_num + 1).to_s, "listRequisition.size" => "100","rlPager.nbDisplayPage" => "5", "languageSelect" => "en", 
							"dropListSize" => "100", "dropSortBy" => "0"}).content
	page = page.split('!|!')
	page.delete_if{|str| str == "false" || str == "true" || str == "" || str == "?" || str == ""}
	page.delete_at(0)
	page.delete_at(0)
	#page.slice!(need_lines, page.count - need_lines)
	jobs_per_page.times do |i|
		jobs << (Hash[ "title" => page[1 + LINES_FOR_JOB * i], "details" => [{ "location" => page[11 + LINES_FOR_JOB * i], "url" => page[25 + LINES_FOR_JOB * i], "job_reference" => page[10 + LINES_FOR_JOB * i], "description" => page[9 + LINES_FOR_JOB * i] + ", " + page[12 + LINES_FOR_JOB * i]}]])
	end
end

def process_array(label,jobs,xml)
  jobs.each do |hash|
    xml.send(label) do                 # Create an element named for the label
      hash.each do |key,value|
        if value.is_a?(Array)
          process_array(key,value,xml) # Recurse
        else
          xml.send(key,value)          # Create <key>value</key> (using variables)
        end
      end
    end
  end
end

builder = Nokogiri::XML::Builder.new do |xml|
  xml.root do                           # Wrap everything in one element.
    process_array('vacansy',jobs,xml)  # Start the recursion with a custom name.
  end
end

file = File.open("helton_jobs_xml.txt", "w")
	file.write(builder.to_xml)
file.close
Pry.start(binding) 