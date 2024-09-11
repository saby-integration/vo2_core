
&НаКлиенте
Процедура ОбработкаВыбораАккаунта(ИдАккаунта, Кэш) 
	
    Попытка
		Если Кэш.Парам.СпособХраненияМетокСтатусов = 0 Тогда
			МодульОбъектаКлиент().СохранитьМеткиСтатусов(Кэш);
		КонецЕсли;
        ИдСессии = ОбработчикПереключенияОрганизации(ИдАккаунта, Кэш);
		МодульОбъектаКлиент().ОчиститьЗначенияФич();
	Исключение 
		ИнфОбОшибке = ИнформацияОбОшибке();
		СбисИсключение = МодульОбъектаКлиент().НовыйСбисИсключение(ИнфОбОшибке, "ФормаСменыАккаунта.ОбработкаВыбораАккаунта");
		МодульОбъектаКлиент().СообщитьСбисИсключение(СбисИсключение);
		Возврат 
	КонецПопытки;	              
	МодульОбъектаКлиент().СбисДействияПриВыходеИзАккаунта(Кэш);
	НажатиеВыполнено = Истина;
	ПараметрыЗакрытияФормы = Новый Структура("ИдСессии, ИдАккаунта, АккаунтИзменился", ИдСессии, ИдАккаунта, Ложь);
	Если Не ТекущийАккаунт = ИдАккаунта Тогда
		ПараметрыЗакрытияФормы.АккаунтИзменился = Истина;
	КонецЕсли;
	ЭтаФорма.Закрыть(ПараметрыЗакрытияФормы);	  
	
КонецПроцедуры

// Обработка выбора организации   
&НаКлиенте
Функция ОбработчикПереключенияОрганизации(ИдАккаунта, Кэш)
	
	Если Кэш.СБИС.ПараметрыИнтеграции.Свойство("ИдАккаунта") И Кэш.СБИС.ПараметрыИнтеграции.ИдАккаунта = ИдАккаунта Тогда  
		Возврат "";
	КонецЕсли;
	Кэш.Парам.ИдентиФикаторСессии = МодульОбъектаКлиент().СбисПереключитьАккаунт(Кэш, Новый Структура("НомерАккаунта", ИдАккаунта), Новый Структура(), Ложь);
	Возврат Кэш.Парам.ИдентиФикаторСессии;
	
КонецФункции 	

&НаКлиенте
Процедура ИнициализироватьФорму(Кэш, СписокДопОпераций) 
	ЛокальныйКэш = Кэш;
	Попытка
		ТекущийАккаунт = ЛокальныйКэш.СБИС.ПараметрыИнтеграции.ИдАккаунта;
	Исключение
		ТекущийАккаунт = "";
	КонецПопытки;
	Попытка
		// Заполняем список аккаунтов 	
		СписокОрганизаций.Очистить();
        МассивАккаунтов = ЛокальныйКэш.СБИС.МодульОбъектаКлиент.СбисПолучитьСписокАккаунтов(ЛокальныйКэш, СписокДопОпераций, Ложь);
		Для каждого Аккаунт Из МассивАккаунтов Цикл
			НоваяСтрока = СписокОрганизаций.Добавить();
			НоваяСтрока.НазваниеАккаунта = Аккаунт.НазваниеАккаунта;
			НоваяСтрока.ИдАккаунта = Аккаунт.НомерАккаунта;	
		КонецЦикла;	
	Исключение
		Сообщить("Не удалось получить список аккаунтов. Обратитесь в тех. поддержку!");
	КонецПопытки;
КонецПроцедуры

