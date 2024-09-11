
&НаКлиенте
Функция СБИС_ВыполнитьДействие(Кэш, document_in, ДопПараметры, Отказ) Экспорт
	Результат = СбисОтправитьИОбработатьКоманду(Кэш, "ExecuteAction2", Новый Структура("document_in", document_in), ДопПараметры, Отказ);
	Если Отказ Тогда
		Возврат Кэш.ОбщиеФункции.сбисИсключение(Результат,  Кэш.СБИС.ПараметрыИнтеграции.ИнтеграцияИмя + ".СБИС_ВыполнитьДействие");
	КонецЕсли;
	Возврат Результат	
КонецФункции

&НаКлиенте
Функция СБИС_ПодготовитьДействие(Кэш, document_in, ДопПараметры, Отказ) Экспорт
	Результат = СбисОтправитьИОбработатьКоманду(Кэш, "PrepareAction", document_in, ДопПараметры, Отказ);
	Если Отказ Тогда
		Возврат Кэш.ОбщиеФункции.сбисИсключение(Результат,  Кэш.СБИС.ПараметрыИнтеграции.ИнтеграцияИмя + ".СБИС_ПодготовитьДействие");
	КонецЕсли;
	Возврат Результат
КонецФункции

// Получает данные файла вложения	
&НаКлиенте
функция СБИС_ПолучитьДанныеФайла(Кэш,Ссылка) экспорт
	ИмяФайла = сбисПолучитьФайл(Кэш, Ссылка);
	
	Если ИмяФайла = Ложь Тогда
		Возврат Ложь;
	КонецЕсли;
	
	ТекстДок = Новый ЧтениеТекста(ИмяФайла);
	СтрокаТекст = СтрЗаменить(НРег(ТекстДок.ПрочитатьСтроку()),"'","""");
	СтрокаКодировка = Кэш.КэшЗначенийИни.КодировкиЧтенияФайлов.ПоУмолчанию.ДляВсех;
	//Проверим кодировки для принудительного чтения.	
	Для Каждого КодировкаДляЧтения Из Кэш.КэшЗначенийИни.КодировкиЧтенияФайлов.Определять Цикл
		ПозицияКодировки = Найти(СтрокаТекст, "encoding");
		Если ПозицияКодировки И Найти(Сред(СтрокаТекст, ПозицияКодировки), КодировкаДляЧтения) Тогда
			СтрокаКодировка = КодировкаДляЧтения;
			Прервать;
		КонецЕсли;
	КонецЦикла;
	//Переоткрываем файл в найденной кодировке
	ТекстДок.Открыть(ИмяФайла,СтрокаКодировка);
	РезультатТекст = ТекстДок.Прочитать();
	Попытка
		УдалитьФайлы(ИмяФайла);
	Исключение
	КонецПопытки;
	
	Если	РезультатТекст = Неопределено
		Или	Лев(РезультатТекст,4)="%PDF" Тогда// для PDF-файла иногда возвращается крокозябра, которая потом вызывает ошибку передачи данных между клиентом и сервером, несмотря на то, что это строка
		РезультатТекст = "";
	КонецЕсли;
	
	Возврат РезультатТекст;
КонецФункции

&НаКлиенте
Функция СБИС_СериализоватьСтрокуВBase64(Кэш, ПараметрыСериализовать, ДопПараметры, Отказ) Экспорт
	Возврат сбисСтрокаВBASE64(ПараметрыСериализовать.Строка);
КонецФункции      

&НаКлиенте
Функция СБИС_СериализоватьФайлВBase64(Кэш, ПараметрыСериализовать, ДопПараметры, Отказ) Экспорт
	Возврат сбисФайлСКлиентаВBASE64(ПараметрыСериализовать.ПолноеИмяФайла);
КонецФункции

&НаКлиенте
Функция СБИС_СохранитьПоСсылкеВФайл(Кэш, ПараметрыФайла, ДопПараметры, Отказ) Экспорт
	ДопПараметрыЗапроса	= Новый Структура("СообщатьПриОшибке, ВернутьОшибку, ЕстьРезультат", Ложь, Истина, Истина);
	ПараметрыЗаписи = Новый Структура("uri_in, filename_in", ПараметрыФайла.Ссылка, ПараметрыФайла.ИмяФайла);
	
	Результат = СбисОтправитьИОбработатьКоманду(Кэш, "LoadDataFromURIToFile2", ПараметрыЗаписи, ДопПараметрыЗапроса, Отказ);
	Если Отказ Тогда 
		Возврат Кэш.ОбщиеФункции.сбисИсключение(Результат,  Кэш.СБИС.ПараметрыИнтеграции.ИнтеграцияИмя + ".СБИС_СохранитьПоСсылкеВФайл");
	КонецЕсли;
	Возврат ПараметрыФайла.ИмяФайла;
КонецФункции

&НаКлиенте
Функция СБИС_СписокИзменений(Кэш, filter, ДопПараметры, Отказ) Экспорт
	ДопПараметрыВызова = Новый Структура("ВернутьОшибку, СообщатьПриОшибке", Истина, Ложь);
	Результат = СбисОтправитьИОбработатьКоманду(Кэш, "ReadChanges", filter, ДопПараметрыВызова, Отказ);
	Если Отказ Тогда
		Результат = Кэш.ОбщиеФункции.СбисИсключение(Результат, Кэш.СБИС.ПараметрыИнтеграции.ИнтеграцияИмя + ".СБИС_СписокИзменений");
	КонецЕсли;
	Возврат Результат;
КонецФункции

&НаКлиенте
Функция СБИС_ТекущаяДата(Кэш, Отказ=Ложь) Экспорт
	Возврат ТекущаяДата();
КонецФункции	
	
&НаКлиенте
Функция СБИС_ИнформацияОКонтрагенте(Кэш, СтруктураКонтрагента, ДопПараметры, Отказ) Экспорт
	Результат = СбисОтправитьИОбработатьКоманду(Кэш, "ReadContragentInfo", СтруктураКонтрагента, ДопПараметры, Отказ);
	Если Отказ Тогда
		Возврат Кэш.ОбщиеФункции.сбисИсключение(Результат,  Кэш.СБИС.ПараметрыИнтеграции.ИнтеграцияИмя + ".СБИС_ИнформацияОКонтрагенте");
	КонецЕсли;
	
	Возврат Результат;
КонецФункции

&НаКлиенте
Функция СБИС_ПолучитьИнформациюОТекущемПользователе(Кэш, param, ДопПараметры, Отказ) Экспорт
	Возврат Новый Структура();
КонецФункции

&НаКлиенте
Функция СБИС_ПолучитьСписокАккаунтов(Кэш, param, ДопПараметры, Отказ) Экспорт
	Возврат Новый Массив();
КонецФункции

&НаКлиенте
Функция СБИС_ПереключитьАккаунт(Кэш, param, ДопПараметры, Отказ) Экспорт
	Возврат "";
КонецФункции

&НаКлиенте
Функция СБИС_ПолучитьПараметрыПакетаДляОткрытияОнлайн(ОписаниеПакета, ДопПараметры) Экспорт	
	
	Возврат Новый Структура("ИдДокумента, Тикет", ОписаниеПакета.ИдДокумента, ""); 
	
КонецФункции

&НаКлиенте
Функция СБИС_ЗаписатьВложение(Кэш, param, ДопПараметры, Отказ) Экспорт
	Результат = сбисОтправитьИОбработатьКоманду(Кэш, "WriteAttachment", param, ДопПараметры, Отказ);
	Если Отказ Тогда
		Возврат Кэш.ОбщиеФункции.сбисИсключение(Результат,  Кэш.СБИС.ПараметрыИнтеграции.ИнтеграцияИмя + ".СБИС_ЗаписатьВложение");
	КонецЕсли;
	Возврат Результат
КонецФункции

&НаКлиенте
Функция АПИ3_ИнитКоннекшен(ПараметрыИнит, ДопПараметрыВызова) Экспорт
	ДопПарметрыВызоваИнтеграции = Новый Структура("ВернутьОшибку, СообщатьПриОшибке", Истина, Ложь);
	Результат = СбисОтправитьИОбработатьКомандуCallIntegrationApi(ДопПараметрыВызова.Кэш, "API3.InitConnection", ПараметрыИнит, ДопПарметрыВызоваИнтеграции, ДопПараметрыВызова.Отказ);
	Если ДопПараметрыВызова.Отказ Тогда
		Возврат ДопПараметрыВызова.Кэш.ОбщиеФункции.сбисИсключение(Результат,  ДопПараметрыВызова.Кэш.СБИС.ПараметрыИнтеграции.ИнтеграцияИмя + ".АПИ3_ИнитКоннекшен");
	КонецЕсли;
	Возврат Результат;
КонецФункции

