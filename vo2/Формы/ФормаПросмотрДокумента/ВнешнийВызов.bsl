
// Процедура открывает форму просмотра пакета документов	
&НаКлиенте
Процедура ПоказатьДокумент(ВходящийКэш, Пакет, ДополнительныеПараметры = Неопределено) Экспорт
	МестныйКэш		= ВходящийКэш;
	Кэш 			= ВходящийКэш;
	СоставПакета	= Пакет;
	
	ДокументРазобран		= Ложь;
	ДокументУчетаРазобран	= Ложь;
	ВложенияУчетаРазобраны	= Ложь;
	ОбновлятьГлавноеОкно	= Ложь;
	ЕстьВходящиеВложения	= Ложь;
	ОтметитьВсе				= Истина;
	ЭтоПустойПакет			= Ложь;
	ОткрытьПакет			= Истина;
	
	ЗаголовокПакета	= "";
	ПакетОрганизация= "";
	ПакетКонтрагент	= "";
	АбонентскийЯщик = "Определять автоматически"; 
	
	//1189641556 
	ПараметрыРаботы = Новый Структура;
	
	сбисЭлементФормы(ЭтаФорма,"ТулБар").Видимость = Истина;
	сбисЭлементФормы(ЭтаФорма,"ПодготовитьКЗагрузке").Видимость = Истина;
	сбисЭлементФормы(ЭтаФорма,"ЗагрузитьНаВложении").Видимость = Ложь;
	сбисЭлементФормы(ЭтаФорма,"ПереключитьТипВложений").Видимость =		СоставПакета.Свойство("ВложениеУчета")
																	И	СоставПакета.ВложениеУчета.Количество();
	ТаблицаДокументов.Очистить();
	сбисУстановитьHTML("<html></html>");
	ЭтаФорма.Открыть();
	
	//+++ МАИ 1183311220
	ТекущийРаздел = МестныйКэш.Разделы["р"+МестныйКэш.Текущий.Раздел];
	ТипДокумента = МестныйКэш.Текущий.ТипДок;
	Если ДополнительныеПараметры <> Неопределено Тогда
		Если ТипЗнч(ДополнительныеПараметры) = Тип("Структура") Тогда
			Если ДополнительныеПараметры.Свойство("ТипДокумента") Тогда
				ТипДокумента = ДополнительныеПараметры.ТипДокумента;	
			КонецЕсли;	
			Если ДополнительныеПараметры.Свойство("ТекущийРаздел") Тогда
				ТекущийРаздел = ДополнительныеПараметры.ТекущийРаздел;	
			КонецЕсли;
		КонецЕсли;
	КонецЕсли;
	//--- МАИ 1183311220
	
	Если Не	СоставПакета.Вложение.Количество() Тогда
		ЭтоПустойПакет = Истина;
		Если Не СоставПакета.Свойство("ДобавочныеСтроки") Тогда
			ОткрытьПакет = Ложь;
		КонецЕсли;
	КонецЕсли;
	
	Если Не ОткрытьПакет И Не Кэш.Парам.Меркурий Тогда // alo Меркурий
		Сообщить("В пакете отсутствуют вложения.");
		Возврат;
	КонецЕсли;
	
	Если Не ЭтоПустойПакет Тогда
		
		МодульОбъектаКлиент().ПолучитьЭлементФормыОбработки(ЭтаФорма, "ТабличнаяЧасть.Характеристика").Видимость = Ложь;
		
		#Если Не ТолстыйКлиентОбычноеПриложение Тогда

			Если Кэш.Ини.Конфигурация.Свойство("ИмяОтбораХарактеристики") Тогда
				ИмяОтбораХарактеристики = СокрЛП(СтрЗаменить(Кэш.Ини.Конфигурация.ИмяОтбораХарактеристики.Значение,"'", ""));
			Иначе
				ИмяОтбораХарактеристики = "Номенклатура";
			КонецЕсли;
			ИмяРеквизитаКонтрагентаВДоговоре = "Контрагент";
			Если Кэш.Ини.Конфигурация.Свойство("Договоры_Контрагент") Тогда
				ИмяРеквизитаКонтрагентаВДоговоре = СокрЛП(Сред(Кэш.Ини.Конфигурация.Договоры_Контрагент.Значение, Найти(Кэш.Ини.Конфигурация.Договоры_Контрагент.Значение, ".")+1));	
			КонецЕсли;
			Договор1СУстановитьОтбор(ИмяРеквизитаКонтрагентаВДоговоре);
			
		#КонецЕсли
	КонецЕсли;
	
	фрм = МестныйКэш.ГлавноеОкно.сбисНайтиФормуФункции("УстановитьВидимостьЭлементовВформеПросмотра","Раздел_"+ТекущийРаздел+"_"+ТипДокумента,"Раздел_"+ТекущийРаздел+"_Шаблон",МестныйКэш);	
	фрм.УстановитьВидимостьЭлементовВформеПросмотра(ЭтаФорма, СоставПакета, Кэш.Парам);
	фрм = МестныйКэш.ГлавноеОкно.сбисНайтиФормуФункции("сбисСписокДополнительныхОпераций","Раздел_"+ТекущийРаздел+"_"+ТипДокумента,"Раздел_"+ТекущийРаздел+"_Шаблон",МестныйКэш);	
	СписокДопОпераций = фрм.сбисСписокДополнительныхОпераций(Кэш, ЭтаФорма);
	ЗаполнитьПрохождение(СоставПакета);
	
	ЭлементКонтент = Кэш.ГлавноеОкно.СбисПолучитьЭлементФормы(ЭтаФорма, "Контент");
	Кэш.ГлавноеОкно.СбисПолучитьЭлементФормы(ЭтаФорма, "Контент").ТекущаяСтраница = Кэш.ГлавноеОкно.СбисПолучитьЭлементФормы(ЭлементКонтент, "Просмотр");
	//ЭтаФорма.Элементы.Контент.ТекущаяСтраница = ЭтаФорма.Элементы.Контент.ПодчиненныеЭлементы.Просмотр;
	Если СоставПакета.Свойство("НашаОрганизация") Тогда
		ПакетОрганизация = МестныйКэш.ОбщиеФункции.сбисНазваниеСтороны(СоставПакета.НашаОрганизация);
	КонецЕсли;
	Если СоставПакета.Свойство("Контрагент") Тогда
		ПакетКонтрагент = МестныйКэш.ОбщиеФункции.сбисНазваниеСтороны(СоставПакета.Контрагент);
	КонецЕсли;
		
	Грузополучатель = МодульОбъектаКлиент().СоставПакета_Получить(СоставПакета, "Грузополучатель");

	Если ЗначениеЗаполнено(Грузополучатель) Тогда
		ПакетГрузополучатель = МестныйКэш.ОбщиеФункции.сбисНазваниеСтороны(Грузополучатель);
	Иначе
		сбисЭлементФормы(ЭтаФорма, "ГруппаГрузополучатель").Видимость = Ложь;
	КонецЕсли;

	//1189641556
	ФункционалПоддержкиМаркировки = МодульОбъектаКлиент().ПолучитьЗначениеФичи(Новый Структура("НазваниеФичи", "ПоддержкаМаркировки"));
	ФункционалНовыеКонтрагенты = МодульОбъектаКлиент().ПрименятьФункционалНовыеКонтрагенты(Новый Структура("СоставПакета", СоставПакета));
	ФункционалПоддержкиПрослеживаемости = МодульОбъектаКлиент().ПолучитьЗначениеФичи(Новый Структура("НазваниеФичи", "ПоддержкаПрослеживаемости")); 
	ФункционалПоддержкиНовойМаркировки = МодульОбъектаКлиент().ПолучитьЗначениеФичи(Новый Структура("НазваниеФичи", "ПоддержкаНовойМаркировки"));
	
	Если  ФункционалНовыеКонтрагенты Тогда
		
		УстановитьТипыРеквизитовСторон();
		сбисЭлементФормы(ЭтаФорма, "УчетОрганизация").Доступность = Ложь;
		сбисЭлементФормы(ЭтаФорма, "УчетКонтрагент").Доступность = Ложь;
		сбисЭлементФормы(ЭтаФорма, "УчетГрузополучатель").Доступность = Ложь;
		
		сбисЭлементФормы(ЭтаФорма, "УчетОрганизация").Видимость = СоставПакета.Свойство("Направление") 
			И Не УчетОрганизация = Неопределено;
		
		сбисЭлементФормы(ЭтаФорма, "УчетКонтрагент").Видимость = СоставПакета.Свойство("Направление") 
			И Не УчетКонтрагент = Неопределено;  
			
		сбисЭлементФормы(ЭтаФорма, "ГруппаГрузополучатель").Видимость = Не Грузополучатель = Неопределено
			И Кэш.Парам.Свойство("ТипГрузополучателя")
			И Не Кэш.Парам.ТипГрузополучателя = "ГрузополучательНеВедется"; 
	Иначе 
		сбисЭлементФормы(ЭтаФорма, "УчетОрганизация").Видимость = Ложь;
		сбисЭлементФормы(ЭтаФорма, "УчетКонтрагент").Видимость = Ложь;
		сбисЭлементФормы(ЭтаФорма, "ГруппаГрузополучатель").Видимость = Ложь;
	КонецЕсли;

	Если СоставПакета.Свойство("Примечание") Тогда
		ПакетКомментарий = СоставПакета.Примечание;
	Иначе
		ПакетКомментарий = "";
	КонецЕсли;
	
	Если Не Кэш.Разделы.Свойство("Текущий") Тогда
		Кэш.Разделы.Вставить("Текущий", Новый Структура);
	КонецЕсли;
	Кэш.Разделы.Текущий.Вставить("ФормаПросмотрДокумента", Кэш.Текущий);
	сбисЭлементФормы(ЭтаФорма,"ПереключитьТипВложений").Заголовок = "Показать вложения СБИС";
	
	ИмяРеквизитаВложений = "Вложение";
	
	//1189641556 
	ПараметрыРаботы.Вставить("МаркировкаЗаполнена",Ложь); 
	ПараметрыРаботы.Вставить("ПрослеживаемостьЗаполнена",Ложь);
	
	// До 24.3206
	//Состояние = МодульОбъектаКлиент().СоставПакета_Получить(СоставПакета, "Состояние");
	//
	//МодульОбъектаКлиент().ПолучитьЭлементФормыОбработки(ЭтаФорма, "Записать").Видимость = ЗначениеЗаполнено(Состояние)
	//	И Состояние.Свойство("Код")
	//	И Состояние.Код = "0";
	// ----------------------------------------------------------------------------------------
	// Удалить после 24.3206
	МодульОбъектаКлиент().ПолучитьЭлементФормыОбработки(ЭтаФорма, "Записать").Видимость = Ложь;
	// ----------------------------------------------------------------------------------------
	Если МодульОбъектаКлиент().ПолучитьЗначениеФичи("РасширенныйФункционалСопоставленияНоменклатуры") Тогда	
		МодульОбъектаКлиент().ПолучитьЭлементФормыОбработки(ЭтаФорма, "ТабличнаяЧастьЗаписатьСопоставлениеНоменклатуры").Доступность = Ложь;
		МодульОбъектаКлиент().ПолучитьЭлементФормыОбработки(ЭтаФорма, "ТабличнаяЧастьОткрытьФормуСопоставления").Доступность = Ложь;
		МодульОбъектаКлиент().ПолучитьЭлементФормыОбработки(ЭтаФорма, "ТабличнаяЧастьСоздатьСопоставитьНоменклатуруВ1С").Доступность = Ложь;
		МодульОбъектаКлиент().ПолучитьЭлементФормыОбработки(ЭтаФорма, "ОтметитьВсе").Доступность = Ложь; 
	КонецЕсли;
	//--------------------------------------

	ОбновитьПоляФормыПоДокументуСБИС(СоставПакета);

	#Если ТолстыйКлиентОбычноеПриложение Тогда
		ЭтаФорма.Открыть();
	#Иначе
		ЭтаФорма.Элементы.ТаблицаДокументов.Обновить();
		Если ТаблицаДокументов.Количество() Тогда // alo Меркурий
			НомерСтроки = ТаблицаДокументов[0];
			Если МестныйКэш.ПараметрыСистемы.Клиент.УправляемоеПриложение Тогда
				НомерСтроки = НомерСтроки.ПолучитьИдентификатор();
			КонецЕсли;
			сбисЭлементФормы(ЭтаФорма,"ТаблицаДокументов").ТекущаяСтрока = НомерСтроки;
		КонецЕсли;									// alo Меркурий
		ТаблицаДокументовПриАктивизацииЯчейки(сбисЭлементФормы(ЭтаФорма, "ТаблицаДокументов"));
		
		ЭтаФорма.ОбновитьОтображениеДанных();
	#КонецЕсли
	
КонецПроцедуры 

