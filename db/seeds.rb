

# this is to get a random from this array, not using it
# arr = [1,2,3]
# userid = arr.sample


# User.create(email: 'admin@ex.com',
#             password: 'asdfasdf',
#             password_confirmation: 'asdfasdf',
#             name: 'Admin1',
#             role: User.roles[:admin])
# User.create(email: 'user1@ex.com',
#             password: 'asdfasdf',
#             password_confirmation: 'asdfasdf',
#             name: 'User One')

# p "Created #{User.count} users"

# 10.times do |x|
#   post = Post.create(title: "Title #{x}",
#                      body: "Body #{x} Words go here Idk",
#                      user_id: User.first.id)

#   5.times do |y|
#     post.comments.create(body: "Comment #{y}",
#                    user_id: User.second.id)
#   end
# end

# p "Created #{Post.count} posts"

# run seed file based on environment
puts 'Seeding database'
load(Rails.root.join('db', 'seeds', "#{Rails.env.downcase}.rb"))