
// Функция - создать пустой экземпляр ошибки
//
// Параметры:
//  Type	 - Строка, Число, Неопределено					 - тип исключения. Это может быть код, или заданный тип
//  Message	 - Строка, Неопределено							 - задать подготовленное сообщение
//  Details	 - Строка, Неопределено							 - задать подготовленную расшифровку
//  Action	 - Строка, Неопределено							 - задать проблемное место для уточнения места возникновения ошибки и дальнейшего проброса в стэк
//  Data	 - Структура, Неопределено						 - задать данные ошибки
//  Hint	 - Структура, Строка, Неопределено				 - задать данные решения ошибки
//  Stack	 - Структура, Соответствие, Массив, Неопределено - задать данные для стэка
// 
// Возвращаемое значение:
//  ExtException - экземпляр класса
//
//DynamicDirective
Функция яExtException_CreateInstance(	Type=Неопределено, Message=Неопределено, Details=Неопределено, Action=Неопределено,
										Data=Неопределено, Hint=Неопределено,	 Stack=Неопределено)
										
	КлючиЭкземпляра = 
	// Сообщение по типу или коду
	"message
	// Детальная информация о проблеме
	|detail
	// Где произошла проблема
	|action
	// Данные ошибки, которые могут потребоваться для ее обработки
	|data
	// Дамп ошибки - техническое описание упавшего места - номер строки, модуль и техническая часть из того, что отдает 1С
	|dump
	// Код ошибки для классификации сценария проблемы. Не может быть пустым! Всегда должно быть число с 6 знаками!
	|code
	// Помощь в решении возникшей проблемы. По-умолчанию не инитим, формируется методом Get либо если в присланном исключении есть решение.
	|hint
	// Стэк вызова
	|stack";							
								
	NewExtException = НовыйОбъектSABY(Новый ФиксированнаяСтруктура("Тип, Свойства", "ExtException", КлючиЭкземпляра));
	
	Если	ТипЗнч(Type) = Тип("Число")
		Или	ТипЗнч(Type) = Тип("ФиксированнаяСтруктура") Тогда
		
		// Пришел код в виде числа, или разложенный в фикс. структуре
		NewExtException.code = яExtException_Static_CodeFormat(Type);
		
	Иначе
		
		NewExtException.code = яExtException_Static_CodeFormat();
		Если ТипЗнч(Type) = Тип("Строка") Тогда
			
			// Тут можно расширить определение кода по устанавливаемому типу
			ExtException_Set(NewExtException, "Type", Type);
			
		КонецЕсли;

	КонецЕсли;
	
	Если Не Message = Неопределено Тогда
		
		NewExtException.message	= Message;
		
	КонецЕсли;
	NewExtException.detail	= Details;
	NewExtException.action	= Action;
	NewExtException.data	= Data;
	NewExtException.stack	= Новый Массив;
	
	Если Не Stack = Неопределено Тогда
		
		ExtException_Set(NewExtException, "stack", stack);
		
	КонецЕсли;
	
	Возврат NewExtException;

КонецФункции

// Функция - заполняет параметры по-умолчанию от того, что есть в созданном экземпляре
//
// Параметры:
//  ExtException - ExtException	 - созданный экземпляр
// 
//DynamicDirective
Процедура яExtException_InitInstance(ExtException)

	Если ExtException.code = Неопределено Тогда
		
		ExtException.code = яExtException_Static_CodeFormat();
		
	КонецЕсли;

	codesOld = ExtException_Get(ExtException, "OldCodes");
	
	Если ExtException.message = Неопределено Тогда
		
		ExtException.message = яExtException_Static_MessageByCodes(codesOld.code, codesOld.extCode);
		
	КонецЕсли;
	
	// Предварительная установка типа по основному коду. Со временем отказаться от кодов в пользу типизации.
	// Расширять перечень, по необходимости вынести в отдельный метод
	Если codesOld.code = 304 Тогда
		
		ОбъектSABY_Установить(ExtException, "Тип", "UnauthorizedError");
		
	ИначеЕсли  codesOld.code = 775 Тогда
		
		ОбъектSABY_Установить(ExtException, "Тип", "TransportError");
		
	КонецЕсли;

	Если ExtException.detail = Неопределено Тогда
		
		ExtException.detail = ExtException.message;
		
	КонецЕсли;
	
	ExtException.hint = яExtException_GetHint(ExtException);

КонецПроцедуры

//DynamicDirective
Процедура яExtException_AddToStack(ExtException, StackData)
	Перем СтарыйСбисСтек, ДанныеЗаписиСтека;
	
	СбисСтек = ExtException.stack;
	
	Если StackData = Неопределено Тогда
		
		Возврат;
		
	ИначеЕсли ТипЗнч(StackData) = Тип("Массив") Тогда
		
		// Передан стек
		СтарыйСбисСтек = StackData;
		// Возьмём дата от текущего исключения, чтобы проследить что она не попадет лишний раз в стэк
		ДанныеЗаписиСтека = ExtException.data; 
		
	Иначе
		
		// Запись в стэк по добавляемому исключению. Включая data.
		ЗаписьДляСтека = яExtException_Static_NewStackLine(StackData);
		// Возьмём дата от записи, чтобы проследить что она не попадет лишний раз в стэк
		ДанныеЗаписиСтека = ЗаписьДляСтека.data; 
		СбисСтек.Вставить(0, ЗаписьДляСтека);
		Если ТипЗнч(StackData) = Тип("Соответствие") Тогда
			СтарыйСбисСтек = StackData.Получить("stack");
		Иначе
			StackData.Свойство("stack", СтарыйСбисСтек);
		КонецЕсли;
		
	КонецЕсли;
	
	// Стэк есть и это не стэк от текущего исключения (возможность добавить ошибку саму себя в стэк перед перегенерацией)
	Если	Не	ЗначениеЗаполнено(СтарыйСбисСтек)
		Или		СтарыйСбисСтек = СбисСтек Тогда
		
		Возврат;
		
	КонецЕсли;
		
	// Пробросить в конец элементы от старого стека
	Для Каждого ЭлементСтарогоСтека Из СтарыйСбисСтек Цикл
		
		ЗаписьДляСтекаОтСтарого = яExtException_Static_NewStackLine(ЭлементСтарогоСтека);
		Если ЗаписьДляСтекаОтСтарого.data = ExtException.data Тогда
			
			// В стэке не нужны, т.к. либо уже там есть, либо будет при пробросе этого исключения
			ЗаписьДляСтекаОтСтарого.data = Неопределено;
			
		КонецЕсли;
		СбисСтек.Добавить(ЗаписьДляСтекаОтСтарого);
		
	КонецЦикла;
	
КонецПроцедуры

//DynamicDirective
Функция яExtException_DefaultMessage(ExtException)
	
	Codes = ExtException_Get(ExtException, "OldCodes");
	Возврат яExtException_Static_MessageByCodes(Codes.code, Codes.extCode);
	
КонецФункции

//DynamicDirective

// Функция - Dump метод для исключений как полный текст
//
// Параметры:
//  ExtException	 - ExtException	 - текущая ошибка
// 
// Возвращаемое значение:
//  Строка - Сообщение в формате полного текста
//
Функция яExtException_Dump_FullText(ExtException) 
	
	Результат = ExtException.message;
	
	Если Результат = Неопределено Тогда
		
		Результат = "";
		
	КонецЕсли;
	
	Если	Не ExtException.message = ExtException.detail Тогда 
		Результат = Результат + Символы.ПС + "Детально: " + ExtException.detail;
	КонецЕсли;

	Если	ЗначениеЗаполнено(ExtException.dump)
		И	ExtException.dump.Свойство("ДетализацияОшибки")
		И	ExtException.dump.Свойство("ИсходнаяСтрока")
		И	ExtException.dump.Свойство("НомерСтроки") Тогда
		
		СтрокаДетально = "В модуле {ИмяМодуля}, в строке ""{ИсходнаяСтрока}"" ({НомерСтроки}) произошла ошибка ""{ДетализацияОшибки}""!";
		//СтрокаДетально = ПрименитьФорматКСтроке(СтрокаДетально, ExtException.dump);
		Результат = Результат + Символы.ПС + "Подбробная информация: " + СтрокаДетально;
		
	КонецЕсли;
	
	Возврат Результат;
	
КонецФункции

#Область include_core2_base_Helpers_ExtException_private_Append
#КонецОбласти

#Область include_core2_base_Helpers_ExtException_private_Static
#КонецОбласти

