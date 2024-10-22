
// Описать, как обработать в отправку приложенный файл не XML.
//
// Параметры:
//  Кэш					 - ЛокальныйКэш	- Струкутра
//  ДанныеФайла			 - Структура	- Вложение, Файл
//  ПараметрыПодготовки	 - Струкутра	- Данные отправки документа - СоставПакета, Документ, СтатусПакета
//
&НаКлиенте
Процедура Отправка_ОбработатьВнешнийФайл(Кэш, ДанныеФайла, ПараметрыПодготовки) Экспорт
	
	СБИСПлагин_ОбработатьВнешнийФайл(Кэш, ДанныеФайла, ПараметрыПодготовки) 

КонецПроцедуры

// Описать, как обработать в отправку приложенный файл не XML.
//
// Параметры:
//  Кэш					 - ЛокальныйКэш	- Струкутра
//  ДанныеФайла			 - Структура	- Вложение, Файл
//  ПараметрыПодготовки	 - Струкутра	- Данные отправки документа - СоставПакета, Документ, СтатусПакета
//
&НаКлиенте
Процедура Отправка_ОбработатьXMLФайл(Кэш, ДанныеФайла, ПараметрыПодготовки) Экспорт
	
	СБИСПлагин_ОбработатьXMLФайл(Кэш, ДанныеФайла, ПараметрыПодготовки);

КонецПроцедуры

// Описать, как обработать асинхронное событие
//
// Параметры:
//  ОбработчикКоманды	 - АсинхроннаяСбисКоманда	- Структура команды отправки
//  ПараметрыСобытий	 - Струкутра				- Данные для формируемых подписок
//
&НаКлиенте
Функция Отправка_ПодпискиСобытия(ПараметрыСобытий) Экспорт
	
	Кэш = ПараметрыСобытий.Кэш;
	Результат = Новый Структура;
	Результат.Вставить("Error",		Новый Структура("Функция",					"WriteDocumentEx2_Error"));
	Результат.Вставить("Message",	Новый Структура("Функция, ФункцияОшибки",	"WriteDocumentEx2_Message", "WriteDocumentEx2_Error"));
	Возврат Результат;
				
КонецФункции

