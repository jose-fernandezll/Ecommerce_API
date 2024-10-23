user = User.new(name: "jose fernandez", email: "jose@test.com")
user.save(validate: false)
user.update!(stripe_id: 'fake_stripe_id_for_seed')