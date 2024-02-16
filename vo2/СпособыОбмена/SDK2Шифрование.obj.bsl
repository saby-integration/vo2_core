
&НаКлиенте
Перем МестныйКэш Экспорт;
&НаКлиенте
Перем ЕстьИзменения Экспорт;
&НаКлиенте
Перем ПоследнееИзменение Экспорт;
// функции для совместимости кода 
&НаКлиенте
Функция сбисПолучитьФорму(СбисИмяФормы)
	Возврат ВладелецФормы.сбисПолучитьФорму(СбисИмяФормы);
КонецФункции
&НаКлиенте
Функция сбисЭлементФормы(Форма,ИмяЭлемента)
	Если ТипЗнч(ЭтаФорма) = Тип("УправляемаяФорма") Тогда
		Возврат Форма.Элементы.Найти(ИмяЭлемента);
	КонецЕсли;
	Возврат Форма.ЭлементыФормы.Найти(ИмяЭлемента);
КонецФункции
&НаКлиенте
Функция сбисПолучитьСтраницу(Элемент, ИмяСтраницы)
	Если ТипЗнч(ЭтаФорма) = Тип("УправляемаяФорма") Тогда
		Возврат Элемент.ПодчиненныеЭлементы[ИмяСтраницы];
	КонецЕсли;
	Возврат Элемент.Страницы[ИмяСтраницы];
КонецФункции
&НаКлиенте
Процедура сбисПоказатьСостояние(ТекстСостояния, Форма = Неопределено, Индикатор = Неопределено, Пояснение = "")
	Если ТипЗнч(ЭтаФорма) = Тип("УправляемаяФорма") Тогда
		Состояние(ТекстСостояния,Индикатор,Пояснение);
	Иначе
		Форма.ЭлементыФормы.ПанельОжидания.Видимость = Истина;
		Форма.НадписьОжидания = Символы.ПС + ТекстСостояния;
		Форма.НадписьПояснение = Пояснение;
		Если Индикатор<>Неопределено Тогда
			Форма.ЭлементыФормы.Индикатор.Видимость = Истина;
			Форма.ЭлементыФормы.Индикатор.Значение = Индикатор;
		КонецЕсли;
	КонецЕсли;	
КонецПроцедуры
&НаКлиенте
Процедура сбисСпрятатьСостояние(Форма = Неопределено)
	Если ТипЗнч(ЭтаФорма) = Тип("УправляемаяФорма") Тогда
	Иначе
		Форма.ЭлементыФормы.ПанельОжидания.Видимость = Ложь;
		Форма.ЭлементыФормы.Индикатор.Видимость = Ложь;
	КонецЕсли;	
КонецПроцедуры
&НаКлиенте
Функция сбисСообщитьОбОшибке(ИнформацияОПакете = "")
	Ошибка = ПолучитьСообщениеОбОшибке(Ложь);
	Если Не МестныйКэш.ТихийРежим Тогда
		Если ТипЗнч(ЭтаФорма) = Тип("УправляемаяФорма") Тогда
			Попытка
				ЭтотОбъект="";
			Исключение
			КонецПопытки;
	        Сообщить(ИнформацияОПакете + Ошибка.ТекстОшибки);
		Иначе
			фрм =ЭтотОбъект.ПолучитьФорму("ФормаОшибка");
			фрм.ТекстОшибки = Ошибка.ТекстОшибки;
			фрм.ИнформацияОбОшибке = ИнформацияОПакете + Ошибка.ИнформацияОбОшибке;
			фрм.ОткрытьМодально();
		КонецЕсли;
	КонецЕсли;
	Возврат Ошибка.ТекстОшибки;
КонецФункции

//------------------------------------------------------

&НаКлиенте
Функция Включить(Кэш, ДопПараметры=Неопределено, Отказ=Ложь) Экспорт
// Добавляет SDK в Кэш	
	Возврат Кэш.ВИ.Включить(Кэш, ДопПараметры, Отказ);
КонецФункции
&НаКлиенте
Функция Завершить(Кэш, ДопонительныеПараметры, Отказ) Экспорт
	Возврат Истина;
КонецФункции
&НаКлиенте
Функция ВключитьОтладку(Кэш, КаталогОтладки) Экспорт
	Возврат Кэш.ВИ.ВключитьОтладку(Кэш, КаталогОтладки);
КонецФункции
&НаКлиенте
Функция ОтключитьОтладку(Кэш, КаталогОтладки) Экспорт
	Возврат Кэш.ВИ.ОтключитьОтладку(Кэш, КаталогОтладки);
КонецФункции
// Изменяет каталог отладки с соответствующими проверками
&НаКлиенте
Функция УстановитьКаталогОтладки(Кэш) Экспорт
	Кэш.ВИ.УстановитьКаталогОтладки(Кэш);
КонецФункции
&НаКлиенте
Функция ЗакрытьСессию(Кэш) Экспорт 	
// Закрывает сессию	
	Возврат Кэш.ВИ.ЗакрытьСессию(Кэш);
КонецФункции	
&НаКлиенте
Функция АвторизоватьсяПоЛогинуПаролю(Кэш,Логин,Пароль,Отказ=Ложь) Экспорт 	
// Авторизуется на online.sbis.ru по логину/паролю	
	МестныйКэш = Кэш;
	Возврат Кэш.ВИ.АвторизоватьсяПоЛогинуПаролю(Кэш,Логин,Пароль,Отказ);
КонецФункции	
&НаКлиенте
Функция АвторизоватьсяПоСертификату(Кэш,Сертификат,Отказ=Ложь) Экспорт
// Авторизуется на online.sbis.ru по сертификату		
	МестныйКэш = Кэш;
	Возврат Кэш.ВИ.АвторизоватьсяПоСертификату(Кэш,Сертификат,Отказ);
КонецФункции
&НаКлиенте
Функция ПодтвердитьАвторизацию(Кэш, ПараметрыВвода, ПараметрыПодтверждения, Отказ) Экспорт
	Возврат Кэш.ВИ.ПодтвердитьАвторизацию(Кэш,ПараметрыВвода,ПараметрыПодтверждения,Отказ);
КонецФункции
&НаКлиенте
Функция ОтправитьКодАвторизации(Кэш, ПараметрыПодтверждения, Отказ) Экспорт
	Возврат Кэш.ВИ.ОтправитьКодАвторизации(Кэш,ПараметрыПодтверждения,Отказ);
КонецФункции
&НаКлиенте
Функция СформироватьНастройкиПодключения(Кэш, ИдентификаторСессии = "") Экспорт
	// Устанавливает в SDK настройки подключения		
	МестныйКэш = Кэш;
	Возврат Кэш.ВИ.СформироватьНастройкиПодключения(Кэш,ИдентификаторСессии);
КонецФункции
&НаКлиенте
Функция сбисСессияДействительна(Кэш) Экспорт
	МестныйКэш = Кэш;
	Возврат Кэш.ВИ.сбисСессияДействительна(Кэш);
КонецФункции
&НаКлиенте
Функция ПолучитьИдентификаторСессии(Кэш) Экспорт
// получает идентификатор текущей сессии	
	Возврат Кэш.ВИ.ПолучитьИдентификаторСессии(Кэш);
КонецФункции
&НаКлиенте
Функция ПолучитьСписокСертификатовДляАвторизации(Кэш,ТекстОшибки) Экспорт
// Получает список сертификатов для авторизации	
	МестныйКэш = Кэш;
	Возврат Кэш.ВИ.ПолучитьСписокСертификатовДляАвторизации(Кэш,ТекстОшибки);
КонецФункции
&НаКлиенте
Функция ПолучитьСписокСертификатов(Кэш, filter=Неопределено) Экспорт
// Получает список доступных сертификатов	
	МестныйКэш = Кэш;
	Возврат Кэш.ВИ.ПолучитьСписокСертификатов(Кэш, filter);
КонецФункции
&НаКлиенте
Функция ПолучитьСписокСертификатовПоФильтру(Кэш, filter=Неопределено, Отказ)
	Возврат Новый СписокЗначений();	
КонецФункции
&НаКлиенте
Функция ПолучитьСписокЛокальныхСертификатов(Кэш, filter=Неопределено) Экспорт
	Возврат Новый СписокЗначений();
КонецФункции
&НаКлиенте
функция ПолучитьСертификатыДляАктивации(Кэш, СписокИНН) Экспорт
// функция активирует серверные сертификаты для определенного списка ИНН	
	Возврат Кэш.ВИ.ПолучитьСертификатыДляАктивации(Кэш, СписокИНН);
КонецФункции
&НаКлиенте
функция АктивироватьСерверныеСертификаты(Кэш, СписокСертификатов) Экспорт
	// функция активирует серверные сертификаты для определенного списка ИНН	
	Возврат Кэш.ВИ.АктивироватьСерверныеСертификаты(Кэш, СписокСертификатов);
КонецФункции
//Метод устарел, вместо него использовать Кэш.СБИС.МодульОбъектаКлиент.СбисПолучитьИнформациюОТекущемПользователе
&НаКлиенте
Функция ИнформацияОТекущемПользователе(Кэш) Экспорт
// Получает информацию о текущем пользователе	
	МестныйКэш = Кэш;
	Возврат Кэш.ВИ.ИнформацияОТекущемПользователе(Кэш);
КонецФункции
&НаКлиенте
Функция ПолучитьСообщениеОбОшибке(Кратко = Истина) Экспорт
// Получает последнюю ошибку SDK	
	Возврат МестныйКэш.ВИ.ПолучитьСообщениеОбОшибке(Кратко);
КонецФункции	
&НаКлиенте
Функция ПолучитьФильтр()
// Формирует структуру фильтра для списочных методов SDK	
	Возврат МестныйКэш.ВИ.ПолучитьФильтр();	
КонецФункции	
&НаКлиенте
Функция СериализоватьObjectВСтруктуру(Object) Экспорт
// сериализует  com-объект в структуру	
	Возврат МестныйКэш.ВИ.СериализоватьObjectВСтруктуру(Object);
КонецФункции
&НаКлиенте
Функция СериализоватьСтруктуруВObject(Структура,Кэш) Экспорт
// сериализует  com-объект в структуру	
	Возврат Кэш.ВИ.СериализоватьСтруктуруВObject(Структура,Кэш);
КонецФункции

&НаКлиенте
Функция ПолучитьСписокДокументовОтгрузки(Кэш) Экспорт
// Получает список документов реализации с online.sbis.ru 	
	МестныйКэш = Кэш;
	Возврат Кэш.ВИ.ПолучитьСписокДокументовОтгрузки(Кэш);
КонецФункции
&НаКлиенте
Функция ПолучитьСписокСобытий(Кэш, ТипРеестра) Экспорт
// Получает список документов по событиям с online.sbis.ru	
	МестныйКэш = Кэш;
	Возврат Кэш.ВИ.ПолучитьСписокСобытий(Кэш, ТипРеестра);
КонецФункции
&НаКлиенте
Функция сбисПолучитьСписокДокументов(Кэш) Экспорт
// Получает список документов определенного типа с online.sbis.ru	
	МестныйКэш = Кэш;
	Возврат Кэш.ВИ.сбисПолучитьСписокДокументов(Кэш);
КонецФункции
&НаКлиенте
функция ПрочитатьДокумент(Кэш,ИдДок,ДопПараметры=Неопределено,Отказ=Ложь) экспорт
// Получает структуру документа СБИС	
	Возврат Кэш.ВИ.ПрочитатьДокумент(Кэш,ИдДок,ДопПараметры,Отказ);
КонецФункции
&НаКлиенте
функция ПолучитьДанныеФайла(Кэш,Ссылка) экспорт
// Получает данные файла вложения	
    Возврат Кэш.ВИ.ПолучитьДанныеФайла(Кэш,Ссылка);
КонецФункции
&НаКлиенте
функция СохранитьВложениеПоСсылкеВФайл(Кэш,Ссылка,ИмяФайла) экспорт //d.ch
    Возврат Кэш.ВИ.СохранитьВложениеПоСсылкеВФайл(Кэш,Ссылка,ИмяФайла);
КонецФункции
//&НаСервереБезКонтекста
//Функция ИмяРегистраСвойствОбъектов()
//	Если Метаданные.РегистрыСведений.Найти("ЗначенияСвойствОбъектов")<>Неопределено Тогда
//		Возврат "ЗначенияСвойствОбъектов";
//	ИначеЕсли Метаданные.РегистрыСведений.Найти("ДополнительныеСведения")<>Неопределено Тогда
//		Возврат "ДополнительныеСведения";
//	Иначе
//		// ??? где храним статусы
//	КонецЕсли
//КонецФункции
&НаКлиенте
функция ПолучитьHTMLВложения(Кэш,ИдДок, Вложение) экспорт
// Получает html по идентификаторам пакета и вложения
// Используется при просмотре документов из реестров СБИС
	Возврат Кэш.ВИ.ПолучитьHTMLВложения(Кэш,ИдДок, Вложение);
КонецФункции
&НаКлиенте
функция ПолучитьHTMLПоXML(Кэш, Вложение) экспорт
	// Получает html по xml	
	// Используется при просмотре документов из реестров продаж (1С)
	Возврат Кэш.ВИ.ПолучитьHTMLПоXML(Кэш, Вложение);
КонецФункции
&НаКлиенте
Функция сбисВыполнитьКоманду(Кэш, Идентификатор,ИмяКоманды, ПредставлениеПакета) Экспорт
// Выполняет указанную команду по документу СБИС (утверждение/отклонение)	
	МестныйКэш = Кэш;
	
	document_out = МестныйКэш.Docflow.CreateSimpleObject();
	document_out.Write( "Идентификатор", Идентификатор );
	
	// Прочитаем пакет   
	doc = Кэш.docflow.ReadDocument(document_out);
	СоставПакета = СериализоватьObjectВСтруктуру(doc);

    	
	Если СоставПакета.Свойство("Этап") и (СоставПакета.Этап[0].Название  = "Утверждение" или СоставПакета.Этап[0].Название  = "Утвердить") Тогда
		action = Неопределено;
		Комментарий="";
		Если ИмяКоманды = "Отклонить" Тогда
			Если НЕ ВвестиСтроку(Комментарий,"Причина отклонения",,Истина) Тогда
				   Возврат Ложь;
			КонецЕсли;
		КонецЕсли;	
		
		//Ищем действие соответсвующее команде
		Для Каждого Действие из СоставПакета.Этап[0].Действие Цикл
			Если Действие.Название = ИмяКоманды Тогда
				Возврат сбисВыполнитьДействие(Кэш, СоставПакета, СоставПакета.Этап[0], Действие, Комментарий, ПредставлениеПакета);
			КонецЕсли;
		КонецЦикла;
		
	КонецЕсли;	
	Возврат Ложь;
КонецФункции
&НаКлиенте
Функция сбисВыполнитьДействие(Кэш, СоставПакета, Этап, Действие, Комментарий, ПредставлениеПакета) Экспорт
	// Выполняет указанное действие по документу СБИС
	МестныйКэш = Кэш;
	ГлавноеОкно = Кэш.ГлавноеОкно;
	Если НЕ Действие.Свойство("Сертификат") или  Действие.Сертификат.Количество()=0 Тогда
		Сообщить("Отсутствует сертификат ЭЦП для утверждения/отклонения пакета документов "+ПредставлениеПакета);
		Возврат Ложь;
	КонецЕсли;
	Кэш.ВИ.ОбработатьСлужебныеДокументыПоПакету(Кэш, СоставПакета);
	certificate = СериализоватьСтруктуруВObject(Действие.Сертификат[0],Кэш);
	//certificate = МестныйКэш.Docflow.CreateSimpleObject();
	//certificate.Write("ИНН", Действие.Сертификат[0].ИНН);
	//certificate.Write("ФИО", Действие.Сертификат[0].ФИО);
	//certificate.Write("Должность", Действие.Сертификат[0].Должность);
	//certificate.Write("Квалифицированный", "Да");

							
	// Назначение действие на этап
	action = Кэш.Docflow.CreateSimpleObject();
	action.Write("Название", Действие.Название);
	action.WriteObject("Сертификат", certificate);
	Если Комментарий<>"" Тогда
		action.Write("Комментарий", Комментарий);
	КонецЕсли;	

	
	// Назначение этапа
	stage = Кэш.Docflow.CreateSimpleObject();
	stage.Write("Название", Этап.Название);
	stage.Write("Идентификатор",Этап.Идентификатор); 
	stage.WriteObject("Действие", action);
	
	
	document_in = Кэш.Docflow.CreateSimpleObject();
	document_in.WriteObject( "Этап", stage );
	document_in.Write( "Идентификатор", СоставПакета.Идентификатор );	
	
	// Подготовка этапа
	prepared_document = Кэш.docflow.PrepareAction(document_in);
	Если prepared_document  = Неопределено Тогда
		сбисСообщитьОбОшибке();
		Возврат Ложь
	КонецЕсли;
	
	attachmentList = prepared_document.ReadObjectList("Этап").at(0).ReadObjectList("Вложение");
	Если attachmentList = Неопределено Тогда
		attachmentList = Кэш.Docflow.CreateSimpleObjectList();
	КонецЕсли;
	
	//UAA формирование титулов
	сбисПараметрыТитулов = Новый Структура;
	ОшибкаФормирования = Ложь;
	РезультатФормирования = Кэш.ОбщиеФункции.сбисСформироватьТитулы(Кэш, СоставПакета, Действие, сбисПараметрыТитулов, ОшибкаФормирования);
	Если ОшибкаФормирования Тогда
		Кэш.ГлавноеОкно.сбисСообщитьОбОшибке(Кэш, РезультатФормирования);
		Возврат Ложь;
	КонецЕсли;
		
	StreamHelper = Новый COMОбъект("SBIS.StreamHelper");

	Для Каждого Вложение Из СоставПакета.Вложение Цикл
		Если Не Вложение.Свойство("Идентификатор") Тогда
			attachment = Кэш.Docflow.CreateSimpleObject();
			file = Кэш.Docflow.CreateSimpleObject();
			ИмяФайла = ?(Вложение.Свойство("ИмяФайла"),Вложение.ИмяФайла,Вложение.СтруктураФайла.Файл.Имя+"__"+Формат(ТекущаяДата(),"ДФ=yyyyMMdd")+"_"+строка(Новый УникальныйИдентификатор())+".xml");
			file.Write( "Имя", ИмяФайла ); 
		    file.Write( "ДвоичныеДанные", StreamHelper.StringToBase64(Вложение.XMLДокумента) ); 
			attachment.WriteObject( "Файл", file );
			ИдВложения = строка(Новый УникальныйИдентификатор());
			attachment.Write( "Идентификатор",  ИдВложения);
			Если ЗначениеЗаполнено(Вложение.Тип) и ЗначениеЗаполнено(Вложение.ВерсияФормата) Тогда
				attachment.Write( "Тип",  Вложение.Тип);
				attachment.Write( "Подтип",  Вложение.ПодТип);
				attachment.Write( "ВерсияФормата",  Вложение.ВерсияФормата);
			КонецЕсли;
			Если Вложение.Свойство("Дата") и ЗначениеЗаполнено(Вложение.Дата) Тогда
				attachment.Write( "Дата",  Вложение.Дата);
			КонецЕсли;
			//attachment.Write( "Номер",  Вложение.Номер);
			//attachment.Write( "Сумма",  Вложение.Сумма);
			Если Вложение.Свойство("Название") и ЗначениеЗаполнено(Вложение.Название) Тогда
				attachment.Write( "Название",  Вложение.Название);
			КонецЕсли;

			attachment.Write( "Служебный",  ?(Вложение.Свойство("Служебный"),Вложение.Служебный,"Нет"));
			attachmentList.Add( attachment );
		КонецЕсли;
	КонецЦикла;
	
	
	stage = prepared_document.ReadObjectList("Этап").at(0);
	action = prepared_document.ReadObjectList("Этап").at(0).ReadObjectList("Действие").at(0);
	stage.WriteObject("Действие", action);
	stage.WriteObjectList("Вложение", attachmentList);
	prepared_document.WriteObject( "Этап", stage );
	
	// Завершение этапа
	completed_document = Кэш.docflow.ExecuteAction(prepared_document);
	Если completed_document  = Неопределено Тогда 
		сбисСообщитьОбОшибке();
		Возврат Ложь;
	КонецЕсли;
	Возврат Истина;
КонецФункции

// Интеллектуальная функция выполнить команду пока не умеет прикладывать вложения, поэтому пользуемся неинтеллектуальной
//&НаКлиенте
//Функция сбисВыполнитьКоманду(Кэш, СоставПакета,ИмяКоманды, ПредставлениеПакета) Экспорт
//// Выполняет указанную команду по документу СБИС (утверждение/отклонение)	
//	МестныйКэш = Кэш;	
//	Если СоставПакета.Свойство("Этап") и (СоставПакета.Этап[0].Название  = "Утверждение" или СоставПакета.Этап[0].Название  = "Утвердить") Тогда
//		action = Неопределено;
//		Комментарий="";
//		Если ИмяКоманды = "Отклонить" Тогда
//			Если НЕ ВвестиСтроку(Комментарий,"Причина отклонения",,Истина) Тогда
//				   Возврат Ложь;
//			КонецЕсли;
//		КонецЕсли;	
//		// Назначение действие на этап
//		action = МестныйКэш.Docflow.CreateSimpleObject();
//		//action.Write("Название", Действие.Название);
//		action.Write("Название", ИмяКоманды);
//		//action.WriteObject("Сертификат", certificate);
//		Если Комментарий<>"" Тогда
//			action.Write("Комментарий", Комментарий);
//		КонецЕсли;	
//		
//		// Назначение этапа
//		stage = МестныйКэш.Docflow.CreateSimpleObject();
//		stage.Write("Название", "Утверждение");
//		stage.Write("Идентификатор",СоставПакета.Этап[0].Идентификатор); 
//		stage.WriteObject("Действие", action);
//		
//		document_in = МестныйКэш.Docflow.CreateSimpleObject();
//		document_in.WriteObject( "Этап", stage );
//		document_in.Write( "Идентификатор", СоставПакета.Идентификатор );	
//		
//		Результат = Кэш.docflow.ExecuteActionEx(document_in);
//		Если Результат  = Неопределено Тогда
//			сбисСообщитьОбОшибке(ПредставлениеПакета);
//			Возврат Ложь
//		КонецЕсли;
//	КонецЕсли;	
//	Возврат Истина;
//КонецФункции	
&НаКлиенте
Функция сбисПодписант(Кэш, ИНН) Экспорт
// Получает Информацию о контрагенте с онлайна
	filter = Кэш.Docflow.CreateSimpleObject();
	cert = Кэш.Docflow.CreateSimpleObject();
	cert.Write("ИНН", ИНН);
	cert.Write("Квалифицированный", "Да");
	filter.WriteObject("Сертификат", cert);
	СписокСертификатов = ПолучитьСписокСертификатов(Кэш,filter);
	Если СписокСертификатов.Количество()>0 Тогда
		Возврат СписокСертификатов[0].Значение;
	Иначе
		Возврат Новый Структура("Должность,ФИО,ИНН");
	КонецЕсли;
КонецФункции
&НаКлиенте
Функция сбисИдентификаторУчастника(Кэш, ИНН, КПП, Название) Экспорт
// Получает Информацию о контрагенте с онлайна
	Участник = Новый Структура;
	Если СтрДлина(СокрЛП(Инн))=12 Тогда
		СвФЛ = Новый Структура;
		Участник.Вставить("СвФЛ",СвФЛ);
		Участник.СвФЛ.Вставить("ИНН",Инн);
	Иначе
		СвЮЛ = Новый Структура;
		Участник.Вставить("СвЮЛ",СвЮЛ);
		Участник.СвЮЛ.Вставить("ИНН",ИНН);
		Участник.СвЮЛ.Вставить("КПП",КПП);
	КонецЕсли;
	оКонтрагент = ПолучитьИнформациюОКонтрагенте(Кэш, Участник);
	Если оКонтрагент<>Ложь Тогда
		Возврат оКонтрагент.Идентификатор;
	КонецЕсли;
	Возврат "";
КонецФункции
&НаКлиенте
Функция ПолучитьИнформациюОКонтрагенте(Кэш, СтруктураКонтрагента) Экспорт
// Получает Информацию о контрагенте с онлайна
	Возврат Кэш.ВИ.ПолучитьИнформациюОКонтрагенте(Кэш, СтруктураКонтрагента);
КонецФункции
&НаКлиенте
Функция ОбработкаСлужебныхДокументов(Кэш) Экспорт
// Получает список организаций с необработанными этапами и запускает для них обработку служебных документов
	Кэш.ВИ.ОбработкаСлужебныхДокументов(Кэш);
КонецФункции
&НаКлиенте
Процедура сбисПрерываниеПользователем()
// Прячет состояние при прерывании отправки, обработки служебных, обработки статусов	
	ГлавноеОкно = сбисПолучитьФорму("ФормаГлавноеОкно");
	сбисСпрятатьСостояние(ГлавноеОкно);	
КонецПроцедуры
&НаКлиенте
Функция ОтправитьПакетыДокументов(Кэш, МассивПакетов, РезультатОтправки=Неопределено) Экспорт
// Отправляет сформированные пакеты документов	
	МестныйКэш = Кэш;
	КоличествоПакетов = МассивПакетов.Количество();
	Если КоличествоПакетов = 0 Тогда
		Возврат Ложь;
	КонецЕсли;
	ГлавноеОкно = Кэш.ГлавноеОкно;
	фрм = ГлавноеОкно.сбисНайтиФормуФункции("ЗаписатьПараметрыДокументовСБИС",Кэш.ФормаРаботыСоСтатусами,"",Кэш);
	Если Кэш.парам.СостояниеЭД Тогда
		ПараметрыПоиска = Новый Структура;
		ПараметрыПоиска.Вставить("ИмяФункции",	"ЗаписатьПараметрыДокументовСБИС");
		ПараметрыПоиска.Вставить("КлючФорм",	"Статусы_СостоянияЭД");
		фрмЭД = Кэш.ОбщиеФункции.сбисНайтиФормуФункцииПодсистемы(Кэш, ПараметрыПоиска);
	КонецЕсли;

	сбисПоказатьСостояние("Отправка документов", ГлавноеОкно,, "(прервать -  Ctrl+Break)");
	ВсегоОтправлено = 0;
	ВсегоОшибок = 0;
	StreamHelper = Новый COMОбъект("SBIS.StreamHelper");
		documenty = Кэш.Docflow.CreateSimpleObjectList();
	Для СчетчикПакетов=0 По КоличествоПакетов-1 Цикл
			СоставПакета = МассивПакетов[СчетчикПакетов];
			document = Кэш.Docflow.CreateSimpleObject();
			attachmentList = Кэш.Docflow.CreateSimpleObjectList();
			Для Каждого Вложение Из СоставПакета.Вложение Цикл
				attachment = Кэш.Docflow.CreateSimpleObject();
				file = Кэш.Docflow.CreateSimpleObject();
				Если Вложение.Свойство("ПолноеИмяФайла") Тогда // внешний файл добавлен в пакет
					file.Write( "Имя", Вложение.ИмяФайла ); 
				    file.Write( "ДвоичныеДанные", StreamHelper.FileToBase64(Вложение.ПолноеИмяФайла) ); 
				Иначе  // сформирован xml
					ИмяФайла = Вложение.СтруктураФайла.Файл.Имя+".xml";
					file.Write( "Имя", ИмяФайла ); 
				    file.Write( "ДвоичныеДанные", StreamHelper.StringToBase64(Вложение.XMLДокумента) ); 
				КонецЕсли;
				
				Если Вложение.Свойство("Подпись") Тогда //d.ch
					ЭЦП = Кэш.Docflow.CreateSimpleObjectList();
					Для Каждого Запись из Вложение.Подпись Цикл
						ЗаписьЭЦП = Кэш.Docflow.CreateSimpleObject();
						ФайлЭЦП = Кэш.Docflow.CreateSimpleObject();
						ФайлЭЦП.Write( "Имя", Запись.Файл.Имя ); 
			    		ФайлЭЦП.Write( "ДвоичныеДанные",StreamHelper.FileToBase64(Запись.Файл.ПолноеИмяФайла)); 
						ЗаписьЭЦП.WriteObject("Файл",ФайлЭЦП);
						ЭЦП.Add(ЗаписьЭЦП);
					КонецЦикла;
					attachment.WriteObjectList( "Подпись", ЭЦП );
				КонецЕсли;
				
			    attachment.WriteObject( "Файл", file );
				ИдВложения = строка(Новый УникальныйИдентификатор());
				Вложение.Вставить("Идентификатор", ИдВложения);
				attachment.Write( "Идентификатор",  ИдВложения);
				Если Вложение.Свойство("Тип") и ЗначениеЗаполнено(Вложение.Тип) и Вложение.Свойство("ПодТип") и ЗначениеЗаполнено(Вложение.ПодТип) и Вложение.Свойство("ВерсияФормата") и ЗначениеЗаполнено(Вложение.ВерсияФормата) Тогда
					attachment.Write( "Тип",  Вложение.Тип);
					attachment.Write( "Подтип",  Вложение.ПодТип);
					attachment.Write( "ВерсияФормата",  Вложение.ВерсияФормата);
					Если Вложение.Свойство("ПодВерсияФормата") и ЗначениеЗаполнено(Вложение.ПодВерсияФормата) Тогда
						attachment.Write( "ПодверсияФормата",  Вложение.ПодВерсияФормата);
					КонецЕсли;
				КонецЕсли;
				attachment.Write( "Дата",  Вложение.Дата);
				attachment.Write( "Номер",  Вложение.Номер);
				attachment.Write( "Сумма",  Вложение.Сумма);
				attachment.Write( "Название",  Вложение.Название);
				attachmentList.Add( attachment );
			КонецЦикла;
			document.Write( "Тип",СоставПакета.Тип);	
			Если СоставПакета.Свойство("ПользовательскийИдентификатор") Тогда
				ИдПакета = Сред(СоставПакета.ПользовательскийИдентификатор,Найти(СоставПакета.ПользовательскийИдентификатор,":")+1);
			Иначе
				ИдПакета = строка(Новый УникальныйИдентификатор());
			КонецЕсли;
			
			СоставПакета.Вставить("Идентификатор", ИдПакета);
			document.Write( "Идентификатор", ИдПакета ); 
			Если СоставПакета.Свойство("ПользовательскийИдентификатор") Тогда
				redaction = Кэш.Docflow.CreateSimpleObject();
				redaction.Write("ИдентификаторИС", СоставПакета.ПользовательскийИдентификатор);
				document.WriteObject( "Редакция", redaction);
			КонецЕсли;
			Если СоставПакета.Свойство("Примечание") и ЗначениеЗаполнено(СоставПакета.Примечание) Тогда
				document.Write( "Примечание", СоставПакета.Примечание);
			КонецЕсли;
			document.WriteObjectList( "Вложение", attachmentList );
			
			org = Кэш.Docflow.CreateSimpleObject(); 
			Если СоставПакета.НашаОрганизация.Свойство("СвФЛ") Тогда
				СвФЛ = Кэш.Docflow.CreateSimpleObject();
				СвФЛ.Write( "ИНН", СоставПакета.НашаОрганизация.СвФЛ.ИНН); 
				org.WriteObject( "СвФЛ", СвФЛ );	
			Иначе
				СвЮЛ = Кэш.Docflow.CreateSimpleObject();
				СвЮЛ.Write( "ИНН", СоставПакета.НашаОрганизация.СвЮЛ.ИНН ); 
				СвЮЛ.Write( "КПП", СоставПакета.НашаОрганизация.СвЮЛ.КПП );
				org.WriteObject( "СвЮЛ", СвЮЛ );
			КонецЕсли;
			document.WriteObject( "НашаОрганизация", org );
			
			kontr = Кэш.Docflow.CreateSimpleObject(); 
			Если СоставПакета.Контрагент.Свойство("СвФЛ") Тогда
				СвФЛ = Кэш.Docflow.CreateSimpleObject();
				СвФЛ.Write( "ИНН", СоставПакета.Контрагент.СвФЛ.ИНН ); 
				kontr.WriteObject( "СвФЛ", СвФЛ );	
			Иначе
				СвЮЛ = Кэш.Docflow.CreateSimpleObject();
				СвЮЛ.Write( "ИНН", СоставПакета.Контрагент.СвЮЛ.ИНН ); 
				СвЮЛ.Write( "КПП", СоставПакета.Контрагент.СвЮЛ.КПП );
				kontr.WriteObject( "СвЮЛ", СвЮЛ );
			КонецЕсли;
			Если СоставПакета.Контрагент.Свойство("Подразделение") и СоставПакета.Контрагент.Подразделение.Свойство("Идентификатор") Тогда
				Подразделение = Кэш.Docflow.CreateSimpleObject();
				Подразделение.Write( "Идентификатор", СоставПакета.Контрагент.Подразделение.Идентификатор); 
				kontr.WriteObject( "Подразделение", Подразделение );
			КонецЕсли;	
			Если СоставПакета.Контрагент.Свойство("Контакт")  Тогда
				Если СоставПакета.Контрагент.Контакт.Свойство("Телефон")  Тогда
					kontr.Write( "Телефон", СоставПакета.Контрагент.Контакт.Телефон );
				КонецЕсли;
				Если СоставПакета.Контрагент.Контакт.Свойство("EMAIL")  Тогда
					kontr.Write( "Email", СоставПакета.Контрагент.Контакт.EMAIL );
				КонецЕсли;
			КонецЕсли;
			document.WriteObject( "Контрагент", kontr );
			
			Если СоставПакета.Свойство("Сертификат") Тогда
				certificate = СериализоватьСтруктуруВObject(СоставПакета.Сертификат,Кэш);
			КонецЕсли;
			action = Кэш.Docflow.CreateSimpleObject();
			action.Write("Название", "Отправить");
			action.WriteObject("Сертификат", certificate);
					
			// Назначение этапа
			stage = Кэш.Docflow.CreateSimpleObject();
			stage.Write("Название", "Отправка");
			stage.WriteObject("Действие", action);
		//document.WriteObject( "Этап", stage ); 
			
			Если СоставПакета.Свойство("Ответственный") и СоставПакета.Ответственный.Количество()>0 Тогда
				otv = Кэш.Docflow.CreateSimpleObject();
				Для Каждого Элемент Из СоставПакета.Ответственный Цикл
					otv.Write( Элемент.Ключ, Элемент.Значение );	
				КонецЦикла;
				document.WriteObject( "Ответственный", otv ); 	
			КонецЕсли;
			Если СоставПакета.Свойство("Подразделение") и СоставПакета.Подразделение.Количество()>0 Тогда
				podrazdel = Кэш.Docflow.CreateSimpleObject();
				Для Каждого Элемент Из СоставПакета.Подразделение Цикл
					podrazdel.Write( Элемент.Ключ, Элемент.Значение );	
				КонецЦикла;
				document.WriteObject( "Подразделение", podrazdel ); 	
			КонецЕсли;
			Если СоставПакета.Свойство("Регламент") и СоставПакета.Регламент.Количество()>0 Тогда
				regl = Кэш.Docflow.CreateSimpleObject();
				Для Каждого Элемент Из СоставПакета.Регламент Цикл
					regl.Write( Элемент.Ключ, Элемент.Значение );	
				КонецЦикла;
				document.WriteObject( "Регламент", regl ); 	
			КонецЕсли;
			Если СоставПакета.Свойство("ДокументОснование") и СоставПакета.ДокументОснование.Количество()>0 Тогда
				osnovania = Кэш.Docflow.CreateSimpleObjectList();
				Для Каждого ДокОсн Из СоставПакета.ДокументОснование Цикл 
					osn = Кэш.Docflow.CreateSimpleObject();
					doc = Кэш.Docflow.CreateSimpleObject();
					Для Каждого Элемент Из ДокОсн Цикл
						doc.Write( Элемент.Ключ, Элемент.Значение );	
					КонецЦикла;
					osn.WriteObject( "Документ", doc );
					osnovania.Add(osn);
				КонецЦикла;
				document.WriteObjectList( "ДокументОснование", osnovania ); 				
			КонецЕсли;
			shifr = Кэш.Docflow.CreateSimpleObject();
			shifr.Write( "Зашифрован", "Да" );
			document.WriteObject( "Шифрование", shifr );
			documenty.Add(document);
		КонецЦикла;	
		
		param = Кэш.Docflow.CreateSimpleObject();
		param.WriteObjectList( "Документ", documenty );
		Если Кэш.Ини.Конфигурация.Свойство("ЧислоПотоковОтправки") Тогда
			param.Write( "ЧислоПотоков", СтрЗаменить(Кэш.Ини.Конфигурация.ЧислоПотоковОтправки.Значение,"'","") );	
		КонецЕсли;
		
			
			Результат = Кэш.docflow.WriteDocumentsEx(param);	
			Если Результат = Неопределено Тогда //почему неопределено
				сбисСпрятатьСостояние(ГлавноеОкно);
				ТекстОшибки = сбисСообщитьОбОшибке();
				ЭлементСписка = Кэш.РезультатОтправки.ТипыОшибок.НайтиПоЗначению(ТекстОшибки);
				Если ЭлементСписка=Неопределено Тогда
					Кэш.РезультатОтправки.ТипыОшибок.Добавить(ТекстОшибки, КоличествоПакетов-ВсегоОтправлено-ВсегоОшибок);
				Иначе
					ЭлементСписка.Представление = Число(ЭлементСписка.Представление)+КоличествоПакетов-ВсегоОтправлено-ВсегоОшибок;
				КонецЕсли;
		Если НЕ Кэш.РезультатОтправки.Свойство("ПрерватьОтправку") Тогда
			Кэш.РезультатОтправки.Вставить("ПрерватьОтправку", ТекстОшибки);
		КонецЕсли;
		сбисСпрятатьСостояние(ГлавноеОкно);
		Возврат Ложь;
	КонецЕсли;
	// Обрабатываем результат отправки - проставляем статусы
	Результат = СериализоватьObjectВСтруктуру(Результат);
	ДанныеПоСтатусам = Новый Массив;
	сч = 0;
	Для Каждого Элемент Из Результат.Реестр Цикл
		СоставПакета = МассивПакетов[сч];
		Если Элемент.Свойство("Документ") Тогда
			СоставПакета.Вставить("Отправлен", Истина);
			ВсегоОтправлено = ВсегоОтправлено + 1;
			Кэш.РезультатОтправки.Отправлено = Кэш.РезультатОтправки.Отправлено + 1;
			ТекстСообщения = "";
			Для Каждого Вложение Из СоставПакета.Вложение Цикл
				Если Вложение.Свойство("Документы1С") Тогда
					Для Каждого Документ1С Из Вложение.Документы1С Цикл
						СтруктураСвойств = Новый Структура("ДокументСБИС_Ид,ДокументСБИС_ИдВложения,ДокументСБИС_Статус", СоставПакета.Идентификатор,Вложение.Идентификатор,Элемент.Документ.Состояние.Название);
						ДанныеПоСтатусам.Добавить(Новый Структура("СтруктураСвойств, Документ1С, ИдАккаунта",СтруктураСвойств, Документ1С.Значение, Кэш.Интеграция.ПолучитьИдТекущегоАккаунта(Кэш)));
						ТекстСообщения = ТекстСообщения+", "+строка(Документ1С.Значение);	
					КонецЦикла;
				КонецЕсли;
			КонецЦикла;
			ТекстСообщения = "Отправлен пакет документов: "+Сред(ТекстСообщения, 3);
			//Сообщить(ТекстСообщения);	
		КонецЕсли;
		Если Элемент.Свойство("Ошибка") Тогда
			ВсегоОшибок = ВсегоОшибок + 1;
			Кэш.РезультатОтправки.Ошибок = Кэш.РезультатОтправки.Ошибок + 1;
			ТекстОшибки = Элемент.Ошибка.Описание;
			ОписаниеРасширенное = Элемент.Ошибка.ОписаниеРасширенное;
			ЭлементСписка = Кэш.РезультатОтправки.ТипыОшибок.НайтиПоЗначению(ТекстОшибки);
			Если ЭлементСписка=Неопределено Тогда
				Кэш.РезультатОтправки.ТипыОшибок.Добавить(ТекстОшибки, 1);
			Иначе
				ЭлементСписка.Представление = Число(ЭлементСписка.Представление)+1;
			КонецЕсли;
			Если СоставПакета.Вложение.Количество()>0 и СоставПакета.Вложение[0].Свойство("Документы1С") Тогда
				ОсновнойДокумент1С = СоставПакета.Вложение[0].Документы1С[0].Значение;
			Иначе
				ОсновнойДокумент1С = Неопределено;
			КонецЕсли;
			//AU изменена структура в детализации ошибок для возможности проброса дампа в сервис статистики
			ЭлементСоответствия = Кэш.РезультатОтправки.ДетализацияОшибок.Получить(ТекстОшибки);
			Если ЭлементСоответствия=Неопределено Тогда
				ЭлементСоответствия = Новый Массив;
				Кэш.РезультатОтправки.ДетализацияОшибок.Вставить(ТекстОшибки, ЭлементСоответствия);
			КонецЕсли;
			СтрокаВСоответствие = Новый Структура("ОбработанДокумент1С,Сообщение,СтруктураОшибки", Элемент.ОсновнойДокумент1С, ОписаниеРасширенное, Новый Структура("error, details, code", ТекстОшибки, ОписаниеРасширенное, 100));
			ЭлементСоответствия.Добавить(СтрокаВСоответствие);
			ТекстСообщения = "";
			Для Каждого Вложение Из СоставПакета.Вложение Цикл
				Если Вложение.Свойство("Документы1С") Тогда
					Для Каждого Документ1С Из Вложение.Документы1С Цикл
						СтруктураСвойств = Новый Структура("ДокументСБИС_Ид,ДокументСБИС_ИдВложения,ДокументСБИС_Статус", СоставПакета.Идентификатор,Вложение.Идентификатор,"Ошибка: "+Лев(ТекстОшибки, 230));
						ДанныеПоСтатусам.Добавить(Новый Структура("СтруктураСвойств, Документ1С",СтруктураСвойств, Документ1С.Значение));
						ТекстСообщения = ТекстСообщения+", "+строка(Документ1С.Значение);	
					КонецЦикла;
				КонецЕсли;
			КонецЦикла;
			ТекстСообщения = "Пакет документов не отправлен: "+Сред(ТекстСообщения, 3)+". "+ТекстОшибки;
			//Сообщить(ТекстСообщения);	
			Если Лев(Элемент.Ошибка.Описание, 14) = "Ошибка WinHTTP" и НЕ Кэш.РезультатОтправки.Свойство("ПрерватьОтправку") Тогда
				Кэш.РезультатОтправки.Вставить("ПрерватьОтправку", ТекстОшибки);
			КонецЕсли;
		КонецЕсли;
		сч = сч+1;
	КонецЦикла;
	фрм.ЗаписатьПараметрыДокументовСБИС(ДанныеПоСтатусам, Кэш.Ини.Конфигурация, ГлавноеОкно.Кэш.Парам.КаталогНастроек);
	// << alo 
	если Кэш.парам.СостояниеЭД тогда
		фрмЭД.ЗаписатьПараметрыДокументовСБИС(ДанныеПоСтатусам, Кэш.Ини.Конфигурация, Кэш.ГлавноеОкно.Кэш.Парам.КаталогНастроек);
	конецесли;	// alo >>
	
	//AU точка входа после отправки партии пакетов документов с данными по статусам.
	фрм = Кэш.ГлавноеОкно.сбисНайтиФормуФункции("сбисОбработатьСписокОтправленных","РаботаСДокументами1С","", Кэш);
	Если Не фрм = Ложь Тогда
		//Данные по детализации статусов и списка номенклатуры смотреть в кэше.
		Контекст = Новый Структура("ДанныеПоСтатусам", ДанныеПоСтатусам);//Структура для возможности расширения, если понадобится добавить что-то ещё.
		фрм.сбисОбработатьСписокОтправленных(Кэш, Контекст);
	КонецЕсли;
	//
	сбисСпрятатьСостояние(ГлавноеОкно);
	
КонецФункции
&НаКлиенте
Процедура сбисПолучитьОтветыПоОтправке(Кэш) Экспорт
	Кэш.ОбщиеФункции.сбисСтатистика_СформироватьИЗаписатьСтатистикуНаСервис(Кэш, Новый Структура("Действие", "Отправка"),Ложь);
КонецПроцедуры
&НаКлиенте
Функция ПолучитьСписокИзменений(Кэш, ДопПараметрыФильтра = Неопределено) Экспорт
// Получает статусы документов сбис
	МестныйКэш = Кэш;
	Кэш.ВИ.ПолучитьСписокИзменений(Кэш, ДопПараметрыФильтра);
КонецФункции
&НаКлиенте
Функция сбисТекущаяДата(Кэш) Экспорт
// получает текущую дату-время на сервере СБИС	
	Возврат Кэш.ВИ.сбисТекущаяДата(Кэш);
КонецФункции
&НаКлиенте
функция сбисТекущаяДатаМСек(Кэш) экспорт
	// Получает текущую дату в миллисекундах с начала 1970г
	Возврат 0;
КонецФункции
Функция сбисПолучитьНастройки(СтруктураНастроек) Экспорт
// Получает параметры запроса статусов из настроек пользователя СБИС	
	УстановитьПривилегированныйРежим(Истина); 
    Для Каждого Элемент Из СтруктураНастроек Цикл 
		Попытка
			СтруктураНастроек[Элемент.Ключ] = ХранилищеОбщихНастроек.Загрузить(Элемент.Ключ,,,"СБИС");
		Исключение
			СтруктураНастроек[Элемент.Ключ] = ХранилищеОбщихНастроек.Загрузить(Элемент.Ключ);
		КонецПопытки;
	КонецЦикла;
	УстановитьПривилегированныйРежим(Ложь);
	Возврат СтруктураНастроек;
КонецФункции
&НаКлиенте
Процедура УстановитьВидимостьОбновитьСтатусы(Кэш) Экспорт
// Если более часа не проверяли статусы, то выводим красное предупреждение	
	Кэш.ВИ.УстановитьВидимостьОбновитьСтатусы(Кэш);
КонецПроцедуры
&НаКлиенте
Функция ДоступныСерверныеНастройки() Экспорт
	
	Возврат	Ложь;
	
КонецФункции
&НаКлиенте
Функция сбисОтправитьСообщениеСтатистики(Кэш, СообщениеСтатистики, Отказ) Экспорт
	Возврат Кэш.ВИ.сбисОтправитьСообщениеСтатистики(Кэш,СообщениеСтатистики,Отказ);
КонецФункции
&НаКлиенте
Функция сбисОтправитьСообщениеОшибки(Кэш, СообщениеОбОшибке, Отказ) Экспорт
	Возврат Кэш.ВИ.сбисОтправитьСообщениеОшибки(Кэш,СообщениеОбОшибке,Отказ);
КонецФункции

//SDK не умеет в ИД аккаунта.
&НаКлиенте
Функция ПолучитьИдТекущегоАккаунта(Кэш) Экспорт
	Возврат Неопределено;
КонецФункции

////////////////////////////////////////////////////
//////////////////Автообновление////////////////////
////////////////////////////////////////////////////

&НаКлиенте
Функция сбисПолучитьПараметрыАктуальнойВерсии(Кэш, ПараметрыОбновления, Отказ) Экспорт
	Возврат Кэш.ВИ.сбисПолучитьПараметрыАктуальнойВерсии(Кэш,ПараметрыОбновления,Отказ);
КонецФункции

&НаКлиенте
Функция сбисСохранитьВФайлПоСсылке(Кэш, сбисПараметрыФайла, Отказ) Экспорт	
	Возврат Кэш.ВИ.сбисСохранитьВФайлПоСсылке(Кэш, сбисПараметрыФайла, Отказ);	
КонецФункции

&НаКлиенте
Функция сбисВключенРезервныйДомен(Кэш, АдресСервера) Экспорт
	Возврат Ложь;
КонецФункции

#Область include_core_vo2_СпособыОбмена_SDK2Шифрование_ВнешниеОбертки
#КонецОбласти

