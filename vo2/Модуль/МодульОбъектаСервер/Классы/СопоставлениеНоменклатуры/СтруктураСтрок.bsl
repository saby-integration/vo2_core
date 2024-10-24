
#Область include_core2_vo2_Модуль_МодульОбъектаСервер_Классы_СопоставлениеНоменклатуры_СтруктураСтрок_СтрокаСопоставленияСБИС
#КонецОбласти

#Область include_core2_vo2_Модуль_МодульОбъектаСервер_Классы_СопоставлениеНоменклатуры_СтруктураСтрок_ОписаниеНоменклатуры1С
#КонецОбласти

#Область include_core2_vo2_Модуль_МодульОбъектаСервер_Классы_СопоставлениеНоменклатуры_СтруктураСтрок_СопоставлениеДляЕдиницы
#КонецОбласти

Функция ПорядокАвтоматическогоСопоставленияПоУмолчанию() Экспорт
	
	ПорядокАвтоматическогоСопоставления = Новый Массив;
	
	//ПорядокАвтоматическогоСопоставления.Добавить("GTIN"); // Убрали, т.к. GTIN в отдельном поле
	ПорядокАвтоматическогоСопоставления.Добавить("КодПокупателя");
	ПорядокАвтоматическогоСопоставления.Добавить("Идентификатор");
	ПорядокАвтоматическогоСопоставления.Добавить("Артикул");
	ПорядокАвтоматическогоСопоставления.Добавить("Код");
	ПорядокАвтоматическогоСопоставления.Добавить("Наименование");
	ПорядокАвтоматическогоСопоставления.Добавить("КодПоставщика");
	
	Возврат ПорядокАвтоматическогоСопоставления;
	
КонецФункции

Функция СтрокаСопоставленияСБИССервер_СформироватьТаблДок(Вложение, ДопПараметры = Неопределено) Экспорт
	
	Если НЕ ЗначениеЗаполнено(Вложение.КлассыСопоставленияНоменклатур) Тогда
		
		// Прокинуть исключение	
		
	КонецЕсли;
	
	ТаблДокИзФайла = Вложение.ТаблДок; // Рассчитывался при подготовке к загрузке
	
	ИндексСтрокиНоменклатурыСБИС = 0; 
	
	РассчитаннаяСтрокаТЧ = Новый Структура; 
	ТаблДокОбработанный = Новый Массив;
	ПорядковыйНомер = 1;
	
	Для Каждого Сопоставление Из Вложение.КлассыСопоставленияНоменклатур Цикл
		
		Для Каждого СтрокаНоменклатуры1С Из Сопоставление.Номенклатура1С Цикл
			
			Номенклатура1С = СтрокаНоменклатуры1С.Значение;
			Если НЕ ЗначениеЗаполнено(Номенклатура1С.Кол_во) Тогда
				Продолжить;
			КонецЕсли;
			
			РассчитаннаяСтрокаТЧ = ГлобальныйКэш.ТекущийСеанс.Модули.ФункцииДокументов.СбисСкопироватьОбъектНаКлиенте(ТаблДокИзФайла[ИндексСтрокиНоменклатурыСБИС]);
			
			// Ссылка и Наименование (а почему имя, а не ссылка?) 
			РассчитаннаяСтрокаТЧ.Название = ПолучитьИмяНоменклатурыПоСсылкеСервер(СтрокаНоменклатуры1С.Ключ);
			РассчитаннаяСтрокаТЧ.Вставить("Номенклатура", СтрокаНоменклатуры1С.Ключ);
			
			// Единицы
			Если РассчитаннаяСтрокаТЧ.Свойство("ЕдИзм") Тогда
				Для Каждого Единица Из Номенклатура1С.Единицы Цикл
					
					РассчитаннаяСтрокаТЧ.ЕдИзм = Единица.Ключ; 
					РассчитаннаяСтрокаТЧ.ОКЕИ  = Единица.Значение.ОКЕИ;
					РассчитаннаяСтрокаТЧ.Вставить("Коэффициент", Единица.Значение.Коэффициент);  
					Прервать;
				КонецЦикла;
			КонецЕсли;    
			
			// Цена, КолВо, Сумма с НДС 
			РассчитаннаяСтрокаТЧ.Цена 	= Номенклатура1С.Цена;
			РассчитаннаяСтрокаТЧ.Кол_во = Номенклатура1С.Кол_во;
			РассчитаннаяСтрокаТЧ.Сумма 	= Номенклатура1С.Сумма;
			
			// НДС
			РассчитаннаяСтрокаТЧ.НДС.Сумма 	= Номенклатура1С.СуммаНДС;
			РассчитаннаяСтрокаТЧ.НДС.Ставка = Номенклатура1С.СтавкаНДС;
			
			// Цена и Сумма без НДС
			РассчитаннаяСтрокаТЧ.СуммаБезНал = Номенклатура1С.СуммаБезНал;
			РассчитаннаяСтрокаТЧ.ЦенаБезНДС  = Номенклатура1С.СуммаБезНал / Номенклатура1С.Кол_во;
			
			// Непонятные параметры, потеребить Андрея
			НомерСтрокиТЧ = ПорядковыйНомер - 1;
			РассчитаннаяСтрокаТЧ.ПорНомер = ПорядковыйНомер;
			ТаблДокОбработанный.Добавить(РассчитаннаяСтрокаТЧ);                 
			
			ПорядковыйНомер = ПорядковыйНомер + 1;
		КонецЦикла;
		ИндексСтрокиНоменклатурыСБИС = ИндексСтрокиНоменклатурыСБИС + 1;
	КонецЦикла; 
	
	Возврат ТаблДокОбработанный;		
	
КонецФункции  

// Алярма, удалю функцию когда выпилю старое получение значение реквизита справочников и сделаю нормальный механизм
&НаСервере
Функция ПолучитьИмяНоменклатурыПоСсылкеСервер(Ссылка) Экспорт
	Возврат Ссылка.Наименование;
КонецФункции
