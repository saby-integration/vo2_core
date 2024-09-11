
// Процедура выполняет расширенное выполнение действия над документом. Вызываются методы СБИС.ПодготовитьДействие и СБИС.ВыполнитьДействие
//
// Параметры:
//  АсинхроннаяСБИСКоманда	 - 	Структура - Данные отправки документа - СоставПакета, Документ, СтатусПакета 
//  ДопПараметры			 - 	Структура - Набор полей, работа с которыми может расширить результат работы процедуры 
//
&НаКлиенте
Процедура ExecuteActionEx(АсинхроннаяСБИСКоманда, ДопПараметры) Экспорт
	Перем ОшибкаРезультат;
	
    ОшибкаОтправки		= Ложь;
	Кэш					= ДопПараметры.Кэш;

	action = Новый Структура("Название"); 
	Этап = АсинхроннаяСБИСКоманда.АргументВызова.СтатусЭДО.Этап;
	Действие = Этап.Действие[0];
		
	СертификатДляПодписания = Неопределено;
	Алгоритм = Неопределено;
	Если	Действие.ТребуетПодписания = "Да"
		И	Действие.Свойство("Сертификат") Тогда
		СертификатВыбран = Ложь;
		ТекстОшибки = "";
		Сертификат = Кэш.ФормаЭП.сбисВыбратьПодходящийСертификат(Кэш, Действие.Сертификат, ТекстОшибки);
		Если Сертификат<>Ложь Тогда
			action.Вставить("Сертификат", Сертификат.СертификатДок);
			СертификатДляПодписания = Сертификат.СертификатДляПодписания;
			Алгоритм = Сертификат.Алгоритм;
			СертификатВыбран = Истина;
		КонецЕсли;

		Если Не СертификатВыбран и ТекстОшибки <> "" Тогда
			
			МодульОбъектаКлиент().ВызватьСбисИсключение("Не найден подходящий сертификат для подписания документа", "ФормаЭП.сбисВыбратьПодходящийСертификат",,,ТекстОшибки);
			
		КонецЕсли;
	КонецЕсли;
		
	// Назначение этапа
	stage = Новый Структура;
	stage.Вставить("Название", Этап.Название);
	stage.Вставить("Действие", action);
	
	
	document_in = Новый Структура;
	document_in.Вставить( "Идентификатор", АсинхроннаяСБИСКоманда.АргументВызова.ИдентификаторОтправки );	
	document_in.Вставить( "Этап", stage );
	
	СтруктураРезультата = СБИС_ПодготовитьДействие(Кэш, document_in,, ОшибкаОтправки);

	Если ОшибкаОтправки Тогда
		
		МодульОбъектаКлиент().ВызватьСбисИсключение(СтруктураРезультата, "API.ExecuteActionEx")
		
	КонецЕсли;

	// выполняем действие
	
	prepared_document = СтруктураРезультата;  
	
	Этап = prepared_document.Этап[0];
	Действие = Этап.Действие[0];
	
	// Назначение этапа
	stage = Новый Структура; 
	stage.Вставить("Название", Этап.Название);
	
	// Назначение действия на этап
	action = Новый Структура;
	action.Вставить("Название", Действие.Название);
	Если Действие.свойство("Сертификат") Тогда 
		Если ЗначениеЗаполнено(СертификатДляПодписания) и Этап.Свойство("Вложение") Тогда
			stage.Вставить("Вложение", Новый Массив);
			ТекстОшибки = "";
			ПараметрыДействия = Новый Структура;
			ПараметрыДействия.Вставить("ПараметрыПодписанияВложения", Новый Структура("СертификатДляПодписания, Алгоритм, Сертификат", СертификатДляПодписания, Алгоритм));
			ПараметрыДействия.Вставить("Сертификат", Сертификат.СертификатДок);
			сбисПодписатьВложения(Кэш, Этап.Вложение,ПараметрыДействия);
			stage.Вложение = Этап.Вложение;
			Если ТекстОшибки<>"" Тогда
				
				МодульОбъектаКлиент().ВызватьСбисИсключение("Не удалось подписать вложение", "ФормаЭП.сбисВыбратьПодходящийСертификат",,,ТекстОшибки);
				
			КонецЕсли;
        КонецЕсли;
		action.Вставить("Сертификат", Действие.Сертификат[0]);
	КонецЕсли;
	
	stage.Вставить("Действие", action);
						
	document_in = Новый Структура;
	document_in.Вставить("Идентификатор",	prepared_document.Идентификатор );	
	document_in.Вставить("Этап",			stage );
	
	
	СтруктураПараметровЗапроса = Новый Структура("Документ",document_in);
	
	// Выполнение этапа
	СтруктураРезультата = СБИС_ВыполнитьДействие(Кэш, document_in,,ОшибкаОтправки);

	Если ОшибкаОтправки Тогда
		
		МодульОбъектаКлиент().ВызватьСбисИсключение(СтруктураРезультата, "API.ExecuteActionEx")
		
	КонецЕсли;
	
	АсинхронноеСбисСобытие = МодульОбъектаКлиент().НовыйАсинхронноеСбисСобытие(АсинхроннаяСБИСКоманда.Идентификатор, СтруктураРезультата, "Message");
	МодульОбъектаКлиент().АсинхроннаяСбисКоманда_ВызватьСобытие(АсинхроннаяСбисКоманда, АсинхронноеСбисСобытие);
	
КонецПроцедуры

