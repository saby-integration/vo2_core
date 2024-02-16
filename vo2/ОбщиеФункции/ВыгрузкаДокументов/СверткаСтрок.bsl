
&НаКлиенте
Функция СвернутьМассивСтрокДокумента(Кэш, Знач МассивСтрок, КолонкиСуммирования) Экспорт
	ИтоговыйМассивСтрок = Новый Массив;
	
	Ошибка = Ложь;
	МассивИд = Новый Массив;
	счСвернутых = 1;
	КолонкиСуммированияМассив = Кэш.ОбщиеФункции.РазбитьСтрокуВМассивНаКлиенте(КолонкиСуммирования, ",");

	Для Каждого СтрокаМассива Из МассивСтрок Цикл
		ИдСтроки = "";
		Для Каждого СтрокаСтруктуры Из СтрокаМассива Цикл
			Если	ТипЗнч(СтрокаСтруктуры) = Тип("КлючИЗначение")
					И СтрокаСтруктуры.Ключ = "ПорНомер" Тогда
					// Не добавляем в ИД порядковый номер строки
					Продолжить;
			КонецЕсли;
			ПолучитьИдСтрокиДокумента(ИдСтроки, СтрокаСтруктуры, КолонкиСуммированияМассив);
		КонецЦикла;
		
		ИндексМассива = МассивИд.Найти(ИдСтроки);
		Если ИндексМассива = Неопределено  Тогда // Если не нашли по индексу добавляем всю строку целиком							
			СтрокаМассива.Вставить("ПорНомер",Формат(счСвернутых, "ЧГ=0"));
			ИтоговыйМассивСтрок.Добавить(СтрокаМассива);
			МассивИд.Добавить(ИдСтроки);
			счСвернутых = счСвернутых + 1;
		Иначе
			НайденаяСтрока = ИтоговыйМассивСтрок[ИндексМассива];
			//иначе суммируем необходимые значения
			Для каждого ИмяКолонки из КолонкиСуммированияМассив Цикл
				КолонкаСуммированияМассив = Кэш.ОбщиеФункции.РазбитьСтрокуВМассивНаКлиенте(ИмяКолонки, ".");
				
				РезультатСложения = СложитьСтрокиПриСвертке(Кэш, Ошибка, КолонкаСуммированияМассив, НайденаяСтрока, СтрокаМассива);
				Если РезультатСложения = Ложь Тогда // Допускаем, что колонки может не быть конкретно в нашем массиве сттрок
					СтрокаМассива.Вставить("ПорНомер",Формат(счСвернутых, "ЧГ=0"));
					ИтоговыйМассивСтрок.Добавить(СтрокаМассива);
					МассивИд.Добавить(ИдСтроки);
					счСвернутых = счСвернутых + 1;
					Если Ошибка Тогда // Если неправильно задана колонка суммирования
						Сообщить("Неверно заданы параметры свертки строк в настройках выгрузки документа!");
					КонецЕсли;
					Прервать;
				КонецЕсли;
			КонецЦикла;
		КонецЕсли;
	КонецЦикла;
	
	Возврат ИтоговыйМассивСтрок;
КонецФункции

&НаКлиенте
Функция СложитьСтрокиПриСвертке(Кэш, Ошибка, КолонкаСуммированияМассив, НайденаяСтрока, СуммируемаяСтрока) Экспорт
	ОбъектСуммирования = НайденаяСтрока; // Тут храним то, к чему будем прибавлять
	ЗначениеСложения = СуммируемаяСтрока; // Тут храним то, что будем прибавлять
	
	Для i = 0 По КолонкаСуммированияМассив.ВГраница() Цикл
		КолонкаСуммирования = КолонкаСуммированияМассив[i];
		Попытка // Допускаем, что колонок может не быть
			Если ТипЗнч(ОбъектСуммирования) = Тип("Структура") Тогда
				Если ТипЗнч(ОбъектСуммирования[КолонкаСуммирования]) = Тип("Строка") Тогда
					ОбъектСуммирования[КолонкаСуммирования] = СложитьЗначенияСветкиСтрок(Кэш, КолонкаСуммирования, ОбъектСуммирования[КолонкаСуммирования], ЗначениеСложения[КолонкаСуммирования]);
					Возврат Истина;
				КонецЕсли;
				ОбъектСуммирования = ОбъектСуммирования[КолонкаСуммирования];
				ЗначениеСложения = ЗначениеСложения[КолонкаСуммирования];
				
				// Если это последняя колонка и тип значения объектов  - массив, то сложим массивы
				Если	ТипЗнч(ОбъектСуммирования) = Тип("Массив")
					И КолонкаСуммированияМассив.Найти(КолонкаСуммирования) = КолонкаСуммированияМассив.ВГраница() Тогда
					
					Для Каждого СтрокаМассиваСложения Из ЗначениеСложения Цикл
						ОбъектСуммирования.Добавить(СтрокаМассиваСложения);
					КонецЦикла;
					Возврат Истина;
				ИначеЕсли ТипЗнч(ОбъектСуммирования) = Тип("Структура") И КолонкаСуммированияМассив.ВГраница() = i Тогда
					Возврат Истина; // В некоторых случаях в результате формирования документа вместо массива приходит структура(если значений нет, а что то должно быть) Пример: "ПредСтрТабл.СведПрослеж"
				КонецЕсли;
			ИначеЕсли ТипЗнч(ОбъектСуммирования) = Тип("Массив") Тогда
				ОбъектСуммирования = НайтиСтрокуВМассивеСтруктурИмяЗначение(КолонкаСуммирования, ОбъектСуммирования);
				ЗначениеСложения = НайтиСтрокуВМассивеСтруктурИмяЗначение(КолонкаСуммирования, ЗначениеСложения);
				Если ОбъектСуммирования = Неопределено ИЛИ ЗначениеСложения = Неопределено Тогда
					// Так же допускаем, что такой колонки может не быть
					Возврат Истина;
				КонецЕсли;
				
				ОбъектСуммирования.Значение = СложитьЗначенияСветкиСтрок(Кэш, КолонкаСуммирования, ОбъектСуммирования.Значение, ЗначениеСложения.Значение);
				Возврат Истина;
			КонецЕсли;	
		Исключение
			Возврат Истина;
		КонецПопытки;	
	КонецЦикла;
	
	// Если мы не возвратились в цикле, то колонки суммирования заданы неправильно
	Ошибка = Истина;
	Возврат Ложь;
КонецФункции

&НаКлиенте
Функция СложитьЗначенияСветкиСтрок(Кэш, ИмяЗначения, ПервоеЗначение, ВтороеЗначение) Экспорт
	Результат = "";
	Если ИмяЗначения = "Сумма" ИЛИ ИмяЗначения = "СуммаБезНал" Тогда
		Если ПервоеЗначение = "без акциза" ИЛИ ВтороеЗначение = "без акциза" Тогда
			// Заглушка на суммирование значений сумм акциза
			Если ПервоеЗначение = "без акциза" Тогда
				ПервоеЗначение = 0;
			Иначе
				ПервоеЗначение = Число(ПервоеЗначение);
			КонецЕсли;
			Если ВтороеЗначение = "без акциза" Тогда
				ВтороеЗначение = 0;
			Иначе
				ВтороеЗначение = Число(ВтороеЗначение);
			КонецЕсли;
			Результат = ПервоеЗначение + ВтороеЗначение;
			Если Результат = 0 Тогда
				Результат = "без акциза";
			Иначе
				Результат = Формат(Результат, "ЧЦ=17; ЧДЦ=2; ЧРД=.; ЧГ=0; ЧН=0.00");
			КонецЕсли;
		Иначе
			Результат = Число(ПервоеЗначение) + Число(ВтороеЗначение);
			Результат = Формат(Результат, "ЧЦ=17; ЧДЦ=2; ЧРД=.; ЧГ=0; ЧН=0.00");
		КонецЕсли;
	Иначе
		МассивПервогоЗначения = Кэш.ОбщиеФункции.РазбитьСтрокуВМассивНаКлиенте(Строка(ПервоеЗначение), ".");
		ЧислоЗнаковПослеЗапятойПервогоЗначения = 0;
		Если МассивПервогоЗначения.ВГраница() = 1 Тогда
			ЧислоЗнаковПослеЗапятойПервогоЗначения = СтрДлина(МассивПервогоЗначения[1]);
		КонецЕсли;
		МассивВторогоЗначения = Кэш.ОбщиеФункции.РазбитьСтрокуВМассивНаКлиенте(Строка(ВтороеЗначение), ".");
		ЧислоЗнаковПослеЗапятойВторогоЗначения = 0;
		Если МассивВторогоЗначения.ВГраница() = 1 Тогда
			ЧислоЗнаковПослеЗапятойВторогоЗначения = СтрДлина(МассивВторогоЗначения[1]);
		КонецЕсли;
		
		Если ЧислоЗнаковПослеЗапятойПервогоЗначения >= ЧислоЗнаковПослеЗапятойВторогоЗначения Тогда
			ЧислоЗнаковПослеЗапятой = ЧислоЗнаковПослеЗапятойПервогоЗначения;
		Иначе
			ЧислоЗнаковПослеЗапятой = ЧислоЗнаковПослеЗапятойВторогоЗначения;
		КонецЕсли;

		Результат = Число(ПервоеЗначение) + Число(ВтороеЗначение);
		Результат = Формат(Результат, "ЧЦ=17; ЧДЦ="+ЧислоЗнаковПослеЗапятой+"; ЧРД=.; ЧГ=0; ЧН=0");
	КонецЕсли;
	Возврат Результат;
КонецФункции

&НаКлиенте
Функция НайтиСтрокуВМассивеСтруктурИмяЗначение(Имя, МассивПоиска) Экспорт
	Для ИндМассива = 0 По МассивПоиска.ВГраница() Цикл
		СтрокаМассива = МассивПоиска[ИндМассива];
		Если СтрокаМассива.Имя = Имя Тогда
			Возврат СтрокаМассива;
		КонецЕсли;
	КонецЦикла;
	// Если не нашли строку по имени, возвращаем неопределено
	Возврат Неопределено;
КонецФункции

&НаКлиенте
Процедура ПолучитьИдСтрокиДокумента(ИдСтроки, ЗначениеКоллекция, КолонкиСуммированияМассив, НазваниеКолонки = "", ОбходимСтруктурыИмяЗначение = Ложь) Экспорт	
	Если ТипЗнч(ЗначениеКоллекция) = Тип("Массив") Тогда
		// Проверим, что каждый элемент массива - структура с 2 элементами Имя и Значение. Если это не так, то возвращаемся для дальнейшего сложения массивов.
		Для Каждого СтрокаМассива Из ЗначениеКоллекция Цикл
			Если	ТипЗнч(СтрокаМассива) <> Тип("Структура")	
					ИЛИ СтрокаМассива.Количество() <> 2
					ИЛИ НЕ (СтрокаМассива.Свойство("Имя") И СтрокаМассива.Свойство("Значение")) Тогда
				Возврат;
			КонецЕсли;
		КонецЦикла;
		
		Для Каждого СтрокаМассива Из ЗначениеКоллекция Цикл
			ПолучитьИдСтрокиДокумента(ИдСтроки, СтрокаМассива, КолонкиСуммированияМассив, НазваниеКолонки + ".", Истина);
		КонецЦикла;
	ИначеЕсли ТипЗнч(ЗначениеКоллекция) = Тип("Структура") Тогда
		Если ОбходимСтруктурыИмяЗначение Тогда
			// Если обходим массив структур (Имя) - (Значение), то используем свой алгоритм
			Для Каждого СтрокаСтруктуры Из ЗначениеКоллекция  Цикл
				Если СтрокаСтруктуры.Ключ = "Значение" Тогда
					ПолучитьИдСтрокиДокумента(ИдСтроки, СтрокаСтруктуры, КолонкиСуммированияМассив, НазваниеКолонки + ЗначениеКоллекция.Имя, ОбходимСтруктурыИмяЗначение);
					Прервать;
				КонецЕсли;
			КонецЦикла;	
		Иначе
			Для Каждого СтрокаСтруктуры Из ЗначениеКоллекция Цикл
				ПолучитьИдСтрокиДокумента(ИдСтроки, СтрокаСтруктуры, КолонкиСуммированияМассив, НазваниеКолонки + ".", Ложь);
			КонецЦикла;
		КонецЕсли;
	ИначеЕсли ТипЗнч(ЗначениеКоллекция) = Тип("КлючИЗначение") Тогда
		Если ТипЗнч(ЗначениеКоллекция.Значение) <> Тип("Строка") Тогда
			ПолучитьИдСтрокиДокумента(ИдСтроки, ЗначениеКоллекция.Значение, КолонкиСуммированияМассив, НазваниеКолонки + ЗначениеКоллекция.Ключ, ОбходимСтруктурыИмяЗначение);
			Возврат;
		КонецЕсли;
		
		Если ОбходимСтруктурыИмяЗначение Тогда
			НазваниеКолонкиИтог = НазваниеКолонки;
		Иначе
			НазваниеКолонкиИтог = НазваниеКолонки + ЗначениеКоллекция.Ключ;
		КонецЕсли;
				
		// Формируем Идентификатор строки таблицы. Учитываем значение в идентификаторе только если колонки нет в колонках суммирования. 
		Если КолонкиСуммированияМассив.Найти(НазваниеКолонкиИтог) = Неопределено Тогда
			ИдСтроки = ИдСтроки + СокрЛП(ЗначениеКоллекция.Значение);
		КонецЕсли;
	КонецЕсли;
КонецПроцедуры

