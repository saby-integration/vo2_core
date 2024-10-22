
//Процедура длительной операции формирования и загрузки пакетов отчетности
&НаКлиенте
Процедура ЗагрузитьОтчетность(Кэш, ПараметрыЗагрузки) Экспорт
	ГлавноеОкно = Кэш.ГлавноеОкно;
	
	МассивПакетов = Новый Массив;  // Массив пакетов для одной отправки (если в настройках указано отправлять пакеты по n штук)
	
	МестныйКэш = Кэш;
	СбисПараметрыМетода = ПараметрыЗагрузки;
	Если ПараметрыЗагрузки.СписокДокументов.Количество() Тогда 
		ГлавноеОкно.СбисПоказатьСостояние("Формирование комплектов отчентности", ГлавноеОкно,, "(прервать -  Ctrl+Break)");
		ПодключитьОбработчикОжидания("ЗагрузитьСледующийКомплект", 0.1, Истина);
	КонецЕсли;
КонецПроцедуры

// Функция формирует и загружает комплекты отчетности по отмеченным строкам
&НаКлиенте
Процедура ЗагрузитьСледующийКомплект() Экспорт
	Перем ВсегоКомплектов, ИндексКомплекта;
	ЭтаФорма.ОтключитьОбработчикОжидания("ПрерываниеПользователемФормированияДокументов");
	
	ПараметрыЗагрузки	= СбисПараметрыМетода;
	Кэш					= МестныйКэш;
	ГлавноеОкно			= Кэш.ГлавноеОкно;
	ГлавноеОкно.СбисОбработкаПрерывания();
	Отказ = Ложь;
	Если Не ПараметрыЗагрузки.Свойство("Всего", ВсегоКомплектов) Тогда
		ВсегоКомплектов = ПараметрыЗагрузки.СписокДокументов.Количество();
		ПараметрыЗагрузки.Вставить("Всего", ВсегоКомплектов);
	КонецЕсли;
	Если Не ПараметрыЗагрузки.Свойство("Индекс", ИндексКомплекта) Тогда
		ИндексКомплекта = 0;
		ПараметрыЗагрузки.Вставить("Индекс", ИндексКомплекта);
	КонецЕсли;
	ГлавноеОкно.СбисПоказатьСостояние("Формирование комплектов отчентности", ГлавноеОкно, Мин(100, Окр((ИндексКомплекта+1)*100/ВсегоКомплектов)), "(прервать -  Ctrl+Break)");
	
	СтрокаДетализации = Кэш.ОбщиеФункции.РезультатДействия_СформироватьСтрокуДетализации(Кэш);
	СтрокаКомплект = ПараметрыЗагрузки.СписокДокументов[ИндексКомплекта];
	ПолныйКомплект = Кэш.Текущий.Форма.ПодготовитьСтруктуруДокумента(СтрокаКомплект.Значение, Кэш);
	СтрокаДетализации.Название = ПолныйКомплект.Название;
	Если ПолныйКомплект.Свойство("Ошибка") Тогда		
		Кэш.ОбщиеФункции.РезультатДействия_ДобавитьОшибку(Кэш, ПараметрыЗагрузки.РезультатДействия, СтрокаДетализации, ПолныйКомплект.Ошибка);
	Иначе
		РезультатЗагрузки = Кэш.Интеграция.Интеграция_ЗагрузитьКомплект(Кэш, ПолныйКомплект, Новый Структура("ВернутьОшибку, СообщатьПриОшибке", Истина, Ложь), Отказ);
		Если Отказ Тогда
			Кэш.ОбщиеФункции.РезультатДействия_ДобавитьОшибку(Кэш, ПараметрыЗагрузки.РезультатДействия, СтрокаДетализации, РезультатЗагрузки);
		Иначе
			Кэш.ОбщиеФункции.РезультатДействия_ДобавитьСтатусВРезультатПоПакету();
			Кэш.ОбщиеФункции.РезультатДействия_ДобавитьРезультат(Кэш, ПараметрыЗагрузки.РезультатДействия, СтрокаДетализации, РезультатЗагрузки);
		КонецЕсли;
	КонецЕсли;
	
	ЭтаФорма.ПодключитьОбработчикОжидания("ПрерываниеПользователемФормированияДокументов", 0.2, Истина);
	Если ПараметрыЗагрузки.Индекс < ВсегоКомплектов - 1 Тогда
		ПараметрыЗагрузки.Индекс = ПараметрыЗагрузки.Индекс + 1;
		ЭтаФорма.ПодключитьОбработчикОжидания("ЗагрузитьСледующийКомплект", 0.1, Истина);
	Иначе
		Кэш.ОбщиеФункции.СбисВыполнитьОписаниеОповещения(Кэш, ПараметрыЗагрузки.РезультатДействия, ПараметрыЗагрузки.ОбработчикРезультата);
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Функция ПрочитатьДокумент(Кэш,Контекст) Экспорт
	// Функция перебирает мФайлы в файле настроек и для каждого вызывает функцию формирования структуры документа из соответствующей формы Файл_...	
	// Все вложения из состава пакета добавляем в первый пакет, сформированный по строке документов
	// на случай, если по одному из вложений формируется сразу несколько пакетов
	Если Контекст.МассивПакетов.Количество()>0 Тогда
		Контекст.СоставПакета = Контекст.МассивПакетов[0];
	Иначе
		Контекст.Вставить("СоставПакета",Новый Структура);
		Контекст.СоставПакета.Вставить("Вложение",Новый Массив);
	КонецЕсли;
	Контекст.Вставить("ФайлДанные", Новый Структура);
	ВсеВыгрузилось = Истина;     
	Для Каждого Файл Из Контекст.ДокументДанные.мФайл Цикл
		Файл = Файл.Значение;
		Контекст.ФайлДанные = Файл;
		Файл.Файл_Формат = Кэш.ОбщиеФункции.РассчитатьЗначение("Файл_Формат", Файл, Кэш);
		Файл_Формат = Кэш.ОбщиеФункции.сбисЗаменитьНедопустимыеСимволы(Файл.Файл_Формат);
		Файл_ВерсияФормата = Кэш.ОбщиеФункции.сбисЗаменитьНедопустимыеСимволы(Файл.Файл_ВерсияФормата);
		Если Файл_Формат = "Конверт" И Контекст.СоставПакета.Свойство("Конверт") Тогда     // если конверт уже есть, переходим к следующему мФайлу
			Продолжить;
		КонецЕсли;
		Если Файл.Свойство("ФормаФормирования") Тогда
			ФормаФормирования = Файл.ФормаФормирования;
		Иначе
			ФормаФормирования = "Файл_"+Файл_Формат+"_"+Файл_ВерсияФормата;
		КонецЕсли;
		// << alo 3.03
		ОсновнаяФормаФормирования = "Файл_Шаблон" + ?(Файл_ВерсияФормата = "3_01", "", "_" + Файл_ВерсияФормата);
		фрм = Кэш.ГлавноеОкно.сбисНайтиФормуФункции("ПолучитьДанныеИзДокумента1С",ФормаФормирования,ОсновнаяФормаФормирования,Кэш);
		Если фрм = Ложь Тогда
			Если Кэш.Свойство("РезультатОтправки") Тогда
				Кэш.РезультатОтправки.НеСформировано = Кэш.РезультатОтправки.НеСформировано+1;
				Кэш.РезультатОтправки.ОшибкиДоОтправки = Кэш.РезультатОтправки.ОшибкиДоОтправки + 1;
				Кэш.ОбщиеФункции.ДобавитьОшибкуВРезультатОтправки(Кэш, "Документ не сформирован", "Для документа "+строка(Контекст.Документ)+" не найдена форма формирования электронного документа в формате "+Файл_Формат+", версии "+Файл.Файл_ВерсияФормата, Контекст.Документ, 726)
			Иначе
				Сообщить("Для документа "+строка(Контекст.Документ)+" не найдена форма формирования электронного документа в формате "+Файл_Формат+", версии "+Файл.Файл_ВерсияФормата);
			КонецЕсли;	
			Возврат Ложь;
		КонецЕсли;
		Если Не фрм.ПолучитьДанныеИзДокумента1С(Кэш,Контекст) Тогда //если хотябы что-то не выгрузилось - отбой
			ВсеВыгрузилось = Ложь;
		КонецЕсли; 
	КонецЦикла;
	
	Если Контекст.МассивПакетов.Количество()>0 Тогда
		Контекст.МассивПакетов[0] = Контекст.СоставПакета;
	Иначе
		Контекст.МассивПакетов.Вставить(0, Контекст.СоставПакета);
	КонецЕсли;
	
	Возврат ВсеВыгрузилось;
КонецФункции

&НаКлиенте
Функция ПрочитатьТабличнуюЧасть(Кэш,Контекст) Экспорт
	// Функция формирует табличную часть документа
	// Используется при формировании таб части СФ из документов-оснований
	Контекст.Вставить("СписокТЧ", Новый СписокЗначений);  // список ТЧ, чтобы одна и та же таб. часть дважды не попадала в документ
	Для Каждого Файл Из Контекст.ДокументДанные.мФайл Цикл
		Файл = Файл.Значение;
		Контекст.ФайлДанные = Файл;
		Файл.Файл_Формат = Кэш.ОбщиеФункции.РассчитатьЗначение("Файл_Формат", Файл, Кэш);
		Файл_Формат = Кэш.ОбщиеФункции.сбисЗаменитьНедопустимыеСимволы(Файл.Файл_Формат);
		Файл_ВерсияФормата = Кэш.ОбщиеФункции.сбисЗаменитьНедопустимыеСимволы(Файл.Файл_ВерсияФормата);
		Если Файл_Формат = "Конверт" Тогда     // Конверт пропускаем
			Продолжить;
		КонецЕсли;
		Если Файл.Свойство("ФормаФормирования") Тогда
			ФормаФормирования = Файл.ФормаФормирования;
		Иначе
			ФормаФормирования = "Файл_"+Файл_Формат+"_"+Файл_ВерсияФормата;
		КонецЕсли;    
		
		фрм = Кэш.ГлавноеОкно.сбисНайтиФормуФункции("ПолучитьТабличнуюЧастьДокумента1С",ФормаФормирования,"Файл_Шаблон",Кэш);	
		фрм.ПолучитьТабличнуюЧастьДокумента1С(Кэш,Контекст)
	КонецЦикла;
	Контекст.Удалить("СписокТЧ");
	Возврат Истина;
КонецФункции		

// Загрузка документов
&НаКлиенте
Функция ЗагрузитьДокументыВ1С(Кэш, СписокОтмеченныхДокументов, ДополнительныеПараметры=Неопределено) Экспорт
	// Загружает отмеченные пакеты документов в 1С	
	
	//Режим 0 Перезаполнить
	//Режим 1 Создать новые
	//Режим 2 Отменить
	//Режим 3 Загружать ещё не загруженные
	РежимДокументов = 3;
	//Режим 0 Документ не загружается, если нет сопоставления.
	//Режим 1 Для несопоставленных позиций создавать карточки номенклатуры и контрагента.
	//Режим 2 В табличную часть загружать только сопоставленную номенклатуру.                             
	РежимНоменклатуры = 1;
	Если Не ДополнительныеПараметры = Неопределено Тогда
		Если ДополнительныеПараметры.Свойство("РежимДокументов") Тогда
			РежимДокументов = ДополнительныеПараметры.РежимДокументов;
		КонецЕсли;
		Если ДополнительныеПараметры.Свойство("РежимНоменклатуры") Тогда
			РежимНоменклатуры = ДополнительныеПараметры.РежимНоменклатуры;
		КонецЕсли;
	КонецЕсли;
	
	Обновлять = Ложь;
	МестныйКэш = Кэш;
	ГлавноеОкно = Кэш.ГлавноеОкно;
	Всего = СписокОтмеченныхДокументов.Количество();
	Загружено = 0;
	сч = 0;
	
	ПараметрыРезультатаДействия = Новый Структура("ПредставлениеОперации, ФормаВызова, ПрикладнаяСтатистика",
		"ЗагрузкаДокумента",
		"Документ_Шаблон",
		МодульОбъектаКлиент().НовыйПрикладнаяСтатистика());
	РезультатДействия = МестныйКэш.ОбщиеФункции.РезультатДействия_Получить(МестныйКэш, ПараметрыРезультатаДействия);
	МестныйКэш.Вставить("РезультатДействия", РезультатДействия);
	ПараметрыЗагрузки = Новый Структура("РежимДокументов, РежимНоменклатуры", РежимДокументов, РежимНоменклатуры);
	//Если необходимо внести какие-то изменения, ответив на вопрос, то массово не делаем. Только на форме просмотра.
	ДополнительныеПараметрыЗагрузки = Новый Структура("ОтветНаИзмененияВИсходныйДокумент, ФормаВызова", Неопределено, "Документ_Шаблон");
	Для Каждого Строка из СписокОтмеченныхДокументов Цикл
		сч = сч + 1;
		сбисПоказатьСостояние("Загрузка документов",ГлавноеОкно,Мин(100,Окр(сч*100/Всего)));
		МассивПакетов = Кэш.Текущий.Форма.ПодготовитьСтруктуруДокумента(Строка.Значение, Кэш);
		МестныйКэш.ОбщиеФункции.РезультатДействия_ДобавитьВремя(Кэш, РезультатДействия, "ПолучениеДанных");
		Для Каждого Пакет Из МассивПакетов Цикл
			ПолныйСоставПакета = МестныйКэш.ОбщиеФункции.РазобратьСтруктуруДокументаСбис(Пакет, Кэш);
			ПолныйСоставПакета = МестныйКэш.ОбщиеФункции.ЗаполнитьРеквизитыОснованийПакета(ПолныйСоставПакета, МестныйКэш); // пока SDK не возвращает дату, номер док. основания
			МестныйКэш.ОбщиеФункции.РезультатДействия_ДобавитьВремя(Кэш, РезультатДействия, "Подготовка");
			ПолныйСоставПакета.Вставить("НоменклатураСопоставлена",Истина);
			СписокВложений = Новый Массив;
			Для Каждого Вложение Из ПолныйСоставПакета.Вложение Цикл
				ДанныеДляЗагрузки = МестныйКэш.ОбщиеФункции.ЗаполнитьДанныеДляЗагрузкиПоУмолчанию(Кэш,ПолныйСоставПакета,Вложение,ДополнительныеПараметрыЗагрузки);
				ВложениеДобавить = Новый СписокЗначений;
				ВложениеДобавить.Добавить(Вложение);
				ДанныеДляЗагрузки.Вставить("Вложение", ВложениеДобавить);
				ДанныеДляЗагрузки.Вставить("Отмечен", Истина);
				СписокВложений.Добавить(ДанныеДляЗагрузки);
			КонецЦикла;
			Если Не СписокВложений.Количество() Тогда 
				Продолжить; 
			КонецЕсли;
			//Здесь не используем возвращаемый результат, так как он в созданном результате действия. Его и возвращаем в конце.
			МестныйКэш.ОбщиеФункции.СоздатьПерезаполнитьДокументы(Кэш,ПолныйСоставПакета,СписокВложений,ПараметрыЗагрузки,ДополнительныеПараметрыЗагрузки);
		КонецЦикла;
	КонецЦикла;
	сбисСпрятатьСостояние(ГлавноеОкно);
	Возврат	РезультатДействия;	
КонецФункции

// Функция заполняет документ 1С данными из файла, проставляет идентификаторы и статус документа СБИС	
&НаКлиенте
Функция СоздатьДокумент(Кэш, Вложение, Ини, СоставПакета, МассивОснований, Документ1С = Неопределено) Экспорт
	Перем ИскатьДокумент1С, СохранитьСопоставление;
	
	МестныйКэш		= Кэш;
	ГлавноеОкно		= Кэш.ГлавноеОкно;
	СтруктураФайла	= Вложение.СтруктураФайла;
	
	Если КэшДляСервера = Неопределено Тогда
		КэшДляСервера = Кэш.ОбщиеФункции.КэшДляСервера(Кэш);
	КонецЕсли;
	
	СписокДокументов			= Новый СписокЗначений;
	СтруктураДанныхДокумента	= Новый Структура;
	
	//AU таким костыльным способом передаём строку детализации внуть метода.
	ДанныеДетализации = Кэш.ОбщиеФункции.РезультатДействия_ИзвлечьВременныеДанные(Кэш);
	Кэш.ОбщиеФункции.сбисСкопироватьСтруктуруНаКлиенте(СтруктураДанныхДокумента, Ини);
	ТипДокумента = СообщитьИмяРеквизита(Ини.Документ.Значение);
	
	Если Не ДанныеДетализации.Свойство("ИскатьДокумент1С", ИскатьДокумент1С) Тогда
		ИскатьДокумент1С =	Документ1С = Неопределено
						И	МодульОбъектаКлиент().ПолучитьЗначениеПараметраСбис("СопоставлятьПередЗагрузкой");
	КонецЕсли;
	
	Если ИскатьДокумент1С Тогда
		
		РеквизитыДляПоиска = Новый Структура;
		РеквизитыДляПоиска.Вставить("НашаОрганизация",	СоставПакета.НашаОрганизация);
		РеквизитыДляПоиска.Вставить("Контрагент",		?(СоставПакета.Свойство("Контрагент"), СоставПакета.Контрагент, Неопределено));
		РеквизитыДляПоиска.Вставить("Дата",				МодульОбъектаКлиент().ДатаИзСтроки(Вложение.Дата));
		РеквизитыДляПоиска.Вставить("Номер",			Вложение.Номер);
		
		ФормаНайтиДок = ГлавноеОкно.сбисНайтиФормуФункции("НайтиПодходящиеДокументыОпределенногоТипа", "РаботаСДокументами1С",, Кэш);
		ФормаНайтиДок.НайтиПодходящиеДокументыОпределенногоТипа(СписокДокументов, Ини, Кэш.Ини, Кэш.Парам, РеквизитыДляПоиска);
		
	КонецЕсли;

	ЗаполнитьДанныеДокумента1С = Истина;
	
	Если СписокДокументов.Количество() = 1 Тогда
		
		Документ1С = СписокДокументов[0].Значение; 
		
		// Если документ уже загружен в рамках текущего пакета, то надо дополнить его данными текущего вложения
		// (например, загружаем акт и накладную в одно поступление)
		ДокументНайденВМассивеОснований = Ложь;
		
		Для Каждого ОснованиеСтруктура Из МассивОснований Цикл
			
			ДокОснование = ОснованиеСтруктура;
			
			Если ТипЗнч(ОснованиеСтруктура) = Тип("Структура") Тогда
				
				ДокОснование = ДокОснование.ДокОснование;
				
			КонецЕсли;
			
			Если ДокОснование = Документ1С Тогда
				
				ДокументНайденВМассивеОснований = Истина;
				Прервать;    
				
			КонецЕсли;  
			
		КонецЦикла;
		
		Если Не ДокументНайденВМассивеОснований Тогда
			
			ЗаполнитьДанныеДокумента1С	= Ложь;
			СтрокаСообщения				= "Найден соответствующий документ 1С " + строка(Документ1С);
			
			// AU если нет результата действия, то всё остаётся работать по старому алгоритму.
			// Если есть, то анализ и демонстрация сообщений будет проводиться на уровне вызова.
			Если ДанныеДетализации.ЗаполнитьДетализацию Тогда
				
				ПараметыЗаполнения = Новый Структура("Ссылка, Тип, Состояние, Сообщение", Документ1С, "Документ." + ТипДокумента, "Найден.", СтрокаСообщения);
				Кэш.ОбщиеФункции.РезультатДействия_ДобавитьВРасшифровку(Кэш, "ЗагрузкаДокумента", ДанныеДетализации.СтрокаДетализации, ПараметыЗаполнения);
				
			Иначе
				
				Сообщить("Для документа " + Вложение.Название + " н" + Сред(СтрокаСообщения, 1));
				
			КонецЕсли; 
			
		КонецЕсли;

	КонецЕсли;
	
	Если ЗаполнитьДанныеДокумента1С Тогда
		
		Документ1С = ЗаполнитьДанныеДокумента1С(Кэш,
												СтруктураДанныхДокумента,
												СтруктураФайла,
												МассивОснований,
												СоставПакета,
												Вложение,
												Документ1С,
												ДанныеДетализации);	
												
	КонецЕсли;
	
	Если Документ1С = Неопределено Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	// Если явно не указано - сохранять ли сопоставление
	Если Не ДанныеДетализации.Свойство("СохранитьСопоставление", СохранитьСопоставление) Тогда
		СохранитьСопоставление = Истина; 
	
		Для Каждого ОснованиеСтруктура Из МассивОснований Цикл
			
			Если ТипЗнч(ОснованиеСтруктура) = Тип("Структура") Тогда
				ДокОснование = ОснованиеСтруктура.ДокОснование;
			Иначе
				ДокОснование = ОснованиеСтруктура;
			КонецЕсли; 
			
			Если ДокОснование = Документ1С Тогда
				
				СохранитьСопоставление = Ложь;
				Прервать; 
				
			КонецЕсли; 
			
		КонецЦикла;
		
		СохранитьСопоставление =	СохранитьСопоставление
							И Не	РассчитатьЗначение("СохранитьСопоставление", Новый Структура("Ини", СтруктураДанныхДокумента)) = Ложь;
							
	КонецЕсли;
	
	// Если документ уже загружен по текущему пакету, то не перепривязываем его к новому вложению
	// (иначе будут проблемы при повторной загрузке)
	Если СохранитьСопоставление Тогда
		
		СбисОписаниеОбъекта = Новый Структура("Тип, Ключ, Значение", "ДокументШаблон.СтруктураСвойств", Вложение.Идентификатор);
		СтруктураСвойств = Кэш.ОбщиеФункции.СбисПолучитьЗначениеРассчитанногоОбъекта(Кэш, СбисОписаниеОбъекта);
		Кэш.ОбщиеФункции.СбисОчиститьЗначениеРассчитанногоОбъекта(Кэш, СбисОписаниеОбъекта);
		
		ПараметрыЗаписать = Новый Структура("Режим, СоставПакета, Документ1С", "Сопоставление", СоставПакета, Документ1С);
		Если ЗначениеЗаполнено(СтруктураСвойств) Тогда
			ПараметрыЗаписать.Вставить("СтруктураСвойств", СтруктураСвойств);
		КонецЕсли;
		МодульОбъектаКлиент().ВложениеСБИС_Записать(Вложение, ПараметрыЗаписать);
		
	КонецЕсли;
	
	// ВААл. Записываем в прикладную статистику факт создания/перезаписи документа 1С.
	// Спилить по https://dev.saby.ru/opendoc.html?guid=dd2e9551-cb7a-418e-9d34-032d93a8c6e1&client=3
	ЗаписьПрикладнойСтатистики = МодульОбъектаКлиент().НовыйЗаписьПрикладнойСтатистики(Вложение.Тип + " - " + ТипДокумента, "Загрузка документов");
	МодульОбъектаКлиент().ПрикладнаяСтатистика_Добавить(Кэш.РезультатДействия.ПрикладнаяСтатистика, ЗаписьПрикладнойСтатистики);
	
	Возврат Документ1С;
	
КонецФункции

// Функция заполняет структуру объекта 1С по файлу настроек
//ДопПараметры - структура, может содержать соответствие обработчика, который будет вызываться для определенного узла
&НаКлиенте
Функция СбисЗаполнитьСтруктуруОбъекта(ОписаниеОбъекта, ПараметрыЗаполнения) Экспорт
	Перем Обработчики, ИниОбхода;
	Кэш			= ПараметрыЗаполнения.Кэш;
	СбисКонтекст= ПараметрыЗаполнения.Контекст;
	
	КонтекстДляКлиента = Новый Структура("Переменные, Ини, ДанныеИсточник", Новый Структура);
	ЗаполнитьЗначенияСвойств(КонтекстДляКлиента, СбисКонтекст);
	КонтекстДляКлиента.Вставить("ИмяОбъекта",					ОписаниеОбъекта.Ключ);
	Если СбисКонтекст.Свойство("СопоставлениеДанныеКлючиИни") Тогда
	    КонтекстДляКлиента.Вставить("СопоставлениеДанныеКлючиИни",	СбисКонтекст.СопоставлениеДанныеКлючиИни);
	КонецЕсли;
	КонтекстДляКлиента.Вставить("ДанныеРезультат",				Новый Структура("Документ", ОписаниеОбъекта.Значение));
	Если СбисКонтекст.Свойство("ДанныеИсточникЛокальные") Тогда
		КонтекстДляКлиента.Вставить("ДанныеИсточникЛокальные",	СбисКонтекст.ДанныеИсточникЛокальные);
	КонецЕсли;
	
	
	АргументыВызова = Новый Структура("Кэш, Контекст, Обработчики, ДополнительныеПараметры", Кэш, КонтекстДляКлиента);
	//Обработчики для возможности выноса особенностей обработки определенных узлов в другие формы.
	//Вынос обработчика в ВФК на свой страх и риск! Стабильное АПИ не гарантируется!
	Если Не ПараметрыЗаполнения.Свойство("Обработчики", АргументыВызова.Обработчики) Тогда
		АргументыВызова.Обработчики = Новый Структура;
	КонецЕсли;
	Если Не ПараметрыЗаполнения.Свойство("ДополнительныеПараметры", АргументыВызова.ДополнительныеПараметры) Тогда
		АргументыВызова.ПараметрыЗаполнения = Новый Структура;
	КонецЕсли;
	
	//Если не указана ини с объектом, по которой считаем, то считаем ини контекста. 
	//Для необходимости заполнения по конкретным узлам из ини, минуя прочие.
	Если Не ОписаниеОбъекта.Свойство("Ини", ИниОбхода) Тогда
		ИниОбхода = КонтекстДляКлиента.Ини;
	КонецЕсли;
	
	//Обработка узлов
	Для Каждого Элемент Из ИниОбхода Цикл
		Обработчик_УзелИни(Новый Структура("Ключ, Значение", Элемент.Ключ, КонтекстДляКлиента.Ини[Элемент.Ключ]), АргументыВызова);
	КонецЦикла;
	
	//Дорасчёт на сервере
	КонтекстДляСервера = Новый Структура("Переменные, Ини", КонтекстДляКлиента.Переменные);
	ЗаполнитьЗначенияСвойств(КонтекстДляСервера, КонтекстДляКлиента);
	
	АргументыРассчитать = Новый Структура("Контекст, ИниОбхода", КонтекстДляСервера, ИниОбхода);
	
	РезультатЗаполнить = Новый Структура("Ключ, Значение", КонтекстДляКлиента.ИмяОбъекта, КонтекстДляКлиента.ДанныеРезультат.Документ, ИниОбхода);
	#Если ТолстыйКлиентОбычноеПриложение Тогда
		ЗаполнитьСтруктуруОбъектаНаСервере(РезультатЗаполнить, АргументыРассчитать);
	#Иначе
		ЗаполнитьСтруктуруОбъектаДляВызоваСервера(РезультатЗаполнить, АргументыРассчитать);
	#КонецЕсли
	Возврат РезультатЗаполнить;
КонецФункции

&НаСервере
Процедура ЗаполнитьСтруктуруОбъектаНаСервере(ОписаниеОбъекта, Знач ПараметрыЗаполнения) Экспорт
	КонтекстСервера = ПараметрыЗаполнения.Контекст;
	КонтекстСервера.Вставить("ДанныеРезультат",	Новый Структура(ОписаниеОбъекта.Ключ, ОписаниеОбъекта.Значение));
	Если Не КонтекстСервера.Свойство("ДополнительныеПараметры") Тогда
		КонтекстСервера.Вставить("ДополнительныеПараметры", Новый Структура);
	КонецЕсли;
	АргументыРассчитать = Новый Структура("Контекст", КонтекстСервера);
	Для Каждого Элемент Из ПараметрыЗаполнения.ИниОбхода Цикл
		Обработчик_УзелИниСервер(Новый Структура("Ключ, Значение", Элемент.Ключ, КонтекстСервера.Ини[Элемент.Ключ]), АргументыРассчитать);
	КонецЦикла;
КонецПроцедуры

//Для того, чтобы для УФ параметры передавались по значению, чтобы ускорить вызов сервера
Процедура ЗаполнитьСтруктуруОбъектаДляВызоваСервера(ОписаниеОбъекта, Знач ПараметрыЗаполнения) Экспорт
	ЗаполнитьСтруктуруОбъектаНаСервере(ОписаниеОбъекта, ПараметрыЗаполнения); 
КонецПроцедуры

// Функция заполняет структуру документа 1С по файлу настроек
//ДопПараметры - структура, может содержать соответствие обработчика, который будет вызываться для определенного узла
&НаКлиенте
Функция ЗаполнитьДаннымиСтруктурыФайлаСтруктуруДокумента(Кэш, СтруктураФайла, Ини, ДокОбъект, МассивОснований, СоставПакета, Вложение, ДопПараметры=Неопределено) Экспорт
	Перем Обработчики;
	
	МестныйКэш = Кэш;
	
	Если КэшДляСервера = Неопределено Тогда
		
		КэшДляСервера = Кэш.ОбщиеФункции.КэшДляСервера(Кэш);
		
	КонецЕсли;                 
	
	Если Вложение.Свойство("ВходящийКонтекст") Тогда 
		
		Ини.Вставить("ВходящийКонтекст", Вложение.ВходящийКонтекст);  
		
	КонецЕсли;
	
	//Для быстрого копирования строк соберём ключи шапки.
	КлючиИниВерхнегоУровня = "";									
	Для Каждого Элемент Из Ини Цикл
		Если Элемент.Ключ = "мТаблДок" Тогда
			Продолжить;
		КонецЕсли;
		КлючиИниВерхнегоУровня = КлючиИниВерхнегоУровня + Элемент.Ключ + ",";
	КонецЦикла;
	КлючиИниВерхнегоУровня = СтрЗаменить(КлючиИниВерхнегоУровня, "мТаблДок,", "");
	Если Прав(КлючиИниВерхнегоУровня, 1) = "," Тогда
		КлючиИниВерхнегоУровня = Сред(КлючиИниВерхнегоУровня, 0, СтрДлина(КлючиИниВерхнегоУровня) - 1);
	КонецЕсли;
	
	Если Вложение.Свойство("КлассыСопоставленияНоменклатур")
		И СтруктураФайла.Свойство("Документ") Тогда
		СтруктураФайла.Документ.ТаблДок.СтрТабл = Вложение.ТаблДок;
	ИначеЕсли Вложение.Свойство("КлассыСопоставленияНоменклатур")
		И СтруктураФайла.Свойство("Файл") Тогда
		СтруктураФайла.Файл.Документ.ТаблДок.СтрТабл = Вложение.ТаблДок;
	КонецЕсли;
	
	// Соответствие описывает, в какие поля в контексте должны заполняться данные от инишки, вида [Документ].Реквизит
	СоответствиеДанныеКлюч = Новый Соответствие;
	СоответствиеДанныеКлюч.Вставить("Документ",					"ДанныеРезультат.Документ");
	СоответствиеДанныеКлюч.Вставить("Документ_РучныеПравки",	"РучныеПравки.Документ");
	
	РучныеПравки = Новый Структура("Документ", МодульОбъектаКлиент().ВложениеСБИС_Получить(Вложение, "СтруктураРучныхПравок"));
	
	//рефактор
	КонтекстДляКлиента	= Новый Структура(
	"Ини, ДанныеИсточник, ДанныеРезультат,ИмяОбъекта, Переменные, Вложение, 
	|СоставПакета, ИниКонфигурация, МассивОснований, Ключи");
	
	КонтекстДляКлиента.Ини				= Ини;
	КонтекстДляКлиента.ДанныеИсточник	= СтруктураФайла;
	КонтекстДляКлиента.ДанныеРезультат	= Новый Структура("Документ", ДокОбъект);
	КонтекстДляКлиента.ИмяОбъекта		= "Документ";
	КонтекстДляКлиента.Вложение			= Вложение;
	КонтекстДляКлиента.СоставПакета		= СоставПакета;
	КонтекстДляКлиента.ИниКонфигурация	= Кэш.Ини.Конфигурация;
	КонтекстДляКлиента.МассивОснований	= МассивОснований;
	КонтекстДляКлиента.Переменные		= Новый Структура("СоздаватьШтрихкодыНоменклатуры", Кэш.Парам.СоздаватьШтрихкодыНоменклатуры);
	КонтекстДляКлиента.Ключи			= Новый Структура("Шапка", КлючиИниВерхнегоУровня);
	
	КонтекстДляКлиента.Вставить("СопоставлениеДанныеКлючиИни",	СоответствиеДанныеКлюч);
	КонтекстДляКлиента.Вставить("РучныеПравки",					РучныеПравки);
	
	// Структура "особых" обработчиков для узлов на клиенте для возможности выноса определенных узлов в другие формы по типу документа.
	// Вынос обработчика в ВФК на свой страх и риск! Стабильное АПИ не гарантируется!
	Если ДопПараметры = Неопределено Тогда
		СтруктураДопПараметров = Новый Структура;
	Иначе
		СтруктураДопПараметров = ДопПараметры;
	КонецЕсли;
	
	Если Не СтруктураДопПараметров.Свойство("Режим") Тогда
		СтруктураДопПараметров.Вставить("Режим", "Полный");
	КонецЕсли;
	
	Обработчики = СтруктураОбработчиковЗаполнения(СтруктураДопПараметров);
	
	АргументыВызова = Новый Структура("Кэш, Контекст, Обработчики, ДополнительныеПараметры", Кэш, КонтекстДляКлиента, Обработчики, СтруктураДопПараметров);
	Для Каждого КлючИЗначение Из Ини Цикл
		
		Обработчик_УзелИни(КлючИЗначение, АргументыВызова);
		
	КонецЦикла;	
	КонтекстДляСервера = Новый Структура("СтруктураФайла, ТаблДок, Ини, Переменные, СопоставлениеДанныеКлючиИни", КонтекстДляКлиента.ДанныеИсточник);
	ЗаполнитьЗначенияСвойств(КонтекстДляСервера, КонтекстДляКлиента);
	
	РезультатЗаполнить = КонтекстДляКлиента.ДанныеРезультат;
	ЗаполнитьДаннымиСтруктурыФайлаСтруктуруДокументаНаСервере(РезультатЗаполнить, КонтекстДляСервера);
	//После всех пертрубаций восстановим связь с переменными
	ДокОбъект		= РезультатЗаполнить.Документ;
	МассивОснований	= КонтекстДляКлиента.МассивОснований;

	Если КонтекстДляСервера.Переменные.Свойство("СоздаватьНоменклатуру") Тогда
		СоздаватьНоменклатуру = КонтекстДляСервера.Переменные.СоздаватьНоменклатуру;  
	Иначе
		СоздаватьНоменклатуру = МодульОбъектаКлиент().ПолучитьЗначениеПараметраСбис("СпособЗагрузки") = 1;
	КонецЕсли; 
	
	МодульОбъектаКлиент().ВложениеСБИС_Заполнить(Вложение, СоздаватьНоменклатуру, "СоздаватьНоменклатуру");
	
	Возврат Неопределено;
КонецФункции

&НаКлиенте
Функция СтруктураОбработчиковЗаполнения(СтруктураДопПараметров) Экспорт
	
	Обработчики = Новый Структура;
	Обработчики.Вставить("мСторона",			Новый Структура("Метод, Модуль",	"Обработчик_мСторона",				ЭтаФорма));
	Обработчики.Вставить("мТаблДок", 			Новый Структура("Метод, Модуль",	"Обработчик_мТаблДок",				ЭтаФорма));
	Обработчики.Вставить("мОснование",			Новый Структура("Метод, Модуль",	"Обработчик_мОснование",			ЭтаФорма));
	Обработчики.Вставить("мПараметрыДокумента",	Новый Структура("Метод, Модуль",	"Обработчик_мПараметрыДокумента",	ЭтаФорма));
	
	Если СтруктураДопПараметров.Свойство("Обработчики") Тогда
		
		Для Каждого КлючИЗначениеОбрабтчик Из СтруктураДопПараметров.Обработчики Цикл
			
			Обработчики.Вставить(КлючИЗначениеОбрабтчик.Ключ, КлючИЗначениеОбрабтчик.Значение);
			
		КонецЦикла;	
			
	КонецЕсли;
	
	Возврат Обработчики;

КонецФункции

