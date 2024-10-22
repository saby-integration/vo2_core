
&НаКлиенте
Функция СформироватьДокументДляГенератора(ПараметрыФормированияВходящие, Кэш) Экспорт
    Перем ТекДокументАдресДоставки;
	
	Док		= ПараметрыФормированияВходящие.Документ;
	Вложение= ПараметрыФормированияВходящие.Вложение;
	
	ТекДокумент = Док.Файл.Документ;
	ТекДокумент.Вставить("ДефНомИспрСФ",  "-");
	ТекДокумент.Вставить("ДефДатаИспрСФ", "-");
	ТекДокумент.Вставить("ПоФактХЖ", 	Вложение.Название);
	ТекДокумент.Вставить("НаимДокОпр", 	ТекДокумент.Название);
	
	//TODO удалить в 24.2100
	//Это не нужно, т.к. стороны должны определяться на стадии ПрочитатьДокумент, а не сгенерировать вложение.
	//Как временное решение, можно восстановить эту логику, но простановка ГП и ГО тут это ошибка
	//Если НЕ ТекДокумент.Свойство("Грузоотправитель") Тогда
	//	ТекДокумент.Вставить("Грузоотправитель", Новый Структура());
	//	Кэш.ОбщиеФункции.сбисСкопироватьСтруктуруНаКлиенте(ТекДокумент.Грузоотправитель, Вложение.Отправитель);
	//КонецЕсли;
	//Если НЕ ТекДокумент.Свойство("Грузополучатель") Тогда
	//	ТекДокумент.Вставить("Грузополучатель", Новый Структура());
	//	Кэш.ОбщиеФункции.сбисСкопироватьСтруктуруНаКлиенте(ТекДокумент.Грузополучатель, Вложение.Получатель);
	//КонецЕсли;
	
	Если ТекДокумент.Свойство("АдресДоставки", ТекДокументАдресДоставки) Тогда
		Если ЗначениеЗаполнено(ТекДокументАдресДоставки) И ТекДокумент.Свойство("Грузополучатель") Тогда
			//Заменяется адрес ГП на адрес доставки. Логика из XSLT.
			АдресСписок = Новый Массив;
			АдресСписок.Добавить(ТекДокумент.АдресДоставки);
			ТекДокумент.Грузополучатель.Вставить("Адрес", АдресСписок);
		КонецЕсли;
		ТекДокумент.Удалить("АдресДоставки");
	КонецЕсли;
	
	Если ФайлДокумент_ОтправительГрузоотправительОнЖе(ТекДокумент) Тогда
		ТекДокумент.Грузоотправитель.Вставить("ОнЖе", "он же");	
	КонецЕсли;
	
	ОшибкаФормирования = Ложь;
	Если ПараметрыФормированияВходящие.Свойство("ФормыПоиска") Тогда
		фрмПараметр = Кэш.ГлавноеОкно.СбисНайтиФормуФункцииСеанса(Кэш, "ЗаполнитьПоДокументПараметр", ПараметрыФормированияВходящие.ФормыПоиска, Новый Структура, ОшибкаФормирования)
	Иначе
		фрмПараметр = ЭтаФорма;
	КонецЕсли; 
	фрмПараметр.ЗаполнитьПоДокументПараметр(Док, Кэш); 
	
	ОшибкаФормирования = Ложь;
	Если ПараметрыФормированияВходящие.Свойство("ФормыПоиска") Тогда
		фрмОснования = Кэш.ГлавноеОкно.СбисНайтиФормуФункцииСеанса(Кэш, "ЗаполнитьПоДокументОснование", ПараметрыФормированияВходящие.ФормыПоиска, Новый Структура, ОшибкаФормирования)
	Иначе
		фрмОснования = ЭтаФорма;
	КонецЕсли;
	фрмОснования.ЗаполнитьПоДокументОснование(Док, Кэш);
	
	СчетчикБезНДС = 0;
	
	Для Каждого ТекСтрока ИЗ ТекДокумент.ТаблДок.СтрТабл Цикл
		ТекСтрока.Вставить("ДефСуммаЦен", 				"");
		ТекСтрока.Вставить("ДефНДС", 					"");
		ТекСтрока.Вставить("ДефЕдКод", 					"");
		ТекСтрока.Вставить("ДефКодСтраныПроизводства", 	"");
		ЗаполнитьПоСтрТаблПараметр(Кэш, ТекСтрока); 
		СформироватьИнфПол(Кэш, ТекСтрока);
		СформироватьСведПрослеж(Кэш, ТекСтрока);
		
		Если ТекСтрока.НДС.Свойство("Ставка") Тогда
			Если ТекСтрока.НДС.Ставка = "без НДС" Тогда
				ТекСтрока.Вставить("БезНДС", ТекСтрока.НДС.Ставка);
				СчетчикБезНДС = СчетчикБезНДС + 1;
			Иначе
				ТекСтрока.Вставить("БезНДС", "");
			КонецЕсли;
		Иначе
			ТекСтрока.Вставить("БезНДС", "");
		КонецЕсли;
		
	КонецЦикла;
	
	Для Каждого ТекСтрока ИЗ ТекДокумент.ТаблДок.ИтогТабл Цикл
		
		Если СчетчикБезНДС = ТекДокумент.ТаблДок.СтрТабл.Количество() Тогда
			ТекСтрока.Вставить("БезНДС", "без НДС");	
		Иначе
			ТекСтрока.Вставить("БезНДС", "");
		КонецЕсли;
		
		ТекСтрока.Вставить("ДефСумма", "");
		ТекСтрока.Вставить("ДефНДС", "");
		
	КонецЦикла;
	
	ОшибкаФормирования = Ложь;
	Если ПараметрыФормированияВходящие.Свойство("ФормыПоиска") Тогда
		фрмОснования = Кэш.ГлавноеОкно.СбисНайтиФормуФункцииСеанса(Кэш, "СформироватьОснование", ПараметрыФормированияВходящие.ФормыПоиска, Новый Структура, ОшибкаФормирования)
	Иначе
		фрмОснования = ЭтаФорма;
	КонецЕсли;
	фрмОснования.СформироватьОснование(Док, Кэш);

	СформироватьПараметры(Док, Кэш);
	
	//Закоментировано в 24.2100, чтобы ПолучитьHTMLПоXML возвращал без подписантов 
	//ТекДокумент.Вставить("Подписант", Новый Структура("ОблПолн", 5));
	
	Возврат Док;
	
КонецФункции

#Область include_core2_ТребуетРефактор_ЗаполнениеПараметровПодстановки  
#КонецОбласти

&НаКлиенте
Процедура ЗаполнитьПоДокументОснование(Док, Кэш) Экспорт
	Перем НомерУстановить, ДатаУстановить;
	
	ТекДокумент = Док.Файл.Документ;

	Если НЕ ТекДокумент.Свойство("Основание") Тогда
		Возврат;	
	КонецЕсли;
	
	мПРД = Новый Массив;
	мСчФ = Новый Массив;
	мПередатДокумОсн = Новый Массив;
	
	СчФ = Новый Структура("Номер, Дата");
	ИспрСчФ = Новый Структура("НомИспрСФ, ДатаИспрСФ, ДефНомИспрСФ, ДефДатаИспрСФ");
	
	Для Каждого ТекСтрока ИЗ ТекДокумент.Основание Цикл
		
		Если	Не	ТекСтрока.Свойство("Номер", НомерУстановить)
			Или		НомерУстановить = Неопределено Тогда
			Продолжить;
		КонецЕсли;
		НомерУстановить = ГенераторПривестиТип(НомерУстановить, "Номер");
		Если ПустаяСтрока(НомерУстановить) Тогда
			Продолжить;
		КонецЕсли;
		
		Если ТекСтрока.Свойство("Тип") Тогда
			Ключ = "Тип";	
		Иначе
			Ключ = "Название";	
		КонецЕсли;
		
		Если		ТекСтрока[Ключ] = "ПРД" Тогда
			мПРД.Добавить(Новый Структура("НомерПРД, ДатаПРД", 
				НомерУстановить, 
				ТекСтрока.Дата));
			
		ИначеЕсли	ТекСтрока[Ключ] = "ДокПодтвОтгр" Тогда
			ТекДокумент.Вставить("ДокПодтвОтгр", Новый Структура());
			ТекДокумент.ДокПодтвОтгр.Вставить("ДатаДокОтгр", ТекСтрока.Дата);
			ТекДокумент.ДокПодтвОтгр.Вставить("НомДокОтгр",  НомерУстановить);
			ТекДокумент.ДокПодтвОтгр.Вставить("НаимДокОтгр", ТекСтрока.НаимДокОтгр);
			
		ИначеЕсли	ТекСтрока[Ключ] = "СчФ" Тогда
			СчФ.Номер	= НомерУстановить;
			СчФ.Дата	= ТекСтрока.Дата;
			
		ИначеЕсли	ТекСтрока[Ключ] = "ИспрСчФ" Тогда
			ИспрСчФ.НомИспрСФ = НомерУстановить;
			ИспрСчФ.ДатаИспрСФ = ТекСтрока.Дата;
			ИспрСчФ.ДефНомИспрСФ = "";
			ИспрСчФ.ДефДатаИспрСФ = "";
			
		ИначеЕсли	ТекСтрока[Ключ] = "ИсхСчФ" Тогда
			мСчФ.Добавить(Новый Структура("Номер, Дата",
				НомерУстановить,
				ТекСтрока.Дата));
			
			ЗаписьПередатДокум = Новый Структура("Номер, Дата, Название");
			ЗаполнитьЗначенияСвойств(ЗаписьПередатДокум, ТекСтрока);
			Если	Ключ = "Название"
				Или	ЗаписьПередатДокум.Название = Неопределено Тогда
				ЗаписьПередатДокум.Название = " ";//Нет названия, пробел для отрисовки пустого названия						
			КонецЕсли;
			мПередатДокумОсн.Добавить(ЗаписьПередатДокум);
			ТекДокумент.Вставить("ПередатДокум", НомерУстановить + " от " + ТекСтрока.Дата);
			
		ИначеЕсли	ТекСтрока[Ключ] = "Сделка"
				Или	Лев(ТекСтрока[Ключ], 5) = "Заказ" Тогда
				
			Если Не ТекДокумент.Свойство("Параметр") Тогда
				ТекДокумент.Вставить("Параметр", Новый Массив);
			КонецЕсли;
			
			Если		ТекСтрока.Свойство("Номер")
				И	Не ПустаяСтрока(НомерУстановить) Тогда
				ТекДокумент.Параметр.Добавить(Новый Структура("Имя, Значение", "ЗаказНомер", НомерУстановить));
			КонецЕсли;
			
			Если		ТекСтрока.Свойство("Дата")
				И	Не	ПустаяСтрока(ТекСтрока.Дата) Тогда
				ТекДокумент.Параметр.Добавить(Новый Структура("Имя, Значение", "ЗаказДата",	ТекСтрока.Дата));
			КонецЕсли;
			
		КонецЕсли;
		
	КонецЦикла;

	Если	Не СчФ.Номер			= Неопределено 
		И	Не СчФ.Дата				= Неопределено 
		И	Не ИспрСчФ.НомИспрСФ	= Неопределено Тогда
		ТекДокумент.Вставить("НомИспрСФ",	  ИспрСчФ.НомИспрСФ);
		ТекДокумент.Вставить("ДатаИспрСФ",    ИспрСчФ.ДатаИспрСФ);
		ТекДокумент.ДефНомИспрСФ	= ИспрСчФ.ДефНомИспрСФ;
		ТекДокумент.ДефДатаИспрСФ	= ИспрСчФ.ДефДатаИспрСФ;
		
		Если ТекДокумент.Свойство("ДокПодтвОтгр") Тогда 
			ТекДокумент.ДокПодтвОтгр.Вставить("ДатаДокОтгр", Счф.Дата);
			ТекДокумент.ДокПодтвОтгр.Вставить("НомДокОтгр",  Счф.Номер);
		КонецЕсли;
	КонецЕсли;
	
	Если мПРД.Количество() <> 0 тогда
		ТекДокумент.Вставить("ПРД", мПРД);	
	КонецЕсли;
	
	Если мСчФ.Количество() <> 0 тогда
		ТекДокумент.Вставить("СчФ", мСчФ);	
	КонецЕсли;
	
	Если мПередатДокумОсн.Количество() <> 0 тогда
		ТекДокумент.Вставить("ПередатДокумОсн", мПередатДокумОсн);	
	КонецЕсли;
	
КонецПроцедуры

//Функция обогащает документ, у которого есть ПредСтрТабл
&НаКлиенте
Функция СформироватьТабличнуюЧастьТабличнаяЧастьДокументаИзменений(ПараметрыФормированияВходящие, Кэш) Экспорт
	Перем ПредСтрТабл;

	ТекДокумент = ПараметрыФормированияВходящие.Документ.Файл.Документ;
	ТекДокумент.ТаблДок.СтрТабл = СформироватьРазностнуюТабличнуюЧастьТабличнаяЧастьДокумента(ТекДокумент.ТаблДок.СтрТабл);	
	ИтогиСоответствие = Новый Соответствие;
	
	ВерсияФорматаПодстановки = ПараметрыФормированияВходящие.Документ.Файл.ВерсияФормата;	
	СбисОбщиеФункции	= Кэш.ТекущийСеанс.Модули.ФункцииДокументов;
	ИмяФормыПоФормату		= "Файл_"	+ СбисОбщиеФункции.СбисЗаменитьНедопустимыеСимволы(ПараметрыФормированияВходящие.Документ.Файл.Формат)
								+ "_"	+ СбисОбщиеФункции.СбисЗаменитьНедопустимыеСимволы(ВерсияФорматаПодстановки);
	СбисФормыПоиска = Новый Массив;
	СбисФормыПоиска.Добавить(ИмяФормыПоФормату);
	Если Не ВерсияФорматаПодстановки = "3.01" Тогда
		СбисФормыПоиска.Добавить("Файл_Шаблон_" + СтрЗаменить(ВерсияФорматаПодстановки, ".", "_"));
	КонецЕсли;
	СбисФормыПоиска.Добавить("Файл_Шаблон"); 
	ПараметрыПримененияПодстановок = Новый Структура;
	ПараметрыПримененияПодстановок.Вставить("ФормыПоиска", СбисФормыПоиска);
	ОшибкаФормирования		= Ложь;
	
	//Обогатить документ параметрами, которые не попадают в формат вложения подстановки, но нужны для более простой обработки
	фрм = Кэш.ГлавноеОкно.СбисНайтиФормуФункцииСеанса(Кэш, "СформироватьДокументДляГенератора", ПараметрыПримененияПодстановок.ФормыПоиска, Новый Структура, ОшибкаФормирования);
	
	Для Каждого ТекСтрока ИЗ ТекДокумент.ТаблДок.СтрТабл Цикл
		фрм.СформироватьПараметрыСтроки(Кэш, ТекСтрока);
		фрм.СформироватьИнфПол(Кэш, ТекСтрока);
		
		Если ТекСтрока.Свойство("ПредСтрТабл", ПредСтрТабл) Тогда
			фрм.СформироватьПараметрыСтроки(Кэш, ПредСтрТабл);
		Иначе
			//Нет узла ПредСтрТабл, значит ничего не менялось
			ПредСтрТабл = ТекСтрока;
		КонецЕсли;
		СформироватьУвеличениеУменьшение(ТекСтрока, ПредСтрТабл, ИтогиСоответствие);
		Если ТекСтрока.Свойство("СведПрослеж") И ПредСтрТабл.Свойство("СведПрослеж") Тогда
			ПрослежТоварРасхождение(ТекСтрока.СведПрослеж, ПредСтрТабл.СведПрослеж);
		КонецЕсли;
	КонецЦикла;
	
	Для Каждого ТекСтрока ИЗ ТекДокумент.ТаблДок.ИтогТабл Цикл
		ЗаполнитьУвеличениеУменьшениеИтоги(ТекСтрока, ИтогиСоответствие);
		ТекСтрока.Удалить("НДС");
		ТекСтрока.Удалить("ПредИтогТабл");
		ТекСтрока.Удалить("Сумма");
		ТекСтрока.Удалить("СуммаБезНал");
	КонецЦикла;
КонецФункции	

&НаКлиенте
Процедура СформироватьОснование(Док, Кэш) Экспорт

	ТекДокумент = Док.Файл.Документ;
	Если НЕ ТекДокумент.Свойство("Основание") Тогда
		Возврат;	
	КонецЕсли;
	
	Исключения = ПолучитьИсключенияОснование();
	ОснованиеМассив = Новый Массив;
	
	Для Каждого ТекСтрока ИЗ ТекДокумент.Основание Цикл
		
		Если ТекСтрока.Свойство("Тип") Тогда
			Ключ = "Тип";	
		Иначе
			Ключ = "Название";	
		КонецЕсли;
		
		Если Исключения.Получить(ТекСтрока[Ключ]) = Истина Тогда
			Продолжить;	
		КонецЕсли;
		
		Если НЕ ЗначениеЗаполнено(ТекСтрока.Название) Тогда
			Продолжить;	
		КонецЕсли;
		
		Если НЕ ТекСтрока.Свойство("Дата") Тогда
			Продолжить;
		КонецЕсли;
		
		Если НЕ ЗначениеЗаполнено(ТекСтрока.Дата) И ТекСтрока.Название <> "-" Тогда
			Продолжить;	
		КонецЕсли; 
		
		Основание = Новый Структура("Номер, Название, Дата");
		Основание.Название 	= ТекСтрока.Название;
		Основание.Номер 	= ТекСтрока.Номер;
		Основание.Дата 		= ТекСтрока.Дата;
		
		ОснованиеМассив.Добавить(Основание);
		
	КонецЦикла;
	
	Если НЕ ОснованиеМассив.Количество() Тогда
		ОснованиеМассив.Добавить(Новый Структура("Название", "Без документа-основания"));
	КонецЕсли;
	
	ТекДокумент.Вставить("Основание", ОснованиеМассив);
	
КонецПроцедуры

&НаКлиенте
Процедура СформироватьПараметры(Док, Кэш) Экспорт
	
	ТекФайл		= Док.Файл;
	ТекДокумент = ТекФайл.Документ;

	Если НЕ ТекДокумент.Свойство("Параметр") Тогда
		Возврат;
	КонецЕсли;
	
	мПараметры = ТекДокумент.Параметр;

	ДобавитьПараметрДокументаПоПути(ТекДокумент, мПараметры, "Получатель.GLN",			"GLNПокуп",			Кэш);
	ДобавитьПараметрДокументаПоПути(ТекДокумент, мПараметры, "Грузополучатель.GLN",		"GLNГрузПолуч",		Кэш);
	ДобавитьПараметрДокументаПоПути(ТекДокумент, мПараметры, "Отправитель.GLN",			"GLNПост",			Кэш);
	ДобавитьПараметрДокументаПоПути(ТекДокумент, мПараметры, "Грузоотправитель.GLN",	"GLNГрузОтпр",		Кэш);

	//Выгрузка наименований для физ.лиц
	ДобавитьПолноеИмяФизЛицаПоПути(ТекДокумент, мПараметры, "Отправитель",		"НаимПост",			Кэш);
	ДобавитьПолноеИмяФизЛицаПоПути(ТекДокумент, мПараметры, "Получатель",		"НаимПокуп",		Кэш);
	ДобавитьПолноеИмяФизЛицаПоПути(ТекДокумент, мПараметры, "Грузоотправитель",	"НаимГрузОтпр",		Кэш);
	ДобавитьПолноеИмяФизЛицаПоПути(ТекДокумент, мПараметры, "Грузополучатель",	"НаимГрузПолуч",	Кэш);

	ДобавитьПараметрДокументаПоПути(ТекФайл,	мПараметры,	"КодФормы",	"ИдВизуализации",	Кэш);
		
	мПараметры = ПолучитьПараметрыБезПустыхЗаписей(Кэш, мПараметры);
	
	Если мПараметры.Количество() <> 0 Тогда
		ТекДокумент.Вставить("Параметры", мПараметры);
	КонецЕсли;
	
КонецПроцедуры

