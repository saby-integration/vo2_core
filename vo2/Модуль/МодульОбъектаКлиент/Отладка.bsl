
&НаКлиенте
Процедура СохранитьОтладочныеДанныеСБИС(ДанныеЗаписать, ДопПараметры=Неопределено) Экспорт
	Перем ПараметрКЗаписи;	
	ОбщиеФункцииДокументов = ГлобальныйКэш.ТекущийСеанс.Модули.ФункцииДокументов;
	Если ДанныеЗаписать.Свойство("XML", ПараметрКЗаписи) Тогда
		Для Каждого ЗаписьПараметра Из ПараметрКЗаписи Цикл
			ШаблонXML = ЗаписьПараметра.Данные;
			Если ЗаписьПараметра.Отказ Тогда
				ШаблонXML = СбисРаботаСJson.ПреобразоватьЗначениеВJson(ШаблонXML);
			КонецЕсли;
			ОшибкаЗаписи	= Ложь;
			сбисПутьЗаписи	= ГлобальныйКэш.Парам.КаталогОтладки;
			Если	ЗаписьПараметра.Свойство("Папка")
				И	ЗначениеЗаполнено(ЗаписьПараметра.Папка) Тогда
				сбисПутьЗаписи = ОбщиеФункцииДокументов.СбисФорматКаталога(сбисПутьЗаписи + ЗаписьПараметра.Папка, ГлобальныйКэш.ПараметрыСистемы.Клиент);
			КонецЕсли;
			РезультатЗаписи = ОбщиеФункцииДокументов.сбисЗаписатьФайл_Клиент(ГлобальныйКэш, Новый Структура("Путь, Имя, Расширение, Данные, Кодировка", сбисПутьЗаписи, ЗаписьПараметра.Имя, "xml", ШаблонXML, "windows-1251"), ОшибкаЗаписи);
			Если ОшибкаЗаписи Тогда
				СообщитьСбисИсключение(РезультатЗаписи);
			КонецЕсли;
		КонецЦикла;
	КонецЕсли;
	Если ДанныеЗаписать.Свойство("XSLT", ПараметрКЗаписи) Тогда
		Для Каждого ЗаписьПараметра Из ПараметрКЗаписи Цикл
			ОшибкаЗаписи	= Ложь;
			сбисПутьЗаписи	= ГлобальныйКэш.Парам.КаталогОтладки;
			Если	ЗаписьПараметра.Свойство("Папка")
				И	ЗначениеЗаполнено(ЗаписьПараметра.Папка) Тогда
				сбисПутьЗаписи = ОбщиеФункцииДокументов.сбисФорматКаталога(сбисПутьЗаписи + ЗаписьПараметра.Папка, ГлобальныйКэш.ПараметрыСистемы.Клиент);
			КонецЕсли;
			РезультатЗаписи = ОбщиеФункцииДокументов.СбисЗаписатьФайл_Клиент(ГлобальныйКэш, Новый Структура("Путь, Имя, Расширение, Данные, Кодировка", сбисПутьЗаписи, ЗаписьПараметра.Имя, "xslt", ЗаписьПараметра.Данные,  КодировкаТекста.UTF8), ОшибкаЗаписи);
			Если ОшибкаЗаписи Тогда
				СообщитьСбисИсключение(РезультатЗаписи);
			КонецЕсли;
		КонецЦикла;
	КонецЕсли;
	Если ДанныеЗаписать.Свойство("Log", ПараметрКЗаписи) Тогда
		СбисИмяМодуля	= Неопределено;
		ОшибкаЗаписи	= Ложь;
		СбисИмяПапкиЛог	= Формат(ТекущаяДата(), "ДФ=dd.MM.yyyy");
		СбисПутьЗаписи	= ОбщиеФункцииДокументов.сбисФорматКаталога(ОбщиеФункцииДокументов.сбисФорматКаталога(ГлобальныйКэш.Парам.КаталогОтладки + "Log", ГлобальныйКэш.ПараметрыСистемы.Клиент) + СбисИмяПапкиЛог, ГлобальныйКэш.ПараметрыСистемы.Клиент);
		//Если Не	ЗаписьПараметра.Свойство("Модуль", СбисИмяМодуля) Тогда
		//	СБисИмяМодуля = "Неизвестно";
		//КонецЕсли;
		ФайлТест = Новый Файл(СбисПутьЗаписи);
		Если	Не ФайлТест.Существует()
			Или	Не ФайлТест.ЭтоКаталог() Тогда 
			Попытка
				СоздатьКаталог(СбисПутьЗаписи);
			Исключение
				ГлобальныйКэш.Парам.РежимОтладки = Ложь;
				СтруктураОшибки = НовыйСбисИсключение(,"МодульОбъектаКлиент.СбисСохранитьОтладочныеДанные", 772, "Ошибка работы с файловой системой", "Ошибка доступа к каталогу записи логов " + СбисПутьЗаписи + ". Детально: " + ИнформацияОбОшибке().Описание);
				СообщитьСбисИсключение(СтруктураОшибки);
				Возврат;
			КонецПопытки;
		КонецЕсли;
	
		СбисФорматЛога = "{Время}{Тип} {Вызов} {Идентификатор}{Сообщение}";
		Для Каждого ЗаписьПараметра Из ПараметрКЗаписи Цикл
			Если ЭтоТипСбис(ЗаписьПараметра, "АсинхроннаяСбисКоманда") Тогда
				Если	ТипЗнч(ЗаписьПараметра.АргументВызова) = Тип("Структура")
					И	ЗаписьПараметра.АргументВызова.Свойство("Метод")
					И	ЗаписьПараметра.АргументВызова.Свойство("ПараметрыМетода") Тогда
					//В команде прописан вызов метода 
					СбисИмяВызова		= ЗаписьПараметра.АргументВызова.Метод;
					ОбъектСообщенияЛога	= ЗаписьПараметра.АргументВызова.ПараметрыМетода;
				Иначе
					СбисИмяВызова		= ЗаписьПараметра.ОбработчикВызова.ИмяПроцедуры;
					ОбъектСообщенияЛога	= ЗаписьПараметра.АргументВызова;
				КонецЕсли;
				Если ЗаписьПараметра.Ответ = Неопределено Тогда
					//Пишется вызов команды
					СбисТипСообщения	= "CALL";
					СбисВремяЛога		= ЗаписьПараметра.ВремяВызова;
				Иначе
					СбисТипСообщения	= ВРег(ЗаписьПараметра.Ответ.Тип);
					ОбъектСообщенияЛога	= ЗаписьПараметра.Ответ.Данные;
					СбисВремяЛога		= ЗаписьПараметра.Ответ.Получено;
				КонецЕсли;	
				СбисИмяМодуля		= ПолучитьЗначениеПараметраСбис("ИнтеграцияИмя");
				СбисИдЛога			=  ЗаписьПараметра.Идентификатор;
			ИначеЕсли ЗаписьПараметра.Свойство("Исключение") Тогда
				СбисИсключение = ЗаписьПараметра.Исключение;
				Попытка
					СбисПоследняяЗаписьСтек = СбисИсключение.stack[0].methodName;
				Исключение
					СбисПоследняяЗаписьСтек	= "МодульОбъектаКлиент.ЗаписьБезСтека";
				КонецПопытки;
				СбисИмяМодуля		= СтрПолучитьСтроку(СтрЗаменить(СбисПоследняяЗаписьСтек, ".", Символы.ПС), 1);
				СбисИмяВызова		= СтрПолучитьСтроку(СтрЗаменить(СбисПоследняяЗаписьСтек, ".", Символы.ПС), 2);
				СбисВремяЛога		= ТекущаяДата();
				ОбъектСообщенияЛога = СбисИсключение;
				СбисТипСообщения	= "ERROR";
				СбисИдЛога			= "";
				Если СбисИсключение.Свойство("code") Тогда
					СбисИдЛога		= СбисИсключение.code;
				КонецЕсли;
			Иначе
				СбисИмяМодуля		= ЗаписьПараметра.Модуль;
				СбисИмяВызова		= ЗаписьПараметра.Вызов;
				СбисВремяЛога		= ЗаписьПараметра.Время;
				ОбъектСообщенияЛога	= ЗаписьПараметра.Сообщение;
				СбисТипСообщения	= ЗаписьПараметра.Тип;
				Если ЗаписьПараметра.Свойство("Идентификатор") Тогда
					СбисИдЛога		= ЗаписьПараметра.Идентификатор;
				Иначе
					СбисИдЛога		= "";
				КонецЕсли;
			КонецЕсли;
			СбисИмяМодуля = СбисИмяМодуля + ".txt";
			СтрокаНаВывод = СтрЗаменить(СтрЗаменить(СтрЗаменить(СбисФорматЛога, 
			"{Время}",		СбисДополнитьСтроку(Формат(СбисВремяЛога, "ДФ=HH:mm:ss"),10)),
			"{Тип}",		СбисДополнитьСтроку(СбисТипСообщения, 15)),
			"{Сообщение}",	СбисРаботаСJSON.ПреобразоватьЗначениеВJSON(ОбъектСообщенияЛога));
			Если СбисИдЛога = "" Тогда
				СтрокаНаВывод = СтрЗаменить(СтрЗаменить(СтрокаНаВывод, 
				"{Вызов}",			СбисДополнитьСтроку(СбисИмяВызова, 70)),
				"{Идентификатор}",	"");
			Иначе
				СтрокаНаВывод = СтрЗаменить(СтрЗаменить(СтрокаНаВывод, 
				"{Вызов}",			СбисДополнитьСтроку(СбисИмяВызова, 40)),
				"{Идентификатор}",	СбисДополнитьСтроку(СбисИдЛога, 40));
			КонецЕсли;
			ТекстДок = Новый ТекстовыйДокумент;
			ФайлТест = Новый Файл(СбисПутьЗаписи + СбисИмяМодуля);
			Если ФайлТест.Существует() Тогда
				ТекстДок.Прочитать(СбисПутьЗаписи + СбисИмяМодуля);
			КонецЕсли;							
			ТекстДок.ДобавитьСтроку(СтрокаНаВывод);
			ТекстДок.Записать(СбисПутьЗаписи + СбисИмяМодуля);
		КонецЦикла;
	КонецЕсли;

КонецПроцедуры

&НаКлиенте
Функция СбисДополнитьСтроку(СтрокаИсх, ДлинаСтрокиДополнить, СимволДополнить = " ")
	СтрокаРезультат = Лев(СтрокаИсх, ДлинаСтрокиДополнить);
	Пока  СтрДлина(СтрокаРезультат) < ДлинаСтрокиДополнить Цикл
		СтрокаРезультат = СтрокаРезультат + СимволДополнить;
	КонецЦикла;
	Возврат СтрокаРезультат;
КонецФункции

