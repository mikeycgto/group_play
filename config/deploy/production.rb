# Single stage deployment
set :stage, :production

# Define the server
server 'groupplay.local', user: 'groupplay', roles: %w{web app}
