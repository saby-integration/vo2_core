
// функции для совместимости кода 
&НаКлиенте
Функция СбисЭлементФормы(Форма,ИмяЭлемента) 
	
	Если ТипЗнч(ЭтаФорма) = Тип("УправляемаяФорма") Тогда
		Возврат Форма.Элементы.Найти(ИмяЭлемента);
	КонецЕсли;
	Возврат Форма.ЭлементыФормы.Найти(ИмяЭлемента);  
	
КонецФункции

&НаКлиенте
Функция СбисПолучитьСтраницу(Элемент, ИмяСтраницы)
	
	Если ТипЗнч(ЭтаФорма) = Тип("УправляемаяФорма") Тогда
		Возврат Элемент.ПодчиненныеЭлементы[ИмяСтраницы];
	КонецЕсли;
	Возврат Элемент.Страницы[ИмяСтраницы]; 
	
КонецФункции
//------------------------------------------------------
&НаКлиенте
Процедура ПоказатьДокумент(Кэш, СтрТабл) Экспорт 
	
	// Процедура открывает окно просмотра документа		
	ГлавноеОкно = Кэш.ГлавноеОкно;
	МассивПакетов = ПодготовитьСтруктуруДокумента(СтрТабл, Кэш);
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
			сч = сч+1;
		КонецЦикла;
		
		Если МодульОбъектаКлиент().ПолучитьЗначениеФичи(Новый Структура("НазваниеФичи", "РасширенныйФункционалСопоставленияНоменклатуры")) Тогда 
			фрм = ГлавноеОкно.сбисНайтиФормуФункции("ПоказатьДокумент","ФормаПросмотрДокументаРасширенноеСопоставление","", Кэш);
			фрм.ПоказатьДокумент(Кэш,ПолныйСоставПакета); 	
		Иначе
			фрм = ГлавноеОкно.сбисНайтиФормуФункции("ПоказатьДокумент", "ФормаПросмотрДокумента","", Кэш);
			фрм.ПоказатьДокумент(Кэш,ПолныйСоставПакета);
		КонецЕсли;  
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Функция ЗаполнитьПрохождение(СоставПакета) Экспорт   
	
	СтруктураСобытий = МодульОбъектаКлиент().ПолучитьФормуОбработки("РаботаСДокументами1С").ЗаполнитьПрохождение(МестныйКэш, СоставПакета, Новый Структура);
	
	Возврат СтруктураСобытий;

КонецФункции  

&НаКлиенте
Процедура НаСменуРаздела(Кэш) Экспорт
	// Процедура обновляет панель массовых операций, панель фильтра, контекстное меню при смене раздела		
	фрм = Кэш.ГлавноеОкно.сбисНайтиФормуФункции("НаСменуРаздела","Раздел_Отправленные_Отправленные","", Кэш);
	фрм.НаСменуРаздела(Кэш);
КонецПроцедуры

&НаКлиенте
Функция ПодготовитьСтруктуруДокумента(СтрокаСпискаДокументов, Кэш) Экспорт
// функция формирует структуру данных по пакету электронных документов, необходимую для его предварительного просмотра		
	Возврат Кэш.ОбщиеФункции.ПодготовитьСтруктуруДокументаСбис(СтрокаСпискаДокументов, Кэш);	
КонецФункции

&НаКлиенте
Процедура ФильтрОчистить(Кэш) Экспорт
// Процедура устанавливает значения фильтра по-умолчанию для текущего раздела	
	ГлавноеОкно = Кэш.ГлавноеОкно;
	
	ОписаниеТиповФильтра = МодульОбъектаКлиент().ПолучитьЗначениеПараметраТекущегоСеанса("ТипыПолейФильтра");
	Если Не ТипЗнч(ОписаниеТиповФильтра) = Тип("Структура") Тогда
		ОписаниеТиповФильтра = Новый Структура;
	КонецЕсли;
	
	Если ТипЗнч(ЭтаФорма) = Тип("УправляемаяФорма") Тогда
		ГлавноеОкно.ФильтрПериод = "За весь период";
	Иначе
		ГлавноеОкно.ФильтрПериод = "0";
	КонецЕсли;
	Если ОписаниеТиповФильтра.Свойство("ФильтрОрганизация") Тогда
		ГлавноеОкно.ФильтрОрганизация = ОписаниеТиповФильтра.ФильтрОрганизация.ПривестиЗначение();
	Иначе	
		ГлавноеОкно.ФильтрОрганизация = "";
	КонецЕсли;
	Если ОписаниеТиповФильтра.Свойство("ФильтрКонтрагент") Тогда
		ГлавноеОкно.ФильтрКонтрагент = ОписаниеТиповФильтра.ФильтрКонтрагент.ПривестиЗначение();
	Иначе	
		ГлавноеОкно.ФильтрКонтрагент = "";
	КонецЕсли;
	Если ОписаниеТиповФильтра.Свойство("ФильтрОтветственный") Тогда
		ГлавноеОкно.ФильтрОтветственный = ОписаниеТиповФильтра.ФильтрОтветственный.ПривестиЗначение();
	Иначе	
		ГлавноеОкно.ФильтрОтветственный = "";
	КонецЕсли;
	ГлавноеОкно.ФильтрДатаНач = "";
	ГлавноеОкно.ФильтрДатаКнц = "";
	ГлавноеОкно.ФильтрСостояние = ГлавноеОкно.СписокСостояний.НайтиПоИдентификатору(0).Значение;
	ГлавноеОкно.ФильтрКонтрагентПодключен = "";
	ГлавноеОкно.ФильтрКонтрагентСФилиалами = Ложь;
	ГлавноеОкно.ФильтрСтраница = 1;
	ГлавноеОкно.ФильтрМаска = "";
КонецПроцедуры

&НаКлиенте
Функция СбисСписокДополнительныхОпераций(Кэш, ФормаПросмотра) Экспорт 
	
	СписокДопОпераций = Новый СписокЗначений;
	СписокДопОпераций.Добавить("СбисПечать", "Печать");
	СписокДопОпераций.Добавить("СохранитьНаДиск", "Сохранить на диск");
	СписокДопОпераций.Добавить("ОткрытьДокументОнлайн", "Открыть документ на sbis.ru");
	СписокДопОпераций.Добавить("ОткрытьКонтрагентаОнлайнПоПакету", "Открыть контрагента на sbis.ru");
	ФормаПросмотра.СервисДопОперацияПросмотра(СписокДопОпераций);	// alo доп операции из инишки Сервис
	Возврат СписокДопОпераций;
	
КонецФункции

&НаКлиенте
Функция СохранитьНаДиск(Кэш, ФормаПросмотра) Экспорт
	ФормаПросмотра.СохранитьНаДискНажатие("");
КонецФункции 

&НаКлиенте
Функция СбисПечать(Кэш, ФормаПросмотра) Экспорт
	ФормаПросмотра.СбисПечать("");
КонецФункции   

&НаКлиенте
Функция ОткрытьДокументОнлайн(Кэш, ФормаПросмотра) Экспорт
	Если ФормаПросмотра<>Неопределено Тогда
	ФормаПросмотра.ОткрытьДокументОнлайн("");
	КонецЕсли;
КонецФункции  

