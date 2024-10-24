
/////////////////Списочные методы///////////////////

//Обрабатывает список документов по событиям с online.sbis.ru для реестра События
&НаКлиенте
Функция ОбработатьСписокСобытий(Кэш, СписокСобытий) Экспорт
	СтруктураДляОбновленияФормы = Новый Структура;
	ГлавноеОкно = Кэш.ГлавноеОкно;
	ГлавноеОкно.ФильтрЕстьЕще = СписокСобытий.Навигация.ЕстьЕще="Да";
	ГлавноеОкно.ФильтрСтраница = Число(СписокСобытий.Навигация.Страница)+1;
	Выборка = СписокСобытий.Реестр;
	Размер = Выборка.Количество();
	МассивДокументов = Новый Массив;	
	
	ДопПараметры = Новый Структура("МассивИдентификаторов, ТипРеестра, КлючОрганизации", Новый Массив, "События", "НашаОрганизация");
	Для сч = 0 По Размер - 1 Цикл
		ГлавноеОкно.сбисПоказатьСостояние("Получение данных с " + Кэш.СБИС.ПараметрыИнтеграции.ПредставлениеСервера, ГлавноеОкно, Мин(100,Окр((сч+1)*100/Размер)));
		
		оДокумент = Выборка[сч];
		НоваяСтр = ОбработатьСобытиеВРеестр(Кэш, оДокумент.Документ, ДопПараметры);
		НоваяСтр.Дата = оДокумент.ДатаВремя;
		МассивДокументов.Добавить(НоваяСтр);
	КонецЦикла;	
	Если ДопПараметры.МассивИдентификаторов.Количество() Тогда
		фрм = Кэш.ГлавноеОкно.сбисНайтиФормуФункции("ПолучитьТаблицуДокументов1СПоИдВложенияСБИС",Кэш.ФормаРаботыСоСтатусами,"",Кэш);
		фрм.ПолучитьТаблицуДокументов1СПоИдВложенияСБИС(МассивДокументов, ДопПараметры.МассивИдентификаторов, Кэш.Ини.Конфигурация, Кэш.Парам.КаталогНастроек);
	КонецЕсли;
	ГлавноеОкно.сбисСпрятатьСостояние(ГлавноеОкно);
	СтруктураДляОбновленияФормы.Вставить("Таблица_РеестрСобытий", МассивДокументов);
	Возврат СтруктураДляОбновленияФормы;
КонецФункции

//Обрабатывает список документов определенного типа с online.sbis.ru для реестра Документы	
&НаКлиенте
Функция ОбработатьСписокДокументов(Кэш, СписокДокументов) Экспорт
	СтруктураДляОбновленияФормы = Новый Структура;
	ГлавноеОкно = Кэш.ГлавноеОкно;
	Навигация = СписокДокументов.Навигация;
	ГлавноеОкно.ФильтрЕстьЕще =		Навигация.Свойство("ЕстьЕще")
								И	Навигация.ЕстьЕще = "Да";
	ГлавноеОкно.ФильтрСтраница = ?(Навигация.Свойство("Страница"), Число(Навигация.Страница)+1, 1);
	Выборка = СписокДокументов.Документ;
	Размер = Выборка.Количество();
	МассивДокументов = Новый Массив;
	ДопПараметры = Новый Структура("ТипРеестра, КлючОрганизации", "Документы", "Организация");
	Для сч = 0 По Размер - 1 Цикл
		ГлавноеОкно.сбисПоказатьСостояние("Получение данных с " + Кэш.СБИС.ПараметрыИнтеграции.ПредставлениеСервера, ГлавноеОкно, Мин(100,Окр((сч+1)*100/Размер)));
		МассивДокументов.Добавить(ОбработатьСобытиеВРеестр(Кэш, Выборка[сч], ДопПараметры));
	КонецЦикла;	
	Если Размер Тогда
		фрм = ГлавноеОкно.сбисНайтиФормуФункции("ПолучитьТаблицуДокументов1СПоИдПакетаСБИС",Кэш.ФормаРаботыСоСтатусами,"",Кэш);
		фрм.ПолучитьТаблицуДокументов1СПоИдПакетаСБИС(МассивДокументов, Кэш.Ини.Конфигурация, ГлавноеОкно.Кэш.Парам.КаталогНастроек);

	КонецЕсли;
	ГлавноеОкно.сбисСпрятатьСостояние(ГлавноеОкно);
	СтруктураДляОбновленияФормы.Вставить("Таблица_РеестрДокументов", МассивДокументов);
	Возврат СтруктураДляОбновленияФормы;
КонецФункции

//Обрабатывает список документов определенного типа с online.sbis.ru для реестра События	
&НаКлиенте
Функция ОбработатьСписокДокументовОтгрузки(Кэш, СписокДокументовОтгрузки) Экспорт
	СтруктураДляОбновленияФормы = Новый Структура;
	ГлавноеОкно = Кэш.ГлавноеОкно;
	ГлавноеОкно.ФильтрЕстьЕще = СписокДокументовОтгрузки.Навигация.ЕстьЕще="Да";
	ГлавноеОкно.ФильтрСтраница = Число(СписокДокументовОтгрузки.Навигация.Страница)+1;
	Выборка = СписокДокументовОтгрузки.Документ;
	Размер = Выборка.Количество();
	МассивДокументов = Новый Массив;	
	ДопПараметры = Новый Структура("МассивИдентификаторов, ТипРеестра, КлючОрганизации", Новый Массив, "События", "НашаОрганизация");
	Для сч = 0 По Размер - 1 Цикл
		ГлавноеОкно.сбисПоказатьСостояние("Получение данных с " + Кэш.СБИС.ПараметрыИнтеграции.ПредставлениеСервера, ГлавноеОкно, Мин(100,Окр((сч+1)*100/Размер)));
		МассивДокументов.Добавить(ОбработатьСобытиеВРеестр(Кэш, Выборка[сч], ДопПараметры));
	КонецЦикла;	
	Если ДопПараметры.МассивИдентификаторов.Количество() Тогда
		фрм = Кэш.ГлавноеОкно.сбисНайтиФормуФункции("ПолучитьТаблицуДокументов1СПоИдВложенияСБИС",Кэш.ФормаРаботыСоСтатусами,"",Кэш);
		фрм.ПолучитьТаблицуДокументов1СПоИдВложенияСБИС(МассивДокументов, ДопПараметры.МассивИдентификаторов, Кэш.Ини.Конфигурация, ГлавноеОкно.Кэш.Парам.КаталогНастроек);
		
	КонецЕсли;
	ГлавноеОкно.сбисСпрятатьСостояние(ГлавноеОкно);
	СтруктураДляОбновленияФормы.Вставить("Таблица_РеестрСобытий", МассивДокументов);
	Возврат СтруктураДляОбновленияФормы;
КонецФункции

//Обрабатывает полученное событие для реестра
//Кэш - структура кэша
//оДокумент - обрабатываемый документ СБИС
//ДопПараметры - структура, ключи:
//		1. МассивИдентификаторов - массив для поиска соответствующих документов 1С по завершении обработки всего реестра
//		2. ТипРеестра - "Документы/События"
//		3. КлючОрганизации - Организация/НашаОрганизация
&НаКлиенте
Функция ОбработатьСобытиеВРеестр(Кэш, оДокумент, ДопПараметры) Экспорт
	Перем СтатусГос, СбисРасширение, КодСостоянияОперации;
	НоваяСтр = Новый Структура("Проведен, Контрагент, Лицо2, Срок, " + ДопПараметры.КлючОрганизации, -1);   // alo Меркурий 
	НоваяСтр.Вставить("ИдСБИС",		оДокумент.Идентификатор);
	НоваяСтр.Вставить("Статус",		ОпределитьНомерСтатусаЭДПоПредставлению(оДокумент.Состояние.Название));
	НоваяСтр.Вставить("Дата",		оДокумент.Дата);
	НоваяСтр.Вставить("Номер",		оДокумент.Номер);
	НоваяСтр.Вставить("Сумма",		?(оДокумент.Свойство("Сумма"),оДокумент.Сумма,0)); 
	НоваяСтр.Вставить("Расхождение", Ложь);
	
	Если оДокумент.Свойство("Контрагент") Тогда
		НазваниеКонтрагента = СбисНазваниеСтороны(оДокумент.Контрагент);
		оДокумент.Контрагент.Вставить("Название", НазваниеКонтрагента);
		НоваяСтр.Контрагент = оДокумент.Контрагент.Название;
	Иначе
		оДокумент.Вставить("Контрагент", Новый Структура("Название", "Не определен"));
	КонецЕсли;
	
	Если оДокумент.Свойство("НашаОрганизация") Тогда
		
		НазваниеОрганизации = СбисНазваниеСтороны(оДокумент.НашаОрганизация);
		оДокумент.НашаОрганизация.Вставить("Название", НазваниеОрганизации);
		НоваяСтр[ДопПараметры.КлючОрганизации] = оДокумент.НашаОрганизация.Название;
		
	Иначе
		
		оДокумент.Вставить("НашаОрганизация", Новый Структура("Название", "Не определен"));
		
	КонецЕсли;
	
	Если	оДокумент.Свойство("Участники")
		И	оДокумент.Участники.Свойство("Лицо2") Тогда
		
		НоваяСтр.Лицо2 = СбисНазваниеСтороны(оДокумент.Участники.Лицо2);
		
	КонецЕсли;
	
	//СтатусВГосСистеме
	Если	оДокумент.Свойство("Расширение",	СбисРасширение) Тогда
		
		Если	СбисРасширение.Свойство("СостояниеМарк",СтатусГос)
			И	СтатусГос.Свойство("СостояниеОперации",			СтатусГос) Тогда //1189641556
			
			НоваяСтр.Вставить("СтатусВГосСистеме", СтатусГос); 
			
		//Прослеживаемой и маркируемой продукции, у одном документе, быть не может
		ИначеЕсли СбисРасширение.Свойство("СостояниеПросл",СтатусГос) 
			И СтатусГос.Свойство("КодСостоянияОперации", КодСостоянияОперации) Тогда 
			ПредставлениеСостояния = СостояниеПрослеживаемостиПоКоду(КодСостоянияОперации);
			НоваяСтр.Вставить("СтатусВГосСистеме", ПредставлениеСостояния); 
		Иначе
			НоваяСтр.Вставить("СтатусВГосСистеме", "");	
		КонецЕсли;
		
		Если	СбисРасширение.Свойство("СрокПоставки") Тогда
			НоваяСтр.Срок = оДокумент.Расширение.СрокПоставки;
		КонецЕсли;
		
		Если	СбисРасширение.Свойство("ЕстьРасхождения") Тогда 
			ЕстьРасхождения = МодульОбъектаКлиент().СоставПакета_Получить(оДокумент, "ЕстьРасхождения");
			НоваяСтр.Вставить("Расхождение", ЕстьРасхождения);
		КонецЕсли;
		
	КонецЕсли;
	
	Если оДокумент.Свойство("Ответственный") Тогда
		
		Отв = оДокумент.Ответственный.Фамилия;
		
		Если ЗначениеЗаполнено(оДокумент.Ответственный.Имя) Тогда
			
			Отв = Отв + " " + Лев(оДокумент.Ответственный.Имя, 1) + ".";
			
			Если ЗначениеЗаполнено(оДокумент.Ответственный.Отчество) Тогда
				Отв = Отв + Лев(оДокумент.Ответственный.Отчество, 1)+".";
			КонецЕсли;	
			
		КонецЕсли;	
		
		НоваяСтр.Вставить("Ответственный", Отв);
		
	ИначеЕсли оДокумент.Свойство("Подразделение") Тогда 
		
		НоваяСтр.Вставить("Ответственный", оДокумент.Подразделение.Название);
		
	Иначе
		
		НоваяСтр.Вставить("Ответственный", "");
		
	КонецЕсли;	
	
	НоваяСтр.Вставить("Документы1С", Новый СписокЗначений);
	
	Если ДопПараметры.ТипРеестра = "События" Тогда
		
		Вложения = "";
		счВложений = 0;
		
		Если оДокумент.Свойство("Вложение") Тогда
			
			Для Каждого Элемент Из оДокумент.Вложение Цикл
				
				Если		Элемент.Свойство("Служебный") 
					И Не	Элемент.Служебный = "Нет" Тогда
					
					Продолжить;
					
				КонецЕсли;
				
				счВложений = счВложений + 1;
				
				Если счВложений < 3 Тогда
					Вложения = Вложения + Элемент.Название+Символы.ПС;
				ИначеЕсли счВложений = 3 Тогда
					Вложения = Вложения + "..."+Символы.ПС;					
				КонецЕсли;
				
				ДопПараметры.МассивИдентификаторов.Добавить(Новый Структура("Ид, ИдВложения", оДокумент.Идентификатор, Элемент.Идентификатор));		
				
			КонецЦикла;
			
		КонецЕсли;
		//  << alo Меркурий
		
		Если Не	счВложений
			И	Кэш.Парам.Меркурий тогда
			
			ДопПараметры.МассивИдентификаторов.Добавить(Новый Структура("Ид, ИдВложения",оДокумент.Идентификатор, ""));
			
		КонецЕсли;		//  alo Меркурий >>
		
		Вложения = Вложения + ?(оДокумент.Состояние.Свойство("Примечание"), "   " + оДокумент.Состояние.Примечание, "");
		НоваяСтр.Вставить("Вложения", Вложения);
		
		Если оДокумент.Свойство("Подразделение") Тогда
			НоваяСтр.Вставить("Склад", оДокумент.Подразделение.Идентификатор);
		КонецЕсли;
		
	Иначе
		
		НоваяСтр.Вставить("Склад", ?(оДокумент.Свойство("Подразделение"),оДокумент.Подразделение.Название,""));
		
	КонецЕсли;
	
	СоставПакета = Новый СписокЗначений;
	СоставПакета.Добавить(оДокумент);
	НоваяСтр.Вставить("СоставПакета", СоставПакета); // нельзя положить сразу структуру, поэтому кладем ее в нулевой элемент списка
	
	//  << alo_ТекущийЭтап
	Если	оДокумент.свойство("Этап")
		И	оДокумент.Этап.Количество() Тогда
		
		НоваяСтр.Вставить("ТекущийЭтап", оДокумент.Этап[0].Название);
		
	Иначе 
		
		НоваяСтр.Вставить("ТекущийЭтап", оДокумент.Состояние.Название);
		
	КонецЕсли;
	//  alo_ТекущийЭтап >>
	
	НоваяСтр.Вставить("Комментарий", ?(оДокумент.Свойство("Примечание"),оДокумент.Примечание,""));
	Возврат НоваяСтр

КонецФункции

&НаКлиенте
Функция ПолучитьФильтрЗадач(Кэш, ДопПараметры=Неопределено) Экспорт
	// Формирует структуру фильтра для списочных методов SDK	
	Фильтр = Новый Структура; 
	
	Если Кэш.ПараметрыСистемы.Клиент.УправляемоеПриложение Тогда
		ЗначениеФильтраПериод	= Кэш.ГлавноеОкно.ФильтрПериод;
	Иначе
		ЗначениеФильтраПериод	= Кэш.ГлавноеОкно.ЭлементыФормы.ФильтрПериод.СписокВыбора.НайтиПоЗначению(Кэш.ГлавноеОкно.ФильтрПериод).Представление;
	КонецЕсли;
	Если Не ЗначениеФильтраПериод = "За весь период" Тогда
		Если ЗначениеЗаполнено(Кэш.ГлавноеОкно.ФильтрДатаКнц) Тогда
			Фильтр.Вставить("ДатаПо", Формат(Кэш.ГлавноеОкно.ФильтрДатаКнц, "ДФ=""гггг-ММ-дд"""));
		Иначе
			Фильтр.Вставить("ДатаПо", Формат(ТекущаяДата(),"ДФ=""гггг-ММ-дд"""));
		КонецЕсли;
		Если ЗначениеЗаполнено(Кэш.ГлавноеОкно.ФильтрДатаНач) Тогда
			Фильтр.Вставить("ДатаС", Формат(Кэш.ГлавноеОкно.ФильтрДатаНач, "ДФ=""гггг-ММ-дд"""));
		КонецЕсли;
	КонецЕсли;
	Фильтр.Вставить("Тип", Кэш.Текущий.ТипДок);
	//Если ГлавноеОкно.СписокСостояний.Количество()>0 и ГлавноеОкно.ФильтрСостояние<>ГлавноеОкно.СписокСостояний.НайтиПоИдентификатору(0).Значение Тогда
	//	фрм = ГлавноеОкно.сбисНайтиФормуФункции("ПолучитьСоответствиеЗначенийФильтра","Раздел_"+"Задачи"+"_"+"Задачи","Раздел_"+"Задачи"+"_Шаблон", ГлавноеОкно.Кэш);	
	//	СоответствиеЗначенийФильтра = фрм.ПолучитьСоответствиеЗначенийФильтра();
	//	Фильтр.Вставить( "ФильтрСостояние", СоответствиеЗначенийФильтра.НайтиПоЗначению(ГлавноеОкно.ФильтрСостояние).Представление ); 
	//КонецЕсли;
	//Если ЗначениеЗаполнено(ГлавноеОкно.ФильтрОрганизация) Тогда
	//	org = Новый Структура; 
	//	Если СтрДлина(СокрЛП(ПолучитьРеквизитОбъекта(ГлавноеОкно.ФильтрОрганизация, "ИНН"))) = 12 Тогда
	//		СвФЛ = Новый Структура;
	//		СвФЛ.Вставить( "ИНН", ПолучитьРеквизитОбъекта(ГлавноеОкно.ФильтрОрганизация, "ИНН") ); 
	//		org.Вставить( "СвФЛ", СвФЛ );	
	//	Иначе
	//		СвЮЛ = Новый Структура;
	//		СвЮЛ.Вставить( "ИНН", ПолучитьРеквизитОбъекта(ГлавноеОкно.ФильтрОрганизация, "ИНН") ); 
	//		СвЮЛ.Вставить( "КПП", ПолучитьРеквизитОбъекта(ГлавноеОкно.ФильтрОрганизация, "КПП") );
	//		org.Вставить( "СвЮЛ", СвЮЛ );
	//	КонецЕсли;
	//	Фильтр.Вставить( "ДокументНашаОрганизация", org ); 
	//КонецЕсли;
	//Если ЗначениеЗаполнено(ГлавноеОкно.ФильтрКонтрагент) Тогда
	//	kontr = Новый Структура; 
	//	ИННКонтр = ПолучитьРеквизитОбъекта(ГлавноеОкно.ФильтрКонтрагент, "ИНН");
	//	Если ТипЗнч(ИННКонтр)=Тип("Строка") Тогда // если выбрана папка контрагентов, то ИНН получается NaN
	//		Если СтрДлина(СокрЛП(ИННКонтр)) = 12 Тогда
	//			СвФЛ = Новый Структура;
	//			СвФЛ.Вставить( "ИНН", ПолучитьРеквизитОбъекта(ГлавноеОкно.ФильтрКонтрагент, "ИНН") ); 
	//			kontr.Вставить( "СвФЛ", СвФЛ );	
	//		Иначе
	//			СвЮЛ = Новый Структура;
	//			СвЮЛ.Вставить( "ИНН", ИННКонтр ); 
	//			СвЮЛ.Вставить( "КПП", ПолучитьРеквизитОбъекта(ГлавноеОкно.ФильтрКонтрагент, "КПП") );
	//			kontr.Вставить( "СвЮЛ", СвЮЛ );
	//		КонецЕсли;
	//		Фильтр.Вставить( "Отправитель", kontr );
	//	КонецЕсли;
	//КонецЕсли;
	//a.v. matyakin
	Если ЗначениеЗаполнено(Кэш.ГлавноеОкно.ФильтрМаска) Тогда
		Фильтр.Вставить("ФильтрПоМаске", Кэш.ГлавноеОкно.ФильтрМаска); 
	КонецЕсли;
	//
	Если ЗначениеЗаполнено(ДопПараметры) Тогда
		Для Каждого Элемент Из ДопПараметры Цикл
			Фильтр.Вставить( Элемент.Ключ, Элемент.Значение );	
		КонецЦикла;
	КонецЕсли;
	//ДопПоля, Фильтр, Сортировка, Навигация	
	navigation = Новый Структура; 
	navigation.Вставить("РазмерСтраницы",	Кэш.ГлавноеОкно.ЗаписейНаСтранице ); 
	navigation.Вставить("Страница",			Кэш.ГлавноеОкно.ФильтрСтраница-1 ); 
	
	Фильтр.Вставить("ДопПоля",		Новый Массив);
	Фильтр.Вставить("Сортировка",	Новый Массив);
	Фильтр.Вставить("Навигация",	navigation);
	//Результат.Добавить(Новый	Массив);
	//Результат.Добавить(filter);	
	//Результат.Добавить(Новый	Массив);
	//Результат.Добавить(navigation);
	
	Возврат Фильтр;	
КонецФункции

//Формирует структуру фильтра для списочных методов	
&НаКлиенте
Функция ПолучитьФильтрСобытий(Кэш, ДопПараметры) Экспорт
	
	Возврат МодульОбъектаКлиент().СформироватьФильтрДляРеестраОнлайна(Кэш.ГлавноеОкно, Новый Структура("ДопФильтры", ДопПараметры));
	
КонецФункции

//Получает список документов определенного типа с online.sbis.ru	
&НаКлиенте
Функция СбисПолучитьСписокЗадач(Кэш) Экспорт
	Отказ						= Ложь;
	ГлавноеОкно					= Кэш.ГлавноеОкно;
	Выборка						= Неопределено;
	СтруктураДляОбновленияФормы = Новый Структура("Таблица_РеестрСобытий");
	
	ГлавноеОкно.сбисПоказатьСостояние("Получение данных с " + Кэш.Сбис.ПараметрыИнтеграции.ПредставлениеСервера, ГлавноеОкно);
	ГлавноеОкно.ОтметитьВсе = Ложь;
	
	filter		= ПолучитьФильтрЗадач(Кэш);
	Результат	= Кэш.Интеграция.сбисПолучитьСписокЗадач(Кэш, filter, Отказ);
	Если Отказ Тогда
		ГлавноеОкно.сбисСпрятатьСостояние(ГлавноеОкно);
		ГлавноеОкно.сбисСообщитьОбОшибке(Кэш, Результат);
		Возврат СтруктураДляОбновленияФормы;
	ИначеЕсли	Не Результат.Свойство("Навигация")
		Или	Не Результат.Свойство("Реестр", Выборка) Тогда
		Возврат СтруктураДляОбновленияФормы;
	КонецЕсли;
	
	ГлавноеОкно.ФильтрСтраница = Число(Результат.Навигация.Страница) + 1;
	ГлавноеОкно.ФильтрЕстьЕще = Результат.Навигация.ЕстьЕще;
	
	Размер	= Выборка.Количество();
	
	МассивДокументов		= Новый Массив;	
	МассивИдентификаторов	= Новый Массив;
	Для сч = 0 По Размер - 1 Цикл
		ГлавноеОкно.сбисПоказатьСостояние("Получение данных с " + Кэш.Сбис.ПараметрыИнтеграции.ПредставлениеСервера, ГлавноеОкно, Мин(100,Окр((сч+1)*100/Размер)));
		
		оДокумент = Выборка[сч].Документ;     
		
		НоваяСтр = Новый Структура;
		//НоваяСтр.Вставить("Статус",			Кэш.ОбщиеФункции.ОпределитьНомерСтатусаЭДПоПредставлению(оДокумент.Состояние.Название));//???
		НоваяСтр.Вставить("Дата",			оДокумент.Дата);
		НоваяСтр.Вставить("Номер",			оДокумент.Номер);
		НоваяСтр.Вставить("ИдСБИС", 		оДокумент.Идентификатор);
		НоваяСтр.Вставить("Контрагент",		оДокумент.Контрагент.Название);
		НоваяСтр.Вставить("НашаОрганизация",оДокумент.НашаОрганизация.Название);
		НоваяСтр.Вставить("Статус",			ОпределитьНомерСтатусаЭДПоПредставлению(Строка(оДокумент.Состояние.Код)));
		
		Вложения		= "";
		счВложений		= 0;
		МассивВложений	= Новый	Массив;
		МассивИдентификаторов.Добавить(Новый Структура("Ид, ИдВложения", НоваяСтр.ИдСБИС, НоваяСтр.ИдСБИС));
		Для Каждого Элемент Из оДокумент.Вложение Цикл
			НазваниеВложения = Элемент.Название;
			Если Элемент.Служебный = "Да" Тогда
				Продолжить;
			КонецЕсли;
			ИдВложения = Неопределено;
			Если Не Элемент.Свойство("Идентификатор", ИдВложения) Тогда
				Продолжить;
			КонецЕсли;
			
			счВложений = счВложений + 1;
			Если счВложений < 3 Тогда
				Вложения = Вложения +НазваниеВложения+Символы.ПС;
			ИначеЕсли счВложений = 3 Тогда
				Вложения = Вложения + "..."+Символы.ПС;					
			КонецЕсли;
			МассивИдентификаторов.Добавить(Новый Структура("Ид, ИдВложения", НоваяСтр.ИдСБИС, ИдВложения));
			МассивВложений.Добавить(Новый Структура("Служебный,			Название,			Направление,	Идентификатор",
			Элемент.Служебный,	НазваниеВложения,	"Входящий",		ИдВложения));
		КонецЦикла;
		Если Не ЗначениеЗаполнено(Вложения) Тогда
			Вложения = оДокумент.Название;
		КонецЕсли;
		НоваяСтр.Вставить("Вложения",	Вложения);
		НоваяСтр.Вставить("Документы1С",Новый СписокЗначений);
		
		ВложениеСостав	= Новый	Структура("ИмяСБИС");
		ВложениеСостав.Вставить("Идентификатор",			НоваяСтр.ИдСБИС);
		ВложениеСостав.Вставить("Вложение",					МассивВложений);
		ВложениеСостав.Вставить("Название",					оДокумент.Название);
		ВложениеСостав.Вставить("СсылкаДляНашаОрганизация",	оДокумент.СсылкаДляНашаОрганизация);
		ВложениеСостав.Вставить("ИдСБИС",					оДокумент.ИдСБИС);
		ВложениеСостав.Вставить("ТекстЗадачи",				"");
		//TODO42 спилить проверку, всегда брать из оДокумент
		оДокумент.Свойство("ИмяСБИС", ВложениеСостав.ИмяСБИС);
		//ВложениеСостав.Вставить("ТекстЗадачи",				оДокумент.taskDescription);???
		
		СоставПакета	= Новый СписокЗначений;
		СоставПакета.Вставить(0,ВложениеСостав);
		НоваяСтр.Вставить("СоставПакета",	СоставПакета); // нельзя положить сразу структуру, поэтому кладем ее в нулевой элемент списка
		НоваяСтр.Вставить("ТекущийЭтап", 	оДокумент.Этап.Название);
		
		НоваяСтр.Вставить("Комментарий",	оДокумент.Примечание);
		НоваяСтр.Вставить("Проведен",		-1);
		МассивДокументов.Добавить(НоваяСтр);
	КонецЦикла;
	Если МассивИдентификаторов.Количество()>0 Тогда
		фрм = ГлавноеОкно.сбисНайтиФормуФункции("ПолучитьТаблицуДокументов1СПоИдВложенияСБИС",Кэш.ФормаРаботыСоСтатусами,"",Кэш);
		фрм.ПолучитьТаблицуДокументов1СПоИдВложенияСБИС(МассивДокументов, МассивИдентификаторов, Кэш.Ини.Конфигурация, Кэш.Парам.КаталогНастроек);
	КонецЕсли;
	ГлавноеОкно.сбисСпрятатьСостояние(ГлавноеОкно);
	СтруктураДляОбновленияФормы.Вставить("Таблица_РеестрСобытий", МассивДокументов);
	Возврат СтруктураДляОбновленияФормы;
КонецФункции

#Область include_core2_vo2_ОбщиеФункции_Прочее_СписочныеМетоды_Реестр1С
#КонецОбласти

