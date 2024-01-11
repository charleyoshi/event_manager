require 'csv'
require 'google/apis/civicinfo_v2'
require 'erb'
require 'time'

# Cleaning zipcode
def clean_zipcode(zipcode)
  # if the zip code is more than five digits, truncate it to the first five digits
  # if the zip code is less than five digits, add zeros to the front until it becomes five digits
  zipcode.to_s.rjust(5, '0')[...5]
end

# Accepts a single zip code as a parameter and returns a comma-separated string of legislator names
def legislators_by_zipcode(zip)
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'

  begin
    legislators = civic_info.representative_info_by_address(
      address: zip,
      levels: 'country',
      roles: %w[legislatorUpperBody legislatorLowerBody]
    ).officials
  rescue StandardError
    'You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials'
  end
end

def save_thank_you_letter(id, form_letter)
  Dir.mkdir('output') unless Dir.exist?('output')

  filename = "output/thanks_#{id}.html"

  File.open(filename, 'w') do |file|
    file.puts form_letter
  end
end

def clean_phone_number(phone_number)
  # If number is valid, return number.
  # If number is not valid, return message.
  phone_number.delete!('^0-9')
  if !phone_number.nil? && (phone_number.length == 10 || (phone_number.length == 11 && phone_number[0] == '1'))
    phone_number.chars.last(10).join
  else
    'Get more mobile alerts on our website!'
  end
end

puts 'Event Manager Initialized!'

unless File.exist? 'event_attendees.csv'
  puts "File doesn't exist."
  exit
end

# Load template
template_letter = File.read('form_letter.erb')
erb_template = ERB.new template_letter

contents = CSV.open('event_attendees.csv', headers: true, header_converters: :symbol)

reg_hours = []
wdays = []

contents.each do |row|
  id = row[0]
  name = row[:first_name]
  zipcode = clean_zipcode row[:zipcode]
  legislators = legislators_by_zipcode(zipcode)

  phone_number = clean_phone_number(row[:homephone])
  # puts "#{row[:homephone]}, #{phone_number}" # continue: 11 digits not correct yet

  reg_hour = Time.strptime(row[:regdate], '%m/%d/%y %H:%M').strftime('%k')
  reg_hours << reg_hour

  wday = Time.strptime(row[:regdate], '%m/%d/%y %H:%M').strftime('%A')
  wdays << wday

  form_letter = erb_template.result(binding)
  save_thank_you_letter(id, form_letter)
end

# Peak registration hours
p reg_hours.tally.sort_by { |_k, v| -v }.to_h

# Most registered weekdays
p wdays.tally.sort_by { |_k, v| -v }.to_h
