
//DynamicDirective

// JSON парсер.   ----------------------------------------------------------------------------
//
// Параметры:
//	Значение - Строка. Строка данных в формате JSON для парсинга;
//
//  Стандарт - Неопределено, Булево. Режим работы:
//		- Истина - стандартный режим (значение по умолчанию);
//		- Ложь - альтернативный режим;
//		- Неопределено - автоопределение режима;
//
//  ПредставленияСсылок - Неопределено, Булево. Режим передачи ссылочных типов, с их представлением или без:
//		- Истина - ссылки передаются вместе со своим представлением, как объекты с двумя свойствами содержащими саму ссылку и ее представление;
//		- Ложь - ссылки передаются без представления (значение по умолчанию).
//		- Неопределено - автоопределение режима.
// 
// Возвращаемое значение:
//  Набор данных согласно содержимому входящих данных. 
//
Функция сбисПрочитатьJSON(Значение, Стандарт = Истина, ПредставленияСсылок = Ложь, ПреобразовыватьДаты = Истина) Экспорт
	Возврат jsonПрочитатьИнициализация(Значение, Стандарт, ПредставленияСсылок, ПреобразовыватьДаты);
КонецФункции 

// ─────────────────────────────────────────────────────────────────────────────
//  НАСТРОЙКИ

//DynamicDirective

// Функция управляющая настройкой "АвтоматическоеПриведениеОбъектаКСтруктуре".
//
// Возвращаемое значение:
//  Булево. Значение настройки:
//		- Истина - выполняется автоматическое приведение объекта к структуре; 
//		- Ложь - автоматическое приведение объекта к структуре не выполняется, все объекты преобразуются в соответствие. 
//
// Примечание:
//  Автоматическое приведение к структуре выполняется только для объектов имена свойств которых могут быть 
//  использованы как ключи структуры, все остальные объекты преобразуются в соответствие.
//
Функция НастройкаАвтоматическоеПриведениеОбъектаКСтруктуре()
	
	Возврат Истина; // Измените для использования автоматического приведения объекта к структуре.
	
КонецФункции // НастройкаАвтоматическоеПриведениеОбъектаКСтруктуре()

//DynamicDirective

// Функция управляющая настройкой "ПолноеМаскированиеСимволов".
//
// Возвращаемое значение:
//  Булево. Значение настройки:
//		- Истина - выполняется полное маскирование символов некорректно обрабатываемых JavaScript-ом; 
//		- Ложь - маскирование выполняется только согласно стандарту и дополнительно маскируются специальные символы. 
//
// Примечание:
//	Маскирование специальных символов из диапазона [0x0000, 0x001f] выполняется в не зависимости от настройки.
//
Функция НастройкаПолноеМаскированиеСимволов()
	
	Возврат Истина;	// Измените для неполного маскирования символов.
	
КонецФункции // НастройкаПолноеМаскированиеСимволов()

//DynamicDirective

// Функция управляющая настройкой "НеявноеПриведениеПримитивныхЗначенийКлюча".
//
// Возвращаемое значение:
//  Булево. Значение настройки:
//		- Истина - выполняется неявное приведение примитивных типов значений ключей соответствий к их строковому представлению в формате 1С; 
//		- Ложь - неявное приведение примитивных типов значений ключей соответствий к строковому представлению не выполняется. 
//
// Примечание:
//	Неявно приводимые типы: Null, Булево, Число, Дата, Строка, УникальныйИдентификатор.
//
Функция НастройкаНеявноеПриведениеПримитивныхЗначенийКлюча()
	
	Возврат Ложь;	// Измените для использования неявного приведения примитивных значений ключей соответствий к строке.
	
КонецФункции // НастройкаНеявноеПриведениеПримитивныхЗначенийКлюча()

//DynamicDirective

// ─────────────────────────────────────────────────────────────────────────────
//  ПАРСЕР
Функция jsonПрочитатьИнициализация(Значение, Стандарт, ПредставленияСсылок, ПреобразовыватьДаты)
	
	// Проверка параметров.
	Если (Не Стандарт = Истина) И (Не Стандарт = Ложь) И (Не Стандарт = Неопределено) Тогда 
		ВызватьИсключение ИсключениеНекорректныйПараметр("Стандарт"); 
	КонецЕсли; 
	Если (Не ПредставленияСсылок = Истина) И (Не ПредставленияСсылок = Ложь) И (Не ПредставленияСсылок = Неопределено) Тогда 
		ВызватьИсключение ИсключениеНекорректныйПараметр("ПредставленияСсылок"); 
	КонецЕсли; 
	
	// Схема подстановок шестнадцатиричной системы.
	СхемаПодстановок = Новый Соответствие; 
	ШестнадцатиричнаяСистема = "0123456789abcdef"; 
	ДесятичноеЧисло = 0;
	Для ВторойРазряд = 1 По 16 Цикл 
		Для ПервыйРазряд = 1 По 16 Цикл 
			СхемаПодстановок.Вставить(Сред(ШестнадцатиричнаяСистема, ВторойРазряд, 1) + Сред(ШестнадцатиричнаяСистема, ПервыйРазряд, 1), ДесятичноеЧисло); 
			ДесятичноеЧисло = ДесятичноеЧисло + 1; 
		КонецЦикла; 
	КонецЦикла;
	
	// Вспомогательные данные.
	ВспомогательныеДанные = Новый Структура("ТипСтроки,СхемаПодстановок,АвтоматическиПриводитьКСтруктуре",
	Тип("Строка"),
	СхемаПодстановок,
	(НастройкаАвтоматическоеПриведениеОбъектаКСтруктуре() = Истина));
	
	// Стартовые значения.
	Индекс = 1; 
	Длина = СтрДлина(Значение);
	
	// Форматирование (первый шаг парсера).
	Если (Стандарт = Истина) Или (Стандарт = Неопределено) Тогда 
		СимволыФорматирования = " " + Символы.ВК + Символы.ПС + Символы.Таб; 
		jsonПрочитатьПропуститьФорматирование(Значение, Стандарт, Индекс, Длина, СимволыФорматирования); 
	Иначе 
		СимволыФорматирования = ""; 
	КонецЕсли;
	Если (Индекс > Длина) Тогда 
		ВызватьИсключение ИсключениеПустойПакетДанных(); 
	КонецЕсли; 
	
	// Парсер.
	Возврат jsonПрочитать(Значение, Стандарт, ПредставленияСсылок, Индекс, Длина, ВспомогательныеДанные, СимволыФорматирования, Истина, ПреобразовыватьДаты);
	
КонецФункции // jsonПрочитатьИнициализация()

//DynamicDirective

Функция jsonПрочитать(Значение, Стандарт, ПредставленияСсылок, Индекс, Длина, ВспомогательныеДанные, СимволыФорматирования, ПервыйУровень, ПреобразовыватьДаты)
	
	Символ = Сред(Значение, Индекс, 1);
	ДлинаЗначения = СтрДлина(Значение);
	Если (Символ = "[") Тогда																								// [
		
		// Массив.
		Результат = Новый Массив;
		
		Индекс = Индекс + 1; 
		jsonПрочитатьПропуститьФорматирование(Значение, Стандарт, Индекс, Длина, СимволыФорматирования); 
		Если (Индекс > Длина) Тогда 
			ВызватьИсключение ИсключениеНеожиданноеОкончаниеМассива(Длина); 
		КонецЕсли;
		Символ = Сред(Значение, Индекс, 1); 
		Если (Символ = "]") Тогда														// ] 
			// Пустой массив.
			Индекс = Индекс + 1;
		Иначе
			Пока (Индекс <= Длина) Цикл
				// Значение.
				Результат.Добавить(jsonПрочитать(Значение, Стандарт, ПредставленияСсылок, Индекс, Длина, ВспомогательныеДанные, СимволыФорматирования, Ложь, ПреобразовыватьДаты));
				
				Символ = Сред(Значение, Индекс, 1);
				Если (Символ = "]") Тогда																					// ]
					// Окончание массива.
					Индекс = Индекс + 1; Прервать;
				Иначе
					// Продолжение массива.
					Если (Символ = ",") Тогда																				// ,
						Индекс = Индекс + 1; jsonПрочитатьПропуститьФорматирование(Значение, Стандарт, Индекс, Длина, СимволыФорматирования); Если (Индекс >= Длина) Тогда ВызватьИсключение ИсключениеНеожиданноеОкончаниеМассива(Длина); КонецЕсли;
					Иначе
						ВызватьИсключение ИсключениеНедопустимыйСимвол(Индекс, ",");
					КонецЕсли;
				КонецЕсли;
			КонецЦикла;
		КонецЕсли;
		
	ИначеЕсли (Символ = "{") Тогда																							// {
		
		// Объект.
		Индекс = Индекс + 1; 
		jsonПрочитатьПропуститьФорматирование(Значение, Стандарт, Индекс, Длина, СимволыФорматирования); 
		Если (Индекс > Длина) Тогда 
			ВызватьИсключение ИсключениеНеожиданноеОкончаниеМассива(Длина); 
		КонецЕсли;
		Символ = Сред(Значение, Индекс, 1); 
		Если (Символ = "}") Тогда														// } 
			// Пустой объект.
			Индекс = Индекс + 1;
			
			ТолькоДопустимыеСтроки = ВспомогательныеДанные.АвтоматическиПриводитьКСтруктуре; 
			Если ТолькоДопустимыеСтроки Тогда 
				РезультатСтруктура = Новый Структура; 
			Иначе 
				РезультатСоответствие = Новый Соответствие; 
			КонецЕсли;
			
		Иначе
			
			ТолькоДопустимыеСтроки = ВспомогательныеДанные.АвтоматическиПриводитьКСтруктуре; 
			РезультатСоответствие = Новый Соответствие; 
			Если ТолькоДопустимыеСтроки Тогда 
				РезультатСтруктура = Новый Структура; 
			КонецЕсли; 
			ТипСтроки = ВспомогательныеДанные.ТипСтроки;
			
			Пока (Индекс <= Длина) Цикл
				
				// Ключ.
				Начало = Индекс; 
				КлючЭлемента = jsonПрочитать(Значение, Стандарт, ПредставленияСсылок, Индекс, Длина, ВспомогательныеДанные, СимволыФорматирования, Ложь, ПреобразовыватьДаты); 
				Если (Не ТипЗнч(КлючЭлемента) = ТипСтроки) Тогда 
					ВызватьИсключение ИсключениеНедопустимыйТипКлюча(Начало, КлючЭлемента); 
				КонецЕсли;
				
				Символ = Сред(Значение, Индекс, 1);
				Если (Символ = ":") Тогда																					// :
					Индекс = Индекс + 1; jsonПрочитатьПропуститьФорматирование(Значение, Стандарт, Индекс, Длина, СимволыФорматирования); Если (Индекс >= Длина) Тогда ВызватьИсключение ИсключениеНеожиданноеОкончаниеОбъетка(Длина); КонецЕсли;
				Иначе
					ВызватьИсключение ИсключениеНедопустимыйСимвол(Индекс, ":");
				КонецЕсли;
				
				// Значение.
				ЗначениеЭлемента = jsonПрочитать(Значение, Стандарт, ПредставленияСсылок, Индекс, Длина, ВспомогательныеДанные, СимволыФорматирования, Ложь, ПреобразовыватьДаты);
				
				// Коллекция.
				РезультатСоответствие.Вставить(КлючЭлемента, ЗначениеЭлемента);
				Если ТолькоДопустимыеСтроки Тогда 
					Попытка 
						РезультатСтруктура.Вставить(КлючЭлемента, ЗначениеЭлемента); 
					Исключение 
						// всегда формируем структуру. Поля с плохими именами не записываем
						//ТолькоДопустимыеСтроки = Ложь;
					КонецПопытки; 
				КонецЕсли;
				
				Символ = Сред(Значение, Индекс, 1);
				Если (Символ = "}") Тогда																					// }
					// Окончание объекта.
					Индекс = Индекс + 1; Прервать;
				Иначе
					// Продолжение объекта.
					Если (Символ = ",") Тогда																				// ,
						Индекс = Индекс + 1; 
						jsonПрочитатьПропуститьФорматирование(Значение, Стандарт, Индекс, Длина, СимволыФорматирования); 
						Если (Индекс >= Длина) Тогда 
							ВызватьИсключение ИсключениеНеожиданноеОкончаниеОбъетка(Длина); 
						КонецЕсли;
					Иначе
						ВызватьИсключение ИсключениеНедопустимыйСимвол(Индекс, ",");
					КонецЕсли;
				КонецЕсли;
				
			КонецЦикла;	
			
		КонецЕсли;
		
		// Структуры.
		Если ТолькоДопустимыеСтроки Тогда   
			Результат = РезультатСтруктура; 
		Иначе
			Результат = РезультатСоответствие;
		КонецЕсли;
		
		// Ссылка.
		Если (ПредставленияСсылок = Истина) Или (ПредставленияСсылок = Неопределено) Тогда 
			Результат = jsonПрочитатьСсылку(Результат, ТолькоДопустимыеСтроки); 
		КонецЕсли;
		
	Иначе
		
		// Примитивные типы.
		Если (Символ = """") Или (Символ = "'") Тогда        																// " , '
			
			// Строка.
			Начало = Индекс; 
			//РезПодстрока = "";
			Пока Истина Цикл
				ТекущийСимвол = Сред(Значение, Индекс+1, 1);
				//РезПодстрока = РезПодстрока + ТекущийСимвол;
				сч = 1;
				ПредельнаяДлина = ДлинаЗначения-Индекс;
				Пока ТекущийСимвол<>Символ и сч<ПредельнаяДлина Цикл
					сч = сч+1;
					ТекущийСимвол = Сред(Значение, Индекс+сч, 1);
					//РезПодстрока = РезПодстрока + ТекущийСимвол;
				КонецЦикла;
				//РезПодстрока = Лев(РезПодстрока, СтрДлина(РезПодстрока)-1);
					
				Позиция = Индекс+сч;
				
				Если (ТекущийСимвол=Символ) Тогда  // нашли закрывающую кавычку
					Индекс = Позиция; 
					Откат = Позиция - 1; 
					Маскировка = Ложь; 
					Пока (Сред(Значение, Откат, 1) = "\") И Булево(Откат) Цикл 
						Маскировка = Не Маскировка; 
						Откат = Откат - 1; 
					КонецЦикла;
					Если Маскировка Тогда 
						//Подстрока = Сред(Подстрока, Позиция + 1); 
					Иначе 
						Прервать; 
					КонецЕсли;
				Иначе
					ВызватьИсключение ИсключениеНеожиданноеОкончаниеПакетаДанных();
				КонецЕсли;
				
			КонецЦикла;
			
			//Подстрока = Сред(Значение, Индекс + 1); Начало = Индекс; 
			//Пока Истина Цикл
			//	Позиция = Найти(Подстрока, Символ);
			//	
			//	Если (Позиция > 0) Тогда
			//		Индекс = Индекс + Позиция; 
			//		Откат = Позиция - 1; 
			//		Маскировка = Ложь; 
			//		Пока (Сред(Подстрока, Откат, 1) = "\") И Булево(Откат) Цикл 
			//			Маскировка = Не Маскировка; 
			//			Откат = Откат - 1; 
			//		КонецЦикла;
			//		Если Маскировка Тогда 
			//			Подстрока = Сред(Подстрока, Позиция + 1); 
			//		Иначе 
			//			Прервать; 
			//		КонецЕсли;
			//	Иначе
			//		ВызватьИсключение ИсключениеНеожиданноеОкончаниеПакетаДанных();
			//	КонецЕсли;
			//	
			//КонецЦикла;
			
			// Строка.
			Результат = jsonПрочитатьСтроку(Сред(Значение, Начало + 1, Индекс - Начало - 1), Стандарт, Начало, ВспомогательныеДанные.СхемаПодстановок, (Символ = "'"));
			
			Если jsonПрочитатьОпределитьДату(Результат) Тогда
				// Дата.
				Если ПреобразовыватьДаты Тогда
					Результат = jsonПрочитатьДату(Результат, Начало);
				КонецЕсли;
				//ИначеЕсли jsonПрочитатьОпределитьИдентификатор(Результат) Тогда
				//	// Идентификатор.
				//	Результат = jsonПрочитатьИдентификатор(Результат, Начало);
			ИначеЕсли (Стандарт = Ложь) Или (Стандарт = Неопределено) Тогда
				Если jsonПрочитатьОпределитьВнутреннийТип(Результат) Тогда
					// Внутренний тип.
					Результат = jsonПрочитатьВнутреннийТип(Результат, Начало);
				КонецЕсли;
			КонецЕсли;
			
			// Корректировка индекса.
			Индекс = Индекс + 1;
			
		Иначе
			
			Если (Символ = "n") Тогда
				// Null.
				Если (Сред(Значение, Индекс, 4) = "null") Тогда 
					Индекс = Индекс + 4; Результат = Null; 
				Иначе 
					ВызватьИсключение ИсключениеНекорректныйТипNull(Индекс); 
				КонецЕсли;
			ИначеЕсли (Символ = "t") Тогда
				// Истина.
				Если (Сред(Значение, Индекс, 4) = "true") Тогда 
					Индекс = Индекс + 4; 
					Результат = Истина; 
				Иначе 
					ВызватьИсключение ИсключениеНекорректныйТипБулево(Индекс); 
				КонецЕсли;
			ИначеЕсли (Символ = "f") Тогда
				// Ложь.
				Если (Сред(Значение, Индекс, 5) = "false") Тогда 
					Индекс = Индекс + 5; 
					Результат = Ложь; 
				Иначе 
					ВызватьИсключение ИсключениеНекорректныйТипБулево(Индекс); 
				КонецЕсли;
			ИначеЕсли (Символ = "u") Тогда
				// Неопределено.
				Если (Сред(Значение, Индекс, 9) = "undefined") Тогда 
					Индекс = Индекс + 9; 
					Результат = Неопределено; 
				Иначе 
					ВызватьИсключение ИсключениеНекорректныйТипНеопределено(Индекс); 
				КонецЕсли;
			Иначе
				// Число.
				Начало = Индекс; 
				Пока Булево(Найти("-+0123456789.", Символ)) И (Индекс <= Длина) Цикл 
					Индекс = Индекс + 1; 
					Символ = Сред(Значение, Индекс, 1); 
				КонецЦикла;
				
				// Преобразование числа.
				Попытка
					Результат = Число(Сред(Значение, Начало, Индекс - Начало));
				Исключение
					ВызватьИсключение ИсключениеНекорректныйФорматЧисла(Начало, Сред(Значение, Начало, Индекс - Начало)); 
				КонецПопытки;
				
				// Экспоненциальная часть.
				Если (Символ = "E") Или (Символ = "e") Тогда
					
					// Степень.
					Индекс = Индекс + 1; 
					Позиция = Индекс; 
					Символ = Сред(Значение, Индекс, 1); 
					Пока Булево(Найти("-+0123456789", Символ)) И (Индекс <= Длина) Цикл 
						Индекс = Индекс + 1; 
						Символ = Сред(Значение, Индекс, 1); 
					КонецЦикла;
					
					// Преобразование степени.
					Попытка
						Степень = Число(Сред(Значение, Позиция, Индекс - Позиция));
					Исключение
						ВызватьИсключение ИсключениеНекорректныйФорматЧисла(Начало, Сред(Значение, Начало, Индекс - Начало)); 
					КонецПопытки;
					
					// Возвидение числа в степень.
					Результат = Результат * Pow(10, Степень);
					
				КонецЕсли;
				
			КонецЕсли;
			
		КонецЕсли;
		
	КонецЕсли;
	
	// Форматирование.
	jsonПрочитатьПропуститьФорматирование(Значение, Стандарт, Индекс, Длина, СимволыФорматирования); 
	Если ПервыйУровень Тогда 
		Если (Индекс <= Длина) Тогда 
			ВызватьИсключение ИсключениеНекорректныйПакетДанных(Индекс); 
		КонецЕсли; 
	Иначе 
		Если (Индекс > Длина) Тогда 
			ВызватьИсключение ИсключениеНеожиданноеОкончаниеПакетаДанных(); 
		КонецЕсли; 
	КонецЕсли;
	
	Возврат Результат;
	
КонецФункции // jsonПрочитать()

//DynamicDirective

Функция jsonПрочитатьОпределитьДату(Значение)
	
	// Проверка.
	Если (СтрДлина(Значение) = 19) Тогда
		Если (Сред(Значение, 03, 1) = ".") И				// -
			(Сред(Значение, 06, 1) = ".") И				// -
			(Сред(Значение, 14, 1) = ".") И				// :
			(Сред(Значение, 17, 1) = ".") Тогда				// :
			// Год. 
			Если Булево(Найти("0123456789", Сред(Значение, 07, 1))) И
				Булево(Найти("0123456789", Сред(Значение, 08, 1))) И
				Булево(Найти("0123456789", Сред(Значение, 09, 1))) И
				Булево(Найти("0123456789", Сред(Значение, 10, 1))) И
				// Месяц.
				Булево(Найти("0123456789", Сред(Значение, 04, 1))) И
				Булево(Найти("0123456789", Сред(Значение, 05, 1))) И
				// День.
				Булево(Найти("0123456789", Сред(Значение, 01, 1))) И
				Булево(Найти("0123456789", Сред(Значение, 02, 1))) И
				// Час.
				Булево(Найти("0123456789", Сред(Значение, 12, 1))) И
				Булево(Найти("0123456789", Сред(Значение, 13, 1))) И
				// Минута.
				Булево(Найти("0123456789", Сред(Значение, 15, 1))) И
				Булево(Найти("0123456789", Сред(Значение, 16, 1))) И
				// Секунда.
				Булево(Найти("0123456789", Сред(Значение, 18, 1))) И
				Булево(Найти("0123456789", Сред(Значение, 19, 1))) Тогда
				Возврат Истина; 
			КонецЕсли;
		КонецЕсли;
	КонецЕсли;
	Если (СтрДлина(Значение) = 10) Тогда
		Если (Сред(Значение, 03, 1) = ".") И				// -
			(Сред(Значение, 06, 1) = ".") Тогда				// :
			// Год. 
			Если Булево(Найти("0123456789", Сред(Значение, 07, 1))) И
				Булево(Найти("0123456789", Сред(Значение, 08, 1))) И
				Булево(Найти("0123456789", Сред(Значение, 09, 1))) И
				Булево(Найти("0123456789", Сред(Значение, 10, 1))) И
				// Месяц.
				Булево(Найти("0123456789", Сред(Значение, 04, 1))) И
				Булево(Найти("0123456789", Сред(Значение, 05, 1))) И
				// День.
				Булево(Найти("0123456789", Сред(Значение, 01, 1))) И
				Булево(Найти("0123456789", Сред(Значение, 02, 1))) Тогда
				Возврат Истина; 
			КонецЕсли;
		КонецЕсли;
	КонецЕсли;
	
	Возврат Ложь;
	
КонецФункции // jsonПрочитатьОпределитьДату()

//DynamicDirective

Функция jsonПрочитатьОпределитьИдентификатор(Значение)
	
	// Проверка.
	Если (СтрДлина(Значение) = 36) Тогда
		Если (Сред(Значение, 09, 1) = "-") И					// -
			(Сред(Значение, 14, 1) = "-") И					// -
			(Сред(Значение, 19, 1) = "-") И					// -
			(Сред(Значение, 24, 1) = "-") Тогда				// -
			// Первая часть. 
			Для Индекс = 01 По 08 Цикл Если Не Булево(Найти("0123456789ABCDEFabcdef", Сред(Значение, Индекс, 1))) Тогда Возврат Ложь; КонецЕсли; КонецЦикла;
			// Вторая часть. 
			Для Индекс = 10 По 13 Цикл Если Не Булево(Найти("0123456789ABCDEFabcdef", Сред(Значение, Индекс, 1))) Тогда Возврат Ложь; КонецЕсли; КонецЦикла;
			// Третья часть. 
			Для Индекс = 15 По 18 Цикл Если Не Булево(Найти("0123456789ABCDEFabcdef", Сред(Значение, Индекс, 1))) Тогда Возврат Ложь; КонецЕсли; КонецЦикла;
			// Четвертая часть. 
			Для Индекс = 20 По 23 Цикл Если Не Булево(Найти("0123456789ABCDEFabcdef", Сред(Значение, Индекс, 1))) Тогда Возврат Ложь; КонецЕсли; КонецЦикла;
			// Пятая часть. 
			Для Индекс = 25 По 36 Цикл Если Не Булево(Найти("0123456789ABCDEFabcdef", Сред(Значение, Индекс, 1))) Тогда Возврат Ложь; КонецЕсли; КонецЦикла;
			Возврат Истина;
		КонецЕсли;
	КонецЕсли;
	
	Возврат Ложь;
	
КонецФункции // jsonПрочитатьОпределитьИдентификатор()

//DynamicDirective

Функция jsonПрочитатьОпределитьВнутреннийТип(Значение)
	
	// Поиск.
	Возврат (Лев(Значение, 1) = "¦") И (Сред(Значение, 5, 1) = "¦") И (Прав(Значение, 1) = "¦"); // ¦xxx¦ ... ¦
	
КонецФункции // jsonПрочитатьОпределитьВнутреннийТип()

//DynamicDirective

Функция jsonПрочитатьСтроку(Значение, Стандарт, Индекс, СхемаПодстановок, ОдинарнаяКавычка)
	
	// Последоавтельность перемаскировки.
	ПоследоавтельностьПеремаскировки = "\" + Символ(65535);
	
	// Демаскирование служебных символов.
	Результат = СтрЗаменить(СтрЗаменить(СтрЗаменить(СтрЗаменить(СтрЗаменить(СтрЗаменить(СтрЗаменить(СтрЗаменить(Значение, 
	"\\",			ПоследоавтельностьПеремаскировки),		// Перемаскирование последовательности.
	"\/",			"/"),           // x2f
	"\b",			Символ(008)),	// x08
	"\t",			Символы.Таб),   // x09
	"\n",			Символы.ПС),    // x0a
	"\f",			Символы.ПФ),    // x0c
	"\r",			Символы.ВК),    // x0d
	"\""",			"""");          // x22
	
	// Демаскирование Юникод символов.
	Позиция = Найти(Результат, "\u"); Пока Булево(Позиция) Цикл
		СтаршийБайт = СхемаПодстановок[НРег(Сред(Результат, Позиция + 2, 2))]; МладшийБайт = СхемаПодстановок[НРег(Сред(Результат, Позиция + 4, 2))]; Если (СтаршийБайт = Неопределено) Или (МладшийБайт = Неопределено) Тогда ВызватьИсключение ИсключениеНекорректныйФорматСтроки(Индекс); КонецЕсли;
		Результат = СтрЗаменить(Результат, Сред(Результат, Позиция, 6), Символ(256 * СтаршийБайт + МладшийБайт)); Позиция = Найти(Результат, "\u");
	КонецЦикла;
	
	// Одинарная кавычка.
	Если ОдинарнаяКавычка Тогда Результат = СтрЗаменить(Результат, "\'", "'"); КонецЕсли;
	
	// Демаскирование перемаскированой последовательности.
	Возврат СтрЗаменить(Результат, ПоследоавтельностьПеремаскировки, "\");				
	
КонецФункции // jsonПрочитатьСтроку()

//DynamicDirective

Функция jsonПрочитатьДату(Значение, Индекс)
	
	// Поиск.
	Попытка
		Возврат ПривестиСтрокуВДату(Значение);
	Исключение
		ВызватьИсключение ИсключениеНекорректныйФорматДаты(Индекс, Значение);
	КонецПопытки;
	
КонецФункции // jsonПрочитатьДату()

//DynamicDirective

Функция jsonПрочитатьСсылку(Значение, Структура)
	
	Перем Ссылка;
	
	// Ссылка.
	Если (Значение.Количество() = 2) Тогда 
		Если Структура Тогда
			Если Значение.Свойство("Представление") И Значение.Свойство("Ссылка", Ссылка) Тогда Возврат Ссылка; КонецЕсли;
		Иначе
			Ссылка = Значение.Получить("Ссылка"); Если (Не Ссылка = Неопределено) И (Не Значение.Получить("Представление") = Неопределено) Тогда Возврат Ссылка; КонецЕсли;
		КонецЕсли;
	КонецЕсли;	
	
	Возврат Значение;
	
КонецФункции // jsonПрочитатьСсылку()

//DynamicDirective

Функция jsonПрочитатьИдентификатор(Значение, Индекс)
	
	// Поиск.
	Попытка
		Возврат Новый УникальныйИдентификатор(Значение);
	Исключение
		ВызватьИсключение ИсключениеНевозможноПреобразоватьЗначение(Индекс, Значение);
	КонецПопытки;
	
КонецФункции // jsonПрочитатьИдентификатор()

//DynamicDirective

Функция jsonПрочитатьВнутреннийТип(Значение, Индекс)
	#Если ВебКлиент Или ТонкийКлиент Тогда
		ВызватьИсключение ИсключениеНевозможноПреобразоватьЗначениеНаКлиенте(Индекс, Значение);
	#Иначе
		
		// Поиск.
		Тип = Сред(Значение, 2, 3); Данные = Сред(Значение, 6, СтрДлина(Значение) - 6);
		
		Если (Тип = "ref") Тогда
			Попытка
				Возврат ЗначениеИзСтрокиВнутр("{""#""," + СтрЗаменить(СтрЗаменить(Данные, "×", ":"), "÷", ",") + "}");
			Исключение
				ВызватьИсключение ИсключениеНевозможноПреобразоватьЗначение(Индекс, Значение);
			КонецПопытки;
		КонецЕсли;
		
		ВызватьИсключение ИсключениеНеопознанныйТип(Индекс, Тип);
		
	#КонецЕсли
КонецФункции // jsonПрочитатьВнутреннийТип()

//DynamicDirective

Процедура jsonПрочитатьПропуститьФорматирование(Значение, Стандарт, Индекс, Длина, СимволыФорматирования)
	
	// Пропуск форматирования.
	Если (Стандарт = Истина) Или (Стандарт = Неопределено) Тогда Пока (Индекс <= Длина) И Булево(Найти(СимволыФорматирования, Сред(Значение, Индекс, 1))) Цикл Индекс = Индекс + 1; КонецЦикла; КонецЕсли;
	// Пробел его не видно, \r, \n, \t .
	
КонецПроцедуры // jsonПрочитатьПропуститьФорматирование()

// ─────────────────────────────────────────────────────────────────────────────
//  ЛОКАЛИЗАЦИЯ

//DynamicDirective

Функция сбисШаблон(Строка, Параметры) Экспорт
	
	Результат = Строка;
	
	Для Каждого Параметр Из Параметры Цикл
		Результат = СтрЗаменить(Результат, "[" + Параметр.Ключ + "]", Строка(Параметр.Значение));
	КонецЦикла;
	
	Возврат Результат;
	
КонецФункции // сбисШаблон()

//DynamicDirective

Функция ИсключениеПустойПакетДанных() Экспорт 
	
	Возврат НСтр("ru = 'JSON: Пустой пакет данных.'; uk = 'JSON: Порожній пакет даних.'");
	
КонецФункции // ИсключениеНеожиданноеОкончаниеСтроки()

//DynamicDirective

Функция ИсключениеНекорректныйПакетДанных(Индекс) Экспорт 
	
	Возврат сбисШаблон(НСтр("ru = 'JSON: Некорректный пакет данных в позиции [Индекс].'; uk = 'JSON: Некоректний пакет даних у позиції [Индекс].'"),
	Новый Структура("Индекс", Индекс));
	
КонецФункции // ИсключениеНекорректныйПакетДанных()

//DynamicDirective

Функция ИсключениеНеожиданноеОкончаниеПакетаДанных() Экспорт 
	
	Возврат НСтр("ru = 'JSON: Неожиданное окончание пакета данных.'; uk = 'JSON: Несподіване закінчення пакета даних.'");
	
КонецФункции // ИсключениеНеожиданноеОкончаниеПакетаДанных()

//DynamicDirective

Функция ИсключениеНеожиданноеОкончаниеМассива(Индекс) Экспорт 
	
	Возврат сбисШаблон(НСтр("ru = 'JSON: Неожиданное окончание массива в позиции [Индекс].'; uk = 'JSON: Несподіване закінчення масиву у позиції [Индекс].'"),
	Новый Структура("Индекс", Индекс));
	
КонецФункции // ИсключениеНеожиданноеОкончаниеМассива()

//DynamicDirective

Функция ИсключениеНеожиданноеОкончаниеОбъетка(Индекс) Экспорт 
	
	Возврат сбисШаблон(НСтр("ru = 'JSON: Неожиданное окончание объекта в позиции [Индекс].'; uk = 'JSON: Несподіване закінчення об''єкту у позиції [Индекс].'"),
	Новый Структура("Индекс", Индекс));
	
КонецФункции // ИсключениеНеожиданноеОкончаниеОбъетка()

//DynamicDirective

Функция ИсключениеНекорректныйТипNull(Индекс) Экспорт 
	
	Возврат сбисШаблон(НСтр("ru = 'JSON: Некорректный тип Null в позиции [Индекс].'; uk = 'JSON: Некоректний тип Null у позиції [Индекс].'"),
	Новый Структура("Индекс", Индекс));
	
КонецФункции // ИсключениеНекорректныйТипNull()

//DynamicDirective

Функция ИсключениеНекорректныйТипБулево(Индекс) Экспорт 
	
	Возврат сбисШаблон(НСтр("ru = 'JSON: Некорректный тип Булево в позиции [Индекс].'; uk = 'JSON: Некоректний тип Булево у позиції [Индекс].'"),
	Новый Структура("Индекс", Индекс));
	
КонецФункции // ИсключениеНекорректныйТипБулево()

//DynamicDirective

Функция ИсключениеНекорректныйТипНеопределено(Индекс) Экспорт 
	
	Возврат сбисШаблон(НСтр("ru = 'JSON: Некорректный тип Неопределено в позиции [Индекс].'; uk = 'JSON: Некоректний тип Невизначено у позиції [Индекс].'"),
	Новый Структура("Индекс", Индекс));
	
КонецФункции // ИсключениеНекорректныйТипНеопределено()

//DynamicDirective

Функция ИсключениеНекорректныйФорматСтроки(Индекс) Экспорт 
	
	Возврат сбисШаблон(НСтр("ru = 'JSON: Некорректный формат строки в позиции [Индекс].'; uk = 'JSON: Некоректний формат рядка у позиції [Индекс].'"),
	Новый Структура("Индекс", Индекс));
	
КонецФункции // ИсключениеНекорректныйФорматСтроки()

//DynamicDirective

Функция ИсключениеНекорректныйФорматДаты(Индекс, Значение) Экспорт 
	
	Возврат сбисШаблон(НСтр("ru = 'JSON: Некорректный формат даты [Значение] в позиции [Индекс].'; uk = 'JSON: Некоректний формат дати [Значение] у позиції [Индекс].'"),
	Новый Структура("Индекс", Индекс, Символ(034) + Значение + Символ(034)));
	
КонецФункции // ИсключениеНекорректныйФорматДаты()

//DynamicDirective

Функция ИсключениеНекорректныйФорматЧисла(Индекс, Значение) Экспорт 
	
	Если ПустаяСтрока(Значение) Тогда
		
		Возврат сбисШаблон(НСтр("ru = 'JSON: Неверный формат данных в позиции [Индекс].'; uk = 'JSON: Невірний формат даних у позиції [Индекс].'"),
		Новый Структура("Индекс", Индекс));
		
	Иначе
		
		Возврат сбисШаблон(НСтр("ru = 'JSON: Некорректный формат числа [Значение] в позиции [Индекс].'; uk = 'JSON: Некоректний формат числа [Значение] у позиції [Индекс].'"),
		Новый Структура("Индекс,Значение", Индекс, Символ(034) + Значение + Символ(034)));
		
	КонецЕсли;
	
КонецФункции // ИсключениеНекорректныйФорматЧисла()

//DynamicDirective

Функция ИсключениеНедопустимыйСимвол(Индекс, Символ) Экспорт 
	
	Если (Символ = Неопределено) Тогда
		
		Возврат сбисШаблон(НСтр("ru = 'JSON: Недопустимый символ в позиции [Индекс].'; uk = 'JSON: Неприпустимий символ в позиції [Индекс].'"),
		Новый Структура("Индекс", Индекс));
		
	Иначе
		
		Возврат сбисШаблон(НСтр("ru = 'JSON: Недопустимый символ в позиции [Индекс], ожидается [Символ].'; uk = 'JSON: Неприпустимий символ в позиції [Индекс], очікується [Символ].'"),
		Новый Структура("Индекс,Символ", Индекс, Символ(034) + Символ + Символ(034)));
		
	КонецЕсли;
	
КонецФункции // ИсключениеНедопустимыйСимвол()

//DynamicDirective

Функция ИсключениеНеопознанныйТип(Индекс, Тип) Экспорт 
	
	Возврат сбисШаблон(НСтр("ru = 'JSON: Недопустимый тип [Тип] в позиции [Индекс].'; uk = 'JSON: Неприпустимий тип [Тип] у позиції [Индекс].'"),
	Новый Структура("Индекс,Тип", Индекс, Символ(034) + Тип + Символ(034)));
	
КонецФункции // ИсключениеНеопознанныйТип()

//DynamicDirective

Функция ИсключениеНевозможноПреобразоватьЗначение(Индекс, Значение) Экспорт 
	
	Возврат сбисШаблон(НСтр("ru = 'JSON: Невозможно преобразовать значение [Значение] в позиции [Индекс].'; uk = 'JSON: Неможливо перетворити значення [Значение] у позиції [Индекс].'"),
	Новый Структура("Индекс,Значение", Индекс, Символ(034) + Значение + Символ(034)));
	
КонецФункции // ИсключениеНевозможноПреобразоватьЗначение()

//DynamicDirective

Функция ИсключениеНевозможноПреобразоватьЗначениеНаКлиенте(Индекс, Значение) Экспорт 
	
	Возврат сбисШаблон(НСтр("ru = 'JSON: Невозможно на клиенте преобразовать значение [Значение] в позиции [Индекс].'; uk = 'JSON: Неможливо на клієнті перетворити значення [Значение] у позиції [Индекс].'"),
	Новый Структура("Индекс,Значение", Индекс, Символ(034) + Значение + Символ(034)));
	
КонецФункции // ИсключениеНевозможноПреобразоватьЗначениеНаКлиенте()

//DynamicDirective

Функция ИсключениеНекорректныйПараметр(Параметр) Экспорт 
	
	Возврат сбисШаблон(НСтр("ru = 'JSON: Недопустимое значение параметра [Параметр].'; uk = 'JSON: Неприпустиме значення параметра [Параметр].'"),
	Новый Структура("Параметр", Символ(034) + Параметр+ Символ(034)));
	
КонецФункции // ИсключениеНекорректныйПараметр()

//DynamicDirective

Функция ИсключениеНедопустимыйТипКлюча(Индекс, Значение) Экспорт 
	
	Если (Индекс = Неопределено) Тогда
		
		Возврат сбисШаблон(НСтр("ru = 'JSON: Недопустимый тип значения ключа [Тип].'; uk = 'JSON: Неприпустимий тип значення ключа [Тип].'"),
		Новый Структура("Тип", ТипЗнч(Значение)));
		
	Иначе
		
		Возврат сбисШаблон(НСтр("ru = 'JSON: Недопустимый тип значения ключа [Тип] в позиции [Индекс].'; uk = 'JSON: Неприпустимий тип значення ключа [Тип] в позиції [Индекс].'"),
		Новый Структура("Индекс,Тип", Индекс, Символ(034) + ТипЗнч(Значение) + Символ(034)));
		
	КонецЕсли;
	
КонецФункции // ИсключениеНедопустимыйТипКлюча()

//DynamicDirective

Функция ИсключениеНевозможноВыполнитьЗапрос(Описание) Экспорт 
	
	Позиция = Найти(Описание, "}: "); Если Булево(Позиция) Тогда Позиция = Позиция + 3; Иначе Позиция = 1; КонецЕсли;
	Длина = Найти(Описание, Символы.ПС); Если Булево(Длина) Тогда Длина = Длина - Позиция; Иначе Длина = СтрДлина(Описание); КонецЕсли;
	Возврат НСтр("ru = 'JSON: Невозможно выполнить запрос. '; uk = 'JSON: Неможливо виконати запит. '") + Сред(Описание, Позиция, Длина) + ".";
	
КонецФункции // ИсключениеНевозможноВыполнитьЗапрос()

//DynamicDirective

Функция ПривестиСтрокуВДату(ДатаСтрокой) Экспорт
	Если Сред(ДатаСтрокой,3,1)="." и Сред(ДатаСтрокой,6,1)="." и СтрДлина(ДатаСтрокой)=10 Тогда //видимо это дата
		Попытка
			Возврат Дата(Сред(ДатаСтрокой,7,4), Сред(ДатаСтрокой,4,2), Лев(ДатаСтрокой, 2));
		Исключение
		КонецПопытки;
	КонецЕсли;		
	Если Сред(ДатаСтрокой,3,1)="." и Сред(ДатаСтрокой,6,1)="." и СтрДлина(ДатаСтрокой)=19 Тогда //видимо это дата
		Попытка
			Возврат Дата(Сред(ДатаСтрокой,7,4), Сред(ДатаСтрокой,4,2), Лев(ДатаСтрокой, 2), Сред(ДатаСтрокой,12, 2), Сред(ДатаСтрокой,15, 2), Сред(ДатаСтрокой,18, 2));
		Исключение
		КонецПопытки;
	КонецЕсли;
КонецФункции

//DynamicDirective

Функция JSON_ПреобразоватьСтроку(ЗначениеПреобразовать)
	Возврат СтрЗаменить(СтрЗаменить(СтрЗаменить(СтрЗаменить(СтрЗаменить(СтрЗаменить(СтрЗаменить(Строка(ЗначениеПреобразовать), 
		"\",								"\\"),// Перемаскирование последовательности.
		//"/",								"\/"),// x2f//AU правый слеш не оборачиваем.
		Символ(008),						"\b"),// x08
		Символы.Таб,						"\t"),// x09
		Символы.ПС,							"\n"),// x0a
		Символы.ПФ,							"\f"),// x0c
		Символы.ВК,							"\r"),// x0d
		Символ(34),							"\""");//кавычки;
КонецФункции

////////////////////////////
/////Конвертер в JSON///////

//Параметры конвертации: Структура. Возможные Значения: "ExtSDK" - режим обмена с плагином. Во всех прочих случаях будет выполнена конвертация в обычный json

//DynamicDirective

Функция ПреобразоватьЗначениеВJSON(ЗначениеПреобразовать, ПараметрыКонвертации=Неопределено) Экспорт
	
	Режим = "Стандарт";
	Если Не ПараметрыКонвертации = Неопределено Тогда
		Режим = ПараметрыКонвертации.Режим;
	КонецЕсли;
	СтрокаJSON = ЗначениеВJSON(ЗначениеПреобразовать, Режим);
	Возврат СтрокаJSON;
	
КонецФункции

//DynamicDirective

Функция ЗначениеВJSON(ЗначениеПреобразовать, Режим, ПервыйУровень=Истина) 
	
	ТекстРезультат	= "";
	_ТипЗначения	= ТипЗнч(ЗначениеПреобразовать);
	Если		ЗначениеПреобразовать = Неопределено	Тогда	//Неопределено
		ТекстРезультат = "null";
		Если Режим = "API" Тогда
			ТекстРезультат = ЗначениеВJSON("", Режим, ПервыйУровень);
		КонецЕсли;
	ИначеЕсли	ЗначениеПреобразовать = Null			Тогда	//Null
		ТекстРезультат = "null";
		Если Режим= "ExtSDK" Тогда
			ТекстРезультат = ЗначениеВJSON(Новый Структура, Режим, ПервыйУровень);//При формировании сообщения, идёт как dict
		КонецЕсли;	
	ИначеЕсли	_ТипЗначения = Тип("Структура")			Тогда	//Структура
		ТекстРезультат = "{";
		Для Каждого КлючИЗначение Из ЗначениеПреобразовать Цикл
			ТекстРезультат = ТекстРезультат+""""+КлючИЗначение.Ключ+""":"+ ЗначениеВJSON(КлючИЗначение.Значение, Режим, Ложь)+",";
		КонецЦикла;
		Если Прав(ТекстРезультат, 1) = "," Тогда
			ТекстРезультат = Лев(ТекстРезультат, СтрДлина(ТекстРезультат)-1);
		КонецЕсли;		
		ТекстРезультат = ТекстРезультат + "}";
	ИначеЕсли _ТипЗначения = Тип("Соответствие") Тогда
	
		ТекстРезультат = "{";
		
		Для Каждого КлючИЗначение Из ЗначениеПреобразовать Цикл
			
			ТекстРезультат = ТекстРезультат 
				+ """"
				+ JSON_ПреобразоватьСтроку(Строка(КлючИЗначение.Ключ))
				+ """:" 
				+ ЗначениеВJSON(КлючИЗначение.Значение, Режим, Ложь)
				+ ",";
				
		КонецЦикла;
		
		Если Прав(ТекстРезультат, 1) = "," Тогда
			ТекстРезультат = Лев(ТекстРезультат, СтрДлина(ТекстРезультат) - 1);
		КонецЕсли;
		
		ТекстРезультат = ТекстРезультат + "}";
	ИначеЕсли	_ТипЗначения = Тип("Массив")			Тогда	//Массив
		ТекстРезультат = ТекстРезультат + "[";
		Для Каждого Элемент Из ЗначениеПреобразовать Цикл
			ТекстРезультат = ТекстРезультат+ЗначениеВJSON(Элемент, Режим, Ложь)+",";
		КонецЦикла;
		Если Прав(ТекстРезультат, 1) = "," Тогда
			ТекстРезультат = Лев(ТекстРезультат, СтрДлина(ТекстРезультат)-1);
		КонецЕсли;		
		ТекстРезультат = ТекстРезультат + "]";
	ИначеЕсли	_ТипЗначения = Тип("Число")				Тогда	//Число 
		ТекстРезультат = Формат(ЗначениеПреобразовать, "ЧРД=.; ЧН=0; ЧГ=0");
		Если Режим = "API" Тогда//Для АПИ оборачиваем числа как строку
			ТекстРезультат = ЗначениеВJSON(ТекстРезультат, Режим, ПервыйУровень);
		КонецЕсли;
	ИначеЕсли	_ТипЗначения = Тип("Булево")			Тогда	//Булево
		ТекстРезультат = Формат(ЗначениеПреобразовать, "БЛ=false; БИ=true");
	Иначе
		Если	_ТипЗначения = Тип("Дата")				Тогда	//Дата
			ТекстРезультат = Строка(ЗначениеПреобразовать);
		Иначе													//Строка
			ТекстРезультат = JSON_ПреобразоватьСтроку(ЗначениеПреобразовать);
		КонецЕсли;
		Если Не ПервыйУровень Тогда//Для 1 уровня не оборачиваем кавычками строку
			ТекстРезультат = """"+ТекстРезультат+"""";
		КонецЕсли;
	КонецЕсли;
	Возврат ТекстРезультат;
	
КонецФункции

