
// Функция - генерирует набор вложений в пакет на основании подготовленных данных одного документа
//
// Параметры:
//  ПараметрыСгенерироватьВходящие	 - Структура	 - 
//		Вложение					- Структура - данные подготовленного вложения, на основании которого формируем вложения в пакет
//		ОснованиеПакета 			- ДокумнтСсылка	- основной документ пакета
//		Пакет(необяз)				- Структура - данные генерируемого пакета
//		МетодПодготовки(необяз)		- Строка - Имя иметода для подготовки вложения генератором (СформироватьДокументДляГенератора).
//      СтруктураДокумента(необяз)	- Структура - данные документа для формирования XML. Должно быть либо во входящем параметре, либо на Вложении
// Возвращаемое значение:
//  Массив - сгенерированные вложения на основании собранной структуры докумнта.
//
&НаКлиенте
Функция СгенерироватьНаборВложенийВПакет(ПараметрыСгенерироватьВходящие) Экспорт
	
	Если ИспользоватьГенераторДляВложения(ПараметрыСгенерироватьВходящие.Вложение) Тогда
		Возврат СформироватьВложенияГенератором(ПараметрыСгенерироватьВходящие, Новый Структура);
	Иначе
		Возврат СформироватьВложенияПрочие(ПараметрыСгенерироватьВходящие, Новый Структура)		
	КонецЕсли;
		
КонецФункции

&НаКлиенте
Функция ИспользоватьГенераторДляВложения(ВложениеДанные) Экспорт
	Возврат 	ГлобальныйКэш.Парам.ИспользоватьГенератор = Истина
			И	ГлобальныйКэш.СБИС.ПараметрыИнтеграции.ГенераторФЭД
			И	ВложениеДанные.Свойство("ИспользоватьГенератор")
			И	ВложениеДанные.ИспользоватьГенератор = Истина ;
КонецФункции

&НаКлиенте
Функция СформироватьВложенияГенератором(ПараметрыФормированияВходящие, ДопПараметры)
	Перем СтруктураФайла, ВерсияФорматаПодстановки, МетодПодготовкиВложения;
	
	Попытка
		Вложение = ПараметрыФормированияВходящие.Вложение;
		Если	Не ПараметрыФормированияВходящие.Свойство("СтруктураДокумента", СтруктураФайла)
			И	Не Вложение.Свойство("СтруктураДокумента",						СтруктураФайла) Тогда
			Возврат СформироватьВложенияПрочие(ПараметрыФормированияВходящие, ДопПараметры);
		КонецЕсли;
		
		СтруктураВложения	= НовыйВложениеСБИС(Вложение, ПараметрыФормированияВходящие);
		Результат			= Новый Массив;
		СбисОбщиеФункции	= ГлобальныйКэш.ТекущийСеанс.Модули.ФункцииДокументов;
		
		СбисФормыПоиска			= Новый Массив;
		ПараметрыФормирования	= Новый Структура("Вложение, Документ, ФормыПоиска", Вложение, СтруктураФайла, СбисФормыПоиска);
		ШаблонXML				= "";
		ОшибкаФормирования		= Ложь;

		ПараметрыПримененияПодстановок = Новый Структура;
		Если Не СтруктураФайла.Файл.Свойство("ВерсияФормата", ВерсияФорматаПодстановки) Тогда
			ВерсияФорматаПодстановки = Вложение.ВерсияФормата;
		КонецЕсли;
		ИмяФормыПоФормату		= "Файл_"	+ СбисОбщиеФункции.СбисЗаменитьНедопустимыеСимволы(СтруктураФайла.Файл.Формат)
									+ "_"	+ СбисОбщиеФункции.СбисЗаменитьНедопустимыеСимволы(ВерсияФорматаПодстановки);
		СбисФормыПоиска.Добавить(ИмяФормыПоФормату);
		Если Не ВерсияФорматаПодстановки = "3.01" Тогда
			СбисФормыПоиска.Добавить("Файл_Шаблон_" + СтрЗаменить(ВерсияФорматаПодстановки, ".", "_"));
		КонецЕсли;
		СбисФормыПоиска.Добавить("Файл_Шаблон");
		ПараметрыПримененияПодстановок.Вставить("ФормыПоиска", СбисФормыПоиска);
		
		//Обогатить документ параметрами, которые не попадают в формат вложения подстановки, но нужны для более простой обработки
		Если Не ПараметрыФормированияВходящие.Свойство("МетодПодготовки", МетодПодготовкиВложения) Тогда
			МетодПодготовкиВложения = "СформироватьДокументДляГенератора";
		КонецЕсли;
		фрм = ГлавноеОкно.СбисНайтиФормуФункцииСеанса(ГлавноеОкно.Кэш, МетодПодготовкиВложения, ПараметрыПримененияПодстановок.ФормыПоиска, Новый Структура, ОшибкаФормирования);
		Если ОшибкаФормирования Тогда
			ВызватьСбисИсключение(фрм, "ГлавноеОкно.СбисНайтиФормуФункцииСеанса." + МетодПодготовкиВложения);
		ИначеЕсли фрм = Ложь Тогда
			ВызватьСбисИсключение(779, "ГлавноеОкно.СбисНайтиФормуФункцииСеанса." + МетодПодготовкиВложения,,,"Не удалось определить модуль для подготовки подстановки");
		КонецЕсли;
		
		ОбработчикГенератора = НовыйСбисОписаниеОповещения(МетодПодготовкиВложения, фрм, ГлавноеОкно.Кэш);
		ВыполнитьСбисОписаниеОповещения(ПараметрыФормирования, ОбработчикГенератора);
		//фрм.СформироватьДокументДляГенератора(ПараметрыФормирования, ГлавноеОкно.Кэш);

		//Обновить связки с изменениями подготовки генератора на всякий случай.
		СтруктураВложения.Вставить("СтруктураФайла", ПараметрыФормирования.Документ);
		Вложение.Вставить("СтруктураДокумента", ПараметрыФормирования.Документ);
		
        РезультатПодставновки = СформироватьИПрименитьПодстановкуПоВложению(Вложение, ПараметрыПримененияПодстановок);
		
		Если ТипЗнч(РезультатПодставновки) = Тип("Массив") Тогда
			Для Каждого ВложениеПодстановки Из РезультатПодставновки Цикл
				Если ВложениеПодстановки.Формат.Основной Тогда
					СтруктураВложения.Вставить("XMLДокумента", ВложениеПодстановки.Тело);
					Продолжить;
				КонецЕсли;
				
				СтруктураВложенияДобавить = СбисОбщиеФункции.СкопироватьОбъектСПараметрамиКлиент(СтруктураВложения,, Ложь);
				СтруктураВложенияДобавить.Вставить("XMLДокумента",	ВложениеПодстановки.Тело);
				СтруктураВложенияДобавить.Вставить("Документы1С",	Новый СписокЗначений);//Отвязка от документа, т.к. иначе сопоставление запишется на добавленный докумт
				ЗаполнитьЗначенияСвойств(СтруктураВложенияДобавить, ВложениеПодстановки.Формат);
				СтруктураВложенияДобавить.Тип = ВложениеПодстановки.Формат.ТипДокумента;
				//Обновить имя файла вложения.
				Если	СтруктураВложения.Свойство("СтруктураФайла")
					И	СтруктураВложения.СтруктураФайла.Свойство("Файл")
					И	ВложениеПодстановки.Формат.Свойство("ИмяФайла") Тогда
					СтруктураВложенияДобавить.СтруктураФайла			= СбисОбщиеФункции.СкопироватьОбъектСПараметрамиКлиент(СтруктураВложения.СтруктураФайла,, Ложь);
					СтруктураВложенияДобавить.СтруктураФайла.Файл		= СбисОбщиеФункции.СкопироватьОбъектСПараметрамиКлиент(СтруктураВложения.СтруктураФайла.Файл,, Ложь);
					СтруктураВложенияДобавить.СтруктураФайла.Файл.Имя	= ВложениеПодстановки.Формат.ИмяФайла;
				КонецЕсли;
				
				Результат.Добавить(СтруктураВложенияДобавить);
			КонецЦикла;
		Иначе
			СтруктураВложения.Вставить("XMLДокумента", РезультатПодставновки);
		КонецЕсли;
		Результат.Вставить(0, СтруктураВложения);
		Возврат Результат;
		
	Исключение
		ВызватьСбисИсключение(ИнформацияОбОшибке(), "МодульОбъектаКлиент.СформироватьИПрименитьПодстановкуПоВложению");
	КонецПопытки;

КонецФункции

&НаКлиенте
Функция СформироватьВложенияПрочие(ПараметрыСгенерироватьВходящие, ДопПараметры)
	
	Перем Документы1СВложения, СтруктураФайла, СтруктураДокумента;
	
	Попытка
		Вложение			= ПараметрыСгенерироватьВходящие.Вложение;
		СтруктураВложения	= НовыйВложениеСБИС(Вложение, ПараметрыСгенерироватьВходящие);
		Результат			= Новый Массив;
		
		Если		Вложение.Свойство("ИмяФайла") Тогда
			
			//Внешний файл. Это вложение не может быть первым, т.к. с первого берутся сведения об отправителе, получателе
			СтруктураВложения.Вставить("ПолноеИмяФайла",	Вложение.ПолноеИмяФайла);
			СтруктураВложения.Вставить("ИмяФайла",			Вложение.ИмяФайла);
			СтруктураВложения.Вставить("XMLДокумента",		?(Вложение.Свойство("XMLДокумента"),		Вложение.XMLДокумента,			""));
			СтруктураВложения.Вставить("СтруктураФайла",	?(Вложение.Свойство("СтруктураДокумента"),	Вложение.СтруктураДокумента,	Новый Структура));
			
		ИначеЕсли	ПараметрыСгенерироватьВходящие.Свойство("СтруктураДокумента", СтруктураДокумента) Тогда
			
			СтруктураВложения.Вставить("СтруктураФайла",	СтруктураДокумента);
			СтруктураВложения.Вставить("XMLДокумента",		ГлобальныйКэш.ТекущийСеанс.Модули.ФункцииДокументов.СбисПолучитьXMLФайлаИзСтруктуры(ГлавноеОкно.Кэш, СтруктураВложения));
			
		ИначеЕсли	Вложение.Свойство("СтруктураДокумента", СтруктураФайла) Тогда 
			
			//XML с инишкой, сгенерировали мы
			СтруктураВложения.Вставить("СтруктураФайла",	СтруктураФайла);
			СтруктураВложения.Вставить("XMLДокумента",		ГлобальныйКэш.ТекущийСеанс.Модули.ФункцииДокументов.СбисПолучитьXMLФайлаИзСтруктуры(ГлавноеОкно.Кэш, СтруктураВложения));
			
		Иначе 
			
			// XML без инишки, неизвестный. Добавить как есть
			СтруктураВложения.Вставить("СтруктураФайла",	Вложение.СтруктураФайла);
			СтруктураВложения.Вставить("XMLДокумента",		Вложение.XMLДокумента);
			
		КонецЕсли;
		
		Результат.Добавить(СтруктураВложения);
		Возврат Результат;
	Исключение
		ВызватьСбисИсключение(ИнформацияОбОшибке(), "МодульОбъектаКлиент.СформироватьВложенияПрочие");
	КонецПопытки;

	
КонецФункции

// Функция - Сформировать и применить подстановку по экземпляру вложения
//
// Параметры:
//  Вложение	 - Структура - экземпляр Вложение
//  ДопПараметры - Структура
//		ФормыПоиска - Массив альтернативных форм для поиска функций генератора.
// 
// Возвращаемое значение:
//   - 
//
&НаКлиенте
Функция СформироватьИПрименитьПодстановкуПоВложению(Вложение, ДопПараметры) Экспорт
	Перем СбисФормыПоиска;
	
	ОшибкаФормирования = Ложь;
	
	Попытка
		фрм = ГлавноеОкно.СбисНайтиФормуФункцииСеанса(ГлавноеОкно.Кэш, "СформироватьНаборПодстановок", ДопПараметры.ФормыПоиска, Новый Структура, ОшибкаФормирования);
		Если ОшибкаФормирования Тогда
			ВызватьСбисИсключение(фрм, "ГлавноеОкно.СбисНайтиФормуФункцииСеанса.СформироватьИПрименитьПодстановкуПоВложению");
		ИначеЕсли фрм = Ложь Тогда
			ВызватьСбисИсключение(779, "ГлавноеОкно.СбисНайтиФормуФункцииСеанса.СформироватьИПрименитьПодстановкуПоВложению",,,"Не удалось определить модуль для формирования подстановки");
		КонецЕсли;
		
		НаборПодстановок = фрм.СформироватьНаборПодстановок(Вложение, ДопПараметры);
		
		Если	ДопПараметры.Свойство("МассоваяОтправка")
			И	ДопПараметры.МассоваяОтправка Тогда
			Возврат НаборПодстановок.Получить("Генератор");	
		КонецЕсли;
		
		ПараметрыДокумента = Новый Структура("ВерсияФормата, ТипДокумента, ПодТип, ПодВерсияФормата");
		ПараметрыДокумента.ВерсияФормата 	= Вложение.ВерсияФормата;
		ПараметрыДокумента.ТипДокумента 	= Вложение.Тип;
		ПараметрыДокумента.ПодТип 			= Вложение.ПодТип;
		ПараметрыДокумента.ПодВерсияФормата = Вложение.ПодВерсияФормата;
		
		РезультатПодставновки = ГлобальныйКэш.ТекущийСеанс.Модули.Интеграция.Интеграция_ФЭДМультиСгенерировать(
			ПараметрыДокумента, 
			НаборПодстановок, 
			Новый Структура("Кэш", ГлавноеОкно.Кэш));
			
		Возврат РезультатПодставновки;
		
	Исключение
		ВызватьСбисИсключение(ИнформацияОбОшибке(), "МодульОбъектаКлиент.СформироватьИПрименитьПодстановкуПоВложению");
	КонецПопытки;
			
КонецФункции

