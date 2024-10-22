
&НаКлиенте
Процедура ВремяОжиданияОтветаПриИзменении(Элемент)
	МестныйКэш.Интеграция.СбисУстановитьВремяОжидания(МестныйКэш, ВремяОжиданияОтвета);
	ПараметрыПриИзменении(Элемент);
КонецПроцедуры

&НаКлиенте
Процедура КаталогНастроекНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	
	СтандартнаяОбработка= Ложь;
	КаталогНастроек	= сбисВыбратьКаталог(КаталогНастроек);

КонецПроцедуры

&НаКлиенте
Процедура КаталогНастроекОткрытие(Элемент, СтандартнаяОбработка)
	СтандартнаяОбработка = Ложь;
	МестныйКэш.ГлавноеОкно.сбисОткрытьКаталог(КаталогНастроек);
КонецПроцедуры 
 

//открывает диалог выбора каталога обмена	
&НаКлиенте
Процедура КаталогОбменаНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	ДиалогОткрытия = Новый ДиалогВыбораФайла(РежимДиалогаВыбораФайла.ВыборКаталога); 
	ДиалогОткрытия.Заголовок = "Выберите каталог обмена документами"; 
	Если ДиалогОткрытия.Выбрать() Тогда 
		КаталогОбмена = ДиалогОткрытия.Каталог; 
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура НастройкаЭПНажатие(Элемент)
	фрм = МестныйКэш.ГлавноеОкно.сбисПолучитьФорму("ФормаНастройкиПодписания",,,МестныйКэш.ГлавноеОкно);
	#Если ТолстыйКлиентОбычноеПриложение Тогда
		МестныйКэш.ГлавноеОкно.сбисПослеНастройкиЭП(фрм.ОткрытьМодально(), Неопределено); 
	#Иначе
		фрм.ОписаниеОповещенияОЗакрытии = Новый ОписаниеОповещения("сбисПослеНастройкиЭП",МестныйКэш.ГлавноеОкно);
		фрм.Открыть();
	#КонецЕсли
КонецПроцедуры

// Процедура устанавливает видимость элементов формы в зависимости от выбранного варианта настроек прокси	
&НаКлиенте
Процедура НастройкиПроксиСервераПриИзменении(Элемент)
	
	ОбновитьДоступностьНастроек();
	
КонецПроцедуры

&НаКлиенте
Процедура ИспользоватьАвтоматическоеСопоставлениеНоменклатурыПриИзменении(Элемент)
	ОбновитьДоступностьНастроек();
КонецПроцедуры 

&НаКлиенте
Процедура СпособОбменаПриИзменении(Элемент)
	
	Если		СпособОбмена = 1
		И	Не	ЗначениеЗаполнено(КаталогОбмена) Тогда
		КаталогОбменаНачалоВыбора(МестныйКэш.ГлавноеОкно.сбисЭлементФормы(ЭтаФорма, "КаталогОбмена"),"", Истина);
	КонецЕсли;

	ОбновитьДоступностьНастроек();
	
КонецПроцедуры

&НаКлиенте
Процедура СпособХраненияНастроекПриИзменении(Элемент)

	ОбновитьДоступностьНастроек();
	
КонецПроцедуры

&НаКлиенте
Процедура СостояниеЭДПриИзменении(Элемент)
	// Включает/выключает дублирование статусов в типовые регистры 1С
	Если СостояниеЭД = Истина Тогда
		ПараметрыПоиска = Новый Структура;
		ПараметрыПоиска.Вставить("ИмяФункции",	"ДублироватьСостояние");
		ПараметрыПоиска.Вставить("КлючФорм",	"Статусы_СостоянияЭД");
		Отказ = Ложь;
		ПараметрыПодсистемы = МестныйКэш.ОбщиеФункции.сбисИнициироватьПодсистему(МестныйКэш, ПараметрыПоиска, Отказ);
		Если Отказ Тогда
			Сообщить("Дублирование статусов в типовые регистры 1С не поддерживается для Вашей конфигурации 1С: " + ПараметрыПодсистемы.details);
			СостояниеЭД = Ложь;
		Иначе
			ПараметрыПриИзменении(Элемент);
		КонецЕсли;
	Иначе
		ПараметрыПриИзменении(Элемент);
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура СпособХраненияМетокСтатусовПриИзменении(Элемент)
	
	Если СпособХраненияМетокСтатусов = МестныйКэш.Парам.СпособХраненияМетокСтатусов Тогда
		Возврат
	КонецЕсли;
	Попытка
		ИзменитьСпособХраненияМетокСтатусов(СпособХраненияМетокСтатусов);
	Исключение
		МодульОбъектаКлиент().СообщитьСбисИсключение(ИнформацияОбОшибке(), "ФормаНастройки.СпособХраненияМетокСтатусовПриИзменении")
	КонецПопытки;
	
КонецПроцедуры

// << alo Меркурий
&НаКлиенте
Процедура МеркурийПриИзменении(Элемент=Неопределено) Экспорт
	ПараметрыПриИзменении(МестныйКэш.ГлавноеОкно.сбисЭлементФормы(ЭтаФорма, "Меркурий"));
	
	СписокДокументов = Новый СписокЗначений;
	Для Каждого Ини Из МестныйКэш.Ини Цикл
		ЗначениеИни = МестныйКэш.ФормаНастроек.Ини(МестныйКэш, Ини.Ключ);
		Если ЗначениеИни.Свойство("мФайл") И ЗначениеИни.мФайл.Свойство("АктРасхождение") Тогда
			СписокДокументов.Добавить(Ини.Ключ);
		КонецЕсли;
	КонецЦикла;
	Если ЗначениеЗаполнено(СписокДокументов) Тогда
		ИмяФайлаОбработки = МестныйКэш.ПараметрыСистемы.Обработка.ПолноеИмяОбработки;
		ВидДопОбработокПечатнаяФорма = неопределено;
		Если МестныйКэш.Ини.Конфигурация.Свойство("ВидДопОбработокПечатнаяФорма") Тогда
			ВидДопОбработокПечатнаяФорма = МестныйКэш.ОбщиеФункции.РассчитатьЗначениеНаСервере("ВидДопОбработокПечатнаяФорма", Новый Структура("Ини", МестныйКэш.Ини.Конфигурация));
		КонецЕсли;
		ПараметрыФормированияНаСервере = Новый Структура("ПометкаУдаления, ПредставлениеПФ, ИдентификаторКоманды, УправляемоеПриложение, ВидДопОбработокПечатнаяФорма, СписокДокументов", 
		(Не Меркурий), "Погасить ВСД", "sbis1cПогаситьВСД", МестныйКэш.ПараметрыСистемы.Клиент.УправляемоеПриложение, ВидДопОбработокПечатнаяФорма, СписокДокументов);
		Попытка
			Если МестныйКэш.ПараметрыСистемы.Обработка.РежимИспользования = "Файл внешней обработки" Тогда
				ОбработкаХранитсяВСправочнике = Ложь;
				ДвоичныеДанныеОбработки = Новый ДвоичныеДанные(ИмяФайлаОбработки);
			Иначе
				ОбработкаХранитсяВСправочнике = Истина;
				ДвоичныеДанныеОбработки = Неопределено;
			КонецЕсли;
			ДанныеОбработки  = Новый Структура("ДвоичныеДанныеОбработки, ОбработкаХранитсяВСправочнике", ДвоичныеДанныеОбработки, ОбработкаХранитсяВСправочнике);
			МестныйКэш.ФормаНастроекОбщее.сбисДобавитьПечатныеФормыНаСервере(ДанныеОбработки, ПараметрыФормированияНаСервере);
			МестныйКэш.ФормаНастроекОбщее.СбисДобавитьКомандыПечатиНаФормы(МестныйКэш,, ПараметрыФормированияНаСервере);	
		Исключение
			РезультатОбновления = МестныйКэш.ОбщиеФункции.СбисИсключение(, "ФайлыНастроекОбщее.СбисДобавитьПечатныеФормы", 700, "Неизвестная ошибка подключения", ОписаниеОшибки());
			СбисПараметрыСтатистики = Новый Структура("Действие, Ошибка", "Запись ошибки", РезультатОбновления);
			МестныйКэш.ОбщиеФункции.сбисСтатистика_СформироватьИЗаписатьСтатистикуНаСервис(МестныйКэш, СбисПараметрыСтатистики, Ложь);
		КонецПопытки;
	КонецЕсли;
КонецПроцедуры // alo Меркурий >> 

//Процедура записывает в местный и глобальный кэш измененный параметр	
&НаКлиенте
Процедура ПараметрыПриИзменении(Элемент) Экспорт 
	
	ПутьКДаннымФормы = Сред(Элемент.Имя, Найти(Элемент.Имя, "_") + 1); 

	Если ИзмененныеПараметры.Свойство(ПутьКДаннымФормы) И МестныйКэш.Парам[ПутьКДаннымФормы] = ЭтаФорма[ПутьКДаннымФормы] Тогда
		ИзмененныеПараметры.Удалить(ПутьКДаннымФормы);	
	Иначе 
		ИзмененныеПараметры.Вставить(ПутьКДаннымФормы, ПутьКДаннымФормы);	
	КонецЕсли; 
	
	ОбновитьДоступностьНастроек();
	
КонецПроцедуры

&НаКлиенте
Процедура ПараметрыСтатусовПриИзменении(Элемент) Экспорт
	
	Если	МестныйКэш.ГлавноеОкно.ДатаПоследнегоЗапросаСтатусов = ДатаПоследнегоЗапросаСтатусов
		И	МестныйКэш.ГлавноеОкно.ИдентификаторПоследнегоСобытия = ИдентификаторПоследнегоСобытия Тогда
		Возврат;
	КонецЕсли;
		
	МестныйКэш.ГлавноеОкно.ДатаПоследнегоЗапросаСтатусов = ДатаПоследнегоЗапросаСтатусов;
	МестныйКэш.ГлавноеОкно.ИдентификаторПоследнегоСобытия = ИдентификаторПоследнегоСобытия;
	
	МодульОбъектаКлиент().СохранитьМеткиСтатусов(МестныйКэш);
	
КонецПроцедуры

&НаКлиенте
Процедура УдалятьПрефиксыПриИзменении(Элемент)
	
	ПараметрыПриИзменении(Элемент);  
	ПараметрыОчистки = Новый Структура("Тип, Ключ", "ПользовательскиеЗначения.Функции", "НомерДокумента");
	МестныйКэш.ОбщиеФункции.сбисОчиститьЗначениеРассчитанногоОбъекта(МестныйКэш, ПараметрыОчистки);

КонецПроцедуры

&НаКлиенте
Процедура ШифроватьВыборочноПриИзменении(Элемент)
	
	ПараметрыПриИзменении(Элемент);
	
КонецПроцедуры

&НаКлиенте
Процедура АдресСервисаОбновленийПриИзменении(Элемент)
	
	//+++ МАИ 09.09.2021 Переопределяем сервер обновлений, если пользователь в режиме отладки указал другой
	МестныйКэш.СБИС.ПараметрыИнтеграции.Вставить("АдресСервисаОбновлений", АдресСервисаОбновлений);
	//--- МАИ 09.09.2021

КонецПроцедуры

&НаКлиенте
Процедура РежимОтладкиПриИзменении(Элемент)
	
	Если РежимОтладки Тогда
		КаталогОтладки = ?(ЗначениеЗаполнено(КаталогОтладки), КаталогОтладки, КаталогНастроек);	
	КонецЕсли;
	
	Если НЕ МестныйКэш.ГлавноеОкно.сбисЭлементФормы(ЭтаФорма, "НадписьАдресСервисаОбновлений") = Неопределено Тогда 
		МестныйКэш.ГлавноеОкно.сбисЭлементФормы(ЭтаФорма, "НадписьАдресСервисаОбновлений").Видимость = РежимОтладки;   
	КонецЕсли;	
	МестныйКэш.ГлавноеОкно.сбисЭлементФормы(ЭтаФорма, "АдресСервисаОбновлений").Видимость = РежимОтладки;
	
	КаталогИзменен = МестныйКэш.Интеграция.УстановитьКаталогОтладки(МестныйКэш);
	сбисПереключитьОтладку();
	СбисЗаполнитьАдресСервера(МестныйКэш);
	
КонецПроцедуры

&НаКлиенте
Процедура КаталогОтладкиНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	КаталогОтладки = сбисВыбратьКаталог(КаталогОтладки); 
	ПараметрыПриИзменении(Элемент);
	КаталогИзменен = МестныйКэш.Интеграция.УстановитьКаталогОтладки(МестныйКэш);
	
	Если КаталогИзменен Тогда
		сбисПереключитьОтладку();	
	КонецЕсли;

КонецПроцедуры

&НаКлиенте
Процедура КаталогОтладкиОткрытие(Элемент, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	МестныйКэш.ГлавноеОкно.сбисОткрытьКаталог(КаталогОтладки);

КонецПроцедуры

&НаКлиенте
Процедура КаталогОтладкиПриИзменении(Элемент)
	
	ПараметрыПриИзменении(Элемент);
	КаталогОтладки = МестныйКэш.ОбщиеФункции.СбисФорматКаталога(КаталогОтладки, МестныйКэш.ПараметрыСистемы.Клиент);
	КаталогИзменен = МестныйКэш.Интеграция.УстановитьКаталогОтладки(МестныйКэш);
		
	Если КаталогИзменен Тогда
		сбисПереключитьОтладку();	
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура Таблица_СервисВыбор(Элемент, ВыбраннаяСтрока, Поле, СтандартнаяОбработка)
	//alo
	ТекущиеДанныеСтроки = ВыбраннаяСтрока;
	Если МестныйКэш.ПараметрыСистемы.Клиент.УправляемоеПриложение Тогда
		ТекущиеДанныеСтроки = Элемент.ТекущиеДанные;
	КонецЕсли;
	Контекст = Новый структура(ТекущиеДанныеСтроки.Ключ, ТекущиеДанныеСтроки.Команда);
	Контекст.Вставить("Кэш", МестныйКэш);
	МестныйКэш.ОбщиеФункции.РассчитатьЗначение(ТекущиеДанныеСтроки.Ключ, Контекст, МестныйКэш);
КонецПроцедуры

&НаКлиенте
Процедура ЗаполнениеКонтрагента1СПриИзменении(Элемент)
	
	Настройки = НастройкиЭлементовЗаполненияКонтрагента1С();	
	ОбновитьНастройкиЭлементовФормы(Настройки.СписокЭлементов, Настройки.ПараметрыНастройки);

КонецПроцедуры

