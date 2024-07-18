
&НаКлиенте
Процедура КонфигурацияПриИзменении_Завершение(АргументЗавершения, ДопПараметры) Экспорт
	
	лОткатитьСистему = ДопПараметры.Отказ;
	ПараметрыОбновить = Новый Структура;
	Если АргументЗавершения = Неопределено Тогда
		лОткатитьСистему = Истина;
	Иначе
		ПараметрыОбновить.Вставить("УстановленныеИни", АргументЗавершения);		
	КонецЕсли;
	Если лОткатитьСистему Тогда
		Конфигурация = ПараметрыРаботы.КонфигурацияБыла;
	КонецЕсли;
	Если ДопПараметры.Отказ Тогда
		МодульОбъектаКлиент().СообщитьСбисИсключение(АргументЗавершения);
		Возврат;
	КонецЕсли;	
	СбисОбновитьОтображение(ПараметрыОбновить);
	                                    
КонецПроцедуры

&НаКлиенте
Процедура ПередЗакрытием_ПослеДиалога(РезультатДиалога, ДопПараметры) Экспорт
	
	Если		ДопПараметры.Режим = "Завершить" Тогда
		Если РезультатДиалога = КодВозвратаДиалога.Да Тогда
			ВыполнитьЗакрытиеФормы = Истина;
			Закрыть();
			МодульОбъектаКлиент().СбисЗавершитьРаботу();
		КонецЕсли;
		Возврат;
	ИначеЕсли	ДопПараметры.Режим = "Сохранить" Тогда
		Если		РезультатДиалога = КодВозвратаДиалога.Отмена Тогда
			Возврат;
		ИначеЕсли	РезультатДиалога = КодВозвратаДиалога.Да Тогда 
			ПараметрыЗаписи = Новый Структура("Отказ, ПродолжитьВыполнение", Ложь, Истина);
			МестныйКэш.ФормаНастроек.СбисСохранитьВыбранныеНастройки(МестныйКэш, ПараметрыЗаписи);
			Если ПараметрыЗаписи.Отказ Тогда 
				Возврат;
			КонецЕсли;
			ВыполнитьЗакрытиеФормы = Истина;
			МестныйКэш.КэшНастроек.ИзмененияВНастройках = Ложь;
			ОбработчикДействия = МодульОбъектаКлиент().НовыйСбисОписаниеОповещения("ПерейтиВРаздел", МестныйКэш.ГлавноеОкно);
			ОтложенноеДействие = МодульОбъектаКлиент().НовыйОтложенноеДействие(Новый Структура("ОписаниеОповещения", ОбработчикДействия));
			МодульОбъектаКлиент().ПодключитьОтложенноеДействие(ОтложенноеДействие);
		Иначе 
			ВыполнитьЗакрытиеФормы = Истина;
			ОбработчикДействия = МодульОбъектаКлиент().НовыйСбисОписаниеОповещения("ПерейтиВРаздел", МестныйКэш.ГлавноеОкно);
			ОтложенноеДействие = МодульОбъектаКлиент().НовыйОтложенноеДействие(Новый Структура("ОписаниеОповещения", ОбработчикДействия));
			МодульОбъектаКлиент().ПодключитьОтложенноеДействие(ОтложенноеДействие);
		КонецЕсли;
	КонецЕсли;
	Закрыть();
	
КонецПроцедуры

&НаКлиенте
Процедура СбисОбновитьТаблицыИниФайлов(УстановленныеИниФайлы = Неопределено, Отказ = Ложь) Экспорт
	Перем СписокИниФайлыПрименить;
	
	Если Отказ Тогда
		ОбновитьПоляФормы(Новый Структура("ТабУстановленныеИниФайлы", Новый Массив()));
		Возврат;
	КонецЕсли;
	
	// Если инишки не передали, то проверим их 
	Если УстановленныеИниФайлы = Неопределено Тогда
		ДопПараметры = Новый Структура("Автообновление", МестныйКэш.Парам.НастройкиАвтообновление);      
		УстановленныеИниФайлы = МестныйКэш.ФормаНастроек.сбисПолучитьМассивУстановленныхИниФайлов(МестныйКэш, ДопПараметры);
	КонецЕсли;
	
	Если Не МестныйКэш.Свойство("Конфигурация") Тогда
		ЭтаФорма.ТабДоступныеИниФайлы.Очистить();
		
		СписокТиповНастроек = МестныйКэш.ФормаНастроек.сбисПолучитьСписокДоступныхНастроек(МестныйКэш);
		
		Если СписокТиповНастроек = Неопределено Тогда    
			ИнфоОбОшибке = "Не удалось получить список доступных настроек. Обратитесь в техподдержку";
			МестныйКэш.СБИС.МодульОбъектаКлиент.ВызватьСбисИсключение(МестныйКэш, "СбисОбновитьТаблицыИниФайлов", , ИнфоОбОшибке);
		КонецЕсли;
		
		ДанныеКонфигураций = МестныйКэш.ФормаНастроекОбщее.СформироватьСтруктуруКонфигураций(МестныйКэш, СписокТиповНастроек);
		МестныйКэш.ГлавноеОкно.сбисЭлементФормы(ЭтаФорма, "Конфигурация").СписокВыбора.ЗагрузитьЗначения(ДанныеКонфигураций.СписокВыбора);		
		МестныйКэш.Вставить("Конфигурация", ДанныеКонфигураций.СтруктураКонфигураций);
		Конфигурация = Конфигурация;//Это имеет смысл, т.к. обновляет список выбора значением.
	КонецЕсли;
	
	Если Не ЗначениеЗаполнено(Конфигурация) Тогда 
		
		ПрефиксСервис = МестныйКэш.КэшНастроек.ПараметрыНастроек.ПрефиксСервис;
		ЗначениеПредставление = Новый Структура("ЗначениеПредставление", "Представление");
		Префикс = МестныйКэш.ФормаНастроекОбщее.ПолучитьМассивФайловДляКонфигурации(СписокТиповНастроек, ПрефиксСервис, ЗначениеПредставление);
		
		Конфигурация = МестныйКэш.ФормаНастроекОбщее.ОпределитьТипНастроекПоПрефиксу(МестныйКэш.КэшНастроек.ПараметрыНастроек.ПрефиксСервис, Префикс);
	КонецЕсли;
	
	Если Не (ТипЗнч(УстановленныеИниФайлы) = Тип("Структура") И	УстановленныеИниФайлы.Свойство("СписокФайлов", СписокИниФайлыПрименить)) Тогда
		СписокИниФайлыПрименить = УстановленныеИниФайлы;
	КонецЕсли;                                                                                                       
	
	//Обновим таблицу доступных инишек
	Если	МестныйКэш.Свойство("Конфигурация") Тогда
		
		Если СписокИниФайлыПрименить = Неопределено Тогда
			СписокИниФайлыПрименить = ТабУстановленныеИниФайлы;
		КонецЕсли;                                           
		
		СтруктураКонфигурации	= МестныйКэш.ФормаНастроек.сбисПолучитьСтруктуруКонфигурации(МестныйКэш, МестныйКэш.Конфигурация, Конфигурация);
		ДоступныеИниФайлы		= МестныйКэш.ФормаНастроекОбщее.СформироватьМассивТабДоступныеИниФайлыОбновить(СтруктураКонфигурации, СписокИниФайлыПрименить);
	Иначе
		ДоступныеИниФайлы = Новый Массив();
	КонецЕсли;
	
	ОбновитьПоляФормы(Новый Структура("ТабДоступныеИниФайлы", ДоступныеИниФайлы));
	
	//Если есть чем, то установленных инишек
	Если Не	УстановленныеИниФайлы = Неопределено Тогда
		ОбновитьПоляФормы(Новый Структура("ТабУстановленныеИниФайлы", СписокИниФайлыПрименить));
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура СбисОбновитьОтображение(ПараметрыОбновления=Неопределено, ДопПараметры=Неопределено)
	
	Перем УстановленныеИниФайлы;
	Если    	ПараметрыОбновления = Неопределено
		Или	Не	ПараметрыОбновления.Свойство("УстановленныеИни", УстановленныеИниФайлы) Тогда
		ДопПараметры = Новый Структура("Автообновление", МестныйКэш.Парам.НастройкиАвтообновление);      
		УстановленныеИниФайлы = МестныйКэш.ФормаНастроек.СбисПолучитьМассивУстановленныхИниФайлов(МестныйКэш, ДопПараметры);
	КонецЕсли;
	СбисОбновитьТаблицыИниФайлов(УстановленныеИниФайлы);
	СбисОбновитьЭлементы_РазделНастроек();
	
КонецПроцедуры

//Процедура управляет отображением элементов на вкладке файлов настроек
&НаКлиенте
Процедура СбисОбновитьЭлементы_РазделНастроек()
	
	Перем ОсновнойЭлементПанелиДействий;
		
	МестныйКэш.ГлавноеОкно.сбисЭлементФормы(ЭтаФорма, "ГруппаДействияНастройкиЛево").Видимость = МодульОбъектаКлиент().ПолучитьЗначениеПараметраСбис("СерверныеНастройки");
	
	СпособХраненияНастроек = МестныйКэш.Парам.СпособХраненияНастроек;
	КаталогНастроек        = МестныйКэш.Парам.КаталогНастроек;
	
	ОбычнаяФорма = Не МестныйКэш.ПараметрыСистемы.Клиент.УправляемоеПриложение;
	АктивныСерверныеНастройки = СпособХраненияНастроек	= 1;
	ЗаголовокНазвания = ?(АктивныСерверныеНастройки, "Выбранные настройки", "Каталог настроек");
	ЗаголовокНазвания = ЗаголовокНазвания + ?(ОбычнаяФорма, ":", "");
	ДобавитьКЗаголовку = "";
	ТипНастроек = Неопределено;
	ВыбраныНастройки = Неопределено;
	
	Если	АктивныСерверныеНастройки
		И	МестныйКэш.КэшНастроек.Свойство("ВыбранныеНастройки", ВыбраныНастройки)
		И	ВыбраныНастройки.ПараметрыРаботы.Свойство("ТипНастроек", ТипНастроек) Тогда
		
		ДобавитьКЗаголовку = ?(ТипНастроек = Неопределено, "", ТипНастроек);
		
		Если МестныйКэш.КэшНастроек.ИзмененияВНастройках Тогда
			ДобавитьКЗаголовку = ДобавитьКЗаголовку + "*";
		КонецЕсли;
		
		НастройкиНазвание = ВыбраныНастройки.Название;
		
	КонецЕсли;
	
	МестныйКэш.ГлавноеОкно.сбисЭлементФормы(ЭтаФорма, "КаталогНастроек").Видимость			= Не АктивныСерверныеНастройки;
	МестныйКэш.ГлавноеОкно.сбисЭлементФормы(ЭтаФорма, "НастройкиНазвание").Видимость		= АктивныСерверныеНастройки;
	
	ЭлементДействия = МестныйКэш.ГлавноеОкно.сбисЭлементФормы(ЭтаФорма, "ДействияСНастройками");
	ЭлементДействие_СохранитьИзменения	= МестныйКэш.ГлавноеОкно.СбисПолучитьЭлементФормы(ЭлементДействия, "ДействияСНастройками_СохранитьИзменения");
	ЭлементДействие_ПеречитатьНастройки	= МестныйКэш.ГлавноеОкно.СбисПолучитьЭлементФормы(ЭлементДействия, "ДействияСНастройками_ПеречитатьНастройки");
	ЭлементДействие_ЗагрузитьИзКаталога	= МестныйКэш.ГлавноеОкно.СбисПолучитьЭлементФормы(ЭлементДействия, "ДействияСНастройками_ЗагрузитьИзКаталога");
	ЭлементДействие_ВыгрузитьВКаталог	= МестныйКэш.ГлавноеОкно.СбисПолучитьЭлементФормы(ЭлементДействия, "ДействияСНастройками_ВыгрузитьВКаталог");
	
	Если АктивныСерверныеНастройки Тогда
		
		ОсновнойЭлементПанелиДействий	= ЭлементДействие_СохранитьИзменения;
		ЗаголовокДействиеЗагрузить		= "Загрузить настройки из каталога";
		ЗаголовокДействиеВыгрузить		= "Выгрузить настройки в каталог";
		
	ИначеЕсли	Не МестныйКэш.ПараметрыСистемы.Конфигурация.Файловая
			И	Не ОбычнаяФорма Тогда
			
			ОсновнойЭлементПанелиДействий = ЭлементДействие_ЗагрузитьИзКаталога;
		ЗаголовокДействиеЗагрузить = "Перенести настройки из каталога на сервер";
		ЗаголовокДействиеВыгрузить = "Получить настройки с сервера в каталог";
		
	КонецЕсли;
	
	Если ОсновнойЭлементПанелиДействий = Неопределено Тогда
		
		ЭлементДействия.Видимость = Ложь;
		
		Если ОбычнаяФорма Тогда
			//TODO спилить отдельную кнопку и сделать как на УФ, от панели
			МестныйКэш.ГлавноеОкно.СбисПолучитьЭлементФормы(ЭтаФорма, "ДействияСНастройками_СохранитьИзменения").Видимость = Ложь;
		КонецЕсли;
		
	Иначе
		
		ЭлементДействия.Видимость = Истина;
		
		Если ОбычнаяФорма Тогда
			МестныйКэш.ГлавноеОкно.СбисПолучитьЭлементФормы(ЭтаФорма, "ДействияСНастройками_СохранитьИзменения").Видимость = Истина;
		Иначе
			
			ЭлементДействие_СохранитьИзменения.Видимость	= АктивныСерверныеНастройки;
			ЭлементДействие_ПеречитатьНастройки.Видимость	= АктивныСерверныеНастройки;
			ЭлементДействие_ЗагрузитьИзКаталога.Заголовок	= ЗаголовокДействиеЗагрузить;
			ЭлементДействие_ВыгрузитьВКаталог.Заголовок		= ЗаголовокДействиеВыгрузить;
			
			ЭлементДействия.Заголовок	= ОсновнойЭлементПанелиДействий.Заголовок;
			ЭлементДействия.Картинка	= ОсновнойЭлементПанелиДействий.Картинка;
			
		КонецЕсли;
		
	КонецЕсли;

	Если ОбычнаяФорма	Тогда
		МестныйКэш.ГлавноеОкно.сбисЭлементФормы(ЭтаФорма, "НадписьНастройки").Заголовок	= ЗаголовокНазвания + " " + ДобавитьКЗаголовку;
	ИначеЕсли АктивныСерверныеНастройки Тогда
		МестныйКэш.ГлавноеОкно.сбисЭлементФормы(ЭтаФорма, "НастройкиНазвание").Заголовок	= ЗаголовокНазвания + " " + ДобавитьКЗаголовку;
	КонецЕсли;
	ОбновитьИнтерфейс();
		
КонецПроцедуры

 // Процедура проверяет структуру настроек, обновляет данные на форме об установленных настройках	
&НаКлиенте
Процедура СбисОбновитьИнформациюНастроек(МестныйКэш, УстановленныеИниФайлы = Неопределено, Отказ = Ложь) Экспорт
	
	СбисОбновитьОтображение();
		
КонецПроцедуры

