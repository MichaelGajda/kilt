filename = File.expand_path "~/.pivotal_tracker"
File.open(filename, 'w') { |file| file.write "token: #{ARGV.first}" }
puts "Successful installed, execute kilt to start."
