&НаКлиенте
Перем МестныйКэш;

// функции для совместимости кода 
&НаКлиенте
Функция сбисПолучитьФорму(ИмяФормы)
	Если ТипЗнч(ЭтаФорма) = Тип("УправляемаяФорма") Тогда
		Попытка
			ЭтотОбъект="";
		Исключение
		КонецПопытки;
		Возврат ПолучитьФорму("ВнешняяОбработка.СБИС.Форма."+ИмяФормы);
	КонецЕсли;
	Возврат ЭтотОбъект.ПолучитьФорму(ИмяФормы);
КонецФункции
&НаКлиенте
Функция сбисЭлементФормы(Форма,ИмяЭлемента)
	Если ТипЗнч(ЭтаФорма) = Тип("УправляемаяФорма") Тогда
		Возврат Форма.Элементы.Найти(ИмяЭлемента);
	КонецЕсли;
	Возврат Форма.ЭлементыФормы.Найти(ИмяЭлемента);
КонецФункции
&НаКлиенте
Функция сбисПолучитьСтраницу(Элемент, ИмяСтраницы)
	Если ТипЗнч(ЭтаФорма) = Тип("УправляемаяФорма") Тогда
		Возврат Элемент.ПодчиненныеЭлементы[ИмяСтраницы];
	КонецЕсли;
	Возврат Элемент.Страницы[ИмяСтраницы];
КонецФункции
//------------------------------------------------------
&НаКлиенте
Функция ОбновитьКонтент(Кэш) Экспорт 
	Перем СбисТекущийЭтап, Стороны;
	МестныйКэш = Кэш;
	ГлавноеОкно = Кэш.ГлавноеОкно;
	filter = Кэш.ОбщиеФункции.ПолучитьФильтрСобытий(Кэш, Новый Структура("Тип, Направление, ДопПоля",
																		"ConsignmentNote",
																		"Исходящий",
																		"Стороны,ТекущиеЭтапы"));
	СтруктураДанныхПолученная = Кэш.Интеграция.СбисПолучитьСписокДокументовПоФильтру(Кэш, filter, ГлавноеОкно); 
	//СтруктураДляОбновленияФормы = Кэш.СБИС.МодульОбъектаКлиент.СбисПолучитьСписокДокументов(Кэш, ПараметрыСписка);
	СтруктураДляОбновленияФормы = Новый Структура("Таблица_РеестрСобытий");
	Если Не СтруктураДанныхПолученная.Свойство("Таблица_РеестрДокументов", СтруктураДляОбновленияФормы.Таблица_РеестрСобытий) Тогда
		СтруктураДляОбновленияФормы.Таблица_РеестрСобытий = Новый Массив;
	КонецЕсли;
	
	// Заказчик и Перевозчик
	Для Индекс = 0 По СтруктураДляОбновленияФормы.Таблица_РеестрСобытий.ВГраница() Цикл
		ОбрабатываемоеСобытие = СтруктураДляОбновленияФормы.Таблица_РеестрСобытий[Индекс];
		ОбрабатываемоеСобытие.СоставПакета[0].Значение.Свойство("Стороны", Стороны); 
		Если ЗначениеЗаполнено(Стороны) Тогда
			Если Стороны.Свойство("Заказчик") Тогда
				ОбрабатываемоеСобытие.Вставить("Заказчик",			Кэш.ОбщиеФункции.СбисНазваниеСтороны(Стороны.Заказчик));
			КонецЕсли;
			Если Стороны.Свойство("Перевозчик") Тогда
				ОбрабатываемоеСобытие.Вставить("Перевозчик",		Кэш.ОбщиеФункции.СбисНазваниеСтороны(Стороны.Перевозчик));
			КонецЕсли;
			Если Стороны.Свойство("Отправитель") Тогда
				ОбрабатываемоеСобытие.Вставить("НашаОрганизация",	Кэш.ОбщиеФункции.СбисНазваниеСтороны(Стороны.Отправитель));
			КонецЕсли;
			Если Стороны.Свойство("Получатель") Тогда
				ОбрабатываемоеСобытие.Вставить("Контрагент",		Кэш.ОбщиеФункции.СбисНазваниеСтороны(Стороны.Получатель));
			КонецЕсли;
		КонецЕсли;
		Если		ОбрабатываемоеСобытие.СоставПакета[0].Значение.Свойство("ТекущиеЭтапы", СбисТекущийЭтап) Тогда
			Если ТипЗнч(СбисТекущийЭтап) = Тип("Массив")
				И	СбисТекущийЭтап.Количество() Тогда
				
				ОбрабатываемоеСобытие.Вставить("ТекущийЭтап", СбисТекущийЭтап[0].Наименование);
			ИначеЕсли ТипЗнч(СбисТекущийЭтап) = Тип("Структура")
				И СбисТекущийЭтап.Свойство("Наименование", СбисТекущийЭтап) Тогда 
				
				ОбрабатываемоеСобытие.Вставить("ТекущийЭтап", СбисТекущийЭтап);
			Иначе
				// Пришло что-то новое, этап не ставим, но и не падаем
			КонецЕсли;
		КонецЕсли;
	КонецЦикла;
	
	Кэш.ОбщиеФункции.ОбновитьПанельНавигации(Кэш);
	Контент = сбисЭлементФормы(ГлавноеОкно, "Контент");
	Контент.ТекущаяСтраница = сбисПолучитьСтраницу(Контент, "РеестрСобытий");	
	Кэш.ТаблДок = сбисЭлементФормы(ГлавноеОкно,"Таблица_РеестрСобытий");
	ГлавноеОкно.СписокДопОперацийРеестра.Очистить();
	Возврат СтруктураДляОбновленияФормы;
КонецФункции

// Функция делает подготовку к переходу	
&НаКлиенте
Функция ОбновитьКонтент_ПередВызовом(СтруктураРаздела, Кэш) Экспорт
	
	Если ЗначениеЗаполнено(Кэш.Парам.ФильтрыПоРазделам["Отправленные"]) Тогда
		Кэш.ГлавноеОкно.сбисВосстановитьФильтр(Кэш, Кэш.Парам.ФильтрыПоРазделам["Отправленные"]);
	Иначе
		ФильтрОчистить(Кэш);
	КонецЕсли;
	
КонецФункции

&НаКлиенте	
Процедура НастроитьКолонки(Кэш) Экспорт
	Кэш.ГлавноеОкно.СбисПолучитьЭлементФормы(Кэш.ГлавноеОкно, Кэш.ГлавноеОкно.СбисПолноеИмяКолонки("Таблица_РеестрСобытий",	"Вложения")).Видимость = Ложь;
	#Если ТолстыйКлиентОбычноеПриложение Тогда
		Кэш.ГлавноеОкно.СбисПолучитьЭлементФормы(Кэш.ГлавноеОкно, Кэш.ГлавноеОкно.СбисПолноеИмяКолонки("Таблица_РеестрСобытий",	"НашаОрганизация")).ТекстШапки = "Отправитель";
		Кэш.ГлавноеОкно.СбисПолучитьЭлементФормы(Кэш.ГлавноеОкно, Кэш.ГлавноеОкно.СбисПолноеИмяКолонки("Таблица_РеестрСобытий",	"Контрагент")).ТекстШапки = "Получатель";
	#Иначе
		Кэш.ГлавноеОкно.СбисПолучитьЭлементФормы(Кэш.ГлавноеОкно, Кэш.ГлавноеОкно.СбисПолноеИмяКолонки("Таблица_РеестрСобытий",	"НашаОрганизация")).Заголовок = "Отправитель";
		Кэш.ГлавноеОкно.СбисПолучитьЭлементФормы(Кэш.ГлавноеОкно, Кэш.ГлавноеОкно.СбисПолноеИмяКолонки("Таблица_РеестрСобытий",	"Контрагент")).Заголовок = "Получатель";
	#КонецЕсли
	Кэш.ГлавноеОкно.СбисПолучитьЭлементФормы(Кэш.ГлавноеОкно, Кэш.ГлавноеОкно.СбисПолноеИмяКолонки("Таблица_РеестрСобытий",	"Комментарий")).Видимость = Ложь;
	Кэш.ГлавноеОкно.СбисПолучитьЭлементФормы(Кэш.ГлавноеОкно, Кэш.ГлавноеОкно.СбисПолноеИмяКолонки("Таблица_РеестрСобытий",	"Ответственный")).Видимость = Ложь;
	
	МассивРеквизитов = Новый Массив;
	МассивРеквизитов.Добавить("Перевозчик");
	МассивРеквизитов.Добавить("Заказчик");
	
	Кэш.ГлавноеОкно.НастроитьКолонкиФормы(Новый Структура("ИмяТаблицы, СтруктураПолей", "Таблица_РеестрСобытий", Новый Структура("КолонкиДобавить", МассивРеквизитов)));
КонецПроцедуры

&НаКлиенте
Процедура НавигацияУстановитьПанель(Кэш) Экспорт
	ГлавноеОкно = Кэш.ГлавноеОкно;
	сбисЭлементФормы(ГлавноеОкно,"ПанельНавигации").Видимость=Истина;
	сбисЭлементФормы(ГлавноеОкно,"ЗаписейНаСтранице1С").Видимость=Ложь;
	сбисЭлементФормы(ГлавноеОкно,"ЗаписейНаСтранице").Видимость=Истина;
КонецПроцедуры	

// Процедура устанавливает значения фильтра по-умолчанию для текущего раздела	
&НаКлиенте
Процедура ФильтрОчистить(Кэш) Экспорт
	ГлавноеОкно = Кэш.ГлавноеОкно;
	Если ТипЗнч(ЭтаФорма) = Тип("УправляемаяФорма") Тогда
		ГлавноеОкно.ФильтрПериод = "За весь период";
	Иначе
		ГлавноеОкно.ФильтрПериод = "0";
	КонецЕсли;
	Если Кэш.ТипыПолейФильтра.Свойство("ФильтрОрганизация") Тогда
		ГлавноеОкно.ФильтрОрганизация = Кэш.ТипыПолейФильтра.ФильтрОрганизация.ПривестиЗначение();
	Иначе	
		ГлавноеОкно.ФильтрОрганизация = "";
	КонецЕсли;
	Если Кэш.ТипыПолейФильтра.Свойство("ФильтрКонтрагент") Тогда
		ГлавноеОкно.ФильтрКонтрагент = Кэш.ТипыПолейФильтра.ФильтрКонтрагент.ПривестиЗначение();
	Иначе	
		ГлавноеОкно.ФильтрКонтрагент = "";
	КонецЕсли;
	Если Кэш.ТипыПолейФильтра.Свойство("ФильтрОтветственный") Тогда
		ГлавноеОкно.ФильтрОтветственный = Кэш.ТипыПолейФильтра.ФильтрОтветственный.ПривестиЗначение();
	Иначе	
		ГлавноеОкно.ФильтрОтветственный = "";
	КонецЕсли;
	ГлавноеОкно.ФильтрДатаНач = "";
	ГлавноеОкно.ФильтрДатаКнц = "";
	ГлавноеОкно.ФильтрСостояние = ГлавноеОкно.СписокСостояний.НайтиПоИдентификатору(0).Значение;
	ГлавноеОкно.ФильтрТипыДокументов = Новый СписокЗначений;
	ГлавноеОкно.ФильтрКонтрагентПодключен = "";
	ГлавноеОкно.ФильтрКонтрагентСФилиалами = Ложь;
	ГлавноеОкно.ФильтрСтраница = 1;
	ГлавноеОкно.ФильтрМаска = "";
	//++ Бухов А. Фильтр по умолчанию 	
	Если Кэш.Ини.Конфигурация.Свойство("ФильтрПоУмолчанию") И  Кэш.Ини.Конфигурация.ФильтрПоУмолчанию.Свойство(Кэш.Текущий.ТипДок) Тогда 
		Попытка
			Ини = Кэш.ОбщиеФункции.ПолучитьДанныеДокумента1С(Кэш.Ини.Конфигурация.ФильтрПоУмолчанию[Кэш.Текущий.ТипДок],Неопределено,Кэш.КэшЗначенийИни, Кэш.Парам);  // alo Меркурий
			Для Каждого Элем Из Ини Цикл 
				Если нрег(Лев(Элем.Ключ, 6)) = "фильтр" Тогда
					ГлавноеОкно[Элем.Ключ] = Элем.Значение;
				КонецЕсли;
			КонецЦикла;
		Исключение
		КонецПопытки;
	КонецЕсли;
	//-- Бухов А. Фильтр по умолчанию
КонецПроцедуры

&НаКлиенте
Функция ПолучитьСтруктуруТаблицыСобытий(Кэш) Экспорт//При переходе в раздел задач, установить таблицу событий
	
	КолонкиИзменить	= Новый	Массив;
	Если  ТипЗнч(Кэш.ГлавноеОкно) = Тип("УправляемаяФорма") Тогда
		ДобавитьКИмениКолонки = "Таблица_РеестрСобытий";
		ПараметрИзменить = "Заголовок";
		ПутьККолонкам	= "Элементы.Таблица_РеестрСобытий.ПодчиненныеЭлементы";
	Иначе
		ДобавитьКИмениКолонки = "";
		ПараметрИзменить = "ТекстШапки";
		ПутьККолонкам	= "ЭлементыФормы.Таблица_РеестрСобытий.Колонки";
	КонецЕсли;
	КолонкиИзменить.Добавить(Новый Структура("ПолноеИмяКолонки, ИмяКолонки, ПараметрыИзменить", ДобавитьКИмениКолонки + "Заказчик", "Контрагент", Новый Структура(ПараметрИзменить, "Заказчик")));
	КолонкиИзменить.Добавить(Новый Структура("ПолноеИмяКолонки, ИмяКолонки, ПараметрыИзменить", ДобавитьКИмениКолонки + "Перевозчик", "НашаОрганизация", Новый Структура(ПараметрИзменить, "Перевозчик")));
	
	СтруктураОбновления	= Новый	Структура();
	СтруктураОбновления.Вставить("ИмяТаблицы",		"Таблица_РеестрСобытий");
	СтруктураОбновления.Вставить("СтруктураПолей",	Новый	Структура("КолонкиИзменить", КолонкиИзменить));
	СтруктураОбновления.Вставить("ПутьККолонкам",	ПутьККолонкам);
	
	Возврат	СтруктураОбновления;

КонецФункции


// Функция заполняет данные о прохождении документа	
&НаКлиенте
Функция ЗаполнитьПрохождение(СоставПакета) Экспорт
	Возврат МестныйКэш.ОбщиеФункции.ЗаполнитьПрохождение(МестныйКэш, СоставПакета, Новый Структура);
КонецФункции

&НаКлиенте
Процедура НаСменуРаздела(Кэш) Экспорт 

	ПодготовитьФильтрРаздела(Кэш);
	
	ПанельМассовыхОпераций = сбисЭлементФормы(Кэш.ГлавноеОкно,"ПанельМассовыхОпераций");
	ПанельМассовыхОпераций.ТекущаяСтраница = Кэш.ГлавноеОкно.сбисПолучитьСтраницу(ПанельМассовыхОпераций,"Полученные_ЭТрН");
КонецПроцедуры

// Процедура для заполнения списков выбора в фильтре. Восстанавливает последние установки фильтра раздела
// 
// Параметры:
//  Кэш  - Структура - Кэш обработки
//
&НаКлиенте
Процедура ПодготовитьФильтрРаздела(Кэш) Экспорт

	СписокСостояний = Новый СписокЗначений();
	СписокСостояний.Добавить("Все документы");
	СписокСостояний.Добавить("Внутренняя обработка");
	СписокСостояний.Добавить("Недоставленные");
	СписокСостояний.Добавить("Не получен ответ");
	СписокСостояний.Добавить("Утвержденные");
	СписокСостояний.Добавить("Отклоненные");
	СписокСостояний.Добавить("С ошибками");
	СписокСостояний.Добавить("Удаленные");
	СписокСостояний.Добавить("Черновики");
			
	Кэш.ГлавноеОкно.СписокСостояний = СписокСостояний;
              
	
	Кэш.ГлавноеОкно.ФильтрОбновитьПанель()
	
КонецПроцедуры // ПодготовитьФильтрРаздела()
