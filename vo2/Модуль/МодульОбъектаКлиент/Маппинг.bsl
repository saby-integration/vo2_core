
// Проверяет на работу по проекту контрагентов
//
// Параметры:
//  Данные	- Структура	- Структура с обязательным полем Вложения
//  ДопПараметры	- Структура, Неопределено	- Допоплнительные параметры расчетов
//
// Возвращаемое значение:
//  Булево	- Применять загрузку по проекту контрагентов или нет
//
&НаКлиенте
Функция ПрименятьФункционалНовыеКонтрагенты(Данные, ДопПараметры = Неопределено) Экспорт

	// Если вдруг работем с коннектом
	Если НЕ ПолучитьЗначениеПараметраСБИС("ДоступныСерверныеНастройки") Тогда
		Возврат Ложь;
	КонецЕсли;

	ФорматыДокументов = ПолучитьЗначениеПараметраСбис("ДокументыДляНовыхКонтрагентов");
	
	Если Данные.Свойство("Вложения")
		И ТипЗнч(Данные.Вложения) = Тип("Структура") Тогда
		
		МассивВложений = Новый Массив;
		МассивВложений.Добавить(Данные.Вложения);
	ИначеЕсли Данные.Свойство("Вложения")
		И ТипЗнч(Данные.Вложения) = Тип("Массив") Тогда
		МассивВложений = Данные.Вложения;
	ИначеЕсли Данные.Свойство("СоставПакета")
		И Данные.СоставПакета.Свойство("Вложение") Тогда
		МассивВложений = Данные.СоставПакета.Вложение;
	Иначе
		Возврат Ложь;
	КонецЕсли;
	
	Результат = Ложь;
	Для Каждого Вложение Из МассивВложений Цикл
		
		Для Каждого ДостуныйФормат Из ФорматыДокументов Цикл 
			
			ФорматТекущегоВложения = ФорматВложения(Вложение);
			Если ДостуныйФормат = ФорматТекущегоВложения Тогда
				Результат = Истина;
				Прервать;
			КонецЕсли;
			
		КонецЦикла;
		
		Если Результат Тогда
			Прервать;
		КонецЕсли;
		
	КонецЦикла;
	
	Возврат Результат;

КонецФункции // ПрименятьФункционалНовыеКонтрагенты()

&НаКлиенте
Функция ФорматВложения(Вложение)

	ПредставлениеТипа = ?(Вложение.Тип = Неопределено, "", Вложение.Тип)
		+ "_" + ?(Вложение.ВерсияФормата = Неопределено, "", Вложение.ВерсияФормата);
	
	Возврат ГлобальныйКэш.ТекущийСеанс.Модули.ФункцииДокументов.СбисЗаменитьНедопустимыеСимволы(ПредставлениеТипа);

КонецФункции

// Вызывает поиск массива сторон по их данным
//
// Параметры:
//  ДанныеДляПоиска  - Массив - Тип элементов - Структура, содержащие 
//                 ИНН, КПП, Тип, ВидИД (0 - 1С, 1 - СБИС), КодФилиала, GLN
//  ДопПараметры  - Неопределено - Прозапас
//
// Возвращаемое значение:
//   Массив   - Объекты маппинга
//
&НаКлиенте
Функция НайтиСтороныНаМаппинге(ДанныеДляПоиска, ДопПараметры = Неопределено) Экспорт
	
	Отказ = Ложь;
	ConnectionId = ПолучитьИдКоннекшена(Отказ);

	Если Отказ ИЛИ НЕ ЭтоУникальныйИдентификатор(ConnectionId) Тогда

		СбисИсключение = НовыйСбисИсключение(ConnectionId, "МодульОбъектаКлиента.НайтиСтороныНаМаппинге");
		СбисСтатистика_СформироватьИЗаписать(Новый Структура("Действие, Ошибка", "Ошибка", СбисИсключение));
		Возврат Ложь;

	КонецЕсли;
	
	ПараметрыПолучения = Новый Структура;
	
	ПараметрыПолучения.Вставить("ConnectionId",	ConnectionId);
	ПараметрыПолучения.Вставить("IdType",		ДопПараметры.ВидИД);
	ПараметрыПолучения.Вставить("Filter",		Новый Массив);
	
	Для Каждого Сторона Из ДанныеДляПоиска Цикл

		ПараметрыПолучения.Filter.Добавить(ДанныеПолученияМаппингаСтороны(Сторона));

	КонецЦикла;
	
	Кэш = ПолучитьТекущийЛокальныйКэш();
	СопоставленныеДанныеСторон = ГлобальныйКэш.ТекущийСеанс.Модули.Интеграция.СБИС_ПолучитьСопоставлениеСторон(Кэш, ПараметрыПолучения, , Отказ);
	
	Если Отказ Тогда

		Возврат Ложь;

	КонецЕсли; 
	
	Возврат СопоставленныеДанныеСторон;

КонецФункции // НайтиМаппингОбъекты()

&НаКлиенте
Функция ДанныеПолученияМаппингаСтороны(ДанныеСтороны)
	
	Результат = Новый Структура;
	Результат.Вставить("Type", ДанныеСтороны.Тип);
	СведенияОСтороне = ДанныеСтороны.Данные;

	Если ТипЗнч(СведенияОСтороне) <> Тип("Структура") Тогда
		Возврат Результат;
	КонецЕсли;
	
	Если СведенияОСтороне.Свойство("ИНН") Тогда
		
		Результат.Вставить("Key1_1", СведенияОСтороне.ИНН);
		
	Иначе
		
		Возврат Результат;
		
	КонецЕсли;
	
	Если СведенияОСтороне.Свойство("КПП") Тогда
		Результат.Вставить("Key1_2", СведенияОСтороне.КПП);
	КонецЕсли;
	
	Если СведенияОСтороне.Свойство("КодФилиала") Тогда
		Результат.Вставить("Key1_3", СведенияОСтороне.КодФилиала);
	КонецЕсли;
	
	Если СведенияОСтороне.Свойство("GLN") Тогда
		Результат.Вставить("Key2", СведенияОСтороне.GLN);
	КонецЕсли;
	
	Если СведенияОСтороне.Свойство("Тип1С") Тогда
		Результат.Вставить("ClientType", СведенияОСтороне.Тип1С);
	КонецЕсли;
	Возврат Результат;
	
КонецФункции

// Находит запись в маппинге и обновляет поля в ней
//
// Параметры:
//  Данные  - Структура - Структура, содержащая сведения стороны,
//                 и объект маппинга.
//  ДопПараметры  - Структура - Дополнительные параметры расчетов.
//
// Возвращаемое значение:
//   Булево   - Успех операции
//
&НаКлиенте
Функция НайтиОбновитьСторонуМаппинга(Данные, ДопПараметры) Экспорт

	Кэш = ПолучитьТекущийЛокальныйКэш();
	ИниКонфигурации = ИниПоПараметрам("Конфигурация");
	Сторона = Данные.СведенияСтороны;
	ОбъектМаппинга = Данные.ОбъектМаппинга;
	
	Отказ = Ложь;
	ConnectionId = ПолучитьИдКоннекшена(Отказ);

	Если Отказ ИЛИ НЕ ЭтоУникальныйИдентификатор(ConnectionId) Тогда

		СбисИсключение = НовыйСбисИсключение(ConnectionId, "МодульОбъектаКлиент.НайтиОбновитьСторонуМаппинга");
		СбисСтатистика_СформироватьИЗаписать(Новый Структура("Действие, Ошибка", "Ошибка", СбисИсключение));
		Возврат Ложь;

	КонецЕсли;
	
	Фильтр = Новый Структура;
	Фильтр.Вставить("ConnectionId", ConnectionId);
	Фильтр.Вставить("IdType", ?(ДопПараметры.ВидОбъекта = "Client", 0, 1));
	Фильтр.Вставить("Id", ОбъектМаппинга[?(ДопПараметры.ВидОбъекта = "Client", "Client", "Sbis") + "Id"]);
	
	ДанныеСтороны = Новый Структура;
	
	Если Сторона.Свойство("Тип") Тогда
		ТипОбъекта = Сторона.Тип;
	ИначеЕсли ТипЗнч(Сторона.Ссылка) = Тип(СтрЗаменить(ИниКонфигурации.Организации.Значение, ".", "Ссылка."))  Тогда
		ТипОбъекта = "НашаОрганизация";
	Иначе
		ТипОбъекта = "Контрагент";
	КонецЕсли;
	
	ОписаниеОрганизации	= ИниКонфигурации.Организации.Значение;
	ОписаниеКонтрагента	= ИниКонфигурации.Организации.Значение;
	ОписаниеПартнера	= ИниКонфигурации.Организации.Значение;

	ТипыСторон = Новый Соответствие;
	ТипыСторон.Вставить(Тип(СтрЗаменить(ОписаниеОрганизации, ".", "Ссылка.")),	СтрЗаменить(ОписаниеОрганизации, ".", "и."));
	ТипыСторон.Вставить(Тип(СтрЗаменить(ОписаниеКонтрагента, ".", "Ссылка.")),	СтрЗаменить(ОписаниеКонтрагента, ".", "и."));
	ТипыСторон.Вставить(Тип(СтрЗаменить(ОписаниеПартнера, ".", "Ссылка.")),		СтрЗаменить(ОписаниеПартнера, ".", "и."));

	Тип1С = ТипыСторон.Получить(ТипЗнч(Сторона.Ссылка));
		
	Фильтр.Вставить("Type", ТипОбъекта);
	
	Если ТипЗнч(Сторона) <> Тип("Структура")
		ИЛИ Сторона.Свойство("ИНН") Тогда
		Возврат Ложь;
	КонецЕсли;
	
	ПоляСторон = Новый Соответствие;
	ПоляСторон.Вставить("ИНН",			ДопПараметры.ВидОбъекта + "Param_1_1");
	ПоляСторон.Вставить("КПП",			ДопПараметры.ВидОбъекта + "Param_1_2");
	ПоляСторон.Вставить("КодФилиала",	ДопПараметры.ВидОбъекта + "Param_1_3");
	ПоляСторон.Вставить("GLN",			ДопПараметры.ВидОбъекта + "Param_2");
	ПоляСторон.Вставить("Тип1С",		"ClientType");
	
	Для каждого СопоставлениеПолей Из ПоляСторон Цикл
		Если Сторона.Свойство(СопоставлениеПолей.Ключ) Тогда
			ДанныеСтороны.Вставить(СопоставлениеПолей.Значение, Сторона[СопоставлениеПолей.Ключ]);
		КонецЕсли;
	КонецЦикла;
	
	Если ДопПараметры.ВидОбъекта = "Client" Тогда

		ДанныеСтороны.Вставить("ClientId", Строка(Сторона.Ссылка.УникальныйИдентификатор()));
		ДанныеСтороны.Вставить("ClientName", Строка(Сторона.Ссылка));
		ДанныеСтороны.Вставить("ClientType", Тип1С);

	Иначе

		ДанныеСтороны.Вставить("SbisId", Сторона.Id);
		ДанныеСтороны.Вставить("SbisName", Сторона.Name);

	КонецЕсли;
	
	ДанныеСтороны.Вставить("Status", 1);
	ДанныеСтороны.Вставить("Status_msg", "Сопоставлено");
	
	Отказ = Ложь;
	СопоставленныеДанныеСторон = ГлобальныйКэш.ТекущийСеанс.Модули.Интеграция.ОбновитьЗаписьСопоставления(Кэш, Фильтр, ДанныеСтороны, Отказ);
	
	Если Отказ Тогда   
		
		ВызватьСбисИсключение(СопоставленныеДанныеСторон, ГлобальныйКэш.СБИС.ПараметрыИнтеграции.ИнтеграцияИмя + ".СБИС_ПолучитьСопоставлениеСторон");
		Возврат Ложь;

	КонецЕсли;

	Возврат Истина;

КонецФункции // НайтиОбновитьСторонуМаппинга()

&НаСервереБезКонтекста
Функция ПолучитьУчастникаПоИд(Идентификатор, ТипСтороны)

	Возврат Справочники[Сред(ТипСтороны, Найти(ТипСтороны, ".") + 1)].ПолучитьСсылку(Новый УникальныйИдентификатор(Идентификатор));

КонецФункции

Функция ОтобратьСтрокуМаппингаПоТипу(МассивСторон, ТипСтороны)
	
	Если Не МассивСторон = Ложь
		И МассивСторон.Количество() Тогда 
		
		Для Каждого СопоставленнаяСторона Из МассивСторон Цикл
			Если Не ЗначениеЗаполнено(СопоставленнаяСторона.ClientType) Тогда
				Продолжить;
			КонецЕсли;
			
			Если ТипСтороны = Тип(СтрЗаменить(СопоставленнаяСторона.ClientType, "и.", "Ссылка.")) Тогда
				Возврат СопоставленнаяСторона;
			КонецЕсли;
		КонецЦикла;
	КонецЕсли;
	
	Возврат Неопределено;

КонецФункции

// Сохраняет сопоставление сторона в маппинге
//
// Параметры:
//  СведенияМаппинга  - Структура - Сведения о контрагенте/организации
//  ДопПараметры  - Структура - Дополнительные параметры вычисления
//                 <продолжение описания параметра>
//
// Возвращаемое значение:
//  Булево	- Успешность операции
//
&НаКлиенте
Функция Маппинг_ОбновитьСторону1С(СведенияМаппинга, ДопПараметры = Неопределено) Экспорт 

	ОбщиеФункции = ГлобальныйКэш.ТекущийСеанс.Модули.ФункцииДокументов;
    
	ПараметрыПолучения = Новый Массив;  
	ТипыДанныхСторон = ТипыСторонДляМаппинга();
	
	ПараметрыПолучения.Добавить(СведенияМаппинга);   
	СведенияМаппинга.Вставить("Тип1С",	ТипыДанныхСторон[СведенияМаппинга.ТипДанныхСтороны]);	
	
	СопоставленныеДанныеСторон = НайтиСтороныНаМаппинге(ПараметрыПолучения, Новый Структура("ВидИД", 1));
	
	СтрокаМаппинга = ОтобратьСтрокуМаппингаПоТипу(СопоставленныеДанныеСторон, ТипЗнч(СведенияМаппинга.Ссылка));
	
	СтруктураДокумента = Новый Структура("ИмяСБИС", СведенияМаппинга.Тип);
	СтруктураОбъекта1С = ОбщиеФункции.СбисПолучитьСтруктуруОбъекта1С(СведенияМаппинга.Ссылка, СтруктураДокумента, Ложь);     
	
	СведенияОбъектаСБИС = Новый Структура;
	ОбщиеФункции.сбисСкопироватьСтруктуруНаКлиенте(СведенияОбъектаСБИС, СведенияМаппинга);  
	
	СБИС_UUID = "";
	
	Если ТипЗнч(СтрокаМаппинга) = Тип("Структура")
		И СтрокаМаппинга.Свойство("UUID") Тогда
		
		СБИС_UUID = СтрокаМаппинга.UUID;
		
	КонецЕсли;
	
	Если ТипЗнч(СтрокаМаппинга) = Тип("Структура")
		И СтрокаМаппинга.Свойство("SbisId")
		И ЗначениеЗаполнено(СтрокаМаппинга.SbisId) Тогда
		
		СведенияОбъектаСБИС.Вставить("ИдСБИС", СтрокаМаппинга.SbisId);
		
	Иначе  
		
		ОбъектAPI = ПолучитьAPIОбъектСтороны(СведенияМаппинга.Тип, СведенияМаппинга.Данные);
		
		Если Не (ТипЗнч(ОбъектAPI) = Тип("Массив")
			И ОбъектAPI.Количество()) Тогда 
			
			Возврат Ложь;
		КонецЕсли;

		СведенияОбъектаСБИС.Вставить("ИдСБИС", ОбъектAPI[0].ИдСБИС);
	
	КонецЕсли;         
	
	СведенияОбъектаСБИС.Вставить("Название", ОбщиеФункции.сбисНазваниеСтороны(СведенияМаппинга.Сторона));
	
	ДанныеСтороны = Новый Структура;
	ДанныеСтороны.Вставить("СБИС",		СведенияОбъектаСБИС);
	ДанныеСтороны.Вставить("ИС",		СтруктураОбъекта1С);
	ДанныеСтороны.Вставить("УИД",		СБИС_UUID);
	ДанныеСтороны.Вставить("Статус",	Новый Структура("Ид, Сообщение", 1, "Сопоставлено"));
	РезультатОбновления = Маппинг_ОбновитьИзДанныхСтороны(СведенияМаппинга.Тип, ДанныеСтороны);
	
	Если НЕ ТипЗнч(РезультатОбновления) = Тип("Число") 
		ИЛИ НЕ СведенияОбъектаСБИС.Тип = "Контрагент" Тогда
		Возврат Истина;
	КонецЕсли;
	
	СовпадаютКА_ГП = ТипыДанныхСторон.ДанныеГрузополучателя = ТипыДанныхСторон.ДанныеКонтрагента;

	Действия = Новый Соответствие;
	Действия.Вставить("ДанныеКонтрагента", "Контрагент сопоставлен");
	Действия.Вставить("ДанныеГрузополучателя", ?(СовпадаютКА_ГП, "Партнер", "Контрагент") + " сопоставлен");

	ЗаписьПрикладнойСтатистики = НовыйЗаписьПрикладнойСтатистики(Действия[СведенияМаппинга.ТипДанныхСтороны], "Загрузка заказа");
	ПрикладнаяСтатистика = НовыйПрикладнаяСтатистика();
	ПрикладнаяСтатистика_Добавить(ПрикладнаяСтатистика, ЗаписьПрикладнойСтатистики);
	ПрикладнаяСтатистика_Отправить(ПрикладнаяСтатистика);

	Возврат Истина;

КонецФункции // Маппинг_ОбновитьСторону1С()

// Возвращает результат метода MappingObject.List
//
// Параметры:
//  ПараметрыСписка  - Структура - Параметры маппинга:
//					Тип - Тип MappingObject
//					ФильтрГлавноеОкно - Параметры фильра с главного окна
//  ДопПараметры  - Структура, Неопределено - Дополнительные параметры
//                 (ДопПоля - получение дополнительынх полей)
//
// Возвращаемое значение:
//   Массив   - Список маппинг объектов
//
&НаКлиенте
Функция ПолучитьСписокМаппинга(ПараметрыСписка, ДопПараметры = Неопределено) Экспорт 

	Перем ДопПоля;
	       
	Отказ = Ложь;
	ConnectionId = ПолучитьИдКоннекшена(Отказ);

	Если Отказ ИЛИ НЕ ЭтоУникальныйИдентификатор(ConnectionId) Тогда                                                                                              
		СбисИсключение = НовыйСбисИсключение(ConnectionId, "МодульОбъектаКлиент.ПолучитьСписокМаппинга");
		СбисСтатистика_СформироватьИЗаписать(Новый Структура("Действие, Ошибка", "Ошибка", СбисИсключение));
        СписокМаппинга = Новый Структура("Данные, Навигация", Новый Массив, Новый Структура);
        СписокМаппинга.Навигация.Вставить("ЕстьЕще", Ложь);
		Возврат СписокМаппинга;
	КонецЕсли;
	
	Фильтр = Новый Структура;       
	Фильтр.Вставить("ConnectionId",	ConnectionId);
	Фильтр.Вставить("SettingId",	ПараметрыСписка.Тип);  
	Если ЗначениеЗаполнено(ПараметрыСписка.ФильтрГлавноеОкно.ФильтрРодитель) Тогда
		Фильтр.Вставить("ClientParentUid", ПараметрыСписка.ФильтрГлавноеОкно.ФильтрРодитель);
	КонецЕсли; 
	
	Навигация = Новый Структура;
	Навигация.Вставить("PageSize",	ПараметрыСписка.ФильтрГлавноеОкно.ЗаписейНаСтранице);
	Навигация.Вставить("Page",		ПараметрыСписка.ФильтрГлавноеОкно.ФильтрСтраница); 
	
	Если	ТипЗнч(ДопПараметры) = Тип("Структура")
		И	ДопПараметры.Свойство("ДопПоля") Тогда
		ДопПоля = ДопПараметры.ДопПоля;
	КонецЕсли;
	
	Отказ = Ложь;
	Кэш = ПолучитьТекущийЛокальныйКэш();
	СписокМаппинга = ГлобальныйКэш.ТекущийСеанс.Модули.Интеграция.MappingObject_List(Кэш, ДопПоля, Фильтр, Навигация, Отказ);
	
	Если Отказ Тогда

        СписокМаппинга = Новый Структура("Данные, Навигация", Новый Массив, Новый Структура);
        СписокМаппинга.Навигация.Вставить("ЕстьЕще", Ложь);

	КонецЕсли;
	
	Возврат СписокМаппинга;

КонецФункции // ПолучитьСписокМаппинга()

&НаКлиенте
Процедура ОбогатитьОбъектМаппинга(СтруктураОбъекта, СторонаСБИС)
	
	СведенияОСтороне = Неопределено;
	Если Не СторонаСБИС.Свойство("СвЮЛ", СведенияОСтороне) Тогда 
		СведенияОСтороне = СторонаСБИС.СвФЛ;
	КонецЕсли;
	
	СтруктураОбъекта.ИНН = СведенияОСтороне.ИНН;
	СтруктураОбъекта.Название = ГлобальныйКэш.ТекущийСеанс.Модули.ФункцииДокументов.сбисНазваниеСтороны(СторонаСБИС);
	
	Если СведенияОСтороне.Свойство("КПП") Тогда  
		СтруктураОбъекта.Вставить("КПП", СведенияОСтороне.КПП);
	Иначе
		СтруктураОбъекта.Вставить("КПП", "");
	КонецЕсли; 
	
	Если СторонаСБИС.Свойство("КодФилиала") Тогда  
		СтруктураОбъекта.Вставить("КодФилиала", СторонаСБИС.КодФилиала);
	Иначе
		СтруктураОбъекта.Вставить("КодФилиала", "");
	КонецЕсли;

КонецПроцедуры // ОбогатитьОбъектМаппинга()

&НаКлиенте 
Функция ПолучитьТип1СДляМаппинга(ИниКонфигурации, ИмяУзла)
	
	Если ИниКонфигурации.Свойство(ИмяУзла) Тогда
		ЗначениеУзла = СтрЗаменить(ИниКонфигурации[ИмяУзла].Значение, """", "");
	Иначе
		ЗначениеУзла = "";
	КонецЕсли;
	
	Попытка
		Если Лев(ЗначениеУзла, 1) = "[" Тогда
			Результат =  ПолучитьТипМетаданных(ИниКонфигурации,	Сред(ЗначениеУзла, 2, Найти(ЗначениеУзла, "]") - 2));
		ИначеЕсли	ТипЗнч(ЗначениеУзла) = Тип("Строка")
			И		Найти(ЗначениеУзла, ".") Тогда 
			      
			Если Лев(ЗначениеУзла, 10) = "Справочник" Тогда                      
				Результат = "Справочники." + Сред(ЗначениеУзла, Найти(ЗначениеУзла, ".") + 1);
			ИначеЕсли Лев(ЗначениеУзла, 8) = "Документ" Тогда
				Результат = "Документы." + Сред(ЗначениеУзла, Найти(ЗначениеУзла, ".") + 1);
			ИначеЕсли Лев(ЗначениеУзла, 23) = "ПланыВидовХарактеристик" Тогда
				Результат = "ПланыВидовХарактеристик." + Сред(ЗначениеУзла, Найти(ЗначениеУзла, ".") + 1);
			Иначе
				Результат = Неопределено;
			КонецЕсли;
				 
		Иначе
			Результат = Неопределено;
		КонецЕсли;
	Исключение
		Результат = Неопределено;
	КонецПопытки;
	
	Возврат Результат;        
	
КонецФункции

&НаКлиенте
Функция ТипыСторонИзИниДляМаппинга(ИниКонфигурации)
	
	ОписаниеТипов = Новый Структура;
	ОписаниеТипов.Вставить("Организации",	ПолучитьТип1СДляМаппинга(ИниКонфигурации, "Организации"));
	ОписаниеТипов.Вставить("Контрагенты",	ПолучитьТип1СДляМаппинга(ИниКонфигурации, "Контрагенты"));
	ОписаниеТипов.Вставить("Партнеры",		ПолучитьТип1СДляМаппинга(ИниКонфигурации, "Партнеры"));
	
	Возврат ОписаниеТипов;
	
КонецФункции

&НаКлиенте
Функция ТипыСторонДляМаппинга()

	Кэш = ПолучитьТекущийЛокальныйКэш();
	ОписаниеКонфигурации = Кэш.Ини.Конфигурация;
	
	ОписаниеТипов = ТипыСторонИзИниДляМаппинга(ОписаниеКонфигурации);
	
	ТипыСторон = Новый Структура;
	ТипыСторон.Вставить("ДанныеОрганизации", ОписаниеТипов.Организации);
	ТипыСторон.Вставить("ДанныеКонтрагента", ОписаниеТипов.Контрагенты);
	
	ТипГрузополучателя = ПолучитьЗначениеПараметраСбис("ТипГрузополучателя");
	
	Если ТипГрузополучателя = "ГрузополучательКонтрагент" Тогда
		ТипыСторон.Вставить("ДанныеГрузополучателя", ОписаниеТипов.Контрагенты);
	ИначеЕсли ТипГрузополучателя = "ГрузополучательПартнер" Тогда
		ТипыСторон.Вставить("ДанныеГрузополучателя", ОписаниеТипов.Партнеры);
	Иначе 
		ТипыСторон.Вставить("ДанныеГрузополучателя", Неопределено);
	КонецЕсли;
	
	Возврат ТипыСторон;

КонецФункции // ТипыСторонДляМаппинга()

&НаКлиенте
Функция ПолучитьAPIОбъектСтороны(ТипAPIОбъекта, ДанныеСтороны) Экспорт 
	
	Filter = Новый Структура("Ключ1_1, Ключ1_2, Ключ1_3");
	
	ДанныеСтороны.Свойство("ИНН",			Filter.Ключ1_1);
	ДанныеСтороны.Свойство("КПП",			Filter.Ключ1_2);
	ДанныеСтороны.Свойство("КодФилиала",	Filter.Ключ1_3);
	
	ПараметрыМетода = Новый Структура("Type, Filter", ТипAPIОбъекта, Filter);
	Возврат ГлавноеОкно.Кэш.Интеграция.API3_FindSbisObject(ГлавноеОкно.Кэш, ПараметрыМетода, Новый Структура);
	
КонецФункции

&НаКлиенте
Функция Маппинг_ОбновитьИзДанныхСтороны(ТипAPIОбъекта, ДанныеСтороны) Экспорт 
	
	Отказ = Ложь;
	ConnectionId = ПолучитьИдКоннекшена(Отказ);
	
	Если Отказ ИЛИ НЕ ЭтоУникальныйИдентификатор(ConnectionId) Тогда

		СбисИсключение = НовыйСбисИсключение(ConnectionId, "МодульОбъектаКлиента.Маппинг_ОбновитьИзДанныхСтороны");
		СбисСтатистика_СформироватьИЗаписать(Новый Структура("Действие, Ошибка", "Ошибка", СбисИсключение));
		Возврат Неопределено;

	КонецЕсли;
	
	param = Новый Структура("ConnectionId, Type", ConnectionId, ТипAPIОбъекта);
		
	ПоляИС = Новый Соответствие;
	ПоляИС.Вставить("ИдИС",			"ClientId");
	ПоляИС.Вставить("ИмяИС",		"ClientType");
	ПоляИС.Вставить("Название",		"ClientName");
	ПоляИС.Вставить("ИНН",			"ClientParam_1_1");
	ПоляИС.Вставить("КПП",			"ClientParam_1_2");
	ПоляИС.Вставить("КодФилиала",	"ClientParam_1_3");
		
	ПоляСБИС = Новый Соответствие;
	ПоляСБИС.Вставить("ИдСБИС",				"SbisId");
	ПоляСБИС.Вставить("Название",			"SbisName");
	ПоляСБИС.Вставить("Данные.ИНН",			"SbisParam_1_1");
	ПоляСБИС.Вставить("Данные.КПП",			"SbisParam_1_2");
	ПоляСБИС.Вставить("Данные.КодФилиала",	"SbisParam_1_3");
	
	ПоляМаппинга = Новый Соответствие;
	ПоляМаппинга.Вставить("ИС",		ПоляИС);
	ПоляМаппинга.Вставить("СБИС",	ПоляСБИС);

	Для Каждого НаборПолей Из ПоляМаппинга Цикл

		Если Не ДанныеСтороны.Свойство(НаборПолей.Ключ) Тогда
			Продолжить;
		КонецЕсли;

		Для каждого Сопоставление Из НаборПолей.Значение Цикл
			КлючСоставной		= СтрЗаменить(Сопоставление.Ключ, ".", Символы.ПС);
			ЗначениеВставить	= ДанныеСтороны[НаборПолей.Ключ];
			ДобавитьПараметр	= Истина;
			Для СтрНомерСТроки = 1 По СтрЧислоСтрок(КлючСоставной) Цикл
				
				Если Не ЗначениеВставить.Свойство(СтрПолучитьСтроку(КлючСоставной, СтрНомерСТроки), ЗначениеВставить) Тогда
					
					ДобавитьПараметр = Ложь;
					Прервать;
					
				КонецЕсли;
				
			КонецЦикла;
			Если ДобавитьПараметр Тогда
				param.Вставить(Сопоставление.Значение, ЗначениеВставить);
            КонецЕсли;

		КонецЦикла;

	КонецЦикла;
	
	Если ДанныеСтороны.Свойство("УИД") 
		И ЗначениеЗаполнено(ДанныеСтороны.УИД) Тогда
		
		param.Вставить("Uuid", ДанныеСтороны.УИД);

	КонецЕсли; 
	
	Если ДанныеСтороны.Свойство("Статус") Тогда
		
		param.Вставить("Status", ДанныеСтороны.Статус.Ид);
		param.Вставить("Status_msg", ДанныеСтороны.Статус.Сообщение);

	КонецЕсли;
	
	ПараметрыМетода = Новый Структура("param", param);
	
	Кэш = ПолучитьТекущийЛокальныйКэш();
	Возврат ГлобальныйКэш.ТекущийСеанс.Модули.Интеграция.MappingObject_UpdateFromData(Кэш, ПараметрыМетода, Новый Структура);
	
КонецФункции

