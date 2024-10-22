
// Функция - создаёт строку сопоставления единицы
//
// Параметры:
//  ИдСБИС	 - 	 - 
//  ИмяСБИС	 - 	 - 
// 
// Возвращаемое значение:
//   - 
//
Функция НовыйСопоставлениеДляЕдиницыСервер(ВходящиеДанные = Неопределено, ДопПараметры = Неопределено) Экспорт
	
	ГолыйКласс = Новый Структура("_класс, Коэффициент, ОКЕИ, Название, Ссылка, Владелец", "СопоставлениеДляЕдиницы", "1", "", "", "", "", "");
	
	Если ВходящиеДанные = Неопределено Тогда
		Возврат ГолыйКласс;
	КонецЕсли;
	
	СопоставлениеДляЕдиницыСервер_Заполнить(ГолыйКласс, ВходящиеДанные.Источник, ДопПараметры);
	
	Возврат ГолыйКласс;
	
КонецФункции

Функция СопоставлениеДляЕдиницыСервер_Ключ(СопоставлениеДляЕдиницы) Экспорт
	
	Если ЗначениеЗаполнено(СопоставлениеДляЕдиницы.Ссылка) Тогда
		Возврат СопоставлениеДляЕдиницы.Ссылка;
	ИначеЕсли ЗначениеЗаполнено(СопоставлениеДляЕдиницы.ОКЕИ) Тогда
		Возврат СопоставлениеДляЕдиницы.ОКЕИ + "_" + СопоставлениеДляЕдиницы.Название;
	Иначе
		Возврат СопоставлениеДляЕдиницы.Название;
	КонецЕсли
		
КонецФункции

Функция СопоставлениеДляЕдиницыСервер_Получить(СопоставлениеДляЕдиницы, КлючПоиска) Экспорт
	
	Если КлючПоиска = "Владелец" Тогда
		Если ЗначениеЗаполнено(СопоставлениеДляЕдиницы.Владелец) Тогда
			// Ничего не делаем, владелец уже заполнен
		ИначеЕсли ЗначениеЗаполнено(СопоставлениеДляЕдиницы.Ссылка) Тогда
			// Если ссылка есть, то владелец не должен быть пустым. Прочерк, если в принципе нет.
			Попытка
				// Пока через Try, переделать на параметр от ини конфигурации
				СопоставлениеДляЕдиницы.Владелец = СопоставлениеДляЕдиницы.Ссылка.Владелец;
			Исключение
			КонецПопытки;
			Если Не ЗначениеЗаполнено(СопоставлениеДляЕдиницы.Владелец)
					Или Не ЭтоСсылкаНаСправочникНоменклатуры(СопоставлениеДляЕдиницы.Владелец) Тогда
						// TODO Добавить передачу вида справочника номенклатуры вторым параметром
				// Не удалось установить владельца. Вроде не должно быть ошибкой
				СопоставлениеДляЕдиницы.Владелец = "-";
			КонецЕсли;
		Иначе
			СопоставлениеДляЕдиницы.Владелец = "";
		КонецЕсли;
		Возврат СопоставлениеДляЕдиницы.Владелец;
	ИначеЕсли КлючПоиска = "Единица" Тогда
		Попытка  
			ВыбраннаяНоменклатураОбъект = СопоставлениеДляЕдиницы.Владелец.ПолучитьОбъект();
			ИмяРеквизита = "ЕдиницыИзмерения";
			СопоставлениеДляЕдиницы.Единица = ВыбраннаяНоменклатураОбъект[ИмяРеквизита];
		Исключение
			Возврат Неопределено;
		КонецПопытки;
	Иначе
		
		// Словили неожиданный ключ? Хреново, но ситуация исключительная, пока не обрабатываем
		Попытка
			Возврат СопоставлениеДляЕдиницы[КлючПоиска]; 
		Исключение 
			Возврат Неопределено;
		КонецПопытки;

	КонецЕсли;
	
	Возврат СопоставлениеДляЕдиницы[КлючПоиска];
	
КонецФункции

Процедура СопоставлениеДляЕдиницыСервер_Вставить(СопоставлениеДляЕдиницы, КлючВставить, ЗначениеВставить) Экспорт
	
	Перем КлючДобавитьВДанные, ЗначениеЗаполнить;
	
	Если		КлючВставить = "Ссылка" Тогда
		Если ЗначениеЗаполнено(ЗначениеВставить) Тогда
			
			СопоставлениеДляЕдиницы.Ссылка = ЗначениеВставить;
			
			// Если ссылка есть, то владелец не должен быть пустым. Прочерк, если в принципе нет.
			Попытка
				СопоставлениеДляЕдиницы.Владелец = ЗначениеВставить.Владелец;
			Исключение
			КонецПопытки;
			Если НЕ ЗначениеЗаполнено(СопоставлениеДляЕдиницы.Владелец)
					Или Не ЭтоСсылкаНаСправочникНоменклатуры(СопоставлениеДляЕдиницы.Владелец) Тогда 
						// TODO Добавить передачу вида справочника номенклатуры вторым параметром
				// Не удалось установить владельца. Вроде не должно быть ошибкой
				СопоставлениеДляЕдиницы.Владелец = "-";
			КонецЕсли;
			
		Иначе
			
			СопоставлениеДляЕдиницы.Владелец = "";
			
		КонецЕсли;
	ИначеЕсли	КлючВставить = "Название" Тогда
		
		Если ЗначениеЗаполнено(ЗначениеВставить) Тогда
			СопоставлениеДляЕдиницы.Название = ЗначениеВставить;
		Иначе
			СопоставлениеДляЕдиницы.Название = Строка(СопоставлениеДляЕдиницы.Ссылка);
		КонецЕсли;
		
	ИначеЕсли	КлючВставить = "Коэффициент" Тогда
		
		Если ЗначениеЗаполнено(ЗначениеВставить) Тогда
			СопоставлениеДляЕдиницы[КлючВставить] = ЗначениеВставить;
		Иначе
			СопоставлениеДляЕдиницы[КлючВставить] = "1";
		КонецЕсли;
		
	ИначеЕсли	СопоставлениеДляЕдиницы.Свойство(КлючВставить) Тогда
		
		СопоставлениеДляЕдиницы[КлючВставить] = ЗначениеВставить;
		
	КонецЕсли;

КонецПроцедуры

Процедура СопоставлениеДляЕдиницыСервер_Заполнить(СопоставлениеДляЕдиницы, Источник, ДопПараметры) Экспорт
	
	Перем ТипИсточника, Владелец;
	
	Если Не ДопПараметры = Неопределено Тогда
		Если Не ДопПараметры.Свойство("ТипИсточника", ТипИсточника) Тогда
			ТипИсточника = Новый Структура;
		КонецЕсли;
		ДопПараметры.Свойство("Владелец", Владелец);
	КонецЕсли;
	
	Если ТипИсточника = "Ссылка" Тогда
		
		СопоставлениеДляЕдиницы.Вставить("ОКЕИ", Источник.Код);
		СопоставлениеДляЕдиницы.Вставить("Название", Источник.Наименование);
		СопоставлениеДляЕдиницы.Вставить("Ссылка", Источник);
		
		Если Не ЗначениеЗаполнено(Владелец) Тогда
			Владелец = Источник.Владелец;
		КонецЕсли;
		
		СопоставлениеДляЕдиницы.Вставить("Владелец", Владелец);
	Иначе
		ЗаполнитьЗначенияСвойств(СопоставлениеДляЕдиницы, Источник);
	КонецЕсли;
	
КонецПроцедуры

Процедура СопоставлениеДляЕдиницыСервер_Заполнить1С(СтрокаСопоставления1С, СопоставлениеЗаполнить) Экспорт
	
	Перем СЛокальнаяПеременная;
	
	Если		СопоставлениеЗаполнить.Свойство("ЕдИзмОрг", СЛокальнаяПеременная) Тогда
		// Наименование единицы измерения в старом формате
	ИначеЕсли	СопоставлениеЗаполнить.Свойство("ЕдИзм1С", СЛокальнаяПеременная) Тогда
		// Наименование единицы измерения в новом формате
	КонецЕсли;
	
	Если	ЗначениеЗаполнено(СЛокальнаяПеременная)
		И	СтрокаСопоставления1С.Единицы.Получить(СЛокальнаяПеременная) = Неопределено Тогда
		ЕдиницаСопоставление = НовыйСопоставлениеДляЕдиницыСервер();
		СопоставлениеДляЕдиницыСервер_Вставить(ЕдиницаСопоставление, "Ссылка", СЛокальнаяПеременная);
	Иначе
		Возврат;
	КонецЕсли;
	
	СопоставлениеДляЕдиницыСервер_Вставить(ЕдиницаСопоставление, "Владелец", СопоставлениеЗаполнить.Ссылка); // Владелец у единицы должен быть заполнен всегда
	
	Если	СопоставлениеЗаполнить.Свойство("ОКЕИ_1С", СЛокальнаяПеременная)
		И	ЗначениеЗаполнено(СЛокальнаяПеременная) Тогда
		СопоставлениеДляЕдиницыСервер_Вставить(ЕдиницаСопоставление, "ОКЕИ", СЛокальнаяПеременная);
	КонецЕсли;
	
	Если		СопоставлениеЗаполнить.Свойство("Коэффициент",	СЛокальнаяПеременная) Тогда
		// Коэффициент в старом формате
	ИначеЕсли	СопоставлениеЗаполнить.Свойство("Коэффициент1С",	СЛокальнаяПеременная) Тогда
		// Коэффициент в новом формате
	КонецЕсли;
	Если ЗначениеЗаполнено(СЛокальнаяПеременная) Тогда
		СопоставлениеДляЕдиницыСервер_Вставить(ЕдиницаСопоставление, "Коэффициент", СЛокальнаяПеременная);
	КонецЕсли;
	
	Если	СопоставлениеЗаполнить.Свойство("ЕдИзмНаименование1С",	СЛокальнаяПеременная)
		И	ЗначениеЗаполнено(СЛокальнаяПеременная) Тогда
		СопоставлениеДляЕдиницыСервер_Вставить(ЕдиницаСопоставление, "Название", СЛокальнаяПеременная);
	Иначе
		СопоставлениеДляЕдиницыСервер_Вставить(ЕдиницаСопоставление, "Название", Строка(ЕдиницаСопоставление.Ссылка));
	КонецЕсли;
	
	ОписаниеНоменклатуры1ССервер_Вставить(СтрокаСопоставления1С, "Единица", ЕдиницаСопоставление);
	
КонецПроцедуры

Процедура СопоставлениеДляЕдиницыСервер_ЗаполнитьСБИС(СтрокаСопоставленияСБИС, СопоставлениеЗаполнить) Экспорт
	
	Перем СЛокальнаяПеременная;
	
	ЕдиницаСопоставление = НовыйСопоставлениеДляЕдиницыСервер();
	
	Если		СопоставлениеЗаполнить.Свойство("ЕдИзмОКЕИ", СЛокальнаяПеременная) Тогда 
		// ОКЕИ в старом формате вариант 1	
	ИначеЕсли	СопоставлениеЗаполнить.Свойство("ОКЕИ", СЛокальнаяПеременная) Тогда
		// ОКЕИ в старом формате вариант 2
	ИначеЕсли	СопоставлениеЗаполнить.Свойство("ЕдИзмОКЕИ_СБИС", СЛокальнаяПеременная) Тогда
		// ОКЕИ в новом формате вариант 1
	ИначеЕсли	СопоставлениеЗаполнить.Свойство("ОКЕИ_СБИС", СЛокальнаяПеременная) Тогда
		// ОКЕИ в новом формате вариант 2
	КонецЕсли;
	Если ЗначениеЗаполнено(СЛокальнаяПеременная) Тогда
		СопоставлениеДляЕдиницыСервер_Вставить(ЕдиницаСопоставление, "ОКЕИ", СЛокальнаяПеременная);
	КонецЕсли;
	
	Если		СопоставлениеЗаполнить.Свойство("ЕдИзмНаименование",	СЛокальнаяПеременная) Тогда
		// Наименование единицы измерения в старом формате вариант 1
	ИначеЕсли 	СопоставлениеЗаполнить.Свойство("ЕдИзм",				СЛокальнаяПеременная) Тогда
		// Наименование единицы измерения в старом формате вариант 2
	ИначеЕсли	СопоставлениеЗаполнить.Свойство("ЕдИзмНаименованиеСБИС",СЛокальнаяПеременная) Тогда
		// Наименование единицы измерения в новом формате
	КонецЕсли;	
	Если ЗначениеЗаполнено(СЛокальнаяПеременная) Тогда
		СопоставлениеДляЕдиницыСервер_Вставить(ЕдиницаСопоставление, "Название", СЛокальнаяПеременная);
	КонецЕсли;

	Если Не ЗначениеЗаполнено(ЕдиницаСопоставление.ОКЕИ) И Не ЗначениеЗаполнено(ЕдиницаСопоставление.Название) Тогда
		Возврат;	
	КонецЕсли;
	
	Если СопоставлениеЗаполнить.Свойство("КоэффициентСБИС",	СЛокальнаяПеременная) Тогда
		// Коэффициент в новом формате
	КонецЕсли;
	Если ЗначениеЗаполнено(СЛокальнаяПеременная) Тогда
		СопоставлениеДляЕдиницыСервер_Вставить(ЕдиницаСопоставление, "Коэффициент", СЛокальнаяПеременная);
	КонецЕсли;
	
	СтрокаСопоставленияСБИССервер_Вставить(СтрокаСопоставленияСБИС, "Единица", ЕдиницаСопоставление);
	
КонецПроцедуры

