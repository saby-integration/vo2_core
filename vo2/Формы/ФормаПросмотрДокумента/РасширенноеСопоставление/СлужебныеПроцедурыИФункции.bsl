
&НаКлиенте
Процедура ОперацииПодготовкиКЗагрузкеРасширенноеСопоставление()
	
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

	МодульОбъектаКлиент().ПолучитьЭлементФормыОбработки(ЭтаФорма, "ТабличнаяЧастьОткрытьФормуСопоставления").Доступность = Истина;
	МодульОбъектаКлиент().ПолучитьЭлементФормыОбработки(ЭтаФорма, "ТабличнаяЧастьСоздатьСопоставитьНоменклатуруВ1С").Доступность = Истина;
	МодульОбъектаКлиент().ПолучитьЭлементФормыОбработки(ЭтаФорма, "ОтметитьВсе").Доступность = Истина;
	
	ЗаполнитьТаблицуДокументов(СоставПакета);
КонецПроцедуры

&НаКлиенте
Процедура ПослеРучнойОбработкиСопоставления(Результат, ДопПараметры = Неопределено) Экспорт
	
	Если Результат = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	ДанныеПоСтрокеСопоставления = Результат;
	
	ОбогащаемаяНоменклатура = Неопределено;
	
	Для Каждого СтрокаСопоставления Из Вложение.КлассыСопоставленияНоменклатур Цикл
		
		Если НЕ СтрокаСопоставления.УИДСтрокиСопоставления = ДанныеПоСтрокеСопоставления.УИДСтрокиСопоставления Тогда
			Продолжить;
		КонецЕсли;
		
		СтрокаСопоставления.Номенклатура1С = ДанныеПоСтрокеСопоставления.Номенклатура1С; 
		МодульОбъектаКлиент().СтрокаСопоставленияСБИСКлиент_Вставить(СтрокаСопоставления, "НеобходимоСопоставление", ДанныеПоСтрокеСопоставления.НеобходимоСопоставление);
		ОбогащаемаяНоменклатура = СтрокаСопоставления;
		
		Прервать;	

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
	
	ИмеютсяИзмененияСопоставленнойНоменклатуры = Ложь;
	Для Каждого КлассСопоставления Из Вложение.КлассыСопоставленияНоменклатур Цикл
		Если КлассСопоставления.НеобходимоСопоставление Тогда
			ИмеютсяИзмененияСопоставленнойНоменклатуры = Истина;
			МодульОбъектаКлиент().ПолучитьЭлементФормыОбработки(ЭтаФорма,"ТабличнаяЧастьЗаписатьСопоставлениеНоменклатуры").Доступность = Истина;
			Прервать;
		КонецЕсли;
	КонецЦикла;
	
	Если НЕ ИмеютсяИзмененияСопоставленнойНоменклатуры Тогда
		МодульОбъектаКлиент().ПолучитьЭлементФормыОбработки(ЭтаФорма,"ТабличнаяЧастьЗаписатьСопоставлениеНоменклатуры").Доступность = Ложь;
		Возврат;
	КонецЕсли;
	
	ЗаполнитьТаблицуДокументов(СоставПакета);
КонецПроцедуры

&НаКлиенте
Процедура ОбновитьСтатусыСопоставления(Элемент = Неопределено)
	
	Если НЕ Вложение.Свойство("КлассыСопоставленияНоменклатур") Тогда
		Возврат;
	КонецЕсли;
	ОтборНоменклатуры = Новый Структура();
	
	ЕстьНесопоставленнаяНоменклатура = Ложь;
	
	Для Каждого ПозицияНоменклатурыСБИС Из Вложение.КлассыСопоставленияНоменклатур Цикл
		
		ОтборНоменклатуры.Вставить("Название", ПозицияНоменклатурыСБИС.НоменклатураСБИС.Наименование); 
		НоменклатураВТабличнойЧасти = ТабличнаяЧасть.НайтиСтроки(ОтборНоменклатуры);
		Если НоменклатураВТабличнойЧасти.Количество() Тогда               
			Для Каждого СтрокаНоменклатуры Из НоменклатураВТабличнойЧасти Цикл  
				Если СтрокаНоменклатуры.Статус = 2 Тогда
					Продолжить;
				КонецЕсли; 
				
				Если НЕ ПозицияНоменклатурыСбис.Номенклатура1С.Количество() Тогда
					СтрокаНоменклатуры.Статус = 1;
					ЕстьНесопоставленнаяНоменклатура = Истина;
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
	
	ТекущийДокумент = сбисЭлементФормы(ЭтаФорма,"ТаблицаДокументов").ТекущиеДанные;
	Если ЕстьНесопоставленнаяНоменклатура И НЕ ТекущийДокумент = Неопределено Тогда
		ТекущийДокумент.Статус = "Не вся номенклатура сопоставлена.";
		ТекущийДокумент.СтатусКартинка = 1;
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ПересчетПоКоэффициентамЕдиницИзмерения(ПодготовленныеДанныеНоменклатур)
	
	Для Каждого КлассСопоставления Из ПодготовленныеДанныеНоменклатур Цикл
		
		Для Каждого Номенклатура1С Из КлассСопоставления.Номенклатура1С Цикл
			
			// Если нет ссылки на номенклатуру - пересчёт не нужен, будет сделан на форме ручного сопоставления 
			Если НЕ Номенклатура1С.Значение.Основное 
				 ИЛИ НЕ ЗначениеЗаполнено(Номенклатура1С.Ключ) Тогда
				Продолжить;
			КонецЕсли;                     
			
			// Получим коэффициент единицы СБИС, он же - коэффициент поставщика.
			Для Каждого ЕдиницаПоставщика Из КлассСопоставления.НоменклатураСБИС.Единицы Цикл 
					КоэффициентСБИС = ЕдиницаПоставщика.Значение.Коэффициент; 
					Прервать;
			КонецЦикла;
				
			// Получим коэффициент единицы.
			Если Номенклатура1С.Значение.Единицы.Количество() Тогда
				Для Каждого Единица Из Номенклатура1С.Значение.Единицы Цикл
					БазоваяЕдиницаОкеи = Единица.Значение.ОКЕИ;
					Коэффициент1С = Единица.Значение.Коэффициент;
					Прервать;
				КонецЦикла;
			Иначе
				Коэффициент1С = КоэффициентСБИС;	
			КонецЕсли;
			
			Если ЗначениеЗаполнено(Номенклатура1С.Значение.Кол_Во) Тогда
				МодульОбъектаКлиент().СтрокаСопоставленияСБИСКлиент_Вставить(КлассСопоставления, "БазоваяЕдиницаОкеи", БазоваяЕдиницаОкеи);
				Продолжить;
			КонецЕсли;
			
			// Заполним данные для табличной части документа 1С
			ТабличныеДанные1С = Новый Структура("Номенклатура, Цена, Сумма, СуммаБезНал, СуммаНДС, СтавкаНДС, Кол_Во");
			ТабличныеДанные1С.Вставить("Номенклатура", Номенклатура1С.Ключ);
			ТабличныеДанные1С.Вставить("БазоваяЕдиницаОкеи", БазоваяЕдиницаОкеи);
						
			Если НЕ Коэффициент1С = Число(КоэффициентСБИС) Тогда	
				ТабличныеДанные1С.Вставить("Цена", КлассСопоставления.НоменклатураСБИС.Цена / Коэффициент1С);
				ТабличныеДанные1С.Вставить("Кол_во", КлассСопоставления.НоменклатураСБИС.Кол_во * Коэффициент1С); 
				СписокСвойств = "Сумма, СуммаНДС, СтавкаНДС, СуммаБезнал";
				ЗаполнитьЗначенияСвойств(ТабличныеДанные1С, КлассСопоставления.НоменклатураСБИС, СписокСвойств);
			Иначе                       
				СписокСвойств = "Цена, Кол_во, Сумма, СуммаБезНал, СуммаНДС, СтавкаНДС";
				ЗаполнитьЗначенияСвойств(ТабличныеДанные1С, КлассСопоставления.НоменклатураСБИС, СписокСвойств); 
			КонецЕсли;
			
			// Запихнём данные в класс номенклатуры 1С
			МодульОбъектаКлиент().ОписаниеНоменклатуры1СКлиент_Заполнить(Номенклатура1С.Значение, ТабличныеДанные1С);
			
		КонецЦикла;
	КонецЦикла;
	
КонецПроцедуры

&НаКлиенте
Процедура ПересчетНДСПоДаннымСтрокиСопоставления(ПодготовленныеДанныеНоменклатур)
	
	Для Каждого КлассСопоставления Из ПодготовленныеДанныеНоменклатур Цикл
		
		НоменклатураСБИС = КлассСопоставления.НоменклатураСБИС;
		Номенклатуры1С 	 = КлассСопоставления.Номенклатура1С;
		
		Если ЗначениеЗаполнено(НоменклатураСБИС.СуммаНДС) 
			И ЗначениеЗаполнено(НоменклатураСБИС.СтавкаНДС)
			И ЗначениеЗаполнено(НоменклатураСБИС.Сумма) Тогда
			КоэффициентНДСДляРасчета = НоменклатураСБИС.СуммаНДС / НоменклатураСБИС.Сумма;    
			СтавкаНДС 			 	 = НоменклатураСБИС.СтавкаНДС;
		ИначеЕсли НоменклатураСБИС.СуммаБезНал = НоменклатураСБИС.Сумма Тогда
			СтавкаНДС = "";
		ИначеЕсли ЗначениеЗаполнено(НоменклатураСБИС.СуммаБезНал)
			И ЗначениеЗаполнено(НоменклатураСБИС.Сумма) Тогда
			
			СуммаНДС = НоменклатураСБИС.Сумма - НоменклатураСБИС.СуммаБезНал;
			КоэффициентНДСДляРасчета = Окр(СуммаНДС / НоменклатураСБИС.СуммаБезНал, 2, 1); 
			СтавкаНДСВПроцентах 	 = КоэффициентНДСДляРасчета * 100;
			СтавкаНДС 				 = Строка(СтавкаНДСВПроцентах);
		Иначе
			Продолжить;
		КонецЕсли;
		
		Для Каждого Номенклатура1С Из Номенклатуры1С Цикл		
			
			Номенклатура1С.Значение.СуммаБезНал = ОКР(Номенклатура1С.Значение.Сумма / (КоэффициентНДСДляРасчета + 1), 2, 1);
			Номенклатура1С.Значение.СуммаНДС 	= ОКР(Номенклатура1С.Значение.Сумма - Номенклатура1С.Значение.СуммаБезНал, 2, 1);
			Номенклатура1С.Значение.СтавкаНДС 	= СтавкаНДС;
			
		КонецЦикла;
	КонецЦикла;
	
КонецПроцедуры

&НаСервере
Процедура АвтоматическоеСопоставлениеНоменклатур(ПодготовленныеДанныеНоменклатур, ПорядокАвтоматическогоСопоставления, ИмяСправочникаНоменклатуры)

	ПараметрыСопоставленияПоРеквизитам = СопоставитьРеквизитыПоискаСМетаданными(ПорядокАвтоматическогоСопоставления, ИмяСправочникаНоменклатуры);
	
	Если ПараметрыСопоставленияПоРеквизитам.Количество() Тогда
		ПоискСопоставленийПоРеквизитамСправочника(ПараметрыСопоставленияПоРеквизитам, ПодготовленныеДанныеНоменклатур, ИмяСправочникаНоменклатуры);
	КонецЕсли;
	
	ПоискСопоставленийПоДополнительнымСведениям(ПорядокАвтоматическогоСопоставления, ПодготовленныеДанныеНоменклатур, ИмяСправочникаНоменклатуры);
	
КонецПроцедуры

&НаСервереБезКонтекста
Функция СопоставитьРеквизитыПоискаСМетаданными(ПорядокАвтоматическогоСопоставления, ИмяСправочникаНоменклатуры)
	
	ПустаяСсылкаОбъектаМетаданных = ПредопределенноеЗначение("Справочник." + ИмяСправочникаНоменклатуры + ".ПустаяСсылка");
	МетаданныеНоменклатуры = ПустаяСсылкаОбъектаМетаданных.Метаданные();
	
	ПараметрыСопоставленияПоРеквизитам = Новый Массив;
	
	Для Каждого ПараметрПоиска Из ПорядокАвтоматическогоСопоставления Цикл
		
		Если НЕ МетаданныеНоменклатуры.Реквизиты.Найти(ПараметрПоиска) = Неопределено Тогда
			ПараметрыСопоставленияПоРеквизитам.Добавить(ПараметрПоиска);
		КонецЕсли;
		
	КонецЦикла;
	
	Возврат ПараметрыСопоставленияПоРеквизитам;
	
КонецФункции

&НаСервере
Процедура ПоискСопоставленийПоРеквизитамСправочника(РеквизитыСправочника, ПодготовленныеДанныеНоменклатур, ИмяСправочникаНоменклатуры)
	
	Запрос = Новый Запрос; 
	Запрос.Текст = "ВЫБРАТЬ
	|	Номенклатура.Ссылка КАК Ссылка
	|ИЗ
	|	Справочник.%СПРНоменклатура% КАК Номенклатура
	|ГДЕ
	|	Номенклатура.%ПараметрПоиска% = &ЗначениеПараметраПоиска";
	
	Запрос.Текст = СтрЗаменить(Запрос.Текст, "%СПРНоменклатура%", ИмяСправочникаНоменклатуры);
	
	Для Каждого СтрокаНоменклатуры Из ПодготовленныеДанныеНоменклатур Цикл
				
		Для Каждого ПараметрПоиска Из РеквизитыСправочника Цикл
			
			ЗначениеПараметраПоиска = Неопределено; 
			
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
			НайденнаяНоменклатура = Запрос.Выполнить().Выгрузить();
			
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

&НаСервере
Процедура ПоискСопоставленийПоДополнительнымСведениям(ПорядокАвтоматическогоСопоставления, ПодготовленныеДанныеНоменклатур, ИмяСправочникаНоменклатуры)
	
	Запрос = Новый Запрос;	
	Запрос.Текст = "ВЫБРАТЬ
	               |	Номенклатура.Ссылка КАК Ссылка
	               |ИЗ
	               |	РегистрСведений.ДополнительныеСведения КАК ДополнительныеСведения
	               |		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.%СПРНоменклатура% КАК Номенклатура
	               |		ПО (ДополнительныеСведения.Объект = Номенклатура.Ссылка)
	               |ГДЕ
	               |	ДополнительныеСведения.Свойство.Наименование = &ПараметрПоиска
	               |	И ДополнительныеСведения.Значение = &ЗначениеПараметраПоиска";
	
	Запрос.Текст = СтрЗаменить(Запрос.Текст, "%СПРНоменклатура%", ИмяСправочникаНоменклатуры);
	
	Для Каждого СтрокаНоменклатуры Из ПодготовленныеДанныеНоменклатур Цикл
				
		Для Каждого ПараметрПоиска Из ПорядокАвтоматическогоСопоставления Цикл
			
			ЗначениеПараметраПоиска = Неопределено; 
			
			Попытка
				Если НЕ СтрокаНоменклатуры.НоменклатураСБИС.Свойство(ПараметрПоиска) Тогда
					Продолжить;
				ИначеЕсли НЕ ЗначениеЗаполнено(СтрокаНоменклатуры.НоменклатураСБИС[ПараметрПоиска]) Тогда
					Продолжить;
				КонецЕсли;
			Исключение
				Продолжить;
			КонецПопытки;
			
			Запрос.УстановитьПараметр("ПараметрПоиска", ПараметрПоиска);
			
			ЗначениеПараметраПоиска = СтрокаНоменклатуры.НоменклатураСБИС[ПараметрПоиска];
			Запрос.УстановитьПараметр("ЗначениеПараметраПоиска", ЗначениеПараметраПоиска);
			НайденнаяНоменклатура = Запрос.Выполнить().Выгрузить();
			
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
