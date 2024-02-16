
   //Подготовка данных по загружаемым в 1С объектам на сервисе IntegrationConfig порционно
&НаКлиенте
Функция Connector_Prepare(Кэш, ПараметрыВызова, Отказ) Экспорт
	ДопПараметрыВызова = Новый Структура("ЕстьРезультат,АдресРесурса,РежимКонвертации", Истина, "/integration_config/service/", "Стандарт");
	Результат = сбисОтправитьИОбработатьКоманду(Кэш, "Connector.Prepare", ПараметрыВызова, ДопПараметрыВызова, Отказ);
	Если Отказ Тогда
		Результат = Кэш.ОбщиеФункции.сбисИсключение(Результат, "API.ПодготовитьПосылкуСОбъектами");
	КонецЕсли;
	Возврат Результат;	
КонецФункции

//Получение объекта на загрузку в 1С
&НаКлиенте
Функция ExtSyncDoc_GetObjectForExecute(Кэш,ИдентификаторПосылки, Отказ) Экспорт
	ДопПараметрыВызова = Новый Структура("ЕстьРезультат,АдресРесурса,РежимКонвертации", Истина, "/integration_config/service/", "Стандарт");
	Результат = сбисОтправитьИОбработатьКоманду(Кэш, "ExtSyncDoc.GetObjectForExecute", Новый Структура("SyncDocId", ИдентификаторПосылки), ДопПараметрыВызова, Отказ);
	Если Отказ Тогда
		Результат = Кэш.ОбщиеФункции.сбисИсключение(Результат, "API.ПолучитьОбъектНаЗагрузку");
	КонецЕсли;
	Возврат Результат;
КонецФункции

//Рассчет объекта на сервисе
&НаКлиенте
Функция ExtSyncDoc_CalcObjectForExecute(Кэш, СтруктураОбъекта, ИдентификаторПосылки, ИмяИни, Отказ) Экспорт
	ДопПараметрыВызова = Новый Структура("ЕстьРезультат,АдресРесурса,РежимКонвертации", Истина, "/integration_config/service/", "Стандарт");
	Результат = сбисОтправитьИОбработатьКоманду(Кэш, "ExtSyncDoc.CalcObjectForExecute", Новый Структура("ObjectData,IniName,SyncDocId", СтруктураОбъекта, ИмяИни, ИдентификаторПосылки), ДопПараметрыВызова, Отказ);
	Если Отказ Тогда
		Результат = Кэш.ОбщиеФункции.сбисИсключение(Результат, "API.РассчитатьОбъектыНаЗапись");
	КонецЕсли;
	Возврат Результат;
КонецФункции

// Обертка метода ExtSyncDoc.Write
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
Функция ExtSyncDoc_Write(Кэш, ПараметрыМетода, Отказ = Ложь) Экспорт 
	
	ДопПараметры = Новый Структура("ЕстьРезультат,АдресРесурса", Истина, "/integration_config/service/");   

	Результат = СбисОтправитьИОбработатьКоманду(Кэш, "ExtSyncDoc.Write", ПараметрыМетода, ДопПараметры, Отказ);
	Если Отказ Тогда
		Результат = Кэш.ОбщиеФункции.СбисИсключение(Результат, "API.ОбновитьОбъектСБИСИзОбъекта1С");
	КонецЕсли;        
	
	Возврат Результат;

КонецФункции // ExtSyncDoc_Write()

// Обертка метода ExtSyncDoc.Execute
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
Функция ExtSyncDoc_Execute(Кэш, ПараметрыМетода, Отказ = Ложь) Экспорт 
	
	ДопПараметры = Новый Структура("ЕстьРезультат,АдресРесурса", Истина, "/integration_config/service/");

	Результат = СбисОтправитьИОбработатьКоманду(Кэш, "ExtSyncDoc.Execute", ПараметрыМетода, ДопПараметры, Отказ);
	
	Если Отказ Тогда
		Результат = Кэш.ОбщиеФункции.СбисИсключение(Результат, "API.ОбновитьОбъектСБИСИзОбъекта1С");
	КонецЕсли;        
	
	Возврат Результат;

КонецФункции // ExtSyncDoc_Execute()

// Обертка метода API3.GetSbisObject
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
Функция API3_GetSbisObject(Кэш, ПараметрыМетода, ДопПараметры, Отказ = Ложь) Экспорт   
	
	ДопПараметры = Новый Структура("АдресРесурса", "/service/?srv=1");
	
	Результат = СбисОтправитьИОбработатьКоманду(Кэш, "API3.GetSbisObject", ПараметрыМетода, ДопПараметры, Отказ);
	
	Если Отказ Тогда
		Результат = Кэш.ОбщиеФункции.СбисИсключение(Результат, "API.ПрочитатьАПИОбъектСБИС");
	КонецЕсли;  
	
	Возврат Результат;

КонецФункции // API3_GetSbisObject()

//Подготовка данных по загружаемым в 1С объектам на сервисе IntegrationConfig порционно
&НаКлиенте
Функция ExtSyncDoc_Prepare(Кэш, ПараметрыВызова, Отказ) Экспорт
	ДопПараметрыВызова = Новый Структура("ЕстьРезультат,АдресРесурса,РежимКонвертации", Истина, "/integration_config/service/", "Стандарт");
	Результат = СбисОтправитьИОбработатьКоманду(Кэш, "ExtSyncDoc.Prepare", ПараметрыВызова, ДопПараметрыВызова, Отказ);
	Если Отказ Тогда
		Результат = Кэш.ОбщиеФункции.сбисИсключение(Результат, "ExtSyncDoc.Prepare");
	КонецЕсли;
	Возврат Результат;	
КонецФункции

// API3.ExtSyncDocRead
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
Функция API3_ExtSyncDocRead(Кэш, ПараметрыМетода, ДопПараметры, Отказ = Ложь) Экспорт 

	ДопПараметры = Новый Структура("ЕстьРезультат,АдресРесурса", Истина, "/integration_config/service/");

	Результат = СбисОтправитьИОбработатьКоманду(Кэш, "API3.ExtSyncDocRead", ПараметрыМетода, ДопПараметры, Отказ);
	
	Если Отказ Тогда
		Результат = Кэш.ОбщиеФункции.СбисИсключение(Результат, "API.ОбновитьОбъектСБИСИзОбъекта1С");
	КонецЕсли;        
	
	Возврат Результат; 

КонецФункции // API3.ExtSyncDocRead()

// API3.FindSbisObject
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
Функция API3_FindSbisObject(Кэш, ПараметрыМетода, ДопПараметры, Отказ = Ложь) Экспорт 

	ДопПараметры = Новый Структура("ЕстьРезультат,АдресРесурса", Истина, "/service/");

	Результат = СбисОтправитьИОбработатьКоманду(Кэш, "API3.FindSbisObject", ПараметрыМетода, ДопПараметры, Отказ);
	
	Если Отказ Тогда
		Результат = Кэш.ОбщиеФункции.СбисИсключение(Результат, "API3.FindSbisObject");
	КонецЕсли;        
	
	Возврат Результат["result"]; 

КонецФункции // API3.FindSbisObject() 

// MappingObject.UpdateFromData
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
Функция MappingObject_UpdateFromData(Кэш, ПараметрыМетода, ДопПараметры, Отказ = Ложь) Экспорт 

	ДопПараметры = Новый Структура("ЕстьРезультат,АдресРесурса", Истина, "/integration_config/service/");

	Результат = СбисОтправитьИОбработатьКоманду(Кэш, "MappingObject.UpdateFromData", ПараметрыМетода, ДопПараметры, Отказ);
	
	Если Отказ Тогда
		Результат = Кэш.ОбщиеФункции.СбисИсключение(Результат, "MappingObject.UpdateFromData");
	КонецЕсли;        
	
	Возврат Результат; 

КонецФункции // MappingObject.UpdateFromData() 

//Обновление записи Маппинга объекта на сервисе
&НаКлиенте
Функция ОбновитьЗаписьСопоставления(Кэш, Фильтр, Данные, Отказ) Экспорт
	ДопПараметрыВызова = Новый Структура("ЕстьРезультат,АдресРесурса,РежимКонвертации", Истина, "/integration_config/service/", "Стандарт");
	Результат = сбисОтправитьИОбработатьКоманду(Кэш, "MappingObject.FindAndUpdate", Новый Структура("Filter,Data", Фильтр, Данные), ДопПараметрыВызова, Отказ);
	Если Отказ Тогда
		Результат = Кэш.ОбщиеФункции.сбисИсключение(Результат, "API.РассчитатьОбъектыНаЗапись");
	КонецЕсли;
	Возврат Результат;
КонецФункции

////////////////////////////////////////////////////
//////////////Серверные настройки вызов/////////////
////////////////////////////////////////////////////
&НаКлиенте
Функция ПолучитьXslt(Кэш, ПараметрыМетода, ДопПараметрыЗапроса, Отказ) Экспорт
	ДопПараметрыЗапроса.Вставить("АдресРесурса", "/integration_config/service/");
	ПараметрыЗапроса = Новый Структура("mask", "*.xslt");
	Результат = сбисОтправитьИОбработатьКоманду(Кэш, "API301.FindXSLT", ПараметрыЗапроса, ДопПараметрыЗапроса, Отказ);
	Если Отказ Тогда
		Возврат Результат;
	КонецЕсли;
	Результат = Кэш.РаботаСJSON.сбисПрочитатьJSON(Результат);
	Если Результат.Свойство("data") Тогда
		Результат = Результат.data;
	КонецЕсли;
	Возврат Результат
КонецФункции

&НаКлиенте
Функция ПолучитьИни(Кэш, ИмяМетода, ПараметрыМетода, ДопПараметрыЗапроса, Отказ) Экспорт
	ДопПараметрыЗапроса.Вставить("АдресРесурса",	"/integration_config/service/");
	ДопПараметрыЗапроса.Вставить("РежимКонвертации","Стандарт");
	сбисСервис = "IntegrationConnection";
	Если ИмяМетода = "ReadConfig" Тогда                                     
		сбисСервис = "IntegrationConfig";
	КонецЕсли;
	Результат = сбисОтправитьИОбработатьКоманду(Кэш, сбисСервис + "." + ИмяМетода, ПараметрыМетода, ДопПараметрыЗапроса, Отказ);
	Если ТипЗнч(Результат) = Тип("Массив") Тогда
		Результат = МассивСтруктурВСтруктуру(Результат);
	КонецЕсли;
	Если Отказ Тогда
		Возврат Кэш.ОбщиеФункции.сбисИсключение(Результат, "API.ПолучитьИни");
	ИначеЕсли Результат = Null Тогда
		Отказ = Истина;
		Возврат Кэш.ОбщиеФункции.сбисИсключение(,"API.ПолучитьИни", 756, "Подключение недоступно", "Возможно оно недоступно для выбранного пользователя, либо было удалено.");
	КонецЕсли;
	Возврат Результат;
КонецФункции

&НаКлиенте
Функция ЗаписатьConnection(Кэш, ПараметрыМетода, ДопПараметрыЗапроса, Отказ) Экспорт
	ДопПараметрыЗапроса.Вставить("АдресРесурса", "/integration_config/service/");
	Возврат сбисОтправитьИОбработатьКоманду(Кэш, "IntegrationConnection.WriteConnection", ПараметрыМетода, ДопПараметрыЗапроса, Отказ)
КонецФункции

&НаКлиенте
Функция ПолучитьСписокConnection(Кэш, ПараметрыМетода, ДопПараметрыЗапроса, Отказ) Экспорт
	ДопПараметрыЗапроса.Вставить("АдресРесурса",	"/integration_config/service/");
	ДопПараметрыЗапроса.Вставить("РежимКонвертации","Стандарт");
	Возврат сбисОтправитьИОбработатьКоманду(Кэш, "IntegrationConnection.ReadConnectionList", ПараметрыМетода, ДопПараметрыЗапроса, Отказ)
КонецФункции

&НаКлиенте
Функция ПолучитьСписокConfig(Кэш, ПараметрыМетода, ДопПараметрыЗапроса, Отказ) Экспорт
	ДопПараметрыЗапроса.Вставить("АдресРесурса", "/integration_config/service/");
	РезультатЗапроса = сбисОтправитьИОбработатьКоманду(Кэш, "IntegrationConfig.ReadConfigList", ПараметрыМетода, ДопПараметрыЗапроса, Отказ);
	Если Отказ Тогда
		Возврат РезультатЗапроса;
	КонецЕсли;
	Возврат сбисRecordSet_to_1C(РезультатЗапроса, Отказ);
	
КонецФункции

&НаКлиенте
Функция сбисRecordSet_to_1C(сбисСписокЗаписей, Отказ) Экспорт 
	сбисДанные		= Неопределено;
	сбисКлючи		= Неопределено;
	сбисРезультат	= Новый Массив;
	Если Не ТипЗнч(сбисСписокЗаписей) = Тип("Структура")
		Или	Не сбисСписокЗаписей.Свойство("d", сбисДанные)
		Или Не сбисСписокЗаписей.Свойство("s", сбисКлючи)Тогда
		Отказ = Истина;
		Возврат Новый Структура("code, message, details", 100, "Неизвестная ошибка системы", "Переданая структура не имеет формат RecordSet");
	КонецЕсли;
	Для Каждого СтрокаДанных Из сбисДанные Цикл
		сбисСтрокаРезультат = Новый Структура;
		Для ИндексКлюча = 0 По сбисКлючи.Количество()-1 Цикл
			Попытка
				сбисСтрокаРезультат.Вставить(сбисКлючи[ИндексКлюча]["n"], СтрокаДанных[ИндексКлюча]);
			Исключение
				//Некорректные ключи не обрабатываются
				Продолжить;
			КонецПопытки;
		КонецЦикла;
		сбисРезультат.Добавить(сбисСтрокаРезультат);
	КонецЦикла;
	Возврат сбисРезультат;
	
КонецФункции




