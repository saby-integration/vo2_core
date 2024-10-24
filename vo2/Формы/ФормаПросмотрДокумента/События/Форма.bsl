
// Процедура - событие завершения отправки
//
// Параметры:
//  РезультатОтправки	 - РезультатОтправки	 - Экземпляр класса отправки
//  ДопПараметры		 - Структура	 - Кэш
//
&НаКлиенте
Процедура ОтправитьДокументы_Завершение(РезультатОтправки, ДопПараметры) Экспорт
	
	ПослеОтправки(Кэш);
	
КонецПроцедуры

// Процедура - событие после отправки
//
// Параметры:
//  ВходящийКэш	 - ЛокальныйКэш	 - структура, есл ине определен кэш на форме
//
&НаКлиенте
Процедура ПослеОтправки(ВходящийКэш) Экспорт 
	Если Кэш = Неопределено Тогда
		Кэш = ВходящийКэш;
	КонецЕсли;
	// Если есть ошибки отправки, то выводим результат, иначе закрываем просмотр 	
	Если Кэш.РезультатОтправки.НеОтправлено>0 Тогда  // если есть ошибки при отправке, показываем окно результатов
		фрм = Кэш.ГлавноеОкно.сбисНайтиФормуФункции("ПоказатьРезультатОтправки","ФормаРезультатОтправки","", Кэш);
		фрм.ПоказатьРезультатОтправки(Кэш);	
	Иначе    // если отправилось без ошибок, закрываем окно просмотра
		ОбновлятьГлавноеОкно = Истина;
		Если ЭтаФорма.Открыта() Тогда
			ЭтаФорма.Закрыть();
		КонецЕсли;
	КонецЕсли;
КонецПроцедуры

// Переходим на закладку просмотр, чтобы при открытии в следующий раз форма открывалась на ней	
&НаКлиенте
Процедура ПередЗакрытием(Отказ, СтандартнаяОбработка)
	
	КонтентВыборЗакладки("Просмотр");
	Если НЕ МодульОбъектаКлиент().ПолучитьЗначениеФичи("РасширенныйФункционалСопоставленияНоменклатуры") Тогда 
		Возврат;
	КонецЕсли;
	
	СопоставленияСохранены = СопоставленияСохраненыПередВыходом();
	
	Если НЕ СопоставленияСохранены 
		И НЕ ВыполнитьЗакрытиеФормы Тогда
		ОбработчикДиалога = МодульОбъектаКлиент().НовыйСбисОписаниеОповещения("ПередЗакрытием_ПослеДиалога", ЭтаФорма, Новый Структура("Режим", "Сохранить"));
		МодульОбъектаКлиент().СбисПоказатьВопрос(ОбработчикДиалога, "Сохранить изменения в сопоставлениях?", РежимДиалогаВопрос.ДаНет,,,"Рекомендуется сохранить внесенные изменения.");
		Отказ = Истина;
		Возврат;
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ПередЗакрытием_ПослеДиалога(РезультатДиалога, ДопПараметры) Экспорт
	
	Если РезультатДиалога = КодВозвратаДиалога.Да Тогда
		СохранитьИзмененныеСопоставления();
		Закрыть();
	ИначеЕсли РезультатДиалога = КодВозвратаДиалога.Нет Тогда
		ВыполнитьЗакрытиеФормы = Истина;
		Закрыть();		
	КонецЕсли;

	
КонецПроцедуры
