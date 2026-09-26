
// Тут расположены методы без контекста их вызова. Их можно позвать в рамках модуля, без уточнения конекста, но они не будут экспортными

// Функция - конструктор исключения для вызова от контекста
//
// Параметры:
//  HandledException	 - ExtException, ИнформацияОбОшибке, Структура, Строка, Число	 - перехваченная ошибка, либо информация о том, что пошло не так
//  Parent				 - Строка, ExtException											 - родитель ошибки. 
//		Это может быть готовое исключение, В КОТОРОЕ надо добавить возникшую проблему. Остальные параметры игнорируются.
//		Это может быть строка с именем метода где возникла проблема. Тогда основная ошибка формируется по полям Type, Message, Details, Data, а возникшая ошибка обогащает новую
//  Type				 - Число, Строка, Неопределено								 - тип, или код ошибки.
//		Не используется, если Parent готовое исключение
//  Message				 - Строка, Неопределено		 - устанавливаемое сообщение для ошибки. Если не задано явно, то определяется по типу, или коду.
//		Не используется, если Parent готовое исключение
//  Details				 - Строка, Неопределено		 - устанавливаемое расширенное сообщение для ошибки. Если не задано явно, то берется сообщение. 
//		Не используется, если Parent готовое исключение
//  Data				 - Структура, Неопределено	 - устанавливаемые данные ошибки. Если не задано явно, то берется от возникшей ошибки.
//		Не используется, если Parent готовое исключение
// 
// Возвращаемое значение:
//  ExtException - экземпляр класса ошибки.
//
//DynamicDirective
Функция NewExtException(	HandledException = Неопределено, Parent	= Неопределено,
							Type = Неопределено, Message = Неопределено, Details = Неопределено, Data = Неопределено)
							
	КонтекстОбъединения	= Новый Структура(
		"ОбновитьКод, ОбновитьТекстСообщения, ОбновитьДетализацию",
		Истина, Истина, Истина);
		
	ФормироватьИсключение =	Не	(	Type = Неопределено
								И	Message = Неопределено
								И	Details = Неопределено
								И	Data = Неопределено);

	Если ОбъектSABY_ЭтоТип(Parent, "ExtException") Тогда
		
		// Перегрузка для объединенения ошибок. Тогда второй аргумент должен быть обязательно типом "ExtException"
		// Все прочие параметры (кроме первых 2) игнорируются
		// Сценарий обогащения уже существующей ошибки в Parent возникшим исключением (проброс от него стека, данных и пр.)
		NewException		= ExtException_Copy(parent);
		GeneratedException	= яExtException_Static_Handle(HandledException, NewException, КонтекстОбъединения);
		ExtException_Append(NewException, "ExtException", GeneratedException, КонтекстОбъединения);
		
	ИначеЕсли	ТипЗнч(HandledException) = Тип("Строка")
			И	Parent	= Неопределено
			И	Type	= Неопределено Тогда
			
		// Создание типизированного исключения	
		NewException = яExtException_CreateInstance(HandledException, Message, Details, "NewExtException", Data);
			
	ИначеЕсли ФормироватьИсключение Тогда
		
		// Если сообщения указаны явно в конструкторе, то они не обновляются от разобранной ошибки.
		КонтекстОбъединения.ОбновитьТекстСообщения	= Не ЗначениеЗаполнено(Message);
		КонтекстОбъединения.ОбновитьДетализацию		= Не ЗначениеЗаполнено(Details);
		
		// Ошибка с параметрами, где 2 аргумент это имя метода в стек
		// Итоговое исключение задается по 2-6 аргументу.
		// Возникшая ошибка добавляется в него
		NewException = яExtException_CreateInstance(Type, Message, Details, Parent, Data);
		КонтекстОбъединения.ОбновитьКод = NewException.code = яExtException_Static_CodeFormat();

		GeneratedException	= яExtException_Static_Handle(HandledException, NewException, КонтекстОбъединения);
		яExtException_InitInstance(GeneratedException);
		
		ExtException_Append(NewException, "ExtException", GeneratedException, КонтекстОбъединения);
				
	Иначе

		// Не задано никаких параметров для нового исключения. Обработать входящее и прописать action
		GeneratedException	= яExtException_CreateInstance();
		NewException		= яExtException_Static_Handle(HandledException, GeneratedException, КонтекстОбъединения);
		Если Не Parent = Неопределено Тогда
			
			ExtException_Set(NewException, "action", Parent);
			
		КонецЕсли;
		
	КонецЕсли;
	
	яExtException_InitInstance(NewException); // установить свойства по-умолчанию, если по итогу что-то не заполнилось
	
	Возврат NewException;
	
КонецФункции

// Процедура - Append метод для обогащения текущего объекта
//
// Параметры:
//  ExtException	 - ExtException				 - текущая ошибка
//  KeySet			 - Неопределенно, Строка	 - ключ, что добавляется к ошибке
//  ValueSet		 - Произвольный				 - значение, добавляемое к текущей ошибке
//	AddParam		 - Неопределено, Структура	 - расширение
// 
//DynamicDirective
Процедура ExtException_Append(ExtException, KeySet = Неопределено, ValueSet = Неопределено, AddParam = Неопределено) 
	
	KeySetCheck = НРег(KeySet);
	Если KeySet = Неопределено Тогда
		
		Если ОбъектSABY_ЭтоТип(ValueSet, "ОбъектSABY") Тогда
			
			TypeSet = ОбъектSABY_Получить(ValueSet, "Тип");
			
		Иначе 
			
			TypeSet = ТипЗнч(ValueSet);
			
		КонецЕсли;
		ExtException_Append(ExtException, TypeSet, ValueSet, AddParam);
		
	ИначеЕсли	KeySetCheck = "extexception"	Тогда
		
		яExtException_Append_ExtException(ExtException, ValueSet, AddParam);

	ИначеЕсли	KeySetCheck = "sabywarning"	Тогда
		
		яExtException_Append_SabyWarning(ExtException, ValueSet, AddParam);

	ИначеЕсли	KeySet = Тип("Структура")	Тогда
		
		яExtException_Append_Structure(ExtException, ValueSet, AddParam);

	Иначе
		
		// Неизвестный ключ/тип
		Возврат;
		
	КонецЕсли;

КонецПроцедуры

// Функция - возвращает копию объекта.
//
// Параметры:
//  ExtException	 - ExtException	 - текущая ошибка
//	AddParam		 - Неопределено	 - расширение
// 
// Возвращаемое значение:
//  ExtException - копия объекта
//
//DynamicDirective
Функция ExtException_Copy(ExtException, AddParam = Неопределено) 
	
	// Пока просто в лоб - поверхностная копия
	Возврат НовыйКопияОбъекта(ExtException);
	
КонецФункции

// Функция - Dump метод для исключений
//
// Параметры:
//  ExtException	 - ExtException				 - текущая ошибка
//  Scenario		 - Строка					 - ключ, как надо выгрузить нашу ошибку
//	AddParam		 - Неопределено, Структура	 - расширение
// 
// Возвращаемое значение:
//  Произвольный - значение по ключу
//
//DynamicDirective
Функция ExtException_Dump(ExtException, Scenario = "Строка", AddParam = Неопределено) 
	
	КлючПроверить = НРег(Scenario);	
		
	Если КлючПроверить = "строка" Тогда
		
		Результат = Saby_ЗначениеВСтрокуВнутрНаСервере(ExtException);
		
	ИначеЕсли КлючПроверить = "сообщение" Тогда
		
		Результат = ExtException.message;
		
		Если Результат = Неопределено Тогда
			
			Результат = "";
			
		КонецЕсли;
		
		Если ExtException.message <> ExtException.detail Тогда
			
			Результат = Результат + " (" + ExtException.detail + ")";
			
		КонецЕсли;
		
	ИначеЕсли КлючПроверить = "полныйтекст" Тогда
		
		Возврат яExtException_Dump_FullText(ExtException);
		
	ИначеЕсли КлючПроверить = "html" Тогда
		
		Результат = "<HTML><BODY scroll=no>" + ExtException.message + "</br>" + ExtException.detail + "</BODY></HTML>";

	ИначеЕсли КлючПроверить = "hint" Тогда
		
		// Временное решение. Тут должно быть разрулено, какую команду генерировать. Пока нет методов, сделан костыль.
		Результат = Новый Структура("ИмяПроцедуры, ДополнительныеПараметры", "ЗапуститьРешениеПроблемы", ExtException);

	ИначеЕсли КлючПроверить = "лог" Тогда
		
		Результат = ExtException;

	ИначеЕсли КлючПроверить = "json" Тогда
		
		Результат = СериализоватьПроизвольноеЗначениеВJSONСтроку(ExtException);
		
	Иначе
		
		Результат = ОбъектSABY_Выгрузить(ExtException, AddParam);
		
	КонецЕсли;
	
	Возврат Результат;
	
КонецФункции

// Функция - Set метод для исключений
//
// Параметры:
//  ExtException	 - ExtException				 - текущая ошибка
//  KeySet			 - Строка					 - Устанавливаемый ключ.
//	ValueSet		 - Произвольный				 - Устанавливаемое значение
//	AddParam		 - Неопределено, Структура   - Расширение
// 
//DynamicDirective
Процедура ExtException_Set(ExtException, KeySet = Неопределено, ValueSet = Неопределено, AddParam = Неопределено) 
	
	KeySetCheck = НРег(KeySet);
	Если	Лев(KeySetCheck, 6) = "detail" Тогда
		
		ExtException.detail = ValueSet;
		
	ИначеЕсли	KeySetCheck = "stack"	Тогда
		
		яExtException_AddToStack(ExtException, ValueSet);
		
	ИначеЕсли	KeySetCheck = "dump"	Тогда
		
		ThisIsDumpObject =	ТипЗнч(ValueSet) = Тип("Структура")
						И	ValueSet.Свойство("ИсходнаяСтрока")
						И	ValueSet.Свойство("ДетализацияОшибки");

		Если	AddParam = KeySet
			Или	ThisIsDumpObject Тогда
			
			// Если явно задается куда поместить, или указан объект дампа
			ExtException.dump = ValueSet; 
			
		Иначе

			// dump формируется при анализе исключения в определенном формате. 
			// Если формат не соответствует, то это data
			ExtException.data = ValueSet;
			
		КонецЕсли;

	ИначеЕсли	KeySetCheck = "method_name"
			Или	KeySetCheck = "methodname" Тогда
		
		ExtException.action = ValueSet;

	ИначеЕсли	KeySetCheck = "code"	Тогда
		
		ExtException.code	= яExtException_Static_CodeFormat(ValueSet);
		Если	AddParam = Неопределено
			Или	AddParam.ОбновитьТекстСообщения Тогда
			
			// Если не указано обратного, то при установке кода присвоить по нему сообщение
			OldCodes = ExtException_Get(ExtException, "OldCodes");
			ExtException.message = яExtException_Static_MessageByCodes(OldCodes.code, OldCodes.extCode);
			
		КонецЕсли;

	ИначеЕсли	KeySetCheck = "action"	Тогда
		
		Если ЗначениеЗаполнено(ExtException.action) Тогда
			
			// Меняется действие на ошибке, надо сохранить предыдущее значение в стэке
			ExtException_Set(ExtException, "stack", яExtException_Static_NewStackLine(ExtException.action));
			
		КонецЕсли;
		ExtException.action = ValueSet;

	ИначеЕсли	KeySetCheck = "type"
			Или	KeySetCheck = "тип" Тогда
		
		CodeByType = яExtException_Static_CodeByType(ValueSet);
		Если Не CodeByType = 100000 Тогда
			
			ExtException_Set(ExtException, "code", CodeByType);
			
		КонецЕсли;
			

		ОбъектSABY_Установить(ExtException, "Тип", ValueSet);
		
	Иначе
		
		Попытка
			
			Если ExtException.Свойство(KeySet) Тогда
				
				ExtException[KeySet] = ValueSet;
				
			КонецЕсли;
			
		Исключение
			
			// На случай непредвиденных ключей
			Возврат;
			
		КонецПопытки;
		
	КонецЕсли;
	
КонецПроцедуры

// Функция - Get метод для исключений
//
// Параметры:
//  ExtException	 - ExtException				 - текущая ошибка
//  KeyGet		 - Строка						 - ключ, что получить
//	AddParam		 - Неопределено, Структура	 - расширение
// 
// Возвращаемое значение:
//  Произвольный - значение по ключу
//
//DynamicDirective
Функция ExtException_Get(ExtException, KeyGet, AddParam = Неопределено) 
	
	KeyCheck = НРег(KeyGet);
	Если KeyCheck = "oldcodes" Тогда
	
		Код1 = Число(Лев(ExtException.code, 3));
		Код2 = Число(Прав(ExtException.code, 3)); 
		Если Код2 = 0 Тогда
			
			Код2 = Неопределено;
			
		КонецЕсли;
	
		Возврат Новый ФиксированнаяСтруктура("code, extCode", Код1, Код2);
		
	ИначеЕсли KeyGet = "defaultmessage" Тогда
		
		// Получить сообщенение от текущего кода/типа, а не установленное на объекте.
		Возврат яExtException_DefaultMessage(ExtException);

	ИначеЕсли KeyGet = "hint" Тогда
		
		Возврат яExtException_GetHint(ExtException);
		
	Иначе
		
		Возврат ExtException[KeyGet];
		
	КонецЕсли;
	
КонецФункции

