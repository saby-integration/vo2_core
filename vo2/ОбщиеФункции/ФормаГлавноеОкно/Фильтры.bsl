
////////////////////////////////////////////////////
///////////////////////Фильтры//////////////////////
////////////////////////////////////////////////////

/////////////////////Стандартный////////////////////

//Функция складывает в структуру текущие значения фильтра для последующего их восстановления	
&НаКлиенте
Функция сбисСохранитьТекущийФильтр(Кэш) Экспорт
	ТекущийФильтр = Новый Структура;
	ТекущийФильтр.Вставить("ФильтрПериод", ФильтрПериод);
	ТекущийФильтр.Вставить("ФильтрДатаНач", ФильтрДатаНач);
	ТекущийФильтр.Вставить("ФильтрДатаКнц", ФильтрДатаКнц);
	ТекущийФильтр.Вставить("ФильтрСостояние", ФильтрСостояние);
	ТекущийФильтр.Вставить("ФильтрКонтрагент", ФильтрКонтрагент);
	ТекущийФильтр.Вставить("ФильтрКонтрагентПодключен", ФильтрКонтрагентПодключен);
	ТекущийФильтр.Вставить("ФильтрКонтрагентСФилиалами", ФильтрКонтрагентСФилиалами);
	ТекущийФильтр.Вставить("ФильтрОрганизация", ФильтрОрганизация);
	ТекущийФильтр.Вставить("ФильтрСтраница", ФильтрСтраница);
	ТекущийФильтр.Вставить("ФильтрОтветственный", ФильтрОтветственный);
	ТекущийФильтр.Вставить("ФильтрТипыДокументов", ФильтрТипыДокументов);
	ТекущийФильтр.Вставить("ФильтрМаска", ФильтрМаска);
	
	//Заполним дополнительные параметры фильтра
	Если Кэш.ПараметрыФильтра.Количество()>0 Тогда
		ТекущийФильтр.Вставить("ПараметрыФильтра", Новый Структура);
		Для Каждого Элемент Из Кэш.ПараметрыФильтра Цикл
			ТекущийФильтр.ПараметрыФильтра.Вставить(Элемент.Ключ,Элемент.Значение);
		КонецЦикла;
	КонецЕсли;
	Возврат ТекущийФильтр;
КонецФункции

//Функция формирует период прописью	
&НаКлиенте
Функция ФильтрПериодПрописью(ДатНач, ДатКнц)
	Если Год(ДатНач)<>Год(ДатКнц) Тогда
		Возврат Формат(ДатНач, "ДФ=""д ММММ гггг""") + " - " + Формат(ДатКнц, "ДФ=""д ММММ гггг""");
	Иначе
		Если Месяц(ДатНач)<>Месяц(ДатКнц) Тогда
			Возврат Формат(ДатНач, "ДФ=""д ММММ""") + " - " + Формат(ДатКнц, "ДФ=""д ММММ""") + " " + Формат(Год(ДатКнц),"ЧГ=0");	
		Иначе
			Если ДатНач=ДатКнц Тогда
				Возврат Формат(ДатКнц, "ДФ=""д ММММ гггг""")
			Иначе
				Возврат строка(День(ДатНач)) + " - " + Формат(ДатКнц, "ДФ=""д ММММ""") + " "+ Формат(Год(ДатКнц),"ЧГ=0");	
			КонецЕсли;
		КонецЕсли;
	КонецЕсли;
КонецФункции

///////////////////Пользователський/////////////////

// Очищает в Кэше значения пользовательских фильтров для текущего раздела	
&НаКлиенте
Функция ОчиститьДополнительныеПараметрыФильтра(ФормаДопФильтра) Экспорт
	СписокДопЭлементов = ФормаДопФильтра.сбисСписокДопПараметровФильтра();
	ПараметрыУстановки = Новый Структура("ФормаДопФильтра, ДопЭлемент", ФормаДопФильтра);
	Отказ = Ложь;
	Для Каждого ДопЭлемент Из СписокДопЭлементов Цикл
		ПараметрыУстановки.ДопЭлемент = ДопЭлемент;
		РезультатУстановки = УстановитьЗначениеЭлементаФильтра(Кэш, ПараметрыУстановки, Отказ);
		Если Отказ Тогда
			сбисСообщитьОбОшибке(Кэш, РезультатУстановки);
			Отказ = Ложь;
		КонецЕсли;
	КонецЦикла;
КонецФункции

//Устанавливает значение для элемента фильтра.
//ЛокальныйКэш
//	Структура инициированного кэша с отвязкой от ГП.
//ПараметрыФильтра
//	Структура с полями "ФормаДопФильтра", "ДопЭлемент" - элемент, возвращаемый формой в списке пользовательских фильтров
//Отказ
//	Булево. Флаг ошибок в процессе установки и возврата структуры ошибки
//Возвращает
//	В случае ошибки, структура описания ошибки.
//	В случае, если это не элемент фильтра - Ложь.
//	В случае успешной установки - Истина;
&НаКлиенте
Функция УстановитьЗначениеЭлементаФильтра(ЛокальныйКэш, ПараметрыФильтра, Отказ) Экспорт
	
	ФормаДопФильтра = ПараметрыФильтра.ФормаДопФильтра;
	ДопЭлемент		= ПараметрыФильтра.ДопЭлемент;
	Попытка
		Если ЛокальныйКэш.ПараметрыСистемы.Клиент.УправляемоеПриложение Тогда
			ДопЭлемент_Значение	= ФормаДопФильтра[ДопЭлемент.Значение];
		Иначе
			ДопЭлемент_Элемент	= ЭтаФорма.ЭлементыФормы[ДопЭлемент.Значение];
			ДопЭлемент_Тип		= ТипЗнч(ДопЭлемент_Элемент);
			Если Не	(	ДопЭлемент_Тип = Тип("ПолеВвода")
					Или	ДопЭлемент_Тип = Тип("ПолеВыбора")
					Или	ДопЭлемент_Тип = Тип("Флажок")) Тогда
				Возврат Ложь;
			КонецЕсли;
			ДопЭлемент_Значение	= ДопЭлемент_Элемент.Значение;
		КонецЕсли;
	Исключение
		СтруктураОшибки = Новый Структура("code, message, details", 100, "Неизвестная ошибка системы", "Ошибка при определении дополнительного элемента фильтра " + ДопЭлемент.Значение + ": " + ОписаниеОшибки());
		Возврат СтруктураОшибки;
	КонецПопытки;
	
	ДопЭлемент_Значение_Тип = ТипЗнч(ДопЭлемент_Значение);
	ПараметрФильтра = "";//По-умолчанию, оставляем строку, как было.
	Если		ДопЭлемент_Значение_Тип = Тип("Дата") Тогда
		ПараметрФильтра = '0001.01.01';
	ИначеЕсли	ДопЭлемент_Значение_Тип = Тип("Число") Тогда
		ПараметрФильтра = 0;
	ИначеЕсли	ДопЭлемент_Значение_Тип = Тип("Булево") Тогда
		ПараметрФильтра = Ложь;
	ИначеЕсли	ДопЭлемент_Значение_Тип = Тип("СписокЗначений") Тогда
		ПараметрФильтра = Новый СписокЗначений;
		ПараметрФильтра.ТипЗначения = ДопЭлемент_Значение.ТипЗначения;//Ограничение типа тоже перенести.
	КонецЕсли;
	
	ЛокальныйКэш.ПараметрыФильтра.Вставить(ДопЭлемент.Значение, ПараметрФильтра);
	Если Не ЛокальныйКэш.ПараметрыСистемы.Клиент.УправляемоеПриложение Тогда
		ДопЭлемент_Элемент.Значение = ПараметрФильтра;
	КонецЕсли;
	Возврат Истина;

КонецФункции

// ОФ Показывает на форме элементы пользовательских фильтров	
&НаКлиенте
Функция ПоказатьДополнительныеПараметрыФильтра(ФормаДопФильтра) Экспорт
	СписокДопЭлементов = ФормаДопФильтра.сбисСписокДопПараметровФильтра();
	Для Каждого Элемент Из СписокДопЭлементов Цикл
		Попытка  
			ЭтаФорма.ЭлементыФормы[Элемент.Значение].Видимость = Истина;
		Исключение
		КонецПопытки;
	КонецЦикла;	
КонецФункции

// ОФ Скрывает на форме элементы пользовательских фильтров	
&НаКлиенте
Функция СкрытьДополнительныеПараметрыФильтра(ФормаДопФильтра) Экспорт
	СписокДопЭлементов =  ФормаДопФильтра.сбисСписокДопПараметровФильтра();
	Для Каждого Элемент Из СписокДопЭлементов Цикл
		Попытка  
			ЭтаФорма.ЭлементыФормы[Элемент.Значение].Видимость = Ложь;
		Исключение
		КонецПопытки;
	КонецЦикла;	
КонецФункции

// ОФ Записывает в Кэш значения пользовательских фильтров для текущего раздела	
&НаКлиенте
Функция УстановитьДополнительныеПараметрыФильтра(ФормаДопФильтра) Экспорт
	СписокДопЭлементов =  ФормаДопФильтра.сбисСписокДопПараметровФильтра();
	Для Каждого Элемент Из СписокДопЭлементов Цикл
		Попытка  
			Если ТипЗнч(ЭтаФорма.ЭлементыФормы[Элемент.Значение]) = Тип("ПолеВвода") или ТипЗнч(ЭтаФорма.ЭлементыФормы[Элемент.Значение]) = Тип("ПолеВыбора") или ТипЗнч(ЭтаФорма.ЭлементыФормы[Элемент.Значение]) = Тип("Флажок") Тогда
				Кэш.ПараметрыФильтра.Вставить(Элемент.Значение,ЭтаФорма.ЭлементыФормы[Элемент.Значение].Значение);
			КонецЕсли;
		Исключение
		КонецПопытки;
	КонецЦикла;	
КонецФункции

