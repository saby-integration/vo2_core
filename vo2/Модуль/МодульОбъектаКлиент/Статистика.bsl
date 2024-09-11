
// Процедура собирает статистику и отправляет на сервис.
//
// Параметры:
//  ПараметрыСтатистики	 - Структура	 - Действие
//  ДопПараметры		 - Структура	 - 
//
&НаКлиенте
Процедура СбисСтатистика_СформироватьИЗаписать(ПараметрыСтатистики, ДопПараметры = Неопределено) Экспорт
	                                                                                                                
	// При отключенном обмене или без авторизации записать ничего не сможем.
	Если Не (ПолучитьЗначениеПараметраСбис("ОбменВключен") И ПолучитьЗначениеПараметраСбис("Авторизован")) Тогда
		Возврат;
	КонецЕсли; 
	
	Попытка 
		
		ДанныеСтатистики = СбисСтатистика_СформироватьДанныеСообщений(ПараметрыСтатистики, ДопПараметры);
		Отказ = Ложь; 
		
		Для Каждого СообщениеСтатистики Из ДанныеСтатистики.Сообщения Цикл 
			
			РезультатОтправки = ГлобальныйКэш.ТекущийСеанс.Модули.Интеграция.СбисОтправитьСообщениеСтатистики(ГлавноеОкно.Кэш, СообщениеСтатистики, Отказ); 
			
			Если Отказ Тогда
				ВызватьСбисИсключение(РезультатОтправки, ПолучитьЗначениеПараметраСбис("ИнтеграцияИмя") + ".СбисОтправитьСообщениеСтатистики");;
			КонецЕсли;  
			
		КонецЦикла;
		
		Для Каждого СообщениеОбОшибке Из ДанныеСтатистики.Ошибки Цикл
			
			РезультатОтправки = ГлобальныйКэш.ТекущийСеанс.Модули.Интеграция.СбисОтправитьСообщениеОшибки(ГлавноеОкно.Кэш, СообщениеОбОшибке, Отказ);
			
			Если Отказ Тогда
				ВызватьСбисИсключение(РезультатОтправки, ПолучитьЗначениеПараметраСбис("ИнтеграцияИмя") + ".СбисОтправитьСообщениеОшибки");;
			КонецЕсли;
			
		КонецЦикла;
		
		Для Каждого СообщениеСтатистики Из ДанныеСтатистики.Прикладная Цикл 
			
			ДопПараметрыОтправки = Новый Структура("Кэш", ГлавноеОкно.Кэш);
			РезультатОтправки = ГлобальныйКэш.ТекущийСеанс.Модули.Интеграция.ExtSysMarking_SendStatisticData(СообщениеСтатистики, ДопПараметрыОтправки, Отказ);
			
			Если Отказ Тогда
				ВызватьСбисИсключение(РезультатОтправки, ПолучитьЗначениеПараметраСбис("ИнтеграцияИмя") + ".ExtSysMarking_SendStatisticData");;
			КонецЕсли;    
			
		КонецЦикла;    
		
	Исключение   
		
		ИнфоОбОшибке = ИнформацияОбОшибке();
		ВызватьСбисИсключение(ИнфоОбОшибке, "МодульОбъектКлиент.СбисСтатистика_СформироватьИЗаписать");
		
	КонецПопытки;           
	
КонецПроцедуры

//Функция, в зависимости от выбранного действия, формирует параметры к отправке на сервис статистики
&НаКлиенте
Функция	СбисСтатистика_СформироватьДанныеСообщений(ПараметрыСтатистики, ДопПараметры = Неопределено) 
	Отказ = Ложь;
	Действие = ПараметрыСтатистики.Действие;
	Если Не ПараметрыСтатистики.Свойство("ИмяРеестра") Тогда
		ПараметрыСтатистики.Вставить("ИмяРеестра", ГлавноеОкно.Кэш.Текущий.ТипДок);
	КонецЕсли;
	Результат = Новый Структура("Сообщения, Ошибки, Прикладная", Новый Массив, Новый Массив, Новый Массив);	
	Если Действие = "Отправка" Тогда
		РезультатОтправки = ПараметрыСтатистики.РезультатОтправки;
		//обрабатываем результат в Кэш
		Если РезультатОтправки.Отправлено Тогда
			ПараметрыСообщения = Новый Структура("count, action_param, action_name", РезультатОтправки.Отправлено, ПараметрыСтатистики.ИмяРеестра, Действие);
			НовоеСообщение = СбисСтатистика_СформироватьСтруктуруОперации(ПараметрыСообщения);
			Результат.Сообщения.Добавить(НовоеСообщение);
		КонецЕсли;
		Если РезультатОтправки.Ошибок Тогда
			ПараметрыСообщения = Новый Структура("count, code, action_param, action_name, error_name, error_detail", 0, 100, ПараметрыСтатистики.ИмяРеестра, Действие);
			Для Каждого ОшибкаОтправки Из РезультатОтправки.ДетализацияОшибок Цикл
				ТекстОшибки = ОшибкаОтправки.Ключ;
				ПараметрыСообщения.count		= 1;
				ПараметрыСообщения.error_name	= ТекстОшибки;
				ПараметрыСообщения.code			= 100;
				//Если нет соответствия кодов, то ставится код по-умолчанию 100.
				Если РезультатОтправки.Свойство("СоответствиеКодовИТекстовОшибок") Тогда
					КодОшибки = РезультатОтправки.СоответствиеКодовИТекстовОшибок.Получить(ТекстОшибки);
					Если Не КодОшибки = Неопределено Тогда
						ПараметрыСообщения.code = Формат(КодОшибки,"ЧГ=0");
					КонецЕсли;
				КонецЕсли;
				//Генерируем для каждой ошибки из детализации сообщение для статистики
				Для Каждого ДетализацияОшибки Из ОшибкаОтправки.Значение Цикл
					СбисСтек = Неопределено;
					//Если у ошибки нет стека, то генерируем
					Если Не ДетализацияОшибки.СтруктураОшибки.Свойство("stack", СбисСтек) Тогда
						СбисСтек	= Новый Массив;
						ЗаписьВСтек	= Новый Структура("message,details,code");
						ЗаполнитьЗначенияСвойств(ЗаписьВСтек, ДетализацияОшибки.СтруктураОшибки);
						ЗаписьВСтек.Вставить("method_name", "WriteDocumentEx");
						Если ДетализацияОшибки.СтруктураОшибки.Свойство("dump") Тогда
							ЗаписьВСтек.Вставить("dump", ДетализацияОшибки.СтруктураОшибки.dump);
						КонецЕсли;
						СбисСтек.Добавить(ЗаписьВСтек);
					КонецЕсли;
					
					ПараметрыОтправки = Новый Структура;
					ПараметрыОтправки.Вставить("ini_name",	ПараметрыСтатистики.ИмяРеестра);
					ПараметрыОтправки.Вставить("value",		Строка(ДетализацияОшибки.ОбработанДокумент1С));
					ПараметрыОтправки.Вставить("type",		"ДокументСсылка." + ПараметрыСтатистики.ИмяРеестра);
					
					ПараметрыСообщения.error_detail	= ДетализацияОшибки.Сообщение;
					НовоеСообщение = СбисСтатистика_СформироватьСтруктуруОшибки(ПараметрыСообщения);
					НовоеСообщение.data.Вставить("stack", СбисСтек);
					НовоеСообщение.data.Вставить("param", ПараметрыОтправки);
					Результат.Ошибки.Добавить(НовоеСообщение);
				КонецЦикла;
			КонецЦикла;
		КонецЕсли;
	ИначеЕсли Действие = "Загрузка" Тогда
		//обрабатываем результат
		Если ПараметрыСтатистики.Результат.Всего.Выполнено Тогда
			ПараметрыСообщения = Новый Структура("count, action_param, action_name", ПараметрыСтатистики.Результат.Всего.Выполнено, ПараметрыСтатистики.ИмяРеестра, Действие);
			НовоеСообщение = СбисСтатистика_СформироватьСтруктуруОперации(ПараметрыСообщения);
			Результат.Сообщения.Добавить(НовоеСообщение);
		КонецЕсли;
		Для Каждого ОшибкаЗагрузки Из ПараметрыСтатистики.Результат.Ошибки.ДетализацияОшибок Цикл
			ПараметрыСообщения = Новый Структура("count, code, action_param, action_name, error_name, error_detail", 1, 100, ПараметрыСтатистики.ИмяРеестра, Действие);
			ТекстОшибки = ОшибкаЗагрузки.Ключ;
			ПараметрыСообщения.error_name	= ТекстОшибки;
			ПараметрыСообщения.code			= 100;
			//Если нет соответствия кодов, то ставится код по-умолчанию 100.
			КодОшибки = ПараметрыСтатистики.Результат.Ошибки.СоответствиеКодов.Получить(ТекстОшибки);
			Если Не КодОшибки = Неопределено Тогда
				ПараметрыСообщения.code = Формат(КодОшибки,"ЧГ=0");
			КонецЕсли;
			//Генерируем для каждой ошибки из детализации сообщение для статистики
			Для Каждого ДетализацияОшибки Из ОшибкаЗагрузки.Значение Цикл
				СбисСтек	= Новый Массив;
				ЗаписьВСтек	= Новый Структура(
				"message,						details,					code,					method_name", 
				ДетализацияОшибки.Состояние,	ДетализацияОшибки.Сообщение,ПараметрыСообщения.code,"ЗагрузитьУпорядоченныйСоставПакетаВыбраннымСпособом");
				
				СбисДампОшибки		= Новый Структура;
				ПараметрыОтправки	= Новый Структура;
				ПараметрыОтправки.Вставить("ini_name",	ПараметрыСтатистики.ИмяРеестра);
				Для Каждого СбисОбработанОбъект Из ДетализацияОшибки.ОбработаныОбъекты1С Цикл
					//Ищем первый объект, на котором свалилась загрузка. Пока что он будет основным в ошибке.
					Если Не СбисОбработанОбъект.Ошибки Тогда
						Продолжить;
					КонецЕсли;
					Если ПараметрыОтправки.Свойство("value") Тогда
						//Допишем остальные объекты в дамп на всякий.
						СбисДампДополнительныеОбъекты = Неопределено;
						Если Не СбисДампОшибки.Свойство("ДополнительныеОбъекты", СбисДампДополнительныеОбъекты) Тогда
							СбисДампДополнительныеОбъекты = Новый Массив;
							СбисДампОшибки.Вставить("ДополнительныеОбъекты", СбисДампДополнительныеОбъекты);
						КонецЕсли;
						СбисДампДополнительныеОбъекты.Добавить(Новый Структура("value, type", Строка(СбисОбработанОбъект.Ссылка), СбисОбработанОбъект.Тип));
						Продолжить;
					КонецЕсли;
					ПараметрыОтправки.Вставить("value",		Строка(СбисОбработанОбъект.Ссылка));
					ПараметрыОтправки.Вставить("type",		СбисОбработанОбъект.Тип);
				КонецЦикла;
				Если ЗначениеЗаполнено(СбисДампОшибки) Тогда
					ЗаписьВСтек.Вставить("dump", СбисДампОшибки);
				КонецЕсли;
				СбисСтек.Добавить(ЗаписьВСтек);					
				
				ПараметрыСообщения.error_detail	= ДетализацияОшибки.Сообщение;
				НовоеСообщение = СбисСтатистика_СформироватьСтруктуруОшибки(ПараметрыСообщения);
				НовоеСообщение.data.Вставить("stack", СбисСтек);
				НовоеСообщение.data.Вставить("param", ПараметрыОтправки);
				Результат.Ошибки.Добавить(НовоеСообщение);
			КонецЦикла;
		КонецЦикла;
	ИначеЕсли Действие = "Ошибка" Тогда
		СбисСтек = Неопределено;
		ПараметрыСообщения	= Новый Структура("count, code, action_param, action_name, error_name, error_detail", 1, 100, "Ошибка", Действие);
		//Если у ошибки нет стека, то генерируем
		Если Не ПараметрыСтатистики.Ошибка.Свойство("stack", СбисСтек) Тогда
			СбисСтек = Новый Массив;
			ЗаписьВСтек	= ГлобальныйКэш.ТекущийСеанс.Модули.ФункцииДокументов.СбисСкопироватьОбъектНаКлиенте(ПараметрыСтатистики.Ошибка);
			СбисСтек.Добавить(ЗаписьВСтек);
		КонецЕсли;
		
		ПараметрыСообщения.code			= Формат(ПараметрыСтатистики.Ошибка.code,"ЧГ=0");
		ПараметрыСообщения.error_name	= ПараметрыСтатистики.Ошибка.message;
		ПараметрыСообщения.error_detail	= ПараметрыСтатистики.Ошибка.details;
		
		НовоеСообщение = СбисСтатистика_СформироватьСтруктуруОшибки(ПараметрыСообщения);
		НовоеСообщение.data.Вставить("stack", СбисСтек);
		Результат.Ошибки.Добавить(НовоеСообщение);
	ИначеЕсли Действие = "Обновление" Тогда
		ПараметрыСтатистикиОтправка	= Новый Структура;
		ПараметрыОтправки	= Новый Структура;
		РезультатДействия			= ПараметрыСтатистики.Результат;
		Отказ = Ложь;
		ДанныеПоНастройкам			= ГлавноеОкно.Кэш.ФормаНастроек.ПолучитьИнформациюПоНастройкам(ГлавноеОкно.Кэш, ПараметрыСтатистикиОтправка, Отказ);
		//Смотрим полученные данные и формируем детальную информацию
		Дамп = Новый Структура("Действия,Xslt,Ини,Функции", Новый Массив, Новый Массив, Новый Массив, ДанныеПоНастройкам.EPF.ЕстьИзменения);
		Для Каждого ФайлНастроек Из ДанныеПоНастройкам.XSLT Цикл
			Если	Не	ФайлНастроек.ЕстьИзменения
				Или		Найти(ФайлНастроек.ИмяФайла, "Утвердить") Тогда
				Продолжить;//Не отправляем статистику по изменениям титулов
			КонецЕсли;
			Дамп.Xslt.Добавить(Новый Структура("file_name", ФайлНастроек.ИмяФайла));
		КонецЦикла;
		Для Каждого ФайлНастроек Из ДанныеПоНастройкам.XML Цикл
			Если Не ФайлНастроек.ЕстьИзменения Тогда
				Продолжить;
			КонецЕсли;
			Дамп.Ини.Добавить(Новый Структура("ini_name", ФайлНастроек.Ини_ИмяИни));
		КонецЦикла;
		ДанныеСообщения = Новый Структура("ИнформацияОНастройках, Ошибки", Дамп, Новый Массив);
		ПараметрыСообщения = Новый Структура("count, code, action_param, action_name, error_name, error_detail", 0, 100, "Ошибка обновления", Действие);
		Для Каждого ОшибкаДействия Из РезультатДействия.Ошибки.ДетализацияОшибок Цикл
			ТекстОшибки = ОшибкаДействия.Ключ;
			ПараметрыСообщения.count		= 1;
			ПараметрыСообщения.error_name	= ТекстОшибки;
			ПараметрыСообщения.code			= "100";
			//Если нет соответствия кодов, то ставится код по-умолчанию 100.
			КодОшибки = РезультатДействия.Ошибки.СоответствиеКодов.Получить(ТекстОшибки);
			Если Не КодОшибки = Неопределено Тогда
				ПараметрыСообщения.code = Формат(КодОшибки,"ЧГ=0");
			КонецЕсли;
			//Генерируем для каждой ошибки из детализации сообщение для статистики
			Для Каждого ДетализацияОшибки Из ОшибкаДействия.Значение Цикл
				СбисСтек = Неопределено;
				ПараметрыСообщения.action_param = ДетализацияОшибки.Название;
				//Если у ошибки нет стека, то генерируем
				Если Не ДетализацияОшибки.Данные.Свойство("stack", СбисСтек) Тогда
					СбисСтек	= Новый Массив;
					ЗаписьВСтек	= Новый Структура("message,details,code");
					ЗаполнитьЗначенияСвойств(ЗаписьВСтек, ДетализацияОшибки.Данные);
					ЗаписьВСтек.Вставить("method_name", "Обновление");
					Если ДетализацияОшибки.Данные.Свойство("dump") Тогда
						ЗаписьВСтек.Вставить("dump", ДетализацияОшибки.Данные.dump);
					КонецЕсли;
					СбисСтек.Добавить(ЗаписьВСтек);
				КонецЕсли;
				
				ПараметрыОтправки = ДетализацияОшибки.Данные.dump;
				
				ПараметрыСообщения.error_detail	= ДетализацияОшибки.Сообщение;
				НовоеСообщение = СбисСтатистика_СформироватьСтруктуруОшибки(ПараметрыСообщения);
				НовоеСообщение.data.Вставить("stack", СбисСтек);
				НовоеСообщение.data.Вставить("param", ПараметрыОтправки);
				Результат.Ошибки.Добавить(НовоеСообщение);
			КонецЦикла;
		КонецЦикла;
		Для Каждого ДействиеПриОбновлении Из РезультатДействия.Действие.ДетализацияВыполнено Цикл
			Дамп.Действия.Добавить(Новый Структура("update_action_name", ДействиеПриОбновлении.Ключ));
		КонецЦикла;
		
		ПараметрыСообщения	= Новый Структура("count, action_param, action_name, data", 1, РезультатДействия.Параметры.ВерсияБыло, Действие, Дамп);
		НовоеСообщение		= СбисСтатистика_СформироватьСтруктуруОперации(ПараметрыСообщения);
		Результат.Сообщения.Добавить(НовоеСообщение);
	ИначеЕсли Действие = "Аутентификация" Тогда
		ДетальноеСообщение = ПараметрыСтатистики.ДетальноеСообщение;
		ПараметрыСообщения	= Новый Структура("count, action_param, action_name", 1, ДетальноеСообщение, Действие);
		НовоеСообщение		= СбисСтатистика_СформироватьСтруктуруОперации(ПараметрыСообщения);
		Результат.Сообщения.Добавить(НовоеСообщение);
	ИначеЕсли Действие = "ПрикладнаяСтатистика" Тогда
		//Прикладная статистика сбора использования функциональности
		ФункционалПрикладнойИмя = "Обработка 1С";
		Если		ТипЗнч(ПараметрыСтатистики.Сообщения) = Тип("Структура") Тогда
			
			ПараметрыСообщения = Новый Структура("Функционал, Количество, Действие, Контекст", ФункционалПрикладнойИмя, 1); 	
			ЗаполнитьЗначенияСвойств(ПараметрыСообщения, ПараметрыСтатистики.Сообщения);
			Результат.Прикладная.Добавить(ПараметрыСообщения);
			
		ИначеЕсли   ТипЗнч(ПараметрыСтатистики.Сообщения) = Тип("Массив") Тогда
			
			Для Каждого ЭлементНаЗапись Из ПараметрыСтатистики.Сообщения Цикл
				ПараметрыСообщения = Новый Структура("Функционал, Количество, Действие, Контекст", ФункционалПрикладнойИмя, 1); 	
				ЗаполнитьЗначенияСвойств(ПараметрыСообщения, ЭлементНаЗапись);
				Результат.Прикладная.Добавить(ПараметрыСообщения);
			КонецЦикла;
			
		Иначе
			
			ПараметрыСообщения			= Новый Структура("Функционал, Количество, Действие, Контекст", ФункционалПрикладнойИмя, 1); 	
			СтрокаРазделить				= СтрЗаменить(ПараметрыСтатистики.Сообщения, ".", Символы.ПС);
			ПараметрыСообщения.Контекст	= СтрПолучитьСтроку(СтрокаРазделить, 1);
			ПараметрыСообщения.Действие	= СтрПолучитьСтроку(СтрокаРазделить, 2);
			Результат.Прикладная.Добавить(ПараметрыСообщения);
			
		КонецЕсли;

	КонецЕсли;
	Возврат Результат;
	
КонецФункции

//Функция генерирует сообщение об успешной операции на сервис статистики
&НаКлиенте
Функция СбисСтатистика_СформироватьСтруктуруОперации(ПараметрыСтатистики)
	СтруктураПараметров = Новый Структура();
	Для Каждого КлючИЗначение Из ПараметрыСтатистики Цикл 
		СтруктураПараметров.Вставить(КлючИЗначение.Ключ, КлючИЗначение.Значение);
	КонецЦикла;
	СтруктураПараметров.Вставить("service",		"ext1C");
	СтрокаМодуль = ГлобальныйКэш.ПараметрыСистемы.Обработка.КраткаяВерсия + "_" + ГлобальныйКэш.СБИС.ПараметрыИнтеграции.ИнтеграцияИмя;
	СтруктураПараметров.Вставить("module", 			СтрокаМодуль);
	СтруктураПараметров.Вставить("subsystem",		ГлобальныйКэш.КэшНастроек.ПараметрыНастроек.ПрефиксУстановленныхНастроек);
	СтруктураПараметров.Вставить("connection_id",	"0");//connection_id не передаём.
	
	Возврат СтруктураПараметров;
	
КонецФункции

//Функция генерирует готовое сообщение об ошибке для сервиса статистики
&НаКлиенте
Функция СбисСтатистика_СформироватьСтруктуруОшибки(ПараметрыСтатистики)
	СтруктураПараметров = СбисСтатистика_СформироватьСтруктуруОперации(ПараметрыСтатистики);
	//Добавим в data поля шапки статистики
	stat_data = ГлобальныйКэш.ТекущийСеанс.Модули.ФункцииДокументов.СбисСкопироватьОбъектНаКлиенте(СтруктураПараметров);
	//Допишем информацию о системе для записи.
	system_info = Новый Структура;
	system_info.Вставить("configuration_info",		ГлобальныйКэш.ПараметрыСистемы.Конфигурация.ПодробнаяИнформация);
	system_info.Вставить("configuration_version",	ГлобальныйКэш.ПараметрыСистемы.Конфигурация.Версия);
	system_info.Вставить("platform_version",		ГлобальныйКэш.ПараметрыСистемы.Клиент.ВерсияПриложения);
	system_info.Вставить("os_client",				ГлобальныйКэш.ПараметрыСистемы.Клиент.ТипОС);
	system_info.Вставить("os_server",				ГлобальныйКэш.ПараметрыСистемы.Сервер.ТипОС);
	system_info.Вставить("first_launch",			ГлобальныйКэш.ПараметрыСистемы.Обработка.ПервыйЗапуск);
	system_info.Вставить("sdk_version",				ГлобальныйКэш.СБИС.ПараметрыИнтеграции.Версия);
	stat_data.Вставить("systemInfo", system_info);
	СтруктураПараметров.Вставить("data", stat_data);
	Возврат СтруктураПараметров;		
	
КонецФункции

