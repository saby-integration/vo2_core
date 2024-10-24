
// Функция возвращает результат поиска значения в массиве структур
//
// Параметры:
//  МассивДляПоиска		 - Массив - Массив для поиска
//  ЗначениеСтруктуры	 - Произвольный - Значение для поиска
//  КлючСтруктуры		 - Строка - Ключ структуры для поиска
// 
// Возвращаемое значение:
//  Структура - Найденное значение (ЭлементМассива) или Неопределено
//
&НаКлиенте
Функция НайтиВМассивеСтруктурПоКлючу(МассивДляПоиска, ЗначениеСтруктуры, КлючСтруктуры) Экспорт	
	Результат = Неопределено;	
	Для Каждого ЭлементМассива Из МассивДляПоиска Цикл
		Если ЗначениеЗаполнено(Результат) Тогда Прервать; КонецЕсли;
		Если ТипЗнч(ЭлементМассива) = Тип("Структура") Тогда
			Для Каждого ЭлементСтруктуры Из ЭлементМассива Цикл
				Если ЭлементСтруктуры.Ключ = КлючСтруктуры
					И ЭлементСтруктуры.Значение = ЗначениеСтруктуры Тогда
					Результат = ЭлементМассива;
					Прервать;
				КонецЕсли;
			КонецЦикла;
		КонецЕсли;
	КонецЦикла;
	
	Возврат Результат;	
КонецФункции

// Функция возвращает массив уникальных значений по ключу структуры
//
// Параметры:
//  МассивИсточник	 - Массив - Массив для поиска 
//  КлючСтруктуры	 - Строка - Ключ структуры для поиска
// 
// Возвращаемое значение:
//  Массив - Найденное значение (ЭлементМассива) или пустой массив
//
&НаКлиенте
Функция СвернутьМассивСтруктурПоКлючу(МассивИсточник, КлючСтруктуры) Экспорт
			
	УникальныеЗначения = Новый Соответствие;  
	МассивПриемник = Новый Массив;
			
	Для Каждого Значение Из МассивИсточник Цикл
		Если УникальныеЗначения[Значение[КлючСтруктуры]] = Неопределено Тогда
			МассивПриемник.Добавить(Значение);
			УникальныеЗначения.Вставить(Значение[КлючСтруктуры], Истина);
		КонецЕсли;
	КонецЦикла; 
	
	Возврат МассивПриемник;		
	
КонецФункции 

// Функция Находит первое вхождение искомой строки как подстроки в исходной строке. Сравнение выполняется с учетом регистра.
//
// Параметры:
//  Строка				 - Строка	- Исходная строка.
//  ПодстрокаПоиска		 - Строка	- Искомая подстрока.
//  НаправлениеПоиска	 - Строка	- Указывает направление поиска подстроки в строке. По умолчанию: СНачала
//  НачальнаяПозиция	 - Число	- Указывает позицию в строке, с которой начинается поиск.
//  НомерВхождения		 - Число	- Указывает номер вхождения искомой подстроки в исходной строке.
// 
// Возвращаемое значение:
//  Число - Результат вычмсления функции.
//
&НаКлиенте
Функция СбисСтрНайти(Строка, ПодстрокаПоиска, НаправлениеПоиска = Неопределено, НачальнаяПозиция = Неопределено, НомерВхождения = 1) Экспорт
    
    Если Строка = "" И ПодстрокаПоиска = "" Тогда
        // чтобы отрабатывало как в платформе
        Если НаправлениеПоиска = "СКонца" Тогда
            Если НомерВхождения = 1 Тогда
                Возврат 1;
            Иначе
                Возврат 0;
            КонецЕсли;
        Иначе
            Возврат Мин(НомерВхождения, ?(НачальнаяПозиция = Неопределено, 1, НачальнаяПозиция));
        КонецЕсли;
    КонецЕсли;
    
    Если НачальнаяПозиция = Неопределено Тогда
        Если НаправлениеПоиска = "СКонца" Тогда
            лНачальнаяПозиция = СтрДлина(Строка);
        Иначе
            лНачальнаяПозиция = 1;
        КонецЕсли;
    Иначе
        лНачальнаяПозиция = НачальнаяПозиция;
    КонецЕсли;
    
    Если НаправлениеПоиска = "СКонца" Тогда
        лСтрока = "";
        Для сч = 1 По СтрДлина(Строка) Цикл
            лСтрока = Сред(Строка, сч, 1) + лСтрока;
        КонецЦикла;
        лПодстрокаПоиска = "";
        Для сч = 1 По СтрДлина(ПодстрокаПоиска) Цикл
            лПодстрокаПоиска = Сред(ПодстрокаПоиска, сч, 1) + лПодстрокаПоиска;
        КонецЦикла;
        лНачальнаяПозиция = Макс(1, СтрДлина(Строка) - лНачальнаяПозиция - СтрДлина(ПодстрокаПоиска) + 2);
    Иначе
        лСтрока = Строка;
        лПодстрокаПоиска = ПодстрокаПоиска;
    КонецЕсли;
    
    лНомерВхождения = 0;
    Результат = Найти(Сред(лСтрока, лНачальнаяПозиция), лПодстрокаПоиска);
    Пока Результат Цикл
        лНачальнаяПозиция = Результат + лНачальнаяПозиция + СтрДлина(ПодстрокаПоиска) - 1;
        лНомерВхождения = лНомерВхождения + 1;
        Если лНомерВхождения = НомерВхождения Тогда
            Прервать;
        КонецЕсли;
        Результат = Найти(Сред(лСтрока, лНачальнаяПозиция), лПодстрокаПоиска);
    КонецЦикла;
    
    Если лНомерВхождения = НомерВхождения Тогда
        Результат = лНачальнаяПозиция - СтрДлина(ПодстрокаПоиска);
    Иначе
        Результат = 0;
    КонецЕсли;
        
    Если НаправлениеПоиска = "СКонца" И Результат <> 0 Тогда
        Результат = СтрДлина(Строка) - Результат - СтрДлина(ПодстрокаПоиска) + 2;
    КонецЕсли;
    
    Возврат Результат;
    
КонецФункции  

// Функция аналог платформееной функции СтрСоединить, возвращает строку, содержащуя соединенные исходные строки с разделителем между ними. 
//
// Параметры:
//  МассивСтрок	 - Массив - Массив, содержащий объединяемые строки.
//  Разделитель	 - Строка - Строка, которая будет вставлена между объединяемыми строками.
// 
// Возвращаемое значение:
//  Строка - Строка, содержащая соединенные исходные строки с разделителем между ними.
//
&НаКлиенте
Функция СбисСтрСоединить(МассивСтрок, Разделитель = "") Экспорт
    
    Результат = "";
    
    Для Каждого ЭлементМассива Из МассивСтрок Цикл
        
        Результат = Результат + ЭлементМассива + Разделитель;    
        
    КонецЦикла;
    
    ОтрезатьСимволов = СтрДлина(Разделитель);
    
    ОставитьСимволов = СтрДлина(Результат) - ОтрезатьСимволов;
    
    Результат = Лев(Результат, ОставитьСимволов);
    
    Возврат Результат;
    
КонецФункции

// Парам - Строка - Выражение для преобразования.
//  Пусто - Неопределенный - Представление пустого значения (0 или пустая строка).
//  Ошибка - Неопределенный - Представление значения при ошибке преобразования.
//
// Параметры:
//  Строка	 - Строка - Выражение для преобразования.
//  Пустое	 - Число - 0 для представления "0", 1 для представления пустой строкой. Если на вход пришла пустая строка или строка не содержащая ЦИФЕРОК
//  Ошибка	 - Число - Что вернём в случае возникновения ошибки. Мне удобно ставить ноль, потому тут ноль 
// 
// Возвращаемое значение:
//  Число - переданное значение в виде числа. Если переданное значение пустое
//  или нулевое, возвращает значение параметра Пустое. В случае ошибки
//  распознавания, возвращает значение параметра Ошибка.
//
&НаКлиенте
Функция СбисСтрокаВЧисло(Знач Строка, Знач Пусто = 0, Знач Ошибка = 0) Экспорт
    
    Перем Результат, НомерСимвола, МаксНомерСимвола, ТекущийСимвол, Алфавит
        , Отрицательное, ЕстьДробнаяЧасть;
        
    Если Не ПустаяСтрока(Строка) Тогда
        Строка = СокрЛП(Строка);
        МаксНомерСимвола = СтрДлина(Строка);
        
        // Определяем знак числа и удаляем его из исходной строки.
        ТекущийСимвол = Лев(Строка, 1);
        Алфавит = "+-";
        Если Найти(Алфавит, ТекущийСимвол) > 0 Тогда
            Строка = Сред(Строка, 2);
            МаксНомерСимвола = МаксНомерСимвола - 1;
            Отрицательное = (ТекущийСимвол = "-");
        Иначе
            Отрицательное = Ложь;
        КонецЕсли;
        
        // С начала исходной строки определяем последовательность максимальной длины,
        // конторая может быть распознана как число.
        НомерСимвола = 1;
        Алфавит = "0123456789 .," + Символы.НПП;
        Пока НомерСимвола <= МаксНомерСимвола Цикл
            ТекущийСимвол = Сред(Строка, НомерСимвола, 1);
            Если Найти(Алфавит, ТекущийСимвол) = 0 Тогда
                Прервать;
            КонецЕсли;
            НомерСимвола = НомерСимвола + 1;
        КонецЦикла;
        
        // Удаляем правую часть строки, которая не участвует в распознавании.
        Если НомерСимвола <= МаксНомерСимвола Тогда
            Строка = Лев(Строка, НомерСимвола - 1);
            МаксНомерСимвола = НомерСимвола - 1;
        КонецЕсли;
        
        Если МаксНомерСимвола > 0 Тогда
            // Очищаем строку слева и справа от пробельных символов.
            Алфавит = " " + Символы.НПП;
            Пока Найти(Алфавит, Лев(Строка, 1)) > 0 Цикл
                Строка = Сред(Строка, 2);
                МаксНомерСимвола = МаксНомерСимвола - 1;
            КонецЦикла;
            Пока Найти(Алфавит, Прав(Строка, 1)) > 0 Цикл
                Строка = Лев(Строка, МаксНомерСимвола - 1);
                МаксНомерСимвола = МаксНомерСимвола - 1;
            КонецЦикла;
            
            // Определяем максимальное количество цифр справа, которые могут быть
            // распознаны как дробная часть
            НомерСимвола = МаксНомерСимвола;
            Алфавит = "012345679";
            Пока НомерСимвола >= 1 Цикл
                ТекущийСимвол = Сред(Строка, НомерСимвола, 1);
                Если Найти(Алфавит, ТекущийСимвол) = 0 Тогда
                    Прервать;
                КонецЕсли;
                НомерСимвола = НомерСимвола - 1;
            КонецЦикла;
            
            Если НомерСимвола > 0 Тогда
                // Для строки "123,456": "456" - дробная часть
                // Для строки "1,123,456": "456" - последняя триада целой части
                Если Найти(".,", ТекущийСимвол) > 0
                    И Не (МаксНомерСимвола - НомерСимвола = 3
                        И МаксНомерСимвола >= 9
                        И Сред(Строка, НомерСимвола - 4, 1) = ТекущийСимвол) Тогда
                    Строка = СтрЗаменить(СтрЗаменить(СтрЗаменить(СтрЗаменить(Лев(Строка, НомерСимвола - 1), ".", ""), ",", ""), " ", ""), Символы.НПП, "") + "." + Сред(Строка, НомерСимвола + 1);
                Иначе
                    Строка = СтрЗаменить(СтрЗаменить(СтрЗаменить(СтрЗаменить(Строка, ".", ""), ",", ""), " ", ""), Символы.НПП, "");
                КонецЕсли;
            КонецЕсли;
            
            Строка = ?(Отрицательное, "-", "") + Строка;
        КонецЕсли;
    КонецЕсли;
    
    Если ПустаяСтрока(Строка) Тогда
        Результат = Пусто;
    Иначе
        Попытка
            Результат = Число(Строка);
        Исключение
            Результат = Ошибка;
        КонецПопытки;
    КонецЕсли;
    
    Возврат Результат;

КонецФункции // СбисСтрокаВЧисло()

 &НаСервере
Функция ПолучитьДанныеОбъекта1С(ОбъектСсылка) Экспорт
    
    Возврат МодульОбъектаСервер().ВычитатьСтруктуруОбъекта1С(ОбъектСсылка);
    
КонецФункции
