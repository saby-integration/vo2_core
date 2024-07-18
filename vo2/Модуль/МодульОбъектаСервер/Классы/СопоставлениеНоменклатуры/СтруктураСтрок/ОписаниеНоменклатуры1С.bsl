
// Функция - создаёт строку сопоставления номенклатуры
//
// Параметры:
//  ИдСБИС	 - 	 - 
//  ИмяСБИС	 - 	 - 
// 
// Возвращаемое значение:
//   - 
//
Функция НовыйОписаниеНоменклатуры1ССервер() Экспорт
	
	Возврат Новый Структура("_класс, Характеристики, Идентификатор, GTIN, Единицы, Основное", "ОписаниеНоменклатуры1С", Новый Массив, "", "", Новый Соответствие, Истина);

КонецФункции

Процедура ОписаниеНоменклатуры1ССервер_Заполнить(СтрокаСопоставленияСБИС, СопоставлениеЗаполнить) Экспорт
	
	Перем СЛокальнаяПеременная;
	
	НоменклатураСсылка	= СопоставлениеЗаполнить.Номенклатура;
	
	СтрНоменклатура = СтрокаСопоставленияСБИС.Номенклатура1С.Получить(НоменклатураСсылка);
	Если СтрНоменклатура = Неопределено Тогда
		СтрНоменклатура = НовыйОписаниеНоменклатуры1ССервер();
	КонецЕсли;
	
	
	// Признак основной номенклатуры для сопоставления
	Если НЕ СтрНоменклатура.Основное Тогда
		Если Не СопоставлениеЗаполнить.Свойство("Основное", СЛокальнаяПеременная) Тогда
			СЛокальнаяПеременная = Ложь;
		КонецЕсли;
		СтрНоменклатура.Основное = СЛокальнаяПеременная;
	КонецЕсли;
	
	
	// GTIN
	Если НЕ ЗначениеЗаполнено(СтрНоменклатура.GTIN) Тогда
		Если Не СопоставлениеЗаполнить.Свойство("GTIN_1С", СЛокальнаяПеременная) Тогда
			СЛокальнаяПеременная = "";
		КонецЕсли;
		СтрНоменклатура.GTIN = СокрЛП(СЛокальнаяПеременная);
	КонецЕсли;
	
	
	// Идентификатор номенклатуры 1С
	Если НЕ ЗначениеЗаполнено(СтрНоменклатура.Идентификатор) Тогда
		Если Не СопоставлениеЗаполнить.Свойство("Идентификатор1С", СЛокальнаяПеременная) Тогда
			СЛокальнаяПеременная = Строка(НоменклатураСсылка.УникальныйИдентификатор());
		КонецЕсли;
		СтрНоменклатура.Идентификатор = СокрЛП(СЛокальнаяПеременная);
	КонецЕсли;
	
	
	// Характеристика
	Если		СопоставлениеЗаполнить.Свойство("Характеристика", СЛокальнаяПеременная) Тогда
		// При записи в старых методах приходит Ссылка на характеристику, а при групповом чтении ссылка на характеристику СБИС.
	ИначеЕсли	СопоставлениеЗаполнить.Свойство("Характеристика1С", СЛокальнаяПеременная) Тогда
		// Характеристика 1С по-новому (ссылка)
	КонецЕсли;
	Если 		ЗначениеЗаполнено(СЛокальнаяПеременная)
		И	Не	ТипЗнч(СЛокальнаяПеременная) = Тип("Структура")
		И	Не	ТипЗнч(СЛокальнаяПеременная) = Тип("Строка")
		И	СтрНоменклатура.Характеристики.Найти(СЛокальнаяПеременная) = Неопределено Тогда
		СтрНоменклатура.Характеристики.Добавить(СЛокальнаяПеременная);
	КонецЕсли;
	
	СтрокаСопоставленияСБИС.Номенклатура1С.Вставить(НоменклатураСсылка, СтрНоменклатура);
	
	Если	СопоставлениеЗаполнить.Свойство("ЕдИзм1С", СЛокальнаяПеременная)
		И	ТипЗнч(СЛокальнаяПеременная) = Тип("Массив")
		И	ЗначениеЗаполнено(СЛокальнаяПеременная) Тогда
		
		Для каждого СтрЕдиница Из СЛокальнаяПеременная Цикл
			СопоставлениеДляЕдиницыСервер_Заполнить1С(СтрокаСопоставленияСБИС, СтрЕдиница);	
		КонецЦикла;	
	ИначеЕсли СопоставлениеЗаполнить.Свойство("ЕдИзм1С", СЛокальнаяПеременная)
		И ТипЗнч(СЛокальнаяПеременная) = Тип("Соответствие") Тогда
			СтрокаСопоставленияСБИС.Номенклатура1С.Получить(НоменклатураСсылка).Единицы.Очистить();
			СтрокаСопоставленияСБИС.Номенклатура1С.Получить(НоменклатураСсылка).Единицы = СЛокальнаяПеременная; 	
	Иначе
		СопоставлениеДляЕдиницыСервер_Заполнить1С(СтрокаСопоставленияСБИС, СопоставлениеЗаполнить);
	КонецЕсли;
	
КонецПроцедуры

Функция ОписаниеНоменклатуры1ССервер_Получить(ОписаниеНоменклатуры1С, КлючПоиска) Экспорт
	
	Перем Значение, КлючДобавления;
	
	Если		КлючПоиска = "Характеристики" Тогда
		Возврат ОписаниеНоменклатуры1С.Характеристики;
	ИначеЕсли	КлючПоиска = "GTIN" Тогда 
		Возврат ОписаниеНоменклатуры1С.GTIN;
	ИначеЕсли	КлючПоиска = "Единицы" Тогда
		Возврат ОписаниеНоменклатуры1С.Единицы;
	Иначе
		Возврат ОписаниеНоменклатуры1С.Единицы.Получить(КлючПоиска);
	КонецЕсли;

КонецФункции

Процедура ОписаниеНоменклатуры1ССервер_Вставить(ОписаниеНоменклатуры1С, КлючВставить, ЗначениеВставить) Экспорт
	
	Перем Значение, КлючДобавления;
	
	Если		КлючВставить = "Характеристика" Тогда
		ОписаниеНоменклатуры1С.Характеристики.Добавить(ЗначениеВставить);
	ИначеЕсли	КлючВставить = "GTIN" Тогда 
		ОписаниеНоменклатуры1С.GTIN = ЗначениеВставить;
	ИначеЕсли	КлючВставить = "Единица" Тогда
		ИдЗаписиСбис = СопоставлениеДляЕдиницыСервер_Ключ(ЗначениеВставить);
		ОписаниеНоменклатуры1С.Единицы.Вставить(ИдЗаписиСбис, ЗначениеВставить);
	ИначеЕсли	КлючВставить = "Номенклатура" Тогда
		ИдЗаписиСбис = СопоставлениеДляЕдиницыСервер_Ключ(ЗначениеВставить);
		ОписаниеНоменклатуры1С.Единицы.Вставить(ИдЗаписиСбис, ЗначениеВставить);
	КонецЕсли;

КонецПроцедуры

