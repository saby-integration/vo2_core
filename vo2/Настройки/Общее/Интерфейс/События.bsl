
&НаКлиенте
Процедура ПередЗакрытием(Отказ, Параметр2=Неопределено, Параметр3=Неопределено, Параметр4=Неопределено)
	
	Если	ВладелецФормы = Неопределено 
		Или ВладелецФормы.Открыта() = Ложь
		Или	ВыполнитьЗакрытиеФормы Тогда
		//Форма ГО закрыта, закрыть следом редактор.
		Возврат;
	КонецЕсли;
	#Если ТолстыйКлиентОбычноеПриложение Тогда
		Параметр2 = Ложь;
	#Иначе
		Параметр4 = Ложь;
	#КонецЕсли
	Если Не МестныйКэш.КэшНастроек.ИниВПорядке Тогда
		ОбработчикДиалога = МодульОбъектаКлиент().НовыйСбисОписаниеОповещения("ПередЗакрытием_ПослеДиалога", ЭтаФорма, Новый Структура("Режим", "Завершить"));
		ТекстВопроса = "Обнаружены ошибки в файлах настроек.
		|Без их исправления дальнейшая работа невозможна.";
		МодульОбъектаКлиент().СбисПоказатьВопрос(ОбработчикДиалога, ТекстВопроса, РежимДиалогаВопрос.ДаНет,,,"Завершить работу?");
		Отказ = Истина;
		Возврат;
	ИначеЕсли МестныйКэш.КэшНастроек.ИзмененияВНастройках Тогда
		ОбработчикДиалога = МодульОбъектаКлиент().НовыйСбисОписаниеОповещения("ПередЗакрытием_ПослеДиалога", ЭтаФорма, Новый Структура("Режим", "Сохранить"));
		МодульОбъектаКлиент().СбисПоказатьВопрос(ОбработчикДиалога, "Сохранить изменения в настройках?", РежимДиалогаВопрос.ДаНетОтмена,,,"Рекомендуется сохранить внесенные изменения.");
		Отказ = Истина;
		Возврат;
	КонецЕсли;
	//МодульОбъектаКлиент().СбисРазблокироватьФорму(ВладелецФормы);
	
КонецПроцедуры

&НаКлиенте
Процедура КонфигурацияОбработкаВыбора(Элемент, ВыбранноеЗначение, СтандартнаяОбработка)

	ПараметрыРаботы.Вставить("КонфигурацияБыла", Конфигурация);

КонецПроцедуры

&НаКлиенте
Процедура КонфигурацияПриИзменении(Элемент)
	
	ПараметрыКонфигурации	= НайтиВыбраннуюКонфигурациюНастроек(МестныйКэш.Конфигурация, Конфигурация);
	ОбработчикЗавершения	= МодульОбъектаКлиент().НовыйСбисОписаниеОповещения("КонфигурацияПриИзменении_Завершение", ЭтаФорма, Новый Структура("Кэш, Отказ", МестныйКэш, Ложь));
	МестныйКэш.ФормаНастроек.КонфигурацияПриИзменении(Новый Структура("Конфигурация, ОбработчикЗавершения", ПараметрыКонфигурации, ОбработчикЗавершения), МестныйКэш);
	                                    
КонецПроцедуры

