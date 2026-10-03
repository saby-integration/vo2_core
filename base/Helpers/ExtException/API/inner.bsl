
// Тут расположены методы без контекста их вызова. Их можно позвать в рамках модуля, без уточнения конекста, но они не будут экспортными

// Функция - конструктор исключения для вызова от контекста
//
// Параметры:
//  HandledException	 - Неопределено, ИнформацияОбОшибке, ExtException, Структура, Строка, Число	 - перехваченная ошибка, либо информация о том, что пошло не так
//  Parent				 - Строка						 - родитель ошибки. Строка с именем метода где возникла проблема.
//  Type				 - Число, Строка, Неопределено	 - тип, или код ошибки. Если Неопределено, то HandledException считается как Type
//  Message				 - Строка, Неопределено			 - устанавливаемое сообщение для ошибки. Если не задано явно, то определяется по типу, или коду.
//  Details				 - Строка, Неопределено			 - устанавливаемое расширенное сообщение для ошибки. Если не задано явно, то берется сообщение. 
//  Data				 - Структура, Неопределено		 - устанавливаемые данные ошибки. Если не задано явно, то берется от возникшей ошибки.
// 
// Возвращаемое значение:
//  ExtException - экземпляр класса ошибки.
//
//DynamicDirective
Функция NewExtException(	HandledException = Неопределено, Parent	= Неопределено,
							Type = Неопределено, Message = Неопределено, Details = Неопределено, Data = Неопределено)
							
	Если HandledException = Неопределено Тогда
		
		// Основание неопределено. Собрать исключение из того, что передано.
		// Анализ не требуется.
		NewException = яExtException_CreateInstance(Type, Message, Details, Parent, Data);
		
	ИначеЕсли	ТипЗнч(HandledException) = Тип("Строка")
			И	Parent	= Неопределено
			И	Type	= Неопределено Тогда
			
		// Основание - строка, но код/тип и место падения не заданы. 
		// Считаем это типизированным исключением, с установкой типа первым аргументом
		// Анализ не требуется.
		NewException = яExtException_CreateInstance(HandledException, Message, Details,, Data);
			
	Иначе
		
		// Что-то непонятное и нужно провести анализ.
		GenerateAdditionalException =	Не	(	Type = Неопределено
										И	Message = Неопределено
										И	Details = Неопределено
										И	Data = Неопределено);
		Если GenerateAdditionalException Тогда
		
			// Итоговое исключение задается по 2-6 аргументу.
			// Возникшая ошибка добавляется в него после анализа.
			// Если в аргументах 2-6 чего-то не хватает, то недостающее берется по ошибке после анализа.
			NewException = яExtException_CreateInstance(Type, Message, Details, Parent, Data);
			
			AppendContext	= Новый Структура("ОбновитьКод, ОбновитьТекстСообщения, ОбновитьДетализацию");
			// Обновить код (и тип) если он не задан напрямую и это "Неизвестная ошибка"
			AppendContext.ОбновитьКод				= NewException.code = яExtException_Static_CodeFormat();
			AppendContext.ОбновитьТекстСообщения	= Не ЗначениеЗаполнено(Message);
			AppendContext.ОбновитьДетализацию		= Не ЗначениеЗаполнено(Details);

			GeneratedException	= яExtException_Static_Handle(HandledException, NewException, AppendContext);
			яExtException_InitInstance(GeneratedException);
			
			ExtException_Append(NewException, "ExtException", GeneratedException, AppendContext);
					
		Иначе

			// Не задано никаких параметров для нового исключения. Обработать входящее и прописать action
			NewException = яExtException_Static_Handle(HandledException);
			Если Не Parent = Неопределено Тогда
				
				ExtException_Set(NewException, "action", Parent);
				
			КонецЕсли;
			
		КонецЕсли;
		
	КонецЕсли;
	
	// установить свойства по-умолчанию, если по итогу что-то не заполнилось
	яExtException_InitInstance(NewException); 
	
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
			DataForStack = Новый Структура("action, type", ExtException.action, "ExtException.Set(action)");
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
		
	ИначеЕсли KeyGet = "type" Тогда
		
		Возврат ОбъектSABY_Получить(ExtException, "Тип");
		
	ИначеЕсли KeyGet = "lastaction" Тогда
		
		// Последнее выполненное действие с учетом стека
		Если ЗначениеЗаполнено(ExtException.Action) Тогда
			
			Возврат ExtException.Action;
			
		КонецЕсли;
		
		Для Каждого StackData Из ExtException.stack Цикл
			
			Если ЗначениеЗаполнено(StackData.Action) Тогда
				
				Возврат StackData.Action;
				
			КонецЕсли;
			
		КонецЦикла;
		
	Иначе
		
		Возврат ОбъектSABY_Получить(ExtException, KeyGet);
		
	КонецЕсли;
	
КонецФункции

