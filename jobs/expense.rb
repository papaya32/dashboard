require 'json'

# URI to the installed app root
host_uri = ENV["DASHING_URI"] || 'http://localhost:3030'

app = ExpenseApp.new()

post '/expense/button' do
  app.expenseButton(params['deviceId'])
end

post '/expense/start' do
  app.expenseStart()
end
