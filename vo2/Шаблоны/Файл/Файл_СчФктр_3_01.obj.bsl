
#Область include_local_ПолучитьМодульОбъекта
#КонецОбласти

&НаКлиенте
Функция ПолучитьДанныеИзДокумента1С(Кэш, Контекст) Экспорт
	// Функция формирует структуру табличной части файла СФ по документам-основаниям
	Попытка	
		// проверяем надо ли пересчитывать суммы в валюту учета
		Валюта = Кэш.ОбщиеФункции.РассчитатьЗначение("Валюта", Контекст.ФайлДанные,Кэш);
		ВалютаУчета = Кэш.ОбщиеФункции.РассчитатьЗначение("ВалютаУчета", Контекст.ФайлДанные,Кэш);
		Если ЗначениеЗаполнено(Валюта) и ЗначениеЗаполнено(ВалютаУчета) и Валюта<>ВалютаУчета Тогда
			ПересчитатьВВалютеУчета = Кэш.ОбщиеФункции.РассчитатьЗначение("ПересчитатьВВалютеУчета", Контекст.ФайлДанные,Кэш);
		Иначе
			ПересчитатьВВалютеУчета = Ложь;
		КонецЕсли;
		Если ПересчитатьВВалютеУчета=Истина Тогда
			Если Контекст.ФайлДанные.Свойство("Валюта_КодОКВ") и Контекст.ФайлДанные.Свойство("ВалютаУчета_КодОКВ") Тогда
				Контекст.ФайлДанные.Валюта_КодОКВ = Контекст.ФайлДанные.ВалютаУчета_КодОКВ;
			КонецЕсли;
		КонецЕсли;
	
		Контекст.Вставить("ТаблДок",Новый Структура());
		Контекст.ТаблДок.Вставить("ИтогТабл",Новый Массив);
		Контекст.ТаблДок.Вставить("СтрТабл",Новый Массив);
		Контекст.Вставить("ИтогСумма",0);
		Контекст.Вставить("ИтогСуммаБезНалога",0);
		Контекст.Вставить("ИтогСуммаНДС",0);
		Контекст.Вставить("ИтогКоличество",0);
		Контекст.Вставить("ИтогБрутто",0);
		Контекст.Вставить("ИтогНетто",0);
		Контекст.Вставить("ИтогКолМест",0);
		
		Контекст.Вставить("ПредИтогСумма",0);
		Контекст.Вставить("ПредИтогСуммаБезНалога",0);
		Контекст.Вставить("ПредИтогСуммаНДС",0);

		Контекст.Вставить("НДСИсчисляетсяАгентом", Кэш.ОбщиеФункции.РассчитатьЗначение("НДСИсчисляетсяАгентом", Контекст.ФайлДанные) = Истина);
		Документ = Контекст.Документ;
		ини = Контекст.ФайлДанные;
		
		УказанТипНоменклатуры = Ложь;
		КолТоваров = 0;
		сч = 1;
		счСвернутых = 1;
    		
		Для Каждого Параметр Из Контекст.ФайлДанные.мТаблДок Цикл
			
			ТабЧасть = Новый Массив;
			Если ТипЗнч(Параметр.Значение)=Тип("Массив") Тогда
				ТабЧасть = Параметр.Значение	
			Иначе
				ТабЧасть.Добавить(Параметр.Значение); // если у СФ только 1 основание
			КонецЕсли;
			МассивИд = Новый Массив;
			// Перебираем документы-основания, из каждого добавляем табличную часть в СФ
			Для Каждого ДокОсн Из ТабЧасть Цикл
				ДокОснование = ДокОсн.ТаблДок_ДокументОснование;
				ИмяДокумента = Кэш.ОбщиеФункции.ПолучитьРеквизитМетаданныхОбъекта(ДокОснование, "Имя");
				ИниДокумента = ИмяДокумента;
				Попытка
					Если Кэш.ФормаНастроек.Ини(Кэш, Кэш.Текущий.ТипДок).Свойство(ИниДокумента) Тогда
						ИниДокумента = Кэш.ОбщиеФункции.РассчитатьЗначение(ИмяДокумента,Кэш.ФормаНастроек.Ини(Кэш, Кэш.Текущий.ТипДок),Кэш);
					КонецЕсли;
				Исключение
				КонецПопытки;
				Если Контекст.ДокументДанные.Свойство(ИмяДокумента) Тогда
					ИниДокумента = Кэш.ОбщиеФункции.РассчитатьЗначение(ИмяДокумента,Контекст.ДокументДанные,Кэш);
				КонецЕсли;
				Если Не Кэш.ини.Свойство(ИниДокумента) Тогда
					Сообщить("Основанием документа "+строка(Контекст.Документ)+" является "+строка(ДокОснование)+". Отсутствует настройка для формирования электронных документов данного типа.");
					Возврат Ложь;
				КонецЕсли;
				ДокументДанные = Неопределено;
				// Проверяем, есть ли в кэше по пакету данные по документу-основанию
				Если Кэш.КэшЗначенийИни.ТекущийПакет.Свойство("СоответствиеДокументДанные") Тогда
					КэшПоОснованию = Кэш.КэшЗначенийИни.ТекущийПакет.СоответствиеДокументДанные.Получить(ДокОснование);
					Если КэшПоОснованию <> Неопределено и КэшПоОснованию.ИмяИни = ИниДокумента Тогда
						ДокументДанные = КэшПоОснованию.ДокументДанные;
					КонецЕсли;
				КонецЕсли;
				Если ДокументДанные = Неопределено Тогда
					ВходящийКонтекстРасчета = Новый Структура;
					ЗначениеИни = Кэш.ФормаНастроек.Ини(Кэш, ИниДокумента);
					ЗначениеИни.Вставить("Формат2016", Новый Структура("Значение,РассчитанноеЗначение", Истина, Истина));
					ЗначениеИни.Вставить("Формат2019", Новый Структура("Значение,РассчитанноеЗначение", Истина, Истина));
					ЗначениеИни.Вставить("ФорматУКД2020", Новый Структура("Значение,РассчитанноеЗначение", Истина, Истина));
					ЗначениеИни.Вставить("ВходящийКонтекст", Новый Структура("Значение,РассчитанноеЗначение", "", ВходящийКонтекстРасчета));
					ЗначениеИни.Вставить("ИспользоватьШтрихкодыНоменклатурыКонтрагентов",	Новый Структура("Значение,РассчитанноеЗначение", Кэш.Парам.ИспользоватьШтрихкодыНоменклатурыКонтрагентов, Кэш.Парам.ИспользоватьШтрихкодыНоменклатурыКонтрагентов));
					ДокументДанные = Кэш.ОбщиеФункции.ПолучитьДанныеДокумента1С(ЗначениеИни, ДокОснование, Кэш.КэшЗначенийИни, Кэш.Парам);  // alo Меркурий
				КонецЕсли;
				ВременныйКонтекст = Новый Структура();
				ВременныйКонтекст.Вставить("СФ",Контекст.ФайлДанные.Документ);
				ВременныйКонтекст.Вставить("Документ",ДокОснование);
				ВременныйКонтекст.Вставить("ДокументДанные", ДокументДанные);
				ВременныйКонтекст.Вставить("ФайлДанные", Новый Структура);
				ВременныйКонтекст.Вставить("ИтогСумма",0);
				ВременныйКонтекст.Вставить("ИтогСуммаБезНалога",0);
				ВременныйКонтекст.Вставить("ИтогСуммаНДС",0);
				ВременныйКонтекст.Вставить("ИтогКоличество",0);
				ВременныйКонтекст.Вставить("ИтогБрутто",0);
				ВременныйКонтекст.Вставить("ИтогНетто",0);
				ВременныйКонтекст.Вставить("ИтогКолМест",0);
				ВременныйКонтекст.Вставить("ПредИтогСумма",0);
				ВременныйКонтекст.Вставить("ПредИтогСуммаБезНалога",0);
				ВременныйКонтекст.Вставить("ПредИтогСуммаНДС",0);
				ВременныйКонтекст.Вставить("ТаблДок",Новый Структура());
				ВременныйКонтекст.ТаблДок.Вставить("СтрТабл",Новый Массив);
				
				//Подменяем во временном контексте признак необходимости пересчета в валюту, т.к. для фактуры и накладной он может отличаться
				Для Каждого Файл Из ВременныйКонтекст.ДокументДанные.мФайл Цикл
					Файл = Файл.Значение;
					Если Файл.Свойство("ПересчитатьВВалютеУчета") Тогда
						Файл.ПересчитатьВВалютеУчета = ПересчитатьВВалютеУчета;
					КонецЕсли;
				КонецЦикла;
				
				фрм = Кэш.ГлавноеОкно.сбисНайтиФормуФункции("ПрочитатьТабличнуюЧасть","Документ_"+ИмяДокумента,"Документ_Шаблон",Кэш);
				Если не фрм.ПрочитатьТабличнуюЧасть(Кэш,ВременныйКонтекст) Тогда
					Возврат Ложь;
				КонецЕсли;
				
				Для Каждого Строка Из ВременныйКонтекст.ТаблДок.СтрТабл Цикл
					Если Строка.Свойство("Тип") Тогда
						УказанТипНоменклатуры = Истина;
						Если Строка.Тип = "1" Тогда
							КолТоваров = КолТоваров+1;
						КонецЕсли;
					КонецЕсли;
					
					Если Контекст.ФайлДанные.Свойство("СвернутьКолонкиГруппировок") и Контекст.ФайлДанные.Свойство("СвернутьКолонкиСуммирования") Тогда
						//Если есть задача свернуть колонки, то сформируем ключ поиска
						МассивКолонок = Кэш.ОбщиеФункции.РазбитьСтрокуВМассивНаКлиенте(Контекст.ФайлДанные.СвернутьКолонкиГруппировок, ",");
						ИдСтроки = "";
						Для каждого ИмяКолонки из МассивКолонок Цикл
							ПозТочки = Найти(ИмяКолонки, ".");
							Если ПозТочки > 0 Тогда
								ИдСтроки = ИдСтроки + Строка[Лев(ИмяКолонки, ПозТочки - 1)][Сред(ИмяКолонки, ПозТочки + 1)];
							Иначе	
								ИдСтроки = ИдСтроки + СокрЛП(Строка[ИмяКолонки]);
							КонецЕсли;	
						КонецЦикла;
						ИндексМассива = МассивИд.Найти(ИдСтроки);
						Если ИндексМассива = Неопределено  Тогда //Если не нашли по индексу добавляем всю стр целиком							
							Строка.Вставить("ПорНомер",Формат(счСвернутых, "ЧГ=0"));
							Контекст.ТаблДок.СтрТабл.Добавить(Строка);
							МассивИд.Добавить(ИдСтроки);  
							счСвернутых = счСвернутых + 1;
						Иначе
							НайденаяСтрока = Контекст.ТаблДок.СтрТабл[ИндексМассива];
							//иначе суммируем необходимые значения
							МассивКолонок = Кэш.ОбщиеФункции.РазбитьСтрокуВМассивНаКлиенте(Контекст.ФайлДанные.СвернутьКолонкиСуммирования, ",");
							Для каждого ИмяКолонки из МассивКолонок Цикл
								ПозТочки = Найти(ИмяКолонки, ".");
								Если ПозТочки > 0 Тогда
									НайденаяСтрока[Лев(ИмяКолонки, ПозТочки - 1)][Сред(ИмяКолонки, ПозТочки + 1)] = Число(НайденаяСтрока[Лев(ИмяКолонки, ПозТочки - 1)][Сред(ИмяКолонки, ПозТочки + 1)]) + Число(Строка[Лев(ИмяКолонки, ПозТочки - 1)][Сред(ИмяКолонки, ПозТочки + 1)]);
								Иначе	
									НайденаяСтрока[ИмяКолонки] = Число(НайденаяСтрока[ИмяКолонки]) + Число(Строка[ИмяКолонки]);
								КонецЕсли;	
								// alo
								Если ИмяКолонки = "Сумма" 
									Или ИмяКолонки = "Цена" 
									Или ИмяКолонки = "СуммаБезНал" Тогда
									НайденаяСтрока[ИмяКолонки] = Формат(НайденаяСтрока[ИмяКолонки], "ЧЦ=17; ЧДЦ=2; ЧРД=.; ЧГ=0; ЧН=0.00");
								КонецЕсли;
								Если ИмяКолонки = "НДС.Сумма" Тогда
									НайденаяСтрока["НДС"]["Сумма"] = Формат(НайденаяСтрока["НДС"]["Сумма"], "ЧЦ=17; ЧДЦ=2; ЧРД=.; ЧГ=0; ЧН=0.00"); 
								КонецЕсли;  
							КонецЦикла;	
						КонецЕсли;	
					Иначе
						Строка.Вставить("ПорНомер",Формат(сч, "ЧГ=0"));
						Контекст.ТаблДок.СтрТабл.Добавить(Строка);
					КонецЕсли;
					сч = сч + 1;
				КонецЦикла;
				Контекст.ИтогСумма = Контекст.ИтогСумма+ВременныйКонтекст.ИтогСумма;
				Контекст.ИтогСуммаБезНалога = Контекст.ИтогСуммаБезНалога+ВременныйКонтекст.ИтогСуммаБезНалога;
				Контекст.ИтогСуммаНДС = Контекст.ИтогСуммаНДС+ВременныйКонтекст.ИтогСуммаНДС;
				Попытка
					Контекст.ИтогБрутто = Контекст.ИтогБрутто + ВременныйКонтекст.ИтогБрутто;
				Исключение
				КонецПопытки; 
				Попытка
					Контекст.ИтогКоличество = Контекст.ИтогКоличество + ВременныйКонтекст.ИтогКоличество;
				Исключение
				КонецПопытки;
				Попытка
					Контекст.ИтогНетто = Контекст.ИтогНетто + ВременныйКонтекст.ИтогНетто;
				Исключение
				КонецПопытки;
				Попытка
					Контекст.ИтогКолМест = Контекст.ИтогКолМест + ВременныйКонтекст.ИтогКолМест;
				Исключение
				КонецПопытки;
				Если ВременныйКонтекст.Свойство("ЕстьПредыдущиеДанные") Тогда
					Если Не Контекст.Свойство("ЕстьПредыдущиеДанные") Тогда
						Контекст.Вставить("ЕстьПредыдущиеДанные", Истина);
					КонецЕсли;
					Контекст.ПредИтогСумма = Контекст.ПредИтогСумма+ВременныйКонтекст.ПредИтогСумма;
					Контекст.ПредИтогСуммаБезНалога = Контекст.ПредИтогСуммаБезНалога+ВременныйКонтекст.ПредИтогСуммаБезНалога;
					Контекст.ПредИтогСуммаНДС = Контекст.ПредИтогСуммаНДС+ВременныйКонтекст.ПредИтогСуммаНДС;
				КонецЕсли;

				Если	Не Контекст.ФайлДанные.мСторона.Свойство("Грузоотправитель") // берем грузоотправителя с основания СФ
					Или	Не ЗначениеЗаполнено(Контекст.ФайлДанные.мСторона.Грузоотправитель.Сторона) Тогда
					
					Если ВременныйКонтекст.ДокументДанные.Свойство("мФайл")	Тогда
						НайденоОснованиеСоСтороной = Ложь;
						Для Каждого Элемент Из ВременныйКонтекст.ДокументДанные.мФайл Цикл
							Если Элемент.Значение.Свойство("мТаблДок") Тогда
								Если (Элемент.Значение.мТаблДок.Свойство("Товары") и Элемент.Значение.мТаблДок.Товары.Количество()>0) или (УказанТипНоменклатуры и КолТоваров>0) Тогда
									Если Элемент.Значение.Свойство("мСторона") и Элемент.Значение.мСторона.Свойство("Грузоотправитель") Тогда
										Контекст.ФайлДанные.мСторона.Вставить("Грузоотправитель", Новый Структура);
										Кэш.ОбщиеФункции.сбисСкопироватьСтруктуруНаКлиенте(Контекст.ФайлДанные.мСторона.Грузоотправитель,Элемент.Значение.мСторона.Грузоотправитель);
										НайденоОснованиеСоСтороной = Истина;
									КонецЕсли;
									Если НайденоОснованиеСоСтороной Тогда    // прерываем, когда заполнили данные с какого-либо основания
										Прервать;
									КонецЕсли;
								КонецЕсли;
							КонецЕсли;
						КонецЦикла;
					КонецЕсли;
					
				КонецЕсли;
				
				Если	Не Контекст.ФайлДанные.мСторона.Свойство("Грузополучатель") // берем грузополучателя с основания СФ
					Или	Не ЗначениеЗаполнено(Контекст.ФайлДанные.мСторона.Грузополучатель.Сторона) Тогда
					
					Если ВременныйКонтекст.ДокументДанные.Свойство("мФайл")	Тогда
						НайденоОснованиеСоСтороной = Ложь;
						Для Каждого Элемент Из ВременныйКонтекст.ДокументДанные.мФайл Цикл
							Если Элемент.Значение.Свойство("мТаблДок") Тогда
								Если (Элемент.Значение.мТаблДок.Свойство("Товары") и Элемент.Значение.мТаблДок.Товары.Количество()>0) или (УказанТипНоменклатуры и КолТоваров>0) Тогда
									Если Элемент.Значение.Свойство("мСторона") и Элемент.Значение.мСторона.Свойство("Грузополучатель") Тогда
										Контекст.ФайлДанные.мСторона.Вставить("Грузополучатель", Новый Структура);
										Кэш.ОбщиеФункции.сбисСкопироватьСтруктуруНаКлиенте(Контекст.ФайлДанные.мСторона.Грузополучатель,Элемент.Значение.мСторона.Грузополучатель);
										НайденоОснованиеСоСтороной = Истина;
									КонецЕсли;
									Если НайденоОснованиеСоСтороной Тогда    // прерываем, когда заполнили данные с какого-либо основания
										Прервать;
									КонецЕсли;
								КонецЕсли;
							КонецЕсли;
						КонецЦикла;
					КонецЕсли;
					
				КонецЕсли;
				
			КонецЦикла;
		КонецЦикла;
		
		Если Контекст.ФайлДанные.Свойство("СвернутьКолонкиСуммирования") И НЕ Контекст.ФайлДанные.Свойство("СвернутьКолонкиГруппировок") Тогда
			Контекст.ТаблДок.СтрТабл = Кэш.ОбщиеФункции.СвернутьМассивСтрокДокумента(Кэш, Контекст.ТаблДок.СтрТабл, Контекст.ФайлДанные.СвернутьКолонкиСуммирования);
		КонецЕсли;
		// Добавим номера строк исх. сч. ф.
		Если Контекст.ДокументДанные.Свойство("ВходящийКонтекст")  Тогда
			МассивИсходныхНомеровСтрок = Контекст.ДокументДанные.ВходящийКонтекст.МассивИсходныхНомеровСтрок;
			Если	МассивИсходныхНомеровСтрок.Количество() > 0
				И	Контекст.ТаблДок.СтрТабл.Количество() > 0 Тогда
				
				Для ИндСтр = 0 По Контекст.ТаблДок.СтрТабл.ВГраница() Цикл
					Если ИндСтр > МассивИсходныхНомеровСтрок.ВГраница() Тогда
						Контекст.ТаблДок.СтрТабл[ИндСтр].Вставить("ПорНомТовВСЧФ","");
					Иначе
						Контекст.ТаблДок.СтрТабл[ИндСтр].Вставить("ПорНомТовВСЧФ",Формат(МассивИсходныхНомеровСтрок[ИндСтр], "ЧГ=0"));
					КонецЕсли;
				КонецЦикла;
			КонецЕсли;
		КонецЕсли;
		
		Если УказанТипНоменклатуры = Ложь или (УказанТипНоменклатуры и КолТоваров>0) Тогда
			Контекст.Вставить("ЗаполнятьГрузотпрГрузполуч", Истина);
		Иначе
			Контекст.Вставить("ЗаполнятьГрузотпрГрузполуч", Ложь);
		КонецЕсли;

		
		ИтогТабл=Новый Структура;
		ИтогТабл.Вставить("Сумма", Формат(Контекст.ИтогСумма, "ЧЦ=17; ЧДЦ=2; ЧРД=.; ЧГ=0; ЧН=0.00"));
		ИтогТабл.Вставить("Кол_во", Формат(Контекст.ИтогКоличество, "ЧЦ=17; ЧДЦ=2; ЧРД=.; ЧГ=0; ЧН=0.00"));
		ИтогТабл.Вставить("СуммаБезНал", Формат(Контекст.ИтогСуммаБезНалога, "ЧЦ=17; ЧДЦ=2; ЧРД=.; ЧГ=0; ЧН=0.00"));
		ИтогТабл.Вставить("НДС",Новый Структура);
		ИтогТабл.НДС.Вставить("Сумма",Формат(Контекст.ИтогСуммаНДС, "ЧЦ=17; ЧДЦ=2; ЧРД=.; ЧГ=0; ЧН=0.00"));
		Если Контекст.ИтогКолМест>0 Тогда
			ИтогТабл.Вставить("Упаковка",Новый Структура);
			ИтогТабл.Упаковка.Вставить("КолМест",Формат(Контекст.ИтогКолМест, "ЧЦ=17; ЧДЦ=0; ЧРД=.; ЧГ=0; ЧН=0"));	
		КонецЕсли;
		
		Если Контекст.ФайлДанные.Свойство("ЕдиницаИзмеренияВеса") Тогда
			ЕдиницаИзмеренияВеса = Контекст.ФайлДанные.ЕдиницаИзмеренияВеса;
			ИтогТаблБрутто = Новый Структура;
			Если Контекст.ФайлДанные.Свойство("МассаБруттоИтогПрописью") Тогда
				ИтогТаблБрутто.Вставить("Прописью", Кэш.ОбщиеФункции.РассчитатьЗначение("МассаБруттоИтогПрописью", Контекст.ФайлДанные,Кэш));  
				ИтогТабл.Вставить("Брутто", ИтогТаблБрутто);
			ИначеЕсли Контекст.ИтогБрутто > 0 Тогда
				ИтогТаблБрутто.Вставить("Кол_во", Формат(Контекст.ИтогБрутто, "ЧЦ=17; ЧДЦ=3; ЧРД=.; ЧГ=0; ЧН=0.00"));
				Если Контекст.ФайлДанные.Свойство("МассаИтогПрописью") Тогда
					Контекст.ФайлДанные.Вставить("МассаИтог", Контекст.ИтогБрутто);
					ИтогТаблБрутто.Вставить("Прописью", Кэш.ОбщиеФункции.РассчитатьЗначение("МассаИтогПрописью", Контекст.ФайлДанные,Кэш));
				Иначе	
					ИтогТаблБрутто.Вставить("Прописью", ЧислоПрописью(Контекст.ИтогБрутто, ,",,,,,,,,0")+ " " + СокрЛП(ЕдиницаИзмеренияВеса) + ".");
				КонецЕсли;	
				ИтогТабл.Вставить("Брутто", ИтогТаблБрутто);
			КонецЕсли;
			
			Если Контекст.ИтогНетто > 0 Тогда
				ИтогТаблНетто = Новый Структура;
				ИтогТаблНетто.Вставить("Кол_во", Формат(Контекст.ИтогНетто, "ЧЦ=17; ЧДЦ=3; ЧРД=.; ЧГ=0; ЧН=0.00"));
				Если Контекст.ФайлДанные.Свойство("МассаНеттоИтогПрописью") Тогда
					ИтогТаблНетто.Вставить("Прописью", Кэш.ОбщиеФункции.РассчитатьЗначение("МассаНеттоИтогПрописью", Контекст.ФайлДанные,Кэш));
				ИначеЕсли Контекст.ФайлДанные.Свойство("МассаИтогПрописью") Тогда
					Контекст.ФайлДанные.Вставить("МассаИтог", Контекст.ИтогНетто);
					ИтогТаблНетто.Вставить("Прописью", Кэш.ОбщиеФункции.РассчитатьЗначение("МассаИтогПрописью", Контекст.ФайлДанные,Кэш));
				Иначе	
					ИтогТаблНетто.Вставить("Прописью", ЧислоПрописью(Контекст.ИтогНетто, ,",,,,,,,,0")+ " " + СокрЛП(ЕдиницаИзмеренияВеса) + ".");
				КонецЕсли;	
				ИтогТабл.Вставить("Нетто", ИтогТаблНетто);
			КонецЕсли;
		КонецЕсли;
		Если Контекст.Свойство("ЕстьПредыдущиеДанные") Тогда
			ПредИтогТабл=Новый Структура;
			ПредИтогТабл.Вставить("Сумма", Формат(Контекст.ПредИтогСумма, "ЧЦ=17; ЧДЦ=2; ЧРД=.; ЧГ=0; ЧН=0.00"));	
			ПредИтогТабл.Вставить("СуммаБезНал", Формат(Контекст.ПредИтогСуммаБезНалога, "ЧЦ=17; ЧДЦ=2; ЧРД=.; ЧГ=0; ЧН=0.00"));
			ПредИтогТабл.Вставить("НДС",Новый Структура);
			ПредИтогТабл.НДС.Вставить("Сумма",Формат(Контекст.ПредИтогСуммаНДС, "ЧЦ=17; ЧДЦ=2; ЧРД=.; ЧГ=0; ЧН=0.00"));	
			ИтогТабл.Вставить("ПредИтогТабл",ПредИтогТабл);
			Контекст.Удалить("ЕстьПредыдущиеДанные");
		КонецЕсли;
		//Контекст.ТаблДок.Вставить("ИтогТабл",Новый Массив);
		Контекст.ТаблДок.ИтогТабл.Добавить(ИтогТабл);
		Если Контекст.ТаблДок.СтрТабл.Количество() = 0 Тогда//нет такого документа
			Возврат Истина;
		КонецЕсли;
		Возврат ПолучитьШапкуИзДокумента1С(Кэш,Контекст);		
	Исключение
		Сообщить(ОписаниеОшибки());
		Возврат Ложь;
	КонецПопытки;
КонецФункции

&НаКлиенте
Функция ПолучитьШапкуИзДокумента1С(Кэш, Контекст) Экспорт
	Перем СбисНДСИсчисляетсяАгентом;
	// Функция формирует структуру выгружаемого файла и добавляет его в состав пакета
	Попытка	
		Док  = Новый Структура;
		Док.Вставить("Файл",Новый Структура);
		Кэш.ОбщиеФункции.ЗаполнитьАтрибуты(Кэш,"Файл",Контекст.ФайлДанные,Док.Файл);
		Док.Файл.Вставить("Документ",Новый Структура);
		Кэш.ОбщиеФункции.ЗаполнитьАтрибуты(Кэш,"Документ",Контекст.ФайлДанные,Док.Файл.Документ);
		Док.Файл.Документ.Вставить("Основание",Новый Массив);
		
		Валюта =  Кэш.ОбщиеФункции.РассчитатьЗначение("Валюта_КодОКВ", Контекст.ФайлДанные, Кэш);
		Если ЗначениеЗаполнено(Валюта) Тогда
			Док.Файл.Документ.Вставить("Валюта",Новый Структура);
			Кэш.ОбщиеФункции.ЗаполнитьАтрибуты(Кэш,"Валюта",Контекст.ФайлДанные,Док.Файл.Документ.Валюта);
		КонецЕсли;
		Если Не Контекст.Свойство("НДСИсчисляетсяАгентом", СбисНДСИсчисляетсяАгентом) Тогда
			СбисНДСИсчисляетсяАгентом = Кэш.ОбщиеФункции.РассчитатьЗначение("НДСИсчисляетсяАгентом", Контекст.ФайлДанные) = Истина;
		КонецЕсли;

		Отправитель = "";
		Получатель = "";
		ЗапретРедакций = Ложь;
		ОтправительРоль=Кэш.ОбщиеФункции.РассчитатьЗначение("Отправитель_Роль", Контекст.ФайлДанные, Кэш);
		ПолучательРоль=Кэш.ОбщиеФункции.РассчитатьЗначение("Получатель_Роль", Контекст.ФайлДанные, Кэш);
		Если Не ЗначениеЗаполнено(ОтправительРоль) Тогда
			ОтправительРоль = "Отправитель";
		КонецЕсли;
		Если Не ЗначениеЗаполнено(ПолучательРоль) Тогда
			ПолучательРоль = "Получатель";
		КонецЕсли;
		Для Каждого Параметр Из Контекст.ФайлДанные.мСторона Цикл
			Если Параметр.Значение.Свойство("Роль") Тогда
				Роль = Кэш.ОбщиеФункции.РассчитатьЗначение("Роль",Параметр.Значение,Кэш);
			Иначе
				Роль = Кэш.ОбщиеФункции.РассчитатьЗначение("Сторона_Роль",Параметр.Значение,Кэш);
			КонецЕсли;
			Если Роль = ОтправительРоль Тогда
				Сертификат = Кэш.ОбщиеФункции.РассчитатьЗначение("Сертификат",Параметр.Значение,Кэш);
			КонецЕсли;
			Если Роль = ПолучательРоль Тогда
				ЗапретРедакций = Кэш.ОбщиеФункции.РассчитатьЗначение("ЗапретРедакций",Параметр.Значение,Кэш);
			КонецЕсли;
			Сторона = Кэш.ОбщиеФункции.ПолучитьСторону(Кэш,Параметр.Значение);
			Если Сторона<>Неопределено Тогда
				Док.Файл.Документ.Вставить(Роль,Сторона);
			КонецЕсли;
		КонецЦикла;
		Если Не Док.Файл.Документ.Свойство(ПолучательРоль) Тогда
			МодульОбъектаКлиент().ВызватьСбисИсключение(721, "Файл_СчФктр_3_01.ПолучитьШапкуИзДокумента1С",,,"Не удалось определить ИНН получателя документа " + Строка(Контекст.Документ));
		КонецЕсли;
		Если Не Док.Файл.Документ.Свойство(ОтправительРоль) Тогда
			МодульОбъектаКлиент().ВызватьСбисИсключение(721, "Файл_СчФктр_3_01.ПолучитьШапкуИзДокумента1С",,,"Не удалось определить ИНН отправителя документа " + Строка(Контекст.Документ));
		КонецЕсли;
		КлючФормыПоиска = "Файл_" + Контекст.ФайлДанные.Файл_Формат + "_" + СтрЗаменить(СтрЗаменить(Контекст.ФайлДанные.Файл_ВерсияФормата, ".", "_"), " ", "");
		
		// Если Грузоотправитель и грузополучатель нужны, но они не попали в файл, то берем их с отправителя и получателя
		Если Не Контекст.Свойство("ЗаполнятьГрузотпрГрузполуч") или (Контекст.Свойство("ЗаполнятьГрузотпрГрузполуч") и Контекст.ЗаполнятьГрузотпрГрузполуч = Истина) Тогда
			Если Контекст.ФайлДанные.мСторона.Свойство("Грузоотправитель") и Не Док.Файл.Документ.Свойство("Грузоотправитель") и Док.Файл.Документ.Свойство(ОтправительРоль) Тогда
				Док.Файл.Документ.Вставить("Грузоотправитель",Новый Структура);		
				Кэш.ОбщиеФункции.сбисСкопироватьСтруктуруНаКлиенте(Док.Файл.Документ.Грузоотправитель,Док.Файл.Документ[ОтправительРоль]);
			КонецЕсли;
			Если Контекст.ФайлДанные.мСторона.Свойство("Грузополучатель") и Не Док.Файл.Документ.Свойство("Грузополучатель") и Док.Файл.Документ.Свойство(ПолучательРоль) Тогда
				Док.Файл.Документ.Вставить("Грузополучатель",Новый Структура);		
				Кэш.ОбщиеФункции.сбисСкопироватьСтруктуруНаКлиенте(Док.Файл.Документ.Грузополучатель,Док.Файл.Документ[ПолучательРоль]);
			КонецЕсли;
		КонецЕсли;
		
		Отправитель = Кэш.ОбщиеФункции.сбисСкопироватьОбъектНаКлиенте(Док.Файл.Документ[ОтправительРоль]); 
		Получатель = Кэш.ОбщиеФункции.сбисСкопироватьОбъектНаКлиенте(Док.Файл.Документ[ПолучательРоль]);
		Если ЗапретРедакций = Истина Тогда
			Получатель.Вставить("ЗапретРедакций", Истина);		
		КонецЕсли;

		Если Контекст.ФайлДанные.Свойство("АдресДоставки") И Контекст.ФайлДанные.АдресДоставки <> Неопределено Тогда
			Док.Файл.Документ.Вставить("АдресДоставки", Кэш.ОбщиеФункции.РассчитатьЗначение("АдресДоставки", Контекст.ФайлДанные, Кэш));
		КонецЕсли;
		Если Контекст.ФайлДанные.Свойство("АдресПогрузки") И Контекст.ФайлДанные.АдресПогрузки <> Неопределено Тогда
			Док.Файл.Документ.Вставить("АдресПогрузки", Кэш.ОбщиеФункции.РассчитатьЗначение("АдресПогрузки", Контекст.ФайлДанные, Кэш));
		КонецЕсли;
		
		Если Контекст.ФайлДанные.Свойство("мОснование") Тогда
			фрм = Кэш.ГлавноеОкно.сбисНайтиФормуФункции("ПолучитьДанныеИзДокумента1С_мОснование","Файл_"+Контекст.ФайлДанные.Файл_Формат+"_"+СтрЗаменить(СтрЗаменить(Контекст.ФайлДанные.Файл_ВерсияФормата, ".", "_"), " ", ""),"Файл_Шаблон", Кэш);
			фрм.ПолучитьДанныеИзДокумента1С_мОснование(Кэш, Док, Контекст);
		КонецЕсли;
		
		Если Контекст.ФайлДанные.Свойство("мПараметр") Тогда
			Док.Файл.Документ.Вставить("Параметр",Новый Массив);
			Для Каждого Элемент Из Контекст.ФайлДанные.мПараметр Цикл
				Кэш.ОбщиеФункции.сбисСкопироватьСтруктуруНаКлиенте(Контекст.ФайлДанные,Элемент.Значение);
				Параметр = Новый Структура();
				Кэш.ОбщиеФункции.ЗаполнитьАтрибуты(Кэш,"Параметр",Контекст.ФайлДанные,Параметр);
				Док.Файл.Документ.Параметр.Добавить(Параметр);
			КонецЦикла;
		КонецЕсли;
		
		Если Контекст.ФайлДанные.Свойство("мТранспортноеСредство") Тогда
			Док.Файл.Документ.Вставить("ТранспортноеСредство",Новый Массив);
			Для Каждого Элемент Из Контекст.ФайлДанные.мТранспортноеСредство Цикл
				Кэш.ОбщиеФункции.сбисСкопироватьСтруктуруНаКлиенте(Контекст.ФайлДанные,Элемент.Значение);
				ТранспортноеСредство = Новый Структура();
				Кэш.ОбщиеФункции.ЗаполнитьАтрибуты(Кэш,"ТранспортноеСредство",Контекст.ФайлДанные,ТранспортноеСредство);
				Док.Файл.Документ.ТранспортноеСредство.Добавить(ТранспортноеСредство);
			КонецЦикла;
		КонецЕсли;
		
		ОтветственныйСтруктура = Кэш.ОбщиеФункции.ПолучитьСтруктуруОтветственного(Кэш,Контекст);
		ПодразделениеСтруктура = Кэш.ОбщиеФункции.ПолучитьСтруктуруПодразделения(Кэш,Контекст);
		РегламентСтруктура = Кэш.ОбщиеФункции.ПолучитьСтруктуруРегламента(Кэш,Контекст);
		ОснованияМассив = Кэш.ОбщиеФункции.ПолучитьМассивОснований(Кэш,Контекст);   
		СвязанныеДокументы1С = Кэш.ОбщиеФункции.сбисПолучитьСвязанныеДокументы1С(Кэш,Контекст);
		ДатаВложения = ?(Док.Файл.Документ.Свойство("Дата"), Док.Файл.Документ.Дата, "");
		НомерВложения = ?(Док.Файл.Документ.Свойство("Номер"), Док.Файл.Документ.Номер, "");
		Если СбисНДСИсчисляетсяАгентом Тогда
			СуммаВложения = Формат(Контекст.ИтогСуммаБезНалога, "ЧЦ=17; ЧДЦ=2; ЧРД=.; ЧГ=0; ЧН=0.00");
		Иначе
			СуммаВложения = Формат(Контекст.ИтогСумма, "ЧЦ=17; ЧДЦ=2; ЧРД=.; ЧГ=0; ЧН=0.00");
		КонецЕсли;
		НазваниеВложения = ?(Док.Файл.Документ.Свойство("Название"), Док.Файл.Документ.Название+" № "+НомерВложения+" от "+ДатаВложения+" на сумму "+СуммаВложения, "");
		Тип = Кэш.ОбщиеФункции.РассчитатьЗначение("Вложение_Тип", Контекст.ФайлДанные,Кэш);
		ПодТип = Кэш.ОбщиеФункции.РассчитатьЗначение("Вложение_ПодТип", Контекст.ФайлДанные,Кэш);
		ВерсияФормата = Кэш.ОбщиеФункции.РассчитатьЗначение("Вложение_ВерсияФормата", Контекст.ФайлДанные,Кэш);
		ПодВерсияФормата = Кэш.ОбщиеФункции.РассчитатьЗначение("Вложение_ПодВерсияФормата", Контекст.ФайлДанные,Кэш);
		Примечание = Кэш.ОбщиеФункции.РассчитатьЗначение("Примечание", Контекст.ФайлДанные,Кэш);
		Провести = Кэш.ОбщиеФункции.РассчитатьЗначение("Провести", Контекст.ФайлДанные,Кэш); // alo Провести
		ИспользоватьГенератор = Кэш.ОбщиеФункции.РассчитатьЗначение("ИспользоватьГенератор", Контекст.ФайлДанные, Кэш);
		ИдентификаторГосконтракта = Кэш.ОбщиеФункции.РассчитатьЗначение("ИдентификаторГосконтракта", Контекст.ФайлДанные, Кэш);
		
		Док.Файл.Документ.Вставить("ТаблДок",Контекст.ТаблДок);
		Вложение = Новый Структура("СтруктураДокумента,Отправитель,Получатель,Ответственный,Подразделение,Регламент,ДокументОснование, Документ1С, Название, Тип, ПодТип, ВерсияФормата,ПодВерсияФормата,Дата,Номер,Сумма", Док,Отправитель,Получатель,ОтветственныйСтруктура,ПодразделениеСтруктура,РегламентСтруктура,ОснованияМассив, Контекст.Документ, НазваниеВложения, Тип, ПодТип, ВерсияФормата,ПодВерсияФормата,ДатаВложения,НомерВложения,СуммаВложения);
		Если ЗначениеЗаполнено(Примечание) Тогда
			Вложение.Вставить("Примечание",Примечание);	
		КонецЕсли;
		Если ЗначениеЗаполнено(Сертификат) Тогда
			Вложение.Вставить("Сертификат",Сертификат);	
		КонецЕсли;
		Если ТипЗнч(ИспользоватьГенератор) = Тип("Булево") Тогда
			Вложение.Вставить("ИспользоватьГенератор", ИспользоватьГенератор);
		КонецЕсли;
		Если ЗначениеЗаполнено(ИдентификаторГосконтракта) Тогда
			Вложение.Вставить("ИдентификаторГосконтракта", ИдентификаторГосконтракта);
		КонецЕсли;
		
		ДопПоля= Новый Структура;	// alo ДопПоля
		Кэш.ОбщиеФункции.ЗаполнитьАтрибуты(Кэш,"ДопПоля",Контекст.ФайлДанные,ДопПоля);
		Если ЗначениеЗаполнено(ДопПоля) Тогда
			Вложение.Вставить("ДопПоля",ДопПоля);
		Конецесли;
		Если ЗначениеЗаполнено(Провести) Тогда // alo Провести
			Вложение.Вставить("Провести",Провести);	
		КонецЕсли;   
		Если ЗначениеЗаполнено(СвязанныеДокументы1С) Тогда
			СвязанныеДокументы1С.Вставить(0, Контекст.Документ);
			Вложение.Вставить("Документы1С",СвязанныеДокументы1С);	
		КонецЕсли;
		
		МодульОбъектаКлиент().ПропатчитьФайлВложенияСБИС(Вложение, Новый Структура("ГрязныйИни, ПолучательРоль, ОтправительРоль", Контекст.ФайлДанные, ПолучательРоль, ОтправительРоль));
		
		Контекст.СоставПакета.Вложение.Добавить(Вложение);

		фрм = Кэш.ГлавноеОкно.сбисНайтиФормуФункции("сбисПослеФормированияДокумента","Файл_"+Контекст.ФайлДанные.Файл_Формат+"_"+СтрЗаменить(СтрЗаменить(Контекст.ФайлДанные.Файл_ВерсияФормата, ".", "_"), " ", ""),"Файл_Шаблон", Кэш);
		Если фрм<>Ложь Тогда
			фрм.сбисПослеФормированияДокумента(Док, Кэш, Контекст);	
			Вложение.СтруктураДокумента = Док; // на случай, если Док поменялся в функции сбисПослеФормированияДокумента
		КонецЕсли;
		Возврат Истина;
		
	Исключение
		ИсключениеФормирования = МодульОбъектаКлиент().НовыйСбисИсключение(ИнформацияОбОшибке(), "Файл_СчФктр_3_01.ПолучитьШапкуИзДокумента1С");
		Контекст.СоставПакета.Вставить("Ошибка", ИсключениеФормирования);
		Возврат Ложь;
	КонецПопытки;
КонецФункции

&НаКлиенте
Процедура ОбновитьНоменклатуруВложения(Кэш, Контекст) Экспорт

	Файл = Контекст.ФайлДанные.Файл;
	Изменения = Контекст.Изменения;

	ИмяФормыПоФормату = "Файл_" + Файл.Формат + "_" + Файл.ВерсияФормата;
	
	ИмяФормыПоФормату = Кэш.ОбщиеФункции.сбисЗаменитьНедопустимыеСимволы(ИмяФормыПоФормату);
	
	МассивФормФайл = Новый Массив;
	МассивФормФайл.Добавить("Файл_Шаблон");
	МассивФормФайл.Добавить(ИмяФормыПоФормату);
	
	ФормаФайл = МодульОбъектаКлиент().НайтиФункциюСеансаОбработки("ДобавитьМПараметр", МассивФормФайл);
	
	Для каждого СтрТабл Из Файл.Документ.ТаблДок.СтрТабл Цикл
		
		Ключ = СтрТабл.ПорНомер;
		
		Если Изменения.Получить(Ключ) = Неопределено Тогда 
			Продолжить;
		КонецЕсли;
		
		ЛокальныйКонтекст = Новый Структура("мПараметр", Новый Структура);
		
		Для каждого Изменение Из Изменения.Получить(Ключ) Цикл
			ЛокальныйКонтекст.мПараметр.Вставить(Изменение.Ключ, Новый Структура("Параметр_Имя, Параметр_Значение", Изменение.Ключ, Изменение.Значение));
		КонецЦикла;
		
		ФормаФайл.ДобавитьМПараметр(Кэш, ЛокальныйКонтекст, СтрТабл);
	
	КонецЦикла;
	
КонецПроцедуры