module Users
  TEST_USER = Telegram::Bot::Types::User.new(
    first_name: 'User',
    id: 666,
    is_bot: false,
    language_code: 'en-GB',
    last_name: 'Test',
    username: 'Username'
  )
  BOT = Telegram::Bot::Types::User.new(
    first_name: 'ChtoGdeKogda',
    id: 491811281,
    is_bot: true,
    username: 'chtogde_bot'
  )
end