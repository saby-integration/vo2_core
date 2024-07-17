
&НаКлиенте
Функция СбисИсключение_Представление(СбисИсключение, КлючПредставления="Исключение") Экспорт
	
	КлючПроверить = НРег(КлючПредставления);
	Если КлючПроверить = "сообщение" Тогда
		
		Результат = СбисИсключение.message;
		
		Если Результат = Неопределено Тогда
			
			Результат = "";
			
		КонецЕсли;
		
		Если	СбисИсключение.Свойство("details")
			И	СбисИсключение.message <> СбисИсключение.details Тогда 
			Результат = Результат + " (" + СбисИсключение.details + ")";
		КонецЕсли;
		
	ИначеЕсли КлючПроверить = "полныйтекст" Тогда
		
		Результат = СбисИсключение.message;
		
		Если Результат = Неопределено Тогда
			
			Результат = "";
			
		КонецЕсли;
		
		Если	Не СбисИсключение.message = СбисИсключение.details Тогда 
			Результат = Результат + Символы.ПС + "Детально: " + СбисИсключение.details;
		КонецЕсли;
	
		Если	ЗначениеЗаполнено(СбисИсключение.dump)
			И	СбисИсключение.dump.Свойство("ДетализацияОшибки")
			И	СбисИсключение.dump.Свойство("ИсходнаяСтрока")
			И	СбисИсключение.dump.Свойство("НомерСтроки") Тогда
			
			СтрокаДетально = "В модуле {ИмяМодуля}, в строке ""{ИсходнаяСтрока}"" ({НомерСтроки}) произошла ошибка ""{ДетализацияОшибки}""!";
			СтрокаДетально = ПрименитьФорматКСтроке(СтрокаДетально, СбисИсключение.dump);
			Результат = Результат + Символы.ПС + "Подбробная информация: " + СтрокаДетально;
			
		КонецЕсли;
		
	Иначе 
		
		Результат = СбисИсключение_ВСтроку(СбисИсключение);
		
	КонецЕсли;
	
	Возврат Результат;
	
КонецФункции

&НаСервере
Функция СбисИсключение_ВСтрокуВызовСервера(Знач СбисИсключение, ДопПарамеры = Неопределено) 
	
	Возврат МодульОбъектаСервер().СбисИсключение_ВСтрокуСервер(СбисИсключение, ДопПарамеры);
	
КонецФункции

&НаСервере
Функция СбисИсключение_ИзСтрокиВызовСервера(Знач СбисИсключение, ДопПарамеры = Неопределено) 
	
	Возврат МодульОбъектаСервер().СбисИсключение_ИзСтрокиСервер(СбисИсключение, ДопПарамеры);
	
КонецФункции

#Область include_core2_vo2_МодульОбъекта_Классы_СбисИсключение_Общее //&НаКлиенте
#КонецОбласти

