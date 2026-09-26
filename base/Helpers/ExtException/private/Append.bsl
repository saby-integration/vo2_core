
// Процедура - объединение исключений
//
// Параметры:
//  ExtException		 - ExtException	 - текущее исключение, в которое добавляются данные из другого
//  AppendableException	 - ExtException	 - добавляемое исключение
//  КонтектОбъединения	 - Структура	 - расширение объединения
//
//DynamicDirective
Процедура яExtException_Append_ExtException(ExtException, AppendableException, MethodContext = Неопределено)
	Перем СбисСтек;
	
	// Если не указано явно, то сообщения обновляются только в рамках прописи значений если они пусты
	Если MethodContext = Неопределено Тогда
		
		ОбновитьДетализацию		 = Не ЗначениеЗаполнено(ExtException.detail);
		ОбновитьТекстСообщения	 = Не ЗначениеЗаполнено(ExtException.message);
		ОбновитьКод				 = ExtException.code = яExtException_Static_CodeFormat();
		
	Иначе
		
		ОбновитьДетализацию		 = MethodContext.ОбновитьДетализацию;
		ОбновитьТекстСообщения	 = MethodContext.ОбновитьТекстСообщения;
		ОбновитьКод				 = MethodContext.ОбновитьКод;
		
	КонецЕсли;
	
	//Если не указаны основные поля для новой ошибки
	Если ОбновитьКод Тогда
		
		ExtException.code = AppendableException.code;
				
	КонецЕсли;
	
	Если ОбновитьТекстСообщения	Тогда
		
		ExtException.message = AppendableException.message;
		
	КонецЕсли;
	
	Если ОбновитьДетализацию Тогда
		
		Если AppendableException.detail = Неопределено Тогда
		
			ExtException.detail = AppendableException.message;
			
		Иначе
			
			ExtException.detail = AppendableException.detail;
			
		КонецЕсли;
	
	КонецЕсли;
	
	Если    	ExtException.hint = Неопределено
		Или	Не	ExtException.hint.type = "url" Тогда
		
		ExtException.hint = AppendableException.hint;
		
	КонецЕсли;
	
	// data от ошибки прокидывается на верхний уровень всегда.
	Если ExtException.data = Неопределено Тогда
		
		// Поверхностная копия data для отрыва от старой ошибки, включая стэк и пр.
		ExtException.data = НовыйКопияОбъекта(AppendableException.data);
		
	КонецЕсли;

	ExtException_Set(ExtException, "stack", AppendableException);
	
КонецПроцедуры
	
//DynamicDirective
Процедура яExtException_Append_SabyWarning(ExtException, WarningData, Context)
    Перем ДампДетализация, ДампИмяМодуля, ДампНомерСтроки, ДампИсходнаяСтрока;
	

	//вычисляем или переопределяем extCode 
	Если ExtException.code = 779 Тогда
		
		Если Найти(WarningData.details, "Не удалось определить работающего сотрудника по идентификатору") Тогда
			
			ExtException_Set(ExtException, "code", 779202);
			
		ИначеЕсли Найти(WarningData.details, "организация") Тогда
			
			ExtException_Set(ExtException, "code", 779204);
	  
		КонецЕсли;
		
	КонецЕсли;  
	
	message = WarningData.message;
	Если message = Неопределено Тогда
		
		OldCodes	= ExtException_Get(ExtException, "OldCodes");
		message		= яExtException_Static_MessageByCodes(OldCodes.code, OldCodes.extcode);
		
	КонецЕсли;

	details = WarningData.details;
	Если details = Неопределено Тогда
		
		details	= message;
		
	КонецЕсли;
	
	ExtException_Set(ExtException, "message",	message);
	ExtException_Set(ExtException, "stack",		WarningData.stack);
	ExtException_Set(ExtException, "dump",		яExtException_Static_NewDump(WarningData,,,,"Saby.Warning"), "dump");
	
	Если	ЗначениеЗаполнено(details) 
		И	Лев(details, "1") = "{"
		И	Прав(details, "1") = "}" Тогда
		
		ЗапакованныеЗначения = ПрочитатьJSONСтрокуВОбъект(details);
		Если ПроверитьТипSaby(ЗапакованныеЗначения, "ExtException") Тогда
			
			// Внутри details лежит запакованное исключение, которое нам прислала БЛ. 
			// Как основной ответ должно быть оно, а не то что определилось по оберткам.
			NewExtException = NewExtException(ЗапакованныеЗначения, "ExtException.Append.SabyWarning");
			ExtException_Append(NewExtException, "ExtException", ExtException);
			ExtException = NewExtException;
			Возврат;
			
		Иначе
			
			data = Новый Структура("addinfo", ЗапакованныеЗначения);
			ExtException_Set(ExtException, "data", data);
			
		КонецЕсли; 
		
	Иначе
		
		ExtException_Set(ExtException, "Details", details);	
		
	КонецЕсли;
		
КонецПроцедуры

//DynamicDirective
Процедура яExtException_Append_Structure(ExtException, StructureData, Context)
	
	Для Каждого КлючИЗначение Из StructureData Цикл
		
		ExtException_Set(ExtException, КлючИЗначение.Ключ, КлючИЗначение.Значение);
		
	КонецЦикла;
	
КонецПроцедуры

//DynamicDirective

// Функция - генерирует описание решения ошибки по текущей информации
//
// Параметры:
//  ExtException	 - ExtException	 - Исключение, для которого требуется получить ссылку, либо действие на решение для пользователя
// 
// Возвращаемое значение:
//  Структура - hint, с полями type, text, action, где
//		type = что было подобрано: url если это ссылка на БЗ, либо command если это команда в модуле.
//		text = представление для вывода в интерфейсе
//		action = ссылка, или имя вызываемой команды модуля.
//
Функция яExtException_GetHint(ExtException)
	
	Если ЗначениеЗаполнено(ExtException.hint) Тогда
		
		// Есть готовый - пришел от БЛ или плагина
		Возврат ExtException.hint;
		
	КонецЕсли;
		
	РешениеПроблемы = Новый Структура("type, text, action", "url", "Решение ошибки");
	OldCodes		= ExtException_Get(ExtException, "OldCodes");
	Если OldCodes.code = 301 Тогда
		
		Если OldCodes.extCode  = 101 Тогда
			
			РешениеПроблемы.action = "https://saby.ru/help/integration/1C_set/modul/typical_errors/internet_error";
			
		КонецЕсли; 
		
	ИначеЕсли OldCodes.code = 306 Тогда
		
		Если OldCodes.extCode  = 101 Тогда
			
			РешениеПроблемы.action = "https://online.sbis.ru/article/8d3fc255-3db6-4f0f-8dcc-119dd9d233ca/a90c74a8-cf82-4d6f-9141-f0090c8aa482";
			
		ИначеЕсли OldCodes.extCode  = 103 Тогда
			
			РешениеПроблемы.action = "https://online.sbis.ru/article/f3817cb5-02be-4c93-95ac-ef7caa3efea7/e50b4023-d32e-4b69-b7fe-243f87e9aafc";
			
		ИначеЕсли OldCodes.extCode  = 302 Тогда
			
			РешениеПроблемы.action = "https://online.sbis.ru/article/f3817cb5-02be-4c93-95ac-ef7caa3efea7/1d9d5639-2df1-45d1-9630-01030f0d8879";
			
		КонецЕсли; 
		                                     		
	ИначеЕсли OldCodes.code = 310 Тогда
		
		Если OldCodes.extCode  = 75 Тогда
			
			РешениеПроблемы.action = "https://saby.ru/help/data_exchange/marking/start/nastr?tb=tab2";
			
		КонецЕсли;
		
	ИначеЕсли OldCodes.code = 325 Тогда
		
		Если OldCodes.extCode  = 150 Тогда
			
			РешениеПроблемы.action = "https://saby.ru/help/integration/1C_set/modul/resend";
			
		ИначеЕсли OldCodes.extCode  = 201 Тогда
			
			РешениеПроблемы.action = "https://link.sbis.ru/article/f3817cb5-02be-4c93-95ac-ef7caa3efea7/e85c917b-53bc-4d78-98c0-6cecaa7e1258";
			
		КонецЕсли;
	
	ИначеЕсли OldCodes.code = 502 Тогда
		
		Если OldCodes.extCode  = 100 Тогда
			
			РешениеПроблемы.action = "https://saby.ru/help/integration/1C_set/modul/rights";
			
		КонецЕсли;	
		
	ИначеЕсли OldCodes.code = 703 Тогда
		
		Если OldCodes.extCode  = 102 Тогда
			
			РешениеПроблемы.action = "https://saby.ru/help/integration/catalog/driver_not_found";
			
		КонецЕсли;
		
	ИначеЕсли OldCodes.code = 709 Тогда
		
		Если OldCodes.extCode  = 101 Тогда
			
			РешениеПроблемы.action = "https://saby.ru/help/integration/1C_set/modul/rights";
			
		КонецЕсли;
		
	ИначеЕсли OldCodes.code = 711 Тогда
		
		Если OldCodes.extCode  = 101 Тогда
			
			РешениеПроблемы.action = "https://saby.ru/help/plugin/sbis3plugin/install";
			
		КонецЕсли;
		
	ИначеЕсли OldCodes.code = 731 Тогда
                                                        
		Если OldCodes.extCode = 102 Тогда
			
			РешениеПроблемы.action = "https://saby.ru/help/integration/1C_set/modul/local_vo";
			
		ИначеЕсли OldCodes.extCode = 101 Тогда
			
			РешениеПроблемы.action = "https://online.sbis.ru/article/f3817cb5-02be-4c93-95ac-ef7caa3efea7/0d7c6671-13af-488c-8aec-c4db3bd5bc06";
			
		КонецЕсли;
		
	ИначеЕсли OldCodes.code = 735 Тогда

		Если	OldCodes.extCode = 101 Тогда
			
			РешениеПроблемы.action = "https://saby.ru/help/integration/1C_set/modul/exchange";
			
		КонецЕсли; 
		
	ИначеЕсли OldCodes.code = 747 Тогда

		Если	OldCodes.extCode = 101 Тогда
			
			РешениеПроблемы.action = "https://online.sbis.ru/article/f3817cb5-02be-4c93-95ac-ef7caa3efea7/0df8c1b2-fecd-4583-8635-e258594465d5";
			
		КонецЕсли;
		
	ИначеЕсли OldCodes.code = 760 Тогда

		Если	OldCodes.extCode = 101 Тогда
			
			РешениеПроблемы.action = "https://saby.ru/help/integration/1C_set/modul/typical_errors/cert_not_found_vo";
			
		КонецЕсли;
				
	ИначеЕсли OldCodes.code = 770 Тогда

		Если	OldCodes.extCode = 103 Тогда
			
			РешениеПроблемы.action = "https://online.sbis.ru/article/8a37d386-6b03-4aa6-969a-51b4bcbe6277/d82ac9ec-1169-4027-9582-66abf8b2d60b";
			
		КонецЕсли;
		
	ИначеЕсли OldCodes.code = 772 Тогда

		Если	OldCodes.extCode = 102 Тогда
			
			РешениеПроблемы.action = "https://online.sbis.ru/article/f3817cb5-02be-4c93-95ac-ef7caa3efea7/0f6f72b7-d5d8-4893-a226-cde0e415c3c0";
			
		ИначеЕсли OldCodes.extCode = 104 Тогда
			
			РешениеПроблемы.action = "https://saby.ru/help/integration/1C_set/modul/check_catalog";
			
		КонецЕсли;
		
	ИначеЕсли OldCodes.code = 773 Тогда
		
		Если OldCodes.extCode  = 101 Тогда
			
			РешениеПроблемы.action = "https://saby.ru/help/integration/1C_set/modul/rights";
			
		КонецЕсли;
		
	ИначеЕсли OldCodes.code = 775 Тогда
		
		Если OldCodes.extCode  = 101 Тогда
			
			РешениеПроблемы.action = "https://saby.ru/help/integration/1C_set/modul/typical_errors/plugin_answer";
			
		КонецЕсли;

	ИначеЕсли OldCodes.code = 776 Тогда
		
		Если	OldCodes.extCode = 101 Тогда
			
			РешениеПроблемы.action = "https://saby.ru/help/integration/catalog/driver_not_found";
			
		КонецЕсли;
		
	ИначеЕсли OldCodes.code = 775 Тогда
		
		Если	OldCodes.extCode = 102 Тогда
			
			РешениеПроблемы.action = "https://online.saby.ru/reg/?check=ExtSDK";
			
		КонецЕсли;
		
	ИначеЕсли OldCodes.code = 779 Тогда
		                                                     
		Если	OldCodes.extCode = 301
			Или OldCodes.extCode = 201 Тогда
			
			РешениеПроблемы.action = "https://online.sbis.ru/article/f3817cb5-02be-4c93-95ac-ef7caa3efea7/a79d02b8-c289-4b48-ae9c-f3d69f3409e1";
			
		ИначеЕсли OldCodes.extCode = 202 Тогда
			
			РешениеПроблемы.action = "https://online.saby.ru/page/kbase_entity/e0ccd4d9-9159-48a2-9143-3479ea0917b4?folderId=a830f104-239b-495c-aa88-9c05b1c6f4dd";
		
		ИначеЕсли OldCodes.extCode = 203 Тогда
			
			РешениеПроблемы.action = "https://saby.ru/help/integration/1C_set/modul/typical_errors/identerr";
			
		ИначеЕсли OldCodes.extCode = 204 Тогда
			
			РешениеПроблемы.action = "https://link.sbis.ru/article/f3817cb5-02be-4c93-95ac-ef7caa3efea7/803ac165-6efb-40d2-974f-789f60e56a0c";
			
		ИначеЕсли OldCodes.extCode = 108 Тогда
			
			РешениеПроблемы.action = "https://saby.ru/help/integration/1C_set/modul/download";
			
		ИначеЕсли OldCodes.extCode = 103 Тогда
			
			РешениеПроблемы.action = "https://saby.ru/help/integration/1C_set/modul/update_edits";
			
		КонецЕсли;
		
	КонецЕсли;
	
	Если РешениеПроблемы.action = Неопределено Тогда
		
		РешениеПроблемы = Новый Структура("type, text, action", "command", "Сохранить данные об ошибке", "СохранитьОшибку")
		
	КонецЕсли;

	Возврат РешениеПроблемы;
	
КонецФункции

//DynamicDirective

// Функция - гадание на кофейной гуще для стартового определения кода, если ловим 1С-ное исключение.
//
// Параметры:
//	ExtException		 - ExtException			 - ПРЕДПОЛАГАЕМАЯ ошибка, которая формируется на основании упавшего исключения 1С. 
//		Она нам нужна, чтобы получить значения которые были переданы в конструктор исключения из места падения для дополнительного уточнения кейса.
//  СообщениеОбОшибке	 - Строка				 - основное сообщение ошибки
//  ДетализацияОшибки	 - Строка				 - детализация ошибки. Это либо Описание, либо Описание из вложенного описания исключения
//  КодНовогоИсключения	 - Число (600)			 - код ошибки, если не удастся определить по сообщениям проблему
// 
// Возвращаемое значение:
//  ФиксированнаяСтруктура - основной код и расширение в старом формате.
//
Функция яExtException_AnalysePlatfromMessages(ExtException, СообщениеОбОшибке, ДетализацияОшибки = Неопределено, КодНовогоИсключения = 600)
	Перем КодРасширения, ПредполагаемыйСценарий;
	
	КодыОшибкиГен = ExtException_Get(ExtException, "OldCodes");
	ПредполагаемыйКод		= КодыОшибкиГен.code;
	ПредполагаемыйСценарий	= КодыОшибкиГен.extCode;

	Если Не ПредполагаемыйСценарий = Неопределено Тогда
		
		// Уже есть код расширения для нового исключения.
		// Пока не трогаю. т.к. могут быть конфликты
		
	ИначеЕсли ПредполагаемыйКод = 400 Тогда
		
		КодНовогоИсключения = ПредполагаемыйКод;
		Если Найти(ДетализацияОшибки, "SSL connect error") Тогда
			
			КодНовогоИсключения	= 301;
			КодДоп				= 301;
			КодРасширения		= 101;
			

		ИначеЕсли Найти(ДетализацияОшибки, "Couldn't resolve host name") Тогда
				
			КодНовогоИсключения = 401;
			КодРасширения = 101;
			
		ИначеЕсли Найти(ДетализацияОшибки, "Ошибка установки соединения") Тогда
				
			КодРасширения = 402;
			
		ИначеЕсли Найти(ДетализацияОшибки, "Превышен таймаут")
			Или Найти(ДетализацияОшибки, "Request Timeout") Тогда
				
			КодРасширения = 403; 
			
		КонецЕсли;

	ИначеЕсли ПредполагаемыйКод = 501 Тогда
		
		Если Найти(ДетализацияОшибки, "недостаточно прав") Тогда
		
			КодРасширения = 100;
			
		ИначеЕсли Найти(ДетализацияОшибки, "значение параметра") Тогда
			
			КодНовогоИсключения = 608;
			КодРасширения = 100;
			
		КонецЕсли;
		
	ИначеЕсли ПредполагаемыйКод = 502 Тогда
		
		// Ошибка записи в 1С
		Если    Найти(ДетализацияОшибки, "поля")
			И	Найти(ДетализацияОшибки, "не уникально") Тогда
		
			КодРасширения = 301;
			
		КонецЕсли;

	ИначеЕсли ПредполагаемыйКод = 615 Тогда
		
		// Ошибка создания объекта
		Если	Найти(ДетализацияОшибки, "Не найден")
			И	Найти(ДетализацияОшибки, "метод") Тогда
			
			// Упал конструктор описания оповещения
			КодНовогоИсключения	= 624;
			КодРасширения		= 100;
			
		КонецЕсли;

	ИначеЕсли ПредполагаемыйКод = 710 Тогда
		
		Если Найти(СообщениеОбОшибке, "Отсустствуют активные этапы") Тогда
			
			КодНовогоИсключения	= ПредполагаемыйКод;
			КодРасширения		= 101;
			
		КонецЕсли;
		
	ИначеЕсли ПредполагаемыйКод = 719 Тогда
		
		КодНовогоИсключения = ПредполагаемыйКод;
		Если	Найти(ДетализацияОшибки, "отменено") Тогда
			
			КодРасширения		= 104;
			
		КонецЕсли;
		
	ИначеЕсли ПредполагаемыйКод = 747 Тогда
		
		КодНовогоИсключения = ПредполагаемыйКод;
		Если	(	Найти(ДетализацияОшибки, "Отсутствует")
				Или Найти(ДетализацияОшибки, "не удалось получить"))
			И	Найти(ДетализацияОшибки, "ини файл") Тогда
			
			КодРасширения		= 200;
			
		ИначеЕсли Найти(ДетализацияОшибки,"не установлена") Тогда
			
			КодРасширения		= 101;
			
		КонецЕсли;
		
	ИначеЕсли ПредполагаемыйКод = 767 Тогда
		
		Если Найти(ДетализацияОшибки, НСтр("ru = 'Недостаточно прав'"))
			Или Найти(ДетализацияОшибки, НСтр("ru = 'Нарушение прав'")) Тогда
			
			КодНовогоИсключения = ПредполагаемыйКод;
			КодРасширения		= 301;
			
		КонецЕсли;

	ИначеЕсли ПредполагаемыйКод = 770 Тогда
		
		Если Найти(СообщениеОбОшибке, НСтр("ru = 'ЗагрузитьТаблицуСтилейXSLИзСтроки' en = 'LoadXSLStylesheetFromString'")) Тогда
			
			КодНовогоИсключения = ПредполагаемыйКод;
			КодРасширения		= 101;
			
		ИначеЕсли Найти(СообщениеОбОшибке, НСтр("ru = 'Ошибка разбора XML'")) Тогда
			
			КодНовогоИсключения = ПредполагаемыйКод;
			КодРасширения		= 104;
			
		КонецЕсли;	
		
	ИначеЕсли ПредполагаемыйКод = 765 Тогда
		
		Если Найти(ДетализацияОшибки, "СпособСопоставленияНоменклатуры") Тогда
		
			КодНовогоИсключения = ПредполагаемыйКод;
			КодРасширения = 101;
			
		КонецЕсли;
		
	ИначеЕсли ПредполагаемыйКод = 779 Тогда
		
		Если Найти(ДетализацияОшибки, "Значение поля ""Контрагент"" не может быть пустым!") Тогда
		
			КодНовогоИсключения = ПредполагаемыйКод;
			КодРасширения = 301;
			
		КонецЕсли;
		
	КонецЕсли;
	
	Если КодРасширения = Неопределено Тогда
		
		Если		Найти(ДетализацияОшибки, "ODBC")
			И	 Не Найти(ДетализацияОшибки, "dbf' уже существует") Тогда
				
			КодНовогоИсключения	= 776;
			КодРасширения		= 101;
			
		ИначеЕсли ДетализацияОшибки = "Не подключен файл статусов DBF." Тогда
			
			КодНовогоИсключения	= 753;
			КодРасширения		= 101;
			
		ИначеЕсли Найти(ДетализацияОшибки, "Недостаточно прав") Тогда
			
			КодНовогоИсключения	= 753;
			Если Найти(СообщениеОбОшибке, "(Выполнить)") Тогда
				
				КодРасширения = 101;
				
			КонецЕсли; 
			
		ИначеЕсли Найти(ДетализацияОшибки, "Ошибка доступа к файлу") Тогда
			
			КодНовогоИсключения	= 772;
			Если Найти(СообщениеОбОшибке, "СоздатьКаталог") Тогда
				
				КодРасширения = 104;
				
			КонецЕсли;
			
		ИначеЕсли Найти(ДетализацияОшибки, "Не найден контейнер ключа электронной подписи.") Тогда
			
			КодНовогоИсключения	= 731;
			КодРасширения = 110;
			
		ИначеЕсли Найти(ДетализацияОшибки, "Тип не определен") Тогда
			
			КодНовогоИсключения	= 612;
			
		ИначеЕсли Найти(ДетализацияОшибки, "евозможно расшифровать файл") Тогда
	
			КодНовогоИсключения	= 735;
			КодРасширения		= 101;
			
		ИначеЕсли Найти(ДетализацияОшибки, "В файле настроек некорректно указан путь к табличной части документа") Тогда	
			
			КодРасширения = 300;
			
		КонецЕсли;
		
	КонецЕсли;

	Если КодРасширения = Неопределено Тогда
		
		Если		КодНовогоИсключения = 100
			И	Не	ПредполагаемыйКод = 100
			И	Не	ПредполагаемыйКод = Неопределено Тогда
			
			// Не удалось определить код, но при этом предполагаемый код не дефолтный. Установить его как результат
			КодНовогоИсключения = ПредполагаемыйКод;
			
		КонецЕсли;
		
	КонецЕсли;
	
	Возврат Новый ФиксированнаяСтруктура("code, extCode", КодНовогоИсключения, КодРасширения);
	
КонецФункции

