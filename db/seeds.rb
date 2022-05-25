# timo = User.findcreate!(
#   first_name: 'Timo',
#   last_name: 'Moss',
#   email: 'timo.moss@gmail.com',
#   password: '123456789'
# )
#
# account = User::Account.create!(
#   user: timo,
#   balance: 4000000
# )
#
# tanya = User.create!(
#   first_name: 'Tanya',
#   last_name: 'Moss',
#   email: 'tanya.moss@gmail.com',
#   password: '123456789'
# )
#
# account = User::Account.create!(
#   user: tanya,
#   balance: 4000000
# )
#

MoneyTransaction.create!(sender_id: 1,  receiver_id: 2,  amount: 50000.00,  description: 'For pleasure')