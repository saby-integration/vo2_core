
&НаКлиенте
Процедура ВызватьОбработчикКнопки(ПараметрыОбработчикаКнопки, ДопПараметры=Неопределено) Экспорт
	//Найдем действие, которое требуется выполнить при нажатии.
	Попытка
		РазделКнопки = ПолучитьМенюТекущегоРаздела(); 
	Исключение
		ВызватьСбисИсключение(ИнформацияОбОшибке(), "МодульОбъектКлиент.ВызватьОбработчикКнопки");
	КонецПопытки;
	
	Для Каждого СбисКнопка Из РазделКнопки Цикл
		Если Не СбисКнопка.ИмяКнопки = ПараметрыОбработчикаКнопки.Имя Тогда 
			Продолжить;
		КонецЕсли;
		фрм = ГлавноеОкно.СбисНайтиФормуФункции(СбисКнопка.МетодАктивации, "РаботаСДокументами1С", "ФормаГлавноеОкно");
		Если фрм = Ложь Тогда
			ВызватьСбисИсключение(, "МодульОбъектКлиент.ВызватьОбработчикКнопки",,"Не удалось найти обработчик метода " + ПараметрыОбработчикаКнопки.Имя);
		Иначе
			ВыполнитьСбисОписаниеОповещения(ГлавноеОкно.Кэш, НовыйСбисОписаниеОповещения(сбисКнопка.МетодАктивации, фрм));
		КонецЕсли;
		Возврат;
	КонецЦикла;
	ВызватьСбисИсключение(, "МодульОбъектКлиент.ВызватьОбработчикКнопки",,"Не удалось найти обработчик метода " + ПараметрыОбработчикаКнопки.Имя);
КонецПроцедуры

&НаКлиенте
Функция ПолучитьМенюТекущегоРаздела() Экспорт
	
    Перем ИмяТекущийРаздел, ЗначениеТекущийРаздел;
	
	Кэш = ГлавноеОкно.Кэш;
	Если		Не	Кэш.Свойство("Разделы") Тогда
		ВызватьСбисИсключение(,"МодульОбъектаКлиент.ПолучитьМенюТекущегоРаздела", 779, , "Не определена структура разделов.");
	ИначеЕсли	Кэш.Текущий = Неопределено Тогда
		ВызватьСбисИсключение(,"МодульОбъектаКлиент.ПолучитьМенюТекущегоРаздела", 779, , "Не определён текущий раздел.");
	ИначеЕсли	Не	Кэш.Разделы.Свойство("р" + Кэш.Текущий.Раздел, ИмяТекущийРаздел) Тогда
		ВызватьСбисИсключение(,"МодульОбъектаКлиент.ПолучитьМенюТекущегоРаздела", 779, , "Не удалось определить раздел.");
	ИначеЕсли	Не Кэш.МенюРазделов.Свойство(ИмяТекущийРаздел, ЗначениеТекущийРаздел) Тогда
		ВызватьСбисИсключение(,"МодульОбъектаКлиент.ПолучитьМенюТекущегоРаздела", 779, , "В меню разделов не найден основной раздел.");
	ИначеЕсли	Не ЗначениеТекущийРаздел.Свойство(Кэш.Текущий.Имя, ЗначениеТекущийРаздел) Тогда
		ВызватьСбисИсключение(,"МодульОбъектаКлиент.ПолучитьМенюТекущегоРаздела", 779, , "В меню разделов не найден текущий раздел.");
	КонецЕсли;
	Возврат ЗначениеТекущийРаздел;
	
КонецФункции

// Функция описывает структуру элементов формы настроек, видимость которых меняется в зависимости от СО и переопределяется на форме интеграции в функции ВидимостьНастроек()
// 
// Возвращаемое значение: Структура Ключ		- Имя элемента формы
//   -                              Значение	- Булево, значение видимости
//
&НаКлиенте
Функция ВидимостьНастроекПоУмолчанию() Экспорт
	
	ВидимостьНастроек = Новый Структура;
	ВидимостьНастроек.Вставить("ИспользоватьНовуюОтправку",		Истина);
	ВидимостьНастроек.Вставить("ИспользоватьГенератор",			Ложь);
	ВидимостьНастроек.Вставить("ВремяОжиданияОтвета",			Ложь);
	ВидимостьНастроек.Вставить("НастройкаЭП",					Ложь); 
	
	Возврат ВидимостьНастроек;
	
КонецФункции

// Функция описывает список доступных типов для метода СБИС.СписокДокументов https://sbis.ru/help/integration/catalog/guide#1
// 
// Возвращаемое значение: СписокЗначений
//
&НаКлиенте
Функция ФильтрТипыДокументовСписок() Экспорт

	ФильтрТипыДокументовСписок = Новый СписокЗначений;
	ФильтрТипыДокументовСписок.Добавить("ЭДОНакл",				"Накладные");
    ФильтрТипыДокументовСписок.Добавить("АктВР",				"Акты (услуги, работы, права)");
    ФильтрТипыДокументовСписок.Добавить("СчФктр,УпдСчфДоп",		"Счета-фактуры (вкл.в составе УПД)");
    ФильтрТипыДокументовСписок.Добавить("УпдДоп",				"Передаточные документы");
    ФильтрТипыДокументовСписок.Добавить("счФактКор,УкдКсчфДис",	"Счета-фактуры корректировочные (вкл. в составе УКД)");
	ФильтрТипыДокументовСписок.Добавить("УкдДис",				"УКД");
    ФильтрТипыДокументовСписок.Добавить("АктСвер",				"Акты сверки");
    ФильтрТипыДокументовСписок.Добавить("Договор",				"Договоры");
    ФильтрТипыДокументовСписок.Добавить("ЭДОСч",				"Счета");
	ФильтрТипыДокументовСписок.Добавить("АктПриемки",			"Акты о приемке");
	ФильтрТипыДокументовСписок.Добавить("Заказ",				"Заказы поставщикам");
 	ФильтрТипыДокументовСписок.СортироватьПоПредставлению();
	
	Возврат ФильтрТипыДокументовСписок;
	
КонецФункции

// Функция - формирует фильтр для реестровых методов Онлайна.
//
// Параметры:
//  ПараметрыФильтраВходящие - Структура, Форма - объект, содержащий поля фильтров, одноименные главному окну
//  ДопПараметры			 - Структура	 - 
//		ДопПоля		- Строка - расширение метода.
//		ДопФильтры	- Структура - результат функции ПараметраФильтраДляСобытий от реестра.
// 
// Возвращаемое значение:
//  Структура - фильтр для реестров онлайна https://sbis.ru/help/integration/api/all_methods/list_doc; https://sbis.ru/help/integration/api/all_methods/events_doc
//
&НаКлиенте
Функция	СформироватьФильтрДляРеестраОнлайна(ПараметрыФильтраВходящие, ДопПараметры) Экспорт
	
	ЗначениеФильтраСобытий = Новый Структура; 
	ЗначениеФильтраСобытий.Вставить("ДопПоля", "Этап,Лицо2");
	//Этап			- получить этапы в реестре
	//Лицо2			- получить Грузополучатель
	//Расширение	- получить объект расширения документа, где можно взять статусы гос. систем.
	
	Если ПолучитьЗначениеПараметраСбис("СтатусыВГосСистеме") Тогда
		ЗначениеФильтраСобытий.ДопПоля = ЗначениеФильтраСобытий.ДопПоля + ",Расширение";
	КонецЕсли;
	
	Если ДопПараметры.Свойство("ДопПоля") Тогда
		ЗначениеФильтраСобытий.ДопПоля = ЗначениеФильтраСобытий.ДопПоля + ДопПараметры.ДопПоля;
	КонецЕсли;
	
	ДанныеПоФильтрам = Новый Структура(
	"ЗаписейНаСтранице, ФильтрСтраница
	|, ФильтрДатаНач, ФильтрДатаКнц, СписокСостояний, ФильтрСостояние, ФильтрТипыДокументов
	|, ФильтрОрганизация, ФильтрКонтрагент, ФильтрКонтрагентСФилиалами, ФильтрМаска",
	10, 1);
	ЗаполнитьЗначенияСвойств(ДанныеПоФильтрам, ПараметрыФильтраВходящие);
	
	//Дата с/по
	Если ЗначениеЗаполнено(ДанныеПоФильтрам.ФильтрДатаНач) Тогда
		ЗначениеФильтраСобытий.Вставить("ДатаС",	Формат(ДанныеПоФильтрам.ФильтрДатаНач, "ДФ=""дд.ММ.гггг""")); 
	КонецЕсли;
	Если ЗначениеЗаполнено(ДанныеПоФильтрам.ФильтрДатаКнц) Тогда
		ЗначениеФильтраСобытий.Вставить("ДатаПо",	Формат(ДанныеПоФильтрам.ФильтрДатаКнц, "ДФ=""дд.ММ.гггг""")); 
	КонецЕсли;
	
	//Состояние
	Если		ЗначениеЗаполнено(ДанныеПоФильтрам.СписокСостояний)
		И		ЗначениеЗаполнено(ДанныеПоФильтрам.ФильтрСостояние)
		И		ТипЗнч(ДанныеПоФильтрам.СписокСостояний) = Тип("СписокЗначений")
		И	Не	ДанныеПоФильтрам.ФильтрСостояние = ДанныеПоФильтрам.СписокСостояний.НайтиПоИдентификатору(0).Значение Тогда
		ЗначениеФильтраСобытий.Вставить("Состояние", ДанныеПоФильтрам.ФильтрСостояние); 
	КонецЕсли;
	
	//ТипВложения
	Если ЗначениеЗаполнено(ДанныеПоФильтрам.ФильтрТипыДокументов) тогда
		
		СписокТипДок = "";//"ЭДОНакл,Договор,СчФктр"
		
		Для Каждого ТипДок Из ДанныеПоФильтрам.ФильтрТипыДокументов Цикл
			
			СписокТипДок = СписокТипДок + ТипДок.Значение + ",";
			
		КонецЦикла;
		
		ЗначениеФильтраСобытий.Вставить("ТипВложения", Лев(СписокТипДок, СтрДлина(СписокТипДок) - 1)); 
		
	КонецЕсли;
	
	//Организация
	Если ЗначениеЗаполнено(ДанныеПоФильтрам.ФильтрОрганизация) Тогда
		
		ПараметрыДляСтороны	= Новый Структура("Ключ", "НашаОрганизация");
		СторонаФильтра		= СформироватьФильтрДляРеестраОнлайна_Сторона(ДанныеПоФильтрам.ФильтрОрганизация, ПараметрыДляСтороны);
		Если Не СторонаФильтра = Неопределено Тогда
			
			ЗначениеФильтраСобытий.Вставить(ПараметрыДляСтороны.Ключ, СторонаФильтра);
			
		КонецЕсли;
		
	КонецЕсли;
	
	//Контрагент
	Если ЗначениеЗаполнено(ДанныеПоФильтрам.ФильтрКонтрагент) Тогда
		
		ПараметрыДляСтороны = Новый Структура("Ключ, Фильтры", "Контрагент", ДанныеПоФильтрам);
		СторонаФильтра		= СформироватьФильтрДляРеестраОнлайна_Сторона(ДанныеПоФильтрам.ФильтрКонтрагент, ПараметрыДляСтороны);
		Если Не СторонаФильтра = Неопределено Тогда
			
			ЗначениеФильтраСобытий.Вставить(ПараметрыДляСтороны.Ключ, СторонаФильтра);
			
		КонецЕсли;
		
	КонецЕсли;
		
	//Маска
	Если ЗначениеЗаполнено(ДанныеПоФильтрам.ФильтрМаска) Тогда
		
		ЗначениеФильтраСобытий.Вставить("Маска", ДанныеПоФильтрам.ФильтрМаска);
		
	КонецЕсли;
	
	//ДопПараметры
	Если	ДопПараметры.Свойство("ДопФильтры") 
		И	ЗначениеЗаполнено(ДопПараметры.ДопФильтры) Тогда
		Для Каждого Элемент Из ДопПараметры.ДопФильтры Цикл
			ЗначениеФильтраСобытий.Вставить(Элемент.Ключ, Элемент.Значение);	
		КонецЦикла;
	КонецЕсли;
	
	ОбъектНавигации = Новый Структура; 
	ОбъектНавигации.Вставить("РазмерСтраницы",	Строка(ДанныеПоФильтрам.ЗаписейНаСтранице)); 
	ОбъектНавигации.Вставить("Страница",		Строка(ДанныеПоФильтрам.ФильтрСтраница - 1)); 
	
	ЗначениеФильтраСобытий.Вставить("Навигация", ОбъектНавигации);
	
	Возврат ЗначениеФильтраСобытий;	
	
КонецФункции

&НаКлиенте
Функция	СформироватьФильтрДляРеестраОнлайна_Сторона(ФильтрСсылка, ДопПараметры)
	Перем ДанныеСторонаИни;
	
	СтруктураСтороныДляФильтра	= Новый Структура; 
	ИниКонфигурация				= ИниПоПараметрам("Конфигурация");
	МодульРаботыСДокументами	= ГлобальныйКэш.ТекущийСеанс.Модули.ФункцииДокументов;
	
	Если	Не	ИниКонфигурация.Свойство("мСторона",			ДанныеСторонаИни)
		Или	Не	ДанныеСторонаИни.Свойство(ДопПараметры.Ключ, 	ДанныеСторонаИни) Тогда
		ДанныеСторонаИни = Новый Структура;
	КонецЕсли;
	
	ИННСтороны	= СокрЛП(МодульРаботыСДокументами.ПолучитьРеквизитОбъекта(ФильтрСсылка, "ИНН"));
	Если Не ЗначениеЗаполнено(ИННСтороны) Тогда
		
		Возврат Неопределено;
		
	КонецЕсли;
	
	СвФЛЮЛ		= Новый Структура("ИНН", ИННСтороны);
	
	Если СтрДлина(ИННСтороны) = 12 Тогда
		
		СтруктураСтороныДляФильтра.Вставить("СвФЛ", СвФЛЮЛ);	
		
	Иначе
		
		Попытка
			
			СвФЛЮЛ.Вставить( "КПП", МодульРаботыСДокументами.ПолучитьРеквизитОбъекта(ФильтрСсылка, "КПП"));
			
		Исключение
			
			// если КПП живет в другом реквизите или вообще не в реквизите, а в регистре сведений
			Если ЗначениеЗаполнено(ДанныеСторонаИни) Тогда 
				
				Контекст = Новый Структура("Документ, Ини, ТекущийРазделИни", ФильтрСсылка, ИниКонфигурация, ДанныеСторонаИни);
				СвФЛЮЛ.Вставить("КПП", СокрЛП(МодульРаботыСДокументами.РассчитатьЗначениеНаСервере("Сторона_КПП", Контекст))); 
				
			КонецЕсли;
		КонецПопытки;
		
		СтруктураСтороныДляФильтра.Вставить("СвЮЛ", СвФЛЮЛ);
		
	КонецЕсли;
	
	Если ДанныеСторонаИни.Свойство("Сторона_КодФилиала") Тогда
		
		Контекст = Новый Структура("Документ, Ини, ТекущийРазделИни", ФильтрСсылка, ИниКонфигурация, ДанныеСторонаИни);
		СвФЛЮЛ.Вставить("КодФилиала", СокрЛП(МодульРаботыСДокументами.РассчитатьЗначениеНаСервере("Сторона_КодФилиала", Контекст)));
		
	КонецЕсли;
	
	ЗначениеСФилиалами = Неопределено;
	Если	ДопПараметры.Свойство("Фильтры")
		И	ДопПараметры.Фильтры.Свойство("Фильтр" + ДопПараметры.Ключ + "СФилиалами", ЗначениеСФилиалами)
		И	ЗначениеЗаполнено(ЗначениеСФилиалами)
		И	ЗначениеСФилиалами Тогда
		СтруктураСтороныДляФильтра.Вставить("ДопПоля", "СФилиалами");
	КонецЕсли;
	
	Возврат СтруктураСтороныДляФильтра;
	
КонецФункции 

