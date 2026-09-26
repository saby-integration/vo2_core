
// Функция - анализ исключения
//
// Параметры:
//  HandledException	 - Произвльный	 - данные о возникшей проблеме. Это может быть готовое исключение, строка, число Структура, Соответствие и пр.
//  GeneratedException	 - ExtException	 - дополнительное исключение. Для конструктора это аргументы 2-6.
//  КонтекстОбъединения	 - Структура	 - контекст обработки исключения
// 
// Возвращаемое значение:
//  ExtException - обработанное исключение с учетом GeneratedException
//
//DynamicDirective
Функция яExtException_Static_Handle(HandledException, GeneratedException = Неопределено, КонтекстОбъединения = Неопределено);
	
	// Проверить перегрузки для конструктора
	Если		ТипЗнч(HandledException) = Тип("ИнформацияОбОшибке")	Тогда
		
		ExtException = яExtException_Static_Handle_ErrorInfo(HandledException, GeneratedException, КонтекстОбъединения);
		
	ИначеЕсли	ТипЗнч(HandledException) = Тип("Строка")				Тогда
		
		ExtException = яExtException_Static_Handle_String(HandledException, GeneratedException, КонтекстОбъединения);
		
	ИначеЕсли	ТипЗнч(HandledException) = Тип("Число")				Тогда
		
		ExtException = яExtException_CreateInstance(HandledException);
		
	ИначеЕсли	ОбъектSABY_ЭтоТип(HandledException, "ExtException") Тогда
			
		// Это уже готовое исключение. Проверка делается только по типу объекта.
		ExtException = ExtException_Copy(HandledException);

	ИначеЕсли	ПроверитьТипSaby(HandledException, "SbisWarning") Тогда
		
		ExtException = яExtException_Static_Handle_SabyWarning(HandledException, GeneratedException, КонтекстОбъединения)
		
	ИначеЕсли	ТипЗнч(HandledException) = Тип("Структура")			Тогда
		
		ExtException = яExtException_Static_Handle_Structure(HandledException, GeneratedException, КонтекстОбъединения);
		
	ИначеЕсли	ТипЗнч(HandledException) = Тип("Соответствие")			Тогда
		
		ExtException = яExtException_Static_Handle_Map(HandledException, GeneratedException, КонтекстОбъединения);
		
	Иначе
		
		//Неизвестная ошибка
		ExtException		= яExtException_CreateInstance();
		ExtException.dump	= яExtException_Static_NewDump(HandledException);
		
	КонецЕсли;
	
	Возврат ExtException;
	
КонецФункции

//DynamicDirective
Функция яExtException_Static_Handle_Map(HandledException, GeneratedException, КонтекстОбъединения)
		
	Источник = HandledException.Получить("Error");
	Если Источник = Неопределено Тогда
		
		Источник			= HandledException; 
		Параметр_message	= Источник.Получить("message");
		Параметр_method		= Источник.Получить("method_name");
		
		Если	Не Параметр_message = Неопределено
			И	Не	Параметр_method	= Неопределено Тогда
			
			Возврат яExtException_Static_Handle_PluginExtException(Источник, GeneratedException, КонтекстОбъединения);
			
		КонецЕсли;
		
	КонецЕсли;
	
	NewExtException = яExtException_CreateInstance();
	
	Для Каждого КлючИЗначение Из Источник Цикл
		
		ExtException_Set(NewExtException, КлючИЗначение.Ключ, КлючИЗначение.Значение);
		
	КонецЦикла;
	
	Если NewExtException.dump = Неопределено Тогда
		
		NewExtException.dump = яExtException_Static_NewDump(HandledException);
		
	КонецЕсли;
	
	Возврат NewExtException;
	
КонецФункции

// Функция - генерирует ExtSysException из информации об ошибке
//
// Параметры:
//  ErrorInfo			 - ИнформацияОбОшибке	 - вызванное исключение
//	GeneratedException	 - ExtException			 - генерируемое исключение в рамках анализа ошибки
//	КонтекстОбъединения	 - Структура			 - расширение
// 
// Возвращаемое значение:
//  ExtException - Структура разобранной ошибки
//
//DynamicDirective
Функция яExtException_Static_Handle_ErrorInfo(ErrorInfo, GeneratedException, КонтекстОбъединения)
	
	Если	ТипЗнч(ErrorInfo.Описание) = Тип("Строка")
		И	Лев(ErrorInfo.Описание, 5) = "{""#""," Тогда
		
		Попытка
			
			ВосстановленноеИсключение = Saby_ЗначениеИзСтрокиВнутрНаСервере(ErrorInfo.Описание);
			
			Если ПроверитьТипSaby(ВосстановленноеИсключение, "ExtException") Тогда
				
				НовоеИсключение = ВосстановленноеИсключение;
				
			Иначе
				
				// Неизвестно, что за исключение было в теле. Запустить разбор того, что там лежало.
				НовоеИсключение = яExtException_Static_Handle(ВосстановленноеИсключение, GeneratedException, КонтекстОбъединения)
				
			КонецЕсли;
			
			НовоеИсключение.dump = яExtException_Static_NewDump(ErrorInfo);
			
			Возврат НовоеИсключение;
			
		Исключение
			
			//Это не завёрнутый ExtSysException, дальше разбираем как 1С-ное исключение
		
		КонецПопытки;
			
	КонецЕсли;

    Возврат яExtException_Static_Handle_ErrorInfo_Continue(ErrorInfo, GeneratedException, КонтекстОбъединения);
	
КонецФункции

// Функция - генерирует ExtSysException из информации об ошибке
//
// Параметры:
//  ErrorInfo	 - ИнформацияОбОшибке	 - вызванное исключение, которое не является запакованным ExtException
// 
// Возвращаемое значение:
//  ExtException - Структура ошибки
//
//DynamicDirective
Функция яExtException_Static_Handle_ErrorInfo_Continue(ErrorInfo, GeneratedException, КонтекстОбъединения)
	Перем СообщениеОбОшибке;
	
	СложнаяСтруктура = Ложь;
	
	СтруктураОшибкиСообщения = ErrorInfo;
	Пока ТипЗнч(СтруктураОшибкиСообщения.Причина) = Тип("ИнформацияОбОшибке") Цикл
		СтруктураОшибкиСообщения = СтруктураОшибкиСообщения.Причина;
		СложнаяСтруктура = Истина;
	КонецЦикла;
	
	Если СложнаяСтруктура Тогда
		
		СообщениеОбОшибке	= ErrorInfo.Описание;
		ДетализацияОшибки	= СтруктураОшибкиСообщения.Описание;
		
	ИначеЕсли ErrorInfo.Причина = Неопределено Тогда
		
		ДетализацияОшибки	= ErrorInfo.Описание;
		
	Иначе
		
		СообщениеОбОшибке	= ErrorInfo.Описание;
		ДетализацияОшибки	= ErrorInfo.Причина;
		
	КонецЕсли;
	
	// Так как тут упало в 1С-ное ИнформацияОбОшибке, то проводим анализ, где кодом по-умолчанию будет 600 - Неизвестная ошибка приложения 
	КодыНовогоИсключения	= яExtException_AnalysePlatfromMessages(GeneratedException, СообщениеОбОшибке, ДетализацияОшибки);
	КодыВСтаромФормате		= ExtException_Get(GeneratedException, "OldCodes");
	
	Если    Не КодыНовогоИсключения.code = 600
		И	Не КодыНовогоИсключения.code = КодыВСтаромФормате.code Тогда
		
		// По предполагаемой ошибке смогли подобрать другой код на основании Информации об ошибке 1С.
		GeneratedException.stack.Добавить(яExtException_Static_NewStackLine(GeneratedException));
		GeneratedException.code		= Неопределено;
		GeneratedException.message	= Неопределено;
		
	ИначеЕсли ЗначениеЗаполнено(КодыНовогоИсключения.extCode) Тогда
		
		// Сообщение должно быть установлено по кодам
		СообщениеОбОшибке = Неопределено;   
	
	ИначеЕсли	КодыНовогоИсключения.code = 776 Тогда
		
		СообщениеОбОшибке = ДетализацияОшибки;
		
	ИначеЕсли	КодыНовогоИсключения.code	= 717 Тогда
		
		ДетализацияОшибки	= СообщениеОбОшибке + " " + ДетализацияОшибки;
		СообщениеОбОшибке	= Неопределено;	
		
	Иначе
		
		КонтекстОбъединения.ОбновитьТекстСообщения = Ложь;

	КонецЕсли;

	СбисОсновнаяОшибка = яExtException_CreateInstance(	яExtException_Static_CodeFormat(КодыНовогоИсключения),
														СообщениеОбОшибке,
														ДетализацияОшибки,
														СокрЛП(ErrorInfo.ИсходнаяСтрока));
												
	СбисОсновнаяОшибка.dump	= яExtException_Static_NewDump(ErrorInfo, ДетализацияОшибки);
	Если ЗначениеЗаполнено(КодыНовогоИсключения.extCode) Тогда
		
		СбисОсновнаяОшибка.message		= яExtException_DefaultMessage(СбисОсновнаяОшибка);
		КонтекстОбъединения.ОбновитьКод = Истина;
		
	КонецЕсли;
	
	ExtException_Set(СбисОсновнаяОшибка, "Тип", "1cErrorInfo");
	
	Возврат СбисОсновнаяОшибка;
	
КонецФункции

// Функция - генерирует ExtSysException из строки
//
// Параметры:
//  StringIn	 - Строка	 - исключение, которое может быть сериализованнйо в JSON строкой, либо просто сообщением.
// 
// Возвращаемое значение:
//  ExtException - ошибка
//
//DynamicDirective
Функция яExtException_Static_Handle_String(StringIn, GeneratedException, Context)
    Перем СтрокаРазбора, ДампОшибки, ДампДетализация, ДампИмяМодуля, ДампНомерСтроки, ДампИсходнаяСтрока, КодОшибкиНаш, ИмяМетодаОшибки, ТипОшибкиОпределяемый;
	
	БазоваяОшибка = StringIn;
	Если Лев(БазоваяОшибка, 4) = "http" Тогда
		
		КодОшибкиHTTP			= Сред(БазоваяОшибка,5,3);
		КодОшибкиНаш			= яExtException_Static_OurCodeByHTTPCode(КодОшибкиHTTP);
		ИмяМетодаОшибки			= "HTTPСоединение.ОтправитьДляОбработки";
		БазоваяОшибка			= Неопределено;
		ТипОшибкиОпределяемый	= "HTTPStatus"
		
	ИначеЕсли Лев(БазоваяОшибка, 1) = "{" Тогда		
		
		//Это JSON - объект с ошибкой
		СтрокаРазбора 			= БазоваяОшибка;
		ТипОшибкиОпределяемый	= "JSONDataError"
		
	ИначеЕсли	Лев(БазоваяОшибка,35) = "callBLObject(): Метод бизнес логики"
		И		Найти(БазоваяОшибка,"вернул ошибку") Тогда
		
		ИмяМодуля		= СтрЗаменить(БазоваяОшибка, "callBLObject(): Метод бизнес логики", Символы.ПС);
		ИмяМодуля		= СтрЗаменить(БазоваяОшибка, "вернул ошибку", Символы.ПС);
		
		//Это ошибка от БЛ в формате JSON
		СтрокаРазбора	= Сред(БазоваяОшибка, Найти(БазоваяОшибка,"{"));
		СтрокаРазбора	= Лев(СтрокаРазбора, СтрДлина(СтрокаРазбора)-1);
		
		ДампДетализация		= Лев(БазоваяОшибка, Найти(БазоваяОшибка,"{") - 1);
		ДампИмяМодуля		= СтрПолучитьСтроку(ИмяМодуля, 2);
		ДампИмяМодуля		= "Saby." + ИмяМодуля;
		ДампИсходнаяСтрока	= "callBLObject(): Метод бизнес логики " + ИмяМодуля + "вернул ошибку";
		ДампОшибки			= яExtException_Static_NewDump(, ДампДетализация, ДампИсходнаяСтрока,  ДампНомерСтроки, ДампИмяМодуля);
		ТипОшибкиОпределяемый	= "callBLObjectError";
		
	ИначеЕсли Найти(БазоваяОшибка, "{""jsonrpc"":") Тогда
		
		//Это ошибка от БЛ в формате JSON
		НачалоТелаСтроки		= Найти(БазоваяОшибка,"{""jsonrpc"":");
		СтрокаРазбора			= Сред(БазоваяОшибка, НачалоТелаСтроки);
		ДампДетализация			= Лев(БазоваяОшибка, НачалоТелаСтроки - 1);
		ДампИсходнаяСтрока		= "{""jsonrpc"":";
		ДампОшибки				= яExtException_Static_NewDump(, ДампДетализация, ДампИсходнаяСтрока,  ДампНомерСтроки, ДампИмяМодуля);
		ТипОшибкиОпределяемый	= "jsonrpcRequest"
		
	КонецЕсли;
	
	Если СтрокаРазбора = Неопределено Тогда
		
		//Это сообщение неизвестной ошибки.
		СбисОсновнаяОшибка = яExtException_CreateInstance(КодОшибкиНаш, БазоваяОшибка,,ИмяМетодаОшибки);
		ExtException_Set(СбисОсновнаяОшибка, "Type", ТипОшибкиОпределяемый);

	Иначе
		
		Попытка
			
			СбисОшибкаИзJSON = ПрочитатьJSONСтрокуВОбъект(СтрокаРазбора);
			Если СбисОшибкаИзJSON.Свойство("Error") Тогда
				
				СбисОшибкаИзJSON = СбисОшибкаИзJSON.Error;
				
			КонецЕсли;
			
			Если ПроверитьТипSaby(СбисОшибкаИзJSON, "SbisWarning") Тогда
				
				СбисОсновнаяОшибка = яExtException_Static_Handle_SabyWarning(СбисОшибкаИзJSON, GeneratedException, Context);
				
			ИначеЕсли СбисОшибкаИзJSON = "Not authorized." Тогда
				
				СбисОсновнаяОшибка = яExtException_CreateInstance("UnauthorizedError");

			Иначе	
				
				// Неизвестная ошибка отправится в message.
				СбисОсновнаяОшибка = яExtException_CreateInstance(ТипОшибкиОпределяемый, СбисОшибкаИзJSON);
				
			КонецЕсли;	
			
		Исключение
			
			ОшибкаРазбора = NewExtException(ИнформацияОбОшибке(), "ExtException.Static.Handle.String.ПрочитатьJSONСтрокуВОбъект");
			СбисОсновнаяОшибка = яExtException_CreateInstance(,,,,Новый Структура("Error", БазоваяОшибка));
			ExtException_Append(СбисОсновнаяОшибка,, ОшибкаРазбора);
			
		КонецПопытки;
		
	КонецЕсли; 
	
	СбисОсновнаяОшибка.dump	= ДампОшибки;
	
	Возврат СбисОсновнаяОшибка;
	
КонецФункции	

// Функция - генерирует ExtSysException из структуры
//
// Параметры:
//  БазоваяОшибка			 - SbisWarning		 - исключение в виде структуры, присылаемое БЛ
//  ГенерируемоеИсключение	 - СбисИсключение	 - текущее формируемое исключение
// 
// Возвращаемое значение:
//  ExtException - Структура ошибки
//
//DynamicDirective
Функция яExtException_Static_Handle_SabyWarning(SabyWarning, GeneratedException, Context)
	
	code = яExtException_Static_OurCodeByAPICode(ВРег(SabyWarning.data.classid));
	
	WarningData = Новый Структура("message, details, stack");
	ЗаполнитьЗначенияСвойств(WarningData, SabyWarning);
	
	ExtException = яExtException_CreateInstance(code,,, "ExtException.Handle.SabyWarning", SabyWarning.data);
	ExtException_Set(ExtException, "Type", "From_SabyWarning");
	
	ExtException_Append(ExtException, "SabyWarning", WarningData);

	Возврат ExtException;
	
КонецФункции

// Функция - генерирует ExtSysException из структуры
//
// Параметры:
//  БазоваяОшибка	 - Строка	 - исключение, которое может быть сериализованнйо в JSON строкой, либо просто сообщением.
// 
// Возвращаемое значение:
//  Структура - ExtSysException
//
//DynamicDirective
Функция яExtException_Static_Handle_Structure(StructureIn, GeneratedException, Context)
    Перем ДампОшибки, ДампДетализация, ДампИмяМодуля, ДампНомерСтроки, ДампИсходнаяСтрока;
	
	Если	StructureIn.Свойство("code")
		И	StructureIn.Свойство("detail")
		И	StructureIn.Свойство("method_name") Тогда
			
		// Это ошибка плагина, модуля (ExtSDK2)
		ExtException = яExtException_Static_Handle_PluginExtException(StructureIn, GeneratedException, Context);

	Иначе
		
		ExtException = яExtException_CreateInstance();
		ExtException_Append(ExtException,,StructureIn);
		
	КонецЕсли;  
		
	Возврат ExtException;
	
КонецФункции 

// Функция - генерирует ExtSysException из структуры
//
// Параметры:
//  БазоваяОшибка
// 
// Возвращаемое значение:
//  Структура - ExtSysException
//
// BSLLS:CognitiveComplexity-off
// BSLLS:CyclomaticComplexity-off
//DynamicDirective
Функция яExtException_Static_Handle_PluginExtException(PluginExtException, GeneratedException, Context)
	Перем ExtMessage, ExtDetails, ExtData, ExtStack, OriginalError, APICode, ExtDump, ExtCode, ExtAction;
	
	// Задать тип для проброски его в стэк
	PluginExtException.Вставить("type", "PluginExtException");

	Если ТипЗнч(PluginExtException) = Тип("Соответствие") Тогда
		
		OriginalError	= PluginExtException.Получить("original_error");
		ExtCode			= PluginExtException.Получить("code");
		ExtMessage		= PluginExtException.Получить("message");
		ExtDetails		= PluginExtException.Получить("detail");
		ExtAction		= PluginExtException.Получить("method_name");
		ExtDump			= PluginExtException.Получить("dump");
		ExtStack		= PluginExtException.Получить("stack");
		
	Иначе
		
		PluginExtException.Свойство("original_error",	OriginalError);
		PluginExtException.Свойство("code",				ExtCode);
		PluginExtException.Свойство("message",			ExtMessage);
		PluginExtException.Свойство("detail",			ExtDetails);
		PluginExtException.Свойство("method_Name",		ExtAction);
		PluginExtException.Свойство("dump",				ExtDump);
		PluginExtException.Свойство("stack",			ExtStack);
		
	КонецЕсли;

	Если Не OriginalError = Неопределено Тогда
		
		APICode = яExtException_Static_OurCodeByAPICode("{" + OriginalError["classid"] + "}"); 
		
	КонецЕсли; 
  
	Если	APICode = Неопределено
		Или	APICode = 100000 Тогда  
		Если ExtCode = 303 Тогда
			ExtException = яExtException_CreateInstance("ConfirmAuthError",ExtMessage,ExtDetails, ExtAction,,, PluginExtException);
		Иначе	
			ExtException = яExtException_CreateInstance(ExtCode,ExtMessage,ExtDetails, ExtAction,,, PluginExtException);
		КонецЕсли;
		
	Иначе
		
		WarningData = Новый Структура("details, message, stack, data", ExtDetails, ExtMessage, ExtStack, ExtData);
		ExtException = яExtException_CreateInstance(APICode,,, ExtAction, WarningData.data);
		ExtException_Append(ExtException, "SabyWarning", WarningData);
		
	КонецЕсли;
	
	//Нет ошибки БЛ, значит это исключение плагина, пробуем подобрать по тексту от плагина
	
	Если Context.ОбновитьКод Тогда 
		
		// Нужно проверить текст и обновить код ошибки.
		Если Найти(ExtDetails, "заблокирован согласно назначеннным правам") Тогда
			
			ExtException_Set(ExtException, "code",		306302);
			ExtException_Set(ExtException, "detail",	"Метод " + ExtAction + " заблокирован согласно назначенным правам");
			
		ИначеЕсли Найти(ExtDetails, "Не хватает подписи под") Тогда			 
			
			ExtException_Set(ExtException, "code",		731101);
			ExtException_Set(ExtException, "detail",	"Отсутствует сертификат для утверждения/отклонения пакета документов");
			
		ИначеЕсли Найти(ExtDetails, "зашифрованном виде необходим локальный сертификат") Тогда
			
			ExtException_Set(ExtException, "code",		731107);
			ExtException_Set(ExtException, "detail",	"Не найден сертификат для шифрования");
			
		ИначеЕсли Найти(ExtDetails, "Ошибка авторизации при вызове") Тогда
			
			ExtException_Set(ExtException, "type",		"UnauthorizedError");
			ExtException_Set(ExtException, "detail",	ExtMessage);

		КонецЕсли;
		
	Иначе
		
		// code исключения плагина с большой долей вероятности не будет соответствовать нашим, поэтому добавляем только в стэк.
		ExtException_Set(ExtException, "message",	ExtMessage);
		ExtException_Set(ExtException, "detail",	ExtDetails);
			
	КонецЕсли;
	
	Если ЗначениеЗаполнено(ExtDump) Тогда
		
		// Переложить дамп ошибки в data, т.к. для плагина это оно и есть
		ДампОшибки = ExtDump;
		
		// Если http запрос упал в плагине
		Если ТипЗнч(ДампОшибки) = Тип("Структура") Тогда
			Если	ДампОшибки.Свойство("data")
				И	ДампОшибки.data.Свойство("StatusCode") Тогда
				
				КодОшибкиHTTP	= ДампОшибки.data.StatusCode;
				КодОшибки		= яExtException_Static_OurCodeByHTTPCode(КодОшибкиHTTP);
				ExtException2	= яExtException_CreateInstance(КодОшибки);
				ExtException_Append(ExtException,, ExtException2);
				
			КонецЕсли;
			
			Если Не ДампОшибки.Свойство("addinfo") Тогда
				
				// Восстановим структуру ошибки БЛ, которую сломал плагин
				Если PluginExtException.code = 303 Тогда
				
					// Если код ошибки - 303, значит ожидается подтверждение аутентификации.
					addInfo = Новый Структура;
					addInfo.Вставить("Идентификатор",		ДампОшибки.ResourceID);
					addInfo.Вставить("ИдентификаторСессии",	ДампОшибки.SessionID);
					addInfo.Вставить("МетодВалидации",		ДампОшибки.MethodToValidate);
					
					ДампОшибки = Новый Структура("addinfo", addinfo);
					
				КонецЕсли;
				
			КонецЕсли;
			
		КонецЕсли;
				
		ExtException_Set(ExtException, "data", ДампОшибки);
				
	КонецЕсли;
		
	Если	(		Не	ЗначениеЗаполнено(ExtCode)
				Или		ExtCode = 100) Тогда
			
		КодОшибкиСтека = яExtException_Static_Handle_PluginExtException_ExtractCode(PluginExtException);
		
		Если КодОшибкиСтека = 300 Тогда
			
			// http ошибка. Наверх должна уйти именно эта ошибка, т.к. плагин все равно ее оборачивает неправильно. 
			КодИзDetail		= Лев(PluginExtException.detail, 3);
			КодОшибки		= яExtException_Static_OurCodeByHTTPCode(КодИзDetail);
			ExtExceptionNew	= яExtException_CreateInstance("HTTPStatus");
			ExtException_Set(ExtExceptionNew, "code", КодОшибки);
			
			ExtException_Append(ExtExceptionNew,, ExtException);
			Возврат ExtExceptionNew;
			
		ИначеЕсли	ТипЗнч(КодОшибкиСтека) = Тип("Число")
				И	КодОшибкиСтека >= 100 Тогда
			
			ExtException_Set(ExtException, "code", КодОшибкиСтека);
			
		КонецЕсли;
		
	КонецЕсли;
	
	Возврат ExtException;
	
КонецФункции
// BSLLS:CyclomaticComplexity-on
// BSLLS:CognitiveComplexity-on

//DynamicDirective
Функция яExtException_Static_Handle_PluginExtException_ExtractCode(ExtSysException)
	Перем СтекОшибки, ЗаписьОшибкиВСтеке;
	
	ЭтоСоответствия = ТипЗнч(ExtSysException) = Тип("Соответствие");
	Если ЭтоСоответствия Тогда
		
		СтекОшибки = ExtSysException.Получить("stack");
		
	Иначе
		
		ExtSysException.Свойство("stack", СтекОшибки);
		
	КонецЕсли;
	
	Если Не ЗначениеЗаполнено(СтекОшибки) Тогда
		
		Возврат Неопределено;
		
	КонецЕсли;
		
	ОшибкаИзStack = СтекОшибки[0];
	Если ЭтоСоответствия Тогда
		
		ЗаписьОшибкиВСтеке = ОшибкаИзStack.Получить("error");
		
	Иначе
		
		ОшибкаИзStack.Свойство("error", ЗаписьОшибкиВСтеке);
		
	КонецЕсли;
	
	Если Не		ЗаписьОшибкиВСтеке = Неопределено
			И	Найти(ЗаписьОшибкиВСтеке, " : error ") Тогда
		
		КодОшибки = Лев(СтрЗаменить(ЗаписьОшибкиВСтеке," : error ", ""),3);
		ОписаниеЧисла = Новый ОписаниеТипов("Число");
		КодОшибки = ОписаниеЧисла.ПривестиЗначение(КодОшибки);
		Если Булево(КодОшибки) Тогда
			
			Возврат КодОшибки;
			
		КонецЕсли;
		
	КонецЕсли;
	
	Возврат Неопределено;
	
КонецФункции

