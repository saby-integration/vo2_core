
&НаКлиенте
Перем НажатиеВыполнено, Прервано Экспорт;//На случай множественного нажатия для прерывания

#Область include_local_ПолучитьМодульОбъекта
#КонецОбласти

&НаКлиенте
Процедура ПрерватьОбработку(Команда)

	Прервано = Истина;
	Если НажатиеВыполнено Тогда
		Возврат;
	КонецЕсли;
	НажатиеВыполнено = Истина;

	ПараметрыФормы.Вставить("СкрытьФормуБезЗавершения", Ложь);
	ПараметрыФормы.Результат = "Прервать";
	Закрыть(ПараметрыФормы.Результат);
	
КонецПроцедуры

&НаКлиенте
Процедура ПоказатьСостояниеДлительнойОперации(ТекстСостояния, СбисИндикатор = Неопределено, СбисПояснение = "", ДопПараметры = Неопределено) Экспорт
	
	СбисПрерывать			= Ложь;
	БлокироватьИнтерфейс	= Ложь;
	НажатиеВыполнено		= Ложь;
	
	Заголовок = ТекстСостояния;
	МодульОбъектаКлиент().ПолучитьЭлементФормыОбработки(ЭтаФорма, "Пояснение").Заголовок = СбисПояснение;
	Если Не ДопПараметры = Неопределено Тогда
		Если ДопПараметры.Свойство("Прерывать") Тогда
			СбисПрерывать = ДопПараметры.Прерывать;
		КонецЕсли;
		Если ДопПараметры.Свойство("БлокироватьИнтерфейс") Тогда
			БлокироватьИнтерфейс = ДопПараметры.БлокироватьИнтерфейс;
		КонецЕсли;
	КонецЕсли;
	Если СбисИндикатор = Неопределено Тогда
		МодульОбъектаКлиент().ПолучитьЭлементФормыОбработки(ЭтаФорма, "Индикатор").Видимость = Ложь;
	Иначе
		МодульОбъектаКлиент().ПолучитьЭлементФормыОбработки(ЭтаФорма, "Индикатор").Видимость = Истина;
		ИндикаторМакс	= Макс(СбисИндикатор, 0);
		Индикатор		= Мин(Окр(ИндикаторМакс), 100);
	КонецЕсли;
	МодульОбъектаКлиент().ПолучитьЭлементФормыОбработки(ЭтаФорма, "ПрерватьОбработку").Видимость	= СбисПрерывать;
	МодульОбъектаКлиент().СбисУстановитьБлокировкуФормы(ВладелецФормы, Новый Структура("Блокировка", БлокироватьИнтерфейс));
	
	Если Открыта() Тогда
		#Если Не ТолстыйКлиентОбычноеПриложение Тогда
			ОбновитьОтображениеДанных();
		#КонецЕсли
	Иначе
		Открыть();
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура СпрятатьСтатусДлительнойОперации(СбисЗавершить = Ложь) Экспорт
			
	ОбработкаПрерывания			= ОписаниеОповещенияОЗакрытии;
	ОписаниеОповещенияОЗакрытии	= Неопределено;
	
	Если Открыта() Тогда
		Если Не СбисЗавершить Тогда
			ПараметрыФормы.Вставить("СкрытьФормуБезЗавершения", Истина);
		КонецЕсли;
		Закрыть();
	КонецЕсли;
	//После закрытия восстановить обработку прерывания, чтобы при следующем открытии и возобновлении показа операции не потерялось прерывание
	Если СбисЗавершить Тогда
		Прервано = Ложь;
		ПараметрыФормы = Новый Структура("РежимЗапуска, Результат");
	Иначе
		ОписаниеОповещенияОЗакрытии = ОбработкаПрерывания;
	КонецЕсли;

КонецПроцедуры

&НаКлиенте
Процедура ПриЗакрытии()
	
	Если	ПараметрыФормы.Свойство("СкрытьФормуБезЗавершения")
		И	ПараметрыФормы.СкрытьФормуБезЗавершения Тогда
		Возврат;
	КонецЕсли;
	ОбработчикЗавершения	= МодульОбъектаКлиент().НовыйСбисОписаниеОповещения("ПослеЗакрытия", ЭтаФорма);
	НовыйОтложенноеДействие	= МодульОбъектаКлиент().НовыйОтложенноеДействие(Новый Структура("ОписаниеОповещения", ОбработчикЗавершения));
	Попытка
		МодульОбъектаКлиент().ПодключитьОтложенноеДействие(НовыйОтложенноеДействие);
	Исключение
		МодульОбъектаКлиент().СообщитьСбисИсключение(ИнформацияОбОшибке(), Новый Структура("СтатусСообщения, ИмяКоманды", "warning", "ФормаИндикатора.ПриЗакрытии"));
	КонецПопытки;
	
КонецПроцедуры

// Процедура - после закрытия почистить форму
//
// Параметры:
//  Аргумент	 - 	 - 
//  ДопПараметры - 	 - 
//
&НаКлиенте
Процедура ПослеЗакрытия(Аргумент=Неопределено, ДопПараметры=Неопределено) Экспорт
	
	#Если ТолстыйКлиентОбычноеПриложение Тогда
		//Вызвать описание оповещения о закрытии вручную.
		Если Не ОписаниеОповещенияОЗакрытии = Неопределено Тогда
			МодульОбъектаКлиент().ВыполнитьСбисОписаниеОповещения(ПараметрыФормы.Результат, ОписаниеОповещенияОЗакрытии);
		КонецЕсли;
	#КонецЕсли
	
	ПараметрыФормы				= Новый Структура("РежимЗапуска, Результат");
	ОписаниеОповещенияОЗакрытии	= Неопределено;
	
КонецПроцедуры


Прервано = Ложь;
ПараметрыФормы = Новый Структура("РежимЗапуска, Результат");
