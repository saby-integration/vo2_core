
// Функция - Рассчитать значение параметра ини на сервере
//
// Параметры:
//  ИмяПараметраРассчитать	 - Строка	 - имя узла ини, в котором надо выполнить расчет
//  Контекст				 - Структура - контекст расчёта
//		Ини	- Структура - узел инишки, в котором ищется расчитываемый параметр
// 
// Возвращаемое значение:
//  Произвольное - посчитанное значение
//
Функция РассчитатьЗначениеСервер(ИмяПараметраРассчитать, Контекст) Экспорт
	Перем РасчитываемоеЗначение, РассчитанноеЗначение;
	
	ПараметрыДляРасчета		= СокрЛП(ИмяПараметраРассчитать);
	РассчитываемоеЗначение	= РассчитатьЗначениеСервер_ПолучитьРассчитываемоеЗначение(ПараметрыДляРасчета, Контекст);
	
	Если		РассчитываемоеЗначение = Неопределено
		Или	(	РассчитываемоеЗначение.ИмяПеременнойВПараметре
			И	РассчитываемоеЗначение.УзелИни.Свойство("РассчитанноеЗначение", РассчитанноеЗначение)) Тогда
				
		//Уже расчитанно, либо параметры не определены
		Возврат РассчитанноеЗначение;

	КонецЕсли;

	ИмяПеременнойВПараметре	= РассчитываемоеЗначение.ИмяПеременнойВПараметре;
	ЗнПер					= РассчитываемоеЗначение.ПараметрСчитать;
	ПараметрИни				= РассчитываемоеЗначение.УзелИни;
	ПозТочки				= Найти(ЗнПер, ".");
	ПервыйСимвол			= Лев(ЗнПер, 1);
		
	Если ПервыйСимвол="{" Тогда   // функции из глобальных серверных модулей 1С
		
		Возврат ВычислитьФункциюНаСервере(Контекст, ЗнПер);
		
	ИначеЕсли ПервыйСимвол="[" Тогда  // ссылка на объект (другую переменную)
		
		СтрОбъекта=Сред(ЗнПер,2,Найти(ЗнПер,"]")-2);
		Если СтрОбъекта = "Переменные" Тогда
			Объект1С = Контекст.Переменные;
		Иначе
			Объект1С = РассчитатьЗначениеСервер(СтрОбъекта,Контекст);
		КонецЕсли;
		Если Найти(ЗнПер,".")>0 Тогда
			ИмяРек=сред(ЗнПер,Найти(ЗнПер,".")+1);
		Иначе
			ИмяРек = "";
		КонецЕсли;
		
		Попытка
			Если Найти(строка(Объект1С),"Массив")>0 Тогда //это строка табличной части
				Объект1С = Контекст.ДанныеРезультат.Получить(Контекст.ИмяОбъектаЛокальное)[ИмяРек];
			Иначе
				Если ЗначениеЗаполнено(ИмяРек) Тогда
					Объект1С = Объект1С[ИмяРек];
				КонецЕсли;
				Если Найти(строка(Объект1С),"ТабличнаяЧасть")>0 Тогда //это сама табличная часть
					Если ИмяПеременнойВПараметре и Контекст.Ини[ИмяПараметраРассчитать].Свойство("Отбор") Тогда
						Отбор = Новый Структура;
						Для Каждого Элемент Из Контекст.Ини[ИмяПараметраРассчитать].Отбор Цикл
							Отбор.Вставить(Элемент.Ключ, РассчитатьЗначениеСервер(Элемент.Значение, Контекст));
						КонецЦикла;
						Если Лев(строка(Объект1С),10) = "Справочник" Тогда
							ТипМетаданных = "Справочники";
						Иначе
							ТипМетаданных = "Документы";
						КонецЕсли;
						ИмяОбъектаИТЧ = СбисРазложитьСтрокуВМассивПодстрок(Строка(Объект1С), ".");
						Реквизиты = Метаданные[ТипМетаданных][ИмяОбъектаИТЧ[1]].ТабличныеЧасти[ИмяОбъектаИТЧ[2]].Реквизиты;
						СтрокиТЧ = Объект1С.НайтиСтроки(Отбор);
						Для Каждого СтрокаТЧ Из СтрокиТЧ Цикл 
							СтруктураСтрокиТЧ = Новый Структура();
							Для Каждого Реквизит Из Реквизиты Цикл 
								СтруктураСтрокиТЧ.Вставить(Реквизит.Имя, СтрокаТЧ[Реквизит.Имя]);
							КонецЦикла;
							Возврат СтруктураСтрокиТЧ;
						КонецЦикла;
						Возврат Неопределено;
					КонецЕсли;
				КонецЕсли;	
			КонецЕсли;
			Если ИмяПеременнойВПараметре и Контекст.Ини[ИмяПараметраРассчитать].Свойство("Формат") Тогда // Надо установить отбор
				Объект1С = Формат(Объект1С,	Контекст.Ини[ИмяПараметраРассчитать].Формат);
			КонецЕсли;
			
			Возврат Объект1С;
			
		Исключение
			ошибка = ОписаниеОшибки();
		КонецПопытки;	
	ИначеЕсли ПервыйСимвол="^" Тогда	// формула
		Возврат ВычислитьФормулуЗначенияНаСервере(ЗнПер, ИмяПараметраРассчитать, Контекст);
	ИначеЕсли ПервыйСимвол="'" Тогда	 // строка
		Если ЗнПер="'Истина'" Тогда
			Возврат Истина;
		ИначеЕсли ЗнПер="'Ложь'" Тогда
			Возврат Ложь;
		ИначеЕсли ИмяПеременнойВПараметре и ПараметрИни.Свойство("Тип") и ПараметрИни.Тип = "Число" Тогда
			возврат Число(Сред(ЗнПер,2,СтрДлина(ЗнПер)-2));
		ИначеЕсли ИмяПеременнойВПараметре и ПараметрИни.Свойство("Тип") и ПараметрИни.Тип = "Запрос" Тогда
			Запрос = Новый Запрос;
			Запрос.Текст=Сред(ЗнПер,2,СтрДлина(ЗнПер)-2);
			Если ПараметрИни.Свойство("Отбор") Тогда
				Для Каждого Элемент Из ПараметрИни.Отбор Цикл
					Запрос.УстановитьПараметр(Элемент.Ключ, РассчитатьЗначениеСервер(Элемент.Значение, Контекст));
				КонецЦикла;
			КонецЕсли;
			РезультатЗапроса = Запрос.Выполнить();
			Выборка = РезультатЗапроса.Выбрать();
			Если ПараметрИни.Свойство("Выбрать") и нрег(ПараметрИни.Выбрать) = "все" Тогда
				РезультатМассив = Новый Массив;
				Пока Выборка.Следующий() Цикл
					РезультатСтруктура = Новый Структура;
					Для Каждого Колонка Из РезультатЗапроса.Колонки Цикл
						РезультатСтруктура.Вставить(Колонка.Имя, Выборка[Колонка.Имя]);
					КонецЦикла;
					РезультатМассив.Добавить(РезультатСтруктура);
				КонецЦикла;
				Возврат РезультатМассив;
			Иначе
				Если Выборка.Количество()=0 Тогда
					Возврат Неопределено;
				КонецЕсли;
				РезультатСтруктура = Новый Структура;
				Выборка.Следующий();
				Для Каждого Колонка Из РезультатЗапроса.Колонки Цикл
					РезультатСтруктура.Вставить(Колонка.Имя, Выборка[Колонка.Имя]);
				КонецЦикла;
				Возврат РезультатСтруктура;
			КонецЕсли;
		Иначе
			возврат Сред(ЗнПер,2,СтрДлина(ЗнПер)-2);
		КонецЕсли;
	ИначеЕсли ПозТочки>0 Тогда
		ПервыйСимвол = Лев(ЗнПер, ПозТочки-1);
		
		Если ПервыйСимвол = "Справочник" Тогда	// ссылка на справочник
			ИмяРек=сред(ЗнПер,12);
			Если Контекст.Ини[ИмяПараметраРассчитать].Свойство("Отбор") Тогда
				Возврат РасчитатьОтборНаСервере(Контекст, Контекст.Ини[ИмяПараметраРассчитать], Новый Структура("Тип, Объект", ПервыйСимвол, ИмяРек));				
			Иначе
				возврат Справочники[ИмяРек];
			КонецЕсли;
		ИначеЕсли ПервыйСимвол = "Документ" Тогда // ссылка на документ	
			ИмяРек=сред(ЗнПер,10);
			Возврат Контекст.ДанныеРезультат["Документ"];
		ИначеЕсли ПервыйСимвол = "Константа" Тогда	// константа
			ИмяРек=сред(ЗнПер,11);
			возврат Константы[ИмяРек].Получить();
		ИначеЕсли ПервыйСимвол = "Перечисление" Тогда	// значение перечисления
			ИмяРек=сред(ЗнПер,14);
			возврат Перечисления[ИмяРек];
		ИначеЕсли ПервыйСимвол = "РегистрыСведений" Тогда	// ссылка на регистр сведений
			ИмяРек=сред(ЗнПер,18);
			Если Не Контекст.Ини[ИмяПараметраРассчитать].Свойство("Отбор") Тогда
				Возврат Неопределено;
			КонецЕсли;
			Отбор = Новый Структура;
			Если Контекст.Ини[ИмяПараметраРассчитать].Свойство("СрезПоследних") Тогда
				
				Для Каждого Элемент Из Контекст.Ини[ИмяПараметраРассчитать].Отбор Цикл
					Отбор.Вставить(Элемент.Ключ, РассчитатьЗначениеСервер(Элемент.Значение, Контекст));
				КонецЦикла;
				ДатаСреза = РассчитатьЗначениеСервер(Контекст.Ини[ИмяПараметраРассчитать].СрезПоследних, Контекст);
				НаборЗаписей = РегистрыСведений[ИмяРек].СрезПоследних(ДатаСреза,Отбор);
			Иначе
				НаборЗаписей = РегистрыСведений[ИмяРек].СоздатьНаборЗаписей();
				
				Для Каждого Элемент Из Контекст.Ини[ИмяПараметраРассчитать].Отбор Цикл
					
					НаборЗаписей.Отбор[Элемент.Ключ].Установить(РассчитатьЗначениеСервер(Элемент.Значение, Контекст));
				КонецЦикла;
				НаборЗаписей.Прочитать();
			КонецЕсли;
			Если НаборЗаписей.Количество()=0 Тогда
				Возврат Неопределено;
			КонецЕсли;
			Запись = НаборЗаписей.Получить(0);
			Результат = Новый Структура();
			Ресурсы = Метаданные.РегистрыСведений[ИмяРек].Ресурсы;	
			Для Каждого Ресурс Из Ресурсы Цикл 
				Результат.Вставить(Ресурс.Имя, Запись[Ресурс.Имя]);
			КонецЦикла;
			возврат Результат; 
		ИначеЕсли ПервыйСимвол = "РегистрыНакопления" Тогда
			
			ИмяРек = Сред(ЗнПер,20);
			
			Если Не Контекст.Ини[ИмяПараметраРассчитать].Свойство("Отбор") Тогда
				Возврат Неопределено;
			КонецЕсли;
			
			Отбор = Новый Структура; 
			
			Если Контекст.Ини[ИмяПараметраРассчитать].Свойство("СрезОстатка") Тогда
				
				Для Каждого Элемент Из Контекст.Ини[ИмяПараметраРассчитать].Отбор Цикл
					Отбор.Вставить(Элемент.Ключ, РассчитатьЗначениеСервер(Элемент.Значение, Контекст));
				КонецЦикла;
				
				ДатаСреза		= РассчитатьЗначениеСервер(Контекст.Ини[ИмяПараметраРассчитать].СрезОстатка, Контекст);
				НаборЗаписей	= РегистрыНакопления[ИмяРек].Остатки(ДатаСреза,Отбор);
				
			Иначе
				
				НаборЗаписей	= РегистрыНакопления[ИмяРек].СоздатьНаборЗаписей();
				
				Для Каждого Элемент Из Контекст.Ини[ИмяПараметраРассчитать].Отбор Цикл					
					НаборЗаписей.Отбор[Элемент.Ключ].Установить(РассчитатьЗначениеСервер(Элемент.Значение, Контекст));
				КонецЦикла;
				
				НаборЗаписей.Прочитать(); 
				
			КонецЕсли;
			
			Если НаборЗаписей.Количество()=0 Тогда
				Возврат Неопределено;
			КонецЕсли;
			
			Запись		= НаборЗаписей.Получить(0);
			Результат	= Новый Структура();
			Ресурсы		= Метаданные.РегистрыНакопления[ИмяРек].Ресурсы;
			
			Для Каждого Ресурс Из Ресурсы Цикл 
				Результат.Вставить(Ресурс.Имя, Запись[Ресурс.Имя]);
			КонецЦикла;
			
			Возврат Результат;
			
		ИначеЕсли ПервыйСимвол = "ПланыСчетов" Тогда	// alo ПланыСчетов
			ИмяРек=сред(ЗнПер,13);
			Если Контекст.Ини[ИмяПараметраРассчитать].Свойство("Отбор") Тогда
				Отбор = Новый Структура;
				Для Каждого Элемент Из Контекст.Ини[ИмяПараметраРассчитать].Отбор Цикл
					Отбор.Вставить(Элемент.Ключ, РассчитатьЗначениеСервер(Элемент.Значение, Контекст));
				КонецЦикла;
				Выборка = ПланыСчетов[ИмяРек].Выбрать(,Отбор);
				Если Выборка.Следующий() Тогда
					Возврат Выборка.Ссылка;
				Иначе
					Возврат Неопределено;
				КонецЕсли;
			Иначе
				возврат ПланыСчетов[ИмяРек];
			КонецЕсли;
		КонецЕсли;
	ИначеЕсли Найти(ЗнПер,"'") = 0 и ПозТочки = 0 и ЗначениеЗаполнено(ЗнПер) и Контекст.Переменные.Свойство(ЗнПер) Тогда
		возврат Контекст.Переменные[ЗнПер];
	Иначе
		возврат Неопределено;
	КонецЕсли	
КонецФункции

Функция РассчитатьЗначениеСервер_ПолучитьРассчитываемоеЗначение(ИмяПараметраРассчитать, Контекст)
	
	Результат		= Новый Структура("ПараметрСчитать, ИмяПеременнойВПараметре, УзелИни", ИмяПараметраРассчитать, Ложь);
	ПервыйСимвол	= Лев(ИмяПараметраРассчитать, 1);
	Если Не (	ПервыйСимвол = "["
			Или	ПервыйСимвол = "'" 
			Или ПервыйСимвол = "{"
			Или ПервыйСимвол = "^")	Тогда  
			
		// в случае, если в качестве параметра функции используется, не имя, а значение параметра
		Результат.ИмяПеременнойВПараметре = Истина;
	
		Попытка
		
			Если Не	Контекст.Ини.Свойство(ИмяПараметраРассчитать, Результат.УзелИни) Тогда
				
				Возврат Неопределено;
								
			КонецЕсли;
				
			ЕстьЧтоСчитать = ( 	Результат.УзелИни.Свойство("ВычислитьНаСервере",	Результат.ПараметрСчитать)
							И	ЗначениеЗаполнено(Результат.ПараметрСчитать))
						Или	(	Результат.УзелИни.Свойство("Значение",				Результат.ПараметрСчитать)
							И	ЗначениеЗаполнено(Результат.ПараметрСчитать));
							
			Если Не ЕстьЧтоСчитать Тогда
			
				Возврат Неопределено;
			
			КонецЕсли;
				
		Исключение
			
			Возврат Неопределено;
			
		КонецПопытки;
		
	КонецЕсли;
	
	Возврат Результат;

КонецФункции

//Универсальная функция для расчета отбора запросом
Функция РасчитатьОтборНаСервере(Контекст, ПараметрИни, ОписаниеОбъектаОтбора)
	Отбор = Новый Структура;
	Запрос = Новый Запрос("ВЫБРАТЬ
	                      |	ОбъектОтбора.Ссылка КАК Ссылка
	                      |ИЗ
	                      |	{0}.{1} КАК ОбъектОтбора
	                      |ГДЕ
						  |	");
	Запрос.Текст = СтрЗаменить(СтрЗаменить(Запрос.Текст,"{0}",ОписаниеОбъектаОтбора.Тип),"{1}",ОписаниеОбъектаОтбора.Объект);					  
	Для Каждого Элемент Из ПараметрИни.Отбор Цикл
		РасчитатьОтборНаСервере_ДобавитьОтбор(Контекст, Запрос, Элемент)
	КонецЦикла;
	Запрос.Текст = Лев(Запрос.Текст, СтрДлина(Запрос.Текст)-4);
	Попытка
		РезультатЗапроса = Запрос.Выполнить().Выбрать();
		Если Не РезультатЗапроса.Следующий() Тогда
			Возврат Неопределено;
		КонецЕсли;
	Исключение
		Возврат Неопределено;
	КонецПопытки;
	Возврат РезультатЗапроса.Ссылка;
КонецФункции

//Заполняет отбор в запросе
Процедура РасчитатьОтборНаСервере_ДобавитьОтбор(Контекст, Запрос, Элемент)
	Запрос.Параметры.Вставить(Элемент.Ключ, РассчитатьЗначениеСервер(Элемент.Значение, Контекст));
	Запрос.Текст = Запрос.Текст + СтрЗаменить(	"ОбъектОтбора.{0} = &{0}
												|	И	", "{0}", Элемент.Ключ);
КонецПроцедуры

Функция ВычислитьФормулуЗначенияНаСервере(ЗнПер, ПараметрИни, Контекст)
	
	Попытка
		ВычисляемаяСтрока = СокрЛП(Сред(ЗнПер, 2));
		ПозСкобки = Найти(ВычисляемаяСтрока, "(");
		ИмяФормулы = нрег(СокрЛП(Лев(ВычисляемаяСтрока, ПозСкобки-1)));
		СтрокаПараметров = Сред(ВычисляемаяСтрока,ПозСкобки+1, СтрДлина(ВычисляемаяСтрока)-ПозСкобки-1);
		МассивПараметров = СбисРазложитьСтрокуВМассивПодстрок(СтрокаПараметров, ",");
		ТекущееПолеИни = Новый Структура;
		Если ТипЗнч(ПараметрИни)=Тип("Структура") Тогда
			ТекущееПолеИни = ПараметрИни;
		ИначеЕсли Контекст.Свойство("ТекущееПолеИни") Тогда
			ТекущееПолеИни = Контекст.ТекущееПолеИни;
		КонецЕсли;
		Если ИмяФормулы = ">" Тогда
			Если МассивПараметров.Количество()<>4 Тогда   // неправильно написана формула
				Возврат Неопределено;
			КонецЕсли;
			сч = 0;
			Для Каждого Элемент Из МассивПараметров Цикл
				МассивПараметров[сч] = РассчитатьЗначениеСервер(Элемент, Контекст);
				сч = сч+1;
			КонецЦикла;
			Если МассивПараметров[0]>МассивПараметров[1] Тогда
				Возврат МассивПараметров[2];
			Иначе
				Возврат МассивПараметров[3];
			КонецЕсли;
		ИначеЕсли ИмяФормулы = "<" Тогда
			Если МассивПараметров.Количество()<>4 Тогда   // неправильно написана формула
				Возврат Неопределено;
			КонецЕсли;
			сч = 0;
			Для Каждого Элемент Из МассивПараметров Цикл
				МассивПараметров[сч] = РассчитатьЗначениеСервер(Элемент, Контекст);
				сч = сч+1;
			КонецЦикла;
			Если МассивПараметров[0]<МассивПараметров[1] Тогда
				Возврат МассивПараметров[2];
			Иначе
				Возврат МассивПараметров[3];
			КонецЕсли;
		ИначеЕсли ИмяФормулы = "=" Тогда
			КолПараметров = МассивПараметров.Количество();
			Если НЕ (КолПараметров=3 или КолПараметров=4) Тогда   // неправильно написана формула
				Возврат Неопределено;
			КонецЕсли;
			сч = 0;
			Для Каждого Элемент Из МассивПараметров Цикл
				МассивПараметров[сч] = РассчитатьЗначениеСервер(Элемент, Контекст);
				сч = сч+1;
			КонецЦикла;
			Если КолПараметров = 3 Тогда
				Если ЗначениеЗаполнено(МассивПараметров[0]) Тогда
					Возврат МассивПараметров[1];
				Иначе
					Возврат МассивПараметров[2];
				КонецЕсли;
			Иначе
				Если МассивПараметров[0]=МассивПараметров[1] Тогда
					Возврат МассивПараметров[2];
				Иначе
					Возврат МассивПараметров[3];
				КонецЕсли;
			КонецЕсли;
		ИначеЕсли ИмяФормулы = "!=" Тогда
			КолПараметров = МассивПараметров.Количество();
			Если НЕ (КолПараметров=3 или КолПараметров=4) Тогда   // неправильно написана формула
				Возврат Неопределено;
			КонецЕсли;
			сч = 0;
			Для Каждого Элемент Из МассивПараметров Цикл
				МассивПараметров[сч] = РассчитатьЗначениеСервер(Элемент, Контекст);
				сч = сч+1;
			КонецЦикла;
			Если КолПараметров = 3 Тогда
				Если НЕ ЗначениеЗаполнено(МассивПараметров[0]) Тогда
					Возврат МассивПараметров[1];
				Иначе
					Возврат МассивПараметров[2];
				КонецЕсли;
			Иначе
				Если МассивПараметров[0]<>МассивПараметров[1] Тогда
					Возврат МассивПараметров[2];
				Иначе
					Возврат МассивПараметров[3];
				КонецЕсли;
			КонецЕсли;
		ИначеЕсли ИмяФормулы = "+" Тогда
			Если ТекущееПолеИни.Свойство("Тип") и ТекущееПолеИни.Тип = "Число" Тогда
				Результат = 0;
			Иначе
				Результат = "";
			КонецЕсли;
			Для Каждого Элемент Из МассивПараметров Цикл
				Элемент = РассчитатьЗначениеСервер(Элемент, Контекст);
				Если ТекущееПолеИни.Свойство("Тип") и ТекущееПолеИни.Тип = "Число" Тогда
					Результат = Результат + Число(Элемент);
				Иначе
					Результат = Результат + Элемент;
				КонецЕсли;	
			КонецЦикла;
			Если ТекущееПолеИни.Свойство("Формат") Тогда
				Результат = Формат(Результат,ТекущееПолеИни.Формат);
			КонецЕсли;
			Возврат Результат;
		ИначеЕсли ИмяФормулы = "*" Тогда
			Результат = 1;
			Для Каждого Элемент Из МассивПараметров Цикл
				Элемент = РассчитатьЗначениеСервер(Элемент, Контекст);
				Результат = Результат * Число(Элемент);
			КонецЦикла;
			Если ТекущееПолеИни.Свойство("Формат") Тогда
				Результат = Формат(Результат,ТекущееПолеИни.Формат);
			КонецЕсли;
			Возврат Результат;
		ИначеЕсли ИмяФормулы = "сред" Тогда
			КолПараметров = МассивПараметров.Количество();
			Если НЕ (КолПараметров=2 или КолПараметров=3) Тогда
				Возврат Неопределено;
			КонецЕсли;
			сч = 0;
			Для Каждого Элемент Из МассивПараметров Цикл
				МассивПараметров[сч] = РассчитатьЗначениеСервер(Элемент, Контекст);
				сч = сч+1;
			КонецЦикла;
			Если КолПараметров=2 Тогда
				Возврат Сред(МассивПараметров[0],МассивПараметров[1]);
			Иначе
				Возврат Сред(МассивПараметров[0],МассивПараметров[1],МассивПараметров[2]);	
			КонецЕсли;
		ИначеЕсли ИмяФормулы = "найти" Тогда
			КолПараметров = МассивПараметров.Количество();
			Если КолПараметров<>2 Тогда
				Возврат Неопределено;
			КонецЕсли;
			сч = 0;
			Для Каждого Элемент Из МассивПараметров Цикл
				МассивПараметров[сч] = РассчитатьЗначениеСервер(Элемент, Контекст);
				сч = сч+1;
			КонецЦикла;
			Возврат Найти(МассивПараметров[0],МассивПараметров[1]);	
		ИначеЕсли ИмяФормулы = "или" Тогда
			КолПараметров = МассивПараметров.Количество();
			Если МассивПараметров.Количество()<3 Тогда   // неправильно написана формула
				Возврат Неопределено;
			КонецЕсли;
			МассивПараметров[КолПараметров-1] = РассчитатьЗначениеСервер(МассивПараметров[КолПараметров-1], Контекст);
			МассивПараметров[КолПараметров-2] = РассчитатьЗначениеСервер(МассивПараметров[КолПараметров-2], Контекст);
			Для сч = 0 По КолПараметров-3 Цикл
				МассивПараметров[сч] = РассчитатьЗначениеСервер(МассивПараметров[сч], Контекст);
				Если МассивПараметров[сч] = Истина Тогда
					Возврат МассивПараметров[КолПараметров-2];
				КонецЕсли;
			КонецЦикла;
			Возврат МассивПараметров[КолПараметров-1];
		ИначеЕсли ИмяФормулы = "и" Тогда
			КолПараметров = МассивПараметров.Количество();
			Если МассивПараметров.Количество()<3 Тогда   // неправильно написана формула
				Возврат Неопределено;
			КонецЕсли;
			МассивПараметров[КолПараметров-1] = РассчитатьЗначениеСервер(МассивПараметров[КолПараметров-1], Контекст);
			МассивПараметров[КолПараметров-2] = РассчитатьЗначениеСервер(МассивПараметров[КолПараметров-2], Контекст);
			Для сч = 0 По КолПараметров-3 Цикл
				МассивПараметров[сч] = РассчитатьЗначениеСервер(МассивПараметров[сч], Контекст);
				Если МассивПараметров[сч] = Ложь Тогда
					Возврат МассивПараметров[КолПараметров-1];
				КонецЕсли;
			КонецЦикла;
			Возврат МассивПараметров[КолПараметров-2];
		ИначеЕсли ИмяФормулы = "окрбольше" Тогда
			КолПараметров = МассивПараметров.Количество();
			Если МассивПараметров.Количество()<>1 Тогда   // неправильно написана формула
				Возврат Неопределено;
			КонецЕсли;
			МассивПараметров[0] = РассчитатьЗначениеСервер(МассивПараметров[0], Контекст);
			Если Цел(МассивПараметров[0]) = МассивПараметров[0] Тогда
				Возврат МассивПараметров[0];
			Иначе
				Возврат Цел(МассивПараметров[0])+1;
			КонецЕсли;
		ИначеЕсли ИмяФормулы = "окр" Тогда
			КолПараметров = МассивПараметров.Количество();
			Если МассивПараметров.Количество()<2 Тогда   // неправильно написана формула
				Возврат Неопределено;
			КонецЕсли;
			сч = 0;
			Для Каждого Элемент Из МассивПараметров Цикл
				МассивПараметров[сч] = РассчитатьЗначениеСервер(Элемент, Контекст);
				сч = сч+1;
			КонецЦикла;
			Если МассивПараметров.Количество() = 2 Тогда
				Возврат Окр(Число(МассивПараметров[0]), Число(МассивПараметров[1]));
			Иначе
				Возврат Окр(Число(МассивПараметров[0]), Число(МассивПараметров[1]), РежимОкругления.Окр15как10);
			КонецЕсли;
		КонецЕсли;
	Исключение
		Ошибка = ОписаниеОшибки();
		Возврат Неопределено
	КонецПопытки
	
КонецФункции

Функция ВычислитьФункциюНаСервере(Контекст, СбисПараметр)
	Перем Документ, СтрТабл, Переменные;
	
	Если Контекст.Свойство("ИмяОбъекта") Тогда
		
		Контекст.ДанныеРезультат.Свойство(Контекст.ИмяОбъекта, Документ);
		
	КонецЕсли;	
	Если Контекст.Свойство("ИмяОбъектаЛокальное") Тогда
		
		Контекст.ДанныеРезультат.Свойство(Контекст.ИмяОбъектаЛокальное, СтрТабл);
		
	КонецЕсли;
	Контекст.Свойство("Переменные", Переменные);
	
	Если Сред(СбисПараметр, 2, 14) = "МодульОбъекта." Тогда
		
		ПарамерВычислить = Сред(СбисПараметр, 16, СтрДлина(СбисПараметр) - 16);
		
	Иначе
		
		ПарамерВычислить = Сред(СбисПараметр, 2, СтрДлина(СбисПараметр)-2);
		
	КонецЕсли;
	
	Попытка
		
		Результат = Вычислить(ПарамерВычислить);

	Исключение
		
		Ошибка = ОписаниеОшибки();
		
		Если Найти(Ошибка, "Обращение к процедуре объекта как к функции") Тогда
			Попытка
				
				Выполнить(ПарамерВычислить);
				
			Исключение
				
				Ошибка = ОписаниеОшибки();
				Сообщить(Ошибка+ "(ошибка при выполнении процедуры """+Сред(СбисПараметр, 2, СтрДлина(СбисПараметр)-2)+""")");
				
			КонецПопытки;
		#Если ТолстыйКлиентОбычноеПриложение Тогда
		ИначеЕсли	Найти(Ошибка, "Ошибка компиляции при вычислении выражения") Тогда
			
			Сообщить("Вы запустили 1С:Предприятие в режиме ""Толстый клиент"". Установите режим запуска ""Тонкий клиент"" или обратитесь к администратору. " + "(ошибка при выполнении процедуры или вычисления функции """+Сред(СбисПараметр, 2, СтрДлина(СбисПараметр)-2)+""")");
				
		#КонецЕсли				
		Иначе
			
			Сообщить(Ошибка+ "(ошибка при вычислении функции """+Сред(СбисПараметр, 2, СтрДлина(СбисПараметр)-2)+""")");
			
		КонецЕсли;
	КонецПопытки;
	
	Возврат Результат;
КонецФункции

#Область include_core2_vo2_Модуль_МодульОбъектаСервер_РассчитатьЗначениеНаСервере_ФункцииВызываемыеЧерезИни
#КонецОбласти

