require_relative 'common'

# encoding: utf-8
class ScenariosToursTest < Test::Unit::TestCase
  include Common

  def setup
    @processor = BotProcessorMock.new
    @chat = Telegram::Bot::Types::Chat.new(type: 'private', id: '123', first_name: 'Test', last_name: 'User')
    change_question_to('two_questions_no_pass_criteria.xml')
  end

  def teardown
    send_message('/stop')
  end

  def test_switching_to_tours
    send_message('/start')
    send_message('/tours')
    expected = Constants::SWITCHED_TO_TOURS
    assert_equal(expected, @reply.message, 'Incorrect message while switching to tours')
  end

  def test_switching_to_tours_then_to_random
    send_message('/start')
    send_message('/tours')
    send_message('/random')
    expected = Constants::SWITCHED_TO_RANDOM
    assert_equal(expected, @reply.message, 'Incorrect message while switching to random after tours')
  end

  def test_switching_to_random_after_start
    send_message('/start')
    send_message('/random')
    expected = Constants::ALREADY_RANDOM
    assert_equal(expected, @reply.message, 'Incorrect message while switching to random after start')
  end

  def test_switching_to_tours_twice
    send_message('/start')
    send_message('/tours')
    send_message('/tours')
    expected = Constants::ALREADY_TOURS
    assert_equal(expected, @reply.message, 'Incorrect message while switching to tours twice')
  end
end