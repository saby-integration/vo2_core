
#Область include_local_ПолучитьМодульОбъекта
#КонецОбласти


/////////Функции для совместимости кода/////////////
&НаКлиенте
Функция сбисЭлементФормы(Форма, ИмяЭлемента)
	Если ТипЗнч(ЭтаФорма) = Тип("УправляемаяФорма") Тогда
		Возврат Форма.Элементы.Найти(ИмяЭлемента);
	КонецЕсли;
	Возврат Форма.ЭлементыФормы.Найти(ИмяЭлемента);
КонецФункции

// Функции получения объекта обработки разделены для клиента и сервера, 
// чтобы не тянуть серверный контекст на УФ, если находимся на клиенте
&НаКлиенте
Функция сбисОбъектОбработкиНаКлиенте()
	#Если ТолстыйКлиентОбычноеПриложение Тогда
		Возврат ЭтотОбъект;
	#Иначе
		Возврат Объект;
	#КонецЕсли
КонецФункции

// Функции получения объекта обработки разделены для клиента и сервера, 
// чтобы не тянуть серверный контекст на УФ, если находимся на клиенте
&НаСервере
Функция сбисОбъектОбработкиНаСервере()
	#Если ТолстыйКлиентОбычноеПриложение Тогда
		Возврат ЭтотОбъект;
	#Иначе
		Возврат Объект;
	#КонецЕсли
КонецФункции
 

////////////////////////////////////////////////////
////////////////////Работа Формы////////////////////
////////////////////////////////////////////////////

//////////////////События формы/////////////////////

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	ОбновитьКонтент();
	ФильтрОбновитьПанель();
	УстановитьФильтрРеестра();
	ФормаОткрыта = Истина;
КонецПроцедуры

&НаКлиенте
Процедура ПриЗакрытии(ЗавершениеРаботы)
	СделатьЗаписиПрочитаннымиИОбновитьДатуПросмотра();
	Попытка
		СохранитьДанныеРеестра();
	Исключение
	КонецПопытки;
	ОбновитьКонтент();
	ФормаОткрыта = Ложь;
КонецПроцедуры

&НаКлиенте
Процедура ОбработкаОповещения(ИмяСобытия, Параметр, Источник)
	// Закрываем эту форму, если закрывается форма главного окна ВО.
	Если ИмяСобытия = "ЗакрытьСБИС" Тогда
		Если ФормаОткрыта = Истина Тогда
			Закрыть();
		КонецЕсли;
	КонецЕсли;
КонецПроцедуры

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	УстановитьУсловноеОформлениеРеестра();
КонецПроцедуры


////////////////События элементов///////////////////

// Команда для открытия документа на форме ФормаПросмотрДокумента 
&НаКлиенте
Процедура ОткрытьДокумент(Элемент, ВыбраннаяСтрока, Поле, СтандартнаяОбработка)
	СтандартнаяОбработка = Ложь;
	ОткрытьПоказатьДокумент(Элемент.ТекущиеДанные.SabyObjId);
КонецПроцедуры

//////////////////////Кнопки////////////////////////

// Команда для обновления даты просмотра статусов
&НаКлиенте
Процедура Прочитано(Команда)
	СделатьЗаписиПрочитаннымиИОбновитьДатуПросмотра();
	СохранитьДанныеРеестра();
	ОбновитьКонтент();
КонецПроцедуры

// Команда очистки записей реестра, у которых конечный статус 
&НаКлиенте
Процедура Очистить(Команда)
	ВсегоСтрок = сбисОбъектОбработкиНаКлиенте().LongOperations.Количество();

	Сч = 0;
	Пока Сч < ВсегоСтрок Цикл
		СтрокаОперации = сбисОбъектОбработкиНаКлиенте().LongOperations.Получить(Сч);
		Если СтрокаОперации.State <> "Подготовка"
			И СтрокаОперации.State <> "В обработке" Тогда
			
			сбисОбъектОбработкиНаКлиенте().LongOperations.Удалить(СтрокаОперации);
			ВсегоСтрок = ВсегоСтрок - 1;				
		Иначе
			Сч = Сч + 1;
		КонецЕсли;		
	КонецЦикла;
	
	СохранитьДанныеРеестра();
КонецПроцедуры

&НаКлиенте
Процедура ВыбратьФильтрОперацииИзСписка(Команда)
	ВыбратьФильтрОбщая("ФильтрОперация", СписокДлительныхОпераций);
КонецПроцедуры

&НаКлиенте
Процедура ВыбратьФильтрСтатусаИзСписка(Команда)
	ВыбратьФильтрОбщая("ФильтрСтатус", СписокСтатусовДлительныхОпераций);
КонецПроцедуры

&НаКлиенте
Процедура ВыбратьФильтрПрочитаноНеПрочитано(Команда)
	ВыбратьФильтрОбщая("ФильтрВсеНепрочитанные", СписокВсеНепрочитанные);	
КонецПроцедуры

// Контекстное меню: Открытие объекта в 1С, если это возможно
&НаКлиенте
Процедура ОткрытьОбъект1С(Команда)
	ТекДанные = сбисЭлементФормы(ЭтаФорма, "LongOperations").ТекущиеДанные;
	
	Если ТекДанные <> Неопределено Тогда
		SabyObjId = сбисЭлементФормы(ЭтаФорма, "LongOperations").ТекущиеДанные.SabyObjId;
	Иначе 
		Сообщить("Строка не выбрана.");
		Возврат;
	КонецЕсли;
	
	Кэш = ЭтаФорма.ВладелецФормы.Кэш;
	
	ПолныйСоставПакета = Новый Структура;
	
	ГлавноеОкно = Кэш.ГлавноеОкно;
	фрм = ГлавноеОкно.сбисНайтиФормуФункции("НайтиДокументы1СПоПакетуСБИС", Кэш.ФормаРаботыСоСтатусами, "" ,Кэш);
	
	ПолныйСоставПакета = Кэш.Интеграция.ПрочитатьДокумент(Кэш, SabyObjId);
	
	Если ПолныйСоставПакета = Ложь ИЛИ НЕ ПолныйСоставПакета.Количество() Тогда
		Сообщить("Невозможно открыть объект. Не удалось получить состав пакета.");
		Возврат;
	КонецЕсли;
	
	МассивСсылок1С = Новый Массив;	
	Для Каждого Вложение Из ПолныйСоставПакета.Вложение Цикл
		Если Не Вложение.Свойство("Служебный") ИЛИ Вложение.Служебный = "Нет" Тогда
			ДанныеДокумента1С = фрм.НайтиДокументы1СПоИдВложенияСБИС(ПолныйСоставПакета.Идентификатор, Вложение.Идентификатор, Кэш.Ини, ГлавноеОкно.Кэш.Парам.КаталогНастроек);
			Если ЗначениеЗаполнено(ДанныеДокумента1С) Тогда
				Для каждого Ссылка1С Из ДанныеДокумента1С.Ссылки Цикл
					МассивСсылок1С.Добавить(Ссылка1С.Значение);
				КонецЦикла;
			КонецЕсли;
		КонецЕсли;
	КонецЦикла;
	
	Если Не МассивСсылок1С.Количество() Тогда
		Сообщить("Нет связанных документов 1С");
		Возврат;
	КонецЕсли;
	Для Каждого сбисДокументОткрыть Из МассивСсылок1С Цикл
		Попытка
			#Если ТолстыйКлиентОбычноеПриложение Тогда
				ОткрытьЗначение(сбисДокументОткрыть);
			#Иначе
				ПоказатьЗначение(, сбисДокументОткрыть);
			#КонецЕсли
		Исключение
			Сообщить(ИнформацияОбОшибке().Описание);
		КонецПопытки;
	КонецЦикла;
КонецПроцедуры

// Контекстное меню: Открытие объекта на sbis.ru, если это возможно
&НаКлиенте
Процедура ОткрытьОбъектОнлайн(Команда)
	ТекДанные = сбисЭлементФормы(ЭтаФорма, "LongOperations").ТекущиеДанные;
	
	Если ТекДанные <> Неопределено Тогда
		SabyObjId = ТекДанные.SabyObjId;
	Иначе 
		Сообщить("Строка не выбрана.");
		Возврат;
	КонецЕсли;
	
	Кэш = ЭтаФорма.ВладелецФормы.Кэш;
	
	ПолныйСоставПакета = Новый Структура;
	
	ГлавноеОкно = Кэш.ГлавноеОкно;
	
	ПолныйСоставПакета = Кэш.Интеграция.ПрочитатьДокумент(Кэш, SabyObjId);
	
	Если ПолныйСоставПакета = Ложь ИЛИ НЕ ПолныйСоставПакета.Количество() Тогда
		Сообщить("Невозможно открыть объект. Не удалось получить состав пакета.");
		Возврат;
	КонецЕсли;
	
	ГлавноеОкно.ОткрытьДокументОнлайнПоПакетуЗавершение(ПолныйСоставПакета.СсылкаДляНашаОрганизация, ПолныйСоставПакета, Кэш);
КонецПроцедуры


////////////////////////////////////////////////////
////////////////////API////////////////////
////////////////////////////////////////////////////

// Открытие формы извне
&НаКлиенте
Процедура Показать() Экспорт
	Отказ = Ложь;
	
	ПодготовитьРеестрКРаботе();
	
	Если сбисОбъектОбработкиНаКлиенте().LongOperations.Количество() = 0 Тогда
		Сообщить("История длительных операций пуста.");
		Отказ = Истина; 
	КонецЕсли;
	
	Если Отказ ИЛИ НЕ РеестрГотовКРаботе Тогда
		Возврат;
	КонецЕсли;
	
	Если Не ЭтаФорма.Открыта() Тогда
		ЭтаФорма.Открыть();
	Иначе
		ЭтаФорма.Активизировать();
	КонецЕсли;	
КонецПроцедуры

// Получение реестра из хранилища, заполнение служебных списков, обновление показа количества операций в ГО.
&НаКлиенте
Процедура ПодготовитьРеестрКРаботе() Экспорт
	Если РеестрГотовКРаботе Тогда
		Возврат;
	КонецЕсли;
	
	РезультатЗагрузки = ЗагрузитьИзХранилищаДанныеДлительныхОпераций();
	Если РезультатЗагрузки <> Неопределено Тогда
		ГлавноеОкно = ЭтаФорма.ВладелецФормы;
		Кэш = ГлавноеОкно.Кэш;
		ГлавноеОкно.СбисСообщитьОбОшибке(Кэш, РезультатЗагрузки);
		Возврат;
	КонецЕсли;
	
	УдалитьЗаписиСтарше3ДнейСДатыПоследнегоПросмотра();
	
	ЗаполнитьСписокДлительныхОпераций();
	ЗаполнитьСписокСтатусовДлительныхОпераций();
	ЗаполнитьСписокВсеНепрочитанные();
	ФильтрВсеНепрочитанные = "Непрочитанные";
	ОбновитьКонтент();
	
	РеестрГотовКРаботе = Истина;
КонецПроцедуры

// Основная процедура для добавления/обновления записи в реестре
// Важно! После добавления записей, небходимо выполнить запись реестра процедурой "СохранитьДанныеРеестра"
// СтруктураЗаполнения - Тип "Структура", значения:
//		Id			- (строка, max 80)	- идентификатор операции (обязательный)
//		Operation	- (строка, max 99)	- наим. операции, из переч. операций (обязательный, если новая строка операции)
//		Begin		- (дата-время)		- дата начала операции (обязательный, если новая строка операции)
//		Update		- (дата-время)		- дата изменения статуса (обязательный, если обновляем стаус)
//		State		- (строка, max 99)	- статус операции, из переч. статусов операций (обязательный, если обновляем статус)
//		Detail		- (строка, неогр.)	- комментарий к статусу (необязательный)
//		SabyObjName	- (строка, max 99)	- наименование объекта СБИС (обязательный, если новая строка операции)
//		SabyObjId	- (строка, max 80)	- идентификатор ВИ объекта СБИС (обязательный, если новая строка операции)
//		Progress	- (число, 0-100)	- прогресс операции (необязательный)
&НаКлиенте
Процедура ДобавитьОбновитьЗаписьРеестра(СтруктураЗаполнения) Экспорт
	Результат = ДобавитьОбновитьЗаписьРеестраНаФорме(СтруктураЗаполнения);
	
	Если Результат <> Неопределено Тогда
		ГлавноеОкно = ЭтаФорма.ВладелецФормы;
		ГлавноеОкно.СбисСообщитьОбОшибке(ГлавноеОкно.Кэш, Результат.СтруктураОшибки);
		Если Результат.Свойство("ИндексСтроки") Тогда
			сбисОбъектОбработкиНаКлиенте().LongOperations.Удалить(Результат.ИндексСтроки);	
		КонецЕсли;
		Возврат;	
	КонецЕсли;
	
	ОбновитьКонтент();
	ФильтрОбновитьПанель();
	УстановитьФильтрРеестра();
КонецПроцедуры

// Добавление записей в реестр по массиву структур и одновременное сохранение реестра
// Описание структуры записи см. в описании процедуры "ДобавитьОбновитьЗаписьРеестра"
&НаКлиенте
Процедура ДобавитьОбновитьМассивЗаписейРеестра(МассивЗаписей) Экспорт
	Для каждого Запись Из МассивЗаписей Цикл
		ДобавитьОбновитьЗаписьРеестра(Запись);	
	КонецЦикла;
	СохранитьДанныеРеестра();
КонецПроцедуры

// Сохранение данных реестра с отловом ошибки
&НаКлиенте
Процедура СохранитьДанныеРеестра() Экспорт
	ГлавноеОкно = ЭтаФорма.ВладелецФормы;
	Кэш = ГлавноеОкно.Кэш;
	Результат = ПоместитьВХранилищеДанныеДлительныхОпераций();
	Если Результат <> Неопределено Тогда
		ГлавноеОкно.СбисСообщитьОбОшибке(Кэш, Результат);
		Возврат;
	КонецЕсли;
КонецПроцедуры

////////////////////////////////////////////////////
////////////////////Системные///////////////////
////////////////////////////////////////////////////

// Загрузка настроек длительных операций и ТЧ обработки LongOperations из хранилища общих настроек.
// Возвращает Неопределено, если ошибок нет и Структуру с ошибкой, если ошибка есть
&НаСервере
Функция ЗагрузитьИзХранилищаДанныеДлительныхОпераций()
	Попытка
		СтруктураДлительныеОперации = ХранилищеОбщихНастроек.Загрузить("ДлительныеОперацииСБИС");
	Исключение
		СтруктураОшибки = Новый Структура("code,message,details", 604, "Ошибка получения данных из ИС", "Не удалось загрузить реестр длительных операций.");
		Возврат СтруктураОшибки;
	КонецПопытки;
	
	Если СтруктураДлительныеОперации = Неопределено Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	сбисОбъектОбработкиНаСервере().LongOperations.Загрузить(СтруктураДлительныеОперации.LongOperations);
	
	ДатаПросмотраСтатусовПредыдущегоСеанса	= СтруктураДлительныеОперации.ДатаПросмотраСтатусовПредыдущегоСеанса;	
	
	СтруктураФильтров = СтруктураДлительныеОперации.СтруктураФильтров;
	ФильтрОперация          = СтруктураФильтров.ФильтрОперация;
	ФильтрСтатус            = СтруктураФильтров.ФильтрСтатус;
	
	Возврат Неопределено;
КонецФункции

// Сохранение настроек длительных операций и ТЧ обработки LongOperations в хранилище общих настроек.
// Возвращает Неопределено, если ошибок нет и Структуру с ошибкой, если ошибка есть
&НаСервере
Функция ПоместитьВХранилищеДанныеДлительныхОпераций()
	//Подготовим структуру для хранения реестра. Если нужны дополнительные хранимые параметры, добавляем сюда.
	СтруктураДлительныеОперации = Новый Структура;
	СтруктураДлительныеОперации.Вставить("LongOperations",                         сбисОбъектОбработкиНаСервере().LongOperations.Выгрузить());
	СтруктураДлительныеОперации.Вставить("ДатаПросмотраСтатусовПредыдущегоСеанса", ДатаПросмотраСтатусов);
	СтруктураДлительныеОперации.Вставить("СтруктураФильтров",                      ПолучитьСтруктуруФильтров());

	Попытка
		ХранилищеОбщихНастроек.Сохранить("ДлительныеОперацииСБИС", , СтруктураДлительныеОперации);
	Исключение
		СтруктураОшибки = Новый Структура("code,message,details", 100, "Неизвестная ошибка системы", "Не удалось сохранить реестр длительных операций.");
		Возврат СтруктураОшибки;
	КонецПопытки;
	
	Возврат Неопределено;
КонецФункции

// Обработка добавления/обновления записи в реестре
// Возвращает Неопределено, если ошибок нет и Структуру с ошибкой и индексом строки(если добавлялась новая), если ошибка есть
&НаКлиенте
Функция ДобавитьОбновитьЗаписьРеестраНаФорме(СтруктураЗаполнения)
	Id = СтруктураЗаполнения.Id;
	
	НайденныеСтроки = сбисОбъектОбработкиНаКлиенте().LongOperations.НайтиСтроки(Новый Структура("Id", Id));
	
	РезультатСтруктура = Новый Структура;
	
	Если НайденныеСтроки.Количество() Тогда
		СтрокаОперации = НайденныеСтроки[0];
		
		Если СтруктураЗаполнения.Свойство("Update") И ЗначениеЗаполнено(СтруктураЗаполнения.Update) Тогда
			Если СтрокаОперации.Update >= СтруктураЗаполнения.Update Тогда
				Возврат Неопределено;	
			КонецЕсли;
			СтрокаОперации.Update = СтруктураЗаполнения.Update;
		Иначе 
			СтруктураОшибки = Новый Структура("code,message,details", 204, "Неверные параметры метода", "Не заполнено ключевое поле ""Update"", необходимое для формирования записи реестра длительных операций.");
			РезультатСтруктура.Вставить("СтруктураОшибки", СтруктураОшибки);
			Возврат РезультатСтруктура;
		КонецЕсли;
		
		Если СтруктураЗаполнения.Свойство("State") И ЗначениеЗаполнено(СтруктураЗаполнения.State) Тогда
			СтрокаОперации.State = СтруктураЗаполнения.State;
		Иначе 
			СтруктураОшибки = Новый Структура("code,message,details", 204, "Неверные параметры метода", "Не заполнено ключевое поле ""State"", необходимое для формирования записи реестра длительных операций.");
			РезультатСтруктура.Вставить("СтруктураОшибки", СтруктураОшибки);
			Возврат РезультатСтруктура;
		КонецЕсли;
		
		Если СтруктураЗаполнения.Свойство("Detail") И ЗначениеЗаполнено(СтруктураЗаполнения.Detail) Тогда
			СтрокаОперации.Detail = СтруктураЗаполнения.Detail;
		Иначе
			СтрокаОперации.Detail = "";
		КонецЕсли;
		
		Если СтруктураЗаполнения.Свойство("Progress") И ЗначениеЗаполнено(СтруктураЗаполнения.Progress) Тогда
			СтрокаОперации.Progress = СтруктураЗаполнения.Progress;
		КонецЕсли;
		
	Иначе
		
		СтрокаОперации = сбисОбъектОбработкиНаКлиенте().LongOperations.Добавить();
		
		РезультатСтруктура.Вставить("ИндексСтроки", СтрокаОперации.НомерСтроки - 1);

		СтрокаОперации.New = Истина;
		
		Если СтруктураЗаполнения.Свойство("Id") И ЗначениеЗаполнено(СтруктураЗаполнения.Id) Тогда
			СтрокаОперации.Id = СтруктураЗаполнения.Id;
		Иначе 
			сбисОбъектОбработкиНаКлиенте().LongOperations.Удалить(СтрокаОперации);
			СтруктураОшибки = Новый Структура("code,message,details", 204, "Неверные параметры метода", "Не заполнено ключевое поле ""Id"", необходимое для формирования записи реестра длительных операций.");
			РезультатСтруктура.Вставить("СтруктураОшибки", СтруктураОшибки);
			Возврат РезультатСтруктура;
		КонецЕсли;
		
		Если СтруктураЗаполнения.Свойство("Operation") И ЗначениеЗаполнено(СтруктураЗаполнения.Operation) Тогда
			СтрокаОперации.Operation = СтруктураЗаполнения.Operation;
		Иначе
			сбисОбъектОбработкиНаКлиенте().LongOperations.Удалить(СтрокаОперации);
			СтруктураОшибки = Новый Структура("code,message,details", 204, "Неверные параметры метода", "Не заполнено ключевое поле ""Operation"", необходимое для формирования записи реестра длительных операций.");
			РезультатСтруктура.Вставить("СтруктураОшибки", СтруктураОшибки);
			Возврат РезультатСтруктура;
		КонецЕсли;
		
		Если СтруктураЗаполнения.Свойство("Begin") И ЗначениеЗаполнено(СтруктураЗаполнения.Begin) Тогда
			СтрокаОперации.Begin = СтруктураЗаполнения.Begin;
		Иначе
			сбисОбъектОбработкиНаКлиенте().LongOperations.Удалить(СтрокаОперации);
			СтруктураОшибки = Новый Структура("code,message,details", 204, "Неверные параметры метода", "Не заполнено ключевое поле ""Begin"", необходимое для формирования записи реестра длительных операций.");
			РезультатСтруктура.Вставить("СтруктураОшибки", СтруктураОшибки);
			Возврат РезультатСтруктура;
		КонецЕсли;
		
		Если СтруктураЗаполнения.Свойство("State") И ЗначениеЗаполнено(СтруктураЗаполнения.State) Тогда
			СтрокаОперации.State = СтруктураЗаполнения.State;
		Иначе 
			СтрокаОперации.State = "В обработке";
		КонецЕсли;
		
		Если СтруктураЗаполнения.Свойство("Detail") И ЗначениеЗаполнено(СтруктураЗаполнения.Detail) Тогда
			СтрокаОперации.Detail = СтруктураЗаполнения.Detail;
		КонецЕсли;
		
		Если СтруктураЗаполнения.Свойство("SabyObjName") И ЗначениеЗаполнено(СтруктураЗаполнения.SabyObjName) Тогда
			СтрокаОперации.SabyObjName = СтруктураЗаполнения.SabyObjName;
		Иначе
			сбисОбъектОбработкиНаКлиенте().LongOperations.Удалить(СтрокаОперации);
			СтруктураОшибки = Новый Структура("code,message,details", 204, "Неверные параметры метода", "Не заполнено ключевое поле ""SabyObjName"", необходимое для формирования записи реестра длительных операций.");
			РезультатСтруктура.Вставить("СтруктураОшибки", СтруктураОшибки);
			Возврат РезультатСтруктура;
		КонецЕсли;
		
		Если СтруктураЗаполнения.Свойство("SabyObjId") И ЗначениеЗаполнено(СтруктураЗаполнения.SabyObjId) Тогда
			СтрокаОперации.SabyObjId = СтруктураЗаполнения.SabyObjId;
		Иначе
			сбисОбъектОбработкиНаКлиенте().LongOperations.Удалить(СтрокаОперации);
			СтруктураОшибки = Новый Структура("code,message,details", 204, "Неверные параметры метода", "Не заполнено ключевое поле ""SabyObjId"", необходимое для формирования записи реестра длительных операций.");
			РезультатСтруктура.Вставить("СтруктураОшибки", СтруктураОшибки);
			Возврат РезультатСтруктура;
		КонецЕсли;
	КонецЕсли;
	
	Возврат Неопределено;
КонецФункции

&НаКлиенте
Процедура УдалитьЗаписиСтарше3ДнейСДатыПоследнегоПросмотра()
	СрокАвтоочисткиЗаписей = 3 * 24 * 60 * 60; //3 дня в секундах
	ВсегоСтрок = сбисОбъектОбработкиНаКлиенте().LongOperations.Количество();
	Сч = 0;
	Пока Сч < ВсегоСтрок Цикл
		СтрокаОперации = сбисОбъектОбработкиНаКлиенте().LongOperations.Получить(Сч);
		Если ДатаПросмотраСтатусовПредыдущегоСеанса - СтрокаОперации.Update > СрокАвтоочисткиЗаписей 
			И НЕ СтрокаОперации.New Тогда
			сбисОбъектОбработкиНаКлиенте().LongOperations.Удалить(СтрокаОперации);
			ВсегоСтрок = ВсегоСтрок - 1;
		Иначе
			Сч = Сч + 1;
		КонецЕсли;		
	КонецЦикла;
КонецПроцедуры

// Обновляет количественные показатели длительных операций обновляет заголовок кнопки на форме главного окна:
// - КоличествоОперацийВсего
// - КоличествоНовыхОпераций
&НаКлиенте
Процедура ОбновитьКонтент()
	КоличествоОперацийВсего = сбисОбъектОбработкиНаКлиенте().LongOperations.Количество();
	
	КоличествоНовыхОпераций = 0;
	сбисОбъектОбработкиНаКлиенте().LongOperations.Сортировать("Begin Убыв");
	Для каждого СтрокаОперации Из сбисОбъектОбработкиНаКлиенте().LongOperations Цикл
		Если СтрокаОперации.New Тогда
			КоличествоНовыхОпераций = КоличествоНовыхОпераций + 1;
		КонецЕсли;
		
		Если СтрокаОперации.State = "Подготовка" Тогда
			СтрокаОперации.StatePicture = 0;
		ИначеЕсли СтрокаОперации.State = "В обработке" Тогда
			СтрокаОперации.StatePicture = 4;
		ИначеЕсли СтрокаОперации.State = "Ошибка" Тогда
			СтрокаОперации.StatePicture = 3;
		ИначеЕсли СтрокаОперации.State = "Успех" Тогда
			СтрокаОперации.StatePicture = 6;
		Иначе
			СтрокаОперации.StatePicture = 7;
		КонецЕсли;
	КонецЦикла;

	КнопкаДлительныеОперации = сбисЭлементФормы(ЭтаФорма.ВладелецФормы, "КнопкаДлительныеОперации");
	Если КоличествоНовыхОпераций Тогда
		КнопкаДлительныеОперации.Шрифт = Новый Шрифт( , , Истина);
	Иначе
		КнопкаДлительныеОперации.Шрифт = Новый Шрифт( , , Ложь);
	КонецЕсли;
	
	КнопкаДлительныеОперации.Заголовок = КоличествоОперацийВсего;
КонецПроцедуры

// Делает строки с непросмотренными операциями жирными 
// В 8.1 нужно полностью закомментировать управляемую часть
&НаСервере
Процедура УстановитьУсловноеОформлениеРеестра()
	#Если НЕ ТолстыйКлиентОбычноеПриложение Тогда
		// Жирным шрифтом выделяем строки с непрочитанными статусами
		ЭлементОформления = ЭтаФорма.УсловноеОформление.Элементы.Добавить();
		ПолеЭлемента = ЭлементОформления.Поля.Элементы.Добавить();
		ПолеЭлемента.Поле = Новый ПолеКомпоновкиДанных(Элементы.LongOperationsSabyObjName.Имя);
		ПолеЭлемента = ЭлементОформления.Поля.Элементы.Добавить();
		ПолеЭлемента.Поле = Новый ПолеКомпоновкиДанных(Элементы.LongOperationsBegin.Имя);
		ПолеЭлемента = ЭлементОформления.Поля.Элементы.Добавить();
		ПолеЭлемента.Поле = Новый ПолеКомпоновкиДанных(Элементы.LongOperationsUpdate.Имя);
		ПолеЭлемента = ЭлементОформления.Поля.Элементы.Добавить();
		ПолеЭлемента.Поле = Новый ПолеКомпоновкиДанных(Элементы.LongOperationsOperation.Имя);
		ПолеЭлемента = ЭлементОформления.Поля.Элементы.Добавить();
		ПолеЭлемента.Поле = Новый ПолеКомпоновкиДанных(Элементы.LongOperationsProgress.Имя);
		ПолеЭлемента = ЭлементОформления.Поля.Элементы.Добавить();
		ПолеЭлемента.Поле = Новый ПолеКомпоновкиДанных(Элементы.LongOperationsDetail.Имя);
		ОтборЭлемента = ЭлементОформления.Отбор.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
		ОтборЭлемента.ЛевоеЗначение = Новый ПолеКомпоновкиДанных("Объект.LongOperations.New");
		ОтборЭлемента.ВидСравнения = ВидСравненияКомпоновкиДанных.Равно;
		ОтборЭлемента.ПравоеЗначение = Истина;
		ЭлементОформления.Оформление.УстановитьЗначениеПараметра("Шрифт", Новый Шрифт( , ,Истина));
	#КонецЕсли	
КонецПроцедуры

// Помечает записи прочитанными и устанавливает текущую дату как дату просмотра статусов
&НаКлиенте
Процедура СделатьЗаписиПрочитаннымиИОбновитьДатуПросмотра()
	ДатаПросмотраСтатусов = ТекущаяДата();
	
	Для каждого СтрокаОперации Из сбисОбъектОбработкиНаКлиенте().LongOperations Цикл
		СтрокаОперации.New = Ложь;
	КонецЦикла;
КонецПроцедуры 


////////////////////////////////////////////////////
////////////////////Фильтры///////////////////
////////////////////////////////////////////////////

// Перечисление всех возможных длительных операций
&НаСервере
Процедура ЗаполнитьСписокДлительныхОпераций()
	СписокДлительныхОпераций.Добавить("");
	СписокДлительныхОпераций.Добавить("Проверка статусов кодов маркировки");
	СписокДлительныхОпераций.Добавить("Проверка статусов кодов РНПТ");
	СписокДлительныхОпераций.Добавить("Эмиссия кодов маркировки");
	СписокДлительныхОпераций.Добавить("Ввод в оборот кодов маркировки");
	СписокДлительныхОпераций.Добавить("Списание кодов маркировки");
КонецПроцедуры

// Перечисление всех возможных статусов длительных операций
&НаСервере
Процедура ЗаполнитьСписокСтатусовДлительныхОпераций()
	СписокСтатусовДлительныхОпераций.Добавить("",  "");
	СписокСтатусовДлительныхОпераций.Добавить("Подготовка",  "Подготовка");
	СписокСтатусовДлительныхОпераций.Добавить("В обработке", "В обработке");
	СписокСтатусовДлительныхОпераций.Добавить("Ошибка",      "Ошибка");
	СписокСтатусовДлительныхОпераций.Добавить("Успех",       "Успех");
	СписокСтатусовДлительныхОпераций.Добавить("Отменено",    "Отменено");
КонецПроцедуры

// Перечисление все и непрочитанные
&НаСервере
Процедура ЗаполнитьСписокВсеНепрочитанные()
	СписокВсеНепрочитанные.Добавить("Все",  "Все");
	СписокВсеНепрочитанные.Добавить("Непрочитанные",  "Непрочитанные");
КонецПроцедуры

// Очистка фильтра
&НаКлиенте
Процедура ФильтрОчистить(Элемент)
	ОчиститьЗначенияФильтров();
	ФильтрОбновитьПанель();	
	УстановитьФильтрРеестра();
КонецПроцедуры

// Обновление палели фильтра в правом верхнем углу
&НаКлиенте
Процедура ФильтрОбновитьПанель()
	Если ЗначениеЗаполнено(ФильтрОперация) Тогда
		сбисЭлементФормы(ЭтаФорма, "ВыборФильтраОперации").Заголовок = ФильтрОперация;
	Иначе
		сбисЭлементФормы(ЭтаФорма, "ВыборФильтраОперации").Заголовок = "Все операции";
	КонецЕсли;
	
	Если ЗначениеЗаполнено(ФильтрСтатус) Тогда
		сбисЭлементФормы(ЭтаФорма, "ВыбратьФильтрСтатуса").Заголовок = ФильтрСтатус;
	Иначе
		сбисЭлементФормы(ЭтаФорма, "ВыбратьФильтрСтатуса").Заголовок = "В любом статусе";
	КонецЕсли;
	
	сбисЭлементФормы(ЭтаФорма, "ВыбратьФильтрВсеНепрочитанные").Заголовок = ФильтрВсеНепрочитанные;
КонецПроцедуры

// Очистка значений фильтра
&НаКлиенте
Процедура ОчиститьЗначенияФильтров()
	ФильтрОперация			= "";
	ФильтрСтатус   			= "";
	ФильтрВсеНепрочитанные	= "Все";
КонецПроцедуры

// Установка значений фильтра
&НаКлиенте
Процедура УстановитьФильтрРеестра() 
	#Если ТолстыйКлиентОбычноеПриложение Тогда
		Если ЗначениеЗаполнено(ФильтрОперация) Тогда
			ЭлементыФормы.LongOperations.ОтборСтрок.Operation.Установить(ФильтрОперация);
		Иначе
			ЭлементыФормы.LongOperations.ОтборСтрок.Operation.Установить(,Ложь);
		КонецЕсли;
		Если ЗначениеЗаполнено(ФильтрСтатус) Тогда
			ЭлементыФормы.LongOperations.ОтборСтрок.State.Установить(ФильтрСтатус);
		Иначе
			ЭлементыФормы.LongOperations.ОтборСтрок.State.Установить(,Ложь);
		КонецЕсли;
		Если ФильтрВсеНепрочитанные = "Непрочитанные" Тогда
			ЭлементыФормы.LongOperations.ОтборСтрок.New.Установить(Истина);
		Иначе
			ЭлементыФормы.LongOperations.ОтборСтрок.New.Установить(,Ложь);
		КонецЕсли;		
	#Иначе
		СтруктураОтбора = Новый Структура;
		Если ЗначениеЗаполнено(ФильтрОперация) Тогда
			СтруктураОтбора.Вставить("Operation", ФильтрОперация);
		КонецЕсли;
		Если ЗначениеЗаполнено(ФильтрСтатус) Тогда
			СтруктураОтбора.Вставить("State", ФильтрСтатус);
		КонецЕсли;
		Если ФильтрВсеНепрочитанные = "Непрочитанные" Тогда
			СтруктураОтбора.Вставить("New", Истина);
		КонецЕсли;
		
		Элементы.LongOperations.ОтборСтрок = Новый ФиксированнаяСтруктура(СтруктураОтбора);
	#КонецЕсли
КонецПроцедуры

// Открытие документа на форме ФормаПросмотрДокумента 
&НаКлиенте
Процедура ОткрытьПоказатьДокумент(SabyObjId)
	ГлавноеОкно = ЭтаФорма.ВладелецФормы;
	Кэш = ГлавноеОкно.Кэш;
	
	МассивПакетов = Новый Массив;
	ПолныйСоставПакета = Новый Структура;
	
	фрм = ГлавноеОкно.сбисНайтиФормуФункции("НайтиДокументы1СПоПакетуСБИС", Кэш.ФормаРаботыСоСтатусами, "", Кэш);
	
	ПолныйСоставПакета = Кэш.Интеграция.ПрочитатьДокумент(Кэш, SabyObjId);
	
	Если ПолныйСоставПакета = Ложь Тогда
		Сообщить("Невозможно открыть объект. Не удалось получить состав пакета.");
		Возврат;
	КонецЕсли;
	МассивСлужебных = Новый Массив;
	Если ПолныйСоставПакета.Свойство("Вложение") Тогда
		фрм.НайтиДокументы1СПоПакетуСБИС(ПолныйСоставПакета, Кэш.Ини, ГлавноеОкно.Кэш.Парам.КаталогНастроек, МассивСлужебных);
		// Удалим служебные вложения
		счУдаленных = 0;
		Для Каждого Элемент Из МассивСлужебных Цикл
			ПолныйСоставПакета.Вложение.Удалить(Элемент - счУдаленных);
			счУдаленных = счУдаленных + 1;
		КонецЦикла;
		МассивПакетов.Добавить(ПолныйСоставПакета);
	Иначе
		Сообщить("В пакете " + ПолныйСоставПакета.Название + " отсутствуют вложения.");
		Возврат;
	КонецЕсли;
	
	Если МассивПакетов.Количество() > 0 Тогда
		ПолныйСоставПакета = МассивПакетов[0];
		сч = 0;
		Для Каждого Элемент Из ПолныйСоставПакета.Вложение Цикл
			Если ПолныйСоставПакета.Свойство("Событие") Тогда
				Элемент.Вставить("Событие", ПолныйСоставПакета.Событие);
			КонецЕсли;
			ТекстHTML = Кэш.Интеграция.ПолучитьHTMLВложения(Кэш, ПолныйСоставПакета.Идентификатор, Элемент);
			ПолныйСоставПакета.Вложение[сч].Вставить("ТекстHTML",ТекстHTML);
			ПолныйСоставПакета.Вложение[сч].Вставить("Отмечен",Истина);
			сч = сч + 1;
		КонецЦикла;
		
		ДополнительныеПараметры = Новый Структура;
		ДополнительныеПараметры.Вставить("ТипДокумента",  "Полученные");
		ДополнительныеПараметры.Вставить("ТекущийРаздел", "Полученные");
		
		Если МодульОбъектаКлиент().ПолучитьЗначениеФичи(Новый Структура("НазваниеФичи", "РасширенныйФункционалСопоставленияНоменклатуры")) Тогда 
			фрм = ГлавноеОкно.сбисНайтиФормуФункции("ПоказатьДокумент","ФормаПросмотрДокументаРасширенноеСопоставление","", Кэш);
			фрм.ПоказатьДокумент(Кэш,ПолныйСоставПакета, ДополнительныеПараметры); 	
		Иначе
			фрм = ГлавноеОкно.сбисНайтиФормуФункции("ПоказатьДокумент", "ФормаПросмотрДокумента","", Кэш);
			фрм.ПоказатьДокумент(Кэш,ПолныйСоставПакета, ДополнительныеПараметры);
		КонецЕсли; 
	Иначе 
		Сообщить("Невозможно открыть объект. Массив пакетов пуст.");
		Возврат;
	КонецЕсли;
КонецПроцедуры

// Общая процедура, вызываемая после выбора фильтра
&НаКлиенте
Процедура ВыбратьФильтрОбщая(ИмяФильтра, СписокЗначенийФильтра)
	ДопПараметры = Новый Структура("ИмяФильтра", ИмяФильтра);
	ТекущийЭлементФильтра = СписокЗначенийФильтра.НайтиПоЗначению(ЭтаФорма[ДопПараметры.ИмяФильтра]);
	#Если ТолстыйКлиентОбычноеПриложение Тогда
		ВыбранноеЗначение = ВыбратьИзСписка(СписокЗначенийФильтра, , ТекущийЭлементФильтра);
		ВыбратьФильтрОбщая_Завершение(ВыбранноеЗначение, ДопПараметры);
	#Иначе
		ПоказатьВыборИзСписка(Новый ОписаниеОповещения("ВыбратьФильтрОбщая_Завершение", ЭтаФорма, ДопПараметры), СписокЗначенийФильтра, , ТекущийЭлементФильтра);
	#КонецЕсли
КонецПроцедуры

&НаКлиенте
Процедура ВыбратьФильтрОбщая_Завершение(ВыбранноеЗначение, ДопПараметры) Экспорт
	Если ВыбранноеЗначение = Неопределено ИЛИ НЕ ДопПараметры.Свойство("ИмяФильтра") Тогда
		Возврат;	
	КонецЕсли;
	
	ЭтаФорма[ДопПараметры.ИмяФильтра] = ВыбранноеЗначение.Значение;
		
	ФильтрОбновитьПанель();	
	УстановитьФильтрРеестра();
КонецПроцедуры

// Получение фильтров реестра в виде структуры
Функция ПолучитьСтруктуруФильтров()
	СтруктураФильтров = Новый Структура;
	
	СтруктураФильтров.Вставить("ФильтрОперация",	ФильтрОперация);
	СтруктураФильтров.Вставить("ФильтрСтатус", 		ФильтрСтатус);
	
	Возврат СтруктураФильтров;
КонецФункции


//////////////////////////////////////////////////////////////////////////////////

////////////////////// Обычное приложение/////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////

Процедура LongOperationsПриВыводеСтроки(Элемент, ОформлениеСтроки, ДанныеСтроки)
	Если ДанныеСтроки.New Тогда
		ОформлениеСтроки.Шрифт = Новый Шрифт( , , Истина);		
	КонецЕсли; 
	
	ОформлениеСтроки.Ячейки.LongOperationsStatePicture.ОтображатьТекст		= Ложь;
	ОформлениеСтроки.Ячейки.LongOperationsStatePicture.ОтображатьКартинку	= Истина;
	ОформлениеСтроки.Ячейки.LongOperationsStatePicture.ИндексКартинки		= ДанныеСтроки.StatePicture;
КонецПроцедуры
