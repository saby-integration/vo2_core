
&НаКлиенте
Функция ПослеВопросаОЗакрытии(Результат, ДопПараметры) Экспорт
		
	Если Результат = КодВозвратаДиалога.Да Тогда
		ЗакрытьБезСохранения = Истина; 
		Закрыть(Неопределено);
	Иначе
		ЗакрытьБезСохранения = Ложь;
	КонецЕсли;	                      
	
	ДопПараметры.ЗакрытьБезСохранения = ЗакрытьБезСохранения;
	Возврат ДопПараметры.ЗакрытьБезСохранения;
	
КонецФункции

// Функция - Проверить наличие критических ошибок
// Проверяет наличие ошибок, при которых запрещено сохранять внесённые вручную изменения сопоставлений 
//
// Возвращаемое значение:
// Булево  - Наличие или отсутствие ошибок, при которых будем запрещать запись данных по сопоставлению
//
&НаКлиенте
Функция ПроверитьЗаполнениеДанныхНоменклатур1С()
	
	ОчиститьСообщения();
	СписокОшибок = Новый Массив; 
	СчетчикСтрок = 1;
	
	Для Каждого Строка Из ТабличнаяЧасть Цикл
		
		Если Не ЗначениеЗаполнено(Строка.Номенклатура)
			И Не ЗначениеЗаполнено(Строка.Единицы) Тогда
			СписокОшибок.Добавить("Не заполнены Номенклатура и Единицы в строке №" + СчетчикСтрок);
		ИначеЕсли Не ЗначениеЗаполнено(Строка.Номенклатура) Тогда
			СписокОшибок.Добавить("Не заполнена Номенклатура в строке №" + СчетчикСтрок);
		ИначеЕсли Не ЗначениеЗаполнено(Строка.Единицы) Тогда
			СписокОшибок.Добавить("Не заполнены Единицы в строке №" + СчетчикСтрок);
		КонецЕсли;                                                                 
		
		СчетчикСтрок = СчетчикСтрок + 1;
		
	КонецЦикла;
	
	Возврат СписокОшибок;
	
КонецФункции

&НаКлиенте
Процедура ПодборЕдиницИзмерения()
	
	ПолноеИмяФормыВыбора = СправочникЕдиницПолноеИмя + ".ФормаВыбора";
	ПараметрыПодбора = Новый Структура("РежимВыбора, ЗакрыватьПриВыборе, МножественныйВыбор");
	 
    ПараметрыПодбора.МножественныйВыбор = Истина;    
	
	#Если ТолстыйКлиентОбычноеПриложение Тогда
		ОткрытьФорму(ПолноеИмяФормыВыбора, ПараметрыПодбора, ЭтаФорма);
	#Иначе
		ДопПараметры = Новый Структура;
		ОбработкаВыбора = МодульОбъектаКлиент().НовыйСбисОписаниеОповещения("ПослеВыбораЕдиницИзмерения", ЭтаФорма, ДопПараметры);
		ОткрытьФорму(ПолноеИмяФормыВыбора, ПараметрыПодбора, ЭтаФорма, , , , ОбработкаВыбора, РежимОткрытияОкнаФормы.БлокироватьОкноВладельца);	
	#КонецЕсли
	
КонецПроцедуры 

&НаКлиенте
Процедура ПослеВыбораЕдиницИзмерения(Результат, ДопПараметры = Неопределено) Экспорт
	
	Если НЕ ЗначениеЗаполнено(Результат) Тогда 
		Возврат;
	КонецЕсли;
	
	ТабЧастьТекДанные = МестныйКэш.ГлавноеОкно.сбисЭлементФормы(ЭтаФорма, "ТабличнаяЧасть").ТекущиеДанные; 
	
	Если ТабЧастьтекДанные.Единицы = Неопределено Тогда
		ТабЧастьТекДанные.Единицы = Новый Структура("Единицы", Новый Соответствие);
	Иначе
		ТабЧастьТекДанные.Единицы.Единицы.Очистить();  
	КонецЕсли;
	
	ТабЧастьТекДанные.ЕдиницыПредставление = "";
	
	Если ДопПараметры.Свойство("НайденоВНоменклатуре") И ДопПараметры.НайденоВНоменклатуре Тогда
		
		Единица = ПолучитьДанныеИзСправочникаЕдиниц(Результат);
		
		Если ЗначениеЗаполнено(ТабЧастьТекДанные.Коэффициент) Тогда
			КоэффициентЕдиницы = ТабЧастьТекДанные.Коэффициент;
		Иначе
			КоэффициентЕдиницы = 1;
		КонецЕсли;
		
		СтруктураЕдиницы = Новый Структура("_класс, Коэффициент, ОКЕИ, Название, Ссылка, Владелец", "СопоставлениеДляЕдиницы", КоэффициентЕдиницы, Единица.Код, Единица.Наименование, Результат, Единица.Владелец);
		ТабЧастьТекДанные.Единицы.Единицы.Вставить(Результат, СтруктураЕдиницы);
		ТабЧастьТекДанные.ЕдиницыПредставление = ТабЧастьТекДанные.ЕдиницыПредставление + Единица.Наименование + "; ";
		
	Иначе	
		Для Каждого ЕдиницаСсылка Из Результат Цикл 
			
			Единица = ПолучитьДанныеИзСправочникаЕдиниц(ЕдиницаСсылка);
			
			Если ЗначениеЗаполнено(ТабЧастьТекДанные.Коэффициент) Тогда
				КоэффициентЕдиницы = ТабЧастьТекДанные.Коэффициент;
			Иначе
				КоэффициентЕдиницы = 1;
			КонецЕсли;
			
			СтруктураЕдиницы = Новый Структура("_класс, Коэффициент, ОКЕИ, Название, Ссылка, Владелец", "СопоставлениеДляЕдиницы", КоэффициентЕдиницы, Единица.Код, Единица.Наименование, ЕдиницаСсылка, Единица.Владелец);
			ТабЧастьТекДанные.Единицы.Единицы.Вставить(ЕдиницаСсылка, СтруктураЕдиницы);
			ТабЧастьТекДанные.ЕдиницыПредставление = ТабЧастьТекДанные.ЕдиницыПредставление + Единица.Наименование + "; ";
		КонецЦикла;
	КонецЕсли;	
КонецПроцедуры

&НаСервере
Функция ПолучитьДанныеИзСправочникаЕдиниц(Ссылка);

	СпрОбъект = Ссылка.ПолучитьОбъект();
	Единица = Новый Структура("Код, Наименование, Владелец");
	
	Единица.Код = СпрОбъект.Код;
	Единица.Наименование = СпрОбъект.Наименование;
	Единица.Владелец = СпрОбъект.Владелец;

	Возврат Единица;
	
КонецФункции

// Преобразует строку таблицы значений в структуру.
// Свойства структуры и их значения совпадают с колонками переданной строки.
//
// Параметры:
//  СтрокаТаблицыЗначений - СтрокаТаблицыЗначений
//
// Возвращаемое значение:
//  Структура - преобразованная строка таблицы значений.
//
Функция СтрокаТаблицыЗначенийВСтруктуру(СтрокаТаблицыЗначений) Экспорт
	
	Структура = Новый Структура;
	Для каждого Колонка Из СтрокаТаблицыЗначений.Владелец().Колонки Цикл
		Структура.Вставить(Колонка.Имя, СтрокаТаблицыЗначений[Колонка.Имя]);
	КонецЦикла;
	
	Возврат Структура;
	
КонецФункции

&НаКлиенте
Процедура ПеречистатьСуммыПоСтрокам()
	
	СуммаВсего 	  = 0;
	СуммаНДСВсего = 0;
	
	Для Каждого Строка Из ТабличнаяЧасть Цикл
		СуммаВсего = СуммаВсего + Строка.Сумма;
		СуммаНДСВсего = СуммаНДСВсего + Строка.СуммаНДС;
	КонецЦикла;
	
	Если НЕ СуммаВсего = СуммаПоДокументу Тогда
		Сообщить("Не сходится сумма по документу(" + СуммаПоДокументу + ") и сумма по строкам сопоставления(" + СуммаВсего + ")");
	КонецЕсли;
	
		Если НЕ СуммаНДСВсего = СуммаНДСПоДокументу Тогда
		Сообщить("Не сходится сумма НДС по документу(" + СуммаНДСПоДокументу + ") и сумма НДС по строкам сопоставления(" + СуммаНДСВсего + ")");
	КонецЕсли;
			
КонецПроцедуры

// Процедура - Заполнить результат ручного сопоставления
// Внесение в класс сопоставления всех данных (изменённых и уже существовавших) номенклатур 1С из табличной части формы ручного сопоставления
//
// Параметры:
//  ДанныеРучногоСопоставления	 - Структура - Содержит массив данных класса сопоставления номенклатур по проекту расширенных проверок сопоставления номенклатур
//
&НаСервере
Процедура ЗаполнитьРезультатРучногоСопоставления(ДанныеРучногоСопоставления)
	
	ТаблицаНоменклатур1С = ТабличнаяЧасть.Выгрузить(); 
	ДанныеНоменклатуры1С = Новый Структура; 
	
	ДанныеРучногоСопоставления.Номенклатура1С.Очистить();
	
	Для Каждого Номенклатура1С Из ТаблицаНоменклатур1С Цикл 	
		
		ДанныеНоменклатуры1С = СтрокаТаблицыЗначенийВСтруктуру(Номенклатура1С);
		ДанныеНоменклатуры1С.Вставить("_класс", "ОписаниеНоменклатуры1С");
		ДанныеРучногоСопоставления.Номенклатура1С.Вставить(Номенклатура1С.Номенклатура, ДанныеНоменклатуры1С);
		
		// Финт ушами. Даже не спрашивай, Андрей, не хочу о грустном (с) Сыч
		ИзменяемаяСтрокаКласса = ДанныеРучногоСопоставления.Номенклатура1С.Получить(Номенклатура1С.Номенклатура); 
		Если ДанныеНоменклатуры1С.Единицы.Количество() Тогда
			ЕдиницыВрем = ДанныеНоменклатуры1С.Единицы.Единицы;
			ИзменяемаяСтрокаКласса.Удалить("Единицы");
			ИзменяемаяСтрокаКласса.Вставить("Единицы", ЕдиницыВрем);
		КонецЕсли;
	КонецЦикла;  

КонецПроцедуры

// Функция - Получить безопасное наименование
//
// Параметры:
//  ИсходнаяСтрока	 - Строка - Преобразуемая строка 
// 
// Возвращаемое значение:
// Строка  - Строка без спецсиволов, содержит только цифры и буквы кириллицы/латиницы 
//
Функция ПолучитьБезопасноеНаименование(ИсходнаяСтрока) Экспорт
	
	Результат = "";
	
	Латиница = "QWERTYUIOPASDFGHJKLZXCVBNMqwertyuiopasdfghjklzxcvbnm";
	Кириллица = "абвгдеёзжийклмнопрстуфхцчшщъыьэюяАБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯ";
	Цифры = "0123456789";                                                            
	ДопустимыеСимволы = Латиница + Кириллица + Цифры;
	
	Для ПозицияСимвола = 1 по СтрДлина(ИсходнаяСтрока) Цикл
		ТекСимв = Сред(ИсходнаяСтрока, ПозицияСимвола, 1);
		Если Найти(ДопустимыеСимволы, ТекСимв) > 0 Тогда
			Результат = Результат + ТекСимв;
		КонецЕсли;
	КонецЦикла;
	
	Возврат ВРЕГ(Результат);
	
КонецФункции

// Процедура - Произвести пересчет по коэффициенту единиц измерения
//
// Параметры:
//  СтрокаДляПересчета	 - Строка табличной части	 - Строка в которой будет вестить пересчет
//  КоэффициентПересчета - Число	 - На это число будет умножено количество 
//
&НаКлиенте
Процедура ПроизвестиПересчетПоКоэффициентуЕдиницИзмерения(СтрокаДляПересчета)
	
	СтрокаДляПересчета.Количество = СтрокаДляПересчета.Количество * (СтрокаДляПересчета.Коэффициент / СтрокаДляПересчета.КоэффициентБыл);
	СтрокаДляПересчета.Цена 	  = СтрокаДляПересчета.Цена / (СтрокаДляПересчета.Коэффициент / СтрокаДляПересчета.КоэффициентБыл);
	
	СтрокаДляПересчета.КоэффициентБыл = СтрокаДляПересчета.Коэффициент;
	ПеречистатьСуммыПоСтрокам();
	
КонецПроцедуры

&НаСервере
Функция Номенклатуры1СИзменены()
	
	ТаблицаНоменклатур1С = ТабличнаяЧасть.Выгрузить();
	Если ТаблицаНоменклатур1С.Количество() <> ДанныеРучногоСопоставления.Номенклатура1С.Количество() Тогда
		Возврат Истина;
	КонецЕсли;
	
	Для Каждого СопоставленнаяНоменклатура1С Из ДанныеРучногоСопоставления.Номенклатура1С Цикл
		
		СтрокаСНоменклатурой1С = ТаблицаНоменклатур1С.Найти(СопоставленнаяНоменклатура1С.Ключ, "Номенклатура");
		
		Если СтрокаСНоменклатурой1С = Неопределено Тогда
			Возврат Истина;
		КонецЕсли;
		
		Если НЕ СопоставленнаяНоменклатура1С.Значение.Единицы = СтрокаСНоменклатурой1С.Единицы.Единицы Тогда
			Возврат Истина;	
		КонецЕсли;
		
	КонецЦикла;
	
	Возврат Ложь;
КонецФункции
