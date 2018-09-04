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
    assert_equal(expected, @reply.message, '')
  end
end