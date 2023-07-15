# seed.rb

# Create a user with a username and password
User.create(username: "john_doe", password: "password123")

# Create more users if needed
User.create(username: "jane_smith", password: "abc123")
User.create(username: "bob_jackson", password: "qwerty")

# Run the seed file using `rails db:seed` command to populate the database with the data.
