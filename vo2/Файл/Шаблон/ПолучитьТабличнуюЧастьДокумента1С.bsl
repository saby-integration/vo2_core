
//Функция формирует структуру табличной части файла	
&НаКлиенте
Функция ПолучитьТабличнуюЧастьДокумента1С(Кэш,Контекст) Экспорт
	Перем СбисНДСИсчисляетсяАгентом;
	СуммаВключаетНДС = Кэш.ОбщиеФункции.РассчитатьЗначение("СуммаВключаетНДС", Контекст.ФайлДанные,Кэш);
	КодыМаркировки = Кэш.ОбщиеФункции.РассчитатьЗначение("КодыМаркировки", Контекст.ФайлДанные,Кэш);
	ПредКодыМаркировки = Кэш.ОбщиеФункции.РассчитатьЗначение("ПредКодыМаркировки", Контекст.ФайлДанные,Кэш);
	Если Не Контекст.Свойство("НДСИсчисляетсяАгентом", СбисНДСИсчисляетсяАгентом) Тогда
		СбисНДСИсчисляетсяАгентом = Кэш.ОбщиеФункции.РассчитатьЗначение("НДСИсчисляетсяАгентом", Контекст.ФайлДанные) = Истина;
	КонецЕсли;
	УказанТипНоменклатуры = Ложь;
	КолТоваров = 0;
	// проверяем надо ли пересчитывать суммы в валюту учета
	Валюта = Кэш.ОбщиеФункции.РассчитатьЗначение("Валюта", Контекст.ФайлДанные,Кэш);
	ВалютаУчета = Кэш.ОбщиеФункции.РассчитатьЗначение("ВалютаУчета", Контекст.ФайлДанные,Кэш);
	Если ЗначениеЗаполнено(Валюта) и ЗначениеЗаполнено(ВалютаУчета) и Валюта<>ВалютаУчета Тогда
		ПересчитатьВВалютеУчета = Кэш.ОбщиеФункции.РассчитатьЗначение("ПересчитатьВВалютеУчета", Контекст.ФайлДанные,Кэш);
	Иначе
		ПересчитатьВВалютеУчета = Ложь;
	КонецЕсли;
	Если ПересчитатьВВалютеУчета=Истина Тогда
		ИтогСумма = Кэш.ОбщиеФункции.РассчитатьЗначение("ИтогСумма", Контекст.ФайлДанные,Кэш);
		СуммаДляПересчетаВключаетНДС = Кэш.ОбщиеФункции.РассчитатьЗначение("СуммаДляПересчетаВключаетНДС", Контекст.ФайлДанные,Кэш);	
		Если Не ЗначениеЗаполнено(СуммаДляПересчетаВключаетНДС) Тогда
			СуммаДляПересчетаВключаетНДС = СуммаВключаетНДС;
		КонецЕсли;
		КурсВзаиморасчетов = Кэш.ОбщиеФункции.РассчитатьЗначение("КурсВзаиморасчетов", Контекст.ФайлДанные,Кэш);
		КратностьВзаиморасчетов = Кэш.ОбщиеФункции.РассчитатьЗначение("КратностьВзаиморасчетов", Контекст.ФайлДанные,Кэш);
		Если Контекст.ФайлДанные.Свойство("Валюта_КодОКВ") и Контекст.ФайлДанные.Свойство("ВалютаУчета_КодОКВ") Тогда
			Контекст.ФайлДанные.Валюта_КодОКВ = Контекст.ФайлДанные.ВалютаУчета_КодОКВ;
		КонецЕсли;
	КонецЕсли;
	
	ЦенаВключаетНДС = Кэш.ОбщиеФункции.РассчитатьЗначение("ЦенаВключаетНДС", Контекст.ФайлДанные,Кэш);
	Если Не ЗначениеЗаполнено(ЦенаВключаетНДС) Тогда
		ЦенаВключаетНДС = СуммаВключаетНДС;
	КонецЕсли;
	
	сч=1;
	Для Каждого Параметр Из Контекст.ФайлДанные.мТаблДок Цикл
		// Чтобы одна и та же табличная часть не попадала 2 раза в документ (в СФ, если по документу-основанию формируются дополнительные файлы)
		Если Контекст.Свойство("СписокТЧ") Тогда  
			Если Контекст.СписокТЧ.НайтиПоЗначению(Параметр.Ключ)<>Неопределено Тогда
				Продолжить;
			Иначе
				Контекст.СписокТЧ.Добавить(Параметр.Ключ);
			КонецЕсли;
		КонецЕсли;		
		
		Если ТипЗнч(Параметр.Значение) = Тип("Массив") Тогда    // стандартная табличная часть
			ТабЧастьДокумента = Параметр.Значение;
		ИначеЕсли ТипЗнч(Параметр.Значение) = Тип("Структура") и Лев(Параметр.Значение.ТаблДок,1)<>"{" Тогда  // табличная часть из одной строки, которая заполняется прямо из реквизитов документа
			ТабЧастьДокумента = Новый Массив;
			ТабЧастьДокумента.Добавить(Параметр.Значение);
		Иначе   // табличная часть вычисляется с помощью функции
			Кэш.ОбщиеФункции.сбисСкопироватьСтруктуруНаКлиенте(Контекст.ФайлДанные, Параметр.Значение);
			ТабЧастьДокумента = Кэш.ОбщиеФункции.РассчитатьЗначение("ТаблДок", Контекст.ФайлДанные, Кэш);
		КонецЕсли;
		
		Если ТипЗнч(ТабЧастьДокумента) = Тип("Массив") Тогда
			Для Каждого Стр Из ТабЧастьДокумента Цикл
				//Если Кэш.Парам.ОтправлятьНоменклатуруСДокументами = Истина и Кэш.Ини.Свойство("Номенклатура") Тогда
				//	Номенклатура = Кэш.ОбщиеФункции.РассчитатьЗначение("Номенклатура", Стр, Кэш);
				//	Если Кэш.СписокНоменклатуры.НайтиПоЗначению(Номенклатура) = Неопределено Тогда
				//		Кэш.СписокНоменклатуры.Добавить(Номенклатура);
				//	КонецЕсли;
				//КонецЕсли;
				ДобавлятьСтроку = ?(Стр.Свойство("ДобавлятьСтроку"),Стр.ДобавлятьСтроку,Истина);
				Стр.Вставить("РеквизитСопоставленияНоменклатуры", Кэш.Парам.РеквизитСопоставленияНоменклатуры);
				Стр.Вставить("СуммаВключаетНДС",СуммаВключаетНДС);
				Стр.Вставить("КодыМаркировки", КодыМаркировки);
				Стр.Вставить("ПредКодыМаркировки", ПредКодыМаркировки);
				НоваяСтрока = Новый Структура;
				Кэш.ОбщиеФункции.ЗаполнитьАтрибуты(Кэш,"ТаблДок",Стр,НоваяСтрока);
				НоваяСтрока.Вставить("ПорНомер",Формат(сч, "ЧГ=0")); 
				СуммаНДС = Кэш.ОбщиеФункции.РассчитатьЗначение("СуммаНДС", Стр, Кэш);
				Попытка
					СуммаНДС = Число(СуммаНДС);
				Исключение
					СуммаНДС = 0;
				КонецПопытки;
				Если НоваяСтрока.Свойство("Сумма") и СуммаВключаетНДС<>Неопределено Тогда
				Попытка
					НоваяСтрока.Сумма = Число(НоваяСтрока.Сумма);
				Исключение
					НоваяСтрока.Сумма = 0;
				КонецПопытки;
				НоваяСтрока.Вставить("СуммаБезНал",формат(НоваяСтрока.Сумма - ?(СуммаВключаетНДС, СуммаНДС, 0), "ЧЦ=17; ЧДЦ=2; ЧРД=.; ЧГ=0; ЧН=0.00"));
				// d.ch 20.02.19 Для налоговой ставки "НДС исчисляется налоговым агентом" обнуляем сумму с учетом НДС
				Если СбисНДСИсчисляетсяАгентом Тогда
					НоваяСтрока.Сумма = "0.00";
				Иначе 
					НоваяСтрока.Сумма = формат(Число(НоваяСтрока.Сумма) + ?(СуммаВключаетНДС, 0, СуммаНДС), "ЧЦ=17; ЧДЦ=2; ЧРД=.; ЧГ=0; ЧН=0.00");
				КонецЕсли;
				КонецЕсли;
				Если Стр.Свойство("СуммаАкциз") и ЗначениеЗаполнено(Стр.СуммаАкциз) Тогда
					НоваяСтрока.Вставить("Акциз",Новый Структура);
					НоваяСтрока.Акциз.Вставить("Сумма", Кэш.ОбщиеФункции.РассчитатьЗначение("СуммаАкциз", Стр, Кэш));	
				КонецЕсли;
				Если Стр.Свойство("СуммаНДС") Тогда
					НоваяСтрока.Вставить("НДС",Новый Структура);
					фрм = Кэш.ГлавноеОкно.сбисНайтиФормуФункции("ЗначениеИТипСтавки","РаботаСДокументами1С","",Кэш);
					СтрСтавка = фрм.ЗначениеИТипСтавки(Стр.СтавкаНДС);
					НоваяСтрока.НДС.Вставить( "Сумма", формат(СуммаНДС, "ЧЦ=17; ЧДЦ=2; ЧРД=.; ЧГ=0; ЧН=0.00"));	
					НоваяСтрока.НДС.Вставить( "Ставка", СтрСтавка.Ставка);	
					НоваяСтрока.НДС.Вставить( "ТипСтавки", СтрСтавка.ТипСтавки);	
				КонецЕсли;
				
				Если Стр.Свойство("мПараметр") Тогда
					НоваяСтрока.Вставить("Параметр", Новый Массив);
					Для Каждого Элемент Из Стр.мПараметр Цикл
						Кэш.ОбщиеФункции.сбисСкопироватьСтруктуруНаКлиенте(Стр,Элемент.Значение);
						Параметр = Новый Структура();
						Кэш.ОбщиеФункции.ЗаполнитьАтрибуты(Кэш,"Параметр",Стр,Параметр);
						НоваяСтрока.Параметр.Добавить(Параметр);
					КонецЦикла;
				КонецЕсли;
				
				Если Стр.Свойство("НомСредИдентТов") Тогда
					НомСредИдентТов = Кэш.ОбщиеФункции.РассчитатьЗначение("НомСредИдентТов", Стр, Кэш); 
					КодыМаркировки = Стр.КодыМаркировки; 
					НоваяСтрока.Вставить("НомСредИдентТов", НомСредИдентТов);
				КонецЕсли;
				
				Если	Стр.Свойство("мСведПрослеж")
					И	Стр.мСведПрослеж.Свойство("СведПрослежРасчет") Тогда
					КонтекстРасчета = Кэш.ОбщиеФункции.СкопироватьОбъектСПараметрамиКлиент(Стр.мСведПрослеж.СведПрослежРасчет,,Ложь);
					КонтекстРасчета.Вставить("мСведПрослеж", Стр.мСведПрослеж);
					Стр.мСведПрослеж = Новый Структура("СведПрослеж", Кэш.ОбщиеФункции.РассчитатьЗначение("СведПрослеж", КонтекстРасчета, Кэш));
				КонецЕсли;				
				
				//KES МОТП ИСМП-->
				//перебрать все свойства строки и найти сложные узлы
				мСложныеУзлы = Новый Массив;
				Для Каждого Элемент Из Стр Цикл
					Если ТипЗнч(Элемент.Значение) = Тип("Структура")
						И	Не (	Элемент.Ключ = "мПараметр"
								Или	Элемент.Ключ = "ПредСтрТабл_СведПрослеж") Тогда
						ОбработатьСложныйУзел(Элемент.Значение,Стр,НоваяСтрока,Кэш);
					КонецЕсли;
				КонецЦикла;
				//<--KES МОТП ИСМП
				
				Если Стр.Свойство("ПредСтрТабл") Тогда
					Если сч = 1 Тогда  
						Контекст.Вставить("ЕстьПредыдущиеДанные", Истина);
					КонецЕсли;
					//В строку должны быть заполнены все простые узлы заранее (которые добавляются кодом), чтобы при заполнении они выгружались в случае наличия составных узлов в ини
					ПредыдущиеДанные = Новый Структура("СуммаБезНал");
					
					Кэш.ОбщиеФункции.ЗаполнитьАтрибуты(Кэш,"ПредСтрТабл",Стр,ПредыдущиеДанные);
					СуммаНДСДо = Кэш.ОбщиеФункции.РассчитатьЗначение("СуммаНДСДо", Стр, Кэш);
					СуммаНДСДо = Число(СуммаНДСДо);
					ПредыдущиеДанные.СуммаБезНал = формат(Число(ПредыдущиеДанные.Сумма) - ?(СуммаВключаетНДС, СуммаНДСДо, 0), "ЧЦ=17; ЧДЦ=2; ЧРД=.; ЧГ=0; ЧН=0.00");
					Если СбисНДСИсчисляетсяАгентом Тогда
						ПредыдущиеДанные.Сумма = "0.00";
					Иначе 
						ПредыдущиеДанные.Сумма = формат(Число(ПредыдущиеДанные.Сумма) + ?(СуммаВключаетНДС, 0, СуммаНДСДо), "ЧЦ=17; ЧДЦ=2; ЧРД=.; ЧГ=0; ЧН=0.00");
					КонецЕсли;
					Если Стр.Свойство("СуммаАкцизДо") и ЗначениеЗаполнено(Стр.СуммаАкцизДо) Тогда
						ПредыдущиеДанные.Вставить("Акциз",Новый Структура);
						ПредыдущиеДанные.Акциз.Вставить( "Сумма", Стр.СуммаАкцизДо);	
					КонецЕсли;
					ПредыдущиеДанные.Вставить("НДС",Новый Структура);
					фрм = Кэш.ГлавноеОкно.сбисНайтиФормуФункции("ЗначениеИТипСтавки","РаботаСДокументами1С","", Кэш);
					СтрСтавка = фрм.ЗначениеИТипСтавки(Стр.СтавкаНДСДо);
					ПредыдущиеДанные.НДС.Вставить( "Сумма", формат(СуммаНДСДо, "ЧЦ=17; ЧДЦ=2; ЧРД=.; ЧН=0.00; ЧГ=0; ЧО=1"));	
					ПредыдущиеДанные.НДС.Вставить( "Ставка", СтрСтавка.Ставка);	
					ПредыдущиеДанные.НДС.Вставить( "ТипСтавки", СтрСтавка.ТипСтавки);
					
					Если Стр.Свойство("ПредНомСредИдентТов") Тогда
						ПредНомСредИдентТов = Кэш.ОбщиеФункции.РассчитатьЗначение("ПредНомСредИдентТов", Стр, Кэш);
						ПредыдущиеДанные.Вставить("НомСредИдентТов", ПредНомСредИдентТов);
					КонецЕсли;
					
					НоваяСтрока.Вставить("ПредСтрТабл",ПредыдущиеДанные);
					Контекст.ПредИтогСумма       	= Контекст.ПредИтогСумма + ПредыдущиеДанные.Сумма;
					Контекст.ПредИтогСуммаБезНалога = Контекст.ПредИтогСуммаБезНалога + ПредыдущиеДанные.СуммаБезНал;
					Контекст.ПредИтогСуммаНДС    	= Контекст.ПредИтогСуммаНДС + СуммаНДСДо;
				КонецЕсли;				
				
				Если Стр.Свойство("Расхождения") Тогда
					НоваяСтрока.Вставить("Расхождения", Новый Массив);
					Для Каждого Элемент Из Стр.Расхождения Цикл
						Кэш.ОбщиеФункции.сбисСкопироватьСтруктуруНаКлиенте(Стр,Элемент);
						Расхождение = Новый Структура();
						Кэш.ОбщиеФункции.ЗаполнитьАтрибуты(Кэш,"Расхождения",Стр,Расхождение);
						НоваяСтрока.Расхождения.Добавить(Расхождение);
					КонецЦикла;	
				КонецЕсли;
				
				// при необходимости пересчитываем в валюту учета
				Если ПересчитатьВВалютеУчета = Истина Тогда
					Если НЕ ЗначениеЗаполнено(ИтогСумма) Тогда   // есть готовые суммы по каждой строке и не надо распределять общую сумму по строкам
						CуммаДляПересчета = Кэш.ОбщиеФункции.РассчитатьЗначение("CуммаДляПересчета", Стр, Кэш); 
						CуммаНДСДляПересчета = Кэш.ОбщиеФункции.РассчитатьЗначение("CуммаНДСДляПересчета", Стр, Кэш); 
						Попытка
							СуммаВВалютеУчета = CуммаДляПересчета*КурсВзаиморасчетов/?(КратностьВзаиморасчетов=0,1,КратностьВзаиморасчетов);
							СуммаНДСВВалютеУчета = CуммаНДСДляПересчета*КурсВзаиморасчетов/?(КратностьВзаиморасчетов=0,1,КратностьВзаиморасчетов);
							СуммаНДС = СуммаНДСВВалютеУчета;
							НоваяСтрока.СуммаБезНал = формат(СуммаВВалютеУчета - ?(СуммаДляПересчетаВключаетНДС, СуммаНДСВВалютеУчета, 0), "ЧЦ=17; ЧДЦ=2; ЧРД=.; ЧГ=0; ЧН=0.00");
							Если Не СбисНДСИсчисляетсяАгентом Тогда
								НоваяСтрока.Сумма = формат(Число(СуммаВВалютеУчета) + ?(СуммаДляПересчетаВключаетНДС, 0, СуммаНДСВВалютеУчета), "ЧЦ=17; ЧДЦ=2; ЧРД=.; ЧГ=0; ЧН=0.00");
								НоваяСтрока.НДС.Сумма = формат(СуммаНДСВВалютеУчета, "ЧЦ=17; ЧДЦ=2; ЧРД=.; ЧГ=0; ЧН=0.00");
							КонецЕсли;
							Если НЕ (НоваяСтрока.Свойство("Цена") И Число(НоваяСтрока.Цена) = 0) Тогда
								НоваяСтрока.Вставить("Цена", формат(Число(НоваяСтрока.СуммаБезНал)/?(Число(НоваяСтрока.Кол_во)=0,1,Число(НоваяСтрока.Кол_во)), "ЧЦ=17; ЧДЦ=2; ЧРД=.; ЧГ=0; ЧН=0.00"));
							КонецЕсли;
							Если НоваяСтрока.Свойство("Параметр") Тогда
								Для каждого мПараметр Из НоваяСтрока.Параметр Цикл
									Если мПараметр.Имя = "Цена1С" Тогда
										мПараметр.Значение = формат(Число(?(ЦенаВключаетНДС, НоваяСтрока.Сумма, НоваяСтрока.СуммаБезНал))/?(Число(НоваяСтрока.Кол_во)=0,1,Число(НоваяСтрока.Кол_во)), "ЧЦ=17; ЧДЦ=2; ЧРД=.; ЧГ=0; ЧН=0.00");	
									КонецЕсли;
								КонецЦикла;
							КонецЕсли;
						Исключение
						КонецПопытки;
					КонецЕсли;
				КонецЕсли;
				
				СтруктураУпаковка = Новый Структура;
				Кэш.ОбщиеФункции.ЗаполнитьАтрибуты(Кэш,"Упаковка",Стр,СтруктураУпаковка);
				Если СтруктураУпаковка.Количество()>0 Тогда
					НоваяСтрока.Вставить("Упаковка",СтруктураУпаковка);
				КонецЕсли;
				
				СтруктураБрутто = Новый Структура;
				Кэш.ОбщиеФункции.ЗаполнитьАтрибуты(Кэш,"Брутто",Стр,СтруктураБрутто);
				Если СтруктураБрутто.Количество()>0 Тогда
					НоваяСтрока.Вставить("Брутто",СтруктураБрутто);
				КонецЕсли;
				
				СтруктураНетто = Новый Структура;
				Кэш.ОбщиеФункции.ЗаполнитьАтрибуты(Кэш,"Нетто",Стр,СтруктураНетто);
				Если СтруктураНетто.Количество()>0 Тогда
					НоваяСтрока.Вставить("Нетто",СтруктураНетто);
				КонецЕсли;
				
				СтруктураХарактеристика = Новый Структура;
				Кэш.ОбщиеФункции.ЗаполнитьАтрибуты(Кэш,"Характеристика",Стр,СтруктураХарактеристика);
				Если СтруктураХарактеристика.Количество()>0 Тогда
					НоваяСтрока.Вставить("Характеристика",СтруктураХарактеристика);
				КонецЕсли;
				
				фрм = Кэш.ГлавноеОкно.сбисНайтиФормуФункции("сбисПослеФормированияСтроки","Файл_"+Кэш.ОбщиеФункции.сбисЗаменитьНедопустимыеСимволы(Контекст.ФайлДанные.Файл_Формат)+"_"+Кэш.ОбщиеФункции.сбисЗаменитьНедопустимыеСимволы(Контекст.ФайлДанные.Файл_ВерсияФормата),"Файл_Шаблон", Кэш);
				Если фрм<>Ложь Тогда
					ДобавлятьСтроку = фрм.сбисПослеФормированияСтроки(НоваяСтрока, Кэш, Контекст, Стр);	
				КонецЕсли;
				Если ДобавлятьСтроку<>Ложь Тогда      // <>Ложь написано для совместимости со старыми функциями сбисПослеФормированияСтроки, которые могли ничего не возвращать
					
					Попытка
						Контекст.ИтогКоличество     = Контекст.ИтогКоличество + НоваяСтрока.Кол_во;
					Исключение
					КонецПопытки;
					Попытка
					Контекст.ИтогСумма       	= Контекст.ИтогСумма + НоваяСтрока.Сумма;
					Контекст.ИтогСуммаБезНалога = Контекст.ИтогСуммаБезНалога + НоваяСтрока.СуммаБезНал;
					Если НоваяСтрока.Свойство("НДС") Тогда
						Контекст.ИтогСуммаНДС    	= Контекст.ИтогСуммаНДС + НоваяСтрока.НДС.Сумма;
					КонецЕсли;
					Исключение
					КонецПопытки;
					Попытка
						Контекст.ИтогБрутто         = Контекст.ИтогБрутто + ?(НоваяСтрока.Брутто.Свойство("Кол_во"),НоваяСтрока.Брутто.Кол_во, 0);
					Исключение
					КонецПопытки;
					Попытка
						Контекст.ИтогНетто         = Контекст.ИтогНетто + ?(НоваяСтрока.Нетто.Свойство("Кол_во"),НоваяСтрока.Нетто.Кол_во, 0);
					Исключение
					КонецПопытки;
					Попытка
						Контекст.ИтогКолМест 	    = Контекст.ИтогКолМест + ?(НоваяСтрока.Упаковка.Свойство("КолМест"),НоваяСтрока.Упаковка.КолМест, 0);
					Исключение
					КонецПопытки;
					
					Контекст.ТаблДок.СтрТабл.Добавить(НоваяСтрока);
					сч=сч+1;
					Если НоваяСтрока.Свойство("Тип") Тогда
						УказанТипНоменклатуры = Истина;
						Если НоваяСтрока.Тип = "1" Тогда
							КолТоваров = КолТоваров+1;
						КонецЕсли;
					КонецЕсли;
				КонецЕсли;
				
				// При необходимости проверяем, вся ли номенклатура сопоставлена
				Если Контекст.Свойство("НоменклатураКодКонтрагента") и (Не НоваяСтрока.Свойство(Контекст.НоменклатураКодКонтрагента) или Не ЗначениеЗаполнено(НоваяСтрока[Контекст.НоменклатураКодКонтрагента]))  Тогда
					Контекст.СоставПакета.Вставить("Ошибка","Не вся номенклатура сопоставлена");	
				КонецЕсли;
			КонецЦикла;
		КонецЕсли;
	КонецЦикла;
	Если Контекст.ФайлДанные.Свойство("ЗаполнятьГрузотпрГрузполуч") Тогда
		Контекст.Вставить("ЗаполнятьГрузотпрГрузполуч", Контекст.ФайлДанные.ЗаполнятьГрузотпрГрузполуч);
	ИначеЕсли УказанТипНоменклатуры = Ложь или (УказанТипНоменклатуры и КолТоваров>0) Тогда
		Контекст.Вставить("ЗаполнятьГрузотпрГрузполуч", Истина);
	Иначе
		Контекст.Вставить("ЗаполнятьГрузотпрГрузполуч", Ложь);
	КонецЕсли;
	
	фрм = Кэш.ГлавноеОкно.сбисНайтиФормуФункции("СбисПослеФормированияТабличнойЧасти","Файл_"+Кэш.ОбщиеФункции.сбисЗаменитьНедопустимыеСимволы(Контекст.ФайлДанные.Файл_Формат)+"_"+Кэш.ОбщиеФункции.сбисЗаменитьНедопустимыеСимволы(Контекст.ФайлДанные.Файл_ВерсияФормата),"Файл_Шаблон", Кэш);
	Если Не фрм = Ложь Тогда
		фрм.СбисПослеФормированияТабличнойЧасти(Кэш, Контекст, Новый Структура("ТаблДок, ПересчитатьВВалютеУчета, ИтогСумма", Контекст.ТаблДок, ПересчитатьВВалютеУчета=Истина, ИтогСумма));	
	КонецЕсли;	
КонецФункции	

// Функция - Сформировать табличную часть по набору сопоставлений номенклатуры
//
// Параметры:
//  НаборСопоставленийНоменклатуры	 - Структура	 - Содержит 
//	                                 - 
//  ДопПараметры					 - Структура	 - Брать направление и если исходящий, то схлопнуть ТаблДок по номенклатуре СБИС. Схлопнуть Да/Нет
// 
// Возвращаемое значение:
// Массив  - Подготовленные для загрузки/выгрузки строки табличной части документа 1С
//
&НаКлиенте
Функция СформироватьТабличнуюЧастьПоНаборуСопоставленийНоменклатуры(НаборСопоставленийНоменклатуры, ДопПараметры = Неопределено) Экспорт
	
	// Сделать списочный и точечный методы класса для получения значений свойств
	
	// Инициализация локальных переменных
	ИндексСтрокиНоменклатурыСБИС = 0;  
	РассчитаннаяСтрокаТЧ = Новый Структура; 
	ТаблДокОбработанный = Новый Массив;
	ПорядковыйНомер = 1;
	
	// Входящие параметры
	НаборСопоставлений 	  = НаборСопоставленийНоменклатуры.НаборСопоставлений;
	ТабличнаяЧастьИзФайла = НаборСопоставленийНоменклатуры.ТабличнаяЧасть;
	
	Для Каждого Сопоставление Из НаборСопоставлений Цикл
		
		Для Каждого СтрокаНоменклатуры1С Из Сопоставление.Номенклатура1С Цикл
			
			Номенклатура1С = СтрокаНоменклатуры1С.Значение;
			Если НЕ ЗначениеЗаполнено(Номенклатура1С.Кол_во) Тогда
				Продолжить;
			КонецЕсли;
			
			ЛокальныйКэш = МодульОбъектаКлиент().ПолучитьТекущийЛокальныйКэш();
			РассчитаннаяСтрокаТЧ = ЛокальныйКэш.ТекущийСеанс.Модули.ФункцииДокументов.СбисСкопироватьОбъектНаКлиенте(ТабличнаяЧастьИзФайла[ИндексСтрокиНоменклатурыСБИС]);
			РассчитаннаяСтрокаТЧ.Вставить("Номенклатура");
			
			СписокСвойствНаЗаполнение = Новый Массив;
			
			Для Каждого Элемент Из РассчитаннаяСтрокаТЧ Цикл
				СписокСвойствНаЗаполнение.Добавить(Элемент.Ключ);
			КонецЦикла;
			
			ИндексУдаляемогоЭлемента = СписокСвойствНаЗаполнение.Найти("ОКЕИ");
			Если НЕ ИндексУдаляемогоЭлемента = Неопределено Тогда
				СписокСвойствНаЗаполнение.Удалить(ИндексУдаляемогоЭлемента);
			КонецЕсли;
			
			ИндексУдаляемогоЭлемента = СписокСвойствНаЗаполнение.Найти("Коэффициент");
			Если НЕ ИндексУдаляемогоЭлемента = Неопределено Тогда
				СписокСвойствНаЗаполнение.Удалить(ИндексУдаляемогоЭлемента);
			КонецЕсли;
			
			ВыгруженнаяНоменклатуры1С = МодульОбъектаКлиент().ОписаниеНоменклатуры1СКлиент_Получить(Номенклатура1С, СписокСвойствНаЗаполнение);
			
			Если НЕ ДопПараметры.СвернутьСтроки Тогда
				ЗаполнитьЗначенияСвойств(РассчитаннаяСтрокаТЧ, ВыгруженнаяНоменклатуры1С);
			 
				РассчитаннаяСтрокаТЧ.Название = ПолучитьИмяНоменклатурыПоСсылкеКлиент(РассчитаннаяСтрокаТЧ.Номенклатура);
						
				НомерСтрокиТЧ = ПорядковыйНомер - 1;
			
				Если РассчитаннаяСтрокаТЧ.Свойство("ПорНомер") Тогда
					РассчитаннаяСтрокаТЧ.ПорНомер = ПорядковыйНомер; 
				КонецЕсли;
			
				ТаблДокОбработанный.Добавить(РассчитаннаяСтрокаТЧ);                 
			
				ПорядковыйНомер = ПорядковыйНомер + 1;
			ИначеЕсли ДопПараметры.СвернутьСтроки 
				И ДопПараметры.НаправлениеСворачивания = "СБИС" Тогда
				СложитьДанныеНоменклатур1С(РассчитаннаяСтрокаТЧ, ВыгруженнаяНоменклатуры1С); 
			Иначе
				СложитьДанныеНоменклатурСбис(РассчитаннаяСтрокаТЧ, ВыгруженнаяНоменклатуры1С);
			КонецЕсли;
		КонецЦикла;
		ИндексСтрокиНоменклатурыСБИС = ИндексСтрокиНоменклатурыСБИС + 1;
	КонецЦикла; 
	
	Возврат ТаблДокОбработанный;	
	
КонецФункции

&НаСервере
Функция ПолучитьИмяНоменклатурыПоСсылкеКлиент(Ссылка)
	Возврат МодульОбъектаСервер().ПолучитьИмяНоменклатурыПоСсылкеСервер(Ссылка);
КонецФункции

&НаКлиенте
Процедура СложитьДанныеНоменклатур1С(Приемник, Источник)
	
	СписокСвойств = Новый Массив;
	СписокСвойств.Добавить("Кол_во");
	СписокСвойств.Добавить("Сумма");
	СписокСвойств.Добавить("НДС.Сумма");
	СписокСвойств.Добавить("ЦенаБезНДС");
	
	
	Для Каждого Ключ Из СписокСвойств Цикл
		
		Если Ключ = "СуммаНДС" Тогда
			Приемник.НДС.Сумма = Приемник.НДС.Сумма + Источник.НДС.Сумма;
		Иначе
			Приемник[Ключ] = Приемник[Ключ] + Источник[Ключ];	
		КонецЕсли;
		
	КонецЦикла;
	
КонецПроцедуры

&НаКлиенте
Процедура СложитьДанныеНоменклатурСбис(Приемник, Источник)
	
	// В душе не чаю что тут нужно делать, так что это пока заглушка (с) Сыч
	Возврат;
	
КонецПроцедуры

#Область include_core2_vo2_Файл_Шаблон_ПолучитьТабличнуюЧастьДокумента1С_ШтатныеОбработчикиТочекВхода
#КонецОбласти

#Область include_core2_vo2_Файл_Шаблон_ПолучитьТабличнуюЧастьДокумента1С_Прочее
#КонецОбласти

