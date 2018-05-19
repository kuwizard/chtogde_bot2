require_relative 'common'

# encoding: utf-8
class ScenariosWithTextTest < Test::Unit::TestCase
  include Common

  def setup
    @processor = BotProcessor.new(MessageParser.instance)
    @chat = Telegram::Bot::Types::Chat.new(type: 'private', id: '123', first_name: 'Test', last_name: 'User')
    db = DatabaseMock.new({})
    GameManager.instance.restore_previous_games(db)
  end

  def teardown
    send_message('/stop')
  end

  def test_answer_incorrectly
    send_message('/start')
    send_message('/next')
    reply = send_message('/фигня')
    expected = '"*фигня*" - это неправильный ответ.'
    assert_equal(expected, reply.message, 'Incorrect message on incorrect answer')
  end

  def test_answer_correctly_primary
    send_message('/start')
    send_message('/next')
    reply = send_message('/быть')
    expected = "\"*быть*\" - это правильный ответ!\n*Комментарий*: Замечательный комментарий."
    assert_equal(expected, reply.message, 'Incorrect message on correct answer')
  end

  def test_answer_correctly_upcase
    send_message('/start')
    send_message('/next')
    reply = send_message('/БЫТЬ')
    expected = "\"*БЫТЬ*\" - это правильный ответ!\n*Комментарий*: Замечательный комментарий."
    assert_equal(expected, reply.message, 'Incorrect message on correct UPPERCASE answer')
  end

  def test_repeat
    send_message('/start')
    send_message('/next')
    reply = send_message('/repeat')
    expected = '*Вопрос*: Быть или не быть?'
    assert_equal(expected, reply.message, 'Incorrect message on /repeat after answer')
  end

  def test_surrender
    send_message('/start')
    send_message('/next')
    reply = send_message('/answer')
    expected = "*Ответ*: Быть.\n*Комментарий*: Замечательный комментарий."
    assert_equal(expected, reply.message, 'Incorrect message on /answer')
  end
end