
// <Описание процедуры>
//
// Параметры:
//  <Параметр1>  - <Тип.Вид> - <описание параметра>
//                 <продолжение описания параметра>
//  <Параметр2>  - <Тип.Вид> - <описание параметра>
//                 <продолжение описания параметра>
//
&НаКлиенте
Функция ПодготовитьОбъектМаппинга(УИД, ДопПараметры = Неопределено) Экспорт 

	Кэш = ГлавноеОкно.Кэш;   
	Отказ = Ложь;
	
	requiredActionsCount	= 1;
	countProcessed			= 0;
	allObjects				= 1;
	countError				= 0;
	Для Сч = 0 По 4500 Цикл                           
		ПараметрыВызова = Новый Структура("SyncDocId, Direction", УИД, 1);
		Результат = Кэш.Интеграция.ExtSyncDoc_Prepare(Кэш, ПараметрыВызова, Отказ);
		Если Отказ Тогда
			Возврат Кэш.ОбщиеФункции.сбисИсключение(Результат, "API.ПодготовитьПосылкуПорционно");
		КонецЕсли;    
		
		СинхДокумент = ПолучитьДокументСинхронизации(УИД);
		Для Каждого СинхОбъект Из СинхДокумент.ExtSyncObjects Цикл
			СтруктураДляОбновления = Новый Структура("СтруктураОбъекта,			ИмяИни,						Статус",
													  СинхОбъект.Data.data_is,	СинхОбъект.Data.ini_name,	СинхОбъект.StatusId);
			ОбновитьОбъектСБИСИзОбъекта1С(СтруктураДляОбновления, Новый Структура("Uuid, Отказ", УИД, Отказ));
		КонецЦикла;
		
		Если Результат.Свойство("all_objects") Тогда
			allObjects		= Результат.all_objects;
			countProcessed	= Результат.count_processed;
			countError		= Результат.count_error;
		КонецЕсли;
		requiredActionsCount = Результат.requiredActions.Количество();
		Если requiredActionsCount = 0 И countProcessed + countError >= allObjects Тогда 
			Возврат Результат;
		КонецЕсли;
	КонецЦикла;

КонецФункции // ПодготовитьОбъектМаппинга()


&НаКлиенте
Функция ОбновитьОбъектСБИСИзОбъекта1С(СтруктураДляОбновления, ДопПараметры) Экспорт
	Кэш = ГлавноеОкно.Кэш;     
	СтруктураОбъекта = СтруктураДляОбновления.СтруктураОбъекта;
	Отказ = ДопПараметры.Отказ;
	
	СтруктураЗаписиДокумента = Новый Структура;
	СтруктураЗаписиДокумента.Вставить("Uuid", ?(ДопПараметры.Свойство("Uuid"), ДопПараметры.Uuid, Строка(Новый УникальныйИдентификатор)));
	СтруктураЗаписиДокумента.Вставить("Data", Новый Структура("ini_name", СтруктураДляОбновления.ИмяИни));
	
	МассивОбъектов = Новый Массив;
	СтруктураЗаписиОбъекта = Новый Структура;
	СтруктураЗаписиОбъекта.Вставить("Type", СтруктураОбъекта.ИмяИС);
	СтруктураЗаписиОбъекта.Вставить("Id", СтруктураОбъекта.ИдИС);
	Если СтруктураДляОбновления.Свойство("Статус") Тогда
		СтруктураЗаписиОбъекта.Вставить("StatusId", СтруктураДляОбновления.Статус);
	КонецЕсли;
	СтруктураЗаписиОбъекта.Вставить("Data", Новый Структура("data_is", СтруктураОбъекта));
	МассивОбъектов.Добавить(СтруктураЗаписиОбъекта);
	
	СтруктураПакета = Новый Структура("ConnectionId,ExtSyncDoc,ExtSyncObj", ПолучитьЗначениеПараметраСбис("ИдентификаторНастроек"), СтруктураЗаписиДокумента, МассивОбъектов); 
	
	ПараметрыЧтения = Новый Структура("param", СтруктураПакета);
	
	Возврат Кэш.Интеграция.ExtSyncDoc_Write(Кэш, ПараметрыЧтения, Отказ);
	
КонецФункции

//Запись объекта 1С на сервис
&НаКлиенте
Функция ЗавершитьОбновитьОбъектСБИСИзОбъекта1С(ИдентификаторЗаписиДокумента, Отказ) Экспорт
	
	Кэш = ГлавноеОкно.Кэш;
	ПараметрыЧтения = Новый Структура("param", Новый Структура("SyncDocId", ИдентификаторЗаписиДокумента));
	
	Возврат Кэш.Интеграция.ExtSyncDoc_Execute(Кэш, ПараметрыЧтения, Отказ) 
	
КонецФункции

//Получение структуры API3 объекта с сервиса
&НаКлиенте
Функция ПрочитатьАПИОбъектСБИС(ПараметрыЧтения, Отказ) Экспорт
	Кэш = ГлавноеОкно.Кэш;                                
	
	МассивИдентификаторов = Новый Массив;
	МассивИдентификаторов.Добавить(ПараметрыЧтения.ИдСБИС);
	
	ПараметрыЧтения = Новый Структура("Type,IdList", ПараметрыЧтения.ИмяСБИС, МассивИдентификаторов);
	ДопПараметры = Новый Структура("ЕстьРезультат", Истина);
	СтруктураОбъекта = Кэш.Интеграция.API3_GetSbisObject(Кэш, ПараметрыЧтения, ДопПараметры, Отказ);
	
	Для Индекс = 0 По СтруктураОбъекта.Количество() - 1 Цикл
	        ЛокальныйОбъект = СтруктураОбъекта[Индекс];
		Если ЛокальныйОбъект.Свойство("error") Тогда
			Отказ = Истина;
			Возврат Кэш.ОбщиеФункции.СбисИсключение(ЛокальныйОбъект.error, "API.ПрочитатьАПИОбъектСБИС");
		Иначе
			Возврат ЛокальныйОбъект;
		КонецЕсли;
    КонецЦикла;
	Возврат Неопределено;
КонецФункции

//Ожидание подготовки данных к загрузке объектов 1С на сервисе IntegrationConfig
&НаКлиенте
Функция ПодготовитьПосылкуПорционно(ИдентификаторПосылки, Отказ) Экспорт
	Кэш = ГлавноеОкно.Кэш;
	
	requiredActionsCount	= 1;
	countProcessed			= 0;
	allObjects				= 1;
	countError				= 0;
	Для Сч = 0 По 4500 Цикл                           
		ПараметрыВызова = Новый Структура("ConnectorName,SyncDocId,ReturnIterationResults", "Saby", ИдентификаторПосылки, Истина);
		Результат = Кэш.Интеграция.Connector_Prepare(Кэш, ПараметрыВызова, Отказ);
		Если Отказ Тогда
			Возврат Кэш.ОбщиеФункции.сбисИсключение(Результат, "API.ПодготовитьПосылкуПорционно");
		КонецЕсли;
		Если Результат.Свойство("all_objects") Тогда
			allObjects		= Результат.all_objects;
			countProcessed	= Результат.count_processed;
			countError		= Результат.count_error;
		КонецЕсли;
		requiredActionsCount = Результат.requiredActions.Количество();
		Если requiredActionsCount = 0 И countProcessed + countError >= allObjects Тогда 
			Возврат Результат;
		КонецЕсли;
	КонецЦикла;
	Отказ = Истина;
	Возврат Кэш.ОбщиеФункции.сбисИсключение("Не удалось обработать запрос, повторите попытку позже или уменьшите количество строк в документе.", "API.ПодготовитьПосылкуПорционно");
КонецФункции

&НаКлиенте
Функция ЗаписатьПосылкуСОбъектами(СтруктураПослыки, Отказ) Экспорт
	Кэш = ГлавноеОкно.Кэш;
	Param = Новый Структура("param", СтруктураПослыки);
	Возврат Кэш.Интеграция.ExtSyncDoc_Write(Кэш, Param, Отказ);
КонецФункции

//Загружает посылку в 1С по идентификатору. В случае успешной/частично успешной загрузки структура с полями Ошибки,Успешно.
&НаКлиенте
Функция ЗагрузитьПосылку(ИдентификаторПосылки, Отказ) Экспорт
	Перем СтруктураАпи3Объекта; 
	Кэш = ГлавноеОкно.Кэш;
	Результат = Новый Структура("Ошибки,Успешно",Новый Массив, Новый Массив);
	Для СбисСчетчик = 0 По 100 Цикл
        ОбъектНаЗагрузку = Кэш.Интеграция.ExtSyncDoc_GetObjectForExecute(Кэш, ИдентификаторПосылки, Отказ);
		Если Отказ Тогда
			Возврат Кэш.ОбщиеФункции.СбисИсключение(ОбъектНаЗагрузку, "МодульОбъектаКлиент.ЗагрузитьПосылку");
		ИначеЕсли Не ЗначениеЗаполнено(ОбъектНаЗагрузку) Тогда
			//Кончились объекты, прервать
			Прервать;
		КонецЕсли;
	
		ОшибкаЗагрузкиОбъекта = Ложь;
		Если		Не ОбъектНаЗагрузку.Свойство("Data", СтруктураАпи3Объекта) Тогда
			ОшибкаЗагрузкиОбъекта = Истина;
			ОбъектНаЗагрузку.Вставить("Data", Новый Структура);
			СбисСтруктураОшибки = Кэш.ОбщиеФункции.СбисИсключение(, "ФормаHTML.ЗагрузитьПосылку", 779,,"Не удалось получить даные объекта");
		ИначеЕсли	Не СтруктураАпи3Объекта.Свойство("data", СтруктураАпи3Объекта) Тогда
			ОшибкаЗагрузкиОбъекта = Истина;
			СбисСтруктураОшибки = Кэш.ОбщиеФункции.СбисИсключение(, "ФормаHTML.ЗагрузитьПосылку", 779,,"Не удалось получить даные объекта");
		Иначе                                                                                                  
			ПараметрыЗагрузки = Новый Структура("СтруктураАпи3Объекта, ИдентификаторПосылки", СтруктураАпи3Объекта, ИдентификаторПосылки);
			РезультатЗагрузки = ЗагрузитьАПИ3Объект(ПараметрыЗагрузки, ОшибкаЗагрузкиОбъекта);
			Если ОшибкаЗагрузкиОбъекта Тогда
				СбисСтруктураОшибки = Кэш.ОбщиеФункции.СбисИсключение(РезультатЗагрузки, "МодульОбъектаКлиент.ЗагрузитьПосылку");
			КонецЕсли;
		КонецЕсли;
		
		Если ОшибкаЗагрузкиОбъекта Тогда
			ОбъектНаЗагрузку.Вставить("StatusId", "Ошибка");
			ОбъектНаЗагрузку.Вставить("StatusMsg", Новый Массив);
			ТекстОшибки = "Ошибка загрузки объекта";
			ИндексНачалаСообщения = Найти(СбисСтруктураОшибки.details, "Объект");
			ИндексКонцаСообщения  = Найти(СбисСтруктураОшибки.details, "не сопоставлен");
			Если ИндексНачалаСообщения > 0 И ИндексКонцаСообщения > 0 Тогда
				ТекстОшибки = Сред(СбисСтруктураОшибки.details, ИндексНачалаСообщения, ИндексКонцаСообщения - ИндексНачалаСообщения +14);
			ИначеЕсли Найти(СбисСтруктураОшибки.details, "не уникально") > 0 Тогда
				ТекстОшибки = СбисСтруктураОшибки.details;
			КонецЕсли;
			ОбъектНаЗагрузку.StatusMsg.Добавить("Ошибка загрузки объекта. " + СбисСтруктураОшибки.details);
			ОбъектНаЗагрузку.Data.Вставить("error", СбисСтруктураОшибки);
			Результат.Ошибки.Добавить(ОбъектНаЗагрузку);
		Иначе
			ОбъектНаЗагрузку.Вставить("StatusId", "Синхронизирован");
			Результат.Успешно.Добавить(ОбъектНаЗагрузку);
		КонецЕсли;			
	
		МассивОбъектовСинхронизации = Новый Массив;
		МассивОбъектовСинхронизации.Добавить(ОбъектНаЗагрузку);
		ИдентификаторПодключения = ПолучитьЗначениеПараметраСбис("ИдентификаторНастроек");
		СтруктураСинхДокумента = Новый Структура("ConnectionId,ExtSyncDoc,ExtSyncObj", ИдентификаторПодключения, Новый Структура("Uuid", ИдентификаторПосылки), МассивОбъектовСинхронизации);
		param = Новый Структура("param", СтруктураСинхДокумента);
		ИдентификаторПосылки = Кэш.Интеграция.ExtSyncDoc_Write(Кэш, param, Отказ);
		Если Отказ Тогда
			Возврат Кэш.ОбщиеФункции.СбисИсключение(ИдентификаторПосылки, "ФормаHTML.ЗагрузитьПосылку");
		КонецЕсли;
	КонецЦикла;
	Возврат Результат;
КонецФункции

//Получение объектов для загрузку в 1С, загрузка в 1С.
&НаКлиенте
Функция ЗагрузитьАПИ3Объект(ПараметрыЗагрузки, Отказ) Экспорт 
	Перем ИмяИни, СбисИдАккаунта;                   
	Кэш = ГлавноеОкно.Кэш;
	СтруктураОбъекта	 = ПараметрыЗагрузки.СтруктураАпи3Объекта;
	ИдентификаторПосылки = ПараметрыЗагрузки.ИдентификаторПосылки;
	ИдентификаторПодключения = ПолучитьЗначениеПараметраСбис("ИдентификаторНастроек");

	ИмяОбъекта = СтруктураОбъекта.ИмяСБИС;
	СоответствиеИменСих = Новый Соответствие;
	СоответствиеИменСих.Вставить("ВидКонтактнойИнформации", "ВидыКонтактнойИнформации");
	ИмяИни = СоответствиеИменСих.Получить(ИмяОбъекта);
	Если ИмяИни = Неопределено Тогда
		ИмяИни = ИмяОбъекта;
	КонецЕсли;
	ИмяИни = "СинхЗагрузка_" + ИмяИни;
	Если ИмяИни = Неопределено Тогда
		Отказ = Истина;
	    Возврат Кэш.ОбщиеФункции.СбисИсключение(, "ФормаHTML.ЗагрузитьАПИ3Объект", 610, "Отсутствует файл настроек для данного типа данных", "Не найден ини файл для загрузки объекта " + ИмяОбъекта);	
	КонецЕсли;
	
	ОбъектыНаЗапись = Кэш.Интеграция.ExtSyncDoc_CalcObjectForExecute(Кэш, СтруктураОбъекта, ИдентификаторПосылки, ИмяИни, Отказ);
	Если Отказ Тогда
	    Возврат Кэш.ОбщиеФункции.СбисИсключение(ОбъектыНаЗапись, "МодульОбъектаКлиент.ЗагрузитьАПИ3Объект");	
	КонецЕсли;
	Кэш.СБИС.ПараметрыИнтеграции.Свойство("ИдАккаунта", СбисИдАккаунта);

	СписокРезультат = Новый Массив;
	Для Каждого ОбъектНаЗапись Из ОбъектыНаЗапись Цикл
		Результат = ЗаписатьАПИ3ОбъектВ1С(Кэш, ОбъектНаЗапись.Значение, СтруктураОбъекта, ИмяИни, Отказ);
		Если Отказ Тогда
			Возврат Кэш.ОбщиеФункции.СбисИсключение(Результат, "МодульОбъектаКлиент.ЗагрузитьАПИ3Объект");	
		КонецЕсли;
		СписокРезультат.Добавить(Результат);
		Если ИмяОбъекта = СтруктураОбъекта.ИмяСБИС Тогда
			СтруктураСвойств = Новый Структура("ДокументСБИС_Ид,ДокументСБИС_ИдВложения,ДокументСБИС_Статус", СтруктураОбъекта.ИдентификаторВИ, СтруктураОбъекта.ИдентификаторВИ, "");
	        фрм = Кэш.ГлавноеОкно.сбисНайтиФормуФункции("ЗаписатьПараметрыДокументаСБИС",Кэш.ФормаРаботыСоСтатусами,"",Кэш);
	        фрм.ЗаписатьПараметрыДокументаСБИС(СтруктураСвойств, Результат.Ссылка, Кэш.Ини.Конфигурация, Кэш.ГлавноеОкно.КаталогНастроек, Новый Структура("ИдАккаунта", СбисИдАккаунта));
		КонецЕсли;
	КонецЦикла;
	Возврат СписокРезультат;
КонецФункции

//Создание объектов в учетной системе на основании структуры объекта (с идентификаторами)
// СтруктураОбъекта - Структура, соответствующая загружаемому объекту, с определением типов данных.
// АПИ3Объект - Полученные данные объекта
// ТипИмяОбъекта - имя типа объекта
// ИмяИни - Имя ИНИ по которой рассчитывается объект
&НаКлиенте
Функция ЗаписатьАПИ3ОбъектВ1С(Кэш, СтруктураОбъекта, АПИ3Объект, ИмяИни, Отказ)
	Перем ТипИмяОбъекта;
	ИдентификаторПодключения = ПолучитьЗначениеПараметраСбис("ИдентификаторНастроек");
	Если Не	(	(	СтруктураОбъекта.Свойство("Идентификатор")
				И	СтруктураОбъекта.Идентификатор.Свойство("Объект", ТипИмяОбъекта)) 
			Или	(	СтруктураОбъекта.Свойство("Ref")
				И	СтруктураОбъекта.Ref.Свойство("Объект", ТипИмяОбъекта))) Тогда
		Отказ = Истина;                 
		СбисДамп = Новый Структура("ИмяИни, АПИ3Объект", ИмяИни, АПИ3Объект);
	    Возврат Кэш.ОбщиеФункции.СбисИсключение(, "ФормаHTML.ЗаписатьАПИ3ОбъектВ1С", 780, , "В структуре АПИ3 объекта отсутствуют данные для идентификации", СбисДамп);	
	КонецЕсли;
	
	ТипыСинхИни = Новый Массив;
	ТипыСинхИни.Добавить("СинхВыгрузка");
	ТипыСинхИни.Добавить("СинхЗагрузка");
	ЗначениеИниФайла = Кэш.ФормаНастроек.Ини(Кэш, ИмяИни, Новый Структура("ДоступныеТипыИни, ПринудительноеЧтение", ТипыСинхИни, Истина),Отказ);
	Если Отказ Тогда
	    Возврат Кэш.ОбщиеФункции.СбисИсключение(ЗначениеИниФайла, "ФормаHTML.ЗаписатьАПИ3ОбъектВ1С");	
	КонецЕсли;
	
	ПараметрыОбработкиАпи3Объекта = Новый Структура("Тип, СтруктураОбъекта", ТипИмяОбъекта, СтруктураОбъекта);
	Если АПИ3Объект.Свойство("ИдИС") Тогда
		ПараметрыОбработкиАпи3Объекта.Вставить("Идентификатор", АПИ3Объект.ИдИС);
	КонецЕсли;
	Если ЗначениеИниФайла.Свойство("Ключи") Тогда
		//Чтобы не отдавать всю ини на сервер, забираем только узел с ключами если есть такое
		ПараметрыОбработкиАпи3Объекта.Вставить("Ключи", ЗначениеИниФайла.Ключи);
	КонецЕсли;
	ДанныеОбъекта1С = Кэш.ОбщиеФункции.ВыполнитьОбработкуАпи3Объекта(Кэш, ПараметрыОбработкиАпи3Объекта, Отказ);
	Если Отказ Тогда
	    Возврат Кэш.ОбщиеФункции.СбисИсключение(ДанныеОбъекта1С, "ФормаHTML.ЗаписатьАПИ3ОбъектВ1С");	
	КонецЕсли;
		
	Если ДанныеОбъекта1С.Свойство("ДанныеМаппинга") Тогда
		Фильтр = Новый Структура("Type,Id,IdType,ConnectionId", АПИ3Объект.ИмяСБИС, АПИ3Объект.ИдСБИС, 1, ИдентификаторПодключения);
		РезультатОбновленияСопоставления = Кэш.Интеграция.ОбновитьЗаписьСопоставления(Кэш, Фильтр, ДанныеОбъекта1С.ДанныеМаппинга, Отказ);
		Если Отказ Тогда
	   		Возврат Кэш.ОбщиеФункции.СбисИсключение(РезультатОбновленияСопоставления, "ФормаHTML.ЗаписатьАПИ3ОбъектВ1С");	
		КонецЕсли;
	КонецЕсли;
	Возврат ДанныеОбъекта1С;
КонецФункции

// <Описание функции>
//
// Параметры:
//  <Параметр1>  - <Тип.Вид> - <описание параметра>
//                 <продолжение описания параметра>
//  <Параметр2>  - <Тип.Вид> - <описание параметра>
//                 <продолжение описания параметра>
//
// Возвращаемое значение:
//   <Тип.Вид>   - <описание возвращаемого значения>
//
&НаКлиенте
Функция ПолучитьДокументСинхронизации(УИД, ДопПараметры = Неопределено) Экспорт 
	
	Кэш = ГлавноеОкно.Кэш;
	ПараметрыВызова = Новый Структура("param", Новый Структура("SyncDocId, ExtSyncObject", УИД, Истина));
	Возврат Кэш.Интеграция.API3_ExtSyncDocRead(Кэш, ПараметрыВызова, ДопПараметры);

КонецФункции // ПолучитьОбъектыСинхронизацииИзЖурнала()

