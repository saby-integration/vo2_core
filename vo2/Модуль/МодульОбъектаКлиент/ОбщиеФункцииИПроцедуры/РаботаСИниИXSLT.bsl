
// Функция - возвращает XSLT по параметрам и кладет в Кэш, если ее еще там нет
//
// Параметры:
//  ПараметрыИниВходящие - Параметры ини к чтению.
//		- Неопределено	- прочитать все XSLT	
//		- Строка		- получение XSLT напрямую по имени
//		- Структура		- может содержать ключи: 
//				Имя			- Строка, Массив	- для запроса нескольких XSLT. Если есть, то учитывается только ТипИни
//				Вложение	- ВложениеСБИС		- определение XSLT для вложения. Может быть вместе с Направление. Если Направление не указано, то ставится как Входящий
//  ДопПараметры		 - дополнительно, расширение 
//		- Неопределено	- не требуется
//
// Возвращаемое значение:
//  Струкутра 	- может быть несколько XSLT (поиск по типу 1С/СБИС)
//	Строка		- XSLT получаем по имени
//
&НаКлиенте
Функция XSLTПоПараметрам(ПараметрыВходящие = Неопределено, ДопПараметры = Неопределено) Экспорт 
	
	Перем РезультатЧтения;
	
	Кэш = ГлавноеОкно.Кэш;
	МодульНастройки = Кэш.ТекущийСеанс.Модули.Настройки;
	
	// Если пришли сюда впервые
	Если Не	Кэш.Свойство("xslt") Тогда
		Кэш.Вставить("xslt", Новый Структура);
	КонецЕсли;
	
	Если ПараметрыВходящие = Неопределено Тогда
		// Получить всё (структура)
		
		Если	Не	Кэш.Свойство("xslt", РезультатЧтения)
			Или	Не ЗначениеЗаполнено(РезультатЧтения) Тогда
			
			ОшибкаЧтения = Ложь;
			ИдентификаторНастроек = ПолучитьЗначениеПараметраСбис("ИдентификаторНастроек");
			МодульНастройки.СбисСформироватьСтруктуруXSLT(Кэш, ИдентификаторНастроек,, ОшибкаЧтения);
			
			Если ОшибкаЧтения Тогда
				ВызватьСбисИсключение(, "МодульОбъектаКлиент.XSLTПоПараметрам", 770, "Ошибка чтения XSLT", "Ошибка чтения XSLT");
			КонецЕсли;
			
		КонецЕсли;
		
		РезультатЧтения = Кэш.xslt;
		
	ИначеЕсли ТипЗнч(ПараметрыВходящие) = Тип("Строка") Тогда
		// Получить 1 (строка)

		Если Не Кэш.Xslt.Свойство(ПараметрыВходящие, РезультатЧтения) Тогда
			
			ОшибкаЧтения = Ложь;
			ИдентификаторНастроек = ПолучитьЗначениеПараметраСбис("ИдентификаторНастроек");
			РезультатЧтения = МодульНастройки.СбисПолучитьXSLTПоНазванию(Кэш, ИдентификаторНастроек, ПараметрыВходящие, ОшибкаЧтения);
			
			Если ОшибкаЧтения Тогда
				Если ТипЗнч(РезультатЧтения) = Тип("Строка") Тогда
					РезультатЧтения = Кэш.РаботаСJSON.сбисПрочитатьJSON(РезультатЧтения).error;
				КонецЕсли;
				
				Если РезультатЧтения.code = 100 ИЛИ РезультатЧтения.code = 770 Тогда
					// xslt по имени не найдено / некорректное имя xslt
					РезультатЧтения = Неопределено;
				Иначе
					ВызватьСбисИсключение(РезультатЧтения, "МодульОбъектаКлиент.XSLTПоПараметрам", 770, "Ошибка чтения XSLT", "Ошибка чтения XSLT");
				КонецЕсли;
			Иначе
				// Кэшировать в т.ч. пустой результат
				Кэш.Xslt.Вставить(ПараметрыВходящие, РезультатЧтения);
			КонецЕсли;
			
		КонецЕсли;
		
	ИначеЕсли ТипЗнч(ПараметрыВходящие) = Тип("Массив") Тогда
		// Получить список (структура)
		
		РезультатЧтения = Новый Структура;
		Для Каждого ИмяXSLT Из ПараметрыВходящие Цикл
			
			XSLTЗначение = XSLTПоПараметрам(ИмяXSLT);
			Если НЕ ЗначениеЗаполнено(XSLTЗначение) Тогда
				
				Продолжить;
				
			КонецЕсли;
			
			РезультатЧтения.Вставить(ИмяXSLT, XSLTЗначение);
			
		КонецЦикла;
		
	Иначе	
		
		РезультатЧтения = Новый Структура;
		
	КонецЕсли;
	
	Возврат РезультатЧтения;
	
КонецФункции
	
// Функция - возвращает настройки по параметрам
//
// Параметры:
//  ПараметрыИниВходящие - Параметры ини к чтению.
//		- Неопределено	- прочитать все настройки	
//		- Строка		- получение настройки напрямую по имени
//		- Структура		- может содержать ключи: 
//				Имя			- Строка, Массив	- для запроса нескольких настроек. Если есть, то учитывается только ТипИни
//				ТипИни		- Строка			- тип настройки для запроса из поддерживаемых обработкой (Выгрузка/Загрузка/ПроверкаРасхождения).
//				Тип1С		- Строка			- тип 1С для поиска подходящих настроек под объект 1С
//				ТипСБИС		- Строка			- тип формата документа для поиска подходящей настройки
//				Направление	- Строка			- Входящий/Исходящий - в какую сторону требуется настройка. Например, могут быть ини Загрузка_Исходящий 
//				Вложение	- ВложениеСБИС		- определение настройки для ТипИни "Загрузка" вложения. Может быть вместе с Направление. Если Направление не указано, то ставится как Входящий
//				ОбъектСсылка- Ссылка			- определение настройки для обработки конкретного объекта 1С (Документ)
//  ДопПараметры		 - дополнительно, расширение 
//		- Неопределено	- не требуется
//		- Структура		- ПринудительноеЧтение	- Булево признак для попытки чтения настройки, не смотря на отсутствие её в меню разделов.
//
// Возвращаемое значение:
//  Струкутра 	- если запрашивается/может быть несколько ини (поиск по типу 1С/СБИС)
//	Ини 		- если запрашивается конкретная ини по имени
//
&НаКлиенте
Функция ИниПоПараметрам(ПараметрыИниВходящие=Неопределено, ДопПараметры=Неопределено) Экспорт 
	Перем ТипИниПрочитать, ЗначениеИниДокумента;
	
	ОшибкаЧтенияНастройки = Ложь;
	Если ПараметрыИниВходящие = Неопределено Тогда
		//Получить всё
		РезультатЧтения = ГлобальныйКэш.ТекущийСеанс.Модули.Настройки.СбисЗаполнитьНеполученныеНастройки(ГлавноеОкно.Кэш, ОшибкаЧтенияНастройки);
	ИначеЕсли ТипЗнч(ПараметрыИниВходящие) = Тип("Строка") Тогда
		//Читается 1 инишка напрямую по имени, ПараметрыИниВходящие это имя настройки к чтению
		РезультатЧтения = ГлобальныйКэш.ТекущийСеанс.Модули.Настройки.Ини(ГлавноеОкно.Кэш, ПараметрыИниВходящие, Новый Структура, ОшибкаЧтенияНастройки);
		Если	ОшибкаЧтенияНастройки
			И	РезультатЧтения.code = 779 Тогда
			//Ини отсутствует в установленных
			РезультатЧтения			= Неопределено;
			ОшибкаЧтенияНастройки	= Ложь;
		КонецЕсли;
	ИначеЕсли ПараметрыИниВходящие.Свойство("Имя") Тогда
		//Читается 1 инишка напрямую по имени, ПараметрыИниВходящие содержит имя настройки к чтению и может дополнительно - Тип Загрузка, Выгрузка, Система
		//и признак принудиительного чтения - читать, несмотря на отсутствие в меню.
		ДопПараметрыЧтенияИни = Новый Структура;
		Если ТипЗнч(ДопПараметры) = Тип("Структура") Тогда
			Если ДопПараметры.Свойство("ПринудительноеЧтение") Тогда
				ДопПараметрыЧтенияИни.Вставить("ПринудительноеЧтение", Истина);
			КонецЕсли;
		КонецЕсли;
		Если ПараметрыИниВходящие.Свойство("ТипИни", ТипИниПрочитать) Тогда
			Если		ТипИниПрочитать = "ПроверкаРасхождения"
				И	Не	ДопПараметрыЧтенияИни.Свойство("ПринудительноеЧтение")Тогда
				ДопПараметрыЧтенияИни.Вставить("ПринудительноеЧтение", Истина);
			КонецЕсли;
			ДопПараметрыЧтенияИни.Вставить("Тип", ТипИниПрочитать);
		КонецЕсли;
		Если ТипЗнч(ПараметрыИниВходящие.Имя) = Тип("Строка") Тогда
			РезультатЧтения = ГлобальныйКэш.ТекущийСеанс.Модули.Настройки.Ини(ГлавноеОкно.Кэш, ПараметрыИниВходящие.Имя, ДопПараметрыЧтенияИни, ОшибкаЧтенияНастройки);
		Иначе
			РезультатНабора = Новый Структура;
			Для Каждого ИмяИни Из ПараметрыИниВходящие.Имя Цикл
				РезультатЧтения = ГлобальныйКэш.ТекущийСеанс.Модули.Настройки.Ини(ГлавноеОкно.Кэш, ИмяИни, ДопПараметрыЧтенияИни, ОшибкаЧтенияНастройки);
				Если ОшибкаЧтенияНастройки Тогда
					Прервать;
				КонецЕсли;
				РезультатНабора.Вставить(ИмяИни, РезультатЧтения);
			КонецЦикла;
			Если Не ОшибкаЧтенияНастройки Тогда
				РезультатЧтения = РезультатНабора;
			КонецЕсли;
		КонецЕсли;
	ИначеЕсли ПараметрыИниВходящие.Свойство("Тип1С") Тогда
		РезультатЧтения = Новый Структура;
		//Читаются настройки, которые подходят под тип 1С
		СбисСтруктураРазделов	= ГлобальныйКэш.ТекущийСеанс.Модули.Настройки.ПолучитьСтруктуруРазделов(ГлавноеОкно.Кэш,,ОшибкаЧтенияНастройки);
		Если ОшибкаЧтенияНастройки Тогда
			ВызватьСбисИсключение(СбисСтруктураРазделов, "МодульОбъектаКлиент.ИниПоПараметрам");
		КонецЕсли;
			
		СписокИниПолучить = Новый Массив;
		Для Каждого СбисРаздел Из сбисСтруктураРазделов Цикл
			Если ПараметрыИниВходящие.Свойство("ТипИни") Тогда
			Если	(	СбисРаздел.Ключ = "БезРаздела"
				И		ПараметрыИниВходящие.ТипИни = "Выгрузка")
				Или	(Не	СбисРаздел.Ключ = "БезРаздела"
					И	ПараметрыИниВходящие.ТипИни = "Загрузка") Тогда
				//Ини на выгрузку могут быть только с разделом. Ини на загрузку без раздела.
				Продолжить;
			КонецЕсли;
			КонецЕсли;
			Для Каждого СбисПодРаздел Из СбисРаздел.Значение.Список Цикл
				Если Не	ЗначениеЗаполнено(СбисПодРаздел.Значение.Реестр1С_Тип) Тогда
					Продолжить;
				КонецЕсли;
				РеестрПодходит = Ложь;
				Реестр1С_Тип = СтрЗаменить(сбисПодРаздел.Значение.Реестр1С_Тип, ",", Символы.ПС);
				Для НомерСтроки = 1 По СтрЧислоСтрок(Реестр1С_Тип) Цикл
					Если Не СтрПолучитьСтроку(Реестр1С_Тип, НомерСтроки) = ПараметрыИниВходящие.Тип1С Тогда
						Продолжить;
					КонецЕсли;
					РеестрПодходит = Истина;
					Прервать;
				КонецЦикла;
				Если Не РеестрПодходит Тогда
					Продолжить;
				КонецЕсли;
				СписокИниПолучить.Добавить(сбисПодРаздел.Ключ);
			КонецЦикла;
			
		КонецЦикла;
		
		Попытка
			РезультатЧтения = ИниПоПараметрам(Новый Структура("Имя", СписокИниПолучить));
		Исключение
			ВызватьСбисИсключение(ИнформацияОбОшибке(), "МодульОбъектаКлиент.ПолучитьИниПоПараметрам");
		КонецПопытки;
		
	ИначеЕсли ПараметрыИниВходящие.Свойство("ТипСБИС") Тогда
		//Читаются настройки, которые подходят под тип 1С
		РезультатЧтения			= Новый Структура;
		СбисСтруктураРазделов	= ГлобальныйКэш.ТекущийСеанс.Модули.Настройки.ПолучитьСтруктуруРазделов(ГлавноеОкно.Кэш,,ОшибкаЧтенияНастройки);
		
		Если ОшибкаЧтенияНастройки Тогда
			ВызватьСбисИсключение(СбисСтруктураРазделов, "МодульОбъектаКлиент.ИниПоПараметрам");
		КонецЕсли;
		
		Для Каждого СбисРаздел Из сбисСтруктураРазделов Цикл
			
			Если Не ПараметрыИниВходящие.Свойство("ТипИни") Тогда
				
				//Нет фильтра по типу
			
			ИначеЕсли	ПараметрыИниВходящие.ТипИни = "Загрузка"
				     И	СбисРаздел.Ключ = "БезРаздела" Тогда
					 
				//Загрузочные ини все идут без раздела	 
					 
			ИначеЕсли		ПараметрыИниВходящие.ТипИни = "Выгрузка"
				     И	Не	СбисРаздел.Ключ = "БезРаздела" Тогда
					 
				//Ини на Выгрузку проверять везде
				
			Иначе
				
				Продолжить;
				
			КонецЕсли;
			
			Для Каждого СбисПодРаздел Из СбисРаздел.Значение.Список Цикл
				Если Не	ЗначениеЗаполнено(СбисПодРаздел.Значение.РеестрСБИС_Тип) Тогда
					Продолжить;
				КонецЕсли;
				РеестрПодходит	= Ложь;
				РеестрСБИС_Тип	= СтрЗаменить(сбисПодРаздел.Значение.РеестрСБИС_Тип, ",", Символы.ПС);
				Для НомерСтроки = 1 По СтрЧислоСтрок(РеестрСБИС_Тип) Цикл
					Если Не СтрПолучитьСтроку(РеестрСБИС_Тип, НомерСтроки) = ПараметрыИниВходящие.ТипСБИС Тогда
						Продолжить;
					КонецЕсли;
					РеестрПодходит = Истина;
					Прервать;
				КонецЦикла;
				Если Не РеестрПодходит Тогда
					Продолжить;
				КонецЕсли;
				
				Попытка
					
					ЗначениеИниДокумента = ИниПоПараметрам(сбисПодРаздел.Ключ);
					
				Исключение
					
					ВызватьСбисИсключение(ИнформацияОбОшибке(), "МодульОбъектаКлиент.ПолучитьИниПоПараметрам");
					
				КонецПопытки;
				
				Если ЗначениеИниДокумента = Неопределено Тогда
					
					Продолжить;
					
				КонецЕсли;
				
				РезультатЧтения.Вставить(сбисПодРаздел.Ключ, ЗначениеИниДокумента);
				
			КонецЦикла;
		КонецЦикла;
	ИначеЕсли	ПараметрыИниВходящие.Свойство("Вложение") Тогда
		//Подбор настройки для вложения
		ПараметрыВложения = ВложениеСБИС_Получить(ПараметрыИниВходящие.Вложение, "ПараметрыИни");
		
		ИмяИни = ПараметрыВложения.Тип + "_" + ПараметрыВложения.Версия;
		ИмяИни = СтрЗаменить(ИмяИни, ".", "_");
		Если ПараметрыВложения.Направление = "Входящий" Тогда
			ЗначениеИниДокумента = ИниПоПараметрам(ИмяИни);
		КонецЕсли;
		Если ЗначениеИниДокумента = Неопределено Тогда
			ИмяИни = "Загрузка_" + ПараметрыВложения.Направление + "_" + ИмяИни;
			ЗначениеИниДокумента = ИниПоПараметрам(ИмяИни);
		КонецЕсли;
		РезультатЧтения = ЗначениеИниДокумента;

	ИначеЕсли	ПараметрыИниВходящие.Свойство("ОбъектСсылка") Тогда 
		//Подбор настройки под объект
		
		ИмяДок = ГлобальныйКэш.ТекущийСеанс.Модули.ФункцииДокументов.ПолучитьРеквизитМетаданныхОбъекта(ПараметрыИниВходящие.ОбъектСсылка, "Имя");
		ПараметрыИниВходящие.Вставить("Тип1С", ИмяДок);
		Возврат ИниПоПараметрам(ПараметрыИниВходящие, ДопПараметры);
		
	КонецЕсли;
	Если ОшибкаЧтенияНастройки Тогда
		ВызватьСбисИсключение(РезультатЧтения, "МодульОбъектаКлиент.ПолучитьИниПоПараметрам");
	КонецЕсли;
	Возврат РезультатЧтения;
	
КонецФункции

// Функция возвращает название реквизита для значений из файлов настроек.
//	Пример: <Документ_Номер Данные="Файл.Документ.Номер">[Документ].Номер</Документ_Номер> вернёт [Документ].Номер, или Номер
//
// Параметры:
//  ЗначениеРеквизита	 - Структура	 - узел ини
//  ДопПараметры		 - Структура	 - расширение
//		ИмяРеквизита - Булево, если нужно только имя реквизита, без родителя
// 
// Возвращаемое значение:
//  Строка - значение узла ини
//
&НаКлиенте
Функция СтроковоеЗначениеУзлаИни(ЗначениеРеквизита, ДопПараметры) Экспорт
	Перем ЗначениеРеквизитаДляОпределния;

	Если		ТипЗнч(ЗначениеРеквизита) = Тип("Строка") Тогда
		ЗначениеРеквизитаДляОпределния = ЗначениеРеквизита;
	ИначеЕсли	Не ЗначениеРеквизита.Свойство("Значение", ЗначениеРеквизитаДляОпределния) Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	ЗначениеРеквизитаДляОпределния = СтрЗаменить(ЗначениеРеквизитаДляОпределния, "'", "");
	
	Если	ДопПараметры.Свойство("ИмяРеквизита")
		И   ДопПараметры.ИмяРеквизита Тогда
		ЗначениеРеквизитаДляОпределния = Сред(	ЗначениеРеквизитаДляОпределния,
												Найти(ЗначениеРеквизитаДляОпределния,".") + 1, 
												СтрДлина(ЗначениеРеквизитаДляОпределния) - Найти(ЗначениеРеквизитаДляОпределния,"."));
	КонецЕсли;
	
	Возврат ЗначениеРеквизитаДляОпределния;
	
КонецФункции

