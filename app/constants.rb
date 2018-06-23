module Constants
  BOT_NAME = '@chtogde_bot'
  START = 'Ну, поехали! Если нужна помощь, набирай /help. Задать вопрос: /next'
  STOP = 'Всем пока!'
  HELP = '/start - запускает бота
/stop - останавливает бота
/next - следующий вопрос
/answer - дать ответ на предыдущий
/sources - включает/отключает показ списка источников одновременно с ответом
/любой текст - попытаться ответить на заданный вопрос'
  NOT_STARTED = 'Чтобы начать введите /start. Если нужна помощь, набирай /help'
  STARTED_NOT_ASKED = 'Не был задан вопрос, набери /next чтобы получить новый'
  SOURCES_NOW_ON = 'Вывод списка источников *включён*'
  SOURCES_NOW_OFF = 'Вывод списка источников *отключён*'

  RANDOM_QUESTION_URL = 'https://db.chgk.info/xml/random/'
  TOUR_QUESTION_URL = 'https://db.chgk.info/tour/%tour_name/xml/'
  IMAGE_URL = 'http://db.chgk.info/images/db/'
  FILE_PATH = '../tests/data/'
end