&НаКлиенте
Функция ПреобразоватьОтветОнлайна(Ответ, ДопПараметры=Неопределено)
	
	ОбогатитьОтветСсылками(Ответ, ДопПараметрыСервер()); 
	
	//Свернем список по номенклатуре СБИС
	Результат			= Новый Массив;
	НаборСопоставлений	= Новый Соответствие;

	
	Для Каждого СопоставлениеОнлайн Из Ответ Цикл
		
		СтрокаСопоставления = НаборСопоставлений.Получить(СопоставлениеОнлайн.ContrCode);
		
		Если СтрокаСопоставления = Неопределено Тогда
			
			МассивСопоставлений = Новый Массив;
			МассивСопоставлений.Добавить(СопоставлениеОнлайн);
			НаборСопоставлений.Вставить(СопоставлениеОнлайн.ContrCode,МассивСопоставлений);
			
		Иначе
			СтрокаСопоставления.Добавить(СопоставлениеОнлайн);
		КонецЕсли;
	КонецЦикла;
	
	//Перепакуем структуру и сгенерируем классы
	Для Каждого СопоставлениеКлючЗначение Из НаборСопоставлений Цикл
		ДанныеЗаполнения				= Новый Структура("НазваниеСБИС, КодСБИС,АртикулСБИС, ИдентификаторСБИС, БазоваяЕдиницаОКЕИ, GTIN_СБИС, ЕдИзмСБИС, Номенклатура");
		ДанныеЗаполнения.ЕдИзмСБИС		= Новый Массив;	
		ДанныеЗаполнения.Номенклатура	= Новый Массив;
		ЗаполнитьДанныеСБИС				= Истина;	//заполняем по первому сопоставлению, они должны быть одинаковые
		Для Каждого Сопоставление Из СопоставлениеКлючЗначение.Значение Цикл
			
			Если ЗаполнитьДанныеСБИС Тогда
				
				ДанныеЗаполнения.НазваниеСБИС		= Сопоставление.ContrName;
				ДанныеЗаполнения.КодСБИС			= Сопоставление.ContrCode;
				ДанныеЗаполнения.БазоваяЕдиницаОКЕИ = Сопоставление.BaseMeasureUnitCode;	
				Если Сопоставление.Свойство("ContrGTIN") Тогда
					ДанныеЗаполнения.GTIN_СБИС		= Сопоставление.ContrGTIN;
				КонецЕсли;
				ЗаполнитьДанныеСБИС = Ложь;
				
			КонецЕсли;
			
			//Единицы СБИС
			Для Каждого ЕдиницаИзмерения ИЗ Сопоставление.ContrMeasureUnit Цикл
				
				ДанныеЗаполненияЕдиницы = Новый Структура("ЕдИзмНаименованиеСБИС, ОКЕИ_СБИС, КоэффициентСБИС");	
				ДанныеЗаполненияЕдиницы.ЕдИзмНаименованиеСБИС	= ЕдиницаИзмерения.ContrMeasureUnitName;
				ДанныеЗаполненияЕдиницы.ОКЕИ_СБИС				= ЕдиницаИзмерения.ContrMeasureUnitCode; 
				ДанныеЗаполненияЕдиницы.КоэффициентСБИС			= ЕдиницаИзмерения.ContrMeasureUnitQty;		
				ДанныеЗаполнения.ЕдИзмСБИС.Добавить(ДанныеЗаполненияЕдиницы);
				
			КонецЦикла;
			
			ДанныеЗаполненияНоменклатуры = Новый Структура("Номенклатура, Идентификатор, ЕдИзм1С",Сопоставление.Ссылка, Сопоставление.Id, Новый Массив); //Нужны еще GTIN_1С и Характеристика1С, но их у нас нет
						
			ДанныеЗаполненияНоменклатуры.ЕдИзм1С = ДанныеЗаполненияMeasureUnit(Сопоставление);
			
			ДанныеЗаполнения.Номенклатура.Добавить(ДанныеЗаполненияНоменклатуры);
	
		КонецЦикла;
		
		СтрокаСопоставленияСБИС = МодульОбъектаКлиент().НовыйСтрокаСопоставленияСБИСКлиент(ДанныеЗаполнения);
		Результат.Добавить(СтрокаСопоставленияСБИС);
	КонецЦикла;
	
	Возврат Результат;
		
КонецФункции

&НаСервере
Функция ОбогатитьОтветСсылками(Ответ, ДопПараметры) Экспорт

	МодульОбъектаСервер = МодульОбъектаСервер();
	Для Каждого Соответствие Из Ответ Цикл

		Соответствие.Вставить("Ссылка",НоменклатураПоКлючуСопоставления(Соответствие.Id,ДопПараметры));
		Если	Соответствие.Свойство("MeasureUnit") И ЗначениеЗаполнено(Соответствие.MeasureUnit) Тогда

			Для Каждого Единица Из Соответствие.MeasureUnit Цикл

				Единица.Вставить("Ссылка");
				Если ЗначениеЗаполнено(Единица.MeasureUnitCode) Тогда
					Единица.Ссылка = МодульОбъектаСервер.ПодобратьЕдиницуИзмеренияПоОКЕИ(Единица.MeasureUnitCode, Соответствие.Ссылка);
				КонецЕсли;
								
			КонецЦикла;			
		КонецЕсли;
			
	КонецЦикла;
	
КонецФункции

&НаКлиентеНаСервереБезКонтекста
Функция КлючИзКлючаОнлайна(Ключ)
	Возврат СтрПолучитьСтроку(СтрЗаменить(Ключ,"##",Символы.ПС),1);
КонецФункции

&НаКлиентеНаСервереБезКонтекста
Функция КлючКонтрагентаСопоставления(СтруктураКонтрагент)
	Перем СвЮлФл, КлючДляСопоставления;
	Если СтруктураКонтрагент = Неопределено Тогда
		ВызватьИсключение("Неопределен контрагент. Сопоставление номенклатуры невозможно.");
	ИначеЕсли	Не	СтруктураКонтрагент.Свойство("СвЮЛ", СвЮлФл)
		И	Не	СтруктураКонтрагент.Свойство("СвФЛ", СвЮлФл) Тогда
		ВызватьИсключение("Нет сведений о контрагенте. Сопоставление номенклатуры невозможно.");
	ИначеЕсли	Не СвЮлФл.Свойство("ИНН", КлючДляСопоставления)
		Или	Не ЗначениеЗаполнено(КлючДляСопоставления) Тогда
		ВызватьИсключение("Не заполнен ИНН контрагента. Сопоставление номенклатуры невозможно.");
	КонецЕсли;
	Возврат КлючДляСопоставления;
КонецФункции

&НаСервереБезКонтекста
Функция КлючЕдиницыСопоставления(Ссылка) Экспорт
	 Возврат Строка(Ссылка.УникальныйИдентификатор())
КонецФункции

&НаСервереБезКонтекста
Функция КлючНоменклатурыСопоставления(НоменклатураСсылка, ДопПараметры) Экспорт
	
	ДопПараметры.РеквизитСопоставленияНоменклатуры = "Идентификатор"; //Для тестов, в релиз удалить 
	
	Если ДопПараметры.РеквизитСопоставленияНоменклатуры = "Идентификатор" Тогда
		Возврат Строка(НоменклатураСсылка.УникальныйИдентификатор());
	Иначе
		Возврат НоменклатураСсылка[ДопПараметры.РеквизитСопоставленияНоменклатуры];
	КонецЕсли;
	
КонецФункции 

&НаСервереБезКонтекста
Функция НоменклатураПоКлючуСопоставления(Ключ, ДопПараметры)
	
	ДопПараметры.РеквизитСопоставленияНоменклатуры = "Идентификатор"; //Для тестов, в релиз удалить
	
	//Ключ				= КлючИзКлючаОнлайна(Ключ); 
	СправочникМенеджер	= Справочники[СтрЗаменить(ДопПараметры.ТипНоменклатуры,"Справочник.","")];
	
	Если ДопПараметры.РеквизитСопоставленияНоменклатуры = "Идентификатор" Тогда
		Попытка
			Возврат СправочникМенеджер.ПолучитьСсылку(Новый УникальныйИдентификатор(Ключ));
		Исключение
			Возврат СправочникМенеджер.ПустаяСсылка();
		КонецПопытки;
	Иначе
		Возврат СправочникМенеджер.НайтиПоРеквизиту(ДопПараметры.РеквизитСопоставленияНоменклатуры, Ключ);
	КонецЕсли;
	
КонецФункции

//Получает из кэша необходимые параметры для передачи в серверные вызовы
&НаКлиенте
Функция ДопПараметрыСервер()
	
	ДопПараметры = Новый Структура("РеквизитСопоставленияНоменклатуры, ТипЕдиницыИзмерения, ТипНоменклатуры");
	
	Если ВладелецФормы.Кэш.ини.Конфигурация.Свойство("ЕдиницаИзмерения") Тогда
		ДопПараметры.ТипЕдиницыИзмерения = ВладелецФормы.Кэш.ини.Конфигурация.ЕдиницаИзмерения.Значение;
	КонецЕсли;
	
	Если ВладелецФормы.Кэш.ини.Конфигурация.Свойство("Номенклатура") Тогда
		ДопПараметры.ТипНоменклатуры = ВладелецФормы.Кэш.ини.Конфигурация.Номенклатура.Значение;
	Иначе
		ДопПараметры.ТипНоменклатуры = "Справочник.Номенклатура";
	КонецЕсли;
	
	//ДопПараметры.РеквизитСопоставленияНоменклатуры = ВладелецФормы.Кэш.Парам.РеквизитСопоставленияНоменклатуры;
	
	Возврат ДопПараметры;
	
КонецФункции

