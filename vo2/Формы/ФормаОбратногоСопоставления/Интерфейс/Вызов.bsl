&НаКлиенте 
Процедура Показать(ПараметрыОткрытия) Экспорт

	СбисУстановитьФорму(ПараметрыОткрытия);
	
	#Если ТолстыйКлиентОбычноеПриложение Тогда
		ОткрытьМодально();
	#Иначе
		Открыть();
	#КонецЕсли
	
КонецПроцедуры 

&НаКлиенте
Процедура СбисУстановитьФорму(ПараметрыОткрытия)
	
	МодульОбъектаКлиент = МодульОбъектаКлиент();
	
	Кэш						= МодульОбъектаКлиент.ПолучитьТекущийЛокальныйКэш();
	
	ЭтаФорма.Заголовок		= ПараметрыОткрытия.ЗаголовокФормы;
	ДокументДанные			= ПараметрыОткрытия.ДокументДанные;
	Контрагент				= ПараметрыОткрытия.Контрагент;
	ИдентификаторДокумента	= ПараметрыОткрытия.ИдентификаторДокумента;
	ПараметрыРасхождения	= ПараметрыОткрытия.ПараметрыРасхождения;
	Вложение 				= ПараметрыОткрытия.ПараметрыРасхождения.Вложение;
	
	КнопкаЗаписатьНажата = Ложь;
	
	ПорядокАвтоСопоставления = МодульОбъектаКлиент.ПолучитьЗначениеПараметраСБИС("ПорядокАвтоматическогоСопоставления");
	Если Не ЗначениеЗаполнено(ПорядокАвтоСопоставления) Тогда
		ПорядокАвтоСопоставления = МодульОбъектаКлиент.ПорядокАвтоматическогоСопоставленияПоУмолчаниюКлиент();
	Иначе
		ПорядокАвтоСопоставления = МодульОбъектаКлиент.СбисРазложитьСтрокуВМассивПодстрок(ПорядокАвтоСопоставления, ",");
	КонецЕсли;
	ЭлементТипКода = МодульОбъектаКлиент.ПолучитьЭлементФормыОбработки(ЭтаФорма, "ТаблицаСопоставленийТипКодаСБИС");
	ЭлементТипКода.СписокВыбора.ЗагрузитьЗначения(ПорядокАвтоСопоставления);
	
	ТаблДокСБИС = ПараметрыОткрытия.ПараметрыРасхождения.Вложение.СтруктураФайла.Файл.Документ.ТаблДок.СтрТабл;
	СписокНоменклатураКонтрагента = МодульОбъектаКлиент.ПолучитьЭлементФормыОбработки(ЭтаФорма, "ТаблицаСопоставленийНоменклатураКонтрагента");  
	СписокНоменклатураКонтрагента.СписокВыбора.Очистить();
	
	Для Каждого СтрТаблДокСБИС из ТаблДокСБИС Цикл
		СписокНоменклатураКонтрагента.СписокВыбора.Добавить(СтрТаблДокСБИС, СтрТаблДокСБИС.Название); 
	КонецЦикла;
	
	ПараметрыФормы = Новый Структура("Результат", Неопределено);
	
	ЗаполнитьТаблицуСопоставленийПоУмолчанию();
	
	Если ХарактеристикиИспользуютсяВДокументе Тогда
		МодульОбъектаКлиент.ПолучитьЭлементФормыОбработки(ЭтаФорма, "ТаблицаСопоставленийХарактеристика1С").Видимость = Истина;
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ЗаполнитьТаблицуСопоставленийПоУмолчанию(Команда = Неопределено)
	
	ТаблицаСопоставлений.Очистить();
	
	Если Не ЗначениеЗаполнено(ДокументДанные)
			Или Не ДокументДанные.Свойство("мФайл") Тогда
		Закрыть(Неопределено);
		Возврат;
	КонецЕсли;
	
	ФормаРаботыСНоменклатурой = МодульОбъектаКлиент().ПолучитьЗначениеПараметраСбис("МодульСопоставлениеНоменклатуры");
	
	СписокНоменклатурДляОбогащения = Новый Массив;
	Для Каждого мФайл Из ДокументДанные.мФайл Цикл
		Для Каждого мТаблДок Из мФайл.Значение.мТаблДок Цикл
			ИмямФайл		= мФайл.Ключ;
			ИмяТабЧасти		= мТаблДок.Ключ;
			ИндексВТабЧасти	= 0;
			Для Каждого СтрокаДокумента1С Из мТаблДок.Значение Цикл
				
				// Формируем идентификатор строки, как путь в исходных данных документа
				ИдСтроки = ИмямФайл + "." + "мТаблДок" + "." + ИмяТабЧасти + "." + ИндексВТабЧасти;
				СтрокаДокумента1С.Вставить("ИдСтроки", ИдСтроки);
				
				ДанныеНоменклатуры1С = Новый Структура();
				ДанныеНоменклатуры1С.Вставить("ИдентификаторДокумента",	ИдентификаторДокумента);
				ДанныеНоменклатуры1С.Вставить("Номенклатура",			СтрокаДокумента1С.Номенклатура);
				Если СтрокаДокумента1С.Свойство("Характеристика") Тогда
					ДанныеНоменклатуры1С.Вставить("Характеристика1С",	СтрокаДокумента1С.Характеристика);
					ХарактеристикиИспользуютсяВДокументе = Истина;
				Иначе
					ДанныеНоменклатуры1С.Вставить("Характеристика1С",	"");
				КонецЕсли;
				
				//ДанныеНоменклатуры1С.Вставить("Идентификатор1С", СтрокаДокумента1С.Номенклатура.УникальныйИдентификатор());
				ДанныеНоменклатуры1С.Вставить("Идентификатор1С",	ДанныеНоменклатуры1С.Номенклатура.УникальныйИдентификатор());
				ДанныеНоменклатуры1С.Вставить("ЕдИзм1С",			СтрокаДокумента1С.ЕдИзм);
				ДанныеНоменклатуры1С.Вставить("ОКЕИ_1С",			СтрокаДокумента1С.ТаблДок_ОКЕИ);   
				ДанныеНоменклатуры1С.Вставить("БазоваяЕдиницаОКЕИ", СтрокаДокумента1С.ТаблДок_ОКЕИ);
				
				ДопПараметры = Новый Структура("ИдСтроки, ЗаполнениеНоменклатуры1С, БазоваяЕдиницаОКЕИ", 
				ИдСтроки, Истина, СтрокаДокумента1С.ТаблДок_ОКЕИ);                          
				
				ГолыйКлассНоменклатурыДляСопоставления = МодульОбъектаКлиент().НовыйСтрокаСопоставленияСБИСКлиент(ДанныеНоменклатуры1С, ДопПараметры);
				
				СписокНоменклатурДляОбогащения.Добавить(ГолыйКлассНоменклатурыДляСопоставления);
				
				ИндексВТабЧасти = ИндексВТабЧасти + 1;
			КонецЦикла;
		КонецЦикла;
	КонецЦикла;
	
	ПараметрыДляОбогащения = Новый Структура("Контрагент, Номенклатура, ПоискПо1С", Контрагент, СписокНоменклатурДляОбогащения, Истина);
	
	ЛокальнаяПеременная = Неопределено;
	Если Вложение.Свойство("КлассыСопоставленияНоменклатур", ЛокальнаяПеременная) Тогда
		ОбогащенныеДанныеНоменклатурыДляСопоставления = ЛокальнаяПеременная;
	Иначе  
		
		// Выдать эксепш, что нет классов на вложении (не заполнено сопоставление на вложении)
		Попытка           
			// НеИскать документы помогает обойти ошибку https://project.sbis.ru/opendoc.html?guid=ddfe4bde-cf83-4c4e-a973-ab427e7ba7b7&client=3
			// После исправления ошибки надо убрать
			// Негативный эффект - могут придти сопоставления не нашего документа
			ДопПараметры = Новый Структура("Кэш, НеИскатьПоДокументу", Кэш, Истина);
			ОбогащенныеДанныеНоменклатурыДляСопоставления =	ФормаРаботыСНоменклатурой.НоменклатураПоставщика_МассовыйПоиск(ПараметрыДляОбогащения, ДопПараметры); 
		Исключение
			МодульОбъектаКлиент().СообщитьСбисИсключение(ИнформацияОбОшибке(), "ФормаРаботыСНоменклатурой.НоменклатураПоставщика_МассовыйПоиск");
			Возврат;
		КонецПопытки;
	КонецЕсли;
	
	Если МодульОбъектаКлиент().ПолучитьЗначениеПараметраСбис("РежимОтладки") Тогда
		
		ДанныеЛогирования = Новый Структура;
		ДанныеЛогирования.Вставить("Тип", 			"СопоставлениеНоменклатуры");
		ДанныеЛогирования.Вставить("Идентификатор", МодульОбъектаКлиент().ВложениеСБИС_Получить(Вложение, "Название"));
		ДанныеЛогирования.Вставить("Вызов", 		ОбогащенныеДанныеНоменклатурыДляСопоставления);
		ДанныеЛогирования.Вставить("Модуль", 		"Файл_Шаблон");
		
		МодульОбъектаКлиент().СохранитьОтладочныеДанныеСБИС(ДанныеЛогирования);
	КонецЕсли;
	
	НомерСтрокиТаблДок = 0;
	Для Каждого СтокаСопоставления Из ОбогащенныеДанныеНоменклатурыДляСопоставления Цикл
		НСтрокаТаблицы = ТаблицаСопоставлений.Добавить();
		
		Если Вложение.Свойство("КлассыСопоставленияНоменклатур") Тогда
			ПутьТаблДок = "Файл.Документ.ТаблДок.СтрТабл";
			СтрТабл = Кэш.ОбщиеФункции.РассчитатьЗначениеИзСтруктуры(ПутьТаблДок, Вложение.СтруктураФайла);
			КоличествоВДокументе1С  = Число(СтрТабл[НомерСтрокиТаблДок].Кол_во);
			ЦенаВДокументе1С 	    = Число(СтрТабл[НомерСтрокиТаблДок].Цена);
			НСтрокаТаблицы.ИдСтроки = НомерСтрокиТаблДок;
			НомерСтрокиТаблДок 	    = НомерСтрокиТаблДок + 1;
		Иначе
			МассивИдСтроки = Кэш.ОбщиеФункции.РазбитьСтрокуВМассивНаКлиенте(СтокаСопоставления.ИдСтроки);
			СтрокаДокумента1С = ДокументДанные.мФайл[МассивИдСтроки[0]][МассивИдСтроки[1]][МассивИдСтроки[2]][Число(МассивИдСтроки[3])];
			КоличествоВДокументе1С = Число(СтрокаДокумента1С.ТаблДок_Кол_во);
			ЦенаВДокументе1С	   = СтрокаДокумента1С.Цена;
			НСтрокаТаблицы.ИдСтроки = СтокаСопоставления.ИдСтроки;
		КонецЕсли;	
		
		НСтрокаТаблицы.КоличествоВДокументе1С		= КоличествоВДокументе1С;
		НСтрокаТаблицы.ЦенаВДокументе1С				= ЦенаВДокументе1С;
		
		НСтрокаТаблицы.НоменклатураСБИС				= СтокаСопоставления.НоменклатураСБИС.Наименование;
		НСтрокаТаблицы.GTIN_СБИС					= СтокаСопоставления.НоменклатураСБИС.GTIN;
		НСтрокаТаблицы.КодСБИС						= СтокаСопоставления.НоменклатураСБИС.Код;
		НСтрокаТаблицы.ТипКодаСБИС					= СтокаСопоставления.НоменклатураСБИС.ТипКода;
		НСтрокаТаблицы.НоменклатураСБИСЗначение     = Новый Структура(СтокаСопоставления.НоменклатураСБИС.ТипКода, СтокаСопоставления.НоменклатураСБИС.Код);

		Для Каждого Номенклатура1С Из СтокаСопоставления.Номенклатура1С Цикл
			НСтрокаТаблицы.Номенклатура1С			= Номенклатура1С.Ключ;       
			НСтрокаТаблицы.Коэффициент1СкСБИС       = Номенклатура1С.Значение.Коэффициент;
			Для Каждого Характеристика1С Из Номенклатура1С.Значение.Характеристики Цикл
				НСтрокаТаблицы.Характеристика1С		= Характеристика1С;
				Прервать;
			КонецЦикла;
			Если Номенклатура1С.Значение.Единицы.Количество() Тогда
				Для Каждого Единица1С Из Номенклатура1С.Значение.Единицы Цикл
					НСтрокаТаблицы.Единица1С		= Единица1С.Ключ;
					Коэффициент1С = Число(Единица1С.Значение.Коэффициент);
					НСтрокаТаблицы.Коэффициент1С	= ?(Коэффициент1С = 0, 1, Коэффициент1С);
					Прервать;
				КонецЦикла;
			Иначе
				НСтрокаТаблицы.Коэффициент1С = 1;
			КонецЕсли;
			
			Прервать;
		КонецЦикла;
		
		Если СтокаСопоставления.НоменклатураСБИС.Единицы.Количество() Тогда
			Для Каждого ЕдиницаСБИС Из СтокаСопоставления.НоменклатураСБИС.Единицы Цикл
				//КоэффициентСБИС = Число(ЕдиницаСБИС.Значение.Коэффициент);
				//НСтрокаТаблицы.КоэффициентСБИС			= ?(КоэффициентСБИС = 0, 1, КоэффициентСБИС);
				НСтрокаТаблицы.НаименованиеЕдиницыСБИС	= ЕдиницаСБИС.Значение.Название;
				НСтрокаТаблицы.ОКЕИ_ЕдиницыСБИС			= ЕдиницаСБИС.Значение.ОКЕИ;
				Прервать;
			КонецЦикла;
		Иначе
			НСтрокаТаблицы.КоэффициентСБИС = 1;
		КонецЕсли;
		
		// Оставлено на случай, если понадобится 2 коэффициента
		//Если ЗначениеЗаполнено(НСтрокаТаблицы.Коэффициент1С)
		//		И ЗначениеЗаполнено(НСтрокаТаблицы.КоэффициентСБИС) Тогда
		//	НСтрокаТаблицы.Коэффициент1СкСБИС		= НСтрокаТаблицы.Коэффициент1С / НСтрокаТаблицы.КоэффициентСБИС;
		//Иначе
		//	НСтрокаТаблицы.Коэффициент1СкСБИС		= 1;
		//КонецЕсли;
		
		//НСтрокаТаблицы.Коэффициент1СкСБИС			= НСтрокаТаблицы.Коэффициент1С;
		НСтрокаТаблицы.КоличествоПересчитанное		= НСтрокаТаблицы.КоличествоВДокументе1С / НСтрокаТаблицы.Коэффициент1СкСБИС;
		НСтрокаТаблицы.ЦенаПересчитанная			= НСтрокаТаблицы.ЦенаВДокументе1С * НСтрокаТаблицы.Коэффициент1СкСБИС;
	КонецЦикла;
	
КонецПроцедуры

