
//Выполняет указанный метод и возвращает результат, либо генерирует и сообщает ошибку.
//Дополнительные параметры - структура, для управления выводом и возвратом результата в случае ошибок. 
//	Возможные значения: СообщатьПриОшибке(Истина),ВернутьОшибку(Ложь),ЕстьРезультат(Ложь), ЖдатьОтвета(Истина). 
//	Так же в качестве дополнительного параметра может быть передана структура Поток и Идентификатор для выполнения запроса.
//Отказ - булево, определяет наличие ошибок в процессе выполнения метода и что вернулось в качестве результата. Если Истина, то структура ошибки с полями "code, message, details"
&НаКлиенте
Функция СбисОтправитьИОбработатьКоманду(Кэш,Метод,ПараметрыМетода=Неопределено,ДопПараметры,Отказ) Экспорт
	
	ДопПараметрыДляВызовов	= Новый Структура("Кэш, ДополнительныеПараметры, Метод, ИмяМодуля", Кэш, ДопПараметры, Метод, МодульОбъектаКлиент().ПолучитьЗначениеПараметраСбис("ИнтеграцияИмя"));
	СобытияКоманды			= Новый Структура;
	ПараметрыОбработчика	= Новый Структура("Метод, ПараметрыМетода", Метод,ПараметрыМетода);
	ПараметрыКоманды		= Новый Структура("ПодпискиНаСобытия, АргументВызова, ПараметрыСобытий, ОчиститьПараметры", СобытияКоманды, ПараметрыОбработчика, ДопПараметрыДляВызовов, Ложь);
	Если ДопПараметры.Свойство("ОчиститьПараметры") Тогда
		ПараметрыКоманды.ОчиститьПараметры = ДопПараметры.ОчиститьПараметры;
	КонецЕсли;
	
	СобытияКоманды.Вставить("Error",		Новый Структура("Функция, Модуль",					"СбисОтправитьИОбработатьКоманду_Ошибка",	ЭтаФорма));
	СобытияКоманды.Вставить("Message",		Новый Структура("Функция, Модуль, ФункцияОшибки",	"СбисОтправитьИОбработатьКоманду_Ответ",	ЭтаФорма, "СбисОтправитьИОбработатьКоманду_Ошибка"));

	ОбработчикКоманды		= МодульОбъектаКлиент().НовыйСбисОписаниеОповещения("СбисОтправитьКоманду_Асинхронно", ЭтаФорма, ДопПараметрыДляВызовов);
	АсинхроннаяСбисКоманда	= МодульОбъектаКлиент().НовыйАсинхроннаяСбисКоманда(ОбработчикКоманды, ПараметрыКоманды);
	
	Результат = МодульОбъектаКлиент().АсинхроннаяСбисКоманда_ОтправитьИДождатьсяОтвета(АсинхроннаяСбисКоманда);
	Если Результат.Тип = "Error" Тогда
		Отказ = Истина;
	КонецЕсли;
		
	Возврат Результат.Данные;
	
КонецФункции
	
//Выполняет указанный метод и возвращает результат, либо генерирует и сообщает ошибку.
//Дополнительные параметры - структура, для управления выводом и возвратом результата в случае ошибок. 
//	Возможные значения: СообщатьПриОшибке(Истина),ВернутьОшибку(Ложь),ЕстьРезультат(Ложь), ЖдатьОтвета(Истина). 
//	Так же в качестве дополнительного параметра может быть передана структура Поток и Идентификатор для выполнения запроса.
//Отказ - булево, определяет наличие ошибок в процессе выполнения метода и что вернулось в качестве результата. Если Истина, то структура ошибки с полями "code, message, details"
&НаКлиенте
Процедура СбисОтправитьКоманду_Асинхронно(АсинхроннаяСБИСКоманда, ПараметрыКомандыВыполнить) Экспорт

	ДопПараметры	= ПараметрыКомандыВыполнить.ДополнительныеПараметры;
	Кэш				= ПараметрыКомандыВыполнить.Кэш;
	Отказ			= Ложь;
	КомандаПлагина	= НовыйСбисПлагинКоманда(Кэш, АсинхроннаяСБИСКоманда, ДопПараметры);
	РезультатВызова = СБИСПлагин_ВыполнитьМетод(ПараметрыКомандыВыполнить.Кэш, КомандаПлагина, ДопПараметры, Отказ);
	
	Если Отказ Тогда
		МодульОбъектаКлиент().ВызватьСбисИсключение(РезультатВызова, Кэш.СБИС.ПараметрыИнтеграции.ИнтеграцияИмя + ".СбисОтправитьКоманду_Асинхронно");
	КонецЕсли;
	
	//Установить более точно время вызова
	АсинхроннаяСБИСКоманда.ВремяВызова = КомандаПлагина.ВремяВызова;

КонецПроцедуры

//Обработка события успешного выполнения метода
&НаКлиенте
Процедура СбисОтправитьИОбработатьКоманду_Ответ(РезультатВызова, ПараметрыОбработки) Экспорт
	
	//Переопределить ответ
	Если РезультатВызова.Данные.Свойство("Result") Тогда
		РезультатВызова.Данные = РезультатВызова.Данные.Result;
	КонецЕсли;	

КонецПроцедуры

//Обработка события ошибки отправки
&НаКлиенте
Процедура СбисОтправитьИОбработатьКоманду_Ошибка(АсинхронноеСбисСобытие, ПараметрыОбработки) Экспорт
 	Перем message_result, message_type, checkResult, КомандаЗавершена;

	ДопПараметры		= ПараметрыОбработки.ДополнительныеПараметры;
	Кэш					= ПараметрыОбработки.Кэш;

	АсинхронноеСбисСобытие.Данные = МодульОбъектаКлиент().НовыйСбисИсключение(АсинхронноеСбисСобытие.Данные, ПараметрыОбработки.ИмяМодуля + "." + ПараметрыОбработки.Метод);
	Если Не ДопПараметры.Свойство("СообщатьПриОшибке")
		Или	ДопПараметры.СообщатьПриОшибке Тогда
		Кэш.ГлавноеОкно.сбисСообщитьОбОшибке(Кэш, АсинхронноеСбисСобытие.Данные);
	КонецЕсли;
	Если 	(	ДопПараметры.Свойство("ВернутьОшибку")
		И	Не	ДопПараметры.ВернутьОшибку) Тогда
		АсинхронноеСбисСобытие.Данные = Неопределено;
	КонецЕсли;

КонецПроцедуры

//Класс команды для вызова СБИС3 плагина
&НаКлиенте
Функция НовыйСбисПлагинКоманда(Кэш, АсинхроннаяСбисКоманда, ДопПараметры=Неопределено) Экспорт
	Перем СбисАккаунт;
	
	СбисПараметрыМетода = АсинхроннаяСбисКоманда.АргументВызова.ПараметрыМетода;
	СбисМетод			= АсинхроннаяСбисКоманда.АргументВызова.Метод;
	СбисИдЗапроса		= АсинхроннаяСбисКоманда.Идентификатор;
	СбисОжиданиеОтвета	= АсинхроннаяСбисКоманда.ВремяОжиданияОтвета;
	СбисМодуль			= МодульОбъектаКлиент().ПолучитьЗначениеПараметраСбис("ИнтеграцияИмя");
	Если СбисПараметрыМетода = Неопределено Тогда
		СбисПараметрыМетода = Новый Структура;
	КонецЕсли;
	Результат = Новый Структура(
	"Метод,		Параметры,				Идентификатор,	Модуль,		ВремяОжиданияОтвета,События,		Аккаунт, Ответ, ВремяВызова, ВремяПолучения, Контракт", 
	СбисМетод,	СбисПараметрыМетода,	СбисИдЗапроса,	СбисМодуль,	СбисОжиданиеОтвета,	Новый Структура);
	Если ДопПараметры = Неопределено Тогда
		Результат.Аккаунт = Кэш.СБИС.ДанныеИнтеграции.Объекты["Форма_" + СбисМодуль].СбисИдАккаунта(Кэш);
		Возврат Результат;
	КонецЕсли;
	Если Не ДопПараметры.Свойство("ВремяОжиданияОтвета", Результат.ВремяОжиданияОтвета) Тогда
		Результат.ВремяОжиданияОтвета = МодульОбъектаКлиент().ПолучитьЗначениеПараметраСбис("ВремяОжиданияОтвета");
	КонецЕсли;
	Если ДопПараметры.Свойство("Модуль") Тогда
		Результат.Модуль = ДопПараметры.Модуль;
	КонецЕсли;
	//Контракт - объект бизнес логики, дополнительная адресация в плагине, 
	//в большенстве случаев контракт и модуль совпадают поэтому может не указываться
	ДопПараметры.Свойство("Контракт", Результат.Контракт);
	//Спилить переопределение аккаунта, после переезда на extSDK2
	Если ДопПараметры.Свойство("Аккаунт") Тогда
		Результат.Аккаунт = ДопПараметры.Аккаунт;
	Иначе
		Результат.Аккаунт = Кэш.Интеграция.СбисИдАккаунта(Кэш);
	КонецЕсли;
	Если ДопПараметры.Свойство("События") Тогда
		Результат.События = ДопПараметры.События;
	КонецЕсли;
	Возврат Результат;
	
КонецФункции


