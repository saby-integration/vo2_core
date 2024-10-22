
&НаКлиенте
Процедура ПриОткрытии()
	
	НажатиеСохранитьВыполнено = Ложь;
	
КонецПроцедуры

&НаКлиенте
Процедура ПередЗакрытием(Отказ, СтандартнаяОбработка)
	
	//Если ПараметрыФормы.Свойство("РежимЗапуска") И ПараметрыФормы.РежимЗапуска = "НастройкиСоединения" И НажатиеСохранитьВыполнено Тогда//Пробуем включить обмен
	Если НажатиеСохранитьВыполнено Тогда
		//Сообщение безопасности 1С при установке ВК прерывает выполнение кода, установим отказ заранее и изменим если проверки пройдут 
		Отказ				= Истина;
 		ПарамерыИзменено	= ПроверитьИПрименитьПараметрыПередЗакрытием(ПараметрыФормы.Результат, Отказ);
		//Если режим это настройка до авторизации, то ничего после завершения не делаем.
		Если	Не ПараметрыФормы.РежимЗапуска = "НастройкиСоединения"
			И	Не Отказ Тогда
			
			ОбработкаЗавершения		= МодульОбъектаКлиент().НовыйСбисОписаниеОповещения("СбисПрименитьНастройки_Завершение", ЭтаФорма);
			ОтложенноеЗавершение	= МодульОбъектаКлиент().НовыйОтложенноеДействие(Новый Структура("ОписаниеОповещения, Аргумент", ОбработкаЗавершения, ПарамерыИзменено));
			МодульОбъектаКлиент().ПодключитьОтложенноеДействие(ОтложенноеЗавершение);
		КонецЕсли;
	
	КонецЕсли;

КонецПроцедуры

&НаКлиенте
Функция ПроверитьИПрименитьПараметрыПередЗакрытием(ПараметрыНовые, Отказ)
	
	МодульОбъектаКлиент	= МодульОбъектаКлиент();
	ФормаГлавноеОкно	= МестныйКэш.ГлавноеОкно;
	ПарамерыИзменено	= Новый Структура("Авторизация, Настройки", Ложь, Ложь);
	ИзмененныеПараметрыСписок = Новый Массив();
	
	// Изменим все параметры на новые   
	Если МестныйКэш.СБИС.Свойство("ОбменВключен") И Не МестныйКэш.СБИС.ОбменВключен Тогда
	      // Изменяем параметр для последующего вывода окна авторизации  
		  ПараметрыФормы.РежимЗапуска = "ОбщиеНастройки";
		  
	КонецЕсли;
	Для Каждого КлючИЗначениеПараметр Из ПараметрыНовые Цикл
		ДопПараметрыИзменения = Неопределено;
		Если		КлючИЗначениеПараметр.Значение = НастройкиПодключения_Было[КлючИЗначениеПараметр.Ключ] Тогда
			Продолжить;
		КонецЕсли;
		ИзмененныйПараметр = Новый Структура("ИмяПараметра, ЗначениеПараметра, ДопПараметры", КлючИЗначениеПараметр.Ключ, КлючИЗначениеПараметр.Значение, ДопПараметрыИзменения);
		ИзмененныеПараметрыСписок.Добавить(ИзмененныйПараметр);
	КонецЦикла;
	МодульОбъектаКлиент.ИзменитьПараметрыСбисМассово(ИзмененныеПараметрыСписок);
	
	Если НастройкиПодключения_Было.АдресСервера <> ПараметрыНовые.АдресСервера Тогда
		ПарамерыИзменено.Авторизация = Истина;
    КонецЕсли;

	Если ПараметрыНовые.СпособОбмена <> НастройкиПодключения_Было.СпособОбмена Или Не МестныйКэш.СБИС.ОбменВключен Тогда
		
		// При изменении способа обмена (SDK, API, каталог)	"перезапускаем" обработку
		Если	(ПараметрыНовые.СпособОбмена = 7	Или НастройкиПодключения_Было.СпособОбмена = 7)
			И	(ПараметрыНовые.СпособОбмена = 6	Или НастройкиПодключения_Было.СпособОбмена = 6) Тогда
			//Идентичные модули, переавторизация не требуется, но если не менялся стенд
		Иначе
			ПарамерыИзменено.Авторизация = Истина;
		КонецЕсли;
		
		СбисДополнительныеПараметры = Новый Структура("ВызыватьРекурсивно", Ложь);
		Попытка
			
			РезультатАктивации = ФормаГлавноеОкно.ОпределитьИнтеграциюРабочиеФормы(ФормаГлавноеОкно.Кэш, ПараметрыНовые, СбисДополнительныеПараметры);
			
		Исключение
			
			РезультатАктивации = Ложь;
			
		КонецПопытки;
		
		Если РезультатАктивации = Ложь И НЕ МодульОбъектаКлиент().ПолучитьЗначениеПараметраСбис("ОтложенныйЗапуск") Тогда
			//Восстановим способ обмена обратно
			ПараметрыНовые.АдресСервера = НастройкиПодключения_Было.АдресСервера;
			ПараметрыНовые.СпособОбмена = НастройкиПодключения_Было.СпособОбмена;
			ФормаГлавноеОкно.ОпределитьИнтеграциюРабочиеФормы(ФормаГлавноеОкно.Кэш, ПараметрыНовые, СбисДополнительныеПараметры);
		КонецЕсли;
		
	КонецЕсли;
	Если	ПараметрыНовые.СпособХраненияНастроек	<> НастройкиПодключения_Было.СпособХраненияНастроек
		Или	ПараметрыНовые.КаталогНастроек			<> НастройкиПодключения_Было.КаталогНастроек Тогда
		
		ПарамерыИзменено.Настройки = Истина;
		
	КонецЕсли;

	ВсеУспешлоИзменено = Истина;
	Для Каждого КлючИЗначениеДанные Из ПараметрыНовые Цикл    
		
		Если КлючИЗначениеДанные.Значение = НастройкиПодключения_Завершение[КлючИЗначениеДанные.Ключ] Тогда
			Продолжить;
		КонецЕсли;
		ВсеУспешлоИзменено = Ложь;
		ТекстОшибкиДляПользователя = "Ошибка при сохранении новых значений настроек. Несохранённому параметру " + КлючИЗначениеДанные.Ключ + " возвращено предыдущее значение.";
		МодульОбъектаКлиент().ИзменитьПараметрСбис(КлючИЗначениеДанные.Ключ, КлючИЗначениеДанные.Значение);
		МодульОбъектаКлиент().СбисСообщить(Новый Структура("Текст, ФормаВладелец", ТекстОшибкиДляПользователя, ЭтаФорма));
	КонецЦикла;
	
	Если Не ВсеУспешлоИзменено Тогда
		//отмена закрытия формы, откат не изменных значений
		ЗаполнитьЗначенияСвойств(ЭтаФорма, ПараметрыНовые, , "ПорядокАвтоматическогоСопоставления");
		НажатиеСохранитьВыполнено = Ложь;
		НастройкиПодключения_Было = ПараметрыНовые;
		Отказ = Истина; 
	Иначе
		Отказ = Ложь;
	КонецЕсли;
	Возврат ПарамерыИзменено;
	
КонецФункции

&НаКлиенте
Процедура ПриЗакрытии(ЗавершениеРаботы)
	
	МодульОбъектаКлиент().ПодключитьОтложенноеДействие(МодульОбъектаКлиент().НовыйСбисОписаниеОповещения("ПослеЗакрытия", ЭтаФорма));
	
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
	
	ПараметрыФормы				= Неопределено;
	ОписаниеОповещенияОЗакрытии	= Неопределено;
	ИзмененСпособИнтеграции 	= Ложь; 
	
КонецПроцедуры

