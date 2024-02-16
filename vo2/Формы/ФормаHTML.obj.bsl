
&НаКлиенте
Перем МестныйКэш Экспорт;

#Область include_local_ПолучитьМодульОбъекта
#КонецОбласти

//author UAA, VII

///////////////////////////////////////////////////
///////////////////////События/////////////////////
///////////////////////////////////////////////////

//При открытии документа на форме просмотра авторизуемся по токену текущей сессии обработки
&НаКлиенте
Процедура ПриОткрытии(Отказ)
	Токен = МестныйКэш.Интеграция.ПолучитьТикетДляТекущегоПользователя(МестныйКэш);
	АдресHTML = Адрес + "&ticket=" + Токен + "&nocheck=1";
КонецПроцедуры

///////////////////////////////////////////////////
///////////////////////Команды/////////////////////
///////////////////////////////////////////////////

//Запускаем выгрузку текущего документа в 1С
&НаКлиенте
Процедура ВыгрузитьВ1С(Команда)
	Отказ = Ложь;	
	Если Не ЗначениеЗаполнено(ИмяСБИС) Тогда
		ПараметрыСообщить = Новый Структура("Текст", "Загрузка документов не подерживается.");
		МодульОбъектаКлиент().СбисСообщить(ПараметрыСообщить);
		Возврат;
	ИначеЕсли Не СбисДоступныАпи3Объекты(МестныйКэш) Тогда
		ПараметрыСообщить = Новый Структура("Текст", "Загрузка документов не подерживается. Необходимо выбрать способ обмена 'API' и способ храниения настроек 'На сервере'");
		МодульОбъектаКлиент().СбисСообщить(ПараметрыСообщить);
		Возврат;
	КонецЕсли;
	Если ИменаСбисКАпи3.Свойство(ИмяСБИС) Тогда
		ИмяСБИС = ИменаСбисКАпи3[ИмяСБИС];
	КонецЕсли;
	Если Не (ИмяСБИС = "АвансовыйОтчет" Или ИмяСБИС = "Задача") Тогда 
		ПараметрыСообщить = Новый Структура("Текст", "Загрузка данного типа документов не поддерживается.");
		МодульОбъектаКлиент().СбисСообщить(ПараметрыСообщить);
		Возврат;
	КонецЕсли;
		
	СтруктураСинхОбъекта = Новый Структура("Data,Type,SbisId,Id,Action", Новый Структура, ИмяСБИС, ИдСБИС, ИдСБИС, 2);
    МассивСинхОбъектов = Новый Массив;
    МассивСинхОбъектов.Добавить(СтруктураСинхОбъекта);
    СтруктураСинхДокумента = Новый Структура("ConnectionId,ExtSyncDoc,ExtSyncObj", ИдентификаторПодключения, Новый Структура("Direction", Число(0)), МассивСинхОбъектов);
	
	// Выполянем Write, Prepare на сервисе 
	ИдентификаторПосылки = МодульОбъектаКлиент().ЗаписатьПосылкуСОбъектами(СтруктураСинхДокумента, Отказ);
	Если Отказ Тогда
		МестныйКэш.ГлавноеОкно.СбисСообщитьОбОшибке(МестныйКэш, ИдентификаторПосылки);
		Возврат;
	КонецЕсли;
	
	РезультатПодготовки = МодульОбъектаКлиент().ПодготовитьПосылкуПорционно(ИдентификаторПосылки, Отказ);
	Если Отказ Тогда
		МестныйКэш.ГлавноеОкно.СбисСообщитьОбОшибке(МестныйКэш, РезультатПодготовки);
		Возврат;
	КонецЕсли;
	
    РезультатЗагрузки = МодульОбъектаКлиент().ЗагрузитьПосылку(ИдентификаторПосылки, Отказ);
	Если Отказ Тогда
		МодульОбъектаКлиент().СообщитьСбисИсключение(РезультатЗагрузки);
		Возврат;
	КонецЕсли;
	Для Каждого ОбъектСОшибкой Из РезультатЗагрузки.Ошибки Цикл
		СтруктураОшибки = ОбъектСОшибкой.Data.error;
		Если СтруктураОшибки.code = 610 Тогда
			СтруктураОшибки.message = "Загрузка документов " + ОбъектСОшибкой.Data.data.ИмяСБИС + " не подерживается";
			СтруктураОшибки.details = СтруктураОшибки.message;
		КонецЕсли;
		МодульОбъектаКлиент().СообщитьСбисИсключение(СтруктураОшибки, Новый Структура("СтатусСообщения, Отправлять, ФормаВладелец", "message", Ложь, ЭтаФорма));
	КонецЦикла;
	ЗаполнитьСсылкуДокумента1С(МестныйКэш);
	Если РезультатЗагрузки.Ошибки.Количество() Тогда
		ПараметрыСообщить = Новый Структура("Текст", "Загрузка завершена с ошибками");
	Иначе
		ПараметрыСообщить = Новый Структура("Текст", "Загрузка завершена успешно. Обработано " + РезультатЗагрузки.Успешно.Количество() + " объектов");
	КонецЕсли;
	МодульОбъектаКлиент().СбисСообщить(ПараметрыСообщить);
КонецПроцедуры

&НаКлиенте
Процедура ЗагрузитьВСБИС(Команда)
	Если Не СбисДоступныАпи3Объекты(МестныйКэш) Тогда
		Сообщить("Загрузка документов не подерживается. Необходимо выбрать способ обмена 'API' и способ храниения настроек 'На сервере'");
		Возврат;
	КонецЕсли;
	Если ДокументСсылка = Неопределено Тогда
		Сообщить("Отсутствует связанный документ 1С");
		Возврат;
	КонецЕсли;
	Если ИменаСбисКАпи3.Свойство(ИмяСБИС) Тогда
		ИмяСБИС = ИменаСбисКАпи3[ИмяСБИС];
	КонецЕсли;
	Если ИмяСБИС <> "АвансовыйОтчет" Тогда 
		Сообщить("Выгрузка данного типа документов не поддерживается.");
		Возврат;
	КонецЕсли;
	
	Отказ = Ложь;	
	ПараметрыЗагрузки = Новый Структура("Ссылка, ИмяСБИС, ИдСБИС", ДокументСсылка, ИмяСБИС, ИдСБИС);
	РезультатЗагрузки = ВыполнитьЗагрузкуВСБИС(МестныйКэш, ПараметрыЗагрузки, Отказ);
	Если Отказ Тогда
		Сообщить("Выгрузка завершено с ошибками");
		МестныйКэш.ГлавноеОкно.СбисСообщитьОбОшибке(МестныйКэш, РезультатЗагрузки);
	КонецЕсли;
	ВыполнитьОбновлениеОтображения(МестныйКэш);
КонецПроцедуры

//Обновление страницы с документом на форме.
&НаКлиенте
Процедура ОбновитьСтраницу(Команда)
	ВыполнитьОбновлениеОтображения(МестныйКэш);
КонецПроцедуры

//Открытие ранее загруженного документа в 1С 	
&НаКлиенте
Процедура ОткрытьВ1С(Команда)
	Если ДокументСсылка = Неопределено Тогда
		Сообщить("Отсутствует связанный документ 1С");
		Возврат;
	КонецЕсли;
	МестныйКэш.ГлавноеОкно.СбисПоказатьЗначение(МестныйКэш, ДокументСсылка); 
КонецПроцедуры

///////////////////////////////////////////////////
///////////////////////Вызовы//////////////////////
///////////////////////////////////////////////////

//Делает обновление страницы
&НаКлиенте
Процедура ВыполнитьОбновлениеОтображения(Кэш)
	Если АдресHTML = Адрес + "&nocheck=1" Тогда
		АдресHTML = Адрес + "&nocheck=1&a=1"
	Иначе
		АдресHTML = Адрес + "&nocheck=1";
	КонецЕсли
КонецПроцедуры

//Делает загрузку в СБИС по параметрам
&НаКлиенте
Функция ВыполнитьЗагрузкуВСБИС(Кэш, ПараметрыЗагрузки, Отказ)                                                                             
	ПараметрыЧтения = Новый Структура("ИдСБИС, ИмяСБИС", ПараметрыЗагрузки.ИдСБИС, ПараметрыЗагрузки.ИмяСБИС);
	СтруктураДокумента = МодульОбъектаКлиент().ПрочитатьАПИОбъектСБИС(ПараметрыЧтения, Отказ);
	Если Отказ Тогда
	    Возврат Кэш.ОбщиеФункции.СбисИсключение(СтруктураДокумента, "ФормаHTML.ВыполнитьЗагрузкуВСБИС");	
	КонецЕсли;
	
	СтруктураОбъекта = Кэш.ОбщиеФункции.СбисПолучитьСтруктуруОбъекта1С(ПараметрыЗагрузки.Ссылка, СтруктураДокумента, Отказ);
	Если Отказ Тогда
	    Возврат Кэш.ОбщиеФункции.СбисИсключение(СтруктураОбъекта, "ФормаHTML.ВыполнитьЗагрузкуВСБИС");	
	КонецЕсли;
	
	ПараметрыОбновления = Новый Структура("СтруктураОбъекта, ИмяИни, Статус", СтруктураОбъекта, "СинхВыгрузка_АвансовыйОтчет", "Обработан");
	УИДЗаписиДокумента = МодульОбъектаКлиент().ОбновитьОбъектСБИСИзОбъекта1С(ПараметрыОбновления, Новый Структура("Отказ", Отказ));
	РезультатОбновления = МодульОбъектаКлиент().ЗавершитьОбновитьОбъектСБИСИзОбъекта1С(УИДЗаписиДокумента, Отказ);
	Если Отказ Тогда
	    РезультатОбновления = Кэш.ОбщиеФункции.СбисИсключение(РезультатОбновления, "ФормаHTML.ВыполнитьЗагрузкуВСБИС");	
	КонецЕсли;
	Возврат РезультатОбновления;
КонецФункции

//Процедура открывает форму просмотра пакета документов	
&НаКлиенте
Процедура ПоказатьДокументОнлайн(Кэш, ВебАдрес, Пакет) Экспорт
	МестныйКэш = Кэш;
	ИдентификаторПодключения = МестныйКэш.Парам.ИдентификаторНастроек;
	УИдСБИС = Пакет.Идентификатор;
	Пакет.Свойство("ИдСБИС", ИдСБИС);
	Пакет.Свойство("ИмяСБИС", ИмяСБИС);
	Адрес = СтрЗаменить(СтрЗаменить(ВебАдрес, "6343037#", ""), "4490677#", "");
	ИменаСбисКАпи3 = Новый Структура("ДоговорДок,ДокОтгрВх,ДокОтгрИсх,ВнутрПрм,АвансОтчет", "Договор", "Поступление", "Реализация", "ВнутреннееПеремещение", "АвансовыйОтчет");
	ЗаполнитьСсылкуДокумента1С(Кэш);
	Если Пакет.Свойство("Название") Тогда
		Заголовок = Пакет.Название;
	Иначе
		Заголовок = Адрес;
	КонецЕсли;
	ЭтаФорма.Открыть();	
КонецПроцедуры

//Находим ссылку на документ 1С по иденитфикатору пакета	
&НаКлиенте
Процедура ЗаполнитьСсылкуДокумента1С(Кэш) Экспорт
	Перем СбисИдАккаунта;
	фрм = Кэш.ГлавноеОкно.СбисНайтиФормуФункции("ДокументыПоИдПакета", Кэш.ФормаРаботыСоСтатусами,"",Кэш);
	МассивСсылок = фрм.ДокументыПоИдПакета(УИдСБИС, Кэш.Ини.Конфигурация);
	ДокументСсылка = Неопределено;
	Если МассивСсылок.Количество() = 1 Тогда
		ДокументСсылка = МассивСсылок[0];
	ИначеЕсли МассивСсылок.Количество() > 1 Тогда
		Кэш.СБИС.ПараметрыИнтеграции.Свойство("ИдАккаунта", СбисИдАккаунта);
		СтруктураСвойств = Новый Структура("ДокументСБИС_Ид,ДокументСБИС_ИдВложения,ДокументСБИС_Статус", УИдСБИС, УИдСБИС, "");
		фрм = Кэш.ГлавноеОкно.сбисНайтиФормуФункции("ЗаписатьПараметрыДокументаСБИС",Кэш.ФормаРаботыСоСтатусами,"",Кэш);
		Для Каждого ОбъектСсылка из МассивСсылок Цикл
			фрм.ЗаписатьПараметрыДокументаСБИС(СтруктураСвойств, ОбъектСсылка, Кэш.Ини.Конфигурация, Кэш.ГлавноеОкно.КаталогНастроек, Новый Структура("ИдАккаунта", СбисИдАккаунта));
		КонецЦикла;
	КонецЕсли;	
КонецПроцедуры

&НаКлиенте
Функция СбисДоступныАпи3Объекты(Кэш)
	Возврат МодульОбъектаКлиент().ПолучитьЗначениеПараметраСбис("СпособХраненияНастроек") = 1
		И МодульОбъектаКлиент().ПолучитьЗначениеПараметраСбис("СпособОбмена") <> 0;
КонецФункции
