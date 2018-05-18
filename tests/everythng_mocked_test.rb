require_relative 'common'

# encoding: utf-8
class EverythingMockedTest < Test::Unit::TestCase
  include Constants
  include Common

  def setup
    @processor = BotProcessor.new(MessageParser.instance)
    @chat = Telegram::Bot::Types::Chat.new(type: 'private', id: '123', first_name: 'Test', last_name: 'User')
    db = DatabaseMock.new({})
    GameManager.instance.restore_previous_games(db)
  end

  def test_start
    reply = send_message('/start')
    assert_equal(Constants::START, reply.message, 'Incorrect message just after start')
  end

  def test_stop_without_start
    reply = send_message('/stop')
    assert_equal(Constants::STOP, reply.message, 'Incorrect message on /stop without start')
  end

  def test_help_without_start
    reply = send_message('/help')
    assert_equal(Constants::HELP, reply.message, 'Incorrect message on /help without start')
  end

  def test_next_without_start
    reply = send_message('/next')
    assert_equal(Constants::NOT_STARTED, reply.message, 'Incorrect message on /next without start')
  end

  def test_answer_without_start
    reply = send_message('/answer')
    assert_equal(Constants::NOT_STARTED, reply.message, 'Incorrect message on /answer without start')
  end

  def test_repeat_without_start
    reply = send_message('/repeat')
    assert_equal(Constants::NOT_STARTED, reply.message, 'Incorrect message on /repeat without start')
  end
end