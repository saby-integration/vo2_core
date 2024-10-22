 
// Процедура - патчит пакеты документов для передачи в форму просмотра 
//
// Параметры:
//  МассивПакетов		- Массив - пакеты для дозаполнения
//  ДопПараметры		- Структура - дополнительные параметры
//
&НаКлиенте
Процедура ПодготовитьДокументСбисКПросмотру(МассивПакетов,ДопПараметры) Экспорт
	
	ТекущийРаздел = ДопПараметры.ТекущийРаздел; 
		
	Если ТекущийРаздел = "Продажа" Тогда
		ПодготовитьДокументСбисВРазделеПродажа(МассивПакетов, ДопПараметры);
	ИначеЕсли ТекущийРаздел = "Полученные" Тогда
		ПодготовитьДокументСбисВРазделеПолученные(МассивПакетов, ДопПараметры);	
	Иначе
		Возврат;
	КонецЕсли;		

КонецПроцедуры	

&НаКлиенте
Процедура ДополнитьПолныйСоставПакетаДаннымиОнлайна(ПолныйСоставПакета, РезультатЧтенияПоИд)
	
	Если ТипЗнч(РезультатЧтенияПоИд) <> Тип("Структура") Тогда
		Возврат;
	КонецЕсли;
	
	ДопПоля = "Расширение,
		|РеализацияЕИС,
		|Идентификатор,
		|Состояние";
	
		Если ПолучитьЗначениеПараметраСбис("ПоддержкаОбменаЕИС")
			И РезультатЧтенияПоИд.Свойство("ДокументОснование") Тогда
		ДопПоля = ДопПоля + ",
			|ДокументОснование";
	КонецЕсли;
	
	Если РезультатЧтенияПоИд.Свойство("Событие") Тогда
		ДопПоля = ДопПоля + ",
			|Событие";
	КонецЕсли;
	
	Изменения = Новый Структура(ДопПоля);
	ЗаполнитьЗначенияСвойств(Изменения, РезультатЧтенияПоИд);
	
	СоставПакета_Обновить(ПолныйСоставПакета, Новый Структура("ДопПоля", Изменения));
	
	ДопПоляВложений = Новый Массив;
	ДопПоляВложений.Добавить("Идентификатор");
	
	Для каждого СБИСВложение Из РезультатЧтенияПоИд.Вложение Цикл
		
		ПараметрыПоиска = Новый Структура("Тип, Номер, ПодТип, ВерсияФормата");
		ЗаполнитьЗначенияСвойств(ПараметрыПоиска, СБИСВложение);
		ПараметрыПоиска.Вставить("Дата", Формат(СБИСВложение.Дата, "ДФ=dd.MM.yyyy"));
		ВложениеИз1С = СоставПакета_Получить(ПолныйСоставПакета, "Вложение", ПараметрыПоиска);
		
		Если ВложениеИз1С = Неопределено Тогда
			Продолжить;
		КонецЕсли;
		
		Для каждого Поле Из ДопПоляВложений Цикл
			ВложениеИз1С.Вставить(Поле, СБИСВложение[Поле]);
		КонецЦикла;
	
	КонецЦикла;
	
КонецПроцедуры

&НаКлиенте
Процедура ПодготовитьДокументСбисВРазделеПродажа(МассивПакетов, ДопПараметры)

	Перем СсылкаНаПервоеВложение, Вложения;
	
	Кэш = ГлавноеОкно.Кэш; 
	ПолныйСоставПакета = МассивПакетов;
	
	Если ДопПараметры.Свойство("Вложения", Вложения)		
		И Вложения[0].Свойство("Документы1С", СсылкаНаПервоеВложение)
		И	СсылкаНаПервоеВложение.Количество() Тогда
		
		СсылкаНаПервоеВложение = СсылкаНаПервоеВложение[0].Значение;
		Отказ = Ложь;
		ДопПараметрыПолученияИдСБИС = Новый Структура("СоставПакета", ПолныйСоставПакета);
		ПараметрыПакетаСБИС	= Кэш.ОбщиеФункции.ИдентификаторСБИСПоДокументу(Кэш, СсылкаНаПервоеВложение, ДопПараметрыПолученияИдСБИС);
		ИдДок				= ПараметрыПакетаСБИС.ИдДокумента;
		Если ЗначениеЗаполнено(ИдДок) Тогда
			ДопПоля = МодульОбъектаКлиент().СоставПакета_Получить(ПолныйСоставПакета, "ДопПоля");
			РеализацияЕИС = ?(ТипЗнч(ДопПоля) = Тип("Массив"), ДопПоля.Найти("ЕИС") <> Неопределено, Ложь);
			ДопПараметры = Новый Структура("СообщатьПриОшибке, ВернутьОшибку, РеализацияЕИС", Ложь, Истина, РеализацияЕИС);
			РезультатЧтенияПоИд = Кэш.Интеграция.ПрочитатьДокумент(Кэш, ИдДок, ДопПараметры, Отказ);
			Если Не Отказ Тогда
				ДополнитьПолныйСоставПакетаДаннымиОнлайна(ПолныйСоставПакета, РезультатЧтенияПоИд);
			КонецЕсли;
		КонецЕсли;
	КонецЕсли;
	Для Каждого Элемент Из Вложения Цикл
		Если ЗначениеЗаполнено(Элемент.XMLДокумента) Тогда
			ТекстHTML = Кэш.Интеграция.ПолучитьHTMLПоXML(Кэш, Элемент);
		Иначе
			ТекстHTML = "";
		КонецЕсли;
		Элемент.Вставить("ТекстHTML", ТекстHTML);
	КонецЦикла; 
	
КонецПроцедуры 

&НаКлиенте
Процедура ПодготовитьДокументСбисВРазделеПолученные(МассивПакетов,ДопПараметры)
	
	Кэш = ГлавноеОкно.Кэш; 
	ПолныйСоставПакета = МассивПакетов;     
	
	ПолныйСоставПакета.Параметры.Вставить("ЕстьАннулирование", Ложь);
	
	сч = 0;
	Для Каждого Элемент Из ПолныйСоставПакета.Вложение Цикл

		Если ПолныйСоставПакета.Свойство("Событие") Тогда
			Элемент.Вставить("Событие", ПолныйСоставПакета.Событие);
		КонецЕсли;

		ТекстHTML = Кэш.Интеграция.ПолучитьHTMLВложения(Кэш, ПолныйСоставПакета.Идентификатор, Элемент);
		ПолныйСоставПакета.Вложение[сч].Вставить("ТекстHTML", ТекстHTML);
		ПолныйСоставПакета.Вложение[сч].Вставить("Отмечен", Истина);
		сч = сч + 1;

	КонецЦикла;
	
КонецПроцедуры

