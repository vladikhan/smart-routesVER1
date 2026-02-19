
# Find the routes creation section and replace venue.city with venue.district.city

# Read the file
content = File.read('db/seeds.rb')

# Fix venue.city references
content.gsub!(/venue\.city(?!\.)/, 'venue.district.city')
content.gsub!(/venues\.sample\.city/, 'venues.sample.district.city')

# Write back
File.write('db/seeds.rb', content)

