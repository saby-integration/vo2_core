
//Получает регламентированный отчет механизмом 1С
//getAttachmentTax
//Возвращает структуру ошибки, если упало формирование, Истина если выгружено, Ложь если файлы не сформированы. Результат заполняется в процессе в переменную СбисРезультат.
&НаКлиенте
Функция ПолучитьВложение_Отчет(Кэш, СбисРезультат, ВложениеСсылка, ДопПараметры, Отказ) Экспорт
	СписокОбъектов = Новый СписокЗначений;
	СписокОбъектов.Добавить(ВложениеСсылка);
	ТекстXML = "";
	Попытка
		ФормаФормированияОбъекта = ПолучитьФорму("Документ.ВыгрузкаРегламентированныхОтчетов.Форма.ФормаДокумента");
		ФормаФормированияОбъекта.СформироватьИЗаписать(СписокОбъектов, ТекстXML);
	Исключение
		Отказ = Истина;
		Возврат Кэш.ОбщиеФункции.СбисИсключение(ОписаниеОшибки(), "РаботаСДокументами1С.ПодготовитьВложение");
	КонецПопытки;
		
	ОписанияОбъектов = Новый Массив;
	Выгружены = ФормаФормированияОбъекта.Объект.Выгрузки;
	Если Не Выгружены.Количество() Тогда
		СбисРезультат.Вставить(ВложениеСсылка, Новый Структура("Ошибка", "Не удалось сформировать текст выгрузки. Проверьте формирование отчета."));
		Возврат Ложь;
	КонецЕсли;
	
	Для Каждого ВыгруженныйОбъект Из Выгружены Цикл
		ТекстXML = ВыгруженныйОбъект.Текст;
		Если Лев(ТекстXML, 9) = "Структура" Тогда
			Попытка
				СтруктураОбъекта = СтрокаОтчетаВСтруктуру(ТекстXML, 2);
				ВременныйФайл = КаталогВременныхФайлов() + СтруктураОбъекта.ИмяФайлаВыгрузки;
				ДвоичныеДанныеФайла = ПолучитьИзВременногоХранилища(СтруктураОбъекта.АдресФайлаВыгрузки);
				ДвоичныеДанныеФайла.Записать(ВременныйФайл);
				ТекстовыйДокумент = Новый ТекстовыйДокумент();
				ТекстовыйДокумент.Прочитать(ВременныйФайл);
			Исключение
				Отказ = Истина;
				Возврат Кэш.ОбщиеФункции.СбисИсключение(ОписаниеОшибки(), "РаботаСДокументами1С.ПодготовитьВложение");
			КонецПопытки;
			ОписанияОбъектов.Добавить(ПолучитьОписаниеОбъектаОтчета(Кэш, ВыгруженныйОбъект.ИмяФайла, ТекстовыйДокумент.ПолучитьТекст(), ВременныйФайл));
		Иначе
			РезультатЗаписи = СбисЗаписатьФайл_Клиент(Кэш, Новый Структура("Имя, Данные", ВыгруженныйОбъект.ИмяФайла, ТекстXML), Отказ);
			Если Отказ Тогда
				Возврат СбисИсключение(РезультатЗаписи, "РаботаСДокументами1С.ПодготовитьВложение");
			КонецЕсли;
			ОписанияОбъектов.Добавить(ПолучитьОписаниеОбъектаОтчета(Кэш, РезультатЗаписи.Имя, ТекстXML, РезультатЗаписи.ПолноеИмя));
		КонецЕсли;
	КонецЦикла;
	СбисРезультат.Вставить(ВложениеСсылка, Новый Структура("Результат", ОписанияОбъектов));
	Возврат Истина;
КонецФункции

//Получает регламентированный отчет механизмом 1С
//getAttachmentTax
//Возвращает структуру ошибки, если упало формирование, Истина если выгружено, Ложь если файлы не сформированы. Результат заполняется в процессе в переменную СбисРезультат.
&НаКлиенте
Функция ПолучитьВложение_ПФР(Кэш, СбисРезультат, ВложениеСсылка, ДопПараметры, Отказ) Экспорт
	ОшибкаЧтения = Ложь;
	ОписанияОбъектов = Новый Массив;
	ТекстXML = ПолучитьВложение_ПФРСервер(ВложениеСсылка, ДопПараметры, ОшибкаЧтения);
	Если ОшибкаЧтения Тогда
		Отказ = Истина;
		Возврат СбисИсключение(ТекстXML,"РаботаСДокументами1С.ПолучитьВложение_ПФР");
	ИначеЕсли ТекстXML = "" Тогда
		Отказ = Истина;
		Возврат СбисИсключение(,"РаботаСДокументами1С.ПолучитьВложение_ПФР", 100, "Не удалось сформировать текст выгрузки. Проверьте формирование отчета.");
	КонецЕсли;
	Попытка
		ИмяФайла = Вычислить("ПроцедурыПерсонифицированногоУчета.ПолучитьИмяФайлаПФ(ВложениеСсылка, ВложениеСсылка.Год)");
	Исключение
		Попытка
			ИмяФайла = Вычислить("ПроцедурыПерсонифицированногоУчета.ИмяФайлаОбмена(ВложениеСсылка.Организация, ВложениеСсылка.Дата)") + ".xml";
		Исключение
			ИмяФайла = ПолучитьРеквизитМетаданныхОбъекта(ВложениеСсылка, "Синоним") + " №" + ПолучитьРеквизитОбъекта(ВложениеСсылка, "Номер") + " от " + Формат(ПолучитьРеквизитОбъекта(ВложениеСсылка, "Дата"), "ДФ=dd.MM.yyyy");
			ИмяФайла = СтрЗаменить(СтрЗаменить(ИмяФайла, ".", ""),"\","");
		КонецПопытки;
	КонецПопытки;
	ПутьКФайлу = СбисЗаписатьФайл_Клиент(Кэш, Новый Структура("Имя, Данные", ИмяФайла, ТекстXML), Отказ);
	ОписанияОбъектов.Добавить(ПолучитьОписаниеОбъектаОтчета(Кэш, ИмяФайла, ТекстXML, ПутьКФайлу));
	СбисРезультат.Вставить(ВложениеСсылка, Новый Структура("Результат", ОписанияОбъектов));
	Возврат Истина;
КонецФункции

&НаСервере
Функция ПолучитьВложение_ПФРСервер(ВложениеСсылка, ДопПараметры, Отказ)
	Перем ИмяФайла;
	Попытка
		ВложениеОбъект = ВложениеСсылка.ПолучитьОбъект();
		ТекстXML = Вычислить("РегламентированнаяОтчетность.ПолучитьТекстФайла(ВложениеОбъект, Ложь)");
	Исключение
		Отказ = Истина;
		Возврат Новый Структура("code, message,details", 100, "Ошибка получения данных отчета в ПФР", ОписаниеОшибки());
	КонецПопытки;
	Возврат ТекстXML;	
	
КонецФункции

&НаКлиенте
Функция СтрокаОтчетаВСтруктуру(СтрокаРазобрать, НачальнаяПозиция=1)
	Результат = Новый Структура;
	Для СтрСчетчик = НачальнаяПозиция По СтрЧислоСтрок(СтрокаРазобрать) Цикл
		СтрКлючЗначение = СтрЗаменить(СтрПолучитьСтроку(СтрокаРазобрать, СтрСчетчик), ":", Символы.ПС);
		Результат.Вставить(СтрПолучитьСтроку(СтрКлючЗначение, 1), СтрПолучитьСтроку(СтрКлючЗначение, 2));
	КонецЦикла;
	Возврат Результат;
КонецФункции

&НаКлиенте
Функция ПолучитьОписаниеОбъектаОтчета(Кэш, ИмяФайла, СтрокаОтчета, ИмяВременногоФайла)
	Результат = Новый Структура("Тип, Имя, Путь", "file", ИмяФайла, ИмяВременногоФайла);
	Если Не (ИмяВременногоФайла = "") Тогда
		Файл = Новый Файл(ИмяВременногоФайла);
		Результат.Вставить("Размер", Файл.Размер());
	КонецЕсли;
	Возврат Результат;
КонецФункции

