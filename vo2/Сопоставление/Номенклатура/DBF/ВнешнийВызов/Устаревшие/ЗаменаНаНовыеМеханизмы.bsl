
// Получает номенклатуру 1С по структуре контрагента и номенклатуры СБИС. Вызывает функцию поиска номенклатуры на сервере 
&НаКлиенте
Функция НайтиНоменклатуруПоставщикаПоТабличнойЧасти(стрКонтрагент, мТаблДок, КаталогНастроек, Ини) Экспорт
	
	Если Не ПараметрыСоединения.НовоеСопоставление Тогда
		Возврат old_НайтиНоменклатуруПоставщикаПоТабличнойЧасти(стрКонтрагент, мТаблДок, КаталогНастроек, Ини);
	КонецЕсли;
	
	Попытка
		
		#Если ТолстыйКлиентОбычноеПриложение Тогда
			Возврат НайтиНоменклатуруПоставщикаПоТабличнойЧасти_СсылкаСервер(стрКонтрагент, мТаблДок);
		#Иначе
			Возврат НайтиНоменклатуруПоставщикаПоТабличнойЧасти_ЗначСервер(стрКонтрагент, мТаблДок);
		#КонецЕсли
			
	Исключение
		ИнфоОбОшибке = ИнформацияОбОшибке();
		МодульОбъектаКлиент().ВызватьСбисИсключение(ИнфоОбОшибке, "СопоставлениеНоменклатуры_ДБФ.НайтиНоменклатуруПоставщикаПоТабличнойЧасти");
	КонецПопытки;
	
КонецФункции

&НаСервере
Функция НайтиНоменклатуруПоставщикаПоТабличнойЧасти_ЗначСервер(Знач стрКонтрагент,  Знач мТаблДок) Экспорт
	
	Возврат НайтиНоменклатуруПоставщикаПоТабличнойЧасти_СсылкаСервер(стрКонтрагент, мТаблДок);
	
КонецФункции

&НаСервере
Функция НайтиНоменклатуруПоставщикаПоТабличнойЧасти_СсылкаСервер(стрКонтрагент,  мТаблДок) Экспорт
	
	МодульОбъектаСервер = МодульОбъектаСервер();
	
	ПараметрыМассовогоПоиска = Новый Структура;
	ПараметрыМассовогоПоиска.Вставить("Ключ",		КлючКонтрагентаСопоставления(стрКонтрагент));
	ПараметрыМассовогоПоиска.Вставить("ПоискПо1С",	Ложь);
	//Создать объекты сопоставления для поиска
	НоменклатураНайти = Новый Массив;
	Для Каждого СтрНоменклатураПоставщика Из мТаблДок Цикл
		НоменклатураНайти.Добавить(МодульОбъектаСервер.НовыйСтрокаСопоставленияСБИССервер(СтрНоменклатураПоставщика));
	КонецЦикла;
	
	Попытка
		НоменклатураПоставщика_ОбогатитьЗаписиСервер(НоменклатураНайти, ПараметрыМассовогоПоиска);
	Исключение
		МодульОбъектаСервер.ВызватьСбисИсключениеСервер(ИнформацияОбОшибке(), "СопоставлениеНоменклатуры_ДБФ.НайтиНоменклатуруПоставщикаПоТабличнойЧасти_Сервер");
	КонецПопытки;
	
	СчетчикСтрок = 0;
	Результат = Новый Структура;
	Для Каждого СтрокаРезультат Из НоменклатураНайти Цикл
		
		НоменклатураПоставщика	= Новый Структура("Характеристика, Номенклатура");
		Номенклатура1С			= МодульОбъектаСервер.СтрокаСопоставленияСБИССервер_Получить(СтрокаРезультат, "Номенклатура1С");
		Для Каждого КлючИзначение Из Номенклатура1С Цикл
			
			НоменклатураПоставщика.Номенклатура = КлючИзначение.Ключ;
			
			ХарактеристикиНоменклатуры1С	= МодульОбъектаСервер.ОписаниеНоменклатуры1ССервер_Получить(КлючИзначение.Значение, "Характеристики");
			ЕдиницыНоменклатуры1С			= МодульОбъектаСервер.ОписаниеНоменклатуры1ССервер_Получить(КлючИзначение.Значение, "Единицы");
			
			Если ЗначениеЗаполнено(ХарактеристикиНоменклатуры1С) Тогда
				
				НоменклатураПоставщика.Характеристика = ХарактеристикиНоменклатуры1С[0];
				
			КонецЕсли;
			
			НоменклатураПоставщика.Вставить("ЕдИзмОрг");
			НоменклатураПоставщика.Вставить("Коэффициент");
			
			Для Каждого КлючИзначениеЕдиницы Из ЕдиницыНоменклатуры1С Цикл
				
				НоменклатураПоставщика.ЕдИзмОрг		= МодульОбъектаСервер.СопоставлениеДляЕдиницыСервер_Получить(КлючИзначениеЕдиницы.Значение, "Ссылка");
				НоменклатураПоставщика.Коэффициент	= МодульОбъектаСервер.СопоставлениеДляЕдиницыСервер_Получить(КлючИзначениеЕдиницы.Значение, "Коэффициент");
				Прервать;
				
			КонецЦикла;
			Прервать;
			
		КонецЦикла;
		СтрокаПоиска = Новый Структура("НоменклатураПоставщика", НоменклатураПоставщика);
		
		СтрокаПоиска.Вставить("Название",		МодульОбъектаСервер.СтрокаСопоставленияСБИССервер_Получить(СтрокаРезультат, "ИмяНоменклатурыСБИС"));
		СтрокаПоиска.Вставить("Идентификатор",	МодульОбъектаСервер.СтрокаСопоставленияСБИССервер_Получить(СтрокаРезультат, "ИдНоменклатурыСБИС"));
		
		Результат.Вставить("СтрТабл_" + Формат(СчетчикСтрок, "ЧН=0; ЧГ=0"), СтрокаПоиска);
		СчетчикСтрок = СчетчикСтрок + 1;
		
	КонецЦикла;
	Возврат Результат;
	
КонецФункции

// Функция ищет номенклатуру поставщика по идентификатору.
// Если сопоставление заполнено, возвращает структуру с номенклатурой и характеристикой номенклатуры
&НаКлиенте
Функция НайтиНоменклатуруПоставщика(стрКонтрагент, СтрНоменклатураПоставщика, КаталогНастроек, Ини) Экспорт

	Если Не ПараметрыСоединения.НовоеСопоставление Тогда
		Возврат old_НайтиНоменклатуруПоставщика(стрКонтрагент, СтрНоменклатураПоставщика, КаталогНастроек, Ини);
	КонецЕсли;
	
	Попытка

		#Если ТолстыйКлиентОбычноеПриложение Тогда
			Возврат НайтиНоменклатуруПоставщика_СсылкаСервер(стрКонтрагент, СтрНоменклатураПоставщика);
		#Иначе
			Возврат НайтиНоменклатуруПоставщика_ЗначСервер(стрКонтрагент, СтрНоменклатураПоставщика);
		#КонецЕсли
		
	Исключение
		ИнфоОбОшибке = ИнформацияОбОшибке();
		МодульОбъектаКлиент().ВызватьСбисИсключение(ИнфоОбОшибке, "СопоставлениеНоменклатуры_ДБФ.НайтиНоменклатуруПоставщикаПоТабличнойЧасти");
	КонецПопытки;
			
КонецФункции

&НаСервере
Функция НайтиНоменклатуруПоставщика_ЗначСервер(Знач стрКонтрагент, Знач СтрНоменклатураПоставщика)
	
	Возврат НайтиНоменклатуруПоставщика_СсылкаСервер(стрКонтрагент, СтрНоменклатураПоставщика);
	
КонецФункции	
	
&НаСервере
Функция НайтиНоменклатуруПоставщика_СсылкаСервер(стрКонтрагент, СтрНоменклатураПоставщика)
	
	МодульОбъектаСервер = МодульОбъектаСервер();
	
	Попытка
		НоменклатураНайти = Новый Массив;
		НоменклатураНайти.Добавить(МодульОбъектаСервер.НовыйСтрокаСопоставленияСБИССервер(СтрНоменклатураПоставщика));
		
		ПараметрыМассовогоПоиска = Новый Структура;
		ПараметрыМассовогоПоиска.Вставить("Ключ",		КлючКонтрагентаСопоставления(стрКонтрагент));		
		ПараметрыМассовогоПоиска.Вставить("ПоискПо1С",	НоменклатураНайти);
		
		НоменклатураПоставщика_ОбогатитьЗаписиСервер(НоменклатураНайти, ПараметрыМассовогоПоиска);
		
		Результат = Новый Структура("Номенклатура, Характеристика, ЕдИзмОрг, Коэффициент");
		
		Номенклатура1С = МодульОбъектаСервер.СтрокаСопоставленияСБИССервер_Получить(Результат.Номенклатура, "Номенклатура1С");
		
		Для Каждого КлючИЗначение Из Номенклатура1С Цикл
			
			Результат.Номенклатура = КлючИЗначение.Ключ;
			
			ХарактиеристикиНоменклатуры = МодульОбъектаСервер.ОписаниеНоменклатуры1ССервер_Получить(КлючИЗначение.Значение, "Характеристики");
			ЕдиницыНоменклатуры			= МодульОбъектаСервер.ОписаниеНоменклатуры1ССервер_Получить(КлючИЗначение.Значение, "Единицы");
			Если ХарактиеристикиНоменклатуры.Количество() Тогда
				Результат.Характеристика = ХарактиеристикиНоменклатуры[0];
			КонецЕсли;
			
			ДЛя Каждого КлючИЗначениеЕдиницы Из ЕдиницыНоменклатуры Цикл
				
				Результат.ЕдИзмОрг		= КлючИЗначениеЕдиницы.Ключ;
				Результат.Коэффициент	= МодульОбъектаСервер.СопоставлениеДляЕдиницыСервер_Получить(КлючИЗначениеЕдиницы.Значение, "Коэффициент");
				Прервать;
				
			КонецЦикла;
			Прервать;
			
		КонецЦикла;
		Возврат Результат;
	Исключение
		ИнфоОбОшибке = ИнформацияОбОшибке();
		МодульОбъектаСервер.ВызватьСбисИсключениеСервер(ИнфоОбОшибке, "СопоставлениеНоменклатуры_ДБФ.НайтиНоменклатуруПоставщикаПоТабличнойЧасти");
	КонецПопытки;
	
КонецФункции

// Процедура устанавливает/удаляет соответствие номенклатуры	
&НаКлиенте
Процедура УстановитьСоответствиеНоменклатуры(СтрКонтрагент, стрНоменклатураПоставщика, КаталогНастроек, Ини) Экспорт
	
	Если Не ПараметрыСоединения.НовоеСопоставление Тогда
		old_УстановитьСоответствиеНоменклатуры(СтрКонтрагент, стрНоменклатураПоставщика, КаталогНастроек, Ини);
		Возврат;
	КонецЕсли;
	
	Попытка
		
		#Если ТолстыйКлиентОбычноеПриложение Тогда
			УстановитьСоответствиеНоменклатуры_СсылкаСервер(СтрКонтрагент, стрНоменклатураПоставщика);
		#Иначе
			УстановитьСоответствиеНоменклатуры_ЗначСервер(СтрКонтрагент, стрНоменклатураПоставщика);
		#КонецЕсли
			
	Исключение
		ИнфоОбОшибке = ИнформацияОбОшибке();
		МодульОбъектаКлиент().ВызватьСбисИсключение(ИнфоОбОшибке, "СопоставлениеНоменклатуры_ДБФ.НайтиНоменклатуруПоставщикаПоТабличнойЧасти");
	КонецПопытки;

КонецПроцедуры

&НаСервере
Процедура УстановитьСоответствиеНоменклатуры_ЗначСервер(Знач СтрКонтрагент, Знач стрНоменклатураПоставщика)
	
	УстановитьСоответствиеНоменклатуры_СсылкаСервер(СтрКонтрагент, стрНоменклатураПоставщика);
	
КонецПроцедуры

// Процедура устанавливает/удаляет соответствие номенклатуры	
&НаСервере
Процедура УстановитьСоответствиеНоменклатуры_СсылкаСервер(СтрКонтрагент, стрНоменклатураПоставщика)
	
	Попытка
		ПараметрыНоменклатуры = Новый Массив;
		ПараметрыНоменклатуры.Добавить(стрНоменклатураПоставщика);
		
		ПараметрыУстановкиСоответствия	= Новый Структура("Ключ, Номенклатура", КлючКонтрагентаСопоставления(СтрКонтрагент));
		НоменклатураСоответствия		= ПривестиФорматЗаписиСопоставления(ПараметрыНоменклатуры);
		
		Если ЗначениеЗаполнено(НоменклатураСоответствия.Удалить) Тогда
			ПараметрыУстановкиСоответствия.Номенклатура = НоменклатураСоответствия.Удалить;
			НоменклатураПоставщика_МассовоеУдалениеСервер(ПараметрыУстановкиСоответствия);
		КонецЕсли;
		Если ЗначениеЗаполнено(НоменклатураСоответствия.Обновить) Тогда
			ПараметрыУстановкиСоответствия.Номенклатура = НоменклатураСоответствия.Обновить;
			НоменклатураПоставщика_МассовоеОбновлениеСервер(ПараметрыУстановкиСоответствия);
		КонецЕсли;
	Исключение
		ИнфоОбОшибке = ИнформацияОбОшибке();
		МодульОбъектаСервер().ВызватьСбисИсключениеСервер(ИнфоОбОшибке, "СопоставлениеНоменклатуры_ДБФ.НайтиНоменклатуруПоставщикаПоТабличнойЧасти");
	КонецПопытки;
	
КонецПроцедуры

// Процедура ищет идентификатор номенклатуры контрагента	
&НаКлиенте
Функция ПолучитьИдентификаторНоменклатурыПоставщика(СтрКонтрагент, стрНоменклатура, КаталогНастроек, Ини) Экспорт
	
	Если Не ПараметрыСоединения.НовоеСопоставление Тогда
		Возврат old_ПолучитьИдентификаторНоменклатурыПоставщика(СтрКонтрагент, стрНоменклатура, КаталогНастроек, Ини);
	КонецЕсли;

	Попытка
		
		#Если ТолстыйКлиентОбычноеПриложение Тогда
			Возврат ПолучитьИдентификаторНоменклатурыПоставщика_СсылкаСервер(СтрКонтрагент, стрНоменклатура);
		#Иначе
			Возврат ПолучитьИдентификаторНоменклатурыПоставщика_ЗначСервер(СтрКонтрагент, стрНоменклатура);
		#КонецЕсли
		
	Исключение
		ИнфоОбОшибке = ИнформацияОбОшибке();
		МодульОбъектаКлиент().ВызватьСбисИсключение(ИнфоОбОшибке, "СопоставлениеНоменклатуры_ДБФ.НайтиНоменклатуруПоставщикаПоТабличнойЧасти");
	КонецПопытки;
	
КонецФункции

&НаСервере
Функция ПолучитьИдентификаторНоменклатурыПоставщика_ЗначСервер(Знач стрКонтрагент, Знач стрНоменклатура)
	
	Возврат ПолучитьИдентификаторНоменклатурыПоставщика_СсылкаСервер(стрКонтрагент, стрНоменклатура);
	
КонецФункции

// Процедура ищет идентификатор номенклатуры контрагента	
&НаСервере
Функция ПолучитьИдентификаторНоменклатурыПоставщика_СсылкаСервер(стрКонтрагент, стрНоменклатура)
	
	МодульОбъектаСервер = МодульОбъектаСервер();
	
	Попытка
		НоменклатураНайти = Новый Массив;
		НоменклатураНайти.Добавить(МодульОбъектаСервер.НовыйСтрокаСопоставленияСБИССервер(стрНоменклатура));
		
		ПараметрыПоиска = Новый Структура;
		ПараметрыПоиска.Вставить("Ключ",	КлючКонтрагентаСопоставления(стрКонтрагент));
		НоменклатураПоставщика_ОбогатитьЗаписиСервер(НоменклатураНайти, ПараметрыПоиска);
		Возврат МодульОбъектаСервер.СтрокаСопоставленияСБИССервер_Получить(НоменклатураНайти[0], "ИдНоменклатурыСБИС");
	Исключение
		ИнфоОбОшибке = ИнформацияОбОшибке();
		МодульОбъектаСервер.ВызватьСбисИсключениеСервер(ИнфоОбОшибке, "СопоставлениеНоменклатуры_ДБФ.ПолучитьИдентификаторНоменклатурыПоставщика_Сервер");
	КонецПопытки;
	
	Возврат "";
	
КонецФункции

