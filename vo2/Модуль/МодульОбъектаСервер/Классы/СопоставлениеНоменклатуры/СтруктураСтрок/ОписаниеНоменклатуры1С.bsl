
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
	
	Описание = Новый Структура;
	Описание.Вставить("_класс", "ОписаниеНоменклатуры1С");
	Описание.Вставить("Ссылка", Неопределено);
	Описание.Вставить("Характеристики", Новый Массив);
	Описание.Вставить("Идентификатор", "");
	Описание.Вставить("GTIN", "");
	Описание.Вставить("Единицы", Новый Соответствие);
	Описание.Вставить("Коэффициент", 1);
	Описание.Вставить("Основное", Ложь);
	Описание.Вставить("Цена", 0);
	Описание.Вставить("Кол_во", 0);
	Описание.Вставить("Сумма", 0);
	Описание.Вставить("СуммаБезнал", 0);
	Описание.Вставить("СтавкаНДС", "");
	Описание.Вставить("СуммаНДС", 0);
	Описание.Вставить("БазоваяЕдиницаОКЕИ", "796");
	Описание.Вставить("Ссылка", Неопределено); // Для работы с ДБФ, по просьбе Андрея (с)Сычев
	
	Возврат Описание;

КонецФункции

Процедура ОписаниеНоменклатуры1ССервер_Заполнить(СтрокаНоменклатуры1С, СопоставлениеЗаполнить) Экспорт
	
	Перем СЛокальнаяПеременная;
	
	НоменклатураСсылка	= СопоставлениеЗаполнить.Номенклатура;
		
	// Признак основной номенклатуры для сопоставления
	Если НЕ СтрокаНоменклатуры1С.Основное Тогда
		Если Не СопоставлениеЗаполнить.Свойство("Основное", СЛокальнаяПеременная) Тогда
			СЛокальнаяПеременная = Ложь;
		КонецЕсли;
		СтрокаНоменклатуры1С.Основное = СЛокальнаяПеременная;
	КонецЕсли;
	
	// GTIN
	Если НЕ ЗначениеЗаполнено(СтрокаНоменклатуры1С.GTIN) Тогда
		Если Не СопоставлениеЗаполнить.Свойство("GTIN_1С", СЛокальнаяПеременная) Тогда
			СЛокальнаяПеременная = "";
		КонецЕсли;
		СтрокаНоменклатуры1С.GTIN = СокрЛП(СЛокальнаяПеременная);
	КонецЕсли;
	
	// Идентификатор номенклатуры 1С
	Если НЕ ЗначениеЗаполнено(СтрокаНоменклатуры1С.Идентификатор) Тогда
		Если Не СопоставлениеЗаполнить.Свойство("Идентификатор1С", СЛокальнаяПеременная) Тогда
			СЛокальнаяПеременная = Строка(НоменклатураСсылка.УникальныйИдентификатор());
		КонецЕсли;
		СтрокаНоменклатуры1С.Идентификатор = СокрЛП(СЛокальнаяПеременная);
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
		И	СтрокаНоменклатуры1С.Характеристики.Найти(СЛокальнаяПеременная) = Неопределено Тогда
		СтрокаНоменклатуры1С.Характеристики.Добавить(СЛокальнаяПеременная);
	КонецЕсли;
	
	Если	СопоставлениеЗаполнить.Свойство("ЕдИзм1С", СЛокальнаяПеременная)
		И	ТипЗнч(СЛокальнаяПеременная) = Тип("Массив")
		И	ЗначениеЗаполнено(СЛокальнаяПеременная) Тогда
		
		Для каждого СтрЕдиница Из СЛокальнаяПеременная Цикл
			СопоставлениеДляЕдиницыСервер_Заполнить1С(СтрокаНоменклатуры1С, СтрЕдиница);	
		КонецЦикла;
		
	ИначеЕсли СопоставлениеЗаполнить.Свойство("ЕдИзм1С", СЛокальнаяПеременная)
		И ТипЗнч(СЛокальнаяПеременная) = Тип("Соответствие") Тогда
			СтрокаНоменклатуры1С.Единицы.Очистить();
			СтрокаНоменклатуры1С.Единицы = СЛокальнаяПеременная; 	
	Иначе
		СопоставлениеДляЕдиницыСервер_Заполнить1С(СтрокаНоменклатуры1С, СопоставлениеЗаполнить);
	КонецЕсли;
	
	// Данные для загрузки в документ 1С
	Если СопоставлениеЗаполнить.Свойство("Цена")
		И ЗначениеЗаполнено(СопоставлениеЗаполнить.Цена) Тогда
		
		СписокСвойств = "Цена, Кол_во, Сумма, СуммаБезНал, СуммаНДС, СтавкаНДС, БазоваяЕдиницаОКЕИ";
		ЗаполнитьЗначенияСвойств(СтрокаНоменклатуры1С, СопоставлениеЗаполнить, СписокСвойств);
				
	КонецЕсли;
	
	// Ссылка на номенклатуру 1С для использования в ДБФ по просьбе Андрея (с)Сычев
	СтрокаНоменклатуры1С.Ссылка = НоменклатураСсылка;
	
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
		ОписаниеНоменклатуры1С.Характеристика = ЗначениеВставить;
	ИначеЕсли	КлючВставить = "GTIN" Тогда 
		ОписаниеНоменклатуры1С.GTIN = ЗначениеВставить;
	ИначеЕсли	КлючВставить = "Единица" Тогда
		ИдЗаписиСбис = СопоставлениеДляЕдиницыСервер_Ключ(ЗначениеВставить);
		ОписаниеНоменклатуры1С.Единицы.Вставить(ИдЗаписиСбис, ЗначениеВставить);
	Иначе
		ОписаниеНоменклатуры1С[КлючВставить] = ЗначениеВставить;
	КонецЕсли;

КонецПроцедуры

