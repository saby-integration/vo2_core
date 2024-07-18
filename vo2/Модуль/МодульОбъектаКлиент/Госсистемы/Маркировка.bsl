
// Функция - заполняет список доступных параметров выбытия кодов маркировки
// 
// Возвращаемое значение:
//  Массив - список параметров причин выбытия кодов маркировки
//  
&НаКлиенте 
Функция ПричиныВыводаИзОборота(ПараметрыДокумента = Неопределено, ДопПараметры = Неопределено) Экспорт
	
	Кэш = ГлавноеОкно.Кэш; 
	ТекущийРаздел = Кэш.Текущий.Раздел;
	
	Если ТекущийРаздел = "1" Тогда
		ПричиныВывода = ПричиныВыводаВходящихДокументов(ПараметрыДокумента, ДопПараметры);	
	Иначе
		ПричиныВывода = ПричиныВыводаИсходящихДокументов(ПараметрыДокумента, ДопПараметры);	
	КонецЕсли;
		
	Возврат ПричиныВывода;  
	
КонецФункции

&НаКлиенте
Функция ПричиныВыводаВходящихДокументов(ПараметрыДокумента, ДопПараметры)    
	
	ПричиныВывода = Новый Массив();
	ПричиныВывода.Добавить(Новый Структура("Причина,ПоУмолчанию,КодПричины","Без вывода из оборота",Истина,"0"));
	ПричиныВывода.Добавить(Новый Структура("Причина,ПоУмолчанию,КодПричины","Приобретение гос предприятием",Ложь,"1")); 
	ПричиныВывода.Добавить(Новый Структура("Причина,ПоУмолчанию,КодПричины","Использование для собственных нужд",Ложь,"2"));  
	ПричиныВывода.Добавить(Новый Структура("Причина,ПоУмолчанию,КодПричины","Безвозмездная передача",Ложь,"3"));   
	ПричиныВывода.Добавить(Новый Структура("Причина,ПоУмолчанию,КодПричины","Передача комиссионеру/агенту",Ложь,"9"));
	ПричиныВывода.Добавить(Новый Структура("Причина,ПоУмолчанию,КодПричины","Возврат комитенту/принципалу",Ложь,"10"));	
	
	Возврат ПричиныВывода;
	
КонецФункции

&НаКлиенте
Функция ПричиныВыводаИсходящихДокументов(ПараметрыДокумента, ДопПараметры)     
	
	Перем КодУчастника;
	
	ПричиныВывода = Новый Массив();
	
	Если НЕ ПараметрыДокумента = Неопределено
		И ПараметрыДокумента.Свойство("to_not_participant",КодУчастника) 
		И НЕ КодУчастника = Неопределено
		И НРЕГ(КодУчастника) = "true" Тогда	
		ПричиныВывода.Добавить(Новый Структура("Причина,ПоУмолчанию,КодПричины","Приобретение гос предприятием",Ложь,"1")); 
		ПричиныВывода.Добавить(Новый Структура("Причина,ПоУмолчанию,КодПричины","Использование для собственных нужд",Истина,"2"));  
		ПричиныВывода.Добавить(Новый Структура("Причина,ПоУмолчанию,КодПричины","Безвозмездная передача",Ложь,"3"));  
		ПричиныВывода.Добавить(Новый Структура("Причина,ПоУмолчанию,КодПричины","Дистанционный способ продажи",Ложь,"4")); 
		ПричиныВывода.Добавить(Новый Структура("Причина,ПоУмолчанию,КодПричины","Продажа по образцам",Ложь,"11")); 
		ПричиныВывода.Добавить(Новый Структура("Причина,ПоУмолчанию,КодПричины","Производственные нужды покупателя",Ложь,"12"));  
	Иначе
		ПричиныВывода.Добавить(Новый Структура("Причина,ПоУмолчанию,КодПричины","Без вывода из оборота",Истина,"0"));
		ПричиныВывода.Добавить(Новый Структура("Причина,ПоУмолчанию,КодПричины","Приобретение гос предприятием",Ложь,"1")); 
		ПричиныВывода.Добавить(Новый Структура("Причина,ПоУмолчанию,КодПричины","Использование для собственных нужд",Ложь,"2"));  
		ПричиныВывода.Добавить(Новый Структура("Причина,ПоУмолчанию,КодПричины","Безвозмездная передача",Ложь,"3"));
		ПричиныВывода.Добавить(Новый Структура("Причина,ПоУмолчанию,КодПричины","Дистанционный способ продажи",Ложь,"4"));
		ПричиныВывода.Добавить(Новый Структура("Причина,ПоУмолчанию,КодПричины","Передача комиссионеру/агенту",Ложь,"9"));
		ПричиныВывода.Добавить(Новый Структура("Причина,ПоУмолчанию,КодПричины","Возврат комитенту/принципалу",Ложь,"10")); 
		ПричиныВывода.Добавить(Новый Структура("Причина,ПоУмолчанию,КодПричины","Продажа по образцам",Ложь,"11")); 
		ПричиныВывода.Добавить(Новый Структура("Причина,ПоУмолчанию,КодПричины","Производственные нужды покупателя",Ложь,"12")); 
	КонецЕсли;
	
	Возврат ПричиныВывода; 
	
КонецФункции

// Функция - заполняет список доступных параметров участников оборота маркируемой продукции
// 
// Возвращаемое значение:
//  Массив - список параметров участников оборота маркируемой продукции
// 
&НаКлиенте
Функция ПараметрыУчастиковОборота() Экспорт
	ПараметрыУчастиков = Новый Массив(); 
	ПараметрыУчастиков.Добавить(Новый Структура("Причина,ПоУмолчанию,КодПричины","Покупатель зарегистрирован в ГИС МТ",Истина,"false"));
	ПараметрыУчастиков.Добавить(Новый Структура("Причина,ПоУмолчанию,КодПричины","Покупатель не зарегистрирован в ГИС МТ",Ложь,"true")); 
	Возврат ПараметрыУчастиков; 
КонецФункции  

// Функция - возвращает список для получения складских параметров документа СБИС Онлайн
// 
// Возвращаемое значение:
//  Массив - список складских параметров
//
&НаКлиенте
Функция СписокСкладскихПараметров()  
	СписокПараметров = Новый Массив;
	СписокПараметров.Добавить("marking_shipment_reason");    
	СписокПараметров.Добавить("to_not_participant");
	СписокПараметров.Добавить("markingContractNumber");
	Возврат СписокПараметров;
КонецФункции 

//Функция возвращает складские параметры документа СБИС Онлайн, для вкладки Маркировка формы просмотра документа
//
// Параметры:
//  СоставПакета
//
//	ЗапрашиваемыеПараметры   - Структура, с массивом запрашиваемых параметров метода
//               
//  ДопПараметры   - Структура, Неопределено - Доп параметры
//
// Возвращаемое значение:
//   Структура
//
&НаКлиенте
Функция ПолучитьСкладскиеПараметрыДокумента(СоставПакета, ДопПараметры = Неопределено) Экспорт  
		
	ПараметрыДокументаСбис = ПрочитатьСкладскиеПараметрыДокумента(СоставПакета, ДопПараметры); 
	
	ИдентификаторГосконтракта =  ПолучитьИдентификаторГосконтракта(ПараметрыДокументаСбис);  
	УчастникиОборота =  ЗаполнитьУчастникОборота(ПараметрыДокументаСбис);  
	ПричиныВывода = ЗаполнитьСписокПричинВывода(ПараметрыДокументаСбис);
	
	СкладскиеПараметрыДокумента = Новый Структура;
		
	
	СкладскиеПараметрыДокумента.Вставить("ПричиныВыводаИзОборота",ПричиныВывода.СписокПричинВывода); 
	СкладскиеПараметрыДокумента.Вставить("ПараметрыУчастниковОборота",УчастникиОборота.СписокУчастников);
	СкладскиеПараметрыДокумента.Вставить("ОтправитьКодыМаркировки",УчастникиОборота.ОтправитьКодыМаркировки);
	СкладскиеПараметрыДокумента.Вставить("ИдентификаторГосконтракта",ИдентификаторГосконтракта);  
	СкладскиеПараметрыДокумента.Вставить("ПричинаВывода",ПричиныВывода.ПричинаВыводаПоУмолчанию); 
	СкладскиеПараметрыДокумента.Вставить("КодПричиныВывода",ПричиныВывода.КодПричиныВывода);
	СкладскиеПараметрыДокумента.Вставить("УчастникОборота",УчастникиОборота.УчастникОборотаПоУмолчанию); 
	СкладскиеПараметрыДокумента.Вставить("ПоказатьГосконтракт",ПричиныВывода.ПоказатьГосконтракт); 
	
	Возврат СкладскиеПараметрыДокумента;

КонецФункции  

// Функция возвращает результат работы метода ExtSysMarking.GetParams
//
// Параметры:
//  СоставПакета  - Структура - обрабатываемый пакет (документ)
//  ДопПараметры  - Структура - Набор полей, работа с которыми может расширить результат работы функции.
//
// Возвращаемое значение:
//   Структура   - Результат вызова. Код результата или ошибка
//
&НаКлиенте
Функция ПрочитатьСкладскиеПараметрыДокумента(СоставПакета, ДопПараметры = Неопределено) 
	
	Кэш = ГлавноеОкно.Кэш;  
	
	ЗапрашиваемыеПараметры = СписокСкладскихПараметров();

	ПараметрыВызова = Новый Структура;  
	ПараметрыВызова.Вставить("ИдДок",СоставПакета.Идентификатор);
	ПараметрыВызова.Вставить("paramsList",ЗапрашиваемыеПараметры);
	 
	ФлагОшибки = Ложь;
	РезультатВызова = ГлобальныйКэш.ТекущийСеанс.Модули.Интеграция.ExtSysMarking_GetParams(ПараметрыВызова, Новый Структура("Кэш", Кэш), ФлагОшибки);
	Если ФлагОшибки Тогда
		ВызватьСбисИсключение(РезультатВызова, "МодульОбъектаКлиент.ПрочитатьСкладскиеПараметрыДокумента");
	КонецЕсли;   
	
	Возврат РезультатВызова;
	
КонецФункции

// Функция, из полученных параметров документа СБИС, возвращает номер госконтракта
//
// Параметры:
//  СкладскиеПараметрыДокумента	 - Структура - Складские параметры документа СБИС
//
&НаКлиенте
 Функция ПолучитьИдентификаторГосконтракта(ПараметрыДокумента) 
	 
	Перем НомерГосконтракта; 
	 
	Если ПараметрыДокумента.Свойство("markingContractNumber",НомерГосконтракта) 
		И НЕ НомерГосконтракта = Неопределено Тогда 
		ИдентификаторГосконтракта = НомерГосконтракта;   
	Иначе
		ИдентификаторГосконтракта = "";
	КонецЕсли;
	
	Возврат ИдентификаторГосконтракта;
		
КонецФункции

// Функция возвращает список параметров участников оборота маркируемой продукции, для вкладки Маркировка, формы просмотра документа
//
// Параметры:
//  СкладскиеПараметрыДокумента	 - Массив - данные документа, полученные при вычитывании складских параметров документа СБИС Онлайн 
// 
&НаКлиенте
Функция ЗаполнитьУчастникОборота(ПараметрыДокумента) 
	
	Перем КодУчастника; 
	
	УчастникиОборота = Новый Структура;
	СписокУчастников = Новый Массив;
	
	МассивПараметровУчастиковОборота = ПараметрыУчастиковОборота();
	
	ОбновлятьПричину = Истина;
	Для Каждого ЭлМасс ИЗ МассивПараметровУчастиковОборота Цикл
		СписокУчастников.Добавить(ЭлМасс.Причина);  
		Если ПараметрыДокумента.Свойство("to_not_participant",КодУчастника) 
			И НЕ КодУчастника = Неопределено
			И ЭлМасс.КодПричины = НРЕГ(КодУчастника) Тогда
			УчастникОборота = ЭлМасс.Причина; 
			ОбновлятьПричину = Ложь;
		ИначеЕсли ЭлМасс.ПоУмолчанию И ОбновлятьПричину Тогда
			УчастникОборота = ЭлМасс.Причина;  
		Иначе
			//
		КонецЕсли; 
	КонецЦикла;	 
	
	Если НРЕГ(КодУчастника) = "true" Тогда
		ОтправитьКодыМаркировки = Истина; 
	Иначе
		ОтправитьКодыМаркировки = Ложь;
	КонецЕсли; 
	
	УчастникиОборота.Вставить("СписокУчастников",СписокУчастников);
	УчастникиОборота.Вставить("УчастникОборотаПоУмолчанию",УчастникОборота); 
	УчастникиОборота.Вставить("ОтправитьКодыМаркировки",ОтправитьКодыМаркировки);
	
	Возврат УчастникиОборота;	
		
КонецФункции 

// Функция возвращает список причин выдода из оборота, для вкладки Маркировка, формы просмотра документа
//
// Параметры:
//  СкладскиеПараметрыДокумента	 - Массив - данные документа, полученные при вычитывании складских параметров документа СБИС Онлайн 
// 
&НаКлиенте
Функция ЗаполнитьСписокПричинВывода(ПараметрыДокумента,ДопПараметры = Неопределено) 
	
	Перем КодПричиныВывода; 
	
	Кэш = ГлавноеОкно.Кэш;
	
	ПричиныВывода = Новый Структура;
	СписокПричинВывода = Новый Массив; 
	
	Если НЕ ПараметрыДокумента = Неопределено
		И ПараметрыДокумента.Свойство("marking_shipment_reason",КодПричиныВывода) 
		И КодПричиныВывода = "1" Тогда
		ПоказатьГосконтракт = Истина;
	Иначе
		ПоказатьГосконтракт = Ложь;
	КонецЕсли;

	МассивПричинВыводаИзОборота = ПричиныВыводаИзОборота(ПараметрыДокумента);
	
	Индекс = Кэш.ОбщиеФункции.ВыбратьДанныеСертификата(МассивПричинВыводаИзОборота,КодПричиныВывода,"КодПричины");  
	
	Если Индекс = Неопределено Тогда
		Индекс = Кэш.ОбщиеФункции.ВыбратьДанныеСертификата(МассивПричинВыводаИзОборота,Истина,"ПоУмолчанию"); 
		//Тут подумать над установкой причины, т.к. она не совпадает с типом участника оборота, завязавшись на КодПричиныВывода, раз она там есть
	КонецЕсли;
	
	ПричинаВывода = МассивПричинВыводаИзОборота[Индекс].Причина;
	КодВывода = МассивПричинВыводаИзОборота[Индекс].КодПричины;

	Для Каждого ЭлМасс ИЗ МассивПричинВыводаИзОборота Цикл    
		СписокПричинВывода.Добавить(ЭлМасс.Причина);  
	КонецЦикла;	 
					
   	ПричиныВывода.Вставить("СписокПричинВывода",СписокПричинВывода);
	ПричиныВывода.Вставить("ПричинаВыводаПоУмолчанию",ПричинаВывода);
	ПричиныВывода.Вставить("ПоказатьГосконтракт",ПоказатьГосконтракт);
	ПричиныВывода.Вставить("КодПричиныВывода",КодВывода);
	
	Возврат ПричиныВывода;
	
КонецФункции

// Получение состояния проверки из ДокументРасширение.Параметры.CrptState
//
// Параметры:
//  СоставПакета  - Структура
//               
//  ДопПараметры   - Структура, Неопределено - Доп параметры
//
// Возвращаемое значение:
//   Строка
//
&НаКлиенте
Функция ЗапроситьСостояниеПроверки(СоставПакета, ДопПараметры = Неопределено) Экспорт 

	Кэш = ГлавноеОкно.Кэш;   

	ПараметрыВызова = Новый Структура;  
	ПараметрыВызова.Вставить("ИдДок",СоставПакета.Идентификатор);
	
	Возврат Кэш.Интеграция.ExtSysMarking_CheckState(ПараметрыВызова, Новый Структура("Кэш", Кэш));

КонецФункции     

// Функция возвращает список номенклатуры документа СБИС
//
// Параметры:
//  СоставПакета  - Структура
//               
//  ДопПараметры   - Структура, Неопределено - Доп параметры
//
// Возвращаемое значение:
//   Структура
//
&НаКлиенте
Функция СоставМаркируемыхПозиций(СоставПакета, ДопПараметры = Неопределено) Экспорт 

	Кэш = ГлавноеОкно.Кэш;   
	
	ПараметрыФильтра = Новый Структура; 
	ПараметрыФильтра.Вставить("docflowId",СоставПакета.Идентификатор);

    ПараметрыВызова = Новый Структура; 	
	ПараметрыВызова.Вставить("Фильтр",ПараметрыФильтра);
	
	Возврат Кэш.Интеграция.ExtSysMarking_NumList(ПараметрыВызова, Новый Структура("Кэш", Кэш));

КонецФункции     

// Получение параметров из SerialNumber.CustomList
//
// Параметры:
//  СоставПакета  - Структура
//               
//  ДопПараметры   - Структура, Неопределено - Доп параметры
//
// Возвращаемое значение:
//   Структура
//
&НаКлиенте
Функция ВернутьПараметрыНоменклатуры(СоставПакета, ДопПараметры = Неопределено) Экспорт 

	Кэш = ГлавноеОкно.Кэш;   

	ПараметрыВызова = Новый Структура;  
	ПараметрыВызова.Вставить("ИдДок",СоставПакета.Идентификатор); 
	ПараметрыВызова.Вставить("КодНоменклатуры",ДопПараметры.НоменклатураСбис); 
	
	Отказ = Ложь;
	РезультатВызова = ГлобальныйКэш.ТекущийСеанс.Модули.Интеграция.ExtSysMarking_NomCheckStateByNomDoc(ПараметрыВызова, Новый Структура("Кэш", Кэш), Отказ);
	Если Отказ Тогда
		ВызватьСбисИсключение(РезультатВызова, "МодульОбъектаКлиент.ВернутьПараметрыНоменклатуры");
	КонецЕсли;
	
	Возврат РезультатВызова;

КонецФункции        

//Установка складских параметров документа ExtSysMarking.SetParam
//
// Параметры:
//  СоставПакета  - Структура
//  УстанавливаемыеПараметры   - Структура
//		КодПричины
//		КодУчастикаОборота
//
// Возвращаемое значение:
//   Структура
//
&НаКлиенте
Функция ИзменитьСкладскойПараметрДокумента(СоставПакета, УстанавливаемыеПараметры) Экспорт 
	Перем ЛНовоеЗначениеУстановить; 
	
	ПараметрыВызова = Новый Структура("ИдДок, name, value",СоставПакета.Идентификатор);  
	Если		УстанавливаемыеПараметры.Свойство("КодПричины",			ЛНовоеЗначениеУстановить) Тогда
		ПараметрыВызова.Вставить("name",	"marking_shipment_reason");
		ПараметрыВызова.Вставить("value",	ЛНовоеЗначениеУстановить);
	ИначеЕсли   УстанавливаемыеПараметры.Свойство("КодУчастикаОборота", ЛНовоеЗначениеУстановить) Тогда
		ПараметрыВызова.Вставить("name",	"to_not_participant");
		ПараметрыВызова.Вставить("value",	ЛНовоеЗначениеУстановить);
	ИначеЕсли   УстанавливаемыеПараметры.Свойство("ИдентификаторГосконтракта", ЛНовоеЗначениеУстановить) Тогда
		ПараметрыВызова.Вставить("name",	"markingContractNumber");
		ПараметрыВызова.Вставить("value",	ЛНовоеЗначениеУстановить);
	Иначе
		ВызватьСбисИсключение(700, "МодульОбъектаКлиент.ИзменитьСкладскойПараметрДокумента",,,"Неизвестный параметр складского документа", УстанавливаемыеПараметры);
	КонецЕсли;	
	
	ФлагОшибки = Ложь;
	РезультатВызова = ГлобальныйКэш.ТекущийСеанс.Модули.Интеграция.ExtSysMarking_SetParam(ПараметрыВызова, Новый Структура("Кэш", ГлавноеОкно.Кэш), ФлагОшибки);
	Если ФлагОшибки Тогда
		ВызватьСбисИсключение(РезультатВызова, "МодульОбъектаКлиент.ИзменитьСкладскойПараметрДокумента");
	КонецЕсли;

КонецФункции   

// Получение состояния и наличия токена в ГИС МТ
//
// Параметры:
//  СоставПакета  - Структура
//               
//  ДопПараметры   - Структура, Неопределено - Доп параметры
//
// Возвращаемое значение:
//   Строка
//
&НаКлиенте
Функция ПроверитьНаличиеТокена(СоставПакета, ДопПараметры = Неопределено) Экспорт 

	Кэш = ГлавноеОкно.Кэш;   

	ПараметрыВызова = Новый Структура;  
	ПараметрыВызова.Вставить("ИдДок",СоставПакета.Идентификатор);
	
	Возврат Кэш.Интеграция.ExtSysMarking_CheckGisSetting(ПараметрыВызова, Новый Структура("Кэш", Кэш));

КонецФункции 

// Запуск проверки кодов маркировки в ГИС МТ
//
// Параметры:
//  СоставПакета  - Структура
//               
//  ДопПараметры   - Структура, Неопределено - Доп параметры
//
// Возвращаемое значение:
//   Строка
//
&НаКлиенте
Функция ИнициироватьПроверкуКодовМаркировки(СоставПакета, ДопПараметры = Неопределено) Экспорт 

	Кэш = ГлавноеОкно.Кэш;   

	ПараметрыВызова = Новый Структура;  
	ПараметрыВызова.Вставить("ИдДок",СоставПакета.Идентификатор);
	
	Возврат Кэш.Интеграция.ExtSysMarking_CheckSnCRPT(ПараметрыВызова, Новый Структура("Кэш", Кэш));

КонецФункции   

// Получение информации по отпечатку сертификата
//
// Параметры:
//  СоставПакета  - Структура
//               
//  ДопПараметры   - Структура, Неопределено - Доп параметры
//
// Возвращаемое значение:
//   Массив
//
&НаКлиенте
Функция ПолучитьДанныеСертификатаСбис(Отпечаток, ДопПараметры = Неопределено) Экспорт 

	Кэш = ГлавноеОкно.Кэш;   

	ПараметрыВызова = Новый Структура;  
	ПараметрыВызова.Вставить("Отпечаток",Отпечаток);
	
	Возврат Кэш.Интеграция.Сертификат_ПрочитатьПоОтпечатку(ПараметрыВызова, Новый Структура("Кэш", Кэш));

КонецФункции     

// Получение информации по созданию токена ГИС МТ
//
// Параметры:
//  СоставПакета  - Структура
//               
//  ДопПараметры   - Структура, Неопределено - Доп параметры
//
// Возвращаемое значение:
//   Массив
//
&НаКлиенте
Функция ПолучитьРезультатСозданияТокена(СоставПакета, ДопПараметры = Неопределено) Экспорт 

	Кэш = ГлавноеОкно.Кэш;   

	ПараметрыВызова = Новый Структура;  
	ПараметрыВызова.Вставить("ИдДок",СоставПакета.Идентификатор);
	
	Возврат Кэш.Интеграция.ExtSysMarking_CheckGisTask(ПараметрыВызова, Новый Структура("Кэш", Кэш));

КонецФункции      

// Получение статуса проверки документа ГИС МТ
//
// Параметры:
//  СоставПакета  - Структура
//               
//  ДопПараметры   - Структура, Неопределено - Доп параметры
//
// Возвращаемое значение:
//   Массив
//
&НаКлиенте
Функция ПроверитьСтатусПроверкиГИСМТ(СоставПакета, ДопПараметры = Неопределено) Экспорт 

	Кэш = ГлавноеОкно.Кэш;   

	ПараметрыВызова = Новый Структура;  
	ПараметрыВызова.Вставить("ИдДок",СоставПакета.Идентификатор);
	
	Возврат Кэш.Интеграция.ExtSysMarking_GetResendingConfigForGIS(ПараметрыВызова, Новый Структура("Кэш", Кэш));

КонецФункции    

// Отправка кодов маркировки в ГИС МТ
//
// Параметры:
//  СоставПакета  - Структура
//               
//  ДопПараметры   - Структура, Неопределено - Доп параметры
//
// Возвращаемое значение:
//   Массив
//
&НаКлиенте
Функция ОтправитьКодыМаркировкиВГИС(СоставПакета, ДопПараметры = Неопределено) Экспорт 

	Кэш = ГлавноеОкно.Кэш;   

	ПараметрыВызова = Новый Структура;  
	ПараметрыВызова.Вставить("ИдДок",СоставПакета.Идентификатор); 
	
	ФлагОшибки = Ложь;
    РезультатВызова = Кэш.Интеграция.ExtSysMarking_SendToGIS(ПараметрыВызова, Новый Структура("Кэш", Кэш),ФлагОшибки);
    Если ФлагОшибки Тогда
        ВызватьСбисИсключение(РезультатВызова, "МодульОбъектаКлиент.ОтправитьКодыМаркировкиВГИС");
    КонецЕсли;
    
    Возврат РезультатВызова;


КонецФункции

// Функция вызывает создание токена в СБИС, для взаимодействия с ГИС МТ
//
// Параметры:
//  СоставПакета  - Структура
//  ПараметрыСоздания - Структура, данные сертификата, для создания токена             
//  ДопПараметры   - Структура, Неопределено - Доп параметры
//
// Возвращаемое значение:
//   Строка - Результат вызова. Дата/время вызова или ошибка
//
&НаКлиенте
Функция СоздатьТокенСбис(СоставПакета, ПараметрыСоздания, ДопПараметры = Неопределено) Экспорт 

	Кэш = ГлавноеОкно.Кэш;   

	ПараметрыВызова = Новый Структура;  
	ПараметрыВызова.Вставить("docflowId",СоставПакета.Идентификатор); 
	ПараметрыВызова.Вставить("thumbprint",ПараметрыСоздания.thumbprint);
	ПараметрыВызова.Вставить("hashOID",ПараметрыСоздания.hashOID); 
	ПараметрыВызова.Вставить("pin",ПараметрыСоздания.pin);
	ПараметрыВызова.Вставить("validFrom",ПараметрыСоздания.validFrom);
	ПараметрыВызова.Вставить("validTo",ПараметрыСоздания.validTo);
	ПараметрыВызова.Вставить("certData",ПараметрыСоздания.certData); 
	
	ФлагОшибки = Ложь;
	РезультатВызова = ГлобальныйКэш.ТекущийСеанс.Модули.Интеграция.ExtSysMarking_CreateGisSetting(ПараметрыВызова, Новый Структура("Кэш", Кэш), ФлагОшибки);
	Если ФлагОшибки Тогда
		ВызватьСбисИсключение(РезультатВызова, "МодульОбъектаКлиент.СоздатьТокенСбис");
	КонецЕсли;

КонецФункции  

// Функция - возвращает представление ставки НДС по её значению
//
// Параметры:
//  Значение - Число - значение атрибута структуры номенклатуры документа СБИС Онлайн 
// 
// Возвращаемое значение:
//  Строка - представление ставки НДС по её значению
//
&НаКлиенте
Функция СтавкаНДСПоПараметруМаркировки(Значение) Экспорт
		
	Если Значение = 0 Тогда
		СтавкаНДС = "0%"; 
	ИначеЕсли Значение = 1 Тогда
		СтавкаНДС = "10%"; 
	ИначеЕсли Значение = 2 Тогда
		СтавкаНДС = "18%";
    ИначеЕсли Значение = 3 Тогда
		СтавкаНДС = "20%";
    ИначеЕсли Значение = 4 Тогда
		СтавкаНДС = "10/110";
    ИначеЕсли Значение = 5 Тогда
		СтавкаНДС = "18/118";
    ИначеЕсли Значение = 6 Тогда
		СтавкаНДС = "без НДС";
    ИначеЕсли Значение = 7 Тогда
		СтавкаНДС = "ЕНВД";
    ИначеЕсли Значение = 8 Тогда
		СтавкаНДС = "Патент";
    ИначеЕсли Значение = 9 Тогда
		СтавкаНДС = "20/120";
	Иначе
		СтавкаНДС = "";
	КонецЕсли;

	Возврат СтавкаНДС;

КонецФункции   

