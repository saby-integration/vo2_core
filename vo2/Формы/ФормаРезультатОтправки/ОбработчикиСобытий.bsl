
&НаКлиенте
Процедура ПриОткрытии(Отказ)

	Отправлено = МестныйКэш.РезультатОтправки.Отправлено;
	НеОтправлено = МестныйКэш.РезультатОтправки.НеОтправлено;
	НеСформировано = МестныйКэш.РезультатОтправки.НеСформировано;
	
	ЭлементыДляВыключенияВидимости = Новый Массив;
	ЭлементыДляВключенияВидимости = Новый Массив;
	
	Если НеОтправлено = 0 Тогда
		ЭлементыДляВыключенияВидимости.Добавить("Причины");
	Иначе
		
		ЭлементыДляВключенияВидимости.Добавить("Причины");
		
		Если МодульОбъектаКлиент().РезультатОтправки_Версия(МестныйКэш.РезультатОтправки) = 2 Тогда
			
			//УФ
			ЭлементыДляВыключенияВидимости.Добавить("ТипыОшибокДокумент1С");
			ЭлементыДляВключенияВидимости.Добавить("ТипыОшибокДокументы1СНазвания");
			//ОФ
			ЭлементыДляВыключенияВидимости.Добавить("Документ1С");
			ЭлементыДляВключенияВидимости.Добавить("Документы1СНазвания");
			ОбработатьСписокВложенийСОшибкамиФЛК();             
			ЗаполнитьДеревоОшибок(МестныйКэш.РезультатОтправки); 
		Иначе
			
			//УФ
			ЭлементыДляВключенияВидимости.Добавить("ТипыОшибокДокумент1С");
			ЭлементыДляВыключенияВидимости.Добавить("ТипыОшибокДокументы1СНазвания");
			//ОФ
			ЭлементыДляВключенияВидимости.Добавить("Документ1С");
			ЭлементыДляВыключенияВидимости.Добавить("Документы1СНазвания");

			ЗаполнитьДеревоОшибокЛегаси(МестныйКэш.РезультатОтправки);	
			
		КонецЕсли;
		
	КонецЕсли;
	
	Если НеСформировано = 0 Тогда
		ЭлементыДляВыключенияВидимости.Добавить("НеСформировано");
	Иначе
		ЭлементыДляВключенияВидимости.Добавить("НеСформировано");	
	КонецЕсли;
		
	Если МестныйКэш.ПараметрыСистемы.Клиент.УправляемоеПриложение Тогда
		
		сбисЗаполнитьЗаголовкиФормы();
		
		Если МестныйКэш.РезультатОтправки.Свойство("ВремяФормирования") Тогда
			
			ЭлементыДляВключенияВидимости.Добавить("ВремяФормирования");
			ВремяФормирования = МестныйКэш.РезультатОтправки.ВремяФормирования;
		Иначе 
			
			ЭлементыДляВыключенияВидимости.Добавить("ВремяФормирования");
		КонецЕсли;
		
		Если МестныйКэш.РезультатОтправки.Свойство("ВремяОтправки") Тогда
			
			ЭлементыДляВключенияВидимости.Добавить("ВремяОтправки");
			ВремяОтправки = МестныйКэш.РезультатОтправки.ВремяОтправки;
		Иначе 
			
			ЭлементыДляВыключенияВидимости.Добавить("ВремяОтправки");
		КонецЕсли;
		
		Если МестныйКэш.РезультатОтправки.Свойство("ВремяНачала") Тогда
			
			ЭлементыДляВключенияВидимости.Добавить("ОбщееВремя");
			ОбщееВремя = (ТекущаяУниверсальнаяДатаВМиллисекундах() - МестныйКэш.РезультатОтправки.ВремяНачала)/1000;
		Иначе
			
			ЭлементыДляВыключенияВидимости.Добавить("ОбщееВремя");
		КонецЕсли;
		
		Если МестныйКэш.РезультатОтправки.Свойство("ВремяЗаписиСтатусов") Тогда
			
			ЭлементыДляВключенияВидимости.Добавить("ВремяЗаписиСтатусов");
			ВремяЗаписиСтатусов = МестныйКэш.РезультатОтправки.ВремяЗаписиСтатусов;
		Иначе
			
			ЭлементыДляВыключенияВидимости.Добавить("ВремяЗаписиСтатусов");
		КонецЕсли;
		
		Если МестныйКэш.РезультатОтправки.Свойство("ВремяПолученияДанных") Тогда
			ЭлементыДляВключенияВидимости.Добавить("ВремяПолученияДанных");
			ВремяПолученияДанных = МестныйКэш.РезультатОтправки.ВремяПолученияДанных;
		Иначе
			ЭлементыДляВыключенияВидимости.Добавить("ВремяПолученияДанных");
		КонецЕсли;
		
		Если МестныйКэш.РезультатОтправки.Свойство("ВремяОжиданияОтвета") Тогда
			
			ЭлементыДляВключенияВидимости.Добавить("ВремяОжиданияОтвета");
			ВремяОжиданияОтвета = МестныйКэш.РезультатОтправки.ВремяОжиданияОтвета;
		Иначе
			
			ЭлементыДляВыключенияВидимости.Добавить("ВремяОжиданияОтвета");
		КонецЕсли;
		
		#Если ТолстыйКлиентОбычноеПриложение Тогда
			HTMLПредставлениеОшибкиФЛК.УстановитьТекст("");	
		#Иначе
			HTMLПредставлениеОшибкиФЛК = Неопределено;	
		#КонецЕсли
		
		ЭлементыДляВыключенияВидимости.Добавить("HTMLПредставлениеОшибкиФЛК");
		
	КонецЕсли;
	
	ВключитьВидимость = Новый Структура("Видимость", Истина);
    ВыключитьВидимость = Новый Структура("Видимость", Ложь);
	ОбновитьНастройкиЭлементовФормы(ЭлементыДляВключенияВидимости, ВключитьВидимость);
	ОбновитьНастройкиЭлементовФормы(ЭлементыДляВыключенияВидимости, ВыключитьВидимость);
	
КонецПроцедуры

&НаКлиенте
Процедура ТипыОшибокПередРазворачиванием(Элемент, Строка, Отказ)
	
	Если НЕ МодульОбъектаКлиент().РезультатОтправки_Версия(МестныйКэш.РезультатОтправки) = 2 Тогда
		Возврат;
	КонецЕсли;  
	
	#Если Не ТолстыйКлиентОбычноеПриложение Тогда
		ТипыОшибокПередРазворачиваниемУФПереопределение(Строка);
		Возврат;	
	#КонецЕсли
	
	//Слетела авторизация, к примеру
	Если Элемент.ТекущиеДанные = Неопределено Тогда  
		Возврат;
	КонецЕсли;
	
	Если Элемент.ТекущиеДанные.КодОшибки = "729" Тогда
		
		ДокументСБИС = Элемент.ТекущиеДанные.ДокументСБИС;
		
		ПредставлениеОшибкиФЛК = МестныйКэш.ГлавноеОкно.сбисЭлементФормы(ЭтаФорма, "HTMLПредставлениеОшибкиФЛК");
			
		Попытка
			
			Если Элемент.ТекущиеДанные.ПротоколОшибки = "" Тогда
				
				HTMLПредставлениеОшибкиФЛКТекст = ПолучитьПредставлениеHTMLОшибкиФЛК(ДокументСБИС);
				
				//Для совместимости кода. "УстановитьТекст" не существует на УФ (с)Сычев
				#Если ТолстыйКлиентОбычноеПриложение Тогда
					ПредставлениеОшибкиФЛК.УстановитьТекст(HTMLПредставлениеОшибкиФЛКТекст);	
				#Иначе
					HTMLПредставлениеОшибкиФЛК = HTMLПредставлениеОшибкиФЛКТекст;	
				#КонецЕсли
				
				Элемент.ТекущиеДанные.ПротоколОшибки = HTMLПредставлениеОшибкиФЛКТекст;
				
			Иначе
				
				#Если ТолстыйКлиентОбычноеПриложение Тогда
					ПредставлениеОшибкиФЛК.УстановитьТекст(Элемент.ТекущиеДанные.ПротоколОшибки);	
				#Иначе
					HTMLПредставлениеОшибкиФЛК = Элемент.ТекущиеДанные.ПротоколОшибки;	
				#КонецЕсли
				
			КонецЕсли;
			
			ПредставлениеОшибкиФЛК.Видимость = Истина;
		Исключение
			
			ПредставлениеОшибкиФЛК.Видимость = Ложь;
			
		КонецПопытки;

	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ТипыОшибокВыбор(Элемент, Строка, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	
	Если Элемент.ТекущиеДанные.ТекстОшибки = "Ошибка ФЛК. Двойной клик покажет/скроет подробный отчёт" Тогда

		ПредставлениеОшибкиФЛК = МестныйКэш.ГлавноеОкно.сбисЭлементФормы(ЭтаФорма, "HTMLПредставлениеОшибкиФЛК");

		Если ПредставлениеОшибкиФЛК.Видимость = Ложь Тогда
			ТипыОшибокПередРазворачиванием(Элемент, Строка, Ложь);	
		Иначе
			ТипыОшибокПередСворачиванием(Элемент, Строка, Ложь);
		КонецЕсли;
		
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ТипыОшибокПередРазворачиваниемУФПереопределение(Строка)

	ТекущаяСтрока = ТипыОшибок.НайтиПоИдентификатору(Строка);
	
	Если ТекущаяСтрока = Неопределено Тогда  //Слетела авторизация, к примеру
		Возврат;
	КонецЕсли;
	
	Если ТекущаяСтрока.КодОшибки = "729" Тогда
		
		ДокументСБИС = ТекущаяСтрока.ДокументСБИС;
		
		ПредставлениеОшибкиФЛК = МестныйКэш.ГлавноеОкно.сбисЭлементФормы(ЭтаФорма, "HTMLПредставлениеОшибкиФЛК");
			
		Попытка
			
			Если ТекущаяСтрока.ПротоколОшибки = "" Тогда
				
				HTMLПредставлениеОшибкиФЛКТекст = ПолучитьПредставлениеHTMLОшибкиФЛК(ДокументСБИС);
				
				#Если ТолстыйКлиентОбычноеПриложение Тогда
					ПредставлениеОшибкиФЛК.УстановитьТекст(HTMLПредставлениеОшибкиФЛКТекст);	
				#Иначе
					HTMLПредставлениеОшибкиФЛК = HTMLПредставлениеОшибкиФЛКТекст;	
				#КонецЕсли
				
				ТекущаяСтрока.ПротоколОшибки = HTMLПредставлениеОшибкиФЛКТекст;
				
			Иначе
				
				#Если ТолстыйКлиентОбычноеПриложение Тогда
					ПредставлениеОшибкиФЛК.УстановитьТекст(ТекущаяСтрока.ПротоколОшибки);	
				#Иначе
					HTMLПредставлениеОшибкиФЛК = ТекущаяСтрока.ПротоколОшибки;	
				#КонецЕсли
				
			КонецЕсли;
			
			ПредставлениеОшибкиФЛК.Видимость = Истина;
		Исключение
			
			ПредставлениеОшибкиФЛК.Видимость = Ложь;	
			
		КонецПопытки;

	КонецЕсли;
	
	
КонецПроцедуры 

&НаКлиенте
Процедура ТипыОшибокПередСворачиванием(Элемент, Строка, Отказ)
	
	Если НЕ МодульОбъектаКлиент().РезультатОтправки_Версия(МестныйКэш.РезультатОтправки) = 2 Тогда
		Возврат;
	КонецЕсли;
	
	ПредставлениеОшибкиФЛК = МестныйКэш.ГлавноеОкно.сбисЭлементФормы(ЭтаФорма, "HTMLПредставлениеОшибкиФЛК");
	
	#Если ТолстыйКлиентОбычноеПриложение Тогда
		ПредставлениеОшибкиФЛК.УстановитьТекст("");	
	#Иначе
		HTMLПредставлениеОшибкиФЛК = Неопределено;	
	#КонецЕсли	
	
	ПредставлениеОшибкиФЛК.Видимость = Ложь;

КонецПроцедуры

&НаКлиенте
Процедура ПередЗакрытием(Отказ, СтандартнаяОбработка)
	
	ЭлементыДляВыключенияВидимости = Новый Массив;
	ЭлементыДляВыключенияВидимости.Добавить("HTMLПредставлениеОшибкиФЛК");
	
	ВыключитьВидимость = Новый Структура("Видимость", Ложь);
	ОбновитьНастройкиЭлементовФормы(ЭлементыДляВыключенияВидимости, ВыключитьВидимость);
		
КонецПроцедуры

&НаКлиенте
Процедура ПриЗакрытии()

	// процедура обновляет форму главного окна	
	ФормаГлавногоОкна = МестныйКэш.ГлавноеОкно;

	Если ФормаГлавногоОкна.Открыта() Тогда
		ФормаГлавногоОкна.ОбновитьКонтент();
	КонецЕсли;	

КонецПроцедуры

&НаКлиенте
Процедура НадписьТиповыеОшибкиНажатие(Элемент)
	ЗапуститьПриложение("https://sbis.ru/help/integration/1C_set/modul/typical_errors");
КонецПроцедуры

