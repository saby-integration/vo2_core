
&НаКлиенте
Процедура ДействияПриСтарте(ПараметрыЗапуска, Кэш) Экспорт
	
	Попытка
		
		УспешноеОбновление = Ложь;
		Если		ПолучитьЗначениеПараметраТекущегоСеанса("ПервыйЗапуск") Тогда
			
			СбисДействияПриПервомЗапуске(ПараметрыЗапуска, Кэш);
			УспешноеОбновление = Истина;
			
		КонецЕсли;
			
		Если   ПолучитьЗначениеПараметраТекущегоСеанса("НоваяВерсия") Тогда
			
			РезультатДействия = СбисДействияПриОбновленииВерсии(Кэш, ПараметрыЗапуска.СтараяВерсия, ПараметрыЗапуска.АктивнаяВерсия);
			СбисСтатистика_СформироватьИЗаписать(Новый Структура("Действие, Результат, ИмяРеестра", "Обновление", РезультатДействия, Кэш.Текущий.ТипДок), Новый Структура);
 			УспешноеОбновление = Истина;
			
		КонецЕсли;     
		
		// Записываем статистику по конфе после запуска
		ПолнаяВерсия = Кэш.ФормаНастроек.СформироватьПрефиксНабораНастроек(Кэш);
		ПрикладнаяСтатистика = НовыйПрикладнаяСтатистика();
		ЗаписьПрикладнойСтатистики = НовыйЗаписьПрикладнойСтатистики(ПолнаяВерсия, "Запуск внешней обработки");
		ПрикладнаяСтатистика_Добавить(ПрикладнаяСтатистика, ЗаписьПрикладнойСтатистики);
		ПрикладнаяСтатистика_Отправить(ПрикладнаяСтатистика);

		//Установить отложенные операции после запуска
		ОбработчикДействия = НовыйСбисОписаниеОповещения("СбисПроверитьПоследнююВерсию", ГлавноеОкно, Кэш);
		ОтложенноеДействиеОбновления = НовыйОтложенноеДействие(Новый Структура("Аргумент, ОписаниеОповещения", ПараметрыЗапуска, ОбработчикДействия));
  		ПодключитьОтложенноеДействие(ОтложенноеДействиеОбновления);

		ОбработчикДействия = НовыйСбисОписаниеОповещения("СбисПроверитьНаличиеОбновлений", ГлавноеОкно, Кэш);
		ПодключитьОтложенноеДействие(НовыйОтложенноеДействие(
		Новый Структура("Периодичность,	Аргумент,							ОписаниеОповещения, ЧислоВызовов", 
						60*60*8,		Новый Структура("Режим", "Авто"),	ОбработчикДействия)));
		
		ОбработчикДействия = НовыйСбисОписаниеОповещения("ОбновитьМеткиСтатусов", ГлавноеОкно.МодульОбъектаКлиент(), Кэш);
		ПодключитьОтложенноеДействие(НовыйОтложенноеДействие(Новый Структура("Периодичность, ОписаниеОповещения, ЧислоВызовов", 600, ОбработчикДействия)));

		Если 	НЕ ПараметрыЗапуска.сбисПараметры.Свойство("НеОтображатьНовостьПриЗапуске")
			ИЛИ НЕ ПараметрыЗапуска.сбисПараметры.НеОтображатьНовостьПриЗапуске Тогда
			АргументПоказаНовости = Новый Структура("ВерсияПрочитана, АктивнаяВерсия", ГлавноеОкно.ПрочитаннаяНовость, ПараметрыЗапуска.АктивнаяВерсия);
			ОтложенноеДействиеОбновления = НовыйОтложенноеДействие(Новый Структура(
			"Аргумент,				ИмяПроцедуры,			Модуль,			ДополнительныеПараметры", 
			АргументПоказаНовости,	"СбисПроверитьНовость",	ГлавноеОкно,	Кэш));
			ПодключитьОтложенноеДействие( ОтложенноеДействиеОбновления);
		КонецЕсли;
		
		ОжидаемаяВерсия = ПолучитьЗначениеПараметраСбис("ОжидаемаяВерсия");
		Если	ЗначениеЗаполнено(ОжидаемаяВерсия) 
			И	Кэш.ОбщиеФункции.ЭтоНоваяВерсия(ОжидаемаяВерсия, ПараметрыЗапуска.АктивнаяВерсия) Тогда
			ОтложенноеДействиеОбновления = НовыйОтложенноеДействие(Новый Структура(
			"Аргумент,				Периодичность,	ИмяПроцедуры,									Модуль", 
			"Предложить перезапуск",60*15,			"сбисУстановитьОформлениеГиперссылокОбновления",ГлавноеОкно));
			ПодключитьОтложенноеДействие(ОтложенноеДействиеОбновления);
		Иначе
			
			ИзменитьПараметрСбис("ОжидаемаяВерсия", "");
			
		КонецЕсли;
		
		Если УспешноеОбновление Тогда
						
			// После обновления, обновить последнюю запущенную версию
	        ИзменитьПараметрСбис("ПредВерсия", ПараметрыЗапуска.АктивнаяВерсия);
			
		КонецЕсли;
		
	Исключение
		
		ИнфоОбОшибке = ИнформацияОбОшибке();
		ВызватьСбисИсключение(ИнфоОбОшибке, "МодульОбъектаКлиент.ДействияПриСтарте");
		
	КонецПопытки;
	
КонецПроцедуры
		
//При изменении версии внешней обработки со старой на новую
&НаКлиенте
Функция  СбисДействияПриОбновленииВерсии(Кэш, СтараяВерсия, НоваяВерсия) Экспорт
	РезультатДействия = Кэш.ОбщиеФункции.РезультатДействия_Новый(Кэш, Новый Структура("ПредставлениеОперации, ФормаВызова", "Обновление", ГлавноеОкно));
	
	Если НоваяВерсияБольшеКлиент(СтараяВерсия, "24.1100") Тогда
		//Если версия ДО 24.1100 то выставить опцию подразделений в "Не создавать ответственных и подразделения"
		ИзменитьПараметрСбис("ВариантВыгрузкиОтвПодр", 2);
	КонецЕсли;
	
	Если НоваяВерсияБольшеКлиент(СтараяВерсия, "24.2132")
		И НЕ ГлавноеОкно.РежимЗапускаГлавногоОкна = "ВнешнийИнтерфейс" Тогда
		
		ИзменитьПараметрСБИС("ИспользоватьНовуюОтправку", Истина);			
		
	КонецЕсли;
	
	Если НоваяВерсияБольшеКлиент(СтараяВерсия, "24.2162")
		И МодульОбъектаКлиент().ПолучитьЗначениеПараметраСбис("ЗаписейНаСтранице") > 50 Тогда

		ИзменитьПараметрСбис("ЗаписейНаСтранице", 50);
		ГлавноеОкно.ЗаписейНаСтранице = 50;

	КонецЕсли;
	
	// Повторим для устранения аварии
	// https://dev.saby.ru/opendoc.html?guid=1da1ff88-6203-407d-a51d-31dd7a45e78e&client=3
	Если НоваяВерсияБольшеКлиент(СтараяВерсия, "24.3205")
		И (МодульОбъектаКлиент().ПолучитьЗначениеПараметраСбис("ЗаписейНаСтранице") > 50
			ИЛИ ГлавноеОкно.ЗаписейНаСтранице > 50 ) Тогда

		ИзменитьПараметрСбис("ЗаписейНаСтранице", 50);
		ГлавноеОкно.ЗаписейНаСтранице = 50;

	КонецЕсли;
	
	Если НоваяВерсияБольшеКлиент(СтараяВерсия, "24.5100") Тогда
		
		ПараметрыСбисПоУмолчанию = ПараметрыСбисПоУмолчанию();
		
		Если ПустаяСтрока(ПолучитьЗначениеПараметраСбис("ЗаполнениеКонтрагента1С")) Тогда
			ИзменитьПараметрСбис("ЗаполнениеКонтрагента1С",	ПараметрыСбисПоУмолчанию["ЗаполнениеКонтрагента1С"]);
		КонецЕсли;
		
		Если ПустаяСтрока(ПолучитьЗначениеПараметраСбис("ТипГрузополучателя")) Тогда
			ИзменитьПараметрСбис("ТипГрузополучателя",	ПараметрыСбисПоУмолчанию["ТипГрузополучателя"]);
		КонецЕсли;
		
    КонецЕсли;
	
	// Обновим файлы настроек без поднятия версии к текущей версии конфигурации
	Если НЕ ПолучитьЗначениеПараметраСбис("НастройкиАвтообновление") Тогда
		Отказ = Ложь;
		СтрокаДетализации = Кэш.ОбщиеФункции.РезультатДействия_СформироватьСтрокуДетализации(Кэш,,Новый Структура("Название", "Освежение файлов настроек"));
		РезультатОсвеженияФайловНастроек = Кэш.ФормаНастроекОбщее.ОсвежитьФайлыНастроек(Кэш, Отказ);
		Если Отказ Тогда
			Кэш.ОбщиеФункции.РезультатДействия_ДобавитьОшибку(Кэш, РезультатДействия, СтрокаДетализации, РезультатОсвеженияФайловНастроек);
			Отказ = Ложь;
		Иначе
			Кэш.ОбщиеФункции.РезультатДействия_ДобавитьРезультат(Кэш, РезультатДействия, СтрокаДетализации, Новый Структура("Выполнено, КлючГруппировки", Истина, "Файлы настроек освежены"));
		КонецЕсли;	
	КонецЕсли;

	Возврат РезультатДействия;
	
КонецФункции

//Выполняется при первом запуске обработки
&НаКлиенте
Процедура СбисДействияПриПервомЗапуске(ПараметрыЗапуска, Кэш) Экспорт
	Попытка
		// При первом запуске заполняем Главное окно значениями по умолчанию
		ЗаполнитьЗначенияСвойств(ГлавноеОкно, ГлобальныйКэш.Парам);

		Отказ = Ложь;
		РезультатДобавленияПФ = Кэш.ФормаНастроекОбщее.СбисДобавитьПечатныеФормы(Кэш, Отказ);
		Если Отказ Тогда
			СбисПараметрыСтатистики = Новый Структура("Действие, Ошибка, ИмяРеестра", "Запись ошибки", РезультатДобавленияПФ, Кэш.Текущий.ТипДок);
			СбисСтатистика_СформироватьИЗаписать(СбисПараметрыСтатистики, Новый Структура);
		КонецЕсли;
	Исключение
		ИнфоОбОшибке = ИнформацияОбОшибке();
		ВызватьСбисИсключение(ИнфоОбОшибке, "МодульОбъектаКлиент.СбисДействияПриПервомЗапуске");
	КонецПопытки;
КонецПроцедуры

// Функция - Параметры сбис по умолчанию
// 
// Возвращаемое значение:
//  Структура - 
//				Ключ		- название параметра
//				Значение	- значение параметра
//
&НаКлиенте
Функция ПараметрыСбисПоУмолчанию() Экспорт
	
	ЗначПоУмолчанию = Новый Структура;
	
	ЗначПоУмолчанию.Вставить("Логин", "");
	ЗначПоУмолчанию.Вставить("Пароль", "");
	ЗначПоУмолчанию.Вставить("Сертификат", "");
	ЗначПоУмолчанию.Вставить("ТипПрокси", "Автоматически");
	ЗначПоУмолчанию.Вставить("ПроксиЛогин", "");
	ЗначПоУмолчанию.Вставить("ПроксиПароль", "");
	ЗначПоУмолчанию.Вставить("ПроксиПорт", "");
	ЗначПоУмолчанию.Вставить("ПроксиСервер", "");
	ЗначПоУмолчанию.Вставить("ЗапомнитьПароль", Ложь);
	ЗначПоУмолчанию.Вставить("ЗапомнитьСертификат", Ложь);
	ЗначПоУмолчанию.Вставить("ВходПоСертификату", Ложь);
	ЗначПоУмолчанию.Вставить("ЗаписейНаСтранице", 50);
	ЗначПоУмолчанию.Вставить("ЗаписейНаСтранице1С", 50);
	ЗначПоУмолчанию.Вставить("РежимСопоставления", 1);
	ЗначПоУмолчанию.Вставить("СопоставлениеПоСумме", 0);
	ЗначПоУмолчанию.Вставить("СопоставлениеПоНомеру", "Точное совпадение");
	ЗначПоУмолчанию.Вставить("СопоставлениеПоДате", "Точное совпадение");
	ЗначПоУмолчанию.Вставить("СопоставлениеПоКонтрагенту", "По ИНН/КПП");
	ЗначПоУмолчанию.Вставить("СопоставлениеПоОрганизации", "Не использовать");
	ЗначПоУмолчанию.Вставить("СопоставлениеПериод", "Дата документа");
	ЗначПоУмолчанию.Вставить("СопоставлятьПередЗагрузкой", Ложь);
	ЗначПоУмолчанию.Вставить("УстанавливатьОбновленияАвтоматически", Истина);
	ЗначПоУмолчанию.Вставить("КаталогОтладки", "");
	ЗначПоУмолчанию.Вставить("ОжидаемаяВерсия", "");
	ЗначПоУмолчанию.Вставить("ВариантВыгрузкиОтвПодр", 2);// Значение по-умолчанию - 2, не создавать отв. и подразделения
	ЗначПоУмолчанию.Вставить("КолПакетовВОтправке", 0);
	ЗначПоУмолчанию.Вставить("КаталогНастроек", "");
	ЗначПоУмолчанию.Вставить("ИдентификаторыНастроекВСБИС", Новый СписокЗначений);
	ЗначПоУмолчанию.Вставить("ИдентификаторНастроек", "");

	ЗначПоУмолчанию.Вставить("СпособОбмена",			6); // ExtSDK2
	ЗначПоУмолчанию.Вставить("СпособХраненияНастроек",	1); // Файлы настроек в СБИС
	
	ЗначПоУмолчанию.Вставить("КаталогОбмена", ""); 
	ЗначПоУмолчанию.Вставить("УдалятьПрефиксИнформационнойБазы", Ложь);
	ЗначПоУмолчанию.Вставить("УдалятьПользовательскийПрефикс", Ложь);
	ЗначПоУмолчанию.Вставить("РазделПоУмолчанию", "Полученные");
	ЗначПоУмолчанию.Вставить("ОтправлятьНоменклатуруСДокументами", Ложь);
	ЗначПоУмолчанию.Вставить("ПересчитыватьЦеныПоДанным1С", 0);
	ЗначПоУмолчанию.Вставить("ПересчитыватьНДСПоДанным1С", 0);
	ЗначПоУмолчанию.Вставить("СпособЗагрузки", 0); 
	ЗначПоУмолчанию.Вставить("ПерезаполнятьТолькоНепроведенные", Ложь);
	ЗначПоУмолчанию.Вставить("ИдентификаторСессии", "");
	ЗначПоУмолчанию.Вставить("ПрочитаннаяНовость", "");
	ЗначПоУмолчанию.Вставить("СостояниеЭД", Ложь);	// alo
	ЗначПоУмолчанию.Вставить("Меркурий", Ложь);	// alo Меркурий
	ЗначПоУмолчанию.Вставить("ШифроватьВыборочно", Ложь);
	ЗначПоУмолчанию.Вставить("АдресСервера", СписокДоступныхСерверовСБИС()[0].Значение);
	ЗначПоУмолчанию.Вставить("НастройкиАвтообновление", Истина);
	ЗначПоУмолчанию.Вставить("ИнтеграцияAPIВызовыНаКлиенте", Ложь);
	ЗначПоУмолчанию.Вставить("СтатусыВГосСистеме", Ложь);
	ЗначПоУмолчанию.Вставить("ВремяОжиданияОтвета", 60); // Время ожидания ответа (для плагина)
	ЗначПоУмолчанию.Вставить("ИспользоватьШтрихкодыНоменклатурыКонтрагентов", Ложь);
	ЗначПоУмолчанию.Вставить("РежимЗагрузки", 3); // Загружать только несопоставленные документы 1С
	ЗначПоУмолчанию.Вставить("СпособХраненияМетокСтатусов", 0); // Обновлять статусы в разрезе пользователя СБИС
	ЗначПоУмолчанию.Вставить("СоздаватьШтрихкодыНоменклатуры", Ложь);
	ЗначПоУмолчанию.Вставить("СохранятьРасхождения", Ложь);
	
	ЗначПоУмолчанию.Вставить("ПредВерсия", Неопределено);
	
	ФильтрыПоРазд = Новый Структура();
	ФильтрыПоРазд.Вставить("Полученные",		Новый Структура);
	ФильтрыПоРазд.Вставить("Отправленные",		Новый Структура);
	ФильтрыПоРазд.Вставить("Полученные_ЭТрН",	Новый Структура);
	ФильтрыПоРазд.Вставить("Отправленные_ЭТрН", Новый Структура);
	ФильтрыПоРазд.Вставить("Продажа",			Новый Структура);
	ФильтрыПоРазд.Вставить("Покупка",			Новый Структура);
	ФильтрыПоРазд.Вставить("Задачи",			Новый Структура);
	ФильтрыПоРазд.Вставить("Учет",				Новый Структура);
	
	ЗначПоУмолчанию.Вставить("ФильтрыПоРазделам", ФильтрыПоРазд);
	ЗначПоУмолчанию.Вставить("ИспользоватьГенератор", Ложь); 
	ЗначПоУмолчанию.Вставить("ИспользоватьНовыйФорматАктаСверки", Ложь);  
	ЗначПоУмолчанию.Вставить("ИспользоватьНовуюОтправку", Истина);  
	ЗначПоУмолчанию.Вставить("РеквизитСопоставленияНоменклатуры", РеквизитСопоставленияНоменклатурыПоУмолчанию());
	ЗначПоУмолчанию.Вставить("ПоддержкаОбменаЕИС", Ложь);
	
	// Проект Контрагенты 1С в обработке
	ЗначПоУмолчанию.Вставить("СкладПоУмолчанию",		Неопределено);
	ЗначПоУмолчанию.Вставить("РасСчетПоУмолчанию",		Неопределено);
	ЗначПоУмолчанию.Вставить("ЗаполнениеКонтрагента1С",	"ПокупательСБИС");
	ЗначПоУмолчанию.Вставить("ТипГрузополучателя",		"ГрузополучательНеВедется");
	
	// Проект Расширенные проверки сопоставления номенклатуры  
	ПорядокАвтоматическогоСопоставленияПоУмолчанию = "Артикул,КодПоставщика,КодПокупателя,GTIN,Идентификатор,Код";
	ЗначПоУмолчанию.Вставить("ПорядокАвтоматическогоСопоставления",					ПорядокАвтоматическогоСопоставленияПоУмолчанию);
	ЗначПоУмолчанию.Вставить("ПараметрыСохраненияСопоставлений",					Неопределено);
	ЗначПоУмолчанию.Вставить("СпособСопоставленияНоменклатуры",						0);	           
	ЗначПоУмолчанию.Вставить("ИспользоватьАвтоматическоеСопоставлениеНоменклатуры", Ложь);
	
	ЗначПоУмолчанию.Вставить("ПараметрыПереносаСопоставлений_Контрагент",			"");
	ЗначПоУмолчанию.Вставить("ПараметрыПереносаСопоставлений_Начат",				Ложь);
	ЗначПоУмолчанию.Вставить("ПараметрыПереносаСопоставлений_Страница",				1);
	ЗначПоУмолчанию.Вставить("ПараметрыПереносаСопоставлений_Форма",				"");
	ЗначПоУмолчанию.Вставить("ПараметрыПереносаСопоставлений_Завершен",				Ложь);

	//1189641556
	ЗначПоУмолчанию.Вставить("СоздаватьЧерновик", Ложь);
	ЗначПоУмолчанию.Вставить("ОтложенныйЗапуск", Ложь);
	
	ЗначПоУмолчанию.Вставить("Филиалы_Получатель",	Истина);
	ЗначПоУмолчанию.Вставить("Филиалы_Отправитель", Ложь);
	
	НастройкиКрипто = Новый Структура();
	НастройкиКрипто.Вставить("ИмяПрограммы", "");
	НастройкиКрипто.Вставить("ПутьКПрограмме", "");
	НастройкиКрипто.Вставить("ТипПрограммы", 0);
	НастройкиКрипто.Вставить("ПодписьНаСервере", Ложь);
	ЗначПоУмолчанию.Вставить("НастройкиКриптографии", НастройкиКрипто);

	ЗначПоУмолчанию.Вставить("ЧтениеНастроекПоТребованию",	Истина);
	ЗначПоУмолчанию.Вставить("РежимОтладки",				Ложь);
	ЗначПоУмолчанию.Вставить("ПолнаяВерсияПродукта",		ГлобальныйКэш.ПараметрыСистемы.Обработка.ПолнаяВерсия);
	ЗначПоУмолчанию.Вставить("UserAgent",					ГлобальныйКэш.ПараметрыСистемы.Обработка.UserAgent);
	
	// Новый формат УПД 24
	ЗначПоУмолчанию.Вставить("УПД24", Ложь);
	
	Возврат ЗначПоУмолчанию;
	
КонецФункции

