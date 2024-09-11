
&НаКлиенте
Процедура Документ1СВыборВариантаСписокПослеДиалога(ПараметрыУстановитьВходящие, ДопПараметры = Неопределено) Экспорт

	Если ПараметрыУстановитьВходящие = Неопределено Тогда
		
		Возврат;
		
	КонецЕсли;
	ВложениеСбис = МодульОбъектаКлиент().ПолучитьЭлементФормыОбработки(ЭтаФорма,"ТаблицаДокументов").ТекущиеДанные.Вложение[0].Значение;

	ПараметрыРаботы.Удалить("ВариантыОбработкиДокумента");
	ПараметрыПросмотр			= МодульОбъектаКлиент().ВложениеСБИС_Получить(ВложениеСБИС, "Просмотр");
	РедактируемыеПоляВложения	= МодульОбъектаКлиент().ВложениеСБИС_Получить(ВложениеСБИС, "Поля1С");
	
	ПараметрыПросмотр.Вставить("ПараметрыДокумент", ПараметрыУстановитьВходящие.Значение);
	
	Документ1СВыборВариантаУстановить(ВложениеСбис, ПараметрыУстановитьВходящие.Значение); 
	ОбновитьПоляФормыПоВложению(ВложениеСбис);

КонецПроцедуры

&НаКлиенте
Процедура Документ1СВыборВариантаУстановить(ВложениеСбис, ПараметрыУстановитьВходящие) Экспорт

	МодульТекущий	= МодульОбъектаКлиент();
	ЭлементДокумент = МодульТекущий.ПолучитьЭлементФормыОбработки(ЭтаФорма, "Документ1С");
	
	ЧтоИзменить = Новый ФиксированнаяСтруктура("УстановитьОграничениеТипа", ПараметрыУстановитьВходящие.Тип);
	МодульТекущий.ИзменитьЭлементФормыОбработки(ЭлементДокумент, ЧтоИзменить);
	Документ1С = ПараметрыУстановитьВходящие.Значение;
	
КонецПроцедуры

// Процедура осуществляет переход по вкладкам формы	
&НаКлиенте
Процедура КонтентВыборЗакладки(ИмяПанели)
	
	ПанельСтраницы = МодульОбъектаКлиент().ПолучитьЭлементФормыОбработки(ЭтаФорма, "Контент");
	ПанельСтраницы.ТекущаяСтраница = МодульОбъектаКлиент().ПолучитьЭлементФормыОбработки(ПанельСтраницы, ИмяПанели);
	
КонецПроцедуры

&НаКлиенте
Процедура НоменклатураОтметитьВсеОбработчик()
	
	СтруктураФайлаВложения = МодульОбъектаКлиент().ВложениеСбис_Получить(Вложение, "УстановленныйПодразделИни");
	Если СтруктураФайлаВложения = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	ПутьТаблДок	= МодульОбъектаКлиент().ПолучитьЭлементФормыОбработки(ЭтаФорма, "ТаблицаДокументов").ТекущиеДанные.ПутьТаблДок;
	ТаблДок		= МестныйКэш.ОбщиеФункции.РассчитатьЗначениеИзСтруктуры(ПутьТаблДок, Вложение.СтруктураФайла);
	Для Каждого Строка Из ЭтаФорма.ТабличнаяЧасть Цикл
		Строка.Отмечен = ОтметитьВсе;   
		Если ОтметитьВсе Тогда
			ТаблДок[Строка.НомерПП-1].Удалить("НеЗагружать");
		Иначе
			ТаблДок[Строка.НомерПП-1].Вставить("НеЗагружать");
		КонецЕсли;
	КонецЦикла;    
	ЗаполнитьТаблицуДокументов(СоставПакета);
	
КонецПроцедуры

// Процедура - обновляет данные состава пакета по заполненным параметрам формы
//
// Параметры:
//  СоставПакетаОбновить - СоставПакета	 - в который вносятся изменения формы
//
&НаКлиенте
Процедура ОбновитьДанныеДокументаСБИС(СоставПакетаОбновить)
	
	// Заполнение заполненных позиций ГК.
	Изменения = Новый Структура("Номенклатура", Новый Соответствие);
	
	Для Каждого СтрокаНоменклатуры Из МодульОбъектаКлиент().ПолучитьЭлементФормыОбработки(ТаблицаМаркировка, "Строки") Цикл
	
		Ключ = Строка(СтрокаНоменклатуры.НомерПП);
		Изменения.Номенклатура.Вставить(Ключ, Новый Структура("ПозГК", СтрокаНоменклатуры.ПозГК));
	
	КонецЦикла;
	
	МодульОбъектаКлиент().СоставПакета_Обновить(СоставПакетаОбновить, Изменения);

	// Перегенерация модифицированных вложений.
	ОснованиеПакета = МодульОбъектаКлиент().СоставПакета_Получить(СоставПакетаОбновить, "ОсновнойДокумент1С");
	
	ПараметрыГенерацииПакетов = Новый Структура("Кэш", Кэш);
	ПараметрыГенерацииПакетов.Вставить("ОснованиеПакета", ОснованиеПакета);

	Для Каждого  Вложение Из МодульОбъектаКлиент().СоставПакета_Получить(СоставПакетаОбновить, "Вложение") Цикл
		
		// Если были изменения во вложении, необходимо записать черновик, иначе нет смысла
		Если Не МодульОбъектаКлиент().ВложениеСБИС_Получить(Вложение, "Модифицирован") Тогда
			
			Продолжить;
			
		КонецЕсли;
			
		ПараметрыГенерацииПакетов = Новый Структура("Кэш", Кэш);
		ПараметрыГенерацииПакетов.Вставить("Вложение", Вложение);
		ПараметрыГенерацииПакетов.Вставить("СтруктураДокумента", МодульОбъектаКлиент().ВложениеСБИС_Получить(Вложение, "СтруктураФайла"));
		РезультатГенерации = МодульОбъектаКлиент().СгенерироватьНаборВложенийВПакет(ПараметрыГенерацииПакетов);
		
		МодульОбъектаКлиент().СоставПакета_Обновить(СоставПакетаОбновить, Новый Структура("Вложения", РезультатГенерации));
			
	КонецЦикла;

КонецПроцедуры

&НаКлиенте
Процедура ОбновитьПоляФормыПоДокументуСБИС(СоставПакетаСБИС)  
	Перем СостояниеПакета;
	
	УстановитьВидимостьЭлементовВкладкиМаркировка(); 
	УстановитьВидимостьЭлементовВкладкиПрослеживаемость();

	МодульТекущий	= МодульОбъектаКлиент();
	
	ПараметрыПакета = МодульТекущий.СоставПакета_Получить(СоставПакетаСБИС, "Параметры");
	ЗагрузкаПоддерживается	= Не	ПараметрыПакета.Свойство("ЗагрузкаПоддерживается")
							Или		ПараметрыПакета.ЗагрузкаПоддерживается;
							
	ПакетРазобран			= 	(ДокументУчетаРазобран	И ИмяРеквизитаВложений = "ВложениеУчета")
							Или (ДокументРазобран		И ИмяРеквизитаВложений = "Вложение");
		
	ВыборочноеШифрование	=	ПараметрыПакета.Свойство("ВыборочноеШифрование")
							И	ПараметрыПакета.ВыборочноеШифрование
							И	МодульТекущий.ПолучитьЗначениеПараметраСБИС("Шифрование")
							И	МодульТекущий.ПолучитьЗначениеПараметраСБИС("ШифроватьВыборочно");
							
	ОтмечатьДокументы		=	Не	ПараметрыПакета.Свойство("ОтмечатьВложения")
							Или		ПараметрыПакета.ОтмечатьВложения;
							
	УдалятьДокументы		=	ПараметрыПакета.Свойство("УдалятьВложения")
							И	ПараметрыПакета.УдалятьВложения; 
							
	ЕстьАннулирование		=   ПараметрыПакета.Свойство("Аннулирование")
							И	ПараметрыПакета.Аннулирование
							И	Не	(	СоставПакетаСБИС.Свойство("Состояние",	СостояниеПакета)
									И	СоставПакетаСБИС.Свойство("Название",	СостояниеПакета)
									И	СостояниеПакета = "Отозван мной");
	
	ПараметрыРаботы.Вставить("ЗагрузкаПоддерживается", ЗагрузкаПоддерживается);
	
	Заголовок		= МодульТекущий.СоставПакета_Получить(СоставПакетаСБИС, "Название");
	ЗаголовокПакета = МодульТекущий.СоставПакета_Получить(СоставПакетаСБИС, "Название");

	Если	МодульТекущий.ПрименятьФункционалНовыеКонтрагенты(Новый Структура("СоставПакета", СоставПакетаСБИС)) Тогда
		
		МодульТекущий.ПолучитьЭлементФормыОбработки(ЭтаФорма, "УчетОрганизация").Доступность		= ПакетРазобран;
		МодульТекущий.ПолучитьЭлементФормыОбработки(ЭтаФорма, "УчетКонтрагент").Доступность			= ПакетРазобран;
		МодульТекущий.ПолучитьЭлементФормыОбработки(ЭтаФорма, "УчетГрузополучатель").Доступность	= ПакетРазобран;
		
	КонецЕсли;
	
	МодульТекущий.ПолучитьЭлементФормыОбработки(ЭтаФорма, "ПакетКомментарий").Доступность =	ПараметрыПакета.Свойство("УказыватьКомментарий")
																						И	ПараметрыПакета.УказыватьКомментарий;;
	
	// Определение видимости вкладок																						
	МодульТекущий.ПолучитьЭлементФормыОбработки(ЭтаФорма, "Контент.Загрузка").Видимость		= ЗагрузкаПоддерживается;
	МодульТекущий.ПолучитьЭлементФормыОбработки(ЭтаФорма, "Контент.Прохождение").Видимость	= СоставПакетаСБИС.Свойство("Событие");

	МодульТекущий.ПолучитьЭлементФормыОбработки(ЭтаФорма, "ТаблицаДокументов.Статус").Видимость			= ПакетРазобран И ЗагрузкаПоддерживается;
	МодульТекущий.ПолучитьЭлементФормыОбработки(ЭтаФорма, "ТаблицаДокументов.СтатусКартинка").Видимость	= ПакетРазобран И ЗагрузкаПоддерживается;
	МодульТекущий.ПолучитьЭлементФормыОбработки(ЭтаФорма, "ТаблицаДокументов.Шифрование").Видимость		= ВыборочноеШифрование;
	МодульТекущий.ПолучитьЭлементФормыОбработки(ЭтаФорма, "ТаблицаДокументов.Отмечен").Видимость		= ОтмечатьДокументы;
	МодульТекущий.ПолучитьЭлементФормыОбработки(ЭтаФорма, "ТаблицаДокументов.Удалить").Видимость		= УдалятьДокументы;
	
	МодульТекущий.ПолучитьЭлементФормыОбработки(ЭтаФорма, "ПодготовитьКЗагрузке").Видимость	= Не ПакетРазобран;
	МодульТекущий.ПолучитьЭлементФормыОбработки(ЭтаФорма, "ЗагрузитьНаВложении").Видимость	= ПакетРазобран;

	МодульТекущий.ПолучитьЭлементФормыОбработки(ЭтаФорма, "ГруппаАбонЯщик").Видимость	=	ПараметрыПакета.Свойство("АбонентскийЯщик")
																						И	ПараметрыПакета.АбонентскийЯщик;
	ЗаполнитьТаблицуДокументов(СоставПакетаСБИС);
																						
КонецПроцедуры

// Процедура обновляет информацию по вложению (просмотр, прохождение, сопоставление номенклатуры) при переключении между вложениями в таблице
&НаКлиенте
Процедура ОбновитьПоляФормыПоВложению(ВложениеСБИС)
	
	УстановитьДанныеПоВложению(ВложениеСБИС);
	УстановитьВидимостьПоВложению(ВложениеСБИС);
	
	СтатусВложение = МодульОбъектаКлиент().ВложениеСБИС_Получить(ВложениеСБИС, "Статус");
	Если СтатусВложение = "Ошибка" Тогда
		
		ОшибкаВложение = МодульОбъектаКлиент().ВложениеСБИС_Получить(ВложениеСБИС, "СтатусыВложения").Ошибка;
		МодульОбъектаКлиент().СообщитьСбисИсключение(ОшибкаВложение, Новый Структура("ИмяКоманды", "ФормаПросмотрДокумента.ОбновитьПоляФормыПоВложению"));
		Возврат;
		
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ОбработкаОповещения(ИмяСобытия, Параметр, Источник)

	// Закрытие формы просмотра при закрытии обработки	
	Если ИмяСобытия = "ЗакрытьСБИС" Тогда
		
		Если ЭтаФорма.Открыта() Тогда
			
			ЭтаФорма.Закрыть();
			
		КонецЕсли;
		
	КонецЕсли;
	
	
КонецПроцедуры

//Обработка сопоставления
&НаКлиенте
Процедура СбисСтрокаТабличнаяЧастьПриИзменении(ВходящийКэш, ТабЧасть)
	
	Если Кэш = Неопределено Тогда
		Кэш = ВходящийКэш;
	КонецЕсли;

	
	СтрокаТабЧасти	= ТабЧасть.ТекущиеДанные;
	Если СтрокаТабЧасти = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	#Если ТолстыйКлиентОбычноеПриложение Тогда
		ИмяПоиска = "НомерПП";
	#Иначе
		ИмяПоиска = "Название";
		Если ЗначениеЗаполнено(СтрокаТабЧасти.КодПокупателя) Тогда
			ИмяПоиска = "КодПокупателя";
		ИначеЕсли ЗначениеЗаполнено(СтрокаТабЧасти.Идентификатор) Тогда
			ИмяПоиска = "Идентификатор";
		КонецЕсли;
	#КонецЕсли
	ЗначениеПоиска = СтрокаТабЧасти[ИмяПоиска];
	
	ДанныеНоменклатуры = Новый Структура("Название, КодПокупателя, Идентификатор, Код, Номенклатура, Характеристика, ХарактеристикаПоставщика, GTIN, ЕдИзм, ЕдИзмОрг, Коэффициент");
    ЗаполнитьЗначенияСвойств(ДанныеНоменклатуры, СтрокаТабЧасти);
	
	ОчищеныКлючиНоменклатура	= Новый Массив;
	УспешноЗаписаноИзменение	= Ложь;
	ЕстьИзмененияСтроки			= Ложь;
	ЕстьИзмененияНоменклатуры	= Ложь;
	Для Каждого КлючИЗначениеСтр Из СтрокаТЧДоИзменения.Номенклатура Цикл
		Если		СтрокаТабЧасти[КлючИЗначениеСтр.Ключ] = КлючИЗначениеСтр.Значение Тогда
			Продолжить;
		ИначеЕсли	КлючИЗначениеСтр.Ключ = "Номенклатура"
			И	Не	ЗначениеЗаполнено(ДанныеНоменклатуры.Номенклатура) Тогда
			КлючиПоискаТЧ = Новый Структура;
			КлючиПоискаТЧ.Вставить("Идентификатор",					ДанныеНоменклатуры.Идентификатор);
			КлючиПоискаТЧ.Вставить("Номенклатура",					СтрокаТЧДоИзменения.Номенклатура.Номенклатура);
			КлючиПоискаТЧ.Вставить("ХарактеристикаНоменклатуры",	СтрокаТЧДоИзменения.Номенклатура.Характеристика);
			ОчищеныКлючиНоменклатура.Добавить("Номенклатура");
			ОчищеныКлючиНоменклатура.Добавить("ХарактеристикаНоменклатуры");
			ОчищеныКлючиНоменклатура.Добавить("ЕдИзмОрг");
			ОчищеныКлючиНоменклатура.Добавить("Коэффициент");
		КонецЕсли;
		ЕстьИзмененияНоменклатуры = Истина;
		ЕстьИзмененияСтроки = Истина;
		Прервать;
	КонецЦикла;
	Если Не ЕстьИзмененияСтроки Тогда
		Для Каждого КлючИЗначениеСтр Из СтрокаТЧДоИзменения.Прочее Цикл
			Если СтрокаТабЧасти[КлючИЗначениеСтр.Ключ] = КлючИЗначениеСтр.Значение Тогда
				Продолжить;
			КонецЕсли;
			ЕстьИзмененияСтроки = Истина;
			Прервать;
		КонецЦикла;
		Если Не ЕстьИзмененияСтроки Тогда
			Возврат;
		КонецЕсли;
	КонецЕсли;
	
	ПутьКонтрагента	= сбисЭлементФормы(ЭтаФорма,"ТаблицаДокументов").ТекущиеДанные.ПутьКонтрагента;
	ПутьТаблДок		= сбисЭлементФормы(ЭтаФорма,"ТаблицаДокументов").ТекущиеДанные.ПутьТаблДок;
	Если Не ЗначениеЗаполнено(ПутьКонтрагента) Тогда
		Сообщить("Отсутствуют требуемые данные для записи сопоставления");
		Возврат;
	КонецЕсли;
	
	//Если меняли номенлклатуру, то запишем.
	Если ЕстьИзмененияНоменклатуры Тогда
		фрм = Кэш.ГлавноеОкно.сбисНайтиФормуФункции("УстановитьСоответствиеНоменклатуры", Кэш.ФормаРаботыСНоменклатурой, "", Кэш);
		Попытка
			фрм.УстановитьСоответствиеНоменклатуры(Кэш.ОбщиеФункции.РассчитатьЗначениеИзСтруктуры(ПутьКонтрагента, Вложение.СтруктураФайла), ДанныеНоменклатуры, Кэш.Парам.КаталогНастроек, Кэш.Ини);
			УспешноЗаписаноИзменение = Истина;
		Исключение
			СбисИсключение = Кэш.ОбщиеФункции.СбисИсключение(ИнформацияОбОшибке(), "ФормаПросмотрДокумента.СбисЗаписатьСопоставление",,"Ошибка записи сопоставления");
			Кэш.ГлавноеОкно.СбисСообщитьОбОшибке(Кэш, СбисИсключение, Новый Структура("ФормаВладелец", ЭтаФорма));
		КонецПопытки;
	КонецЕсли;
	
	НомерПП = СтрокаТабЧасти.НомерПП-1;
	ТаблДок = Кэш.ОбщиеФункции.РассчитатьЗначениеИзСтруктуры(ПутьТаблДок, Вложение.СтруктураФайла);
	ТаблДок[НомерПП].Вставить("Номенклатура",				ДанныеНоменклатуры.Номенклатура);
	ТаблДок[НомерПП].Вставить("ХарактеристикаНоменклатуры",	ДанныеНоменклатуры.Характеристика);
	ТаблДок[НомерПП].Вставить("ЕдИзмОрг",					ДанныеНоменклатуры.ЕдИзмОрг);
	ТаблДок[НомерПП].Вставить("Коэффициент",				ДанныеНоменклатуры.Коэффициент);
	Если СтрокаТабЧасти.Отмечен Тогда
		ТаблДок[НомерПП].Удалить("НеЗагружать");
	Иначе
		ТаблДок[НомерПП].Вставить("НеЗагружать");
	КонецЕсли;
	
	Если	УспешноЗаписаноИзменение
		И	ОчищеныКлючиНоменклатура.Количество() Тогда
		
		ИмяФормыОбработки = "Файл_Шаблон";
		Если НЕ Вложение.ВерсияФорматаДляЗагрузки = "3_01" Тогда
			ИмяФормыОбработки = ИмяФормыОбработки + "_" + Вложение.ВерсияФорматаДляЗагрузки; 
		КонецЕсли;
		ПараметрыОбработать = Новый Структура("Ключи, Очистить, Таблица", КлючиПоискаТЧ, ОчищеныКлючиНоменклатура, ТаблДок);

		МодульОбработкиВложения = МодульОбъектаКлиент().ПолучитьФормуОбработки(ИмяФормыОбработки);
		МодульОбработкиВложения.ОбработатьТабличнуюЧастьДокумента(ПараметрыОбработать, Кэш);
		
	КонецЕсли;
	ЗаполнитьТаблицуДокументов(СоставПакета);

	Если ЗначениеПоиска = Неопределено Тогда
		Возврат;
	КонецЕсли;
	СтрокаТЧУстановить = Новый Структура(ИмяПоиска, ЗначениеПоиска);
	
	ЭтаФорма.ПодключитьОбработчикОжидания("СбисСпозиционироватьСтроку", 0.1, Истина);
КонецПроцедуры

//Позиционирует строку в ТЧ после обновления
&НаКлиенте
Процедура СбисСпозиционироватьСтроку() Экспорт
	ТабЧасть	= СбисЭлементФормы(ЭтаФорма,"ТабличнаяЧасть");
	Строка		= ТабличнаяЧасть.НайтиСтроки(СтрокаТЧУстановить);
	Если Строка.Количество() Тогда
		СтрокаУстановить = Строка[0];
		#Если Не ТолстыйКлиентОбычноеПриложение Тогда 
			СтрокаУстановить = СтрокаУстановить.ПолучитьИдентификатор();
		#КонецЕсли
	Иначе
		Возврат;
	КонецЕсли;
	ТабЧасть.ТекущаяСтрока = СтрокаУстановить;		
КонецПроцедуры

//Запись до изменений
&НаКлиенте
Процедура СбисСтрокаТабличнаяЧастьДоИзменения(ВходящийКэш, ТабЧасть) 
	
	Если Кэш = Неопределено Тогда
		Кэш = ВходящийКэш;
	КонецЕсли;

	СтрокаТЧДоИзменения = Новый Структура("Номенклатура, Прочее", Новый Структура("Номенклатура, Характеристика, ЕдИзмОрг, Коэффициент"), Новый Структура("Отмечен"));
    ЗаполнитьЗначенияСвойств(СтрокаТЧДоИзменения.Номенклатура,	ТабЧасть.ТекущиеДанные);
    ЗаполнитьЗначенияСвойств(СтрокаТЧДоИзменения.Прочее,		ТабЧасть.ТекущиеДанные);
КонецПроцедуры

&НаКлиенте
Процедура СбисСтрокаТабличнаяЧастьНоменклатураНачалоВыбора(ВходящийКэш, Элемент, СтандартнаяОбработка)
	
	Если Кэш = Неопределено Тогда
		Кэш = ВходящийКэш;
	КонецЕсли;

	фрм = Кэш.ГлавноеОкно.сбисНайтиФормуФункции("сбисТабличнаяЧастьНоменклатураНачалоВыбора","ФормаПросмотрДокумента","", Кэш);
	Если Не фрм = Ложь Тогда
		фрм.сбисТабличнаяЧастьНоменклатураНачалоВыбора(Кэш, ЭтаФорма, Элемент, СтандартнаяОбработка);
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура СбисСтрокаТабличнаяЧастьХарактеристикаНачалоВыбора(ВходящийКэш, Элемент, СтандартнаяОбработка) 
	
	Если Кэш = Неопределено Тогда
		Кэш = ВходящийКэш;
	КонецЕсли;

	СтандартнаяОбработка=Ложь;
	Если Не ЗначениеЗаполнено(сбисЭлементФормы(ЭтаФорма,"ТабличнаяЧасть").ТекущиеДанные.Номенклатура) Тогда
		Сообщить("Заполните номенклатуру");
	КонецЕсли;
	
	Если Кэш.Ини.Конфигурация.Свойство("ХарактеристикиНоменклатуры") Тогда
		ИмяСправочникаХарактеристикиНоменклатуры = СокрЛП(Сред(Кэш.Ини.Конфигурация.ХарактеристикиНоменклатуры.Значение, Найти(Кэш.Ини.Конфигурация.ХарактеристикиНоменклатуры.Значение, ".")+1));
	Иначе
		ИмяСправочникаХарактеристикиНоменклатуры="ХарактеристикиНоменклатуры";
	КонецЕсли;
	#Если ТолстыйКлиентОбычноеПриложение Тогда
		Форма = Справочники[ИмяСправочникаХарактеристикиНоменклатуры].ПолучитьФормуВыбора(,Элемент);
		Форма.ПараметрВыборПоВладельцу = сбисЭлементФормы(ЭтаФорма,"ТабличнаяЧасть").ТекущиеДанные.Номенклатура;
    #Иначе
		П = Новый Структура();
		Если Лев(ИмяОтбораХарактеристики,6) = "Отбор." Тогда
			ИмяОтбора = Сред(ИмяОтбораХарактеристики, 7);
			П.Вставить("Отбор", Новый Структура(ИмяОтбора,Элементы.ТабличнаяЧасть.ТекущиеДанные.Номенклатура));
		Иначе
			П.Вставить(ИмяОтбораХарактеристики, Элементы.ТабличнаяЧасть.ТекущиеДанные.Номенклатура);
		КонецЕсли;
		Форма = ПолучитьФорму("Справочник." + ИмяСправочникаХарактеристикиНоменклатуры + ".ФормаВыбора", П, Элемент);
	#КонецЕсли
	Форма.Открыть();
КонецПроцедуры

&НаКлиенте
Процедура СбисСтрокаТабличнаяЧастьЕдиницаНачалоВыбора(ВходящийКэш, Элемент, СтандартнаяОбработка) 
	
	Если Кэш = Неопределено Тогда
		Кэш = ВходящийКэш;
	КонецЕсли;

	СтандартнаяОбработка=Ложь;
	Если Не ЗначениеЗаполнено(сбисЭлементФормы(ЭтаФорма,"ТабличнаяЧасть").ТекущиеДанные.Номенклатура) Тогда
		Сообщить("Заполните номенклатуру");
	КонецЕсли;
	
	ИмяСправочникаЕдИзм = Кэш.ОбщиеФункции.РассчитатьЗначение("ЕдиницыИзмеренияНоменклатуры", Кэш.Ини.Конфигурация, Кэш);
	ИмяСправочникаКлассификаторЕдИзм = Кэш.ОбщиеФункции.РассчитатьЗначение("КлассификаторЕдиницИзмерения", Кэш.Ини.Конфигурация, Кэш);
	Если ЗначениеЗаполнено(ИмяСправочникаЕдИзм) Тогда
		ИмяСправочникаЕдиницыИзмеренияНоменклатуры = СокрЛП(Сред(ИмяСправочникаЕдИзм, Найти(ИмяСправочникаЕдИзм, ".")+1));
	ИначеЕсли ЗначениеЗаполнено(ИмяСправочникаКлассификаторЕдИзм) Тогда
		ИмяСправочникаЕдиницыИзмеренияНоменклатуры = СокрЛП(Сред(ИмяСправочникаКлассификаторЕдИзм, Найти(ИмяСправочникаКлассификаторЕдИзм, ".")+1));
	Иначе
		ИмяСправочникаЕдиницыИзмеренияНоменклатуры = Кэш.ОбщиеФункции.ТипСправочникаЕдиницПоМетаданным();
	КонецЕсли;
	
	#Если ТолстыйКлиентОбычноеПриложение Тогда
		Форма = Справочники[ИмяСправочникаЕдиницыИзмеренияНоменклатуры].ПолучитьФормуВыбора(,Элемент);
		Форма.ПараметрВыборПоВладельцу = сбисЭлементФормы(ЭтаФорма,"ТабличнаяЧасть").ТекущиеДанные.Номенклатура;
    #Иначе
		П = Новый Структура();
		Если Лев(ИмяОтбораХарактеристики,6) = "Отбор." Тогда
			ИмяОтбора = Сред(ИмяОтбораХарактеристики, 7);
			П.Вставить("Отбор", Новый Структура(ИмяОтбора,Элементы.ТабличнаяЧасть.ТекущиеДанные.Номенклатура));
		Иначе
			П.Вставить(ИмяОтбораХарактеристики, Элементы.ТабличнаяЧасть.ТекущиеДанные.Номенклатура);
		КонецЕсли;
		Форма = ПолучитьФорму("Справочник." + ИмяСправочникаЕдиницыИзмеренияНоменклатуры + ".ФормаВыбора", П, Элемент);
	#КонецЕсли
	Форма.Открыть();
	
КонецПроцедуры

&НаКлиенте
Процедура СбисСтрокаТабличнаяЧастьЕдИзмОргНачалоВыбора(ВходящийКэш, Элемент, СтандартнаяОбработка)      
	
	Если Кэш = Неопределено Тогда
		Кэш = ВходящийКэш;
	КонецЕсли;
	
	фрм = Кэш.ГлавноеОкно.сбисНайтиФормуФункции("сбисТабличнаяЧастьЕдИзмОргНачалоВыбора","ФормаПросмотрДокумента","", Кэш);
	Если Не фрм = Ложь Тогда
		фрм.сбисТабличнаяЧастьЕдИзмОргНачалоВыбора(Кэш, ЭтаФорма, Элемент, СтандартнаяОбработка);
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура СбисСтрокаТабличнаяЧастьКоэффициентНачалоВыбора(ВходящийКэш, Элемент, СтандартнаяОбработка)  
	
	Если Кэш = Неопределено Тогда
		Кэш = ВходящийКэш;
	КонецЕсли;

	
	фрм = Кэш.ГлавноеОкно.сбисНайтиФормуФункции("сбисТабличнаяЧастьКоэффициентНачалоВыбора","ФормаПросмотрДокумента","", Кэш);
	Если Не фрм = Ложь Тогда
		фрм.сбисТабличнаяЧастьЕдИзмОргНачалоВыбора(Кэш, ЭтаФорма, Элемент, СтандартнаяОбработка);
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура СбисВыбратьПочтовыйЯщик(ВходящийКэш, Элемент, ДопПараметры)
	
	
	Перем СписокЯщиков, ЭлементВыбораДефолт;
	
	Если Кэш = Неопределено Тогда
		Кэш = ВходящийКэш;
	КонецЕсли;

	Отказ = Ложь;
	ИнформацияОКонтрагенте = Кэш.ОбщиеФункции.ПолучитьИнформациюОКонтрагенте(Кэш, СоставПакета.Контрагент, Новый Структура("ДопПоля", "СписокИдентификаторов"), Отказ);
	Если Отказ Тогда
		Кэш.ГлавноеОкно.СбисСообщитьОбОшибке(Кэш, ИнформацияОКонтрагенте, Новый Структура("ФормаВладелец", ЭтаФорма));
		Возврат;
	КонецЕсли;
	Если	Не	ИнформацияОКонтрагенте.Свойство("Идентификатор", СписокЯщиков)
		Или	Не	ТипЗнч(СписокЯщиков) = Тип("Массив")
		Или		СписокЯщиков.Количество() < 2 Тогда
		Кэш.ГлавноеОкно.СбисСообщитьПользователю(Новый Структура("Текст, ФормаВладелец, ЭлементНазначения", "Указывать абонентский ящик не требуется", ЭтаФорма, "АбонентскийЯщик"), Кэш);
		Возврат;
	КонецЕсли;
	СписокВыбора		= Новый СписокЗначений;
	ЭлементВыбораДефолт = Неопределено;
	Для Каждого ЭлементЯщика Из СписокЯщиков Цикл
		ПредставлениеЯщика =	СтрЗаменить(СтрЗаменить(СтрЗаменить("{оператор}({идентификатор}) - {статус}", 
								"{оператор}", ЭлементЯщика.Оператор.Название), 
											"{идентификатор}", ЭлементЯщика.ИдентификаторУчастника),
														"{статус}", ЭлементЯщика.СостояниеПодключения.Описание);
		
		СписокВыбора.Добавить(ЭлементЯщика.ИдентификаторУчастника, ПредставлениеЯщика);
		Если НРег(ЭлементЯщика.Основной) = "да" Тогда
			ЭлементВыбораДефолт = СписокВыбора.НайтиПоЗначению(ЭлементЯщика.ИдентификаторУчастника);
		КонецЕсли;	
	КонецЦикла;
	СписокВыбора.Добавить("", "Определять автоматически");
	
	ПараметрыВыбораСписка = Новый Структура("Заголовок, Элемент, Обработчик", "Укажите абонентский ящик получателя", ЭлементВыбораДефолт, Кэш.ОбщиеФункции.СбисОписаниеОповещения(Кэш, "СбисВыбратьПочтовыйЯщик_Обработчик", ЭтаФорма, Новый Структура("Кэш", Кэш)));
	МодульОбъектаКлиент().СбисВыбратьИзСписка(СписокВыбора, ПараметрыВыбораСписка);
КонецПроцедуры

&НаКлиенте
Процедура СбисВыбратьПочтовыйЯщик_Обработчик(РезультатВыбора, ДопПараметры) Экспорт
	Если РезультатВыбора = Неопределено Тогда
		Возврат;
	КонецЕсли;
	АбонентскийЯщик = РезультатВыбора.Представление;
	СоставПакета.Контрагент.Вставить("Идентификатор", РезультатВыбора.Значение);
КонецПроцедуры

&НаКлиенте
Процедура СформироватьРасхождениеНажатие_Результат(РезультатОбработки, ДопПараметры) Экспорт

	Если РезультатОбработки = Неопределено Тогда
		
		Возврат;
		
	ИначеЕсли РезультатОбработки.Свойство("code") Тогда
		
		МодульОбъектаКлиент().СообщитьСбисИсключение(РезультатОбработки);
		Возврат;
		
	КонецЕсли;
	
	Если РезультатОбработки.Свойство("ЕстьРасхождения") И РезультатОбработки.ЕстьРасхождения Тогда
		СоставПакета.Вставить("ЕстьРасхождения", Истина);
	КонецЕсли;
	
	СоставПакета.Вложение.Добавить(РезультатОбработки);
	ЗаполнитьТаблицуДокументов(СоставПакета);

КонецПроцедуры                              

&НаКлиенте
Процедура УчетСторонаПриИзменении(Элемент)
	
	Сторона1С = ЭтаФорма[Элемент.Имя];

	Если Не ЗначениеЗаполнено(ДанныеСторон) Тогда
		Возврат;
	КонецЕсли;

	Если Элемент.Имя = "УчетОрганизация" Тогда
		СторонаДляИзменения = ДанныеСторон.ДанныеОрганизации;
		Тип = "НашаОрганизация";
		СторонаСБИС = СоставПакета.НашаОрганизация;
		ТипДанныхСтороны = "ДанныеОрганизации";
	ИначеЕсли Элемент.Имя = "УчетКонтрагент" Тогда
		СторонаДляИзменения = ДанныеСторон.ДанныеКонтрагента;
		Тип = "Контрагент";
		СторонаСБИС = СоставПакета.Контрагент;
		ТипДанныхСтороны = "ДанныеКонтрагента";
	ИначеЕсли Элемент.Имя = "УчетГрузополучатель" Тогда
		СторонаДляИзменения = ДанныеСторон.ДанныеГрузополучателя;
		Тип = "Контрагент";
		СторонаСБИС = МодульОбъектаКлиент().СоставПакета_Получить(СоставПакета, "Грузополучатель");
		ТипДанныхСтороны = "ДанныеГрузополучателя";
	Иначе
		Возврат;
	КонецЕсли;
	
	Если СторонаДляИзменения.Ссылка = Сторона1С Тогда 
		Возврат;
	КонецЕсли;
	
	СторонаДляИзменения.Ссылка = Сторона1С;
	ДанныеДляОбновления = Новый Структура;
	МестныйКэш.ОбщиеФункции.сбисСкопироватьСтруктуруНаКлиенте(ДанныеДляОбновления, СторонаДляИзменения);
	ДанныеДляОбновления.Вставить("Тип", Тип); 
	ДанныеДляОбновления.Вставить("ТипДанныхСтороны", ТипДанныхСтороны);
	ДопПараметры = Новый Структура("СторонаСБИС", СторонаСБИС);
	МодульОбъектаКлиент().Маппинг_ОбновитьСторону1С(ДанныеДляОбновления, ДопПараметры);
	
КонецПроцедуры   

&НаКлиенте
Процедура УстановитьВидимостьПоВложению(ВложениеСБИС)
	
	МодульТекущий		= МодульОбъектаКлиент();
	
	ВидимостьЕдиниц				= МодульТекущий.ПолучитьЗначениеПараметраСБИС("ЕстьЕдиницыНаФормеПросмотра");
	ВидимостьХарактеристик		= Ложь;
	ВидимостьСоздатьКонтрагент	= Ложь;

	ПараметрыПросмотр	= МодульТекущий.ВложениеСБИС_Получить(ВложениеСБИС, "Просмотр");
	Если ЗначениеЗаполнено(ПараметрыПросмотр) Тогда
		
		ВидимостьХарактеристик		= ПараметрыПросмотр.Свойство("ПараметрыНоменклатуры")
									И ПараметрыПросмотр.ПараметрыНоменклатуры.ЕстьХарактеристики;
								
		ВидимостьСоздатьКонтрагент	= ПараметрыПросмотр.Свойство("ПараметрыКонтрагент")
									И ПараметрыПросмотр.ПараметрыКонтрагент.ПоказатьСозданиеКарточки;
		
	КонецЕсли;
	
	СтатусВложение			= МодульТекущий.ВложениеСБИС_Получить(ВложениеСБИС, "Статус");
	ПредставлениеДокумента	= МодульТекущий.ВложениеСБИС_Получить(ВложениеСБИС, "ТекстHTML");
	
	Если Не ЗначениеЗаполнено(ПредставлениеДокумента) Тогда
		
		ПредставлениеДокумента = "<HTML><BODY scroll=no><table cellspacing=0 cellpadding=0 WIDTH=100%><tr><td id=Открыть><ins id=Открыть>Открыть в другой программе</ins></td></tr></table></BODY></HTML>";
		
	КонецЕсли;
	
	МодульТекущий.ИзменитьЭлементФормыОбработки(Новый ФиксированнаяСтруктура("Форма, Реквизит", ЭтаФорма, "ПолеHTMLДокумента"),
												Новый ФиксированнаяСтруктура("HTML", ПредставлениеДокумента));
												
	ГотовКЗагрузке				= СтатусВложение = "Разобран";
	ЗагрузкаПоддерживается		= ПараметрыРаботы.ЗагрузкаПоддерживается;
	// Старое обратное сопоставление
	СопоставлениеПередОтправкой	= Не МодульТекущий.ВложениеСБИС_Получить(ВложениеСБИС, "НоменклатураКодКонтрагента") = Неопределено;
												
	ДанныеПросмотраДокумента	= МодульТекущий.ВложениеСБИС_Получить(ВложениеСБИС, "Просмотр");
			
	ЭлементДокументПоле		= МодульТекущий.ПолучитьЭлементФормыОбработки(ЭтаФорма, "Документ1С");
	ЭлементДокументНадпись	= МодульТекущий.ПолучитьЭлементФормыОбработки(ЭтаФорма, "Документ1С.Надпись");
	
	Если ПараметрыРаботы.Свойство("ВариантыОбработкиДокумента") Тогда
		
		// Установить видимость выбора для варианта обработки документа
		ЭлементДекорация = МодульТекущий.ПолучитьЭлементФормыОбработки(ЭтаФорма, "Документ1СВыборВариантаСписок");
		
		ЭлементДокументПоле.Видимость		= Ложь;
		ЭлементДокументНадпись.Видимость	= Ложь;
		
		МодульТекущий.ПолучитьЭлементФормыОбработки(ЭтаФорма, "Дата1С").Видимость				= Ложь;
		МодульТекущий.ПолучитьЭлементФормыОбработки(ЭтаФорма, "Дата1С.Надпись").Видимость		= Ложь;
		
		ЭлементДекорация.Видимость = Истина;
		ЭлементДекорация.Заголовок = "Не установлен документ";
		
	Иначе
		
		
		Если	ГотовКЗагрузке
			И	ДанныеПросмотраДокумента.Свойство("ПараметрыДокумент") Тогда
			
			ПараметрыДокумент = ДанныеПросмотраДокумента.ПараметрыДокумент;
			ЭлементДокументНадпись.Заголовок = ПараметрыДокумент.Заголовок;
			ЭлементДокументПоле.Доступность = ПараметрыДокумент.Доступность;
			
		КонецЕсли;
		
		ЭлементДокументПоле.Видимость		= Истина;
		ЭлементДокументНадпись.Видимость	= Истина;
		
		МодульТекущий.ПолучитьЭлементФормыОбработки(ЭтаФорма, "Дата1С").Видимость							= Истина;
		МодульТекущий.ПолучитьЭлементФормыОбработки(ЭтаФорма, "Дата1С.Надпись").Видимость					= Истина;
		МодульТекущий.ПолучитьЭлементФормыОбработки(ЭтаФорма, "Документ1СВыборВариантаСписок").Видимость	= Ложь;
		
	КонецЕсли;
		
	Если	ГотовКЗагрузке Тогда	
		
		Если ЗагрузкаПоддерживается Тогда
		
			// Пакет разобран и загрузка поддерживается
			МодульТекущий.ПолучитьЭлементФормыОбработки(ЭтаФорма, "ПанельЗагрузка").Видимость	= Истина;
	 		МодульТекущий.ПолучитьЭлементФормыОбработки(ЭтаФорма, "СинонимДокумента").Видимость = Истина;

			МодульТекущий.ПолучитьЭлементФормыОбработки(ЭтаФорма, "ТабличнаяЧасть.Идентификатор").Видимость				= Истина;
	 		МодульТекущий.ПолучитьЭлементФормыОбработки(ЭтаФорма, "ТабличнаяЧасть.НоменклатураПоставщика").Видимость	= Истина;
	 		МодульТекущий.ПолучитьЭлементФормыОбработки(ЭтаФорма, "ТабличнаяЧасть.ХарактеристикаПоставщика").Видимость	= Истина;
			МодульТекущий.ПолучитьЭлементФормыОбработки(ЭтаФорма, "ТабличнаяЧасть.Характеристика").Видимость			= ВидимостьХарактеристик;	
	 		МодульТекущий.ПолучитьЭлементФормыОбработки(ЭтаФорма, "ТабличнаяЧасть.ЕдИзм").Видимость						= ВидимостьЕдиниц;
			МодульТекущий.ПолучитьЭлементФормыОбработки(ЭтаФорма, "ТабличнаяЧасть.Коэффициент"	).Видимость				= ВидимостьЕдиниц;
	 		МодульТекущий.ПолучитьЭлементФормыОбработки(ЭтаФорма, "ТабличнаяЧасть.Количество").Видимость				= Истина;
	 		МодульТекущий.ПолучитьЭлементФормыОбработки(ЭтаФорма, "ТабличнаяЧасть.Цена").Видимость						= Истина;
	 		МодульТекущий.ПолучитьЭлементФормыОбработки(ЭтаФорма, "ТабличнаяЧасть.СуммаБезНал").Видимость				= Истина;
	 		МодульТекущий.ПолучитьЭлементФормыОбработки(ЭтаФорма, "ТабличнаяЧасть.СтавкаНДС").Видимость					= Истина;
	 		МодульТекущий.ПолучитьЭлементФормыОбработки(ЭтаФорма, "ТабличнаяЧасть.СуммаНДС").Видимость					= Истина;
	 		МодульТекущий.ПолучитьЭлементФормыОбработки(ЭтаФорма, "ТабличнаяЧасть.Сумма").Видимость						= Истина;
			
		ИначеЕсли	СопоставлениеПередОтправкой Тогда	
			
			// Пакет разобран и требуется обратное сопоставление перед отправкой (старая логика)
			МодульТекущий.ПолучитьЭлементФормыОбработки(ЭтаФорма, "ПанельЗагрузка").Видимость	= Ложь;
			МодульТекущий.ПолучитьЭлементФормыОбработки(ЭтаФорма, "СинонимДокумента").Видимость = Ложь;

			МодульТекущий.ПолучитьЭлементФормыОбработки(ЭтаФорма, "ТабличнаяЧасть.Идентификатор").Видимость				= Истина;
	 		МодульТекущий.ПолучитьЭлементФормыОбработки(ЭтаФорма, "ТабличнаяЧасть.НоменклатураПоставщика").Видимость	= Ложь;
	 		МодульТекущий.ПолучитьЭлементФормыОбработки(ЭтаФорма, "ТабличнаяЧасть.ХарактеристикаПоставщика").Видимость	= Ложь;
			МодульТекущий.ПолучитьЭлементФормыОбработки(ЭтаФорма, "ТабличнаяЧасть.Характеристика").Видимость			= Ложь;	
	 		МодульТекущий.ПолучитьЭлементФормыОбработки(ЭтаФорма, "ТабличнаяЧасть.ЕдИзм").Видимость						= Ложь;
			МодульТекущий.ПолучитьЭлементФормыОбработки(ЭтаФорма, "ТабличнаяЧасть.Коэффициент"	).Видимость				= Ложь;
	 		МодульТекущий.ПолучитьЭлементФормыОбработки(ЭтаФорма, "ТабличнаяЧасть.Количество").Видимость				= Ложь;
	 		МодульТекущий.ПолучитьЭлементФормыОбработки(ЭтаФорма, "ТабличнаяЧасть.Цена").Видимость						= Ложь;
	 		МодульТекущий.ПолучитьЭлементФормыОбработки(ЭтаФорма, "ТабличнаяЧасть.СуммаБезНал").Видимость				= Ложь;
	 		МодульТекущий.ПолучитьЭлементФормыОбработки(ЭтаФорма, "ТабличнаяЧасть.СтавкаНДС").Видимость					= Ложь;
	 		МодульТекущий.ПолучитьЭлементФормыОбработки(ЭтаФорма, "ТабличнаяЧасть.СуммаНДС").Видимость					= Ложь;
	 		МодульТекущий.ПолучитьЭлементФормыОбработки(ЭтаФорма, "ТабличнаяЧасть.Сумма").Видимость						= Ложь;
		КонецЕсли;
		
		МодульТекущий.ПолучитьЭлементФормыОбработки(ЭтаФорма, "ПанельЗагрузкаЛево").Видимость = Истина;
 		МодульТекущий.ПолучитьЭлементФормыОбработки(ЭтаФорма, "НеНайденКонтрагент").Видимость = ВидимостьСоздатьКонтрагент;
		
	Иначе
		
		// Нет загрузки 
		МодульТекущий.ПолучитьЭлементФормыОбработки(ЭтаФорма, "ПанельЗагрузкаЛево").Видимость = Ложь;
		
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура УстановитьПолеДокумент1С_СписокВыбора(ВложениеСБИС)
	
	ПараметрыПросмотр			= МодульОбъектаКлиент().ВложениеСБИС_Получить(ВложениеСБИС, "Просмотр");
	РедактируемыеПоляВложения	= МодульОбъектаКлиент().ВложениеСБИС_Получить(ВложениеСБИС, "Поля1С");
	СписокВыбораОпераций	= Новый СписокЗначений;
	
	Если Не ЗначениеЗаполнено(ПараметрыПросмотр) Тогда
		Возврат;
	КонецЕсли;
		
	Если РедактируемыеПоляВложения.Документ = Неопределено Тогда
		
		// Для нередактируемых документов, нельзя изменить основной документ
		ОписаниеНоваяОперация	= Новый Структура("Доступность, Тип, Значение, Заголовок");
		ОписаниеНоваяОперация.Заголовок		= "Документ";
		ОписаниеНоваяОперация.Доступность	= Ложь;
		
		СписокВыбораОпераций.Добавить(ОписаниеНоваяОперация, ОписаниеНоваяОперация.Заголовок);

	Иначе
		
		ОписаниеНоваяОперация	= Новый Структура("Значение, Доступность, Тип, Заголовок");
		Если ЗначениеЗаполнено(РедактируемыеПоляВложения.Документ.Значение) Тогда
		
			ОписаниеНоваяОперация.Заголовок = "Документ";
			ЗаполнитьЗначенияСвойств(ОписаниеНоваяОперация, РедактируемыеПоляВложения.Документ);
			СписокВыбораОпераций.Добавить(ОписаниеНоваяОперация, "Указать существующий документ");
			ОписаниеНоваяОперация.Доступность = ВложениеСБИС.Параметры.РедактироватьСуществующий;

		Иначе
			
			Если ВложениеСБИС.Параметры.РедактироватьСуществующий Тогда
				
				Если РедактируемыеПоляВложения.Документ.Свойство("Ошибка") Тогда
					
					ИсключениеПодбораДокумента = МодульОбъектаКлиент().НовыйСбисИсключение
														(РедактируемыеПоляВложения.Документ.Ошибка,
														"ФормаПросмотрДокумента.УстановитьПолеДокумент1С_СписокВыбора",
														,
														"Ошибка поиска подходящего документа. Требуется установить документ вручную.");
					МодульОбъектаКлиент().СбисСообщить(ИсключениеПодбораДокумента);
					РедактируемыеПоляВложения.Документ.Удалить("Ошибка");
					
				КонецЕсли;
				ОписаниеНоваяОперация.Заголовок = "Новый документ";
				ЗаполнитьЗначенияСвойств(ОписаниеНоваяОперация, РедактируемыеПоляВложения.Номер);
				Если ОписаниеНоваяОперация.Доступность Тогда
					
					ОписаниеНоваяОперация.Заголовок = ОписаниеНоваяОперация.Заголовок + " №";
					
				КонецЕсли;
				СписокВыбораОпераций.Добавить(ОписаниеНоваяОперация, "Создать новый документ");
			
				ОписаниеНоваяОперация = Новый Структура("Тип, Доступность, Значение, Заголовок", РедактируемыеПоляВложения.Документ.Тип, Истина);
				ОписаниеНоваяОперация.Заголовок	= "Документ";
				ЗаполнитьЗначенияСвойств(ОписаниеНоваяОперация, РедактируемыеПоляВложения.Документ);
				
				ОписаниеНоваяОперация.Значение	= ОписаниеНоваяОперация.Тип.ПривестиЗначение();
				СписокВыбораОпераций.Добавить(ОписаниеНоваяОперация, "Указать существующий документ");
				
			Иначе
				
				ОписаниеНоваяОперация.Заголовок = "Новый документ";
				ЗаполнитьЗначенияСвойств(ОписаниеНоваяОперация, РедактируемыеПоляВложения.Документ);
				ОписаниеНоваяОперация.Доступность = Ложь;
				СписокВыбораОпераций.Добавить(ОписаниеНоваяОперация, "Создать новый документ");
				
			КонецЕсли;		

		КонецЕсли;
		
	КонецЕсли;
		
	Если СписокВыбораОпераций.Количество() > 1 Тогда
		
		ПараметрыРаботы.Вставить("ВариантыОбработкиДокумента", СписокВыбораОпераций);
		
	Иначе
		
		ПараметрыРаботы.Удалить("ВариантыОбработкиДокумента");
		Документ1СВыборВариантаСписокПослеДиалога(СписокВыбораОпераций[0]);
		
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура УстановитьДанныеПоВложению(ВложениеСБИС)
	
	МодульТекущий		= МодульОбъектаКлиент();
	СтатусВложение		= МодульТекущий.ВложениеСБИС_Получить(ВложениеСБИС, "Статус");
	
	ТабличнаяЧасть.Очистить();
	
	ЭлементСпискаСинонимы = МодульТекущий.ПолучитьЭлементФормыОбработки(ЭтаФорма, "СинонимДокумента");
	ЭлементСпискаСинонимы.СписокВыбора.Очистить();
	
	СинонимДокумента	= "";
	Договор1С			= "";
	Дата1С				= "";
	Контрагент1С		= "";	
	
	Если Не СтатусВложение = "Разобран" Тогда
		Возврат;
	КонецЕсли;
	
	НаправлениеВложение	= МодульТекущий.ВложениеСБИС_Получить(ВложениеСБИС, "Направление");
	УстановленныйРаздел	= МодульТекущий.ВложениеСБИС_Получить(ВложениеСБИС, "УстановленныйПодразделИни");
	
	Если УстановленныйРаздел = Неопределено Тогда
		
		Возврат;
		
	КонецЕсли;
	
	УстановитьОграничениеТипаРеквизитов(УстановленныйРаздел);
		
	Ини = МодульТекущий.ВложениеСБИС_Получить(ВложениеСБИС, "ФайлИни");
	Если Ини.Свойство("мДокумент") Тогда
		
		НазваниеТекущее = МестныйКэш.ОбщиеФункции.РассчитатьЗначение("Название", УстановленныйРаздел);
		Для Каждого ТипДокумент Из Ини.мДокумент Цикл
			Название	= МестныйКэш.ОбщиеФункции.РассчитатьЗначение("Название", ТипДокумент.Значение);
			Имя			= ТипДокумент.Ключ;
			
			СписокТиповДокументов.Добавить(Название, Имя);
			ЭлементСпискаСинонимы.СписокВыбора.Добавить(Название);
			
			Если Название = НазваниеТекущее Тогда
				
				СинонимДокумента = Название;
				
			КонецЕсли;
			
		КонецЦикла;
		
	КонецЕсли;

	ДанныеПросмотраДокумента = МодульТекущий.ВложениеСБИС_Получить(ВложениеСБИС, "Просмотр");
	
	// Данные промотра должна быть всегда, если установлена ини. Если нет - ошибка
	Если Не ДанныеПросмотраДокумента = Неопределено Тогда
		Если ДанныеПросмотраДокумента.Свойство("ПараметрыДокумент") Тогда
			
			Документ1СВыборВариантаУстановить(ВложениеСБИС, ДанныеПросмотраДокумента.ПараметрыДокумент);
			
		Иначе
			
			УстановитьПолеДокумент1С_СписокВыбора(ВложениеСБИС);
			
		КонецЕсли;
		
		РедактируемыеПоляВложения = МодульТекущий.ВложениеСБИС_Получить(ВложениеСБИС, "Поля1С");

		Если Не РедактируемыеПоляВложения = Неопределено Тогда 

			ПараметрыУстановить = РедактируемыеПоляВложения.Договор;
			Если Не ПараметрыУстановить = Неопределено Тогда
				Договор1С = ПараметрыУстановить.Значение;
				МодульТекущий.ПолучитьЭлементФормыОбработки(ЭтаФорма, "Договор1С").Доступность = ПараметрыУстановить.Доступность;
			КонецЕсли;
			
			ПараметрыУстановить = РедактируемыеПоляВложения.Дата;
			Если Не ПараметрыУстановить = Неопределено Тогда
				Дата1С = ПараметрыУстановить.Значение;
				МодульТекущий.ПолучитьЭлементФормыОбработки(ЭтаФорма, "Дата1С").Доступность = ПараметрыУстановить.Доступность;
			КонецЕсли;
			
			ПараметрыУстановить = РедактируемыеПоляВложения.Контрагент;
			Если Не ПараметрыУстановить = Неопределено Тогда
				Контрагент1С = РедактируемыеПоляВложения.Контрагент.Значение;
				МодульТекущий.ПолучитьЭлементФормыОбработки(ЭтаФорма, "Контрагент1С").Доступность = ПараметрыУстановить.Доступность;
			КонецЕсли;
			
		КонецЕсли;
		
	КонецЕсли;		
	// переделать
	ЗаполнитьДокументДаннымиЭД(ВложениеСБИС);
	ЗаполнитьТаблицуНоменклатуры(ВложениеСБИС);
			
КонецПроцедуры

// Процедура проверяет введенный номер госконтракта и изменяет его в документе СБИС
//
// Параметры:
//  Элемент	 - 	 - 
//  Текст	 - Строка - Строка текста, введенная в поле ввода.
//
&НаКлиенте
Процедура ИдентификаторГосконтрактаОкончаниеВводаТекста(Элемент, Текст)   
	
	Если СтрДлина(СокрЛП(Текст)) < 20 Тогда
		МодульОбъектаКлиент().СбисСообщить("№ контракта должен содержать от 20 до 25 символов"); 
		Возврат;
	КонецЕсли;  
	
	ПараметрыДокумента = Новый Структура("ИдентификаторГосконтракта", СокрЛП(Текст));
	
	Попытка
		МодульОбъектаКлиент().ИзменитьСкладскойПараметрДокумента(СоставПакета, ПараметрыДокумента);
	Исключение
		МодульОбъектаКлиент().СообщитьСбисИсключение(ИнформацияОбОшибке(), "ИдентификаторГосконтрактаОкончаниеВводаТекста");
	КонецПопытки;

КонецПроцедуры

