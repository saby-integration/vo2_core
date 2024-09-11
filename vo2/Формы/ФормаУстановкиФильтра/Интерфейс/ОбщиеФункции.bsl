
&НаКлиенте
Функция ИмяТекущегоВариантаФильтра()
	
	Возврат МодульОбъектаКлиент().ПолучитьЭлементФормыОбработки(ЭтаФорма, "ВариантыФильтров").ТекущаяСтраница.Имя;
	
КонецФункции

// Функция - возвращает набор используемых фильтров по разделу формы
//
// Параметры:
//  ИмяРазделаФильтра	 - Строка	 - имя раздела из панели ВариантыФильтров
// 
// Возвращаемое значение:
//  Структура - поля со значениями по-умолчанию
//
&НаКлиенте
Функция ЗначенияФильтровПоРазделу(ИмяРазделаФильтра = Неопределено) Экспорт
	
	Если ИмяРазделаФильтра = Неопределено Тогда
		
		ИмяРазделаФильтра = ИмяТекущегоВариантаФильтра();
		
	КонецЕсли;
	
	ПутьЭлементов		= "ВариантыФильтров." + ИмяРазделаФильтра + ".";
	ФильтрПериодДефолт	= "За весь период";
	
	Если		ИмяРазделаФильтра = "ФормаСопоставитьСДокументами1С" Тогда
		
		ПараметрыФильтра = Новый Структура("ФильтрДатаНач, ФильтрДатаКнц, ФильтрНомер, ФильтрПериод, ФильтрДельта, ФильтрСтатусСопоставления", "", "", "");
		ПараметрыФильтра.ФильтрДельта				= 0;
		ПараметрыФильтра.ФильтрСтатусСопоставления	= 0;
		ПараметрыФильтра.ФильтрПериод				= ФильтрПериодДефолт;
		
	ИначеЕсли   ИмяРазделаФильтра = "ФормаГлавноеОкноНоменклатура" Тогда
		
		ПараметрыФильтра = Новый Структура("ФильтрНаименованиеНоменклатуры, ФильтрНоменклатура1С, ФильтрКодКонтрагента, ФильтрGTIN");
		
	Иначе
		
		ЭлементКонтрагент	= МодульОбъектаКлиент().ПолучитьЭлементФормыОбработки(ЭтаФорма, ПутьЭлементов + "КонтрагентГруппа.ФильтрКонтрагент");
		ЭлементОрганизация	= МодульОбъектаКлиент().ПолучитьЭлементФормыОбработки(ЭтаФорма, ПутьЭлементов + "ФильтрОрганизация");
 		ЭлементОтветственный= МодульОбъектаКлиент().ПолучитьЭлементФормыОбработки(ЭтаФорма, ПутьЭлементов + "ФильтрОтветственный");
		
		ПараметрыФильтра = Новый Структура;
		
		ПараметрыФильтра.Вставить("ФильтрСтраница",				1);
		ПараметрыФильтра.Вставить("ФильтрПериод",				ФильтрПериодДефолт);

		ПараметрыФильтра.Вставить("ФильтрДатаНач",				"");
		ПараметрыФильтра.Вставить("ФильтрДатаКнц",				"");
		ПараметрыФильтра.Вставить("ФильтрКонтрагентПодключен",	"");
		ПараметрыФильтра.Вставить("ФильтрКонтрагентСФилиалами",	"");
		ПараметрыФильтра.Вставить("ФильтрМаска",				"");
		
		ПараметрыФильтра.Вставить("ФильтрСостояние",			ВладелецФормы.СписокСостояний.НайтиПоИдентификатору(0).Значение);
		ПараметрыФильтра.Вставить("ФильтрКонтрагент",			ЭлементКонтрагент.ОграничениеТипа.ПривестиЗначение());
		ПараметрыФильтра.Вставить("ФильтрОрганизация",			ЭлементОрганизация.ОграничениеТипа.ПривестиЗначение());
		ПараметрыФильтра.Вставить("ФильтрОтветственный",		ЭлементОтветственный.ОграничениеТипа.ПривестиЗначение());
		ПараметрыФильтра.Вставить("ФильтрТипыДокументов",		Новый СписокЗначений);
		
	КонецЕсли;
	
	Возврат ПараметрыФильтра;
	
КонецФункции

