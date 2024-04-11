
////////////////////////////////////////////////////
/////////////Обработка XML конвертеров//////////////
////////////////////////////////////////////////////

//Функция применяет XSLT к указанному XML
&НаКлиенте
Функция сбисПрименитьXSLT(Кэш, ШаблонXML, ИмяXSLT, ДопПараметры, Отказ) Экспорт
	ШаблонXSLT = Неопределено;
	Если Не Кэш.Xslt.Свойство(ИмяXSLT, ШаблонXSLT) Тогда
		Если Кэш.Парам.РежимОтладки Тогда
			сбисНазваниеПапки = Неопределено;
			Если Не ДопПараметры.Свойство("Название", сбисНазваниеПапки) Тогда
				сбисНазваниеПапки = "";
			КонецЕсли;
			лОтладочныеДанные = Новый Структура("XML", Новый Массив);
			лЗаписьXML = Новый Структура("Отказ, Данные, Имя, Папка", Ложь, ШаблонXML, ИмяXSLT, сбисНазваниеПапки);
			лОтладочныеДанные.XML.Добавить(лЗаписьXML);
			сбисСохранитьОтладочныеДанные(Кэш, лОтладочныеДанные, Неопределено);
		КонецЕсли;
		Возврат ШаблонXML;
	КонецЕсли;
	
	Попытка
		РезультатПреобразования = сбисПреобразоватьШаблон(ШаблонXML, ШаблонXSLT, ИмяXSLT, Кэш.СовместимостьМетодов);
	Исключение
		Отказ = Истина;
		РезультатПреобразования = сбисИсключение(, "ОбщиеФункции.сбисПрименитьXSLT", 770, "Ошибка XSLT", ОписаниеОшибки(),
		Новый Структура("ИмяXSLT, СовместимостьМетодов", ИмяXSLT, Кэш.СовместимостьМетодов));
	КонецПопытки;
	Если Кэш.Парам.РежимОтладки Тогда
		сбисНазваниеПапки = Неопределено;
		Если Не ДопПараметры.Свойство("Название", сбисНазваниеПапки) Тогда
			сбисНазваниеПапки = "";
		КонецЕсли;
		лОтладочныеДанные = Новый Структура("XML,XSLT", Новый Массив, Новый Массив);
		лЗаписьXML = Новый Структура("Отказ, Данные, Имя, Папка", Ложь, ШаблонXSLT, ИмяXSLT, сбисНазваниеПапки);
		лОтладочныеДанные.XSLT.Добавить(лЗаписьXML);
		
		лЗаписьXML = Новый Структура("Отказ, Данные, Имя, Папка", Ложь, ШаблонXML, ИмяXSLT + "_origin", сбисНазваниеПапки);
		лОтладочныеДанные.XML.Добавить(лЗаписьXML);
		лЗаписьXML = Новый Структура("Отказ, Данные, Имя, Папка", Отказ, РезультатПреобразования, ИмяXSLT, сбисНазваниеПапки);
		лОтладочныеДанные.XML.Добавить(лЗаписьXML);
		сбисСохранитьОтладочныеДанные(Кэш, лОтладочныеДанные, Неопределено);
	КонецЕсли;
	
	Возврат РезультатПреобразования;
	
КонецФункции

//Функция делает преобразование структуры документа к XML и ищет подходящий xslt. Вызывает преобразование, если есть
&НаКлиенте
Функция сбисПолучитьXMLФайлаИзСтруктуры(Кэш, Вложение, Отказ=Ложь) Экспорт
	
	ИмяXSLT					= сбисИмяXSLTДляВложения(Кэш, Вложение.СтруктураФайла.Файл, Вложение);
	ИмяXSLTФайлИмя			= "ФайлИмя_"+ИмяXSLT;
	
	сбисДопПараметры		= Новый Структура;
	сбисДопПараметры.Вставить("ИмяXSLTФайлИмя",ИмяXSLTФайлИмя);
	Если Вложение.Свойство("Название") Тогда
		сбисДопПараметры.Вставить("Название", Вложение.Название);
	КонецЕсли;
	
	РезультатПреобразования = сбисПолучитьXMLФайлаИзСтруктурыПоИмениXSLT_Клиент(Кэш, Вложение.СтруктураФайла, ИмяXSLT, сбисДопПараметры, Отказ);
	Если Отказ Тогда
		РезультатПреобразования = сбисИсключение(РезультатПреобразования, "ОбщиеФункции.сбисПолучитьXMLФайлаИзСтруктуры");
		Кэш.ГлавноеОкно.сбисСообщитьОбОшибке(Кэш, РезультатПреобразования);
		Возврат Неопределено;
	КонецЕсли;
	Возврат РезультатПреобразования;
КонецФункции

&НаКлиенте
Функция сбисПолучитьXMLФайлаИзСтруктурыПоИмениXSLT_Клиент(Кэш, СтруктураФайла, ИмяXSLT, сбисДополнительныеПараметры, Отказ) Экспорт
	XSLTПреобразование	= Неопределено;
	ЕстьXSLT =		ЗначениеЗаполнено(ИмяXSLT)
				И	Кэш.XSLT.Свойство(ИмяXSLT, XSLTПреобразование);
	
	//KES МОТП ИСМП Имя файла через xslt -->
	XSLTПреобразованиеФайлИмя = Неопределено;
	ЕстьXSLTФайлИмя = сбисДополнительныеПараметры.Свойство("ИмяXSLTФайлИмя") 
					И ЗначениеЗаполнено(сбисДополнительныеПараметры.ИмяXSLTФайлИмя)
					И Кэш.XSLT.Свойство(сбисДополнительныеПараметры.ИмяXSLTФайлИмя,XSLTПреобразованиеФайлИмя);
	
	Если ЕстьXSLTФайлИмя Тогда
		сбисДополнительныеПараметры.Вставить("ШаблонXSLTФайлИмя",XSLTПреобразованиеФайлИмя);
	КонецЕсли;
	//KES <--
	
	Если Не сбисДополнительныеПараметры.Свойство("ПреобразованиеXSL") Тогда
		сбисДополнительныеПараметры.Вставить("ПреобразованиеXSL", Кэш.СовместимостьМетодов.ПреобразованиеXSL);
	КонецЕсли;
	
	//KES МОТП ИСМП Имя файла через xslt -->
	РезультатПреобразованияСтруктура = сбисПолучитьXMLФайлаИзСтруктурыПоИмениXSLT_Сервер(СтруктураФайла, XSLTПреобразование, ИмяXSLT, сбисДополнительныеПараметры, Отказ);
	Если ТипЗнч(РезультатПреобразованияСтруктура) = Тип("Структура") Тогда
		РезультатПреобразования = РезультатПреобразованияСтруктура.РезультатПреобразования;
		Если РезультатПреобразованияСтруктура.Свойство("ИмяФайла") И СтруктураФайла.Свойство("Файл") Тогда
			СтруктураФайла.Файл.Вставить("Имя",РезультатПреобразованияСтруктура.ИмяФайла);
		КонецЕсли;
	Иначе 
		РезультатПреобразования = РезультатПреобразованияСтруктура;
	КонецЕсли;
	//KES <--
	
	
	Если Отказ Тогда
		РезультатПреобразования = сбисИсключение(РезультатПреобразования, "ОбщиеФункции.сбисПолучитьXMLФайлаИзСтруктурыПоИмениXSLT_Сервер");
		РезультатПреобразования = сбисИсключение(РезультатПреобразования, "ОбщиеФункции.сбисПолучитьXMLФайлаИзСтруктурыПоИмениXSLT_Клиент");
	КонецЕсли;
	Если Кэш.Парам.РежимОтладки Тогда//В режиме отладки запишем данные по XML в выбранный каталог
		лОтладочныеДанные	= Новый Структура("XML,XSLT", Новый Массив, Новый Массив);
		сбисНазваниеПапки	= сбисФорматКаталога("Выгрузка", Кэш.ПараметрыСистемы.Клиент);
		Если сбисДополнительныеПараметры.Свойство("Название") Тогда
			сбисНазваниеПапки = сбисНазваниеПапки + сбисДополнительныеПараметры.Название;
		КонецЕсли;
		
		Если ЕстьXSLT Тогда
			лЗаписьXML = Новый Структура("Отказ, Данные, Имя, Папка", Ложь, XSLTПреобразование, ИмяXSLT, сбисНазваниеПапки);
			лОтладочныеДанные.XSLT.Добавить(лЗаписьXML);
			
			лЗаписьXML = Новый Структура("Отказ, Данные, Имя, Папка", Ложь, "", ИмяXSLT + "_origin", сбисНазваниеПапки);
			лЗаписьXML.Данные = сбисПреобразоватьДокументВXML(СтруктураФайла, Кэш.СовместимостьМетодов, лЗаписьXML.Отказ);
			лОтладочныеДанные.XML.Добавить(лЗаписьXML);
			лЗаписьXML = Новый Структура("Отказ, Данные, Имя, Папка", Отказ, РезультатПреобразования, ИмяXSLT, сбисНазваниеПапки);
			лОтладочныеДанные.XML.Добавить(лЗаписьXML);
		Иначе
			лЗаписьXML = Новый Структура("Отказ, Данные, Имя, Папка", Отказ, РезультатПреобразования, Строка(ИмяXSLT) + "_origin", сбисНазваниеПапки);
			лОтладочныеДанные.XML.Добавить(лЗаписьXML);
		КонецЕсли;
		сбисСохранитьОтладочныеДанные(Кэш, лОтладочныеДанные, Неопределено);
	КонецЕсли;
	Возврат РезультатПреобразования;
КонецФункции

&НаСервереБезКонтекста
Функция сбисПолучитьXMLФайлаИзСтруктурыПоИмениXSLT_Сервер(Знач СтруктураФайла, Знач ШаблонXSLT, Знач ИмяXSLT, Знач сбисДополнительныеПараметры, Отказ) Экспорт
	ШаблонXML = сбисПреобразоватьДокументВXML(СтруктураФайла, сбисДополнительныеПараметры, Отказ);
	Если	Отказ
		Или	ШаблонXSLT = Неопределено Тогда 
		Возврат  Новый Структура("РезультатПреобразования",ШаблонXML);
	КонецЕсли;
	
	//KES МОТП ИСМП применить к ШаблонXML-->
	Попытка
		XSLTПреобразованиеФайлИмя = Неопределено;
		//основной xslt
		РезультатПреобразования = сбисПреобразоватьШаблон(ШаблонXML, ШаблонXSLT, ИмяXSLT, сбисДополнительныеПараметры);
	Исключение
		Отказ = Истина;
		РезультатПреобразования = Новый Структура("code,message,details", 770, "Ошибка XSLT", ОписаниеОшибки());
		Возврат Новый Структура("РезультатПреобразования",РезультатПреобразования);
	КонецПопытки;
	
	ИмяФайла = Неопределено;
	Если  сбисДополнительныеПараметры.Свойство("ШаблонXSLTФайлИмя") И ЗначениеЗаполнено(сбисДополнительныеПараметры.ШаблонXSLTФайлИмя) Тогда
		Попытка
			//xslt на Имя
			сбисДополнительныеПараметры.Вставить("output","text");
			ИмяФайла = сбисПреобразоватьШаблон(РезультатПреобразования, сбисДополнительныеПараметры.ШаблонXSLTФайлИмя, сбисДополнительныеПараметры.ИмяXSLTФайлИмя, сбисДополнительныеПараметры);
		Исключение
			Отказ = Истина;
			РезультатПреобразования = Новый Структура("code,message,details", 770, "Ошибка XSLT", ОписаниеОшибки());
			Возврат Новый Структура("РезультатПреобразования",РезультатПреобразования);
		КонецПопытки;
	ИначеЕсли СтруктураФайла.Свойство("Файл") И СтруктураФайла.Файл.Свойство("Имя") Тогда 
		ИмяФайла = СтруктураФайла.Файл.Имя;
	КонецЕсли;
	
	Возврат Новый Структура("РезультатПреобразования,ИмяФайла",РезультатПреобразования,ИмяФайла);
	//<--KES МОТП ИСМП применить к ШаблонXML
КонецФункции

//Функция Получает Имя XSLT для указанного вложения
&НаКлиенте
Функция сбисИмяXSLTДляВложения(Кэш, СтруктураФайла, сбисДополнительныеПараметры) Экспорт 
	
	Файл_Формат			= сбисЗаменитьНедопустимыеСимволы(СтруктураФайла.Формат);
	Файл_ВерсияФормата	= сбисЗаменитьНедопустимыеСимволы(СтруктураФайла.ВерсияФормата);
	
	ПодТип = Неопределено;
	
	Если	Не сбисДополнительныеПараметры.Свойство("ПодТип", ПодТип)
		Или	Не ЗначениеЗаполнено(ПодТип) Тогда
		ПодТип = сбисПодтипПоУмолчанию(Файл_Формат);// на случай, если используется пользовательская настройка без указания подтипа вложения
	КонецЕсли;	
	ИмяXSLT = СбисФорматСтроки(Файл_Формат + "_" + ПодТип + "_" + Файл_ВерсияФормата, "КлючСтруктуры");
	
	Если сбисДополнительныеПараметры.Свойство("Получатель") Тогда
		РасширениеXSLT = сбисРасширениеXSLTПолучателя(сбисДополнительныеПараметры.Получатель);
		Если ЗначениеЗаполнено(РасширениеXSLT) Тогда 
			ИмяXSLT = ИмяXSLT + "_" + РасширениеXSLT;
		КонецЕсли;
	КонецЕсли;
	Возврат ИмяXSLT;
	
КонецФункции

&НаКлиенте
Функция сбисРасширениеXSLTПолучателя(сбисПолучатель) Экспорт 
	
	ПараметрыXSLT = сбисПолучатель;
	Если	ТипЗнч(ПараметрыXSLT) = Тип("Структура")
		И	ПараметрыXSLT.Свойство("Параметр", ПараметрыXSLT) Тогда
		Для Каждого ПараметрXSLT Из ПараметрыXSLT Цикл
			ПараметрИмя		= Неопределено;
			ПараметрЗначение= Неопределено;
			Если	Не ПараметрXSLT.Свойство("Имя",			ПараметрИмя)
				Или	Не ПараметрXSLT.Свойство("Значение",	ПараметрЗначение) Тогда
				Продолжить;
			КонецЕсли;
			Если ПараметрИмя = "СБИС_КодXSLT" Тогда
				Возврат ПараметрЗначение;
			КонецЕсли
		КонецЦикла;
	КонецЕсли;
	Возврат "";
	
КонецФункции

//Функция применяет шаблон xslt в выбранному XML в контексте сервера
&НаСервереБезКонтекста
Функция сбисПреобразоватьШаблон(Знач ШаблонXML, Знач ШаблонXSLT, Знач ИмяXSLT, Знач ДополнительныеПараметры) Экспорт
	Результат = Неопределено;
	ПреобразованиеXSL = Новый ПреобразованиеXSL;
	
	Если ДополнительныеПараметры.ПреобразованиеXSL.ПреобразоватьИзСтроки Тогда
		ПреобразованиеXSL.ЗагрузитьТаблицуСтилейXSLИзСтроки(ШаблонXSLT);
		Результат = ПреобразованиеXSL.ПреобразоватьИзСтроки(ШаблонXML);
	Иначе
		//Для старых платформ остаётся через запись и чтение из файла, так как проблема с кодировкой строки
		ПреобразованиеXSL.ЗагрузитьИзСтроки(ШаблонXSLT);
		
		ИсхФайл = Новый ТекстовыйДокумент;
		ИсхФайл.УстановитьТекст(ШаблонXML);
		ИмяИсходногоФайла = КаталогВременныхФайлов() + ИмяXSLT + "_origin.xml";
		ИсхФайл.Записать(ИмяИсходногоФайла, "windows-1251");
		Если ДополнительныеПараметры.Свойство("output") И ДополнительныеПараметры.output = "text" Тогда
			Результат = ПреобразованиеXSL.ПреобразоватьИзФайла(ИмяИсходногоФайла);
		Иначе
			XML = Новый ЗаписьXML();
			XML.УстановитьСтроку("windows-1251");
			ПреобразованиеXSL.ПреобразоватьИзФайла(ИмяИсходногоФайла, XML);
			Результат = XML.Закрыть();
		КонецЕсли;
	КонецЕсли;
	Возврат Результат;
КонецФункции

//Функция формирует строку xml на основании структуры документа	
&НаСервереБезКонтекста
Функция сбисПреобразоватьДокументВXML(Знач Док, Знач ДополнительныеПараметры, Отказ) Экспорт
	
	ОбъектXML = Новый ЗаписьXML;
	Если ДополнительныеПараметры.Свойство("Кодировка") Тогда
		ОбъектXML.УстановитьСтроку(ДополнительныеПараметры.Кодировка);
	Иначе	
		ОбъектXML.УстановитьСтроку("windows-1251");
	КонецЕсли;
	ОбъектXML.ЗаписатьОбъявлениеXML();
	Попытка
		Если	ДополнительныеПараметры.Свойство("СПростымиЭлементами")
			И	ДополнительныеПараметры.СПростымиЭлементами Тогда
			ЗаписатьСтруктуруВXMLСПростымиЭлементами(ОбъектXML, Док);
		Иначе
			ЗаписатьСтруктуруВXML(ОбъектXML, Док);
		КонецЕсли;
	Исключение
		Отказ = Истина;
		ОбъектXML = Неопределено;
		ОписаниеОшибки = ИнформацияОбОшибке().Описание;
		Возврат Новый Структура("code, message, details", 766, "Ошибка при конвертации", СтрЗаменить(ОписаниеОшибки, "%Заменить%", ""));
	КонецПопытки;
	Возврат ОбъектXML.Закрыть();
	
КонецФункции

//Процедура рекурсивно заполняет ЗаписьXML на основании структуры
&НаСервереБезКонтекста
Процедура ЗаписатьСтруктуруВXML(ОбъектXML, Знач СтруктураДокумента) Экспорт
	// Сначала обходим базовые атрибуты (простые узлы)
	Для Каждого Элемент Из СтруктураДокумента Цикл
		ТипЗначенияЭлемент = ТипЗнч(Элемент.Значение);
		Если ТипЗначенияЭлемент = Тип("Структура") ИЛИ ТипЗначенияЭлемент = Тип("Массив") Тогда
			Продолжить;
		КонецЕсли;
		Если		ТипЗначенияЭлемент = Тип("Строка") Тогда
			ЗначениеВXML = СокрЛП(Элемент.Значение);
		ИначеЕсли	ТипЗначенияЭлемент = Тип("Число") Тогда
			ЗначениеВXML = Формат(Элемент.Значение,"ЧРД=.; ЧГ=0");
		ИначеЕсли	ТипЗначенияЭлемент = Тип("Дата") Тогда
			ЗначениеВXML = Строка(Элемент.Значение);			
		Иначе//неопознанный тип данных
			ЗначениеВXML = Строка(Элемент.Значение);
		КонецЕсли;
		Если Не ЗначениеЗаполнено(ЗначениеВXML) Тогда
			Продолжить;
		КонецЕсли;
		Попытка
			ОбъектXML.ЗаписатьАтрибут(Элемент.Ключ, ЗначениеВXML);
		Исключение
			ВызватьИсключение("Ошибка обработки узла %Заменить%" + Элемент.Ключ + "=" + ЗначениеВXML + ". Детально: " + ОписаниеОшибки());
		КонецПопытки;
	КонецЦикла;

	// Затем обходим сложные узлы
	Для Каждого Элемент Из СтруктураДокумента Цикл
		ТипЗначенияЭлемент = ТипЗнч(Элемент.Значение);
		Если НЕ (ТипЗначенияЭлемент = Тип("Структура") ИЛИ ТипЗначенияЭлемент = Тип("Массив")) Тогда
			Продолжить;
		КонецЕсли;
		Если	ТипЗначенияЭлемент = Тип("Структура") Тогда
			ОбъектXML.ЗаписатьНачалоЭлемента(Элемент.Ключ);	
			Попытка
				ЗаписатьСтруктуруВXML(ОбъектXML, Элемент.Значение);
			Исключение//Укажем точное место, где произошла ошибка
				ОписаниеОшибки = ИнформацияОбОшибке().Описание;
				ВызватьИсключение(СтрЗаменить(ОписаниеОшибки, "%Заменить%", "%Заменить%" + Элемент.Ключ + "."));
			КонецПопытки;
			ОбъектXML.ЗаписатьКонецЭлемента();
			Продолжить;
		ИначеЕсли	ТипЗначенияЭлемент = Тип("Массив") Тогда
			Для Каждого ЭлементМассива Из Элемент.Значение Цикл
				Если ТипЗнч(ЭлементМассива) = Тип("Структура") Тогда
					ОбъектXML.ЗаписатьНачалоЭлемента(Элемент.Ключ);	
					Попытка
						ЗаписатьСтруктуруВXML(ОбъектXML, ЭлементМассива);
					Исключение//Укажем точное место, где произошла ошибка
						ОписаниеОшибки = ИнформацияОбОшибке().Описание;
						ВызватьИсключение(СтрЗаменить(ОписаниеОшибки, "%Заменить%", "%Заменить%" + Элемент.Ключ + "."));
					КонецПопытки;
					ОбъектXML.ЗаписатьКонецЭлемента();
				КонецЕсли;
			КонецЦикла;
			Продолжить;			
		КонецЕсли;
		Если Не ЗначениеЗаполнено(ЗначениеВXML) Тогда
			Продолжить;
		КонецЕсли;
		Попытка
			ОбъектXML.ЗаписатьАтрибут(Элемент.Ключ, ЗначениеВXML);
		Исключение
			ВызватьИсключение("Ошибка обработки узла %Заменить%" + Элемент.Ключ + "=" + ЗначениеВXML + ". Детально: " + ОписаниеОшибки());
		КонецПопытки;
	КонецЦикла;
КонецПроцедуры

//Процедура рекурсивно заполняет ЗаписьXML на основании структуры (xml с простыми элементами. Для записи атрибутов - ключ Атрибуты)
&НаСервереБезКонтекста
Процедура ЗаписатьСтруктуруВXMLСПростымиЭлементами(ОбъектXML, Знач СтруктураДокумента) Экспорт
	Для Каждого Элемент Из СтруктураДокумента Цикл
		Если ТипЗнч(Элемент.Значение) = Тип("Строка") Тогда
			ЗначениеВXML = СокрЛП(Элемент.Значение);
			Если Элемент.Ключ = "ЗначениеУзла" Тогда
				Попытка
					ОбъектXML.ЗаписатьТекст(ЗначениеВXML);
				Исключение
					ВызватьИсключение("Ошибка обработки узла %Заменить%" + Элемент.Ключ + "=" + ЗначениеВXML + ". Детально: " + ОписаниеОшибки());
				КонецПопытки;
				Продолжить;
			КонецЕсли;
		ИначеЕсли ТипЗнч(Элемент.Значение) = Тип("Число") Тогда
			ЗначениеВXML = Формат(Элемент.Значение,"ЧРД=.; ЧГ=0");
		ИначеЕсли ТипЗнч(Элемент.Значение) = Тип("Дата") Тогда
			ЗначениеВXML = Формат(Элемент.Значение,"ДФ=""дд.ММ.гггг ЧЧ.мм.сс""");
		ИначеЕсли Элемент.Значение = Неопределено И Элемент.Ключ <> "ЗначениеУзла" Тогда
			ЗначениеВXML = "";
		ИначеЕсли ТипЗнч(Элемент.Значение) = Тип("Структура") Тогда
			Если Элемент.Ключ = "Атрибуты" Тогда
				Для Каждого Атрибут Из Элемент.Значение Цикл
					ЗначениеАтрибута = СокрЛП(Атрибут.Значение);
					Если Не ЗначениеЗаполнено(ЗначениеАтрибута) Тогда
						Продолжить;
					КонецЕсли;		 
					Попытка
						ОбъектXML.ЗаписатьАтрибут(Атрибут.Ключ, ЗначениеАтрибута);
					Исключение
						ВызватьИсключение("Ошибка обработки узла %Заменить%Атрибуты." + Атрибут.Ключ + "=" + ЗначениеАтрибута + ". Детально: " + ОписаниеОшибки());
					КонецПопытки;
				КонецЦикла;
				Продолжить;
			КонецЕсли;
			Попытка
				ОбъектXML.ЗаписатьНачалоЭлемента(Элемент.Ключ);	
				ЗаписатьСтруктуруВXMLСПростымиЭлементами(ОбъектXML, Элемент.Значение);
				ОбъектXML.ЗаписатьКонецЭлемента();
			Исключение//Укажем точное место, где произошла ошибка
				ОписаниеОшибки = ИнформацияОбОшибке().Описание;
				ВызватьИсключение(СтрЗаменить(ОписаниеОшибки, "%Заменить%", "%Заменить%" + Элемент.Ключ + "."));
			КонецПопытки;
			Продолжить;
		ИначеЕсли ТипЗнч(Элемент.Значение) = Тип("Массив") Тогда
			Для сИндексМассива = 0 По Элемент.Значение.Количество()-1 Цикл
				Попытка
					ОбъектXML.ЗаписатьНачалоЭлемента(Элемент.Ключ);	
					ЗаписатьСтруктуруВXMLСПростымиЭлементами(ОбъектXML, Элемент.Значение[сИндексМассива]);
					ОбъектXML.ЗаписатьКонецЭлемента();
				Исключение//Укажем точное место, где произошла ошибка
					ОписаниеОшибки = ИнформацияОбОшибке().Описание;
					ВызватьИсключение(СтрЗаменить(ОписаниеОшибки, "%Заменить%", "%Заменить%" + Элемент.Ключ + "[" + сИндексМассива +"]."));
				КонецПопытки;
			КонецЦикла;
			Продолжить;
		Иначе
			Продолжить;
		КонецЕсли;
		Попытка
			ОбъектXML.ЗаписатьНачалоЭлемента(Элемент.Ключ);
			ОбъектXML.ЗаписатьТекст(ЗначениеВXML);
			ОбъектXML.ЗаписатьКонецЭлемента();
		Исключение
			ВызватьИсключение("Ошибка обработки узла %Заменить%" + Элемент.Ключ + "=" + ЗначениеВXML + ". Детально: " + ОписаниеОшибки());
		КонецПопытки;
	КонецЦикла
КонецПроцедуры

&НаСервереБезКонтекста
Функция ПолучитьXMLСПростымиЭлементами(Док, кодировка = "windows-1251") Экспорт
	// функция формирует строку xml на основании структуры	(xml без атрибутов, с простыми элементами)
	ОбъектXML = Новый ЗаписьXML;
	ОбъектXML.УстановитьСтроку(кодировка);
	ОбъектXML.ЗаписатьОбъявлениеXML();
	Попытка
		ЗаписатьСтруктуруВXMLСПростымиЭлементами(ОбъектXML,Док);
	Исключение
		ВызватьИсключение(СтрЗаменить(ИнформацияОбОшибке().Описание, "%Заменить%", ""));
	КонецПопытки;
	СтрXML = ОбъектXML.Закрыть();
	Возврат СтрXML;
КонецФункции

