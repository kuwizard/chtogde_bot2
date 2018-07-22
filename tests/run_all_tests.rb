require 'test/unit/testsuite'
require 'test/unit/ui/console/testrunner'

require_relative 'text_messages_test'
require_relative 'real_chgk_db_test'
require_relative 'scenarios_with_pass_criterias_test'
require_relative 'scenarios_with_buttons_test'
require_relative 'scenarios_in_group_chat_test'
require_relative 'restoring_from_db'
require_relative 'scenarios_with_sources_option'
require_relative 'scenarios_with_text_test'

class ChtoGdeAllTestsSuite < Test::Unit::TestSuite
  def self.suite
    result = self.new(self.class.name)
    # result << RealChgkDBTest.suite # As we work with real DB here, it causes tests to run in 1.5-2 seconds instead of 0.2 seconds
    result << TextMessagesTest.suite
    result << ScenariosInGroupChatTest.suite
    result << ScenariosWithButtonsTest.suite
    result << ScenariosWithPassCriteriasTest.suite
    result << ScenariosWithSourcesTest.suite
    result << ScenariosWithTextTest.suite
    result << RestoringFromDbTest.suite
    return result
  end
end

Test::Unit::UI::Console::TestRunner.run(ChtoGdeAllTestsSuite)