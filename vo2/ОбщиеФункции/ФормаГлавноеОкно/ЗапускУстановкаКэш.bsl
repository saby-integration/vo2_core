
&НаКлиенте
Процедура ПроверитьИУстановитьКэш()

	Попытка
		
		ТекущийМодульОбъекта = МодульОбъектаКлиент();
		
	Исключение
		
		ВызватьИсключение("Возникла неизвестная ошибка при запуске обработки. Модуль объекта не был получен: " + ОписаниеОшибки());
		
	КонецПопытки;
	
	Если			ТекущийМодульОбъекта = Неопределено Тогда
		
		ВызватьИсключение("Возникла неизвестная ошибка при запуске обработки. Модуль объекта не был определен.");
		
	ИначеЕсли Не	ТекущийМодульОбъекта.ГлобальныйКэш = Неопределено Тогда 
		
		// считаем, что всё ок если глобальный кэш был установлен
		Возврат;
		
	КонецЕсли;
	
	Попытка
		
		ТекущийМодульОбъекта.НастроитьКэшОбработки(ЭтаФорма);
		
	Исключение
		
		СообщениеОшибки		= "Ошибка настройки стартовых параметров обработки.";
		ОшибкаУстановкиКэш 	= ТекущийМодульОбъекта.НовыйСбисИсключение(ИнформацияОбОшибке(), "ФормаГлавноеОкно.ПроверитьИУстановитьКэш", 703, СообщениеОшибки);
		ВызватьИсключение(ТекущийМодульОбъекта.СбисИсключение_Представление(ОшибкаУстановкиКэш, "ПолныйТекст"));
		
	КонецПопытки;
	
КонецПроцедуры

////////////////////////////////////////////////////
////////////////Запуск, установка кэш///////////////
////////////////////////////////////////////////////

// Процедура заполняет структуру Кэша	
&НаКлиенте
Функция КэшПодготовить(СбисДополнительныеПараметры=Неопределено, Отказ=Ложь) Экспорт
    Перем ТекущийМодульОбъекта;
	
	ПроверитьИУстановитьКэш();
	
	Если СбисДополнительныеПараметры = Неопределено Тогда
		СбисДополнительныеПараметры = Новый Структура;
	КонецЕсли;
	
	СбисПоказатьСостояние("Установка параметров");
	
	//Восстановим параметры
	#Если ТолстыйКлиентОбычноеПриложение Тогда 
		сбисПарам = ВосстановитьЗначение("сбисПарам");
		Если ЗначениеЗаполнено(сбисПарам) Тогда // Параметры есть. Заполним предверсию на форме для определения параметров запуска.
			Кэш.Парам = сбисПарам;
			ПредВерсия	= Кэш.Парам.ПредВерсия;
			// Переопределяем параметры ПервыйЗапуск и НоваяВерсия, т.к. на ОФ они хранятся не на форме.
			Кэш.ПараметрыСистемы.Обработка.Вставить("ПервыйЗапуск", Не ЗначениеЗаполнено(ПредВерсия));
			Кэш.ПараметрыСистемы.Обработка.Вставить("НоваяВерсия",	СбисНоваяВерсия(Кэш.ПараметрыСистемы.Обработка.Версия, ПредВерсия));
		КонецЕсли;
	#КонецЕсли
	
	ТекущийМодульОбъекта = МодульОбъектаКлиент();
	
	//ТекущийМодульОбъекта.УстановитьПараметрыГлобальногоМодуля(, Кэш);
	
	Попытка
		МодульОбработкиJSON = ТекущийМодульОбъекта.ПолучитьФормуОбработки("РаботаСJSON");
		СбисОбщиеФункции	= ТекущийМодульОбъекта.ПолучитьФормуОбработки("РаботаСДокументами1С"); 
		СбисОбщиеФункции.МестныйКэш = Кэш;
	Исключение
		Отказ = Истина;
		Возврат ТекущийМодульОбъекта.НовыйСбисИсключение(ИнформацияОбОшибке(), "ФормаГлавноеОкно.КэшПодготовить", 776, "Запуск программы/функции/метода не удался", "Не удалось определить модули для работы внешней обработки. Обратитесь в техническую поддержку.");
	КонецПопытки;
	ТекущийМодульОбъекта.ОбновитьПараметрГлобальногоМодуля("РаботаСJSON",		МодульОбработкиJSON);
	ТекущийМодульОбъекта.ОбновитьПараметрГлобальногоМодуля("ФункцииДокументов",	СбисОбщиеФункции);
	ТекущийМодульОбъекта.ЛокальныйКэш_ПривестиСовместимость(Кэш);
	
	Если ЗначениеЗаполнено(СбисДополнительныеПараметры) Тогда
		Для Каждого КлючИЗначение Из СбисДополнительныеПараметры Цикл
			Если КлючИЗначение.Ключ = "Парам" Тогда
				Продолжить;
			ИначеЕсли КлючИЗначение.Ключ = "РежимЗапускаГлавногоОкна" Тогда
				РежимЗапускаГлавногоОкна = КлючИЗначение.Значение;
				Продолжить;
			КонецЕсли;
			Кэш.Вставить(КлючИЗначение.Ключ, КлючИЗначение.Значение);
		КонецЦикла;
	КонецЕсли;
	Возврат Кэш;
	
КонецФункции

//Устанавливает в Кэш формы для работы с настройками и методами работы с сервисом
&НаКлиенте
Функция ОпределитьИнтеграциюРабочиеФормы(Кэш, ПараметрыИнтеграции, СбисДополнительныеПараметры=Неопределено)	Экспорт
	
	#Если ВебКлиент Тогда
		// для веб ставим всегда АПИ
		ПараметрыИнтеграции.СпособОбмена = 3;
	#КонецЕсли
	
	Если СбисДополнительныеПараметры = Неопределено Тогда
		СбисДополнительныеПараметры = Новый Структура;
	КонецЕсли;
	Если НЕ СбисДополнительныеПараметры.Свойство("ВызыватьРекурсивно") Тогда
		СбисДополнительныеПараметры.Вставить("ВызыватьРекурсивно", Истина);
	КонецЕсли;
	Если НЕ СбисДополнительныеПараметры.Свойство("ВключатьОбмен") Тогда
		СбисДополнительныеПараметры.Вставить("ВключатьОбмен", Истина);
	КонецЕсли;
	
	//Переделал передачу параметров на структуру, чтобы нормально добавить адрес сервера и его дальнейшую передачу
	ПараметрыИнтеграции_До = Новый Структура("СпособОбмена, СпособХраненияНастроек, АдресСервера");
	ЗаполнитьЗначенияСвойств(ПараметрыИнтеграции_До, ПараметрыИнтеграции);
	
	сбисПоказатьСостояние("Подключение SDK", ЭтаФорма);
	ОпределитьФормуИнтеграции(Кэш, ПараметрыИнтеграции.СпособОбмена);
	ОпределитьФормуРаботыСНастройками(Кэш, ПараметрыИнтеграции.СпособОбмена, ПараметрыИнтеграции.СпособХраненияНастроек);	
	сбисОпределитьФормуРаботысЭП();
	ОпределитьФормуРаботыССопоставлениемНоменклатуры(ПараметрыИнтеграции.СпособСопоставленияНоменклатуры);
	
	ВключениеВыполнено = Ложь;
	Если СбисДополнительныеПараметры.ВызыватьРекурсивно Тогда
		Результат = Кэш.ФормаНастроек.УстановитьПараметрыИнтеграции_ДоВключения(Кэш,ПараметрыИнтеграции,СбисДополнительныеПараметры,ВключениеВыполнено);
		Если ВключениеВыполнено Тогда//Если менялись параметры соединения, например, изменен в каталоге изменен адрес сервера, то включение уже выполнялось через рекурсивный вызов и повторно делать незачем
			сбисСпрятатьСостояние(ЭтаФорма);
			Возврат Результат;
		КонецЕсли;
	КонецЕсли;
		
	Если Не МодульОбъектаКлиент().ПолучитьЗначениеПараметраСбис("ТихийРежим")//Включаем интеграцию сразу, только если не вызов извне и запуск не был отменен специально
		И	СбисДополнительныеПараметры.ВключатьОбмен Тогда
		Кэш.ФормаНастроек.сбисПодключитьЗаплатки(Кэш, Кэш.Парам);
		
		ИмяИнтеграции		= МодульОбъектаКлиент().ПолучитьЗначениеПараметраСБИС("ИнтеграцияИмя", Новый Структура("ЛокальныйКэш", Кэш));
		МодульИнтеграции	= МодульОбъектаКлиент().НайтиФункциюСеансаОбработки("Включить", ИмяИнтеграции);
		
		ОбменВключен		= МодульИнтеграции.Включить(Кэш, ПараметрыИнтеграции);
		МодульИсходный		= МодульОбъектаКлиент().МодульИнтеграцииСБИС(ИмяИнтеграции);
		
		Попытка 
			
			СведенияОбИнтеграции	= МодульИсходный.СведенияОбИнтеграции();
			ВерсияИнтеграции		= СведенияОбИнтеграции.Версия;
			
		Исключение
			
			ВерсияИнтеграции		= "";
			
		КонецПопытки;
		
		
		Если Не ОбменВключен = Истина Тогда
			
			сбисСпрятатьСостояние(ЭтаФорма);
			Возврат Ложь;
			
		КонецЕсли;
	КонецЕсли;

	//Дошли досюда, значит всё должно быть включено. Проверим, что в процессе включения ничего не поменялось 
	УспешноУстнановлено = Истина;
	ЗначениеПараметра = Неопределено;
	Для Каждого КлючИЗначение Из ПараметрыИнтеграции_До Цикл
		Если Не ПараметрыИнтеграции.Свойство(КлючИЗначение.Ключ, ЗначениеПараметра) 
			Или ЗначениеПараметра= КлючИЗначение.Значение Тогда
			Продолжить;
		КонецЕсли;
		УспешноУстнановлено = Ложь;
		Прервать;
	КонецЦикла;
	сбисСпрятатьСостояние(ЭтаФорма);
	Возврат УспешноУстнановлено;	
	
КонецФункции

//Устанавливает в Кэш форму, в зависимости от установленного способа обмена
&НаКлиенте
Процедура ОпределитьФормуИнтеграции(ЛокальныйКэш,ВидОбмена) Экспорт
	
	//TODO 24.1100 Старые параметры, спилить после отказа от старой отправки
	ЛокальныйКэш.Вставить("КоличествоВОтправке", 100);
	
	ИнтеграцияЗаголовок = ""; 
	
	МодульИнтеграции = МодульОбъектаКлиент().МодульИнтеграцииСБИС(ВидОбмена);
	Если МодульИнтеграции = Неопределено Тогда
		
		ОшибкаПодбораИнтеграции = МодульОбъектаКлиент().НовыйСбисИсключение(700, "ФормаГлавноеОкно.ОпределитьФормуИнтеграции",,,"Установлено неизвестный способ обмена.");
		ВызватьИсключение МодульОбъектаКлиент().СбисИсключение_Представление(ОшибкаПодбораИнтеграции);
		
	КонецЕсли;
		
	Если ВидОбмена=0 Тогда
		НадписьSDK		= "ВерсияИнтеграции";
		ИнтеграцияИмя	= "SDK2";
		Если ТипЗнч(ЭтаФорма) = Тип("УправляемаяФорма") Тогда
			ИнтеграцияЗаголовок = "SDK2";
		Иначе 
			ИнтеграцияЗаголовок = "SDK(Снят с поддержки)";
		КонецЕсли;
		сбисЭлементФормы(ЭтаФорма, НадписьSDK).ЦветТекста = WebЦвета.Красный;
		ШрифтДляТекста = Новый Шрифт(,8,Истина,,Истина);
		сбисЭлементФормы(ЭтаФорма, НадписьSDK).Шрифт = ШрифтДляТекста;
		сбисЭлементФормы(ЭтаФорма, НадписьSDK).Гиперссылка = Истина;
	ИначеЕсли ВидОбмена=2 Тогда
		НадписьSDK		= "ВерсияИнтеграции";
		ИнтеграцияИмя	= "SDK2Шифрование";
		Если ТипЗнч(ЭтаФорма) = Тип("УправляемаяФорма") Тогда
			ИнтеграцияЗаголовок = "SDK2";
		Иначе 
			ИнтеграцияЗаголовок = "SDK(Снят с поддержки)";
		КонецЕсли;
		сбисЭлементФормы(ЭтаФорма, НадписьSDK).ЦветТекста = WebЦвета.Красный;
		ШрифтДляТекста = Новый Шрифт(,8,Истина,,Истина);
		сбисЭлементФормы(ЭтаФорма, НадписьSDK).Шрифт = ШрифтДляТекста;
		сбисЭлементФормы(ЭтаФорма, НадписьSDK).Гиперссылка = Истина;
	ИначеЕсли ВидОбмена=3 Тогда
		ИнтеграцияЗаголовок = "API";
		ИнтеграцияИмя		= "API";
	ИначеЕсли ВидОбмена=1 Тогда
		ИнтеграцияЗаголовок = "Каталог";
		ИнтеграцияИмя		= "ИнтеграцияКаталог";
	ИначеЕсли ВидОбмена=4 Тогда
		ИнтеграцияЗаголовок = "ExtSDK";
		ИнтеграцияИмя		= "ExtSDK";
	ИначеЕсли ВидОбмена=5 Тогда
		ИнтеграцияЗаголовок = "ExtSDKCrypto";
		ИнтеграцияИмя		= "ExtSDKCrypto";
	ИначеЕсли ВидОбмена=6 Тогда
		ИнтеграцияЗаголовок = "ExtSDK2";
		ИнтеграцияИмя		= "ExtSDK2";
	ИначеЕсли ВидОбмена=7 Тогда
		ИнтеграцияЗаголовок = "ExtSDK2Crypto";
		ИнтеграцияИмя		= "ExtSDK2Crypto";
	ИначеЕсли ВидОбмена=8 Тогда 
		ЛокальныйКэш.Вставить("КоличествоВОтправке", 1);
		ИнтеграцияЗаголовок = "SabyPluginConnector";
		ИнтеграцияИмя		= "SabyPluginConnector";
	ИначеЕсли ВидОбмена=9 Тогда 
		ИнтеграцияЗаголовок = "SabyHttpsClient";
		ИнтеграцияИмя		= "SabyHttpsClient";
	КонецЕсли;
	
	ШрифтДляТекста = Новый Шрифт(,8); 
	
	ЭлементНадписи = МодульОбъектаКлиент().ПолучитьЭлементФормыОбработки(ЭтаФорма, "ВерсияИнтеграции");
	ЭлементНадписи.ЦветТекста		= WebЦвета.Черный;
	ЭлементНадписи.Шрифт			= ШрифтДляТекста;
	ЭлементНадписи.Гиперссылка		= Ложь;
	
	ЗаголовокНадписи = МодульОбъектаКлиент().ПолучитьЭлементФормыОбработки(ЭтаФорма, "ВерсияИнтеграции.Надпись");
	ЗаголовокНадписи.Заголовок		= ИнтеграцияЗаголовок;
	
	ДопПараметрыУстановить = Новый Структура("Глобально, Кэш", Ложь, ЛокальныйКэш);
	МодульОбъектаКлиент().ИзменитьПараметрСбис("Интеграция",	МодульИнтеграции, ДопПараметрыУстановить);
	МодульОбъектаКлиент().ИзменитьПараметрСбис("ИнтеграцияИмя",	ИнтеграцияИмя, ДопПараметрыУстановить);
	
КонецПроцедуры

//Устанавливает в Кэш форму, в зависимости от выбранного способа хранения настроек
&НаКлиенте
Процедура ОпределитьФормуРаботыСНастройками(ЛокальныйКэш, ВидОбмена, ВидХраненияНастроек, ПараметрыИнициализации=Неопределено) Экспорт
	
	МодульИнтеграцииЛокальный	= МодульОбъектаКлиент().ПолучитьЗначениеПараметраСБИС("Интеграция",	Новый Структура("ЛокальныйКэш", ЛокальныйКэш));
	СведенияОбИнтеграции		= МодульИнтеграцииЛокальный.СведенияОбИнтеграции(); 
	Если		ВидХраненияНастроек = 1
		И Не	СведенияОбИнтеграции.Параметры.ДоступныСерверныеНастройки Тогда
		ВидХраненияНастроек	= 0;
	КонецЕсли;
	
	МодульОбъектаКлиент().ИзменитьПараметрСбис("СпособХраненияНастроек", ВидХраненияНастроек, Новый Структура("Параметры", ПараметрыИнициализации));
	
КонецПроцедуры

// Устанавливает в Кэш форму работы с сопоставлением номенклатуры
&НаКлиенте
Процедура ОпределитьФормуРаботыССопоставлениемНоменклатуры(СпособСопоставленияНоменклатуры)
	
	МодульОбъектаКлиент().ИзменитьПараметрСбис("СпособСопоставленияНоменклатуры", СпособСопоставленияНоменклатуры);	
	
КонецПроцедуры

// Начальное заполнение всех необходимых для работы объектов	
&НаКлиенте
Функция ПослеОткрытияЗаполнитьКэш(СбисДополнительныеПараметры=Неопределено, Отказ=Ложь) Экспорт
	
	РезультатПодготовки = КэшПодготовить(СбисДополнительныеПараметры, Отказ);
	
	Если Отказ Тогда
		Возврат РезультатПодготовки;
	КонецЕсли;
	Версия = Кэш.ПараметрыСистемы.Обработка.Версия;

	СбисПолучитьПарам(СбисДополнительныеПараметры);
	СбисОбновитьЗаголовокФормы(Кэш.СБИС);
	ОпределитьИнтеграциюРабочиеФормы(Кэш, Кэш.Парам);
	
	СпособОбмена			= Кэш.Парам.СпособОбмена;
	СпособХраненияНастроек	= Кэш.Парам.СпособХраненияНастроек;
	

	Возврат Кэш;
КонецФункции

// Начально заполнение всех необходимых для работы объектов	
&НаКлиенте
Процедура ПослеУстановитьРасширениеРаботыСФайлами(АргументВыполнение = Неопределено, ДопПараметры = Неопределено) Экспорт
	
	ОтказЗапуска = Ложь;
	ДополнительныеПараметрыКэша = Новый Структура;
	ДополнительныеПараметрыКэша.Вставить("РежимЗапускаГлавногоОкна", "Обычный");
	РезультатЗапуска = ПослеОткрытияЗаполнитьКэш(ДополнительныеПараметрыКэша, ОтказЗапуска);
	
	Если ОтказЗапуска Тогда
		
		сбисСообщитьОбОшибке(Кэш, РезультатЗапуска);
		
	ИначеЕсли МодульОбъектаКлиент().ПолучитьЗначениеПараметраСбис("ОтложенныйЗапуск") Тогда
		
		//ничего не делаем
		
	Иначе
		
		//СбисПодготовитьРеестрДлительныхОпераций(); TODO раскомментировать, когда потребуется.
		ПослеОткрытияАвторизация();
		
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ПослеОткрытияАвторизация(СбисДополнительныеПараметры=Неопределено) Экспорт
	Если СбисДополнительныеПараметры = Неопределено Тогда
		СбисДополнительныеПараметры = Новый Структура;
	КонецЕсли;

	Если Кэш.Парам.СпособОбмена = 1 Тогда//Для каталога пропускаем авторизацию.
		сбисПослеАвторизации(Кэш.Интеграция.ИнформацияОТекущемПользователе(Кэш), СбисДополнительныеПараметры);
		Возврат;
	КонецЕсли;
	// Авторизация
	сбисПоказатьСостояние("Авторизация", ЭтаФорма);
	формаАвторизации = сбисПолучитьФорму("ФормаАвторизация",,,ЭтаФорма);
	Если	(	Кэш.Парам.ВходПоСертификату И Кэш.Парам.ЗапомнитьСертификат)
		Или (Не Кэш.Парам.ВходПоСертификату И Кэш.Парам.ЗапомнитьПароль) Тогда
		формаАвторизации.ЗагрузитьПараметрыАвторизации(Кэш);
		УспешнаяАвторизация = формаАвторизации.Авторизоваться();
	КонецЕсли;
	Если УспешнаяАвторизация = Истина Тогда
		сбисПослеАвторизации(УспешнаяАвторизация, СбисДополнительныеПараметры);
	Иначе
		Если Не формаАвторизации.Открыта() Тогда
			#Если ТолстыйКлиентОбычноеПриложение Тогда
				Результат = формаАвторизации.ОткрытьМодально();
				сбисПослеАвторизации(Результат,СбисДополнительныеПараметры);
			#Иначе
				формаАвторизации.ОписаниеОповещенияОЗакрытии = Новый ОписаниеОповещения("сбисПослеАвторизации",ЭтаФорма,СбисДополнительныеПараметры);
				формаАвторизации.Открыть();
			#КонецЕсли
		КонецЕсли;
	КонецЕсли;		
КонецПроцедуры

&НаКлиенте
Процедура сбисПоследняяВерсия(Кэш)
	Отказ = Ложь;
	сбисВерсияНаСервере = Кэш.ОбщиеФункции.сбисПолучитьНомерВерсииОбработкиПоПараметрам(Кэш, Отказ);
	Если Отказ Тогда
		Возврат;
	КонецЕсли;
КонецПроцедуры

// Процедура заполняет сохраняемые параметры обработки
//
// Параметры:
//  СбисДополнительныеПараметры	 - Структура - дополнителные параметры функции
//
&НаКлиенте
Процедура СбисПолучитьПарам(СбисДополнительныеПараметры=Неопределено) Экспорт
	
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
	ЗначПоУмолчанию.Вставить("ПредВерсия", "");
	ЗначПоУмолчанию.Вставить("ОжидаемаяВерсия", "");
	ЗначПоУмолчанию.Вставить("ВариантВыгрузкиОтвПодр", 2);// Значение по-умолчанию - 2, не создавать отв. и подразделения
	ЗначПоУмолчанию.Вставить("КолПакетовВОтправке", 0);
	ЗначПоУмолчанию.Вставить("КаталогНастроек", "");
	ЗначПоУмолчанию.Вставить("ИдентификаторыНастроекВСБИС", Новый СписокЗначений);
	ЗначПоУмолчанию.Вставить("ИдентификаторНастроек", "");
	ЗначПоУмолчанию.Вставить("СпособОбмена", 6); //ExtSDK2
	ЗначПоУмолчанию.Вставить("СпособХраненияНастроек", 0);
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
	ЗначПоУмолчанию.Вставить("ПолнаяВерсияПродукта", Кэш.ПараметрыСистемы.Обработка.ПолнаяВерсия);
	ЗначПоУмолчанию.Вставить("ШифроватьВыборочно", Ложь);
	ЗначПоУмолчанию.Вставить("АдресСервера", МодульОбъектаКлиент().СписокДоступныхСерверовСБИС()[0].Значение);
	ЗначПоУмолчанию.Вставить("НастройкиАвтообновление", Истина);
	ЗначПоУмолчанию.Вставить("ИнтеграцияAPIВызовыНаКлиенте", Ложь);
	ЗначПоУмолчанию.Вставить("СтатусыВГосСистеме", Ложь);
	ЗначПоУмолчанию.Вставить("ВремяОжиданияОтвета", 60); // Время ожидания ответа (для плагина)
	ЗначПоУмолчанию.Вставить("ИспользоватьШтрихкодыНоменклатурыКонтрагентов", Ложь);
	ЗначПоУмолчанию.Вставить("РежимЗагрузки", 3); // Загружать только несопоставленные документы 1С
	ЗначПоУмолчанию.Вставить("СпособХраненияМетокСтатусов", 0); // Обновлять статусы в разрезе пользователя СБИС
	ЗначПоУмолчанию.Вставить("СоздаватьШтрихкодыНоменклатуры", Ложь);
	ЗначПоУмолчанию.Вставить("СохранятьРасхождения", Ложь);
	ФильтрыПоРазд = Новый Структура();
	ФильтрыПоРазд.Вставить("Полученные", Новый Структура);
	ФильтрыПоРазд.Вставить("Отправленные", Новый Структура);
	ФильтрыПоРазд.Вставить("Полученные_ЭТрН", Новый Структура);
	ФильтрыПоРазд.Вставить("Отправленные_ЭТрН", Новый Структура);
	ФильтрыПоРазд.Вставить("Продажа", Новый Структура);
	ФильтрыПоРазд.Вставить("Покупка", Новый Структура);
	ФильтрыПоРазд.Вставить("Задачи", Новый Структура);
	ФильтрыПоРазд.Вставить("Учет", Новый Структура);
	ЗначПоУмолчанию.Вставить("ФильтрыПоРазделам", ФильтрыПоРазд);
	ЗначПоУмолчанию.Вставить("ИспользоватьГенератор", Ложь); 
	ЗначПоУмолчанию.Вставить("ИспользоватьНовыйФорматАктаСверки", Ложь);  
	ЗначПоУмолчанию.Вставить("ИспользоватьНовуюОтправку", Истина);  
	ЗначПоУмолчанию.Вставить("РеквизитСопоставленияНоменклатуры", МодульОбъектаКлиент().РеквизитСопоставленияНоменклатурыПоУмолчанию());
	ЗначПоУмолчанию.Вставить("ПоддержкаОбменаЕИС", Ложь);
	
	// Проект Контрагенты 1С в обработке
	ЗначПоУмолчанию.Вставить("СкладПоУмолчанию", Неопределено);
	ЗначПоУмолчанию.Вставить("РасСчетПоУмолчанию", Неопределено);
	ЗначПоУмолчанию.Вставить("ЗаполнениеКонтрагента1С", "ГрузополучательСБИС");
	ЗначПоУмолчанию.Вставить("ТипГрузополучателя", "ГрузополучательНеВедется");
	
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
	
	// Если первый запуск происходит на серверной БД с Линуксом
	Если	ЗначениеЗаполнено(Кэш.ПараметрыСистемы)
		И	Кэш.ПараметрыСистемы.Обработка.ПервыйЗапуск
		И	Кэш.ПараметрыСистемы.Сервер.ЭтоLinux Тогда
		ЗначПоУмолчанию.СпособХраненияНастроек = 1;
	КонецЕсли;
	
	Если ТипЗнч(Кэш.Парам) = Тип("Структура") Тогда
		Для Каждого Поле Из ЗначПоУмолчанию Цикл
			Если НЕ(Кэш.Парам.Свойство(Поле.Ключ)) Тогда
				#Если Не ТолстыйКлиентОбычноеПриложение Тогда
					Попытка
						// Уточнить у Андрея, почему тут не стоит конкретного условия на первый запуск обработки.
						ЗначениеНеБулевоПриПервомЗапуске = Не (Кэш.ПараметрыСистемы.Обработка.ПервыйЗапуск И ТипЗнч(Поле.Значение) = Тип("Булево"));
						ЗначениеЧислоНеПриПервомЗапуске = Не Кэш.ПараметрыСистемы.Обработка.ПервыйЗапуск И ТипЗнч(Поле.Значение) = Тип("Число");
						Если	ЗначениеЗаполнено(ЭтаФорма[Поле.Ключ])
									И ЗначениеНеБулевоПриПервомЗапуске
								Или ЗначениеЧислоНеПриПервомЗапуске Тогда
								
							Кэш.Парам.Вставить(Поле.Ключ,ЭтаФорма[Поле.Ключ]);
							Продолжить;
						
						КонецЕсли;
					Исключение
					КонецПопытки;
				#КонецЕсли
				Кэш.Парам.Вставить(Поле.Ключ,Поле.Значение);
				Попытка
					ЭтаФорма[Поле.Ключ] = Поле.Значение;
				Исключение
				КонецПопытки;
				Продолжить;
			Иначе
				Попытка
					ЭтаФорма[Поле.Ключ] = Кэш.Парам[Поле.Ключ];
				Исключение
				КонецПопытки;	
			КонецЕсли;
		КонецЦикла;
	Иначе
		Кэш.Парам = ЗначПоУмолчанию;
	КонецЕсли;
	
	Если Кэш.Парам.ВремяОжиданияОтвета = 0 Тогда
		Кэш.Парам.ВремяОжиданияОтвета = ЗначПоУмолчанию["ВремяОжиданияОтвета"];
	КонецЕсли;
	
	// Добавляем отдельный фильтр для подразделов ЭТрН
	Если Не Кэш.Парам.ФильтрыПоРазделам.Свойство("Полученные_ЭТрН") Тогда
		Кэш.Парам.ФильтрыПоРазделам.Вставить("Полученные_ЭТрН", Новый Структура);
	КонецЕсли;
	
	Если Не Кэш.Парам.ФильтрыПоРазделам.Свойство("Отправленные_ЭТрН") Тогда
		Кэш.Парам.ФильтрыПоРазделам.Вставить("Отправленные_ЭТрН", Новый Структура);
	КонецЕсли;
	
	Кэш.Парам.ИспользоватьГенератор = Кэш.Парам.ИспользоватьГенератор = Истина;
	// Отладка при запуске всегда ложь. 
	Кэш.Парам.Вставить("РежимОтладки", Ложь);
	Кэш.Парам.Вставить("ЧтениеНастроекПоТребованию", Истина);
	Кэш.Парам.Вставить("ПолнаяВерсияПродукта", Кэш.ПараметрыСистемы.Обработка.ПолнаяВерсия);
	
	Если Не	СбисДополнительныеПараметры = Неопределено
		И	СбисДополнительныеПараметры.Свойство("Парам") Тогда
		
		Для Каждого КлючИЗначение Из СбисДополнительныеПараметры.парам Цикл 
			Кэш.Парам.Вставить(КлючИЗначение.Ключ, КлючИЗначение.Значение);
		КонецЦикла;
		
	КонецЕсли;
	
	Если Кэш.Парам.СпособОбмена = 4 Тогда
		Кэш.Парам.СпособОбмена = 6; // ExtSDK -> ExtSDK2
	ИначеЕсли Кэш.Парам.СпособОбмена = 5 Тогда
		Кэш.Парам.СпособОбмена = 7; // ExtSDKCrypto -> ExtSDK2Crypto
	КонецЕсли;  
	
	// Данные по UserAgent для API методов
	Кэш.Парам.Вставить("UserAgent", Кэш.ПараметрыСистемы.Обработка.UserAgent);
	
	МодульОбъектаКлиент().ИзменитьПараметрСбис("АдресСервера",			Кэш.Парам.АдресСервера);
	МодульОбъектаКлиент().ОбновитьПараметрГлобальногоМодуля("Парам",	Кэш.Парам);
	
КонецПроцедуры

&НаКлиенте
Функция сбисПослеАвторизации(Результат, СбисДополнительныеПараметры) Экспорт

	ЕстьИзмененияАккаунта = Ложь;
	Если Результат = Неопределено Тогда
		//Если результат неопределен, то форма авторизации была просто закрыта.
		Кэш.Парам.ЗапомнитьПароль = Ложь;
		Кэш.Парам.ЗапомнитьСертификат = Ложь;
		МодульОбъектаКлиент().СбисЗавершитьРаботу();
		Возврат Неопределено;
	ИначеЕсли Результат = "" Тогда
		Возврат Неопределено;
	ИначеЕсли ТипЗнч(Результат) = Тип("Структура") Тогда
		Если Результат.ИдСессии = "" Тогда
			Возврат Неопределено;
		КонецЕсли;
		Если Результат.Свойство("АккаунтИзменился") Тогда
			ЕстьИзмененияАккаунта = Результат.АккаунтИзменился;
		КонецЕсли;
		Результат = Результат.ИдСессии;	 
	КонецЕсли;
			
	Пользователь_До	= Пользователь;
	Попытка
		МодульОбъектаКлиент().ЗаполнитьСведенияОПользователеИАккаунте(Новый Структура, Кэш);
	Исключение
		ИнфОбОшибке = ИнформацияОбОшибке();
		СбисСообщитьОбОшибке(Кэш, Кэш.ОбщиеФункции.СбисИсключение(ИнфОбОшибке, "сбисПослеАвторизации")); 
	КонецПопытки;
	
	СбисОбновитьЗаголовокФормы(Кэш.СБИС);
	
	ЕстьИзмененияОбмена			= Не (СпособОбмена			= Кэш.Парам.СпособОбмена);
	ЕстьИзмененияНастроек		= Не (СпособХраненияНастроек= Кэш.Парам.СпособХраненияНастроек);
	ЕстьИзмененияПользователя	= Не (Пользователь_До		= Пользователь) И Не Пользователь_До = "";
	
	Если ЕстьИзмененияОбмена Тогда
		ИзмененияОбмена = Новый Структура("СпособОбмена, СпособОбменаДо", Кэш.Парам.СпособОбмена, СпособОбмена);
		Если СбисДополнительныеПараметры = Неопределено Тогда
			СбисДополнительныеПараметры = Новый Структура();	
		КонецЕсли;
		Если СбисДополнительныеПараметры.Свойство("ИзмененияОбмена") Тогда
			СбисДополнительныеПараметры.ИзмененияОбмена = ИзмененияОбмена;	
		Иначе
			СбисДополнительныеПараметры.Вставить("ИзмененияОбмена", ИзмененияОбмена);	
		КонецЕсли;
	КонецЕсли;
	Если	СбисДополнительныеПараметры.Свойство("ИзмененаФормаНастроек")
		И	СбисДополнительныеПараметры.ИзмененаФормаНастроек Тогда
		ЕстьИзмененияНастроек = Истина;
	КонецЕсли;
	Если ЕстьИзмененияНастроек Тогда
		//был изменен способ хранения настроек. Нужно будет перечитать список доступных конфигураций, если соберёмся в раздел файлов.
		СбисДополнительныеПараметры.Вставить("ИзмененаФормаНастроек", Истина);
		Кэш.ФормаНастроек.ПараметрыРаботы.Вставить("ИзмененаФормаНастроек",	Истина);
	КонецЕсли;
	Если ЕстьИзмененияПользователя Тогда
		//был изменен пользователь. Для серверных настроек понадобится перечитать подключение.
		Кэш.ФормаНастроек.ПараметрыРаботы.Вставить("ИзменениеПользователя",	Истина);
	КонецЕсли;
	Если ЕстьИзмененияАккаунта Тогда
		//был изменен пользователь. Для серверных настроек понадобится перечитать подключение.
		Кэш.ФормаНастроек.ПараметрыРаботы.Вставить("ИзменениеАккаунта",		Истина);
	КонецЕсли;

	СпособХраненияНастроек		= Кэш.Парам.СпособХраненияНастроек;
	СпособОбмена				= Кэш.Парам.СпособОбмена;
	КаталогОбмена				= Кэш.Парам.КаталогОбмена;
	ШифроватьВыборочно			= Кэш.Парам.ШифроватьВыборочно;
	КаталогНастроек				= Кэш.Парам.КаталогНастроек;
	ИнтеграцияAPIВызовыНаКлиенте= Кэш.Парам.ИнтеграцияAPIВызовыНаКлиенте;
	
	Если	ЕстьИзмененияНастроек
		Или	ЕстьИзмененияПользователя 
		Или ЕстьИзмененияАккаунта Тогда
		СбисДополнительныеПараметры.Вставить("ОбновитьКонтент", Истина);
	КонецЕсли;
	
	ПослеОткрытияЗавершение(СбисДополнительныеПараметры);
	
КонецФункции

&НаСервере
Функция ЗаполнитьСписокФорм()
	СписокФорм = Новый СписокЗначений;
	#Если ТолстыйКлиентОбычноеПриложение Тогда
		МетаданныеФорм = ЭтотОбъект.Метаданные().Формы;
	#Иначе
		МетаданныеФорм = РеквизитФормыВЗначение("Объект").Метаданные().Формы;
	#КонецЕсли	
	Для Каждого Фрм Из МетаданныеФорм Цикл
		СписокФорм.Добавить(Фрм.Имя);	
	КонецЦикла;
	Возврат СписокФорм;
КонецФункции

&НаКлиенте
Процедура СбисПодготовитьРеестрДлительныхОпераций()
	фрм = сбисПолучитьФорму("ФормаДлительныеОперации",,,ЭтаФорма);
	фрм.ПодготовитьРеестрКРаботе();		
КонецПроцедуры
