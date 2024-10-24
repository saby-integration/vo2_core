&НаКлиенте
Функция ПреобразоватьОтветОнлайна(Ответ, ДопПараметры=Неопределено)
	
	ОтветСписок		= Ответ.Result;
	ОтветНавигация	= Ответ.Navigation;

	Результат = Новый Структура("Навигация, Список", Новый Структура("ЕстьЕще", ОтветНавигация.HasMore), Новый Массив);
	
	ОбогатитьОтветСсылками(ОтветСписок, ДопПараметрыСервер()); 

	//Свернем список по номенклатуре СБИС
	НаборСопоставлений	= Новый Соответствие;

	Для Каждого СопоставлениеОнлайн Из ОтветСписок Цикл
		
		СтрокаСопоставления = НаборСопоставлений.Получить(СопоставлениеОнлайн.ContrCode);
		
		Если СтрокаСопоставления = Неопределено Тогда
			
			МассивСопоставлений = Новый Массив;
			МассивСопоставлений.Добавить(СопоставлениеОнлайн);
			НаборСопоставлений.Вставить(СопоставлениеОнлайн.ContrCode,МассивСопоставлений);
			
		Иначе
			СтрокаСопоставления.Добавить(СопоставлениеОнлайн);
		КонецЕсли;
	КонецЦикла;
	
	// Перепакуем структуру и сгенерируем классы
	Для Каждого СопоставлениеКлючЗначение Из НаборСопоставлений Цикл
		ДанныеЗаполнения				= Новый Структура("НазваниеСБИС, АртикулСБИС, ИдентификаторСБИС, БазоваяЕдиницаОКЕИ, GTIN_СБИС, ЕдИзмСБИС, Номенклатура");
		ДанныеЗаполнения.ЕдИзмСБИС		= Новый Массив;	
		ДанныеЗаполнения.Номенклатура	= Новый Массив;
		ЗаполнитьДанныеСБИС				= Истина;	// заполняем по первому сопоставлению, они должны быть одинаковые
		Для Каждого Сопоставление Из СопоставлениеКлючЗначение.Значение Цикл
			
			Если ЗаполнитьДанныеСБИС Тогда
				
				ДанныеЗаполнения.НазваниеСБИС		= Сопоставление.ContrName;
				ДанныеЗаполнения.БазоваяЕдиницаОКЕИ = Сопоставление.BaseMeasureUnitCode;	
				
				Если Сопоставление.Свойство("CodeType")
						И ЗначениеЗаполнено(Сопоставление.CodeType) Тогда
					ДанныеЗаполнения.Вставить(Сопоставление.CodeType, Сопоставление.ContrCode);
				Иначе
					ДанныеЗаполнения.Вставить("Код", Сопоставление.ContrCode);
				КонецЕсли;
				
				Если Сопоставление.Свойство("ContrGTIN") Тогда
					ДанныеЗаполнения.GTIN_СБИС		= Сопоставление.ContrGTIN;
				КонецЕсли;
				
				
				ЗаполнитьДанныеСБИС = Ложь;
				
			КонецЕсли;
			
			// Единицы СБИС
			Для Каждого ЕдиницаИзмерения ИЗ Сопоставление.ContrMeasureUnit Цикл
				
				ДанныеЗаполненияЕдиницы = Новый Структура("ЕдИзмНаименованиеСБИС, ОКЕИ_СБИС, КоэффициентСБИС");	
				ДанныеЗаполненияЕдиницы.ЕдИзмНаименованиеСБИС	= ЕдиницаИзмерения.ContrMeasureUnitName;
				ДанныеЗаполненияЕдиницы.ОКЕИ_СБИС				= ЕдиницаИзмерения.ContrMeasureUnitCode; 
			//	ДанныеЗаполненияЕдиницы.КоэффициентСБИС			= ЕдиницаИзмерения.ContrMeasureUnitQty;		
				Если Сопоставление.MeasureUnit.Количество() Тогда
					ДанныеЗаполненияЕдиницы.КоэффициентСБИС = Сопоставление.MeasureUnit[0].MeasureUnitQty;
				Иначе
					ДанныеЗаполненияЕдиницы.КоэффициентСБИС = 1;
				КонецЕсли;

				ДанныеЗаполнения.ЕдИзмСБИС.Добавить(ДанныеЗаполненияЕдиницы);
				
			КонецЦикла;
			
			ДанныеЗаполненияНоменклатуры = Новый Структура(); // Нужны еще GTIN_1С, но их у нас нет
			
			ДанныеЗаполненияНоменклатуры.Вставить("Номенклатура",					Сопоставление.Ссылка);
			ДанныеЗаполненияНоменклатуры.Вставить("Идентификатор",					Сопоставление.Id);
			ДанныеЗаполненияНоменклатуры.Вставить("ЕдИзм1С",						Новый Массив);
			ДанныеЗаполненияНоменклатуры.Вставить("Характеристика",					Сопоставление.Характеристика);

			ДанныеЗаполненияНоменклатуры.ЕдИзм1С = ДанныеЗаполненияMeasureUnit(Сопоставление);
			
			ДанныеЗаполнения.Номенклатура.Добавить(ДанныеЗаполненияНоменклатуры);
	
		КонецЦикла;
		
		ДопПараметрыСтрокиСопоставления = Новый Структура("ЗаполнениеНоменклатуры1С", Истина);
		СтрокаСопоставленияСБИС = МодульОбъектаКлиент().НовыйСтрокаСопоставленияСБИСКлиент(ДанныеЗаполнения, ДопПараметрыСтрокиСопоставления);
		Результат.Список.Добавить(СтрокаСопоставленияСБИС);
	КонецЦикла;
	
	Возврат Результат;
		
КонецФункции

&НаСервере
Функция ОбогатитьОтветСсылками(Ответ, ДопПараметры) Экспорт
	
	СчетчикСтрокПоИндексу = 0;
	
	Для СчетчикЦикла = 1 По Ответ.Количество() Цикл
		
		Соответствие = Ответ[СчетчикСтрокПоИндексу];
		
		Соответствие.Вставить("Ссылка", НоменклатураПоКлючуСопоставления(Соответствие.Id, ДопПараметры));
		
		Если Найти(Строка(Соответствие.Ссылка), "<Объект не найден>")
				ИЛИ Найти(Строка(Соответствие.Ссылка), "<Object not found>")
				ИЛИ Не ЗначениеЗаполнено(Соответствие.Ссылка) Тогда
		// Может найтись ссылка из другой конфы 1С или пустая ссылка из-за неправильной записи номенклатуры, тогда ее удаляем из списка
			Ответ.Удалить(СчетчикСтрокПоИндексу);
			Продолжить;
		КонецЕсли;
		
		Если Соответствие.Свойство("IdChar") Тогда
			Соответствие.Вставить("Характеристика", ХарактеристикаПоИдентификатору(Соответствие.IdChar, ДопПараметры));
		Иначе
			Соответствие.Вставить("Характеристика", Неопределено);
		КонецЕсли;
		
		Если	Соответствие.Свойство("MeasureUnit") И ЗначениеЗаполнено(Соответствие.MeasureUnit) Тогда
			
			Для Каждого Единица Из Соответствие.MeasureUnit Цикл
				
				Единица.Вставить("Ссылка");
				Если ЗначениеЗаполнено(Единица.MeasureUnitCode) Тогда
					
					Если 	ЗначениеЗаполнено(ДопПараметры.КлассификаторЕдиницИзмерения) Тогда
						
						// Старый костыльный механизм 
						Единица.Ссылка = МодульОбъектаСервер().ПодобратьЕдиницуИзмеренияПоОКЕИ(Единица.MeasureUnitCode, ДопПараметры.КлассификаторЕдиницИзмерения);
						
					Иначе
						// Не должно сюда попадать. Оставлено для перестраховки.
						// новый механизм, в ини конфигурации должны быть поля ЕдиницыИзмеренияНоменклатуры КлассификаторЕдиницИзмерения
						// и ЕдиницыИзмеренияНоменклатуры_ЕдиницаПоКлассификатору
						
						ПараметрыЕдиницы = Новый Структура;
						ПараметрыЕдиницы.Вставить("ОКЕИ",			Единица.MeasureUnitCode);
						ПараметрыЕдиницы.Вставить("Наименование",	Единица.MeasureUnitName); 
						ПараметрыЕдиницы.Вставить("Номенклатура",	Соответствие.Ссылка);
						
						Единица.Ссылка = ПодобратьЕдиницуИзмерения(ПараметрыЕдиницы, ДопПараметры);
						
					КонецЕсли;
					
				КонецЕсли;
				
			КонецЦикла;
			
		КонецЕсли;
		
		СчетчикСтрокПоИндексу = СчетчикСтрокПоИндексу + 1;
		
	КонецЦикла;
	
КонецФункции

&НаСервере
Функция ПодобратьЕдиницуИзмерения(ПараметрыЕдиницы, ДопПараметры)
    Перем ПодобраннаяЕдиница;
	
	Если ДопПараметры.ЕдиницыИзмеренияНоменклатуры = "УпаковкиЕдиницыИзмерения" Тогда // УТ 11, КА, ЕРП
			
		Запрос = Новый Запрос;
		Запрос.Текст = 
			"ВЫБРАТЬ РАЗРЕШЕННЫЕ
			|	ВЫБОР
			|		КОГДА Номенклатура.НаборУпаковок = ЗНАЧЕНИЕ(Справочник.НаборыУпаковок.ИндивидуальныйДляНоменклатуры)
			|			ТОГДА Номенклатура.Ссылка
			|		ИНАЧЕ Номенклатура.НаборУпаковок
			|	КОНЕЦ КАК ВладелецУпаковки
			|ПОМЕСТИТЬ ВтВладелецУпаковки
			|ИЗ
			|	Справочник.Номенклатура КАК Номенклатура
			|ГДЕ
			|	Номенклатура.Ссылка = &Номенклатура
			|	И Номенклатура.ИспользоватьУпаковки
			|;
			|
			|////////////////////////////////////////////////////////////////////////////////
			|ВЫБРАТЬ РАЗРЕШЕННЫЕ
			|	УпаковкиЕдиницыИзмерения.Ссылка КАК ЕдиницаИзмерения
			|ИЗ
			|	Справочник.УпаковкиЕдиницыИзмерения КАК УпаковкиЕдиницыИзмерения
			|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ ВтВладелецУпаковки КАК ВтВладелецУпаковки
			|		ПО УпаковкиЕдиницыИзмерения.Владелец = ВтВладелецУпаковки.ВладелецУпаковки
			|ГДЕ
			|	НЕ УпаковкиЕдиницыИзмерения.ПометкаУдаления
			|	И УпаковкиЕдиницыИзмерения.ЕдиницаИзмерения.Код = &ОКЕИ
			|	И УпаковкиЕдиницыИзмерения.Наименование = &Наименование
			|
			|ОБЪЕДИНИТЬ ВСЕ
			|
			|ВЫБРАТЬ
			|	Номенклатура.ЕдиницаИзмерения
			|ИЗ
			|	Справочник.Номенклатура КАК Номенклатура
			|ГДЕ
			|	НЕ Номенклатура.ИспользоватьУпаковки
			|	И Номенклатура.ЕдиницаИзмерения.Код = &ОКЕИ
			|	И Номенклатура.Ссылка = &Номенклатура";
		
		Запрос.УстановитьПараметр("Наименование", 	ПараметрыЕдиницы.Наименование);
		Запрос.УстановитьПараметр("ОКЕИ", 			ПараметрыЕдиницы.ОКЕИ);
		Запрос.УстановитьПараметр("Номенклатура",	ПараметрыЕдиницы.Номенклатура);
	
		
		РезультатЗапроса = Запрос.Выполнить();
		
		ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
		
		Если ВыборкаДетальныеЗаписи.Следующий() Тогда
			ПодобраннаяЕдиница = ВыборкаДетальныеЗаписи.ЕдиницаИзмерения;
		КонецЕсли;
		
	ИначеЕсли НЕ ЗначениеЗаполнено(ДопПараметры.ЕдиницыИзмеренияНоменклатуры) Тогда // Поиск по классификатору 
		
		ПодобраннаяЕдиница = Справочники[ДопПараметры.КлассификаторЕдиницИзмерения].НайтиПоКоду(ПараметрыЕдиницы.ОКЕИ);	
		
	ИначеЕсли ЗначениеЗаполнено(ДопПараметры.ЕдиницыИзмеренияНоменклатуры)
								И ЗначениеЗаполнено(ДопПараметры.ЕдиницыИзмеренияНоменклатуры_ЕдиницаПоКлассификатору) Тогда
		
		ЕдиницаПоКлассификатору = Справочники[ДопПараметры.КлассификаторЕдиницИзмерения].НайтиПоКоду(ПараметрыЕдиницы.ОКЕИ);
		
		Запрос = Новый Запрос;
		Запрос.Текст = 
			"ВЫБРАТЬ ПЕРВЫЕ 1
			|	ЕдиницыИзмерения.Ссылка
			|ИЗ
			|	Справочник."+ДопПараметры.ЕдиницыИзмеренияНоменклатуры+" КАК ЕдиницыИзмерения
			|ГДЕ
			|	ЕдиницыИзмерения.Владелец = &Владелец
			|	И ЕдиницыИзмерения."+ДопПараметры.ЕдиницыИзмеренияНоменклатуры_ЕдиницаПоКлассификатору+" = &ЕдиницаКлассификатора
			|	И НЕ ЕдиницыИзмерения.ПометкаУдаления";
		
		
		Запрос.УстановитьПараметр("Владелец", ДопПараметры.Номенклатура);
		Запрос.УстановитьПараметр("ЕдиницаКлассификатора", ЕдиницаПоКлассификатору);
		
		РезультатЗапроса 		= Запрос.Выполнить();		
		ВыборкаДетальныеЗаписи	= РезультатЗапроса.Выбрать();
		
		Если ВыборкаДетальныеЗаписи.Следующий() Тогда
			Результат = ВыборкаДетальныеЗаписи.Ссылка; 
		КонецЕсли;

		
	КонецЕсли;
		
	Возврат ПодобраннаяЕдиница;	
		
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
	
	ДопПараметры.РеквизитСопоставленияНоменклатуры = "Идентификатор"; // Для тестов, в релиз удалить 
	
	Если ДопПараметры.РеквизитСопоставленияНоменклатуры = "Идентификатор" Тогда
		Возврат Строка(НоменклатураСсылка.УникальныйИдентификатор());
	Иначе
		Возврат НоменклатураСсылка[ДопПараметры.РеквизитСопоставленияНоменклатуры];
	КонецЕсли;
	
КонецФункции 

&НаСервереБезКонтекста
Функция НоменклатураПоКлючуСопоставления(Ключ, ДопПараметры)
	
	ДопПараметры.РеквизитСопоставленияНоменклатуры = "Идентификатор"; // Для тестов, в релиз удалить
	
	// Ключ				= КлючИзКлючаОнлайна(Ключ); 
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

&НаСервереБезКонтекста
Функция ХарактеристикаПоИдентификатору(ИдХарактеристики, ДопПараметры)
	
	Если Не ЗначениеЗаполнено(ИдХарактеристики) Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	Попытка
		СправочникМенеджер	= Справочники.ХарактеристикиНоменклатуры;
		Возврат СправочникМенеджер.ПолучитьСсылку(Новый УникальныйИдентификатор(ИдХарактеристики));
	Исключение
		// Ошибка, которая не должна возникать
		Возврат Неопределено;
	КонецПопытки;
	
КонецФункции

// Получает из кэша необходимые параметры для передачи в серверные вызовы
&НаКлиенте
Функция ДопПараметрыСервер()
	
    ИниКонфигурации = ВладелецФормы.Кэш.ини.Конфигурация; 	
	ДопПараметры	= Новый Структура("КлассификаторЕдиницИзмерения, ЕдиницыИзмеренияНоменклатуры, ЕдиницыИзмеренияНоменклатуры_ЕдиницаПоКлассификатору,
									|РеквизитСопоставленияНоменклатуры, ТипНоменклатуры");
	ТипыПолей1С = МодульОбъектаКлиент().ПолучитьЗначениеПараметраТекущегоСеанса("ТипыПолей1С");
	
	Если ВладелецФормы.Кэш.ини.Конфигурация.Свойство("Номенклатура") Тогда
		ДопПараметры.ТипНоменклатуры = ВладелецФормы.Кэш.ини.Конфигурация.Номенклатура.Значение;
	Иначе
		ДопПараметры.ТипНоменклатуры = "Справочник.Номенклатура";
	КонецЕсли;
	
	ТипыКлассификаторЕдИзм = ТипыПолей1С.КлассификаторЕдиницИзмерения.ТипыМассивСтрок;
	Если ЗначениеЗаполнено(ТипыКлассификаторЕдИзм) Тогда
		ДопПараметры.КлассификаторЕдиницИзмерения = Сред(ТипыКлассификаторЕдИзм[0], Найти(ТипыКлассификаторЕдИзм[0], ".") + 1)
	КонецЕсли;
	
	Если ВладелецФормы.Кэш.ини.Конфигурация.Свойство("ЕдиницыИзмеренияНоменклатуры") Тогда
		ДопПараметры.ЕдиницыИзмеренияНоменклатуры = СтрЗаменить(ИниКонфигурации.ЕдиницыИзмеренияНоменклатуры.Значение,"'","");
	КонецЕсли;
	
	Если ВладелецФормы.Кэш.ини.Конфигурация.Свойство("ЕдиницыИзмеренияНоменклатуры_ЕдиницаПоКлассификатору") Тогда
		ДопПараметры.ЕдиницыИзмеренияНоменклатуры_ЕдиницаПоКлассификатору = СтрЗаменить(ИниКонфигурации.ЕдиницыИзмеренияНоменклатуры_ЕдиницаПоКлассификатору.Значение,"'","");
	КонецЕсли;

	// ДопПараметры.РеквизитСопоставленияНоменклатуры = ВладелецФормы.Кэш.Парам.РеквизитСопоставленияНоменклатуры;
	
	Возврат ДопПараметры;
	
КонецФункции

// Функция - Возвращает соответсвие ИД характеристик по массиву соответствий. Для уменьшения серверных вызовов
//
// Параметры:
//  Сопоставления	 - Массив сопоставлений 
// 
// Возвращаемое значение:
//   -  Соответствие Характеристика(ссылка) Ключ, ИД значение
//
&НаСервереБезКонтекста
Функция ИдХарактеристикСопоставлений(Сопоставления)
	
	Характеристики = Новый Соответствие;
	
	Для Каждого КлассСопоставления Из Сопоставления Цикл
				
		Для Каждого Номенклатура Из КлассСопоставления.Номенклатура1С Цикл
			
			Если ЗначениеЗаполнено(Номенклатура.Значение.Характеристики) Тогда
				Для Каждого Характеристика Из Номенклатура.Значение.Характеристики Цикл			
					Если ЗначениеЗаполнено(Характеристика) Тогда // может прийти пустая характеристика
						Характеристики.Вставить(Характеристика, Характеристика.УникальныйИдентификатор());
					КонецЕсли;
				КонецЦикла;
			КонецЕсли;
			
		КонецЦикла;
		
	КонецЦикла;
	
	Возврат Характеристики;
	
КонецФункции



