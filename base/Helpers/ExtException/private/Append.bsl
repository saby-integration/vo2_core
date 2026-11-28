
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
		// Если переносим код, то обновляем в т.ч. тип. Пока делаем от кода.
		ErrorType = ОбъектSABY_Получить(AppendableException, "Тип");
		Если Не ОбъектSABY_ЭтоТип(ExtException, ErrorType) Тогда
			
			ExtException_Set(ExtException, "Type", ErrorType);
			
		КонецЕсли;
				
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
	Если ExtException.code = 779000 Тогда
		
		Если Найти(WarningData.details, "Не удалось определить работающего сотрудника по идентификатору") Тогда
			
			ExtException_Set(ExtException, "code", 779202);
			
		ИначеЕсли Найти(WarningData.details, "организация") Тогда
			
			ExtException_Set(ExtException, "code", 779204);
	  
		КонецЕсли;
		
	КонецЕсли;  
	
	message = WarningData.message;
	Если message = Неопределено Тогда
		
		message = яExtException_MessageByCode(ExtException);
		
	КонецЕсли;

	details = WarningData.details;
	Если details = Неопределено Тогда
		
		details	= message;
		
	КонецЕсли;
	
	ExtException_Set(ExtException, "message",	message);
	ExtException_Set(ExtException, "stack",		WarningData.stack);
	ExtException_Set(ExtException, "dump",		яExtException_Static_NewDump(WarningData,,,,"Saby.Warning"), "dump");
	
	яExtException_Set_Detail_WithAnalyse(ExtException, details);
		
КонецПроцедуры

//DynamicDirective
Процедура яExtException_Append_Structure(ExtException, StructureData, Context)
	
	Для Каждого КлючИЗначение Из StructureData Цикл
		
		ExtException_Set(ExtException, КлючИЗначение.Ключ, КлючИЗначение.Значение);
		
	КонецЦикла;
	
КонецПроцедуры

