
#Область include_core2_vo2_СпособыОбмена_NativeAPI_ВнешниеОбертки_АсинхронноеВыполнениеДействия
#КонецОбласти

#Область include_core2_vo2_СпособыОбмена_NativeAPI_ВнешниеОбертки_АсинхроннаяОтправка
#КонецОбласти

&НаКлиенте
Функция СБИС_ЗаписатьДокумент(Кэш, document_in, ДопПараметры=Неопределено, Отказ=Ложь)
	
	Если ДопПараметры = Неопределено Тогда
		ДопПараметры = Новый Структура("ПреобразовыватьДаты, СообщатьПриОшибке, ВернутьОшибку", Ложь, Ложь, Истина);
	Иначе
		ОбязательныеПараметры = Новый Структура("ПреобразовыватьДаты, СообщатьПриОшибке, ВернутьОшибку", Ложь, Ложь, Истина);
		Для Каждого КлючЗначение Из ОбязательныеПараметры Цикл
			Если Не ДопПараметры.Свойство(КлючЗначение.Ключ) Тогда
				ДопПараметры.Вставить(КлючЗначение.Ключ,КлючЗначение.Значение);
			КонецЕсли;
		КонецЦикла;
	КонецЕсли;
	
	СтруктураПараметровЗапроса	= Новый Структура("Документ", document_in);
	Результат = сбисОтправитьИОбработатьКоманду(Кэш, "СБИС.ЗаписатьДокумент", СтруктураПараметровЗапроса, ДопПараметры, Отказ);
	Если Отказ Тогда
		Возврат Кэш.ОбщиеФункции.сбисИсключение(Результат,  "SABYHttpClient.СБИС_ЗаписатьДокумент");
	КонецЕсли;
	Возврат Результат;
	
КонецФункции

&НаКлиенте
Функция СБИС_ВыполнитьДействие(Кэш, document_in, ДопПараметры, Отказ) Экспорт
	Результат = СбисОтправитьИОбработатьКоманду(Кэш, "СБИС.ВыполнитьДействие", Новый Структура("Документ",document_in), ДопПараметры, Отказ);
	Если Отказ Тогда
		Возврат Кэш.ОбщиеФункции.сбисИсключение(Результат,  "API.СБИС_ВыполнитьДействие");
	КонецЕсли;
	Возврат Результат;
КонецФункции

&НаКлиенте
Функция СБИС_ПодготовитьДействие(Кэш, document_in, ДопПараметры, Отказ) Экспорт
	Результат = СбисОтправитьИОбработатьКоманду(Кэш, "СБИС.ПодготовитьДействие", Новый Структура("Документ",document_in), ДопПараметры, Отказ);	
	Если Отказ Тогда
		Возврат Кэш.ОбщиеФункции.сбисИсключение(Результат,  "SABYHttpClient.СБИС_ПодготовитьДействие");
	КонецЕсли;
	Возврат Результат;
КонецФункции

&НаКлиенте
Функция СБИС_СериализоватьСтрокуВBase64(Кэш, ПараметрыСериализовать, ДопПараметры, Отказ) Экспорт
	Возврат сбисСтрокаВBASE64(ПараметрыСериализовать.Строка);
КонецФункции

&НаКлиенте
Функция СБИС_СериализоватьФайлВBase64(Кэш, ПараметрыСериализовать, ДопПараметры, Отказ) Экспорт
	Возврат сбисФайлСКлиентаВBASE64(ПараметрыСериализовать.ПолноеИмяФайла);
КонецФункции  

//Функция сохраняет по ссылке в файл в зависимости от среды и настройки "вызовы на клиенте".
//При успехе возвращает ссылку на файл, куда сохранили
//При неудаче структуру ошибки
&НаКлиенте
Функция СБИС_СохранитьПоСсылкеВФайл(Кэш, ПараметрыФайла, ДопПараметры, Отказ) Экспорт
	ПараметрыВызова = Новый Структура("АдресРесурса", ПараметрыФайла.Ссылка);
	ИмяФайлаПолучить = ПараметрыФайла.ИмяФайла;
	Если Не ЗначениеЗаполнено(ИмяФайлаПолучить) Тогда
		ИмяФайлаПолучить = Кэш.ОбщиеФункции.СбисПолучитьИмяВременногоФайлаКлиент("tmp");
	КонецЕсли;
	//#Если ВебКлиент Тогда
	//	Результат = СохранитьВложениеПоСсылкеВФайлНаСервере(КэшДляЗапросаНаСервере(Кэш), ПараметрыВызова, Отказ);
	//	Если Отказ Тогда
	//		Возврат Кэш.ОбщиеФункции.сбисИсключение(Результат,  "API.СБИС_СохранитьПоСсылкеВФайл");
	//	КонецЕсли;
	//	//Получаем файл с сервера
	//	Результат = СбисПолучитьФайлНаКлиент(Кэш, ИмяФайлаПолучить, Результат, Отказ);
	//	Если Отказ Тогда
	//		Возврат Кэш.ОбщиеФункции.сбисИсключение(Результат,  "API.СБИС_СохранитьПоСсылкеВФайл");
	//	КонецЕсли;
	//#ИначеЕсли ТолстыйКлиентОбычноеПриложение Тогда
	//	ПараметрыВызова.Вставить("ПутьКФайлу", ИмяФайлаПолучить);
	//	Результат = СбисОтправитьИОбработатьКомандуGETНаКлиенте(Кэш, ПараметрыВызова, Отказ);
	//	Если Отказ Тогда
	//		Возврат Кэш.ОбщиеФункции.сбисИсключение(Результат,  "API.СБИС_СохранитьПоСсылкеВФайл");
	//	КонецЕсли;
	//#Иначе
		//Если Кэш.Парам.ИнтеграцияAPIВызовыНаКлиенте Тогда
			ПараметрыВызова.Вставить("ПутьКФайлу", ИмяФайлаПолучить);
			Результат = СбисОтправитьИОбработатьКомандуGETНаКлиенте(Кэш, ПараметрыВызова, Отказ);
			Если Отказ Тогда
				Возврат Кэш.ОбщиеФункции.сбисИсключение(Результат,  "API.СБИС_СохранитьПоСсылкеВФайл");
			КонецЕсли;
	//	Иначе
	//		Результат = СохранитьВложениеПоСсылкеВФайлНаСервере(КэшДляЗапросаНаСервере(Кэш), ПараметрыВызова, Отказ);
	//		Если Отказ Тогда
	//			Возврат Кэш.ОбщиеФункции.сбисИсключение(Результат,  "API.СБИС_СохранитьПоСсылкеВФайл");
	//		КонецЕсли;
	//		//Получаем файл с сервера
	//		Результат = СбисПолучитьФайлНаКлиент(Кэш, ИмяФайлаПолучить, Результат, Отказ);
	//		Если Отказ Тогда
	//			Возврат Кэш.ОбщиеФункции.сбисИсключение(Результат,  "API.СБИС_СохранитьПоСсылкеВФайл");
	//		КонецЕсли;
	//	КонецЕсли;
	//#КонецЕсли
	Возврат ИмяФайлаПолучить;
КонецФункции

&НаКлиенте
Функция СБИС_СписокИзменений(Кэш, filter, ДопПараметры, Отказ) Экспорт
	СтруктураПараметровЗапроса	= Новый Структура("Фильтр", filter);
	ДопПараметрыВызова			= Новый Структура("ВернутьОшибку, СообщатьПриОшибке", Истина, Ложь);
	Результат = СбисОтправитьИОбработатьКоманду(Кэш, "СБИС.СписокИзменений", СтруктураПараметровЗапроса, ДопПараметрыВызова, Отказ);
	Если Отказ Тогда
		Результат = Кэш.ОбщиеФункции.СбисИсключение(Результат, Кэш.СБИС.ПараметрыИнтеграции.ИнтеграцияИмя + ".СБИС_СписокИзменений");
	КонецЕсли;
	Возврат Результат;
КонецФункции

//Возвращает текущую дату/время. Для вызовов сервера - время на сервере.
&НаКлиенте
Функция СБИС_ТекущаяДата(Кэш, Отказ=Ложь) Экспорт
	
	//Если Кэш.Парам.ИнтеграцияAPIВызовыНаКлиенте Тогда
		Возврат ТекущаяДата();
	//КонецЕсли;		
	//ДопПараметры				= Новый Структура("СообщатьПриОшибке, ВернутьОшибку", Ложь, Истина);
	//СтруктураПараметровЗапроса	= Новый Структура("Параметр", Новый Структура);
	//РезультатЗапроса = сбисОтправитьИОбработатьКоманду(Кэш, "СБИС.ИнформацияОВерсии", СтруктураПараметровЗапроса, ДопПараметры, Отказ);
	//Если Отказ Тогда
	//	Возврат ТекущаяДата();
	//КонецЕсли;
	//Возврат РезультатЗапроса.ВнешнийИнтерфейс.ДатаВремяЗапроса;
	
КонецФункции

&НаКлиенте
Функция СБИС_ИнформацияОКонтрагенте(Кэш, СтруктураКонтрагента, ДопПараметры, Отказ) Экспорт
	СтруктураРезультата = сбисОтправитьИОбработатьКоманду(Кэш, "СБИС.ИнформацияОКонтрагенте", Новый Структура("Участник", СтруктураКонтрагента), ДопПараметры, Отказ);
	Если Отказ Тогда
		Возврат Кэш.ОбщиеФункции.сбисИсключение(СтруктураРезультата, "API.СБИС_ИнформацияОКонтрагенте");
	КонецЕсли;
	
	Возврат СтруктураРезультата;
КонецФункции

&НаКлиенте
Функция СБИС_ПолучитьИнформациюОТекущемПользователе(Кэш, param, ДопПараметры, Отказ) Экспорт
	param.Вставить("ДопПоля", "Аккаунт,ИдПрофиля");
	Результат = СбисОтправитьИОбработатьКоманду(Кэш, "СБИС.ИнформацияОТекущемПользователе", Новый Структура("Параметр", param), ДопПараметры, Отказ);
	Если Отказ Тогда
		Возврат Кэш.ОбщиеФункции.сбисИсключение(Результат,  "API.СБИС_ПолучитьИнформациюОТекущемПользователе");
	КонецЕсли;
	Возврат Результат;
КонецФункции   

&НаКлиенте
Функция СБИС_ПолучитьСписокАккаунтов(Кэш, param, ДопПараметры, Отказ) Экспорт
	ДопПараметры.Вставить("АдресРесурса", "auth/service/?srv=1"); 
	Результат = СбисОтправитьИОбработатьКоманду(Кэш, "СБИС.СписокАккаунтов", param, ДопПараметры, Отказ);
	Если Отказ Тогда
		Возврат Кэш.ОбщиеФункции.сбисИсключение(Результат,  "API.СБИС_ПолучитьСписокАккаунтов");
	КонецЕсли;
	Возврат Результат;
КонецФункции

&НаКлиенте
Функция СБИС_ПереключитьАккаунт(Кэш, param, ДопПараметры, Отказ) Экспорт
	ДопПараметры.Вставить("АдресРесурса", "auth/service/?srv=1");
	Результат = СбисОтправитьИОбработатьКоманду(Кэш, "СБИС.ПереключитьАккаунт", Новый Структура("Параметр", param), ДопПараметры, Отказ);
	Если Отказ Тогда
		Возврат Кэш.ОбщиеФункции.сбисИсключение(Результат,  "API.СБИС_ПереключитьАккаунт");
	КонецЕсли;
	Возврат Результат;
КонецФункции

&НаКлиенте
Функция СБИС_ПолучитьПараметрыПакетаДляОткрытияОнлайн(ОписаниеПакета, ДопПараметры) Экспорт
	Кэш = ДопПараметры.Кэш;
	Если	ОписаниеПакета.ИдАккаунта = "" Тогда
		Возврат Новый Структура("ИдДокумента, Тикет", ОписаниеПакета.ИдДокумента, "");
	Иначе
		ДанныеТикета = Кэш.СБИС.МодульОбъектаКлиент.СбисПолучитьТикетДляАккаунта(Кэш, ОписаниеПакета, Ложь);
		Возврат Новый Структура("ИдДокумента, Тикет, СтарыйИдСессии", ОписаниеПакета.ИдДокумента, ДанныеТикета.Тикет, ДанныеТикета.СтарыйИдСессии);
	КонецЕсли;
КонецФункции

&НаКлиенте
Функция Интеграция_ФЭДМультиСгенерировать(ПараметрыДокумента, НаборПодстановок, ДопПараметры) Экспорт
	
	Попытка
		Кэш = ДопПараметры.Кэш;
		ДопПараметрыВызова = Новый Структура("СообщатьПриОшибке, ВернутьОшибку",  Ложь, Истина);
		
		Отказ = Ложь;
		ПараметрыВызова = Новый Структура;
		ПараметрыВызова.Вставить("Format",			ПараметрыДокумента);
		ПараметрыВызова.Вставить("SubstitutionList",НаборПодстановок);
		Результат = СбисОтправитьИОбработатьКоманду(ДопПараметры.Кэш, "Integration.FEDMultiGenerate", ПараметрыВызова, ДопПараметрыВызова, Отказ);
		
		Если Отказ Тогда
			МодульОбъектаКлиент().ВызватьСбисИсключение(Результат, Кэш.СБИС.ПараметрыИнтеграции.ИнтеграцияИмя + ".СбисОтправитьИОбработатьКомандуCallSabyApi2");
		КонецЕсли;
		
		Для Каждого файл Из Результат Цикл
			файл["Тело"] = Кэш.ОбщиеФункции.сбисТекстИзBase64(файл["Тело"])
		КонецЦикла;
		
		Возврат Результат;
	Исключение
		ИнфоОбОшибке = ИнформацияОбОшибке();
		МодульОбъектаКлиент().ВызватьСбисИсключение(ИнфоОбОшибке, Кэш.СБИС.ПараметрыИнтеграции.ИнтеграцияИмя + ".Интеграция_ФЭДМультиСгенерировать");
	КонецПопытки;
	
КонецФункции

&НаКлиенте
Функция СБИС_ЗаписатьВложение(Кэш, param, ДопПараметры, Отказ) Экспорт
	Результат = сбисОтправитьИОбработатьКоманду(Кэш, "СБИС.ЗаписатьВложение", Новый Структура("Документ", param), ДопПараметры, Отказ);
	Если Отказ Тогда
		Возврат Кэш.ОбщиеФункции.сбисИсключение(Результат,  Кэш.СБИС.ПараметрыИнтеграции.ИнтеграцияИмя + ".СБИС_ЗаписатьВложение");
	КонецЕсли;
	Возврат Результат
КонецФункции

&НаКлиенте
Функция АПИ3_ИнитКоннекшен(ПараметрыИнит, ДопПараметрыВызова) Экспорт
	
	ДопПарметрыВызоваИнтеграции = Новый Структура("АдресРесурса, СообщатьПриОшибке, ВернутьОшибку", "/integration_config/service/", Ложь, Истина);
	
	Результат = СбисОтправитьИОбработатьКоманду(ДопПараметрыВызова.Кэш, "API3.InitConnection", ПараметрыИнит, ДопПарметрыВызоваИнтеграции, ДопПараметрыВызова.Отказ);
	Если ДопПараметрыВызова.Отказ Тогда
		Возврат ДопПараметрыВызова.Кэш.ОбщиеФункции.сбисИсключение(Результат,  ДопПараметрыВызова.Кэш.СБИС.ПараметрыИнтеграции.ИнтеграцияИмя + ".АПИ3_ИнитКоннекшен");
	КонецЕсли;
	Возврат Результат;
	
КонецФункции

&НаКлиенте
Функция ФункционалВключен(Кэш, ИмяМетода, ДопПараметры = Неопределено, Отказ = Ложь) Экспорт
	ДопПараметры = Новый Структура; 
	Возврат СбисОтправитьИОбработатьКоманду(Кэш, "ExtSys.FeatureIsOn", Новый Структура("name", ИмяМетода), ДопПараметры, Отказ) = Истина;
КонецФункции

&НаКлиенте
Функция сбисОтправитьСообщениеОшибки(Кэш, СообщениеОбОшибке, Отказ) Экспорт

	//Возврат Истина;
	
	сбисДополнительныеПараметрыОшибки = Новый Структура("АдресРесурса, СообщатьПриОшибке, ВернутьОшибку", "/integration_config/service/", Ложь, Истина);
	СообщениеОбОшибке.data = Кэш.РаботаСJson.ПреобразоватьЗначениеВJSON(СообщениеОбОшибке.data);
	
	СтруктураПараметровЗапроса = Новый Структура("error", СообщениеОбОшибке);
	Возврат СбисОтправитьИОбработатьКоманду(Кэш, "API3.WriteError", СтруктураПараметровЗапроса, сбисДополнительныеПараметрыОшибки, Отказ);
КонецФункции

&НаКлиенте
Функция сбисРезультатАвторизации(Кэш, ПараметрыРезультата, Отказ) Экспорт
	РезультатАвторизации = ПараметрыРезультата.Результат;
	Если Не Отказ Тогда
		МодульОбъектаКлиент().ИзменитьПараметрСбис("Авторизован",	Истина);
		Возврат РезультатАвторизации;
	КонецЕсли;
	Если РезультатАвторизации.details = "Для входа введите полученный код подтверждения." Тогда
		РезультатАвторизации.message= "Требуется подтверждение действия";
		РезультатАвторизации.code	= 303;
	ИначеЕсли РезультатАвторизации.code = 775 Тогда
		РезультатАвторизации.details= "Не удалось авторизоваться по " + ?(ПараметрыРезультата.Параметры.Свойство("Логин"), "логину/паролю.", "сертификату.");
	ИначеЕсли РезультатАвторизации.code = 759 Тогда//Переключимся на альтернативный домен и повторим авторизацию
		Возврат сбисПереключитьДомен(Кэш, ПараметрыРезультата, Отказ)
	КонецЕсли;
	Возврат РезультатАвторизации;
КонецФункции

&НаКлиенте
Функция ExtSys_FeatureIsOn(ПараметрыФичи, ДопПараметрыВызова) Экспорт
	Если Не МодульОбъектаКлиент().ПолучитьЗначениеПараметраСбис("Авторизован") Тогда
		//Если ещё не авторизовались, то за фичей не идём, считаем что неопределено.
		Возврат Неопределено;
	КонецЕсли;
	ДопПараметры = Новый Структура("ВернутьОшибку, СообщатьПриОшибке", Истина, Ложь); 
	Возврат СбисОтправитьИОбработатьКоманду(ДопПараметрыВызова.Кэш, "ExtSys.FeatureIsOn", Новый Структура("name", ПараметрыФичи.НазваниеФичи), ДопПараметры, Ложь) = Истина;
КонецФункции

// Вызов функции MappingObject.List. Формирует список
// объектов синхронизируемых объектов определенного типа,
// с данными сопоставления и с расшифровкой естественных ключей
//
// Параметры:
//  Кэш  - Структура - Кэш обработки
//  ДопПоля  - Структура - Набор полей, которыми будут расширены
//					возвращаемые записи.
//	Фильтр	- Структура - Параметры фильтрации выборки.
//	Сортировка	- Структура - Параметры сортировки записей в выборке.
//	Навигация	-	 Структура - Параметры для навигации с типом
//					"постраничная", "бесконечный скролл"
//					или "по курсору".
//
// Возвращаемое значение:
//   Структура   - Результат вызова. Список объектов или ошибка
//
&НаКлиенте
Функция MappingObject_List(Кэш, ДопПоля, Фильтр, Навигация, Отказ = Ложь) Экспорт 

	ДопПараметрыВызова = Новый Структура("ЕстьРезультат,АдресРесурса,РежимКонвертации", Истина, "/integration_config/service/", "Стандарт"); 
	ПараметрыВызова = Новый Структура;
	ПараметрыВызова.Вставить("ExtraFields",		ДопПоля);
	ПараметрыВызова.Вставить("Filter",		Фильтр);  
	ПараметрыВызова.Вставить("Pagination",	Навигация);
	Результат = сбисОтправитьИОбработатьКоманду(Кэш, "MappingObject.List", ПараметрыВызова, ДопПараметрыВызова, Отказ);
	Если Отказ Тогда
		Результат = Кэш.ОбщиеФункции.сбисИсключение(Результат, "MappingObject.List");
	КонецЕсли;
	Возврат Результат;

КонецФункции // MappingObject_List()

&НаКлиенте
Функция СБИС_ПолучитьСопоставлениеСторон(Кэш, ПараметрыДанныеУчастников, ДопПараметры=Неопределено, Отказ) Экспорт
	ДопПараметры = Новый Структура;
	ПараметрыВызова = Новый Структура("data", ПараметрыДанныеУчастников);
	
	Результат = СбисОтправитьИОбработатьКоманду(Кэш, "ExtSysOrganization.MassFind", ПараметрыВызова, ДопПараметры, Отказ);
	Если Отказ Тогда
		Возврат Кэш.ОбщиеФункции.сбисИсключение(Результат,  Кэш.СБИС.ПараметрыИнтеграции.ИнтеграцияИмя + ".СБИС_ПолучитьСопоставлениеСторон");
	КонецЕсли;
	Возврат Результат;
КонецФункции

// Функция получает складские параметры документа, вызывая метод ExtSysMarking.GetParams 
//
// Параметры:
//  params  - Структура - Параметры фильтрации метода
//  ДопПараметры  - Структура - Набор полей, работа с которыми может расширить результат работы функции.
//
// Возвращаемое значение:
//   Структура   - Результат вызова. Список объектов или ошибка
//
&НаКлиенте
Функция ExtSysMarking_GetParams(params, ДопПараметры, Отказ=Ложь) Экспорт  
	
	Кэш = ДопПараметры.Кэш;
	ДопПараметрыВызова = Новый Структура("ВернутьОшибку, СообщатьПриОшибке", Истина, Ложь);  
	ПараметрыКоманды = Новый Структура("docflowId,paramsList",params.ИдДок, params.paramsList); 
	
	Результат = сбисОтправитьИОбработатьКоманду(Кэш, "ExtSysMarking.GetParams", ПараметрыКоманды, ДопПараметрыВызова, Отказ);
	Если Отказ Тогда
		Возврат Кэш.ОбщиеФункции.сбисИсключение(Результат,  Кэш.СБИС.ПараметрыИнтеграции.ИнтеграцияИмя + ".ExtSysMarking_GetParams");
	КонецЕсли;
	Возврат Результат;
	
КонецФункции 

// Функция возвращает данные о проверке кодов маркировки документа, вызывая метод ExtSysMarking.CheckState 
//
// Параметры:
//  params  - Структура - Параметры фильтрации метода
//  ДопПараметры  - Структура - Набор полей, работа с которыми может расширить результат работы функции.
//
// Возвращаемое значение:
//   Структура   - Результат вызова. Список объектов или ошибка
//
&НаКлиенте
Функция ExtSysMarking_CheckState(params, ДопПараметры, Отказ=Ложь) Экспорт 
	
	Кэш = ДопПараметры.Кэш;
	ДопПараметрыВызова = Новый Структура("ВернутьОшибку, СообщатьПриОшибке", Истина, Ложь);  
	ПараметрыКоманды = Новый Структура("docflowId", params.ИдДок); 
	
	Результат = сбисОтправитьИОбработатьКоманду(Кэш, "ExtSysMarking.CheckState", ПараметрыКоманды, ДопПараметрыВызова, Отказ);   
	Если Отказ Тогда
		Возврат Кэш.ОбщиеФункции.сбисИсключение(Результат,  Кэш.СБИС.ПараметрыИнтеграции.ИнтеграцияИмя + ".ExtSysMarking_CheckState");
	КонецЕсли;
	Возврат Результат;

КонецФункции     

// Функция возвращает данные маркированной номенклатуры документа 
//
// Параметры:
//  params  - Структура - Параметры фильтрации метода
//  ДопПараметры  - Структура - Набор полей, работа с которыми может расширить результат работы функции.
//
// Возвращаемое значение:
//   Массив   - Результат вызова. Список объектов или ошибка
//
&НаКлиенте
Функция ExtSysMarking_NumList(params, ДопПараметры, Отказ=Ложь) Экспорт 
	
	Кэш = ДопПараметры.Кэш;
	ДопПараметрыВызова = Новый Структура("ВернутьОшибку, СообщатьПриОшибке", Истина, Ложь);    
	
	ПараметрыКоманды = Новый Структура();  
	ПараметрыКоманды.Вставить("ДопПоля",Новый Массив()); 
	ПараметрыКоманды.Вставить("Фильтр",params.Фильтр);    
	ПараметрыКоманды.Вставить("Сортировка",Новый Массив());
	ПараметрыКоманды.Вставить("Навигация",Новый Массив());

	Результат = сбисОтправитьИОбработатьКоманду(Кэш, "ExtSysMarking.NumList", ПараметрыКоманды, ДопПараметрыВызова, Отказ);  
	Если Отказ Тогда
		Возврат Кэш.ОбщиеФункции.сбисИсключение(Результат,  Кэш.СБИС.ПараметрыИнтеграции.ИнтеграцияИмя + ".ExtSysMarking_NumList");
	КонецЕсли;
	Возврат Результат;

КонецФункции   

// Функция получяет параметры из SerialNumber.CustomList, по конкретной позиции номенклатуры 
//
// Параметры:
//  params  - Структура - Параметры фильтрации метода
//  ДопПараметры  - Структура - Набор полей, работа с которыми может расширить результат работы функции.
//
// Возвращаемое значение:
//   Массив   - Результат вызова. Список объектов или ошибка
//
&НаКлиенте
Функция ExtSysMarking_NomCheckState(params, ДопПараметры, Отказ=Ложь) Экспорт 
	Кэш = ДопПараметры.Кэш;
	
	ДопПараметрыВызова = Новый Структура("ВернутьОшибку, СообщатьПриОшибке", Истина, Ложь);   
	ПараметрыКоманды = Новый Структура("docflowId,nomPK",params.ИдДок,params.КодНоменклатуры); 
	
	Результат = сбисОтправитьИОбработатьКоманду(Кэш, "ExtSysMarking.NomCheckState", ПараметрыКоманды, ДопПараметрыВызова, Отказ); 
	Если Отказ Тогда
		Возврат Кэш.ОбщиеФункции.сбисИсключение(Результат,  Кэш.СБИС.ПараметрыИнтеграции.ИнтеграцияИмя + ".ExtSysMarking_NomCheckState");
	КонецЕсли;
	Возврат Результат;

КонецФункции  

// Функция получает параметры из SerialNumber.CustomList, по конкретной позиции номенклатуры. 
// В отличии от ExtSysMarking_NomCheckState по первичному ключу номенклатуры документа. 
//
// Параметры:
//  params  - Структура - Параметры фильтрации метода
//  ДопПараметры  - Структура - Набор полей, работа с которыми может расширить результат работы функции.
//
// Возвращаемое значение:
//   Массив   - Результат вызова. Список объектов или ошибка
//
&НаКлиенте
Функция ExtSysMarking_NomCheckStateByNomDoc(params, ДопПараметры, Отказ=Ложь) Экспорт 
	Кэш = ДопПараметры.Кэш;
	
	ДопПараметрыВызова = Новый Структура("ВернутьОшибку, СообщатьПриОшибке", Истина, Ложь);   
	ПараметрыКоманды = Новый Структура("docflowId,documentNomenclature",params.ИдДок,params.КодНоменклатуры); 
	
	Результат = сбисОтправитьИОбработатьКоманду(Кэш, "ExtSysMarking.NomCheckStateByNomDoc", ПараметрыКоманды, ДопПараметрыВызова, Отказ); 
	Если Отказ Тогда
		Возврат Кэш.ОбщиеФункции.сбисИсключение(Результат,  Кэш.СБИС.ПараметрыИнтеграции.ИнтеграцияИмя + ".ExtSysMarking_NomCheckStateByNomDoc");
	КонецЕсли;
	Возврат Результат;

КонецФункции 

// Функция устанавливает параметры выбытия кодов маркировки ExtSysMarking.SetParamt
//
// Параметры:
//  params  - Структура - Параметры фильтрации метода
//  ДопПараметры  - Структура - Набор полей, работа с которыми может расширить результат работы функции.
//
// Возвращаемое значение:
//   Структура   - Результат вызова. Список объектов или ошибка
//
&НаКлиенте
Функция ExtSysMarking_SetParam(params, ДопПараметры, Отказ=Ложь) Экспорт 
	
	Кэш = ДопПараметры.Кэш;
	ДопПараметрыВызова = Новый Структура("ВернутьОшибку, СообщатьПриОшибке", Истина, Ложь);  
	ПараметрыКоманды = Новый Структура();  
	ПараметрыКоманды.Вставить("docflowId",params.ИдДок);  
	ПараметрыКоманды.Вставить("name",params.name); 
	ПараметрыКоманды.Вставить("value",params.value);  
	
	Результат = сбисОтправитьИОбработатьКоманду(Кэш, "ExtSysMarking.SetParam", ПараметрыКоманды, ДопПараметрыВызова, Отказ);  
	Если Отказ Тогда
		Возврат Кэш.ОбщиеФункции.сбисИсключение(Результат,  Кэш.СБИС.ПараметрыИнтеграции.ИнтеграцияИмя + ".ExtSysMarking_SetParam");
	КонецЕсли;
	Возврат Результат;
	
КонецФункции 

// Функция проверяет наличие токена в ГИС МТ
//
// Параметры:
//  params  - Структура - Параметры фильтрации метода
//  ДопПараметры  - Структура - Набор полей, работа с которыми может расширить результат работы функции.
//
// Возвращаемое значение:
//   Структура   - Результат вызова. Список объектов или ошибка
//
&НаКлиенте
Функция ExtSysMarking_CheckGisSetting(params, ДопПараметры, Отказ=Ложь) Экспорт   
	
	Кэш = ДопПараметры.Кэш;
	ДопПараметрыВызова = Новый Структура("ВернутьОшибку, СообщатьПриОшибке", Истина, Ложь);  
	ПараметрыКоманды = Новый Структура("docflowId", params.ИдДок);
	Результат = сбисОтправитьИОбработатьКоманду(Кэш, "ExtSysMarking.CheckGisSetting", ПараметрыКоманды, ДопПараметрыВызова, Отказ);
	Если Отказ Тогда
		Возврат Кэш.ОбщиеФункции.сбисИсключение(Результат,  Кэш.СБИС.ПараметрыИнтеграции.ИнтеграцияИмя + ".ExtSysMarking_CheckGisSetting");
	КонецЕсли;
	Возврат Результат;

КонецФункции  

// Функция запуск проверку кодов маркировки в ГИС МТ 
//
// Параметры:
//  params  - Структура - Параметры фильтрации метода
//  ДопПараметры  - Структура - Набор полей, работа с которыми может расширить результат работы функции.
//
// Возвращаемое значение:
//   Структура   - Результат вызова. Список объектов или ошибка
//
&НаКлиенте
Функция ExtSysMarking_CheckSnCRPT(params, ДопПараметры, Отказ=Ложь) Экспорт 
	
	Кэш = ДопПараметры.Кэш;
	ДопПараметрыВызова = Новый Структура("ВернутьОшибку, СообщатьПриОшибке", Истина, Ложь);  
	ПараметрыКоманды = Новый Структура("docflowId", params.ИдДок);
	Результат = сбисОтправитьИОбработатьКоманду(Кэш, "ExtSysMarking.CheckSnCRPT", ПараметрыКоманды, ДопПараметрыВызова, Отказ); 
	Если Отказ Тогда
		Возврат Кэш.ОбщиеФункции.сбисИсключение(Результат,  Кэш.СБИС.ПараметрыИнтеграции.ИнтеграцияИмя + ".ExtSysMarking_CheckSnCRPT");
	КонецЕсли;
	Возврат Результат;

КонецФункции  

// Функция ищет сертификат по отпечатку после чего разбирает его
//
// Параметры:
//  params  - Структура - Параметры фильтрации метода
//  ДопПараметры  - Структура - Набор полей, работа с которыми может расширить результат работы функции.
//
// Возвращаемое значение:
//   Структура   - Результат вызова. Список объектов или ошибка
//
&НаКлиенте
Функция Сертификат_ПрочитатьПоОтпечатку(params, ДопПараметры, Отказ=Ложь) Экспорт 
	Кэш = ДопПараметры.Кэш;
	ДопПараметрыВызова = Новый Структура("ВернутьОшибку, СообщатьПриОшибке", Истина, Ложь);  
	
	ПараметрыКоманды = Новый Структура("Отпечаток", params.Отпечаток);
	Результат = сбисОтправитьИОбработатьКоманду(Кэш, "Сертификат.ПрочитатьПоОтпечатку", ПараметрыКоманды, ДопПараметрыВызова, Отказ);
	Если Отказ Тогда
		Возврат Кэш.ОбщиеФункции.сбисИсключение(Результат,  Кэш.СБИС.ПараметрыИнтеграции.ИнтеграцияИмя + ".Сертификат_ПрочитатьПоОтпечатку");
	КонецЕсли;
	Возврат Результат;
	
КонецФункции    

// Функция получает информацию по созданию токена ГИС МТ
//
// Параметры:
//  params  - Структура - Параметры фильтрации метода
//  ДопПараметры  - Структура - Набор полей, работа с которыми может расширить результат работы функции.
//
// Возвращаемое значение:
//   Структура   - Результат вызова. Список объектов или ошибка
//
&НаКлиенте
Функция ExtSysMarking_CheckGisTask(params, ДопПараметры, Отказ=Ложь) Экспорт 
	
	Кэш = ДопПараметры.Кэш;
	ДопПараметрыВызова = Новый Структура("ВернутьОшибку, СообщатьПриОшибке", Истина, Ложь);  
	
	ПараметрыКоманды = Новый Структура("docflowId", params.ИдДок);
	Результат = сбисОтправитьИОбработатьКоманду(Кэш, "ExtSysMarking.CheckGisTask", ПараметрыКоманды, ДопПараметрыВызова, Отказ);   
	Если Отказ Тогда
		Возврат Кэш.ОбщиеФункции.сбисИсключение(Результат,  Кэш.СБИС.ПараметрыИнтеграции.ИнтеграцияИмя + ".ExtSysMarking_CheckGisTask");
	КонецЕсли;
	Возврат Результат;
	
КонецФункции    

// Функция получает статус проверки документа ГИС МТ
//
// Параметры:
//  params  - Структура - Параметры фильтрации метода
//  ДопПараметры  - Структура - Набор полей, работа с которыми может расширить результат работы функции.
//
// Возвращаемое значение:
//   Структура   - Результат вызова. Список объектов или ошибка
//
&НаКлиенте
Функция ExtSysMarking_GetResendingConfigForGIS(params, ДопПараметры, Отказ=Ложь) Экспорт
	
	Кэш = ДопПараметры.Кэш;
	ДопПараметрыВызова = Новый Структура("ВернутьОшибку, СообщатьПриОшибке", Истина, Ложь);  
	ПараметрыКоманды = Новый Структура();  
	ПараметрыКоманды.Вставить("docflow_id", params.ИдДок); 
	Результат = сбисОтправитьИОбработатьКоманду(Кэш, "ExtSysMarking.GetResendingConfigForGIS", ПараметрыКоманды, ДопПараметрыВызова, Отказ);
	Если Отказ Тогда
		Возврат Кэш.ОбщиеФункции.сбисИсключение(Результат,  Кэш.СБИС.ПараметрыИнтеграции.ИнтеграцияИмя + ".ExtSysMarking_GetResendingConfigForGIS");
	КонецЕсли;
	Возврат Результат;

КонецФункции

// Функция отправляет коды маркировки в ГИС МТ 
//
// Параметры:
//  params  - Структура - Параметры фильтрации метода
//  ДопПараметры  - Структура - Набор полей, работа с которыми может расширить результат работы функции.
//
// Возвращаемое значение:
//   Структура   - Результат вызова. Список объектов или ошибка
//
&НаКлиенте
Функция ExtSysMarking_SendToGIS(params, ДопПараметры, Отказ=Ложь) Экспорт  
	
	Кэш = ДопПараметры.Кэш;
	ДопПараметрыВызова = Новый Структура("ВернутьОшибку, СообщатьПриОшибке", Истина, Ложь);  
	ПараметрыКоманды = Новый Структура();  
	ПараметрыКоманды.Вставить("docflowId", params.ИдДок); 
	Результат = сбисОтправитьИОбработатьКоманду(Кэш, "ExtSysMarking.SendToGIS", ПараметрыКоманды, ДопПараметрыВызова, Отказ);
	Если Отказ Тогда
		Возврат Кэш.ОбщиеФункции.сбисИсключение(Результат,  Кэш.СБИС.ПараметрыИнтеграции.ИнтеграцияИмя + ".ExtSysMarking_SendToGIS");
	КонецЕсли;
	Возврат Результат;
	
КонецФункции

// Функция вызывает создание токена в СБИС, для взаимодействия с ГИС МТ ExtSysMarking.CreateGisSetting
//
// Параметры:
//  params  - Структура - Параметры фильтрации метода
//  ДопПараметры  - Структура - Набор полей, работа с которыми может расширить результат работы функции.
//
// Возвращаемое значение:
//   Строка   - Результат вызова. Дата/время вызова или ошибка
//
&НаКлиенте
Функция ExtSysMarking_CreateGisSetting(params, ДопПараметры, Отказ=Ложь) Экспорт 
	Кэш = ДопПараметры.Кэш;
	ДопПараметрыВызова = Новый Структура("ВернутьОшибку, СообщатьПриОшибке", Истина, Ложь);    
	
	ПараметрыКоманды = Новый Структура(); 
	ПараметрыКоманды.Вставить("data",params);
	
	Результат = сбисОтправитьИОбработатьКоманду(Кэш, "ExtSysMarking.CreateGisSetting", ПараметрыКоманды, Новый Структура("ВернутьОшибку", Ложь), Отказ);  
	Если Отказ Тогда
		Возврат Кэш.ОбщиеФункции.сбисИсключение(Результат,  Кэш.СБИС.ПараметрыИнтеграции.ИнтеграцияИмя + ".ExtSysMarking_CreateGisSetting");
	КонецЕсли;
	Возврат Результат;
	
КонецФункции

// Функция запускает проверку проверку прослеживаемых позиций через обертку метода RNPT.SendDoc 
//
// Параметры:
//  params  - Структура - Параметры фильтрации метода
//  ДопПараметры  - Структура - Набор полей, работа с которыми может расширить результат работы функции.
//
// Возвращаемое значение:
//   Структура   - Результат вызова. Список объектов или ошибка
//
&НаКлиенте
Функция ExtSysMarking_SendDocumentRNPT(params, ДопПараметры, Отказ=Ложь) Экспорт 
	
	Кэш = ДопПараметры.Кэш;
	ДопПараметрыВызова = Новый Структура("ВернутьОшибку, СообщатьПриОшибке", Истина, Ложь);  
	ПараметрыКоманды = Новый Структура("docflowId", params.ИдДок); 
	
	Результат = сбисОтправитьИОбработатьКоманду(Кэш, "ExtSysMarking.SendDocumentRNPT", ПараметрыКоманды, ДопПараметрыВызова, Отказ);   
	Если Отказ Тогда
		Возврат Кэш.ОбщиеФункции.сбисИсключение(Результат,  Кэш.СБИС.ПараметрыИнтеграции.ИнтеграцияИмя + ".ExtSysMarking_SendDocumentRNPT");
	КонецЕсли;
	Возврат Результат;

КонецФункции 

// Функция получает двоичные данные протокола проверки документа СБИС, на наличие ошибок ФЛК 
//
// Параметры:
//  params  - Структура - Параметры фильтрации метода
//  ДопПараметры  - Структура - Набор полей, работа с которыми может расширить результат работы функции.
//
// Возвращаемое значение:
//   Структура   - Результат вызова. Список объектов или ошибка
//
&НаКлиенте
Функция ExtSysMarking_ExportAsHTML(params, ДопПараметры, Отказ=Ложь) Экспорт 
	
	Кэш = ДопПараметры.Кэш;
	ДопПараметрыВызова = Новый Структура("ВернутьОшибку, СообщатьПриОшибке", Истина, Ложь);  
	ПараметрыКоманды = Новый Структура("docflowId, attachId", params.ИдДок, params.ИдВложения);
	
	Результат = сбисОтправитьИОбработатьКоманду(Кэш, "ExtSysMarking.ExportAsHTML", ПараметрыКоманды, ДопПараметрыВызова, Отказ);   
	Если Отказ Тогда
		Возврат Кэш.ОбщиеФункции.сбисИсключение(Результат,  Кэш.СБИС.ПараметрыИнтеграции.ИнтеграцияИмя + ".ExtSysMarking_ExportAsHTML");
	КонецЕсли;
	Возврат Результат;

КонецФункции

&НаКлиенте
Функция ZakupkiGovAPI_GetContractInfo(Кэш, ПараметрыМетода, ДопПараметры, Отказ = Ложь) Экспорт
	
	Если ДопПараметры = Неопределено Тогда
		ДопПараметры = Новый Структура;
	КонецЕсли;

	ДопПараметры.Вставить("АдресРесурса", "/service/?srv=1");
	
	АргументМетода = Новый Структура("data", ПараметрыМетода);
	Результат = СбисОтправитьИОбработатьКоманду(Кэш, "ZakupkiGovAPI.GetContractInfo", АргументМетода, ДопПараметры, Отказ);
	
	Если Отказ Тогда
		Результат = Кэш.ОбщиеФункции.СбисИсключение(Результат, "ZakupkiGovAPI.GetContractInfo");
	КонецЕсли;  
	
	Возврат Результат;
	
КонецФункции

&НаКлиенте
Функция SearchNomenclatureCollation(Кэш, params, ДопПараметры, Отказ=Ложь) Экспорт 
	                                                                                                  
	Возврат СбисОтправитьИОбработатьКоманду(Кэш, "ContractorNomenclatureCollation.SearchByContractorData", params, ДопПараметры, Отказ);

КонецФункции 



#Область include_core2_vo2_СпособыОбмена_NativeAPI_ВнешниеОбертки_ПрикладнаяСтатистика
#КонецОбласти

