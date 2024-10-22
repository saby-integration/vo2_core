
////////////////////////////////////////////////////
///////////////Результат действия///////////////////
////////////////////////////////////////////////////

//Функция описания типового результата выполнения действия
&НаКлиенте
Функция РезультатДействия_Получить(Кэш, ДопПараметры, НовоеДействие=Ложь) Экспорт 
	РезультатДействия = Неопределено;
	Если		НовоеДействие
		Или Не	Кэш.Свойство("РезультатДействия", РезультатДействия) Тогда 
		РезультатДействия = РезультатДействия_Новый(Кэш, ДопПараметры);
		Кэш.Вставить("РезультатДействия", РезультатДействия);
	КонецЕсли;
	Возврат РезультатДействия;
КонецФункции

//Функция описания типового результата выполнения действия
&НаКлиенте
Функция РезультатДействия_Новый(Кэш, ДопПараметры) Экспорт
	РезультатДействия = Новый Структура(
	"Время,	Всего,	Действие,	Ошибки,	Параметры", 
	Новый Структура("Запись, Начало, Конец, ОжиданиеОтвета, Выполнение, ПолучениеДанных, Подготовка",0,0,0,0,0,0,0), 
			Новый Структура("Выполнено, НеВыполнено, ОшибокВыполнения, ОшибокПодготовки", 0,0,0,0),
					Новый Структура("ДетализацияВыполнено, ДетализацияНеВыполнено", Новый Соответствие,Новый Соответствие),
								Новый Структура("ДетализацияОшибок,СоответствиеКодов", Новый Соответствие,Новый Соответствие),
										Новый Структура("КоличествоСвободныхПотоков, КоличествоОтветов, ПорНомер, ПредставлениеОперации, ФормаВызова, СформированныеДанные, ДанныеПоСтатусам", 30));
	РезультатДействия.Время.Начало = СбисТекущаяДатаВМиллисекундах(Кэш);
	Если ЗначениеЗаполнено(ДопПараметры) Тогда
		РезультатДействия_Заполнить(РезультатДействия, ДопПараметры);
	КонецЕсли;
	Если	ДопПараметры.Свойство("СтатусыДляОбработки")
		И	ДопПараметры.СтатусыДляОбработки Тогда
		РезультатДействия.Вставить("НаЗаписьСтатусов", Новый Структура("Ошибки, Ответы", Новый Соответствие, Новый Соответствие));
	КонецЕсли;
	Если РезультатДействия.Параметры.ПредставлениеОперации = "Обновление" Тогда
		РезультатДействия.Параметры.Вставить("ВерсияБыло",	МодульОбъектаКлиент().ПолучитьЗначениеПараметраСбис("ПредВерсия"));
		РезультатДействия.Параметры.Вставить("ВерсияНовая",	Кэш.ПараметрыСистемы.Обработка.Версия);
	КонецЕсли;
	// ВААл.
	// Временно. До выполнения https://dev.saby.ru/opendoc.html?guid=dd2e9551-cb7a-418e-9d34-032d93a8c6e1&client=3
	Если ДопПараметры.Свойство("ПрикладнаяСтатистика") Тогда
		РезультатДействия.Вставить("ПрикладнаяСтатистика", ДопПараметры.ПрикладнаяСтатистика);
	КонецЕсли;
	Возврат РезультатДействия;
КонецФункции

//Сообщает пользователю результат выполнения действия.
&НаКлиенте
Процедура РезультатДействия_СообщитьРезультат(РезультатДействия, ДопПараметры) Экспорт
	Перем СообщитьВыполнено, СообщитьНеВыполнено, СообщитьОшбики, ПараметрыСообщить;
	//Значения по-умолчанию.
	Если Не ДопПараметры.Свойство("СообщитьВыполнено", СообщитьВыполнено) Тогда
		СообщитьВыполнено = Истина;
	КонецЕсли;
	Если Не ДопПараметры.Свойство("СообщитьОшибки", СообщитьОшбики) Тогда
		СообщитьОшбики = Истина;
	КонецЕсли;
	Если Не ДопПараметры.Свойство("СообщитьНеВыполнено", СообщитьНеВыполнено) Тогда
		СообщитьНеВыполнено = Истина;
	КонецЕсли;
	Если Не ДопПараметры.Свойство("ПараметрыСообщить", ПараметрыСообщить) Тогда
		ПараметрыСообщить = Новый Структура();
		Если		РезультатДействия.Параметры.ПредставлениеОперации = "ЗагрузкаДокумента" Тогда
			ПараметрыСообщить.Вставить("Выполнено",		Новый Структура("Текст", "Вложение %Название% загружено. "));
			ПараметрыСообщить.Вставить("НеВыполнено",	Новый Структура("Текст", "Вложение %Название% не загружено. "));
			ПараметрыСообщить.Вставить("Ошибки",		Новый Структура("Текст, Статус", "Вложение %Название% не загружено. ", СтатусСообщения.Внимание));
		ИначеЕсли	РезультатДействия.Свойство("Операция")
				И	РезультатДействия.Операция = "ОбновлениеСтатусов" Тогда
			ПараметрыСообщить.Вставить("Выполнено",		Новый Структура("Текст", "%Название% выполнено. "));
			ПараметрыСообщить.Вставить("НеВыполнено",	Новый Структура("Текст", "%Название% не выполнено. "));
			ПараметрыСообщить.Вставить("Ошибки",		Новый Структура("Текст, Статус", "%Название% завершено с ошибками. ", СтатусСообщения.Внимание));			
		Иначе
			ПараметрыСообщить.Вставить("Выполнено",		Новый Структура("Текст", "Вложение %Название% обработано. "));
			ПараметрыСообщить.Вставить("НеВыполнено",	Новый Структура("Текст", "Вложение %Название% не обработано. "));
			ПараметрыСообщить.Вставить("Ошибки",		Новый Структура("Текст, Статус", "Вложение %Название% не обработано. ", СтатусСообщения.Внимание));			
		КонецЕсли;
		ПараметрыСообщить.Ошибки.Вставить("КлючДанныеЛог", "Исключение");
	КонецЕсли;
	//Показываем детализации
	Если СообщитьВыполнено Тогда
		РезультатДействия_СообщитьДетализацию(РезультатДействия.Действие.ДетализацияВыполнено, ПараметрыСообщить.Выполнено);
	КонецЕсли;
	Если СообщитьНеВыполнено Тогда
		РезультатДействия_СообщитьДетализацию(РезультатДействия.Действие.ДетализацияНеВыполнено, ПараметрыСообщить.НеВыполнено);
	КонецЕсли;
	Если СообщитьОшбики Тогда
		РезультатДействия_СообщитьДетализацию(РезультатДействия.Ошибки.ДетализацияОшибок, ПараметрыСообщить.Ошибки);
	КонецЕсли;	
	
	// ВААл.
	// Спилить по https://dev.saby.ru/opendoc.html?guid=dd2e9551-cb7a-418e-9d34-032d93a8c6e1&client=3
	Если РезультатДействия.Свойство("ПрикладнаяСтатистика") Тогда
		МодульОбъектаКлиент().ПрикладнаяСтатистика_Отправить(РезультатДействия.ПрикладнаяСтатистика);
	КонецЕсли;
	
КонецПроцедуры

//Сообщает все строки из детализации Действие, либо Ошибки
&НаКлиенте
Процедура РезультатДействия_СообщитьДетализацию(ЭлементДетализации, ДопПараметры) 
	СтатусСообщений = Неопределено;
	Если Не ДопПараметры.Свойство("Статус", СтатусСообщений) Тогда
		СтатусСообщений = СтатусСообщения.Обычное;
	КонецЕсли;

	СбисРежимОтладки = МодульОбъектаКлиент().ПолучитьЗначениеПараметраСбис("РежимОтладки");
	ДанныеВЛог = Новый Массив;
	Для Каждого КлючИЗначение Из ЭлементДетализации Цикл
		Для Каждого СтрокаДетализации Из КлючИЗначение.Значение Цикл
			ТекстДетализации = Неопределено;
			Если ДопПараметры.Свойство("Текст", ТекстДетализации) Тогда 
				СообщитьДетализацию	= Истина;
				ТекстДетализации	= СтрЗаменить(ТекстДетализации, "%Название%", СтрокаДетализации.Название);
			Иначе
				СообщитьДетализацию = Ложь;
			КонецЕсли;
			Если Не ПустаяСтрока(СтрокаДетализации.Сообщение) Тогда
				Сообщить(?(СообщитьДетализацию, ТекстДетализации, "") + СтрокаДетализации.Сообщение, СтатусСообщений);
				СообщитьДетализацию = Ложь;
			КонецЕсли;
			Если СтрокаДетализации.ОбработаныОбъекты1С.Количество() = 1 Тогда
				Сообщить(?(СообщитьДетализацию, ТекстДетализации, "") + СтрокаДетализации.ОбработаныОбъекты1С[0].Сообщение, СтатусСообщений);
			Иначе
				Если СообщитьДетализацию Тогда
					Сообщить(ТекстДетализации, СтатусСообщений);
					СообщитьДетализацию = Ложь;
				КонецЕсли;
				Для Каждого СтрокаРасшифровки Из СтрокаДетализации.ОбработаныОбъекты1С Цикл
					Сообщить(СтрокаРасшифровки.Сообщение, СтатусСообщений);
				КонецЦикла;
			КонецЕсли;
			Если СбисРежимОтладки Тогда
				Если ДопПараметры.Свойство("КлючДанныеЛог") Тогда
					лОтладочныеДанные = Новый Структура(ДопПараметры.КлючДанныеЛог, СтрокаДетализации.Данные);
					ДанныеВЛог.Добавить(лОтладочныеДанные);
				КонецЕсли;
			КонецЕсли;
		КонецЦикла;
	КонецЦикла;
	Если СбисРежимОтладки Тогда
		МодульОбъектаКлиент().СохранитьОтладочныеДанныеСБИС(Новый Структура("Log", ДанныеВЛог));
	КонецЕсли;
	
КонецПроцедуры

//Дозаполняет поля результата переданными параметрами
&НаКлиенте
Процедура РезультатДействия_Заполнить(РезультатДействия, ДопПараметры)
	
	Для Каждого КлючИЗначение Из РезультатДействия Цикл
		Если ТипЗнч(КлючИЗначение.Значение) = Тип("Структура") Тогда
			РезультатДействия_Заполнить(КлючИЗначение.Значение, ДопПараметры);
		КонецЕсли;
	КонецЦикла;
	Для Каждого КлючИЗначение Из ДопПараметры Цикл
		Если РезультатДействия.Свойство(КлючИЗначение.Ключ) Тогда
			РезультатДействия[КлючИЗначение.Ключ] = КлючИЗначение.Значение;
		КонецЕсли;
	КонецЦикла;
	
КонецПроцедуры

//Добавляет строку в детализацию ошибок.
//Кэш - структура кэш
//РезультатДействия - Структура "РезультатДействия", в который добавляется ошибка.
//ЭлементДетализации - Струкутра, полученная РезультатДействия_СформироватьСтрокуДетализации
//ПараметрыОшибки - Структура СбисИсключение - Code, message, details
//ДопПараметры - Структура для возможности перегрузки стандартного добавления. ТипОшибки, ПараметрыСчетчика
&НаКлиенте
Процедура РезультатДействия_ДобавитьОшибку(Кэш, РезультатДействия, ЭлементДетализации, ПараметрыОшибки, ДопПараметры=Неопределено, Отказ=Ложь) Экспорт
	
	Отказ = Истина;
	РасширенноеОписаниеОшибки = ПараметрыОшибки.details;
	ТекстОшибки				= Неопределено;
	КодОшибки				= Неопределено;
	ТипОшибки				= Неопределено;
	сбисПараметрыСчетчика	= Неопределено;
	Если Не ПараметрыОшибки.Свойство("message",ТекстОшибки) Тогда
		//Если нет кода ошибки, то считаем её как 100.
		ТекстОшибки = "Неизвестная ошибка системы";
	КонецЕсли;
	Если Не ПараметрыОшибки.Свойство("code",КодОшибки) Тогда
		//Если нет кода ошибки, то считаем её как 100.
		КодОшибки = 100;
	КонецЕсли;
	Если КодОшибки = 100 Тогда
		//Если ошибка - 100, то проверяем наличие ошибки в соответствии кодов. (Можно будет добавить соответствие основных кодов ошибок)
		КодОшибки = РезультатДействия.Ошибки.СоответствиеКодов.Получить(ТекстОшибки);
		Если Не ЗначениеЗаполнено(КодОшибки) Тогда
			КодОшибки = 100;
		КонецЕсли;
	КонецЕсли;
	РезультатДействия.Ошибки.СоответствиеКодов.Вставить(ТекстОшибки, КодОшибки);
	
	Если ДопПараметры = Неопределено Тогда
		ДопПараметры = Новый Структура;
	КонецЕсли;
	Если Не	ДопПараметры.Свойство("ТипОшибки", ТипОшибки) Тогда
		ТипОшибки = "Выполнение";
	КонецЕсли;
	Если Не	ДопПараметры.Свойство("ПараметрыСчетчика", сбисПараметрыСчетчика) Тогда
		сбисПараметрыСчетчика = Новый Структура;
	КонецЕсли;
	ДопПараметр = Неопределено;
	Если ДопПараметры.Свойство("КлючДетализацииУдалить",ДопПараметр) Тогда
		//Очищаем из детализации результата ключ детализации, если необходимо
		ЭлементДетализации = РезультатДействия.Действие.ДетализацияДействия.Свойство(ДопПараметр);
		Если Не ЭлементДетализации = Неопределено Тогда
			РезультатДействия.Действие.ДетализацияДействия.Удалить(ДопПараметр);
		КонецЕсли;
	КонецЕсли;
	Если	сбисПараметрыСчетчика.Свойство("ОбработанКакУспех")
		И	сбисПараметрыСчетчика.ОбработанКакУспех Тогда
		РезультатДействия.Всего.Выполнено = РезультатДействия.Всего.Выполнено - 1;
		сбисПараметрыСчетчика.ОбработанКакУспех = Ложь;
	КонецЕсли;
	Если	Не сбисПараметрыСчетчика.Свойство("ОбработанКакОшибка")
		Или	Не сбисПараметрыСчетчика.ОбработанКакОшибка Тогда
		Если ТипОшибки = "Выполнение" Тогда
			РезультатДействия.Всего.ОшибокВыполнения = РезультатДействия.Всего.ОшибокВыполнения + 1;
		Иначе
			РезультатДействия.Всего.ОшибокПодготовки = РезультатДействия.Всего.ОшибокПодготовки + 1;
		КонецЕсли;
		сбисПараметрыСчетчика.Вставить("ОбработанКакОшибка", Истина);
	КонецЕсли;
	ЭлементСоответствия = РезультатДействия.Ошибки.ДетализацияОшибок.Получить(ТекстОшибки);
	Если ЭлементСоответствия=Неопределено Тогда
		ЭлементСоответствия = Новый Массив;
		РезультатДействия.Ошибки.ДетализацияОшибок.Вставить(ТекстОшибки, ЭлементСоответствия);
	КонецЕсли;
	ЭлементДетализации.Сообщение	= РасширенноеОписаниеОшибки;
	ЭлементДетализации.Данные		= ПараметрыОшибки;
	ЭлементСоответствия.Добавить(ЭлементДетализации);
	РезультатДействия_ДобавитьВремя(Кэш, РезультатДействия, ТипОшибки);
	
КонецПроцедуры	

//Добавляет строку в детализацию результата, в зависимости от того, было выполнено, или нет.
&НаКлиенте
Процедура РезультатДействия_ДобавитьРезультат(Кэш, РезультатДействия, ЭлементДетализации=Неопределено, ПараметрыРезультат, ДопПараметры=Неопределено) Экспорт
	
	Перем КлючГруппировки, КлючДобавления, СбисПараметрыСчетчика, СбисСчитать;
	
	КлючДобавления	= "Выполнено";
	СбисТип			= "Выполнение";
	Если Не ДопПараметры = Неопределено Тогда
		Если ДопПараметры.Свойство("Тип") Тогда
			сбисТип = ДопПараметры.Тип;
		КонецЕсли;
	Иначе
		сбисПараметрыСчетчика = Новый Структура;
	КонецЕсли;
	Если	Не	ПараметрыРезультат.Свойство("Считать", СбисСчитать) Тогда
		СбисСчитать = Истина;
	КонецЕсли;
	Если		ПараметрыРезультат.Свойство("Выполнено") 
		И	Не	ПараметрыРезультат.Выполнено Тогда
		КлючДобавления = "Не" + КлючДобавления;
	КонецЕсли;
	Если Не ПараметрыРезультат.Свойство("КлючГруппировки", КлючГруппировки) Тогда
		КлючГруппировки = "-";
	КонецЕсли;
	Если Не	ПараметрыРезультат.Свойство("ПараметрыСчетчика", сбисПараметрыСчетчика) Тогда
		сбисПараметрыСчетчика = Новый Структура;
	КонецЕсли;
	//Если указан добавляемый элемент детализации, то ставим его в соответствующее место в результате выполнено/невыполнено
	Если Не ЭлементДетализации = Неопределено Тогда 
		ЭлементДляВставки = РезультатДействия.Действие["Детализация" + КлючДобавления].Получить(КлючГруппировки);
		Если ЭлементДляВставки = Неопределено Тогда
			ЭлементДляВставки = Новый Массив; 
			РезультатДействия.Действие["Детализация" + КлючДобавления].Вставить(КлючГруппировки, ЭлементДляВставки);
		КонецЕсли;	
		ЭлементДляВставки.Добавить(ЭлементДетализации);
	КонецЕсли;
	
	Если СбисСчитать Тогда
		//Делаем итерацию по счетчику. Если уже обработан как ошибка, или успех то не считаем.
		Если	(	Не сбисПараметрыСчетчика.Свойство("ОбработанКакУспех")
			Или	Не сбисПараметрыСчетчика.ОбработанКакУспех)
			И	(	Не сбисПараметрыСчетчика.Свойство("ОбработанКакОшибка")
			Или	Не сбисПараметрыСчетчика.ОбработанКакОшибка) Тогда
			РезультатДействия.Всего[КлючДобавления] = РезультатДействия.Всего[КлючДобавления] + 1;
			сбисПараметрыСчетчика.Вставить("ОбработанКакУспех", Истина);
		КонецЕсли;
	КонецЕсли;
	РезультатДействия_ДобавитьВремя(Кэш, РезультатДействия, сбисТип);
	
КонецПроцедуры	

//Обновляет счетчики времени в результате
&НаКлиенте
Процедура РезультатДействия_ДобавитьВремя(Кэш, РезультатДействия, Тип) Экспорт
	
	РезультатДействия.Время.Конец = сбисТекущаяДатаВМиллисекундах(Кэш);
	сбисВремя = РезультатДействия.Время.Конец - РезультатДействия.Время.Начало;
	Для Каждого КлючИЗначение Из РезультатДействия.Время Цикл
		Если	КлючИЗначение.Ключ = "Начало"
			Или	КлючИЗначение.Ключ = "Конец" Тогда
			Продолжить;
		КонецЕсли;
		сбисВремя = сбисВремя - КлючИЗначение.Значение;
	КонецЦикла;
	РезультатДействия.Время[Тип] = РезультатДействия.Время[Тип] + сбисВремя;
	
КонецПроцедуры

//Формирует строку для детализации
&НаКлиенте
Функция РезультатДействия_СформироватьСтрокуДетализации(Кэш, Тип="", ДопПараметры=Неопределено) Экспорт
	
	СтрокаРезультат = Новый Структура("ОбработаныОбъекты1С, Состояние, Сообщение, Название, Данные", Новый Массив, "", "");
	Если Тип = "Загрузка" Тогда
		СтрокаРезультат.Вставить("ИдентификаторПакета");
		СтрокаРезультат.Вставить("ИдентификаторВложения");
	КонецЕсли;
	Если Не ДопПараметры = Неопределено Тогда
		Если ДопПараметры.Свойство("Название") Тогда
			СтрокаРезультат.Название = ДопПараметры.Название
		КонецЕсли;
	КонецЕсли;
	Возврат СтрокаРезультат;
	
КонецФункции

//Вынесено в отдельный метод, чтобы формирование результата было в одном месте. Генерирует строку обработанного объекта 1С в детализации
&НаКлиенте
Процедура РезультатДействия_ДобавитьВРасшифровку(Кэш, ТипДетализации, СтрокаДетализации, ПараметрыОбъекта) Экспорт
	//Добавляем обработанный объект в массив детализации
	СтрокаДобавить = Новый Структура("Ошибки, Ссылка, Тип, Состояние, Сообщение", Ложь);
	ЗаполнитьЗначенияСвойств(СтрокаДобавить, ПараметрыОбъекта);
	
	Если	Кэш.РезультатДействия.Параметры.ФормаВызова = "ФормаПросмотрДокумента"
		И	ТипДетализации = "ЗагрузкаДокумента" Тогда
		СтруктураДокумента1С = Неопределено;
		Если Не ПараметрыОбъекта.Свойство("СтруктураДокумента1С", СтруктураДокумента1С) Тогда
			СтруктураДокумента1С = Новый Структура;
		КонецЕсли;
		СтрокаДобавить.Вставить("СтруктураДокумента1С", СтруктураДокумента1С);
	КонецЕсли;
	СтрокаДетализации.ОбработаныОбъекты1С.Добавить(СтрокаДобавить);
	
КонецПроцедуры	

//Функция для методов, в которые нормально никак не передать дополнительные аргументы. Извлекает детализацию из результата в кэше.
&НаКлиенте
Функция РезультатДействия_ИзвлечьВременныеДанные(Кэш) Экспорт 
	
	Результат = Новый Структура("ЗаполнитьДетализацию, Отказ", Ложь, Ложь);
	ВременныеДанные = Неопределено;
	Если	Кэш.Свойство("РезультатДействия", ВременныеДанные)
		И	ЗначениеЗаполнено(ВременныеДанные)
		И	ВременныеДанные.Свойство("ВременныеДанные",ВременныеДанные)
		И	ЗначениеЗаполнено(ВременныеДанные)
		И	ВременныеДанные.Свойство("ЗаполнитьДетализацию")Тогда
		Результат = ВременныеДанные;
	КонецЕсли;
	Возврат Результат;
КонецФункции

