# encoding:utf-8
# Used to create sample data
#begin
user = User.create email: 'demo@example.com', password: 'demo12345', rol: 'demo'
#user.set_confirmation_token

#UserSession.current_user = user

# Countries
# YAML.load_file('db/defaults/countries.yml').each do |c|
#   Country.new(c[:code], c[:name])
# end
# puts "Countries have been created."
# # Currencies
# YAML.load_file('db/defaults/currencies.yml').each do |c|
#   Currency.new(code: c[:code], name: c[:name])
# end
# puts "Currencies have been created."

org = Organisation.create(:user => user: name => 'Constructora Benavente SpA', :header_css => "bonsai-header", :country_id => 1, :currency => "CLP", :phone => 2745620, :mobile => '70681101', :address => "Santo Domingo 1456, Santiago")
Link.create user_id: user.id organisation_id: org.id, role: 'admin'
puts "The organisation #{org.name} has been created"
#end
