
&НаСервереБезКонтекста
функция сбисЗаполнитьНачальныйОстатокУТ11_4(Контекст) Экспорт
	// Функция возвращает остаток на начало периода сверки взаиморасчетов для конфигурации УТ11	
	ДанныеТЧ = сбисПолучитьДанныеВзаиморасчетовУТ11_4(Контекст);
	Возврат ДанныеТЧ.НачальныйОстаток;
КонецФункции

&НаСервереБезКонтекста
функция сбисЗаполнитьТаблицуВзаиморасчетовУТ11_4(Контекст) Экспорт
	// Функция формирует табличную часть акта сверки для конфигурации УТ11	
	ДанныеТЧ = сбисПолучитьДанныеВзаиморасчетовУТ11_4(Контекст);
	Возврат ДанныеТЧ.ТабЧастьДокумента;
КонецФункции

&НаСервереБезКонтекста
функция сбисПолучитьДанныеВзаиморасчетовУТ11_4(Контекст)
	// Функция формирует данные акта сверки для конфигурации УТ11	
	ИмяДокументаПоступления = "ПоступлениеТоваровУслуг";
	Если Метаданные.Документы.Найти("ПоступлениеТоваровУслуг")= Неопределено Тогда
		ИмяДокументаПоступления = "ПриобретениеТоваровУслуг";
	КонецЕсли;
	
	ТекстЗапроса = ТекстЗапросаОтборПоАналитике() + "
	|ВЫБРАТЬ
	|	ДанныеДокумента.Ссылка					КАК Документ,
	|	ДанныеДокумента.НомерВходящегоДокумента	КАК Номер,
	|	ДанныеДокумента.ДатаВходящегоДокумента	КАК ДатаВходящегоДокумента,
	|	ДанныеДокумента.Дата                    КАК Дата,
	|	Истина									КАК ЭтоВходящийДокумент
	|
	|ПОМЕСТИТЬ ДокументыИнтеркампани
	|
	|ИЗ
	|	Документ.ОтчетПоКомиссииМеждуОрганизациями КАК ДанныеДокумента                 
	|ГДЕ
	|	ДанныеДокумента.Проведен
	|	И ДанныеДокумента.Организация = &Организация
	|	И ДанныеДокумента.Контрагент = &Контрагент
	|	И ДанныеДокумента.Дата МЕЖДУ &НачалоПериодаСверки И &КонецПериодаСверки
	|	И ДанныеДокумента.РасчетыЧерезОтдельногоКонтрагента
	|
	|ОБЪЕДИНИТЬ ВСЕ
	|
	|ВЫБРАТЬ
	|	ДанныеДокумента.Ссылка					КАК Документ,
	|	ДанныеДокумента.Номер 					КАК Номер,
	|	ДанныеДокумента.ДатаВходящегоДокумента	КАК ДатаВходящегоДокумента,
	|	ДанныеДокумента.Дата 					КАК Дата,
	|	Ложь									КАК ЭтоВходящийДокумент
	|ИЗ
	|	Документ.ОтчетПоКомиссииМеждуОрганизациями КАК ДанныеДокумента                 
	|ГДЕ
	|	ДанныеДокумента.Проведен
	|	И ДанныеДокумента.Комиссионер = &Организация
	|	И ДанныеДокумента.Контрагент = &Контрагент
	|	И ДанныеДокумента.Дата МЕЖДУ &НачалоПериодаСверки И &КонецПериодаСверки
	|	И ДанныеДокумента.РасчетыЧерезОтдельногоКонтрагента
	|
	|ОБЪЕДИНИТЬ ВСЕ
	|
	|ВЫБРАТЬ
	|	ДанныеДокумента.Ссылка					КАК Документ,
	|	ДанныеДокумента.НомерВходящегоДокумента КАК Номер,
	|	ДанныеДокумента.ДатаВходящегоДокумента	КАК ДатаВходящегоДокумента,
	|	ДанныеДокумента.Дата                    КАК Дата,
	|	Истина									КАК ЭтоВходящийДокумент
	|ИЗ
	|	Документ.ПередачаТоваровМеждуОрганизациями КАК ДанныеДокумента                 
	|ГДЕ
	|	ДанныеДокумента.Проведен
	|	И ДанныеДокумента.ОрганизацияПолучатель = &Организация
	|	И ДанныеДокумента.Контрагент = &Контрагент
	|	И ДанныеДокумента.Дата МЕЖДУ &НачалоПериодаСверки И &КонецПериодаСверки
	|	И ДанныеДокумента.РасчетыЧерезОтдельногоКонтрагента
	|
	|ОБЪЕДИНИТЬ ВСЕ
	|
	|ВЫБРАТЬ
	|	ДанныеДокумента.Ссылка					КАК Документ,
	|	ДанныеДокумента.Номер 					КАК Номер,
	|	ДанныеДокумента.ДатаВходящегоДокумента	КАК ДатаВходящегоДокумента,
	|	ДанныеДокумента.Дата 					КАК Дата,
	|	Ложь									КАК ЭтоВходящийДокумент
	|ИЗ
	|	Документ.ПередачаТоваровМеждуОрганизациями КАК ДанныеДокумента                 
	|ГДЕ
	|	ДанныеДокумента.Проведен
	|	И ДанныеДокумента.Организация = &Организация
	|	И ДанныеДокумента.Контрагент = &Контрагент
	|	И ДанныеДокумента.Дата МЕЖДУ &НачалоПериодаСверки И &КонецПериодаСверки
	|	И ДанныеДокумента.РасчетыЧерезОтдельногоКонтрагента
	|;
	|/////////////////////////////////////////////////////////////////////////////
	|
	|ВЫБРАТЬ
	|	РасчетыСКлиентамиОстаткиИОбороты.Период КАК Период,
	|	ЕСТЬNULL(РасчетыСКлиентамиОстаткиИОбороты.Регистратор, Неопределено) КАК Документ,
	|	ВЫБОР КОГДА ДокументыИнтеркампани.Документ ЕСТЬ NULL ТОГДА
	|		ВЫБОР
	|			КОГДА ДанныеПервичныхДокументов.Номер = """"
	|				ТОГДА ДанныеПервичныхДокументов.НомерРегистратора
	|			ИНАЧЕ ДанныеПервичныхДокументов.Номер
	|		КОНЕЦ
	|	ИНАЧЕ
	|		ДокументыИнтеркампани.Номер
	|	КОНЕЦ КАК Номер,
	|	ВЫБОР КОГДА ДокументыИнтеркампани.Документ ЕСТЬ NULL ТОГДА
	|		ДанныеПервичныхДокументов.ДатаРегистратора
	|	ИНАЧЕ
	|		ДокументыИнтеркампани.Дата
	|	КОНЕЦ КАК Дата,
	|	ВЫБОР КОГДА ДокументыИнтеркампани.Документ ЕСТЬ NULL ТОГДА
	|		ВЫБОР
	|			КОГДА ДанныеПервичныхДокументов.Дата = ДАТАВРЕМЯ(1,1,1)
	|				ТОГДА ДанныеПервичныхДокументов.ДатаРегистратора
	|			ИНАЧЕ ДанныеПервичныхДокументов.Дата
	|		КОНЕЦ
	|	ИНАЧЕ
	|		ДокументыИнтеркампани.Дата
	|	КОНЕЦ КАК ДатаВходящегоДокумента,
	|	РегистрАналитикаУчетаПоПартнерам.Партнер 	 КАК Партнер,
	|	РегистрАналитикаУчетаПоПартнерам.Договор	 КАК Договор,
	|	РасчетыСКлиентамиОстаткиИОбороты.Валюта 	 КАК Валюта,
	|	ВЫБОР КОГДА ДокументыИнтеркампани.Документ ЕСТЬ NULL ТОГДА
	|		ВЫБОР КОГДА РасчетыСКлиентамиОстаткиИОбороты.Регистратор.НомерВходящегоДокумента ЕСТЬ NULL
	|			ИЛИ РасчетыСКлиентамиОстаткиИОбороты.Регистратор ССЫЛКА Документ.СписаниеБезналичныхДенежныхСредств ТОГДА
	|			Ложь
	|		ИНАЧЕ
	|			Истина
	|		КОНЕЦ
	|	ИНАЧЕ
	|		ДокументыИнтеркампани.ЭтоВходящийДокумент
	|	КОНЕЦ КАК ЭтоВходящийДокумент,
	|	ВЫБОР КОГДА РасчетыСКлиентамиОстаткиИОбороты.СуммаРасход < 0 ТОГДА
	|		-РасчетыСКлиентамиОстаткиИОбороты.СуммаРасход
	|	КОГДА РасчетыСКлиентамиОстаткиИОбороты.СуммаПриход > 0 ТОГДА
	|		РасчетыСКлиентамиОстаткиИОбороты.СуммаПриход
	|	КОНЕЦ КАК СуммаДолгПартнера,
	|	ВЫБОР КОГДА РасчетыСКлиентамиОстаткиИОбороты.СуммаПриход < 0 ТОГДА
	|		-РасчетыСКлиентамиОстаткиИОбороты.СуммаПриход
	|	КОГДА РасчетыСКлиентамиОстаткиИОбороты.СуммаРасход > 0 ТОГДА
	|		РасчетыСКлиентамиОстаткиИОбороты.СуммаРасход
	|	КОНЕЦ КАК СуммаНашДолг,
	|	РасчетыСКлиентамиОстаткиИОбороты.СуммаНачальныйОстаток КАК СуммаНачальныйОстаток,
	|	РасчетыСКлиентамиОстаткиИОбороты.СуммаКонечныйОстаток КАК СуммаКонечныйОстаток,
	|	ЕСТЬNULL(РеализацияТоваровУслугРеглУчет.Организация, Неопределено) КАК ОрганизацияРеглУчет
	|
	|ПОМЕСТИТЬ РасчетыСПартнерами
	|
	|ИЗ
	|	РегистрНакопления.РасчетыСКлиентами.ОстаткиИОбороты(
	|			&НачалоПериодаСверки,
	|			&ГраницаКонецПериода,
	|			Регистратор,
	|			ДвиженияИГраницыПериода,
	|			АналитикаУчетаПоПартнерам В
	|				(ВЫБРАТЬ
	|					ОтборПоАналитике.КлючАналитики
	|				ИЗ
	|					ОтборПоАналитике)
	|	) КАК РасчетыСКлиентамиОстаткиИОбороты
	|	ВНУТРЕННЕЕ СОЕДИНЕНИЕ РегистрСведений.АналитикаУчетаПоПартнерам КАК РегистрАналитикаУчетаПоПартнерам
	|		ПО РасчетыСКлиентамиОстаткиИОбороты.АналитикаУчетаПоПартнерам = РегистрАналитикаУчетаПоПартнерам.КлючАналитики
	|	ЛЕВОЕ СОЕДИНЕНИЕ ДокументыИнтеркампани КАК ДокументыИнтеркампани
	|		ПО РасчетыСКлиентамиОстаткиИОбороты.Регистратор = ДокументыИнтеркампани.Документ
	|	ЛЕВОЕ СОЕДИНЕНИЕ Документ.РеализацияТоваровУслуг КАК РеализацияТоваровУслугРеглУчет
	|		ПО РасчетыСКлиентамиОстаткиИОбороты.Регистратор = РеализацияТоваровУслугРеглУчет.Ссылка
	|		И РеализацияТоваровУслугРеглУчет.ХозяйственнаяОперация = ЗНАЧЕНИЕ(Перечисление.ХозяйственныеОперации.РеализацияКлиентуРеглУчет)
	|		И &Организация = ЗНАЧЕНИЕ(Справочник.Организации.УправленческаяОрганизация)
	|	ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.ДанныеПервичныхДокументов КАК ДанныеПервичныхДокументов
	|		ПО РегистрАналитикаУчетаПоПартнерам.Организация = ДанныеПервичныхДокументов.Организация
	|			И РасчетыСКлиентамиОстаткиИОбороты.Регистратор = ДанныеПервичныхДокументов.Документ
	|
	|ОБЪЕДИНИТЬ ВСЕ
	|
	|ВЫБРАТЬ
	|	РасчетыСПоставщикамиОстаткиИОбороты.Период КАК Период,
	|	ЕСТЬNULL(РасчетыСПоставщикамиОстаткиИОбороты.Регистратор, Неопределено) КАК Документ,
	|	ВЫБОР КОГДА ДокументыИнтеркампани.Документ ЕСТЬ NULL ТОГДА
	|		ВЫБОР
	|			КОГДА ДанныеПервичныхДокументов.Номер = """"
	|				ТОГДА ДанныеПервичныхДокументов.НомерРегистратора
	|			ИНАЧЕ ДанныеПервичныхДокументов.Номер
	|		КОНЕЦ
	|	ИНАЧЕ
	|		ДокументыИнтеркампани.Номер
	|	КОНЕЦ КАК Номер,
	|	ВЫБОР КОГДА ДокументыИнтеркампани.Документ ЕСТЬ NULL ТОГДА
	|		ДанныеПервичныхДокументов.ДатаРегистратора
	|	ИНАЧЕ
	|		ДокументыИнтеркампани.Дата
	|	КОНЕЦ КАК Дата,
	|	ВЫБОР КОГДА ДокументыИнтеркампани.Документ ЕСТЬ NULL ТОГДА
	|		ВЫБОР
	|			КОГДА ДанныеПервичныхДокументов.Дата = ДАТАВРЕМЯ(1,1,1)
	|				ТОГДА ДанныеПервичныхДокументов.ДатаРегистратора
	|			ИНАЧЕ ДанныеПервичныхДокументов.Дата
	|		КОНЕЦ
	|	ИНАЧЕ
	|		ДокументыИнтеркампани.Дата
	|	КОНЕЦ КАК ДатаВходящегоДокумента,
	|	РегистрАналитикаУчетаПоПартнерам.Партнер 	 КАК Партнер,
	|	РегистрАналитикаУчетаПоПартнерам.Договор	 КАК Договор,
	|	РасчетыСПоставщикамиОстаткиИОбороты.Валюта 	 КАК Валюта,
	|	ВЫБОР КОГДА ДокументыИнтеркампани.Документ ЕСТЬ NULL ТОГДА
	|		ВЫБОР КОГДА РасчетыСПоставщикамиОстаткиИОбороты.Регистратор.НомерВходящегоДокумента ЕСТЬ NULL
	|			ИЛИ РасчетыСПоставщикамиОстаткиИОбороты.Регистратор ССЫЛКА Документ.СписаниеБезналичныхДенежныхСредств ТОГДА
	|			Ложь
	|		ИНАЧЕ
	|			Истина
	|		КОНЕЦ
	|	ИНАЧЕ
	|		ДокументыИнтеркампани.ЭтоВходящийДокумент
	|	КОНЕЦ КАК ЭтоВходящийДокумент,
	|	ВЫБОР КОГДА РасчетыСПоставщикамиОстаткиИОбороты.СуммаРасход < 0 ТОГДА
	|		-РасчетыСПоставщикамиОстаткиИОбороты.СуммаРасход
	|	КОГДА РасчетыСПоставщикамиОстаткиИОбороты.СуммаПриход > 0 ТОГДА
	|		РасчетыСПоставщикамиОстаткиИОбороты.СуммаПриход
	|	КОНЕЦ КАК СуммаДолгПартнера,
	|	ВЫБОР КОГДА РасчетыСПоставщикамиОстаткиИОбороты.СуммаПриход < 0 ТОГДА
	|		-РасчетыСПоставщикамиОстаткиИОбороты.СуммаПриход
	|	КОГДА РасчетыСПоставщикамиОстаткиИОбороты.СуммаРасход > 0 ТОГДА
	|		РасчетыСПоставщикамиОстаткиИОбороты.СуммаРасход
	|	КОНЕЦ КАК СуммаНашДолг,
	|	РасчетыСПоставщикамиОстаткиИОбороты.СуммаНачальныйОстаток КАК СуммаНачальныйОстаток,
	|	РасчетыСПоставщикамиОстаткиИОбороты.СуммаКонечныйОстаток КАК СуммаКонечныйОстаток,
	|	ЕСТЬNULL(ПриобретениеТоваровУслугРеглУчет.Организация, Неопределено) КАК ОрганизацияРеглУчет
	|ИЗ
	|	РегистрНакопления.РасчетыСПоставщиками.ОстаткиИОбороты(
	|			&НачалоПериодаСверки,
	|			&ГраницаКонецПериода,
	|			Регистратор,
	|			ДвиженияИГраницыПериода,
	|			АналитикаУчетаПоПартнерам В
	|				(ВЫБРАТЬ
	|					ОтборПоАналитике.КлючАналитики
	|				ИЗ
	|					ОтборПоАналитике)
	|	) КАК РасчетыСПоставщикамиОстаткиИОбороты
	|	ВНУТРЕННЕЕ СОЕДИНЕНИЕ РегистрСведений.АналитикаУчетаПоПартнерам КАК РегистрАналитикаУчетаПоПартнерам
	|		ПО РасчетыСПоставщикамиОстаткиИОбороты.АналитикаУчетаПоПартнерам = РегистрАналитикаУчетаПоПартнерам.КлючАналитики
	|	ЛЕВОЕ СОЕДИНЕНИЕ ДокументыИнтеркампани КАК ДокументыИнтеркампани
	|		ПО РасчетыСПоставщикамиОстаткиИОбороты.Регистратор = ДокументыИнтеркампани.Документ
	|	ЛЕВОЕ СОЕДИНЕНИЕ Документ."+ИмяДокументаПоступления+" КАК ПриобретениеТоваровУслугРеглУчет
	|		ПО РасчетыСПоставщикамиОстаткиИОбороты.Регистратор = ПриобретениеТоваровУслугРеглУчет.Ссылка
	|		И ПриобретениеТоваровУслугРеглУчет.ХозяйственнаяОперация = ЗНАЧЕНИЕ(Перечисление.ХозяйственныеОперации.ЗакупкаУПоставщикаРеглУчет)
	|		И &Организация = ЗНАЧЕНИЕ(Справочник.Организации.УправленческаяОрганизация)
	|	ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.ДанныеПервичныхДокументов КАК ДанныеПервичныхДокументов
	|		ПО РегистрАналитикаУчетаПоПартнерам.Организация = ДанныеПервичныхДокументов.Организация
	|			И РасчетыСПоставщикамиОстаткиИОбороты.Регистратор = ДанныеПервичныхДокументов.Документ
	|
	|ГДЕ
	|	РасчетыСПоставщикамиОстаткиИОбороты.Регистратор ЕСТЬ NULL
	|	ИЛИ НЕ РасчетыСПоставщикамиОстаткиИОбороты.Регистратор ССЫЛКА Документ.АвансовыйОтчет
	|
	|ОБЪЕДИНИТЬ ВСЕ
	|
	|ВЫБРАТЬ
	|	ДанныеДокумента.Дата				КАК Период,
	|	ДанныеДокумента.Ссылка				КАК Документ,
	|	Расшифровка.НомерВходящегоДокумента	КАК Номер,
	|	Расшифровка.ДатаВходящегоДокумента	КАК Дата,
	|	Расшифровка.ДатаВходящегоДокумента	КАК ДатаВходящегоДокумента,
	|	Расшифровка.Поставщик				КАК Партнер,
	|	ВЫБОР КОГДА Расшифровка.Заказ ССЫЛКА Справочник.ДоговорыКонтрагентов ТОГДА
	|		Расшифровка.Заказ
	|	ИНАЧЕ
	|		Расшифровка.Заказ.Договор
	|	КОНЕЦ								КАК Договор,
	|	Расшифровка.ВалютаВзаиморасчетов	КАК Валюта,
	|	Истина								КАК ЭтоВходящийДокумент,
	|	Расшифровка.СуммаВзаиморасчетов		КАК СуммаДолгПартнера,
	|	0									КАК СуммаНашДолг,
	|	0									КАК СуммаНачальныйОстаток,
	|	0									КАК СуммаКонечныйОстаток,
	|	Неопределено						КАК ОрганизацияРеглУчет
	|ИЗ
	|	Документ.АвансовыйОтчет КАК ДанныеДокумента
	|	ВНУТРЕННЕЕ СОЕДИНЕНИЕ Документ.АвансовыйОтчет.ОплатаПоставщикам КАК Расшифровка
	|		ПО Расшифровка.Ссылка = ДанныеДокумента.Ссылка
	|ГДЕ
	|	ДанныеДокумента.Проведен
	|	И ДанныеДокумента.Организация = &Организация
	|	И Расшифровка.Контрагент = &Контрагент
	|	И ДанныеДокумента.Дата МЕЖДУ &НачалоПериодаСверки И &КонецПериодаСверки
	|	И (&НеИспользоватьОтборПоДоговору
	|		ИЛИ ВЫБОР КОГДА Расшифровка.Заказ ССЫЛКА Справочник.ДоговорыКонтрагентов ТОГДА
	|			Расшифровка.Заказ
	|		ИНАЧЕ
	|			Расшифровка.Заказ.Договор
	|		КОНЕЦ = &Договор)
	|;
	|/////////////////////////////////////////////////////////////////////////////
	|
	|ВЫБРАТЬ
	|	РасчетыСПартнерами.Период				 		КАК Период,
	|	РасчетыСПартнерами.Документ				 		КАК Документ,
	|	РасчетыСПартнерами.Номер				 		КАК Номер,
	|	РасчетыСПартнерами.Дата					 		КАК Дата,
	|	РасчетыСПартнерами.ДатаВходящегоДокумента       КАК ДатаВходящегоДокумента,
	|	%ПолеПартнер%
	|	%ПолеДоговор%
	|	РасчетыСПартнерами.Валюта				 		КАК Валюта,
	|	РасчетыСПартнерами.ЭтоВходящийДокумент	 		КАК ЭтоВходящийДокумент,
	|	СУММА(РасчетыСПартнерами.СуммаДолгПартнера)	 	КАК СуммаДолгПартнера,
	|	СУММА(РасчетыСПартнерами.СуммаНашДолг)			КАК СуммаНашДолг,
	|	СУММА(РасчетыСПартнерами.СуммаНачальныйОстаток) КАК СуммаНачальныйОстаток,
	|	СУММА(РасчетыСПартнерами.СуммаКонечныйОстаток)	КАК СуммаКонечныйОстаток,
	|	РасчетыСПартнерами.ОрганизацияРеглУчет			КАК ОрганизацияРеглУчет
	|ПОМЕСТИТЬ РасчетыСПартнерамиГруппировка
	|ИЗ
	|	РасчетыСПартнерами КАК РасчетыСПартнерами
	|
	|СГРУППИРОВАТЬ ПО
	|	Период, Документ, Номер, Дата, ДатаВходящегоДокумента, %Партнер% %Договор% Валюта, ЭтоВходящийДокумент, ОрганизацияРеглУчет
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	РасчетыСПартнерами.Период                 КАК Период,
	|	РасчетыСПартнерами.Документ               КАК Документ,
	|	РасчетыСПартнерами.Номер                  КАК Номер,
	|	РасчетыСПартнерами.Дата                   КАК Дата,
	|	РасчетыСПартнерами.ДатаВходящегоДокумента КАК ДатаВходящегоДокумента,
	|	%ПолеПартнер%
	|	%ПолеДоговор%
	|	РасчетыСПартнерами.Валюта                 КАК Валюта,
	|	РасчетыСПартнерами.ЭтоВходящийДокумент    КАК ЭтоВходящийДокумент,
	|	ЕстьNull(РасчетыСПартнерами.СуммаДолгПартнера,0)      КАК СуммаДолгПартнера,
	|	ЕстьNull(РасчетыСПартнерами.СуммаНашДолг,0)           КАК СуммаНашДолг,
	|	ЕстьNull(РасчетыСПартнерами.СуммаНачальныйОстаток,0)  КАК СуммаНачальныйОстаток,
	|	ЕстьNull(РасчетыСПартнерами.СуммаКонечныйОстаток,0)   КАК СуммаКонечныйОстаток,
	|	ЕстьNull(РасчетыСПартнерами.ОрганизацияРеглУчет,0)    КАК ОрганизацияРеглУчет
	|ИЗ
	|	РасчетыСПартнерамиГруппировка КАК РасчетыСПартнерами
	|
	|УПОРЯДОЧИТЬ ПО
	|	Период, Документ
	|
	|ИТОГИ ПО
	|	%Партнер%
	|	%Договор%
	|	Валюта
	|";
	
	Возврат сбисОбработатьЗапросВзаиморасчетов(Контекст, ТекстЗапроса);
	
КонецФункции

