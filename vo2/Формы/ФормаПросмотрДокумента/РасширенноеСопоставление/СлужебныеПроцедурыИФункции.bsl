
&НаКлиенте
Процедура ОперацииПодготовкиКЗагрузкеРасширенноеСопоставление()
	
	ЗаполнитьДанныеНоменклатурДляРасширенногоСопоставления();
	
	ЭлементФормыХарактеристика = сбисЭлементФормы(ЭтаФорма,"ТабличнаяЧастьХарактеристика");
	Если Не МестныйКэш.ПараметрыСистемы.Клиент.УправляемоеПриложение Тогда
		ЭлементФормыХарактеристика = ЭтаФорма.ЭлементыФормы.ТабличнаяЧасть.Колонки.Характеристика;
	КонецЕсли; 

	ЭлементФормыХарактеристикаПоставщика = сбисЭлементФормы(ЭтаФорма,"ТабличнаяЧастьХарактеристика");
	Если Не МестныйКэш.ПараметрыСистемы.Клиент.УправляемоеПриложение Тогда
		ЭлементФормыХарактеристикаПоставщика = ЭтаФорма.ЭлементыФормы.ТабличнаяЧасть.Колонки.Характеристика;
	КонецЕсли;
	
	ЭлементФормыХарактеристика.Видимость = Ложь;
	ЭлементФормыХарактеристикаПоставщика.Видимость = Ложь;
	
	ОбновитьСтатусыСопоставления();
	
КонецПроцедуры

// функция для совместимости кода 
&НаКлиенте
Функция СбисПолучитьФормуСтар(СбисИмяФормы, Объект1С = Неопределено, ПараметрыФормы = Неопределено, СбисВладелецФормы = Неопределено) Экспорт
	
	Попытка
		ПараметрыЗапросаФормы = Новый Структура;
		ПараметрыЗапросаФормы.Вставить("Владелец",			СбисВладелецФормы);
		ПараметрыЗапросаФормы.Вставить("ОбработкаОбъект",	Объект1С);
		ПараметрыЗапросаФормы.Вставить("Параметры",			ПараметрыФормы);
		Возврат МодульОбъектаКлиент().ПолучитьФормуОбработки(СбисИмяФормы, ПараметрыЗапросаФормы);
	Исключение
		Результат		= Ложь;
		ИнфоОбОшибке	= ИнформацияОбОшибке();
		ОшибкаПолученияФормы= МодульОбъектаКлиент().НовыйСбисИсключение(ИнфоОбОшибке, "ФормаГлавноеОкно.СбисПолучитьФорму");
		ПолноеИмяФормы		= МодульОбъектаКлиент().ПолучитьФормуОбработки_ПолноеИмяФормы(СбисИмяФормы, Объект1С);
		БезопасноеИмяФормы	= МодульОбъектаКлиент().ПолучитьФормуОбработки_БезопасноеИмяФормы(ПолноеИмяФормы, Объект1С);
		
		МодульОбъектаКлиент().СообщитьСбисИсключение(ОшибкаПолученияФормы);
		МодульОбъектаКлиент().ПолучитьФормуОбработки_ЗакэшироватьФорму(Результат, БезопасноеИмяФормы);
		Возврат Результат;
	КонецПопытки;
	
КонецФункции

&НаКлиенте
Процедура ПослеРучнойОбработкиСопоставления(Результат, ДопПараметры = Неопределено) Экспорт
	
	Если Результат = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	ДанныеПоСтрокеСопоставления = Результат;
	
	ОбогащаемаяНоменклатура = Неопределено;
	
	Для Каждого СтрокаСопоставления Из ДанныеНоменклатурДляРасширенногоСопоставления.ПодготовленныеДанныеНоменклатур Цикл
		БезопасноеИмяИдентификатора = ПолучитьБезопасноеНаименование(СтрокаСопоставления.НоменклатураСБИС.Наименование); 
		СтрокаСопоставленияПослеРедактирования = Новый Структура;
		Если ДанныеПоСтрокеСопоставления.Свойство(БезопасноеИмяИдентификатора, СтрокаСопоставленияПослеРедактирования) Тогда
			СтрокаСопоставления.Номенклатура1С = СтрокаСопоставленияПослеРедактирования.Номенклатура1С;
			ОбогащаемаяНоменклатура = СтрокаСопоставления;
			Прервать;
		КонецЕсли;
		
	КонецЦикла;
	
	ОтборНоменклатуры = Новый Структура();
	ОтборНоменклатуры.Вставить("Название", ОбогащаемаяНоменклатура.НоменклатураСБИС.Наименование); 
	ИскомыеСтрокиНоменклатуры = ТабличнаяЧасть.НайтиСтроки(ОтборНоменклатуры);
	
	Если ИскомыеСтрокиНоменклатуры.Количество() Тогда  
		Для Каждого Номенклатура Из ИскомыеСтрокиНоменклатуры Цикл
			Номенклатура.Статус = 2;
		КонецЦикла;
	Иначе
		Сообщить("Запись ручного сопоставления прошла с ошибкой. Номенклатура 1С не записалась");
	КонецЕсли;
	
	СоставПакета.Вставить("ДопПараметрыСопоставления", ДанныеНоменклатурДляРасширенногоСопоставления); 
	ЗаполнитьТаблицуДокументов(СоставПакета);
КонецПроцедуры

&НаКлиенте
Процедура ОбновитьСтатусыСопоставления()
	
	Если НЕ ДанныеНоменклатурДляРасширенногоСопоставления.Свойство("ПодготовленныеДанныеНоменклатур") Тогда
		Возврат;
	КонецЕсли;
	ОтборНоменклатуры = Новый Структура();
	
	Для Каждого ПозицияНоменклатурыСБИС Из ДанныеНоменклатурДляРасширенногоСопоставления.ПодготовленныеДанныеНоменклатур Цикл
		
		ОтборНоменклатуры.Вставить("Название", ПозицияНоменклатурыСБИС.НоменклатураСБИС.Наименование); 
		НоменклатураВТабличнойЧасти = ТабличнаяЧасть.НайтиСтроки(ОтборНоменклатуры);
		Если НоменклатураВТабличнойЧасти.Количество() Тогда               
			Для Каждого СтрокаНоменклатуры Из НоменклатураВТабличнойЧасти Цикл  
				Если СтрокаНоменклатуры.Статус = 2 Тогда
					Продолжить;
				КонецЕсли;
				Для Каждого Номенклатура1С ИЗ ПозицияНоменклатурыСбис.Номенклатура1С Цикл
					Если ЗначениеЗаполнено(Номенклатура1С.Ключ) Тогда
						СтрокаНоменклатуры.Статус = 0;
					Иначе
						СтрокаНоменклатуры.Статус = 1; 
					КонецЕсли;
				КонецЦикла;
			КонецЦикла;
		КонецЕсли;
	КонецЦикла;
	
КонецПроцедуры

&НаКлиенте
Процедура ЗаполнитьДанныеНоменклатурДляРасширенногоСопоставления(ОбогащенныеДанныеНоменклатурыДляСопоставления = Неопределено)
	
	ПодготовленныеДанныеНоменклатур = Новый Массив;
	
	Если НЕ ОбогащенныеДанныеНоменклатурыДляСопоставления = Неопределено Тогда
		ДанныеНоменклатурДляРасширенногоСопоставления.Вставить("ПодготовленныеДанныеНоменклатур", ОбогащенныеДанныеНоменклатурыДляСопоставления);
		Возврат;
	КонецЕсли;
	
	ТабЧасть = сбисЭлементФормы(ЭтаФорма,"ТабличнаяЧасть");
	Для Каждого ПозицияНоменклатурыКонтрагента Из ТабличнаяЧасть Цикл
		
		ГлавноеОкно = МестныйКэш.ГлавноеОкно;      
		ТекущийДокумент = сбисЭлементФормы(ЭтаФорма,"ТаблицаДокументов").ТекущиеДанные;
		ПутьТаблДок = ТекущийДокумент.ПутьТаблДок;
		ТекущееВложение = ТекущийДокумент.Вложение[0].Значение;
		ТаблДок = МестныйКэш.ОбщиеФункции.РассчитатьЗначениеИзСтруктуры(ПутьТаблДок, ТекущееВложение.СтруктураФайла);  
		
		// Я так и не разобрался почему, но на некоторых вложениях структура файла пуста (спагетти код, но может потому что нет инишки нужной?), потому ставлю затычку
		Если ТаблДок = Неопределено Тогда
			Возврат;
		КонецЕсли;
		
		ИскомаяСтрокаТаблДок = Неопределено;
		
		Для Каждого СтрТабл Из ТаблДок Цикл
			
			Если СтрТабл.Название = ПозицияНоменклатурыКонтрагента.Название Тогда
				ИскомаяСтрокаТаблДок = СтрТабл;
			КонецЕсли;
			
		КонецЦикла;
		
		Если НЕ ИскомаяСтрокаТаблДок = Неопределено Тогда
			
			ДанныеНоменклатурыКонтрагента = Новый Структура();
			ДанныеНоменклатурыКонтрагента.Вставить("КодПокупателя");
			ДанныеНоменклатурыКонтрагента.Вставить("Код");
			ДанныеНоменклатурыКонтрагента.Вставить("Артикул");
			ДанныеНоменклатурыКонтрагента.Вставить("Название");
			ДанныеНоменклатурыКонтрагента.Вставить("Идентификатор");
			ДанныеНоменклатурыКонтрагента.Вставить("Номенклатура");
			ДанныеНоменклатурыКонтрагента.Вставить("Характеристика");
			ДанныеНоменклатурыКонтрагента.Вставить("GTIN");
			ДанныеНоменклатурыКонтрагента.Вставить("КодПоставщика");
			ДанныеНоменклатурыКонтрагента.Вставить("ЕдИзм");
			ДанныеНоменклатурыКонтрагента.Вставить("ОКЕИ");
			
			ЗаполнитьЗначенияСвойств(ДанныеНоменклатурыКонтрагента, ИскомаяСтрокаТаблДок);
			ПутьКонтрагента = "Файл.Документ.Отправитель";
			ГолыйКлассНоменклатурыДляСопоставления = МодульОбъектаКлиент().НовыйСтрокаСопоставленияСБИСКлиент(ДанныеНоменклатурыКонтрагента);	
			
		КонецЕсли;
		
		СпособСопоставления = МестныйКэш.Парам.СпособСопоставленияНоменклатуры; 
		Если СпособСопоставления = 1 Тогда
			ИмяФормыРаботыСНоменклатурой = "СопоставлениеНоменклатуры_ДБФ"; 
		Иначе
			ИмяФормыРаботыСНоменклатурой = "СопоставлениеНоменклатуры_СБИС";
		КонецЕсли;                                                          
		
		ФормаРаботыСНоменклатурой = ГлавноеОкно.сбисНайтиФормуФункции("НоменклатураПоставщика_МассовыйПоиск", ИмяФормыРаботыСНоменклатурой,"", МестныйКэш);
		
		СписокНоменклатурДляОбогащения = Новый Массив; 
		СписокНоменклатурДляОбогащения.Добавить(ГолыйКлассНоменклатурыДляСопоставления);
		
		ПараметрыДляОбогащения = Новый Структура("Контрагент, Номенклатура");
		
		ПараметрыДляОбогащения.Вставить("Контрагент",	СоставПакета.Контрагент);  
		ПараметрыДляОбогащения.Вставить("Номенклатура",	СписокНоменклатурДляОбогащения);
		
		ДопПараметры = Новый Структура("Кэш", МестныйКэш);
		Попытка
			ОбогащенныеДанныеНоменклатурыДляСопоставления =	ФормаРаботыСНоменклатурой.НоменклатураПоставщика_МассовыйПоиск(ПараметрыДляОбогащения, ДопПараметры); 
		Исключение
			МодульОбъектаКлиент().СообщитьСбисИсключение(ИнформацияОбОшибке(), "ФормаРаботыСНоменклатурой.НоменклатураПоставщика_МассовыйПоиск");
			Продолжить;
		КонецПопытки;
		
		Если МестныйКэш.Ини.Конфигурация.Свойство("Номенклатура") Тогда
			ИмяСправочникаНоменклатуры = СокрЛП(Сред(МестныйКэш.Ини.Конфигурация.Номенклатура.Значение, Найти(МестныйКэш.Ини.Конфигурация.Номенклатура.Значение, ".") + 1));
		Иначе
			ИмяСправочникаНоменклатуры = "Номенклатура";
		КонецЕсли;
		
		ПустаяСсылкаНоменклатуры = ПолучитьПустуюСсылкуСправочника(ИмяСправочникаНоменклатуры);
		Для Каждого ОбогащеннаяНоменклатура Из ОбогащенныеДанныеНоменклатурыДляСопоставления Цикл
			
			Если Не ОбогащеннаяНоменклатура.Номенклатура1С.Количество() Тогда 
				ГолыйКлассОписаниеНоменклатуры1С = МодульОбъектаКлиент().НовыйОписаниеНоменклатуры1СКлиент();
				ОбогащеннаяНоменклатура.Номенклатура1С.Вставить(ПустаяСсылкаНоменклатуры, ГолыйКлассОписаниеНоменклатуры1С);
			КонецЕсли;
			
			ОбогащеннаяНоменклатура.Вставить("НеобходимоСопоставление", Ложь);
			ПодготовленныеДанныеНоменклатур.Добавить(ОбогащеннаяНоменклатура);
			
		КонецЦикла; 
		
	КонецЦикла;
		
	ПорядокАвтоматическогоСопоставления = МодульОбъектаКлиент().ПолучитьЗначениеПараметраСБИС("ПорядокАвтоматическогоСопоставления");
	
	ИспользоватьАвтоматическоеСопоставление = МодульОбъектаКлиент().ПолучитьЗначениеПараметраСБИС("ИспользоватьАвтоматическоеСопоставлениеНоменклатуры");
	
	Если НЕ ИспользоватьАвтоматическоеСопоставление Тогда
		ДанныеНоменклатурДляРасширенногоСопоставления.Вставить("ПодготовленныеДанныеНоменклатур", ПодготовленныеДанныеНоменклатур);
		СоставПакета.Вставить("ДопПараметрыСопоставления", ДанныеНоменклатурДляРасширенногоСопоставления); 
		ЗаполнитьТаблицуДокументов(СоставПакета);
		
		Возврат;
	КонецЕсли;
	
	// TO DO Ду-ду Убрать как только появится список полей согласно инишкам (с) Сычев
	Если ПорядокАвтоматическогоСопоставления = Неопределено Тогда
		
		ПорядокАвтоматическогоСопоставления = Новый Массив;
		ПорядокАвтоматическогоСопоставления.Добавить("Артикул");
		ПорядокАвтоматическогоСопоставления.Добавить("КодПоставщика");
		ПорядокАвтоматическогоСопоставления.Добавить("КодПокупателя");
		ПорядокАвтоматическогоСопоставления.Добавить("GTIN");
		ПорядокАвтоматическогоСопоставления.Добавить("Идентификатор");
		ПорядокАвтоматическогоСопоставления.Добавить("Код");		
		
		АвтоматическоеСопоставлениеНоменклатур(ПодготовленныеДанныеНоменклатур, ПорядокАвтоматическогоСопоставления, ИмяСправочникаНоменклатуры);
		
	Иначе
		АвтоматическоеСопоставлениеНоменклатур(ПодготовленныеДанныеНоменклатур, ПорядокАвтоматическогоСопоставления.Порядок, ИмяСправочникаНоменклатуры);
	КонецЕсли;
	
	ДанныеНоменклатурДляРасширенногоСопоставления.Вставить("ПодготовленныеДанныеНоменклатур", ПодготовленныеДанныеНоменклатур);
	
	СоставПакета.Вставить("ДопПараметрыСопоставления", ДанныеНоменклатурДляРасширенногоСопоставления); 
	ЗаполнитьТаблицуДокументов(СоставПакета);
	
КонецПроцедуры

&НаСервере
Процедура АвтоматическоеСопоставлениеНоменклатур(ПодготовленныеДанныеНоменклатур, ПорядокАвтоматическогоСопоставления, ИмяСправочникаНоменклатуры)
	
	Запрос = Новый Запрос; 
	Запрос.Текст = "ВЫБРАТЬ
	|	Номенклатура.Ссылка КАК Ссылка
	|ИЗ
	|	Справочник.%СПРНоменклатура% КАК Номенклатура
	|ГДЕ
	|	Номенклатура.%ПараметрПоиска% = &ЗначениеПараметраПоиска";
	
	Запрос.Текст = СтрЗаменить(Запрос.Текст, "%СПРНоменклатура%", ИмяСправочникаНоменклатуры);
	
	Для Каждого СтрокаНоменклатуры Из ПодготовленныеДанныеНоменклатур Цикл
		
		Для Каждого ПараметрПоиска Из ПорядокАвтоматическогоСопоставления Цикл
			
			ЗначениеПараметраПоиска = Неопределено; 
			
			// А вот чё тут делать? Не пришло поле какое-то, грустим
			Попытка
				Если НЕ СтрокаНоменклатуры.НоменклатураСБИС.Свойство(ПараметрПоиска) Тогда
					Продолжить;
				ИначеЕсли НЕ ЗначениеЗаполнено(СтрокаНоменклатуры.НоменклатураСБИС[ПараметрПоиска]) Тогда
					Продолжить;
				КонецЕсли;
			Исключение
				Продолжить;
			КонецПопытки;
			
			ЗначениеПараметраПоиска = СтрокаНоменклатуры.НоменклатураСБИС[ПараметрПоиска];
			Запрос.УстановитьПараметр("ЗначениеПараметраПоиска", ЗначениеПараметраПоиска);
			Запрос.Текст = СтрЗаменить(Запрос.Текст, "%ПараметрПоиска%", ПараметрПоиска); 
			НайденнаяНоменклатура = Запрос.Выполнить().Выбрать();
			
			Если НайденнаяНоменклатура.Количество() Тогда
				
				Для Каждого Номенклатура1С Из НайденнаяНоменклатура Цикл          
					ОписаниеНоменклатуры1С = МодульОбъектаСервер().НовыйОписаниеНоменклатуры1ССервер();
					СтрокаНоменклатуры.Номенклатура1С.Вставить(Номенклатура1С.Ссылка, ОписаниеНоменклатуры1С); 
				КонецЦикла;  
				
				Прервать; 
			КонецЕсли;
		КонецЦикла;
	КонецЦикла;
	
КонецПроцедуры

Функция ПолучитьБезопасноеНаименование(ИсходнаяСтрока) Экспорт
	
	Результат = "";
	
	Латиница = "QWERTYUIOPASDFGHJKLZXCVBNMqwertyuiopasdfghjklzxcvbnm";
	Кириллица = "абвгдеёзжийклмнопрстуфхцчшщъыьэюяАБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯ";
	Цифры = "0123456789";                                                            
	ДопустимыеСимволы = Латиница + Кириллица + Цифры;
	
	Для ПозицияСимвола = 1 по СтрДлина(ИсходнаяСтрока) Цикл
		ТекСимв = Сред(ИсходнаяСтрока, ПозицияСимвола, 1);
		Если Найти(ДопустимыеСимволы, ТекСимв) > 0 Тогда
			Результат = Результат + ТекСимв;
		КонецЕсли;
	КонецЦикла;
	
	Возврат ВРЕГ(Результат);
	
КонецФункции

&НаСервере
Функция ПолучитьПустуюСсылкуСправочника(ИмяСправочника)
	
	ИмяПредопределенногоЭлемента = "Справочник." + ИмяСправочника + ".ПустаяСсылка";
	Возврат ПредопределенноеЗначение(ИмяПредопределенногоЭлемента);	
	
КонецФункции
