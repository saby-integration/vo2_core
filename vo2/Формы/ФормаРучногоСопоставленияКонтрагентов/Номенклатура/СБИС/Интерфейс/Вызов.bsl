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
	
	ЭтаФорма.Заголовок = ПараметрыОткрытия.Заголовок;
	ТабличнаяЧасть.Очистить();
	МестныйКэш = ПараметрыОткрытия.Кэш; 
	
	#Область ЗаполнениеДанныхНоменклатурыСБИС
	// Данные шапки берём неизменно из номенклатуры СБИС, изменения вносить запрещено
	НоменклатураКонтрагента = ПараметрыОткрытия.ОсновныеДанные.НоменклатураСБИС.Наименование;
	Количество 				= ПараметрыОткрытия.ОсновныеДанные.НоменклатураСБИС.Количество;
	Цена 					= ПараметрыОткрытия.ОсновныеДанные.НоменклатураСБИС.Цена;
	СтавкаНДС 				= ПараметрыОткрытия.ОсновныеДанные.НоменклатураСБИС.СтавкаНДС;
	СуммаНДСПоДокументу 	= ПараметрыОткрытия.ОсновныеДанные.НоменклатураСБИС.СуммаНДС;  
	СуммаПоДокументу 		= ПараметрыОткрытия.ОсновныеДанные.НоменклатураСБИС.Сумма;
	СуммаВсего              = ПараметрыОткрытия.ОсновныеДанные.НоменклатураСБИС.Сумма;
	СуммаНДСВсего			= ПараметрыОткрытия.ОсновныеДанные.НоменклатураСБИС.СуммаНДС; 
	Если ПараметрыОткрытия.ОсновныеДанные.НоменклатураСБИС.Свойство("GTIN") Тогда
		GTIN = ПараметрыОткрытия.ОсновныеДанные.НоменклатураСБИС.GTIN;
	КонецЕсли;
	
	Если ПараметрыОткрытия.ОсновныеДанные.НоменклатураСБИС.Свойство("КодПокупателя")  Тогда
		КодПокупателя = ПараметрыОткрытия.ОсновныеДанные.НоменклатураСБИС.КодПокупателя;		
	ИначеЕсли ПараметрыОткрытия.ОсновныеДанные.НоменклатураСБИС.Свойство("ТипКода") И ПараметрыОткрытия.ОсновныеДанные.НоменклатураСБИС.ТипКода = "КодПокупателя" Тогда
		КодПокупателя = ПараметрыОткрытия.ОсновныеДанные.НоменклатураСБИС.Код;
	Иначе 
		КодПокупателя = "";
	КонецЕсли;
	
	Если ПараметрыОткрытия.ОсновныеДанные.НоменклатураСБИС.Свойство("Характеристика") Тогда  
		Характеристика = ПараметрыОткрытия.ОсновныеДанные.НоменклатураСБИС.Характеристика;
	КонецЕсли;
	
	// Теоретически не может быть несколько единиц поставщика, но если такая фигня случится, то возьмём последнюю
	Если ПараметрыОткрытия.ОсновныеДанные.НоменклатураСБИС.Единицы.Количество() Тогда 
		Для Каждого ЕдиницаПоставщика Из ПараметрыОткрытия.ОсновныеДанные.НоменклатураСБИС.Единицы Цикл 
			ЕдиницыИзмерения 		= ЕдиницаПоставщика.Значение.Название;
			Коэффициент 			= ЕдиницаПоставщика.Значение.Коэффициент;  
		КонецЦикла;
	КонецЕсли;
	#КонецОбласти //ЗаполнениеДанныхНоменклатурыСБИС
	
	ДанныеРучногоСопоставления = ПараметрыОткрытия.ОсновныеДанные;
	#Область ЗаполнениеНоменклатуры1С
	ОсновноеСопоставление = Истина;
	Для Каждого Номенклатура1С Из ПараметрыОткрытия.ОсновныеДанные.Номенклатура1С Цикл
		
		Если ПараметрыОткрытия.ОсновныеДанные.Номенклатура1С.Количество() = 1 
			И НЕ ЗначениеЗаполнено(Номенклатура1С.Ключ) Тогда
			
			ТабличнаяЧастьНстр = ТабличнаяЧасть.Добавить();
			ЗаполнитьЗначенияСвойств(ТабличнаяЧастьНСтр, ПараметрыОткрытия.ОсновныеДанные.НоменклатураСБИС, "Цена, Количество, СуммаНДС, СтавкаНДС, СуммаБезНДС, Сумма");   
			ТабличнаяЧастьНСтр.Коэффициент = Коэффициент;
			ТабличнаяЧастьНСтр.КоэффициентБыл = Коэффициент;
			ОсновноеСопоставление = Ложь;
			Прервать;
		ИначеЕсли ПараметрыОткрытия.ОсновныеДанные.Номенклатура1С.Количество() > 1
			И НЕ ЗначениеЗаполнено(Номенклатура1С.Ключ) Тогда
			Продолжить;
		КонецЕсли;     
		
		ТабличнаяЧастьНстр = ТабличнаяЧасть.Добавить();  
		ТабличнаяЧастьНстр.Номенклатура = Номенклатура1С.Ключ;    
		
		// Первую заполненную номенклатуру 1С в списке найденных сопоставлений считаем основной и заполняем для неё все табличные данные из документа
		Если ОсновноеСопоставление 
			И ПараметрыОткрытия.ОсновныеДанные.Номенклатура1С.Количество() > 0 
			И ЗначениеЗаполнено(Номенклатура1С.Ключ) Тогда
			
			ЗаполнитьЗначенияСвойств(ТабличнаяЧастьНСтр, ПараметрыОткрытия.ОсновныеДанные.НоменклатураСБИС, "Цена, Количество, СуммаНДС, СтавкаНДС, СуммаБезНДС, Сумма");   
			ОсновноеСопоставление = Ложь;  
			
		КонецЕсли;
		
		// Для всех строк по умолчанию заполняем:
		// --Елиницы
		// --Ссылку на номенклатуру 1С
		// --GTIN
		ЗаполнитьЗначенияСвойств(ТабличнаяЧастьНСтр, Номенклатура1С.Значение, "GTIN");
		ТабличнаяЧастьНстр.Номенклатура = Номенклатура1С.Ключ;
		
		Если НЕ Номенклатура1С.Значение.Единицы = Неопределено Тогда 
			
			ТабличнаяЧастьНСтр.Единицы = Новый Структура;
			ТабличнаяЧастьНСтр.Единицы.Вставить("Единицы", Номенклатура1С.Значение.Единицы);
			Для Каждого КлючИЗначение Из ТабличнаяЧастьНСтр.Единицы.Единицы Цикл
				ТабличнаяЧастьНСтр.ЕдиницыПредставление = ТабличнаяЧастьНСтр.ЕдиницыПредставление + КлючИЗначение.Ключ + "; ";
			КонецЦикла;
			
			Если ЗначениеЗаполнено(Коэффициент) Тогда   
				ТабличнаяЧастьНСтр.Коэффициент = Коэффициент;
			ИначеЕсли ЗначениеЗаполнено(Номенклатура1С.Значение.Коэффициент) Тогда
				ТабличнаяЧастьНСтр.Коэффициент = Номенклатура1С.Значение.Коэффициент;
			Иначе
				ТабличнаяЧастьНСтр.Коэффициент = 1;		
			КонецЕсли;                             
			
			ТабличнаяЧастьНСтр.КоэффициентБыл = ТабличнаяЧастьНСтр.Коэффициент;
			ПроизвестиПересчетПоКоэффициентуЕдиницИзмерения(ТабличнаяЧастьНСтр);
			
		Иначе
			ТабличнаяЧастьНСтр.Единицы = Новый Структура("Единицы", Новый Соответствие);	
		КонецЕсли;
		
		
	КонецЦикла;
	
	Если НЕ ТабличнаяЧасть.Количество() Тогда
		ТабличнаяЧастьНстр = ТабличнаяЧасть.Добавить();
		ЗаполнитьЗначенияСвойств(ТабличнаяЧастьНСтр, ПараметрыОткрытия.ОсновныеДанные.НоменклатураСБИС, "Цена, Количество, СуммаНДС, СтавкаНДС, СуммаБезНДС, Сумма");
	КонецЕсли;
	#КонецОбласти //ЗаполнениеНоменклатуры1С
	
	Если МестныйКэш.Ини.Конфигурация.Свойство("Номенклатура") Тогда
		ИмяСправочникаНоменклатуры = СокрЛП(Сред(МестныйКэш.Ини.Конфигурация.Номенклатура.Значение, Найти(МестныйКэш.Ини.Конфигурация.Номенклатура.Значение, ".") + 1));
		СправочникНоменклатураПолноеИмя = "Справочник." + ИмяСправочникаНоменклатуры;
		ТипСправочникаНоменклатуры = "СправочникСсылка." + ИмяСправочникаНоменклатуры;
	Иначе
		СправочникНоменклатураПолноеИмя = "Справочник.Номенклатура";
		ТипСправочникаНоменклатуры = "СправочникСсылка.Номенклатура";
	КонецЕсли;
	
	ЭтаФорма.Элементы.ТабличнаяЧастьНоменклатура.ОграничениеТипа = Новый ОписаниеТипов(ТипСправочникаНоменклатуры);	
	
	Если МестныйКэш.Ини.Конфигурация.Свойство("СправочникЕдиницИзмеренийДляСопоставлений") Тогда
		СправочникЕдиницПолноеИмя = "Справочник." + СокрЛП(Сред(МестныйКэш.Ини.Конфигурация.СправочникЕдиницИзмеренийДляСопоставлений.Значение, Найти(МестныйКэш.Ини.Конфигурация.СправочникЕдиницИзмеренийДляСопоставлений.Значение, ".")+1));
		ТипСправочникаЕдиницаИзмерения = МестныйКэш.Ини.Конфигурация.СправочникЕдиницИзмеренийДляСопоставлений.Значение;
	Иначе
		СправочникНоменклатураПолноеИмя = "Справочник.Номенклатура";
		ТипСправочникаЕдиницаИзмерения = "СправочникСсылка.КлассификаторЕдиницИзмерения";
	КонецЕсли;
	
	// Не допилено, на будущее: обработка ошибок сопоставления номенклатуры будет блокировать интерфейс для закрытия пока пользователь не исправит всё, или закроет без сохранения изменений
	СообщенияОбОшибках = Новый Структура;
	СообщенияОбОшибках.Вставить("Модуль");
	СообщенияОбОшибках.Вставить("ТекстОшибки");
	СообщенияОбОшибках.Вставить("Критическая");
	
	ЗакрытьБезСохранения = Ложь;
	СохранениеПроведено  = Ложь; 
	ИмеютсяИзмененияСопоставленнойНоменклатуры = Ложь;
	// ---------------------------------------------------------
	
КонецПроцедуры
