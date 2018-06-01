require_relative 'common'

# encoding: utf-8
class RestoringFromDbTest < Test::Unit::TestCase
  include Common

  def setup
    @processor = BotProcessor.new(MessageParser.instance)
    @chat = Telegram::Bot::Types::Chat.new(type: 'group', id: '123', first_name: 'Group', last_name: 'User')
    @db = DatabaseMock.new({})
    GameManager.instance.restore_previous_games(@db)
    change_question_to('question_no_pass_criteria.xml')
  end

  def teardown
    send_message('/stop')
  end

  def test_killing_after_next
    send_message('/start')
    send_message('/next')
    erase_and_restore_all_games
    reply = send_message('/answer')
    expected = "*Ответ*: Быть\n*Комментарий*: Замечательный комментарий."
    assert_equal(expected, reply.message, 'Incorrect message on /answer')
  end

  def test_killing_after_start
    send_message('/start')
    erase_and_restore_all_games
    send_message('/next')
    reply = send_message('/answer')
    expected = "*Ответ*: Быть\n*Комментарий*: Замечательный комментарий."
    assert_equal(expected, reply.message, 'Incorrect message on /answer')
  end

  def test_next_after_answer_does_not_contain_previous_answer
    send_message('/start')
    send_message('/next')
    send_message('/answer')
    change_question_to('second_question.xml')
    erase_and_restore_all_games
    reply = send_message('/next')
    assert_nil(reply.previous_answer, 'Previous answer is not nil after restoring from db')
  end
end