require 'csv'
require 'google/apis/civicinfo_v2'
require 'erb'


def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5, '0')[0..4]
end

def clean_numbers(numbers)
  digits = numbers.scan(/\d/).join('')

  if digits.length == 10
    formatted_number = "#{digits[0..2]}-#{digits[3..5]}-#{digits[6..9]}"
    return formatted_number
  else
    return "000-000-0000"
  end

end

def day_of_week(time)


end


def legislators_by_zipcode(zip)
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'

  begin
    civic_info.representative_info_by_address(
      address: zip,
      levels: 'country',
      roles: ['legislatorUpperBody', 'legislatorLowerBody']
    ).officials

    rescue
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


puts 'Event Manager Initialized!'

contents = CSV.open(
  'event_attendees.csv',
  headers: true,
  header_converters: :symbol
)

template_letter = File.read('form_letter.erb')
erb_template = ERB.new template_letter

contents.each do |row|
  id = row[0]
  name = row[:first_name]


  zipcode = clean_zipcode(row[:zipcode])

  numbers = clean_numbers(row[:homephone])

  legislators = legislators_by_zipcode(zipcode)
  
  form_letter = erb_template.result(binding)

  # save_thank_you_letter(id,form_letter)

  time = row[:regdate]

  time_object = DateTime.strptime(time, "%m/%d/%y %H:%M")

  hour_of_day = time_object.hour
  day_of_week = time_object.mday
  puts "Signed up on a #{day_of_week} at the #{hour_of_day} hour"

end

