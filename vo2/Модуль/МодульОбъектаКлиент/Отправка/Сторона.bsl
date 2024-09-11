
// Функция - выгружает данные стороны в плоском формате 
//
// Параметры:
//  ДанныеСтороны	 - экземпляр класса сторона	 - Структура СфЮл/СвФЛ
// 
// Возвращаемое значение:
//  Структура - формат с полями "ИНН, КПП, КодФилиала". Если чего-то не хватает, то ""
//
&НаКлиенте
Функция Сторона_Выгрузить(ДанныеСтороны) Экспорт
	Перем СвЮлФлСтороны;
	
	ДанныеСтороныПлоские = Новый Структура("ИНН, КПП, КодФилиала, БИН, ИИН", "", "", "", "", "");
	Если		ДанныеСтороны = Неопределено Тогда
		
		Возврат ДанныеСтороныПлоские;
		
	ИначеЕсли	ДанныеСтороны.Свойство("СвЮЛ", СвЮлФлСтороны) Тогда
		
		Если СвЮлФлСтороны.Свойство("КПП") Тогда
			ДанныеСтороныПлоские.КПП = СвЮлФлСтороны.КПП;
		КонецЕсли;
		
	ИначеЕсли	ДанныеСтороны.Свойство("СвФЛ", СвЮлФлСтороны) Тогда 
		
		//Есть СвФЛ
		
	Иначе
		
		//Нет данных стороны
		ВызватьСбисИсключение(724, "РаботаСДокументами1С.СгенерироватьПакет",, "Сторона не определена", "Отсутствует ИНН/КПП");
		
	КонецЕсли;
	
		Если СвЮлФлСтороны.Свойство("ИНН") Тогда 
		
		ДанныеСтороныПлоские.ИНН = СвЮлФлСтороны.ИНН; 
		
	ИначеЕсли СвЮлФлСтороны.Свойство("БИН") Тогда 
		
		ДанныеСтороныПлоские.БИН = СвЮлФлСтороны.БИН; 
		
	ИначеЕсли СвЮлФлСтороны.Свойство("ИИН") Тогда 
		
		ДанныеСтороныПлоские.ИИН = СвЮлФлСтороны.ИИН;  
		
	Иначе
		
		//Нет данных стороны
		ВызватьСбисИсключение(724, "РаботаСДокументами1С.СгенерироватьПакет",, "Сторона не определена", "Отсутствует ИНН/КПП");  
		
	КонецЕсли;

	Если	СвЮлФлСтороны.Свойство("КодФилиала")
		И	ЗначениеЗаполнено(СвЮлФлСтороны.КодФилиала) Тогда
		ДанныеСтороныПлоские.КодФилиала = СвЮлФлСтороны.КодФилиала;
	КонецЕсли;
	
	Возврат ДанныеСтороныПлоские;
	
КонецФункции
	
// Функция ищет элемент справочника в базе 1С по данным участника в универсальном формате
//
// Параметры:
//  оУчастник	 - Структура	 - класс стороны
//  ДопПараметры - Струкутра	 - расширение поиска
//		УзелИниПоиска	- 
//		ТипСтороны		-
//		Тип1С			-
// 
// Возвращаемое значение:
//  Массив - Список найденныхссылок
//
&НаКлиенте
Функция Сторона_НайтиКарточки1С(оУчастник, ДопПараметры) Экспорт

	Возврат Сторона_НайтиКарточки1СЗапросом(оУчастник, ДопПараметры);
	
КонецФункции

// Функция ищет элемент справочника в базе 1С по данным участника в универсальном формате
//
// Параметры:
//  оУчастник	 - Структура	 - класс стороны
//  ДопПараметры - Струкутра	 - расширение поиска
//		УзелИниПоиска	- Структура, узел ини из мДокумент для поиска стороны под определенный документ
//		ТипСтороны		- Строка Контрагент/Организация. Должно быть определено в ини Конфигураици 
// 
// Возвращаемое значение:
//  Массив - Список найденных ссылок
//
&НаКлиенте
Функция Сторона_НайтиКарточки1СЗапросом(оУчастник, ДопПараметры) Экспорт
	Перем СвФлЮл, УзелИниПоиска, ТекстЗапроса, ТолькоПоИНН;

	Результат	= Новый Массив;
	Если	Не	ТипЗнч(оУчастник) = Тип("Структура")
		Или		оУчастник = Неопределено Тогда 
		Возврат Результат;
	КонецЕсли;
	
	ТипСтороны					= ДопПараметры.ТипСтороны;
	ПараметрыПоискаРеквизиты	= ПолучитьЗначениеПараметраСбис("РеквизитыСторонДляПоиска");
	
	Если Не ПараметрыПоискаРеквизиты.Свойство(ТипСтороны, ПараметрыПоискаРеквизиты) Тогда
		ВызватьСбисИсключение(760, "МодульОбъектаКлиент.Сторона_НайтиКарточки1С",,, "Отсутствует описание стороны " + ТипСтороны + " в ини Конфигурация для поиска.");
	КонецЕсли;
	
	КлючЗапроса = ПараметрыПоискаРеквизиты.КлючЗапроса;
	
	Если Не ДопПараметры.Свойство("ТолькоПоИНН", ТолькоПоИНН) Тогда
		
		ТолькоПоИНН = ПараметрыПоискаРеквизиты.ПоискТолькоПоИНН;
		
	КонецЕсли;
	
	ПараметрыПостроенияЗапроса	= Новый Структура;
	
	Если		оУчастник.Свойство("СвФЛ", СвФлЮл) Тогда
		ТолькоПоИНН = Истина;
		ПараметрыПостроенияЗапроса.Вставить("ИНН", СвФлЮл.ИНН);
	ИначеЕсли	оУчастник.Свойство("СвЮЛ", СвФлЮл) Тогда
		ПараметрыПостроенияЗапроса.Вставить("КПП", СвФлЮл.КПП);
		ПараметрыПостроенияЗапроса.Вставить("ИНН", СвФлЮл.ИНН);
	Иначе
		
		ДампОшибки = Новый Структура("Сторона", оУчастник);
		ОшибкаПоискаСтороны = НовыйСбисИсключение(	, 
													"МодульОбъектаКлиент.Сторона_НайтиКарточки1СЗапросом", 
													760,
													,
													"Неизвестный формат стороны.",
													ДампОшибки);
		ВызватьИсключение СбисИсключение_Представление(ОшибкаПоискаСтороны);
		
	КонецЕсли;
		
	//Определить текст запроса
	СтрокаФильтрКПП = "И Участник." + ПараметрыПоискаРеквизиты.КПП + "=&КПП";
	Если  ДопПараметры.Свойство("УзелИниПоиска", УзелИниПоиска)
		И УзелИниПоиска.Свойство(КлючЗапроса) Тогда
		//В ини на поиск есть свой запрос для соответствующей стороны
		ТекстЗапроса = ГлобальныйКэш.ТекущийСеанс.Модули.ФункцииДокументов.РассчитатьЗначение(КлючЗапроса, УзелИниПоиска);
	Иначе
		ИниКОнфигурации = ИниПоПараметрам("Конфигурация");
		Если ИниКОнфигурации.Свойство(КлючЗапроса) Тогда
			
			ТекстЗапроса = ГлобальныйКэш.ТекущийСеанс.Модули.ФункцииДокументов.РассчитатьЗначение(КлючЗапроса, ИниКОнфигурации);
			
		КонецЕсли;
	КонецЕсли;
	
	Если	ТекстЗапроса = Неопределено Тогда
		
		ТекстЗапроса = "ВЫБРАТЬ РАЗРЕШЕННЫЕ
		|	Участник.Ссылка
		|ИЗ
		|	Справочник." + ПараметрыПоискаРеквизиты.Тип + " КАК Участник
		|ГДЕ
		|	НЕ Участник.ПометкаУдаления 
		|	И Участник." + ПараметрыПоискаРеквизиты.ИНН + "=&ИНН";
		
		Если Не ТолькоПоИНН Тогда
			ТекстЗапроса = ТекстЗапроса + "
			|	" + СтрокаФильтрКПП;
		КонецЕсли;
	КонецЕсли;
	
	//Убрать из текста запроса у равенства пробелы для корректной замены условий.
	ТекстЗапроса = СтрЗаменить(СтрЗаменить(ТекстЗапроса,
								" =", "="),
								"= ", "=");
	
	Если ТолькоПоИНН Тогда
		
		ТекстЗапроса = СтрЗаменить(ТекстЗапроса, СтрокаФильтрКПП, "");
		
	КонецЕсли;
	
	//Подразделение, если есть
	Если	оУчастник.Свойство("Подразделение") 
		И	оУчастник.Подразделение.Свойство("Идентификатор") Тогда
		
		ПараметрыПостроенияЗапроса.Вставить("КодФилиала", оУчастник.Подразделение.Идентификатор);
		
	Иначе
		
		ПараметрыПостроенияЗапроса.Вставить("КодФилиала", "");
		
	КонецЕсли;
	
	//GLN, если есть
	Если	оУчастник.Свойство("GLN") Тогда
		
		ПараметрыПостроенияЗапроса.Вставить("GLN",	оУчастник.GLN);
		
	Иначе
		
		ПараметрыПостроенияЗапроса.Вставить("GLN",	"");
		
	КонецЕсли;
	
	//Пользовательские органичения
	Если оУчастник.Свойство("Ограничения") Тогда
		
		Для Каждого Параметр Из оУчастник.Ограничения Цикл
			
			ПараметрыПостроенияЗапроса.Вставить(Параметр.Ключ, Параметр.Значение);
			
		КонецЦикла;	
		
	КонецЕсли; 
	
	РезультатПоиска = Сторона_НайтиКарточки1СЗапросомСервер(ТекстЗапроса, ПараметрыПостроенияЗапроса);
	РезультатИтог	= Новый Массив;
	
	Для Каждого РезультатСтрока Из РезультатПоиска Цикл 
		Если ТипЗнч(РезультатСтрока) = Тип("Структура") Тогда
			РезультатИтог.Добавить(РезультатСтрока.Ссылка);
		Иначе
			РезультатИтог.Добавить(РезультатСтрока);
		КонецЕсли;
	КонецЦикла;
	
	Возврат РезультатИтог;
	
КонецФункции

&НаСервере
Функция Сторона_НайтиКарточки1СЗапросомСервер(ТекстЗапроса, ПараметрыЗапроса)
	
	Возврат МодульОбъектаСервер().ВыполнитьЗапросСПараметрами(ТекстЗапроса, ПараметрыЗапроса);
	
КонецФункции

// Функция получаяет значение по ключу от данных стороны
//
// Параметры:
//  ДанныеСтороны	- Структура	 - Экземпляр, от которого надо получить значение
//  КлючПолучить	- Строка	 - Что хотим получить из стороны
//  ДопПараметры	- Структура	 - Расширение
// 
// Возвращаемое значение:
//  Произвольный - Найденное значение или Неопределено
//
&НаКлиенте
Функция Сторона_Получить(ДанныеСтороны, КлючПолучить, ДопПараметры = Неопределено) Экспорт 
	Перем Результат; 
	
	Если КлючПолучить = "ИдентификаторЛица" Тогда 
		
		Результат = Сторона_ИдентификаторЛица(ДанныеСтороны);	
		
	ИначеЕсли КлючПолучить = "КлючИдентификатора" Тогда 
		
		Результат = Сторона_КлючИдентификатора(ДанныеСтороны);
		
	Иначе
		
		ДанныеСтороны.Свойство(КлючПолучить, Результат);
		
	КонецЕсли;
	
	Возврат Результат;
	
КонецФункции  

&НаКлиенте
Функция Сторона_КлючИдентификатора(ДанныеСтороны)  
	
	ДанныеСтороныПлоские = Сторона_Выгрузить(ДанныеСтороны);
	
	Если ЗначениеЗаполнено(ДанныеСтороныПлоские.ИИН) Тогда
		
		Возврат "ИИН";
		
	ИначеЕсли ЗначениеЗаполнено(ДанныеСтороныПлоские.БИН) Тогда
		
		Возврат "БИН";
		
	Иначе  
		
		Возврат "ИНН";
		
	КонецЕсли;
	
КонецФункции

&НаКлиенте
Функция Сторона_ИдентификаторЛица(ДанныеСтороны)  
	
	ИНН = Сторона_Получить(ДанныеСтороны, "ИНН"); 
	БИН = Сторона_Получить(ДанныеСтороны, "БИН");  
	ИИН	= Сторона_Получить(ДанныеСтороны, "ИИН"); 
	СвФЛ = Сторона_Получить(ДанныеСтороны, "СвФЛ"); 
	СвЮЛ = Сторона_Получить(ДанныеСтороны, "СвЮЛ"); 
	
	Если ЗначениеЗаполнено(ИНН) Тогда  
		Возврат ИНН; 
	КонецЕсли;	 
	
	Если ЗначениеЗаполнено(БИН) Тогда  
		Возврат БИН; 
	КонецЕсли; 
	
	Если ЗначениеЗаполнено(ИИН) Тогда  
		Возврат ИИН; 
	КонецЕсли;

	Если ЗначениеЗаполнено(СвФЛ) Тогда  
		Возврат Сторона_Получить(СвФЛ, "ИНН"); 
	КонецЕсли;
	
	Если ЗначениеЗаполнено(СвЮЛ) Тогда  
		Возврат Сторона_Получить(СвЮЛ, "ИНН"); 
	КонецЕсли;
	
	Возврат Неопределено;
	
КонецФункции

