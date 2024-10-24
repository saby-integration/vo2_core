
&НаКлиенте
Функция НовыйСоставПакета(ПараметрыКонструктора) Экспорт

	НовыйСоставПакета = Новый Структура("Вложение", Новый Массив);
	Если ПараметрыКонструктора.Свойство("ОснованиеПакета") Тогда
		НовыйСоставПакета.Вложение.Добавить(НовыйВложениеСБИС(, ПараметрыКонструктора));
	КонецЕсли;
	//Новый пакет с установкой ошибки.
	Если ПараметрыКонструктора.Свойство("Ошибка") Тогда
		НовыйСоставПакета.Вставить("Ошибка", ПараметрыКонструктора.Ошибка);
	КонецЕсли;

	Возврат НовыйСоставПакета;
	
КонецФункции

&НаКлиенте
Функция СоставПакета_СтруктураКонтрагентаДляОтправки(СоставПакета) Экспорт
	
	kontr = Новый Структура; 
	
	КлючИдентификатора = МодульОбъектаКлиент().Сторона_Получить(СоставПакета.Контрагент, "КлючИдентификатора"); 	
	
	//ИД контрагента
	Если	СоставПакета.Контрагент.Свойство("Идентификатор")
		И	ЗначениеЗаполнено(СоставПакета.Контрагент.Идентификатор) Тогда
		kontr.Вставить( "Идентификатор", СоставПакета.Контрагент.Идентификатор);
	Иначе		
		СбисИдентификаторКонтрагента = ПрочитатьДополнительныйПараметрСтороны(СоставПакета.Контрагент, "КодОператораАбонентскогоЯщика");
		
		Если Не СбисИдентификаторКонтрагента = Неопределено Тогда
			//ИД явно не указан, то проверить наличие ИД оператора А/Я
			kontr.Вставить("Идентификатор", СбисИдентификаторКонтрагента);
		Иначе
			СбисИдентификаторКонтрагента = ПрочитатьДополнительныйПараметрСтороны(СоставПакета.Контрагент, "Идентификатор");
			Если Не СбисИдентификаторКонтрагента = Неопределено Тогда
				kontr.Вставить("Идентификатор", СбисИдентификаторКонтрагента);
			КонецЕсли;
		КонецЕсли;
		
	КонецЕсли;
	
	//Контакты
	Если СоставПакета.Контрагент.Свойство("Контакт")  Тогда
		Если СоставПакета.Контрагент.Контакт.Свойство("Телефон")  Тогда
			kontr.Вставить( "Телефон", СоставПакета.Контрагент.Контакт.Телефон );
		КонецЕсли;
		Если СоставПакета.Контрагент.Контакт.Свойство("EMAIL")  Тогда
			kontr.Вставить( "Email", СоставПакета.Контрагент.Контакт.EMAIL );
		КонецЕсли;
	КонецЕсли;
	
	//СвФЛ/СвЮл
	Если СоставПакета.Контрагент.Свойство("СвФЛ") Тогда
		СвФЛ = Новый Структура;
		Если СоставПакета.Контрагент.Свойство("Параметр") Тогда
			Для Каждого Параметр из СоставПакета.Контрагент.Параметр Цикл
				Если Параметр.Имя = "ЧастноеЛицо" Тогда
					СвФЛ.Вставить("ЧастноеЛицо", Параметр.Значение);
				КонецЕсли;
				Если Параметр.Имя = "СНИЛС" Тогда
					СвФЛ.Вставить("СНИЛС", Параметр.Значение);						
				КонецЕсли;     					
			КонецЦикла;
		КонецЕсли;  
		Если СоставПакета.Контрагент.СвФЛ.Свойство("ИНН") Тогда  
			СвФЛ.Вставить( "ИНН", СоставПакета.Контрагент.СвФЛ[КлючИдентификатора] );
		КонецЕсли;
		Если СоставПакета.Контрагент.СвФЛ.Свойство("Фамилия") Тогда
			СвФЛ.Вставить( "Фамилия", СоставПакета.Контрагент.СвФЛ.Фамилия );	
		КонецЕсли;
		Если СоставПакета.Контрагент.СвФЛ.Свойство("Имя") Тогда
			СвФЛ.Вставить( "Имя", СоставПакета.Контрагент.СвФЛ.Имя );	
		КонецЕсли;
		Если СоставПакета.Контрагент.СвФЛ.Свойство("Отчество") Тогда
			СвФЛ.Вставить( "Отчество", СоставПакета.Контрагент.СвФЛ.Отчество );	
		КонецЕсли;
		Если СоставПакета.Контрагент.СвФЛ.Свойство("КодФилиала") и ЗначениеЗаполнено(СоставПакета.Контрагент.СвФЛ.КодФилиала) Тогда
			СвФЛ.Вставить( "КодФилиала", СоставПакета.Контрагент.СвФЛ.КодФилиала );	
		КонецЕсли;

		kontr.Вставить( "СвФЛ", СвФЛ );	
	Иначе
		СвЮЛ = Новый Структура;
		СвЮЛ.Вставить( "ИНН", СоставПакета.Контрагент.СвЮЛ[КлючИдентификатора] );  
		Если СоставПакета.Контрагент.СвЮЛ.Свойство("КПП") Тогда
			СвЮЛ.Вставить( "КПП", СоставПакета.Контрагент.СвЮЛ.КПП );
		КонецЕсли;
		Если СоставПакета.Контрагент.СвЮЛ.Свойство("КодСтраны") Тогда
			СвЮЛ.Вставить( "КодСтраны", СоставПакета.Контрагент.СвЮЛ.КодСтраны );	
		КонецЕсли;
		Если СоставПакета.Контрагент.СвЮЛ.Свойство("КодФилиала") и ЗначениеЗаполнено(СоставПакета.Контрагент.СвЮЛ.КодФилиала) Тогда
			СвЮЛ.Вставить( "КодФилиала", СоставПакета.Контрагент.СвЮЛ.КодФилиала );	
		КонецЕсли;
		Если СоставПакета.Контрагент.СвЮЛ.Свойство("Название") Тогда
			СвЮЛ.Вставить( "Название", СоставПакета.Контрагент.СвЮЛ.Название );	
		КонецЕсли;
		kontr.Вставить( "СвЮЛ", СвЮЛ );
	КонецЕсли;
	
	//Подразделение
	Если СоставПакета.Контрагент.Свойство("Подразделение") и СоставПакета.Контрагент.Подразделение.Свойство("Идентификатор") Тогда
		Подразделение = Новый Структура;
		Подразделение.Вставить( "Идентификатор", СоставПакета.Контрагент.Подразделение.Идентификатор); 
		kontr.Вставить( "Подразделение", Подразделение );
	КонецЕсли;	
	Возврат kontr;
	
КонецФункции 

&НаКлиенте
Функция СоставПакета_СтруктураОрганизацииДляОтправки(СоставПакета) Экспорт
	Перем СвФлЮлИсточник, КодФилиалаОрганизации;
	
	СторонаРезультат = Новый Структура;
	
	Если Не СоставПакета.Свойство("НашаОрганизация") Тогда
		
		ВызватьСбисИсключение("Неизвестный формат состава пакета для отправки.", "МодульОбъектаКлиент.СоставПакета_СтруктураОрганизацииДляОтправки");
		
	ИначеЕсли СоставПакета.НашаОрганизация.Свойство("СвФЛ", СвФлЮлИсточник) Тогда
		
		СвФлЮлРезультат = Новый Структура;
		СторонаРезультат.Вставить("СвФЛ", СвФлЮлРезультат);
		
	ИначеЕсли СоставПакета.НашаОрганизация.Свойство("СвЮЛ", СвФлЮлИсточник) Тогда
		
		СвФлЮлРезультат = Новый Структура;
		СторонаРезультат.Вставить("СвЮЛ", СвФлЮлРезультат);
		
		Если СвФлЮлИсточник.Свойство("КПП") Тогда 
			
			СвФлЮлРезультат.Вставить("КПП", СвФлЮлИсточник.КПП);
			
		КонецЕсли;
		
		Если СвФлЮлИсточник.Свойство("КодСтраны") Тогда
			
			СвФлЮлРезультат.Вставить("КодСтраны", СвФлЮлИсточник.КодСтраны);
			
		КонецЕсли;
		
	Иначе
		
		ВызватьСбисИсключение("Неизвестный формат стороны документооборота", "МодульОбъектаКлиент.СоставПакета_СтруктураОрганизацииДляОтправки");
		
	КонецЕсли;
	
	КлючИдентификатора = МодульОбъектаКлиент().Сторона_Получить(СоставПакета.НашаОрганизация, "КлючИдентификатора");
	
	//ИНН обязан быть
	СвФлЮлРезультат.Вставить("ИНН", СвФлЮлИсточник[КлючИдентификатора]);
	
	//Проверим КФ организации.
	Если СоставПакета.Свойство("Контрагент") Тогда
		
		//Может быть задан на контрагенте как КФ отправителя
		КодФилиалаОрганизации = ПрочитатьДополнительныйПараметрСтороны(СоставПакета.Контрагент, "КодФилиалаОтправителя");
		
	КонецЕсли;
	
	Если ЗначениеЗаполнено(КодФилиалаОрганизации)
		Или ( СвФлЮлИсточник.Свойство("КодФилиала", КодФилиалаОрганизации)
		И ЗначениеЗаполнено(КодФилиалаОрганизации)) Тогда
		
		//Есть КФ отправителя, или установлен КФ на органиации. Приоритет КФ отправителя от контрагента выше установленного на организации
		СвФлЮлРезультат.Вставить("КодФилиала", КодФилиалаОрганизации);
		
	КонецЕсли;
	
	Возврат СторонаРезультат;
	
КонецФункции

// Функция - формирует Отправку СБИС - готовый к отправке Документ на основании состава пакета, прочитанного из 1С
//
// Параметры:
//  СоставПакета - Экземпляр класса (Структура)	- документ СБИС, прочитанный от 1С
//  ДопПараметры - Структура	 				- возможность расширения
// 
// Возвращаемое значение:
//  Экземпляр класса ОтправкаДокументаСБИС (Струкутра) 
//
&НаКлиенте
Функция СоставПакета_ПодготовитьКОтправке(СоставПакета, ДопПараметры=Неопределено) Экспорт
	Перем СбисШифрование, Статус, Этап;
	
	Если		ДопПараметры = Неопределено
		Или	Не	ДопПараметры.Свойство("Шифрование", СбисШифрование) Тогда
		СбисШифрование = Ложь;
	КонецЕсли;
	
	МодульИнтеграции = ПолучитьЗначениеПараметраСбис("Интеграция");
	
	document = Новый Структура;
	documentWrite = Новый Структура;  
	
	ЭтоЧерновик = НЕ ДопПараметры = Неопределено
		И	ДопПараметры.Свойство("Статус", Статус)
		И	НЕ	Статус = Неопределено
		И	Статус.Код = "0";
	
	//Сразу проставим статус, так как попали в функцию. В случае, если это не так, статус изменится (Например, в случае отправки вложения файл лоадером)
	Если ЭтоЧерновик Тогда
		Результат	= НовыйОтправкаДокументаСБИС(СоставПакета, "Черновик");
	Иначе
		Результат	= НовыйОтправкаДокументаСБИС(СоставПакета, "Готов");  
	КонецЕсли;
	ОтправкаДокументаСБИС_Установить(Результат, "ДокументОтправить",	document);
	ОтправкаДокументаСБИС_Установить(Результат, "ДокументЗаписать",		documentWrite);
	
	//РезультатПодготовки = Новый Структура("СоставПакета, ДокументОтправить, Ошибки, Готов, Отказ", СоставПакета, document, Новый Массив, Истина, Отказ);
	Если СоставПакета.Свойство("Дата") И ЗначениеЗаполнено(СоставПакета.Дата) Тогда
		document.Вставить("Дата",СоставПакета.Дата);	
	КонецЕсли;
	Если СоставПакета.Свойство("Номер") И ЗначениеЗаполнено(СоставПакета.Номер) Тогда
		document.Вставить("Номер",СоставПакета.Номер);	
	КонецЕсли;
	//Для зашифрованных документов нет суммы
	Если СбисШифрование Тогда
		document.Вставить("Шифрование", Новый Структура("Зашифрован", "Да"));
	ИначеЕсли	СоставПакета.Свойство("Сумма")
			И	ЗначениеЗаполнено(СоставПакета.Сумма) Тогда
		document.Вставить("Сумма",СоставПакета.Сумма);	
	КонецЕсли;
	ИдПакета = СоставПакета_Идентификатор(СоставПакета, ДопПараметры);
	
	attachmentList = Новый Массив;
	attachmentList_Изменены = Новый Массив;

	stage = Новый Структура;
	
	Если ДопПараметры.Свойство("Этап", Этап)
		И ЗначениеЗаполнено(Этап) Тогда
		
		action = Новый Структура("Название", "");
		Действие = Этап.Действие[0];
		ЗаполнитьЗначенияСвойств(action, Действие);
		
		Если	Действие.ТребуетПодписания = "Да"
			И	Действие.Свойство("Сертификат") Тогда
			action.Вставить("Сертификат", Действие.Сертификат);
		КонецЕсли;
		
		Если	Действие.ТребуетКомментария = "Да"
			И	Действие.Свойство("Комментарий") Тогда
			action.Вставить("Комментарий", Действие.Комментарий);
		КонецЕсли;
			
		// Назначение этапа
		stage = Новый Структура;
		stage.Вставить("Название", ?(ЗначениеЗаполнено(Этап.Название), Этап.Название , ""));
		stage.Вставить("Действие", action);
		
	КонецЕсли;
	
	Если СоставПакета_Получить(СоставПакета, "Модифицирован")
		И ЗначениеЗаполнено(stage) Тогда
		document.Вставить("Этап", stage);
		document.Этап.Вставить("Вложение",	attachmentList);
		documentWrite.Вставить("Вложение",	attachmentList_Изменены);
	ИначеЕсли ЗначениеЗаполнено(action) Тогда
		document.Вставить("Этап", stage);
		document.Этап.Вставить("Вложение",	attachmentList);
	Иначе
		document.Вставить("Вложение",		attachmentList); 
	КонецЕсли;
	
	document.Вставить("Тип", СоставПакета.Тип);
	
	Если СоставПакета.Свойство("Подтип") И ЗначениеЗаполнено(СоставПакета.Подтип) Тогда
		document.Вставить( "Подтип",СоставПакета.Подтип);
	КонецЕсли;
	document.Вставить("Идентификатор",	ИдПакета);
	documentWrite.Вставить("Идентификатор",	ИдПакета); 
	
	СоставПакета.Вставить("Идентификатор", ИдПакета);
	//Обработка вложений
	Для Каждого Вложение Из СоставПакета.Вложение Цикл
		ИдВложения = Неопределено;
		Если НЕ (Вложение.Свойство("Идентификатор", ИдВложения)
			И ЗначениеЗаполнено(ИдВложения)) Тогда
			ИдВложения = Строка(Новый УникальныйИдентификатор());
		КонецЕсли;
		Вложение.Вставить("Идентификатор", ИдВложения);
		
		file		= Новый Структура;
		attachment	= Новый Структура("Идентификатор, Файл", ИдВложения, file);
		
		Если СбисШифрование Тогда
			Если ПолучитьЗначениеПараметраСбис("ШифроватьВыборочно") Тогда
				Если Вложение.Свойство("Шифрование") И Вложение.Шифрование = Истина Тогда
					attachment.Вставить("Шифрование", "Да" );
				Иначе
					attachment.Вставить("Шифрование", "Нет" );
				КонецЕсли;
			КонецЕсли;
		ИначеЕсли Вложение.Свойство("Зашифрован") Тогда
			// может быть в случае пересылки зашифрованных пакетов
			attachment.Вставить("Зашифрован", Вложение.Зашифрован);
		КонецЕсли;
		
		СбисПараметрыВложения = Новый Структура("Файл, Вложение, ВложениеВПакет", file, Вложение, attachment);
		
		Если		Вложение.Свойство("ПолноеИмяФайла") Тогда // внешний файл добавлен в пакет

			file.Вставить("Имя", Вложение.ИмяФайла);
			МодульИнтеграции.Отправка_ОбработатьВнешнийФайл(ГлавноеОкно.Кэш, СбисПараметрыВложения, Результат);

		ИначеЕсли	ТипЗнч(СбисПараметрыВложения.Вложение.XMLДокумента) = Тип("Соответствие") Тогда
			
			file.Вставить("Подстановка", СбисПараметрыВложения.Вложение.XMLДокумента);
			
		Иначе  // сформирован xml
			
			ИмяФайла = Вложение.СтруктураФайла.Файл.Имя + ".xml";
			file.Вставить("Имя", ИмяФайла);
			МодульИнтеграции.Отправка_ОбработатьXMLФайл(ГлавноеОкно.Кэш, СбисПараметрыВложения, Результат);
			
		КонецЕсли;
		
		attachmentList.Добавить(СбисПараметрыВложения.ВложениеВПакет);
		
		Если ВложениеСБИС_Получить(Вложение, "Модифицирован") Тогда
			attachmentList_Изменены.Добавить(СбисПараметрыВложения.ВложениеВПакет);
		КонецЕсли;
		
		Если Вложение.Свойство("Подпись") Тогда //d.ch
			ЭЦП = Новый Массив;
			Для Каждого Запись из Вложение.Подпись Цикл
				ЗаписьЭЦП = Новый Структура;
				Если Запись.Свойство("Направление") Тогда
					ЗаписьЭЦП.Вставить("Направление",Запись.Направление);
				КонецЕсли;
				ФайлЭЦП = Новый Структура;
				ФайлЭЦП.Вставить( "Имя", Запись.Файл.Имя ); 
				ФайлЭЦП.Вставить( "ДвоичныеДанные", ПолучитьBASE64ПоИмениФайлаКлиент(Запись.Файл.ПолноеИмяФайла)); 
				ЗаписьЭЦП.Вставить("Файл",ФайлЭЦП);
				ЭЦП.Добавить(ЗаписьЭЦП);
			КонецЦикла;
			attachment.Вставить( "Подпись", ЭЦП );
		КонецЕсли;
		Если СбисШифрование Тогда
			Если	Вложение.Свойство("Тип")
				И	ЗначениеЗаполнено(Вложение.Тип)
				И	Вложение.Свойство("ПодТип")
				И	Вложение.Свойство("ВерсияФормата")
				И	ЗначениеЗаполнено(Вложение.ВерсияФормата) Тогда
				attachment.Вставить( "Тип",  Вложение.Тип);
				attachment.Вставить( "Подтип",  Вложение.ПодТип);
				attachment.Вставить( "ВерсияФормата",  Вложение.ВерсияФормата);
				Если	Вложение.Свойство("ПодВерсияФормата")
					И	ЗначениеЗаполнено(Вложение.ПодВерсияФормата) Тогда
					attachment.Вставить( "ПодверсияФормата",  Вложение.ПодВерсияФормата);
				КонецЕсли;
			КонецЕсли;
			Если Вложение.Свойство("Название") и ЗначениеЗаполнено(Вложение.Название) Тогда
				// для зашифрованных документов убираем сумму из названия
				ПозСуммы = Найти(Вложение.Название, "на сумму");
				Если ПозСуммы Тогда
					Вложение.Название = Лев(Вложение.Название, ПозСуммы-1);
				КонецЕсли;
				attachment.Вставить("Название",  Вложение.Название);
			КонецЕсли;
		КонецЕсли;
	КонецЦикла;
	
	Если СоставПакета.Свойство("ПользовательскийИдентификатор") 
		И (НЕ ДопПараметры.Свойство("Этап",Этап)
		ИЛИ НЕ ЗначениеЗаполнено(Этап)) Тогда
		redaction = Новый Структура;
		redaction.Вставить("ИдентификаторИС", СоставПакета.ПользовательскийИдентификатор);
		document.Вставить( "Редакция", redaction);
		documentWrite.Вставить( "Редакция", redaction);
	КонецЕсли;
	Если СоставПакета.Свойство("Примечание") и ЗначениеЗаполнено(СоставПакета.Примечание) Тогда
		document.Вставить( "Примечание", СоставПакета.Примечание);
	КонецЕсли;
	
	document.Вставить( "НашаОрганизация", СоставПакета_СтруктураОрганизацииДляОтправки(СоставПакета));
	
	Если СоставПакета.Свойство("Контрагент") Тогда
		document.Вставить("Контрагент", СоставПакета_СтруктураКонтрагентаДляОтправки(СоставПакета));
	КонецЕсли;
	
	Если СоставПакета.Свойство("Ответственный") и СоставПакета.Ответственный.Количество()>0 Тогда
		otv = Новый Структура;
		Для Каждого Элемент Из СоставПакета.Ответственный Цикл
			otv.Вставить( Элемент.Ключ, Элемент.Значение );	
		КонецЦикла;
		document.Вставить( "Ответственный", otv ); 	
	КонецЕсли;
	Если СоставПакета.Свойство("Подразделение") и СоставПакета.Подразделение.Количество()>0 Тогда
		podrazdel = Новый Структура;
		Для Каждого Элемент Из СоставПакета.Подразделение Цикл
			podrazdel.Вставить( Элемент.Ключ, Элемент.Значение );	
		КонецЦикла;
		document.Вставить( "Подразделение", podrazdel ); 	
	КонецЕсли;
	Если СоставПакета.Свойство("Регламент") и СоставПакета.Регламент.Количество()>0 Тогда
		regl = Новый Структура;
		Для Каждого Элемент Из СоставПакета.Регламент Цикл
			regl.Вставить( Элемент.Ключ, Элемент.Значение );	
		КонецЦикла;
		document.Вставить( "Регламент", regl ); 	
	КонецЕсли;
	Если СоставПакета.Свойство("ДокументОснование") и СоставПакета.ДокументОснование.Количество()>0 Тогда
		osnovania = Новый Массив;
		Для Каждого ДокОсн Из СоставПакета.ДокументОснование Цикл 
			osn = Новый Структура;
			Если ДокОсн.Свойство("ВидСвязи") Тогда
				osn.Вставить( "ВидСвязи", ДокОсн.ВидСвязи );	
			КонецЕсли;
			doc = Новый Структура;
			Для Каждого Элемент Из ДокОсн Цикл
				Если Элемент.Ключ<>"ВидСвязи" Тогда
					doc.Вставить( Элемент.Ключ, Элемент.Значение );	
				КонецЕсли;
			КонецЦикла;
			osn.Вставить( "Документ", doc );
			osnovania.Добавить(osn);
		КонецЦикла;
		document.Вставить( "ДокументОснование", osnovania ); 				
	КонецЕсли;
	Если	СоставПакета.Свойство("НеЗапускатьВДокументооборот")
		И	СоставПакета.НеЗапускатьВДокументооборот = Истина Тогда
		document.Вставить("НеЗапускатьВДокументооборот", "Да");
	КонецЕсли;
	documentWrite.Вставить("НеЗапускатьВДокументооборот", "Да");
	Если	СоставПакета.Свойство("ДопПоля") Тогда // alo ДопПоля
		DopPolya = Новый Массив;
		Для Каждого Поле Из СоставПакета.ДопПоля Цикл 
			DopPolya.Добавить(?(ТипЗнч(Поле) = Тип("Строка"), Поле, Поле.Ключ));
		КонецЦикла;
		document.Вставить( "ДопПоля", DopPolya );
	КонецЕсли;
	Если	СоставПакета.Свойство("Провести")	// alo Провести
		И	( СоставПакета.Провести = Истина или СоставПакета.Провести = "Да") Тогда
		document.Вставить("Провести", "Да");
	КонецЕсли;  
	
	Возврат Результат;
	
КонецФункции

&НаКлиенте
Функция СоставПакета_Идентификатор(СоставПакета, ДопПараметры = Неопределено) Экспорт 
	Перем ИдПакета, Статус;
	
	Если		СоставПакета.Свойство("ВременныйИдентификатор", ИдПакета) Тогда 
	ИначеЕсли  НЕ ДопПараметры = Неопределено
		И ДопПараметры.Свойство("Статус",Статус)
		И Статус = 0
		И СоставПакета.Свойство("Идентификатор",ИдПакета)
		И НЕ (ИдПакета = "" ИЛИ ИдПакета = Неопределено) Тогда 
		Возврат ИдПакета; //Вернем существующий идентификатор
	ИначеЕсли		СоставПакета.Свойство("ПользовательскийИдентификатор", ИдПакета)
			И	Не (	СоставПакета.Свойство("Контрагент")
					И	СоставПакета.Контрагент.Свойство("ЗапретРедакций")) Тогда
		ИдПакета = Сред(ИдПакета, Найти(ИдПакета,":")+1);
	Иначе
		ИдПакета = Строка(Новый УникальныйИдентификатор());
	КонецЕсли;
	Возврат ИдПакета;
	
КонецФункции

// Функция - проверяет возможность аннулирования для пакета документов 
//
// Параметры:
//  СоставПакета - Структура - документ СБИС, прочитанный от 1С
//  ДопПараметры - Структура - расширение
//                 
// Возвращаемое значение:
//   Булево - Истина - можно аннулировать, Ложь - нельзя аннулировать
//  
&НаКлиенте
Функция СоставПакета_МожноАннулировать(СоставПакета, ДопПараметры = Неопределено) Экспорт

	МассивИд = Новый Массив();
	Если СоставПакета.Свойство("Идентификатор") Тогда
		
		МассивИД.Добавить(СоставПакета.Идентификатор); 
		
	КонецЕсли;
	
	МассивИД = ПроверитьВозможностьАннулирования(МассивИД);  
	
	Если МассивИД.Количество() > 0 
		И МассивИД[0] = СоставПакета.Идентификатор  Тогда
		
		Возврат Истина;
		
	КонецЕсли; 
	Возврат Ложь;     
КонецФункции // ()

&НаКлиенте
Функция СоставПакета_Получить(СоставПакета, КлючПолучить, ДопПараметры = Неопределено) Экспорт 
	Перем ЗначениеИтог;
	
	Если		КлючПолучить = "РегламентНазвание" Тогда
		
		Если 	СоставПакета.Свойство("Регламент",	ЗначениеИтог) 
			И	ЗначениеИтог.Свойство("Название",	ЗначениеИтог) Тогда
			
			Возврат ЗначениеИтог;
			
		Иначе
			
			ЗначениеИтог = "";
			
		КонецЕсли;
		
	ИначеЕсли	КлючПолучить = "Идентификатор" Тогда
		
		Если СоставПакета.Свойство("Идентификатор",ЗначениеИтог)
			И НЕ (ЗначениеИтог = "" Или ЗначениеИтог = Неопределено) Тогда
			
			Возврат ЗначениеИтог; //Вернем существующий идентификатор
			
		Иначе	
			
			ЗначениеИтог = СоставПакета_Идентификатор(СоставПакета);
			
		КонецЕсли;
		
	ИначеЕсли КлючПолучить = "ОсновнойДокумент1С" Тогда
		
		Если	СоставПакета.Вложение.Количество()
			И	СоставПакета.Вложение[0].Свойство("Документы1С") Тогда
			ЗначениеИтог = СоставПакета.Вложение[0].Документы1С[0].Значение;
		КонецЕсли; 
		
	ИначеЕсли КлючПолучить = "СтатусГосСистемы" Тогда
		
		ЗначениеИтог = СоставПакета_СтатусГоссистемыПоПакету(СоставПакета);
		
	ИначеЕсли КлючПолучить = "ЕстьРасхождения" Тогда
		
		ЗначениеИтог = СоставПакета_РасхожденияПоПакету(СоставПакета);
		
	ИначеЕсли КлючПолучить = "ДанныеСравнения" Тогда
		
		ЗначениеИтог = СоставПакета_ДанныеСравнения(СоставПакета, ДопПараметры)
		
	ИначеЕсли КлючПолучить = "ДокументДляВложения" Тогда
		
		ЗначениеИтог = СоставПакета_ОснованиеДляВложения(СоставПакета, ДопПараметры);
		
	ИначеЕсли КлючПолучить = "Название" Тогда
		
		Если Не СоставПакета.Свойство(КлючПолучить, ЗначениеИтог) Тогда
			ЗначениеИтог = "";
			
			Если СоставПакета.Вложение.Количество() Тогда
				Документы1С = ВложениеСБИС_Получить(СоставПакета.Вложение[0], "Документы1С");
				Если ЗначениеЗаполнено(Документы1С) Тогда
					ЗначениеИтог = Строка(Документы1С[0].Значение);
				КонецЕсли;
			КонецЕсли;
			
		КонецЕсли;
		
	ИначеЕсли КлючПолучить = "Вложение" Тогда

		ЗначениеИтог = СоставПакета_НайтиВложение(СоставПакета, ДопПараметры);
		
	ИначеЕсли КлючПолучить = "Модифицирован" Тогда
		Если НЕ СоставПакета.Свойство(КлючПолучить, ЗначениеИтог) Тогда
			ЗначениеИтог = Ложь;
		КонецЕсли;
	ИначеЕсли КлючПолучить = "Грузополучатель" Тогда

		Участники = СоставПакета_Получить(СоставПакета, "Участники");
		
		Если НЕ ЗначениеЗаполнено(Участники) Тогда
			ЗначениеИтог = Неопределено;
		ИначеЕсли Найти("ЗаказИсх, ДокОтгрВх", СоставПакета_Получить(СоставПакета, "Тип")) Тогда
			Участники.Свойство("Лицо3", ЗначениеИтог);
		Иначе
			Участники.Свойство("Лицо2", ЗначениеИтог);
		КонецЕсли;
	ИначеЕсли КлючПолучить = "Параметры" Тогда
		
		Если Не СоставПакета.Свойство("Параметры") Тогда
			
			СоставПакета.Вставить("Параметры", Новый Структура);
			
		КонецЕсли;
		ЗначениеИтог = СоставПакета.Параметры;

	Иначе
		
		СоставПакета.Свойство(КлючПолучить, ЗначениеИтог);
		
	КонецЕсли;
	
	Возврат ЗначениеИтог;
	
КонецФункции

// Функция - ищет ссылку на основание 1С для выбранного вложения. 
// Для поиска в подразделе мДокумент с описанием загрузки вложения должен быть узел  ДокументОснование с тэгом Тип, Или Документ со значением искомого типа
//
// Параметры:
//  СоставПакета - СоставПакета	 - экземпляр ДокументСБИС
//  ВложениеСБИС - ВложениеСБИС	 - экземпляр вложения, для которого надо найти основание
// 
// Возвращаемое значение:
//  ДокументСсылка - Основание для вложения СБИС
//
&НаКлиенте
Функция СоставПакета_ОснованиеДляВложения(СоставПакета, ДопПараметры)
	Перем ТипИниОснование, РежимПоискаДокумента;
	
	ВложениеСБИС	= ДопПараметры.ВложениеСБИС;
	ДопПараметры.Свойство("Режим", РежимПоискаДокумента);
	ИниДок			= ВложениеСБИС_Получить(ВложениеСБИС, "УстановленныйПодразделИни");
	ТипыПоиска		= Новый Массив;
	
	Если	РежимПоискаДокумента = "Основание" Тогда
		
		// Поиск основания. Требуется определить тип.
		Если	ИниДок.Свойство("Документ_Основание", ТипИниОснование)
			И	ТипИниОснование.Свойство("Тип",	ТипИниОснование) Тогда
			
			ДокументТип = СтрЗаменить(ТипИниОснование, ",", Символы.ПС);
			
			Для НомерСтрокиТип = 1 По СтрЧислоСтрок(ДокументТип) Цикл
				
				ТипОснованияПоиск = СсылочныйТипСтрокой(СтрПолучитьСтроку(ДокументТип, НомерСтрокиТип));
				ТипыПоиска.Добавить(ТипОснованияПоиск);
				
			КонецЦикла;
			
		КонецЕсли;
		
	ИначеЕсли ИниДок.Свойство("Документ") Тогда
		
		// Режим не поиск основания, значит ищем основной документ
		ДокументТип = СтроковоеЗначениеУзлаИни(ИниДок.Документ, Новый Структура("ИмяРеквизита", Истина));
		ТипыПоиска.Добавить(ДокументТип);
		
	Иначе
		
		//Нет узлов с описанием типов для поиска оснований
		Возврат Неопределено;
		
	КонецЕсли;
	
	//Заполнить список документов по всем вложениям
	ОбщийНаборОснований = Новый СписокЗначений;
	Для Каждого ВложениеСБИСПакета Из СоставПакета.Вложение Цикл
		
		//Если ВложениеСБИС_Получить(ВложениеСБИС, "Идентификатор") = ВложениеСБИС_Получить(ВложениеСБИСПакета, "Идентификатор") Тогда
		//	
		//	//Текущее вложение не проверяем
		//	Продолжить;
		//	
		//КонецЕсли;
		
		Документы1С = ВложениеСБИС_Получить(ВложениеСБИСПакета, "Документы1С");
		Если ЗначениеЗаполнено(Документы1С) Тогда 
			
			Для Каждого Ссылка1С Из Документы1С Цикл
				
				ОбщийНаборОснований.Добавить(Ссылка1С.Значение);
				
			КонецЦикла;
			
		КонецЕсли;
		
	КонецЦикла;
	
	//Пока подбор только по типу.
	РезультатПоиска = ВыбратьДокументыПоТипамВызовСервера(ОбщийНаборОснований, ТипыПоиска);
	Для Каждого ТипПоиска Из ТипыПоиска Цикл
		
		Если ЗначениеЗаполнено(РезультатПоиска.Получить(ТипПоиска)) Тогда
			Возврат РезультатПоиска.Получить(ТипПоиска)[0];
		КонецЕсли;
		
	КонецЦикла;
		
	Возврат Неопределено
	
КонецФункции

&НаКлиенте
Функция СоставПакета_РасхожденияПоПакету(СоставПакета) 
	
	Перем СбисРасширение, Расхождение;  
	
	Возврат СоставПакета.Свойство("Расширение", СбисРасширение) 
		И СбисРасширение.Свойство("ЕстьРасхождения",Расхождение) 
		И Расхождение = "Да";
		
КонецФункции

// Функция возвращает статус из госсистем по состоянию или коду
//
// Параметры:
//  СоставПакета - Структура - Обрабатываемый пакет (Документ)
// 
// Возвращаемое значение:
//  Строка - Статус документа в госсистеме
//
&НаКлиенте
Функция СоставПакета_СтатусГоссистемыПоПакету(СоставПакета) 
	
	Перем СбисРасширение, СтатусГос;  
	
	Кэш = ГлавноеОкно.Кэш;
	
	Если	СоставПакета.Свойство("Расширение",	СбисРасширение) Тогда
		Если	СбисРасширение.Свойство("СостояниеМарк",СтатусГос)
			И	СтатусГос.Свойство("СостояниеОперации",			СтатусГос) Тогда 				
		//Прослеживаемой и маркируемой продукции, у одном документе, быть не может
		ИначеЕсли СбисРасширение.Свойство("СостояниеПросл",СтатусГос) 
			И СтатусГос.Свойство("КодСостоянияОперации", СтатусГос) Тогда 
			СтатусГос = Кэш.ОбщиеФункции.СостояниеПрослеживаемостиПоКоду(СтатусГос);; 
		Иначе
			СтатусГос = "";
		КонецЕсли; 	
	Иначе
		СтатусГос = "";	
	КонецЕсли; 
	
	Возврат СтатусГос;
	
КонецФункции

&НаКлиенте
Функция СоставПакета_ДанныеСравнения(СоставПакета, ДопПараметры)
	Перем ИдентификаторыВыбрать, СтруктураИниФайла, СтруктураФайла, мДокументы;
	
	СоответствиеРезультат	= Новый Соответствие;
	ДопПараметрыПОдготовить	= Новый Структура("СоставПакета", СоставПакета);
	ЛокальныйКэш			= ПолучитьТекущийЛокальныйКэш();
	ФункцииДокументов		= ПолучитьЗначениеПараметраТекущегоСеанса("ФункцииДокументов");
	
	Если ДопПараметры.Свойство("ИдВложения") Тогда
		
		//Если расхождение не по всем вложениям пакета, а по конкретному Вложению
		ИдентификаторыВыбрать = Новый Массив;
		ИдентификаторыВыбрать.Добавить(ДопПараметры.ИдВложения);
		ДопПараметрыПОдготовить.Вставить("Документ1С", ДопПараметры.Документ1С);
		
	КонецЕсли;
	
	Для Каждого Вложение Из СоставПакета.Вложение Цикл
		
		ИдентификаторВложения	= ВложениеСБИС_Получить(Вложение, "Идентификатор");
		НазваниеВложения		= ВложениеСБИС_Получить(Вложение, "Название");
		Если	Не	ИдентификаторыВыбрать = Неопределено
			И	Не	(		Вложение.Свойство("Идентификатор")
					И	Не	ИдентификаторыВыбрать.Найти(Вложение.Идентификатор) = Неопределено) Тогда
			
			Продолжить;
			
		КонецЕсли;
		
		//разобрать и дозаполнить
		ДопПараметрыРазобрать = Новый ФиксированнаяСтруктура("СоставПакета", СоставПакета);
		ВложениеСБИС_РазобратьДляЗагрузки(Вложение, ДопПараметрыРазобрать);
		
		Если Не	Вложение.Свойство("ИмяИни") Тогда
			
			ВызватьСбисИсключение(,	"МодульОбъектаКлиент.ПодготовитьСтруктуруДокументаДляРасхожденийДляРеестраСБИС",
									735,,"Отсутствует файл настроек для обработки документа СБИС.",
									Новый Структура("ИдВложения,Название", ИдентификаторВложения, НазваниеВложения));
									
		ИначеЕсли	Не Вложение.Свойство("СтруктураИниФайла",	СтруктураИниФайла)
				Или	Не Вложение.Свойство("СтруктураФайла",		СтруктураФайла)
				Или	Не ЗначениеЗаполнено(СтруктураИниФайла) Тогда
				
			ВызватьСбисИсключение(,	"МодульОбъектаКлиент.ПодготовитьСтруктуруДокументаДляРасхожденийДляРеестраСБИС",
									735,,"Проверка документа не поддерживается.");
									
		КонецЕсли;
								
		ИниВложение = ИниПоПараметрам(Вложение.ИмяИни);
		
		Если Не ИниВложение.Свойство("мДокумент", мДокументы) Тогда
			
			ВызватьСбисИсключение(,	"МодульОбъектаКлиент.ПодготовитьСтруктуруДокументаДляРасхожденийДляРеестраСБИС",
									735,,"В файле настроек " + Вложение.ИмяИни + " отсутствует описание мДокумент.");
									
		КонецЕсли;
		
		//ВложениеПоДанным1С	= НовыйВложениеСБИС(Вложение,  );
		//СтруктураФайлаСБИС	= ВложениеСБИС_Получить(Вложение,			"СтруктураФайла");
		//СтруктураФайла1С	= ВложениеСБИС_Получить(ВложениеПоДанным1С, "СтруктураДокумента");
		//
		//СтруктураДокументаПоДаннымСбис	= СтруктураФайлаСБИС.Файл.Документ;
		//СтруктураДокументаПоДанным1С	= СтруктураФайла1С.Файл.Документ;
		ДопПараметрыПОдготовить.Вставить("Вложение", Вложение);

		СтруктураДокументаПоДаннымСбис	= Вложение.СтруктураФайла.Файл.Документ;
		СтруктураДокументаПоДанным1С	= ПолучитьСтруктуруДокумента1СПоПакетуСбис(ДопПараметрыПОдготовить, Новый Структура);
				
		
		ИнформацияОДокументах	= Новый Структура("Формат, Версия", Вложение.ФорматДляЗагрузки, Вложение.ВерсияФорматаДляЗагрузки);
		РезультатДетализации	= Новый Структура("СтруктураДокументаПоДаннымСбис, СтруктураДокументаПоДанным1С, ИнформацияОДокументах");
		РезультатДетализации.СтруктураДокументаПоДаннымСбис	= СтруктураДокументаПоДаннымСбис;
		РезультатДетализации.СтруктураДокументаПоДанным1С	= СтруктураДокументаПоДанным1С;
		РезультатДетализации.ИнформацияОДокументах			= ИнформацияОДокументах;
		
		Если Вложение.Свойство("НастройкаПроверкаРасхождения") Тогда
			
			РезультатДетализации.Вставить("ИмяИниДельты", Вложение.НастройкаПроверкаРасхождения);
			
		КонецЕсли;
		
		СоответствиеРезультат.Вставить(ДопПараметры.КлючДетализации, РезультатДетализации);	
		
	КонецЦикла;
	Возврат СоответствиеРезультат

КонецФункции
	
&НаКлиенте
Функция СоставПакета_ПолучитьДанныеСторонИзПакета(СоставПакета, ДопПараметры = Неопределено) Экспорт
	
	ДанныеСторон = СоставПакета_Получить(СоставПакета, "ДанныеСторон");
	
	Если НЕ ДанныеСторон = Неопределено Тогда
		
		Возврат ДанныеСторон;
		
	КонецЕсли;
		
	ОрганизациияДокумента		= СоставПакета_Получить(СоставПакета, "НашаОрганизация");
    КонтрагентДокумента 		= СоставПакета_Получить(СоставПакета, "Контрагент"); 
	ГрузополучательДокумента	= СоставПакета_Получить(СоставПакета, "Грузополучатель");
	
	ОбщиеФункции = ПолучитьЗначениеПараметраТекущегоСеанса("ФункцииДокументов");
	
	ДанныеКонтрагента		= Новый Структура("Сторона, Данные, Ссылка");
	ДанныеОрганизации		= Новый Структура("Сторона, Данные, Ссылка");
	ДанныеГрузополучателя	= Новый Структура("Сторона, Данные, Ссылка");
	
	Если ЗначениеЗаполнено(ОрганизациияДокумента) Тогда
		
		ДанныеОрганизации.Сторона	= ОбщиеФункции.СбисСкопироватьОбъектНаКлиенте(ОрганизациияДокумента);
		ДанныеОрганизации.Данные	= Сторона_Выгрузить(ОрганизациияДокумента);
		
	КонецЕсли;

	Если ЗначениеЗаполнено(КонтрагентДокумента) Тогда
		
		ДанныеКонтрагента.Сторона	= ОбщиеФункции.СбисСкопироватьОбъектНаКлиенте(КонтрагентДокумента);
		ДанныеКонтрагента.Данные	= Сторона_Выгрузить(КонтрагентДокумента);

	КонецЕсли;

	Если ЗначениеЗаполнено(ГрузополучательДокумента) Тогда
		
		ДанныеГрузополучателя.Сторона	= ОбщиеФункции.СбисСкопироватьОбъектНаКлиенте(ГрузополучательДокумента);
		ДанныеГрузополучателя.Данные	= Сторона_Выгрузить(ГрузополучательДокумента);
		
	КонецЕсли;

	ДанныеСторон = Новый Структура;
	ДанныеСторон.Вставить("ДанныеКонтрагента",		ДанныеКонтрагента);
	ДанныеСторон.Вставить("ДанныеОрганизации",		ДанныеОрганизации);
	ДанныеСторон.Вставить("ДанныеГрузополучателя",	ДанныеГрузополучателя);
	
	ОбогатитьСсылкиСторонПоКлючам(ДанныеСторон);

	СоставПакета.Вставить("ДанныеСторон", ДанныеСторон);
	
	Возврат ДанныеСторон;

КонецФункции

&НаКлиенте
Процедура СоставПакета_РазобратьДляЗагрузки(СоставПакета, ДопПараметры) Экспорт
	Перем ВложенияРазобрать, ИмяРеквизитаВложений, ДанныеШапки;

	Если	Не ДопПараметры.Свойство("ИмяРеквизитаВложений", ИмяРеквизитаВложений)
		ИЛИ НЕ ЗначениеЗаполнено(ИмяРеквизитаВложений) Тогда
				
		ИмяРеквизитаВложений = "Вложение";
		
	КонецЕсли;
	
	Если Не СоставПакета.Свойство(ИмяРеквизитаВложений, ВложенияРазобрать) Тогда
		
		СообщениеОшибки = "В документе " + СоставПакета_Получить(СоставПакета, "Название") + "  отсутствуют вложения необходимого типа.";
		ДампОшибки		= Новый Структура("ИмяРеквизитаВложений", ИмяРеквизитаВложений);
		ОшибкаРазбораПакета = НовыйСбисИсключение(726, "МодульОбъектаКлиент.СоставПакета_РазобратьДляЗагрузки",,,СообщениеОшибки, ДампОшибки);
		ВызватьИсключение СбисИсключение_Представление(ОшибкаРазбораПакета);
		
	КонецЕсли;
	
	ПараметрыРазбора = Новый Структура;
	ПараметрыРазбора.Вставить("СоставПакета", СоставПакета);
	
	Если ДопПараметры.Свойство("Просмотр", ДанныеШапки) И ДанныеШапки = Истина Тогда
		
		ПараметрыРазбора.Вставить("Просмотр", ДанныеШапки);
		СоставПакета.Вставить("Просмотр", Новый Структура);
		
	КонецЕсли;
	
	СоставПакета_ПолучитьДанныеСторонИзПакета(СоставПакета);
	
	//Пока оставить костыль ЕстьОшибкиРасшифровки, надо переделать расшифровку файлов на нормальный проброс ошибок
	ПолучитьТекущийЛокальныйКэш().Вставить("ЕстьОшибкиРасшифровки", Ложь);
	
	Для Каждого ВложениеСБИС Из ВложенияРазобрать Цикл
		
		ВложениеСБИС_РазобратьДляЗагрузки(ВложениеСБИС, ПараметрыРазбора);
				
	КонецЦикла;
	
	ПолучитьТекущийЛокальныйКэш().Удалить("ЕстьОшибкиРасшифровки");
	
КонецПроцедуры

// Процедура - записывает текущий состав пакета в СБИС
//
// Параметры:
//  СоставПакета - СоставПакета	 - экземпляр Документ СБИС
//  ДопПараметры - Структура	 - Расширение
//		ЗапуститьДокументооборот - Булево - (Н)(False) определяет - сохранить документ (как черновик, если до того запись не выполнялась), или сделать запись с запуском ДО. 
// 
&НаКлиенте
Процедура СоставПакета_Записать(СоставПакета, ДопПараметры) Экспорт 
	Перем ОбработчикРезультата;

	//UAAЧерновик Удалить!
	НеЗапускатьВДокументооборот = Истина;
	Если ДопПараметры.Свойство("ЗапуститьДокументооборот") Тогда
		
		НеЗапускатьВДокументооборот = Не ДопПараметры.ЗапуститьДокументооборот;
		
	КонецЕсли;
	НеЗапускатьВДокументооборотБыло = СоставПакета_Получить(СоставПакета, "НеЗапускатьВДокументооборот");
	
	СоставПакета.Вставить("НеЗапускатьВДокументооборот", НеЗапускатьВДокументооборот);
	
	МассивГотовыхПакетов = Новый Массив;
	МассивГотовыхПакетов.Добавить(СоставПакета);
	
	СтрокаДобавить = Новый Структура("МассивПодготовленныхПакетов", МассивГотовыхПакетов); 

	МассивПакетов = Новый Массив;
	МассивПакетов.Добавить(СтрокаДобавить);
	
	Если Не ДопПараметры.Свойство("ОбработчикРезультата", ОбработчикРезультата) Тогда
		
		НовДопПараметры = Новый Структура("СоставПакета, НеЗапускатьВДокументооборотБыло", СоставПакета, НеЗапускатьВДокументооборотБыло);
		ОбработчикРезультата = НовыйСбисОписаниеОповещения("СоставПакета_Записать_Завершить", МодульОбъектаКлиент(), НовДопПараметры);
		
	КонецЕсли;
	ПараметрыДополнительно = Новый Структура("ОбработчикРезультата", ОбработчикРезультата);
		
	ЗапуститьМассовуюОтправкуДокументов(МассивПакетов, ПараметрыДополнительно);
	
КонецПроцедуры
	
// Процедура - дефолтный обработчик завершения записи состава пакета, который просто сообщит о результате
//
// Параметры:
//  РезультатЗаписи	 - РезультатОтправки	 - итог отправки документа
//  ДопПараметры	 - Структура	 - расширение
//
&НаКлиенте
Процедура СоставПакета_Записать_Завершить(РезультатЗаписи, ДопПараметры = Неопределено) Экспорт

	Если ДопПараметры = Неопределено Тогда 
		ДопПараметры = Новый Структура;
	КонецЕсли;
	
	Если ДопПараметры.Свойство("НеЗапускатьВДокументооборотБыло")
		И ДопПараметры.Свойство("СоставПакета") Тогда
		ДопПараметры.СоставПакета.Вставить("НеЗапускатьВДокументооборот", ДопПараметры.НеЗапускатьВДокументооборотБыло);
	КонецЕсли;
	
	//UAAЧерновик Удалить!
	Если РезультатЗаписи.Отправлено Тогда
		СбисСообщить("Успешно выполнено");
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура СоставПакета_Обновить(СоставПакета, Изменения) Экспорт

	Если Изменения.Свойство("Номенклатура") Тогда
		
		СоставПакета_ОбновитьНоменклатуру(СоставПакета, Изменения);
		СоставПакета.Вставить("ПерегенерироватьВложения", Ложь);
		
	КонецЕсли;

	Если Изменения.Свойство("Вложения") Тогда
		СоставПакета_ОбновитьВложения(СоставПакета, Изменения.Вложения);
	КонецЕсли;
	
	Если Изменения.Свойство("ДопПоля") Тогда
		СоставПакета_ДополнитьПолями(СоставПакета, Изменения.ДопПоля);
	КонецЕсли;

	Если Изменения.Свойство("Параметры") Тогда
		
		ПараметрыПакета = СоставПакета_Получить(СоставПакета, "Параметры");
		Для Каждого ПараметрИзменить Из Изменения.Параметры Цикл
			
			ПараметрыПакета.Вставить(ПараметрИзменить.Ключ, ПараметрИзменить.Значение);
			
		КонецЦикла;
		
	КонецЕсли;
	
	Если Изменения.Свойство("Сторона") Тогда
		СоставПакета_ОбновитьСторону(СоставПакета, Изменения.Сторона);
	КонецЕсли;

	СоставПакета.Вставить("Модифицирован", СоставПакета_Модифицирован(СоставПакета));

КонецПроцедуры

#Область include_core2_vo2_Модуль_МодульОбъектаКлиент_Отправка_СоставПакета_private
#КонецОбласти

