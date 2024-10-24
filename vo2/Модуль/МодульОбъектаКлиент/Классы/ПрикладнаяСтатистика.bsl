// Создание нового объекта прикладной статистики
//
// Параметры:
//  ПараметрыКонструктора - Структура, Массив, Неопределено - Начальные параметры.
//   Структура должна содержать обязательные ключи Действие, Контекст и может содежать Количество
//   Массив должне состоять из структур с тем же описанием. Неопределено - пустой объект.
//  ДопПараметры - Структура, Неопределено - Чтобы было!
//
// Возвращаемое значение:
//  Структура - Объект класса прикладной статистики.
&НаКлиенте
Функция НовыйПрикладнаяСтатистика(ПараметрыКонструктора = Неопределено, ДопПараметры = Неопределено) Экспорт
	
	НовыйОбъект = ПрикладнаяСтатистика_Пустой();
	
	Если ТипЗнч(ПараметрыКонструктора) = Тип("Массив") Тогда
		ПараметрыЗаполнения = ПараметрыКонструктора;
	ИначеЕсли ТипЗнч(ПараметрыКонструктора) = Тип("Структура") Тогда
		ПараметрыЗаполнения = Новый Массив;
		ПараметрыЗаполнения.Добавить(ПараметрыКонструктора);
	Иначе
		ПараметрыЗаполнения = Новый Массив;
	КонецЕсли;
	
	Для Каждого ПараметрСтатистики Из ПараметрыЗаполнения Цикл
		ПрикладнаяСтатистика_Добавить(НовыйОбъект, ПараметрСтатистики);
	КонецЦикла;
	
	Возврат НовыйОбъект;
	
КонецФункции

&НаКлиенте
Функция ПрикладнаяСтатистика_Пустой()
	// Объект может содержать несколько Действий, которые могут в свою очередь включать несколько Контекстов.
	// Контекст содерчит числовое значение, указывающее Колчество сценариев, указываемых в статистике.
	// Предназначе для массовой отправки нескольких сценариев с указанием количества
	Возврат Новый Структура("_класс, Действия", "ПрикладнаяСтатистика", Новый Соответствие);
КонецФункции

// Добавляет значения в прикладную статистику
//
// Параметры:
//  ПрикладнаяСтатистика - Структура - Объект прикладной статистики.
//  ОписаниеСтатистики - Структура - Описание добаляемой информации в прикладную статистику.
//   Структура должна содержать обязательные ключи Действие, Контекст и может содежать Количество.
//
// Возвращаемое значение:
//  Булево - Результат добавления в статистику. Если Ложь, то при добавлении произошла ошибка.
&НаКлиенте
Функция ПрикладнаяСтатистика_Добавить(ПрикладнаяСтатистика, ОписаниеСтатистики) Экспорт
	Перем Действие, Контекст, Количество;
	
	Если ТипЗнч(ОписаниеСтатистики) <> Тип("Структура")
		ИЛИ НЕ ОписаниеСтатистики.Свойство("Действие", Действие)
		ИЛИ НЕ ОписаниеСтатистики.Свойство("Контекст", Контекст) Тогда
		Возврат Ложь;
	КонецЕсли;
	
	Если НЕ ОписаниеСтатистики.Свойство("Количество", Количество)
		ИЛИ НЕ ЗначениеЗаполнено(Количество) Тогда
		Количество = 1;
	КонецЕсли;
	
	Если ПрикладнаяСтатистика.Действия.Получить(Действие) = Неопределено Тогда
		ПрикладнаяСтатистика.Действия.Вставить(Действие, Новый Соответствие);
	КонецЕсли;
	
	Если ПрикладнаяСтатистика.Действия[Действие].Получить(Контекст) = Неопределено Тогда
		ПрикладнаяСтатистика.Действия[Действие].Вставить(Контекст, 0);
	КонецЕсли;
	
	ПрикладнаяСтатистика.Действия[Действие][Контекст] = ПрикладнаяСтатистика.Действия[Действие][Контекст] + Количество;
	
	Возврат Истина;
	
КонецФункции

// Отправляет значения в прикладную статистику
//
// Параметры:
//  ПрикладнаяСтатистика - Структура - Объект прикладной статистики.
//  ДопПараметры - Структура, Неопределено - На всякий случай!
//
// Возвращаемое значение:
//  Булево - Результат отправки статистики. Если Ложь, то при отправке произошла ошибка.
&НаКлиенте
Функция ПрикладнаяСтатистика_Отправить(ПрикладнаяСтатистика, ДопПараметры = Неопределено) Экспорт
	
	Сообщения = ПрикладнаяСтатистика_Получить(ПрикладнаяСтатистика, Новый Структура);
	
	Попытка

		СбисСтатистика_СформироватьИЗаписать(Новый Структура("Действие, Сообщения", "ПрикладнаяСтатистика", Сообщения));
		ПрикладнаяСтатистика = ЗаписьПрикладнойСтатистики_Пустой();
		Возврат Истина;

	Исключение
		
		МодульОбъектаКлиент().СообщитьСбисИсключение(ИнформацияОбОшибке(), "Документ_Шаблон.СоздатьДокумент");
		Возврат Ложь;

	КонецПопытки;
	
КонецФункции

// Получить свойства объекта Прикладная статистика.
//
// Параметры:
//  ПрикладнаяСтатистика - Структура - Объект прикладной статистики.
//  ОписаниеСтатистики - Структура - Отбор значений объекта.
//   С ключами Действие и/или Контекст возвращается массив объектов класса ЗаписьПрикладнойСтатистики.
//
// Возвращаемое значение:
//  Массив, Структура - Объекты класса ЗаписьПрикладнойСтатистики
&НаКлиенте
Функция ПрикладнаяСтатистика_Получить(ПрикладнаяСтатистика, ОписаниеСтатистики) Экспорт
	Перем Результат;
	
	Если ОписаниеСтатистики.Свойство("Действие")
		И ОписаниеСтатистики.Свойство("Контекст")
		И ПрикладнаяСтатистика.Действия.Получить(ОписаниеСтатистики.Действие) <> Неопределено Тогда
		
		Количество = ПрикладнаяСтатистика.Действия[ОписаниеСтатистики.Действие].Получить(ОписаниеСтатистики.Контекст);
		ЗаписьПрикладнойСтатистики = НовыйЗаписьПрикладнойСтатистики(ОписаниеСтатистики.Действие, ОписаниеСтатистики.Контекст, Количество);
		Результат = ЗаписьПрикладнойСтатистики;
		
	ИначеЕсли ОписаниеСтатистики.Свойство("Действие")
		И ПрикладнаяСтатистика.Действия.Получить(ОписаниеСтатистики.Действие) <> Неопределено Тогда
		
		МассивРезультатов = Новый Массив;
		Для Каждого Контекст Из ПрикладнаяСтатистика.Действия[ОписаниеСтатистики.Действие] Цикл
			
			Количество = Контекст[ОписаниеСтатистики.Действие].Получить(ОписаниеСтатистики.Контекст);
			ЗаписьПрикладнойСтатистики = НовыйЗаписьПрикладнойСтатистики(ОписаниеСтатистики.Действие, Контекст.Ключ, Количество);
			МассивРезультатов.Добавить(ЗаписьПрикладнойСтатистики);
			
		КонецЦикла;
		
		Результат = МассивРезультатов;
		
	ИначеЕсли ОписаниеСтатистики.Свойство("Контекст") Тогда
		
		МассивРезультатов = Новый Массив;
		
		Для Каждого Действие Из ПрикладнаяСтатистика.Действия Цикл
			
			Количество = Действие.Значение.Получить(ОписаниеСтатистики.Контекст);
			ЗаписьПрикладнойСтатистики = НовыйЗаписьПрикладнойСтатистики(Действие.Ключ, ОписаниеСтатистики.Контекст, Количество);
			МассивРезультатов.Добавить(ЗаписьПрикладнойСтатистики);
			
		КонецЦикла;
		
		Результат = МассивРезультатов;
		
	Иначе
		
		МассивРезультатов = Новый Массив;
		
		Если ЗначениеЗаполнено(ПрикладнаяСтатистика.Действия) Тогда
			Для Каждого Действие Из ПрикладнаяСтатистика.Действия Цикл
				Для Каждого Контекст Из действие.Значение Цикл
					
					ЗаписьПрикладнойСтатистики = НовыйЗаписьПрикладнойСтатистики(Действие.Ключ, Контекст.Ключ, Контекст.Значение);
					МассивРезультатов.Добавить(ЗаписьПрикладнойСтатистики);
					
				КонецЦикла;
			КонецЦикла;
		КонецЕсли;
		
		Результат = МассивРезультатов;
		
	КонецЕсли;
	
	Возврат Результат;
	
КонецФункции

// Создание нового объекта запись прикладной статистики
//
// Параметры:
//  Действие - Строка - Действие прикладной статистики
//  Контекст - Строка - Контекст прикладной статистики
//  Количество - Число - Количество записей прикладной статистики
//
// Возвращаемое значение:
//  Структура - Объект класса запись прикладной статистики.
&НаКлиенте
Функция НовыйЗаписьПрикладнойСтатистики(Действие = "", Контекст = "", Количество = 0) Экспорт
	
	НовыйОбъект = ЗаписьПрикладнойСтатистики_Пустой();
	
	Если ЗначениеЗаполнено(Действие) Тогда
		НовыйОбъект.Действие = Действие;
	КонецЕсли;
	
	Если ЗначениеЗаполнено(Контекст) Тогда
		НовыйОбъект.Контекст = Контекст;
	КонецЕсли;
	
	Если ЗначениеЗаполнено(Количество) Тогда
		НовыйОбъект.Количество = Количество;
	КонецЕсли;
	
	Возврат НовыйОбъект;
	
КонецФункции

&НаКлиенте
Функция ЗаписьПрикладнойСтатистики_Пустой()
	
	ПоляОбъекта = Новый Структура;
	ПоляОбъекта.Вставить("_класс",		"ЗаписьПрикладнойСтатистики");
	ПоляОбъекта.Вставить("Действие",	"");
	ПоляОбъекта.Вставить("Контекст",	"");
	ПоляОбъекта.Вставить("Количество",	0);
	
	Возврат ПоляОбъекта;
	
КонецФункции

// Получить свойства объекта Запись прикладной статистики
//
// Параметры:
//  ЗаписьПрикладнойСтатистики - Структура - Объект запись прикладной статистики.
//  Поле - Строка - Имя свойства.
//
// Возвращаемое значение:
//  Строка, Число - Значение поля записи прикладнойстатистики.
&НаКлиенте
Функция ЗаписьПрикладнойСтатистики_Получить(ЗаписьПрикладнойСтатистики, Поле) Экспорт
	Перем Результат;
	ЗаписьПрикладнойСтатистики.Свойство(Поле, Результат);
	Возврат Результат;
КонецФункции
