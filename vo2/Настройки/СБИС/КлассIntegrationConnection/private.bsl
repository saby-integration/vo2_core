
	
//Функция Сохраняет класс IC, возвращает измененный вариант.
&НаКлиенте
Функция		_КлассIntegrationConnection_Записать(Кэш, КлассIntegrationConnection, ДопПараметры, Отказ)
	Перем ОбновитьИниНаСервере, ТихийРежим;//Можно передать отдельно флаг тихого режима, чтобы статус не скакал при записи промежуточных данных, вроде меню и параметров
	
	СбисДополнительныеПараметры = Кэш.ОбщиеФункции.СкопироватьОбъектСПараметрамиКлиент(ДопПараметры,,Ложь);
	//Доп.Параметры по-умолчанию
	Если Не СбисДополнительныеПараметры.Свойство("СообщатьПриОшибке") Тогда
		СбисДополнительныеПараметры.Вставить("СообщатьПриОшибке", Ложь);
	КонецЕсли;
	Если Не СбисДополнительныеПараметры.Свойство("ВернутьОшибку") Тогда
		СбисДополнительныеПараметры.Вставить("ВернутьОшибку", Истина);
	КонецЕсли;
	Если Не СбисДополнительныеПараметры.Свойство("ЕстьОтвет") Тогда
		СбисДополнительныеПараметры.Вставить("ЕстьОтвет", Истина);
	КонецЕсли;
	Если Не СбисДополнительныеПараметры.Свойство("ТихийРежим", ТихийРежим) Тогда
		ТихийРежим = Ложь;
	КонецЕсли;	
	ЗаписьНовогоСоединения	= Ложь;
	ЗаписьСбисПараметров	= Истина;
	ПараметрыОтправки = Новый Структура;
	Если	Не КлассIntegrationConnection.ПараметрыРаботы.Статус = "Удален"
		И	Не КлассIntegrationConnection.ПараметрыРаботы.Статус = "Новый" Тогда
		ПараметрыОтправки.Вставить("id",		КлассIntegrationConnection.Идентификатор);
	Иначе
		ЗаписьНовогоСоединения = Истина;
		ПараметрыОтправки.Вставить("url",		Кэш.ПараметрыСистемы.Конфигурация.URL);
		ПараметрыОтправки.Вставить("service",	Кэш.КэшНастроек.ПараметрыКонфигурации.service);//service для записи берем из параметров конфигурации системы, т.к. может отличаться для работы с конфигом и коннекшеном
		ПараметрыОтправки.Вставить("subsystem",	КлассIntegrationConnection.ПараметрыКонфигурации.subsystem);
		ПараметрыОтправки.Вставить("version",	Формат(Кэш.ОбщиеФункции.СериализоватьВерсию(КлассIntegrationConnection.ПараметрыКонфигурации.version,"СтрокуВЧисло"), "ЧРГ=; ЧН=0; ЧГ=0"));
		КлассIntegrationConnection.Данные.Параметры.Вставить("Service4Config",	Кэш.КэшНастроек.ПараметрыНастроек.ПрефиксСервис);
		КлассIntegrationConnection.Данные.Параметры.Вставить("nameSubsystem",	Кэш.ФормаНастроекОбщее.ОпределитьТипНастроекПоПрефиксу(,КлассIntegrationConnection.ПараметрыКонфигурации.subsystem));
		Если Не КлассIntegrationConnection.Данные.Параметры.Свойство("comment") Тогда
			КлассIntegrationConnection.Данные.Параметры.Вставить("comment", "Создано обработкой");
		КонецЕсли;
		Если ЗначениеЗаполнено(КлассIntegrationConnection.Идентификатор) Тогда
			//Если требуется создать подключение с конкретным ИД
			ПараметрыОтправки.Вставить("id", КлассIntegrationConnection.Идентификатор);
		КонецЕсли;
	КонецЕсли;
	Если КлассIntegrationConnection.ПараметрыРаботы.ТипНастроек = "Шаблон" Тогда
		ПараметрыОтправки.Вставить("for_all", Истина);
	ИначеЕсли ЗначениеЗаполнено(КлассIntegrationConnection.ПараметрыРаботы.Шаблон) Тогда
		ПараметрыОтправки.Вставить("parent", КлассIntegrationConnection.ПараметрыРаботы.Шаблон);
	КонецЕсли;
	ЕстьИниКЗаписи	= Булево(КлассIntegrationConnection.ПараметрыРаботы.СбисИни.СписокОтправить.Количество());
	ФормированиеМеню=		КлассIntegrationConnection.ПараметрыРаботы.СбисМеню.Обновить
						И	КлассIntegrationConnection.ПараметрыРаботы.СбисМеню.Отправлять;
	ВыполнитьЗапись	=		ЕстьИниКЗаписи
						Или ЗаписьНовогоСоединения
						Или КлассIntegrationConnection.ПараметрыРаботы.Изменен;
	
	КлассIntegrationConnection.ПараметрыРаботы.Изменен = Ложь;
	//Если это не запись сбиспараметров, то проверим необходимость обновить сбисменю. Если надо, то выполним запись 	
	ini_array = Новый Массив;
	//Необязательные параметры. Если есть, то передаём
	//ПараметрыОтправки.Вставить("name_connection",	Кэш.РаботаСJSON.ПреобразоватьЗначениеВJSON(КлассIntegrationConnection.Название));
	ПараметрыОтправки.Вставить("name_connection",	КлассIntegrationConnection.Название);
	ПараметрыОтправки.Вставить("auto_update",		КлассIntegrationConnection.ПараметрыРаботы.Автообновление);
	Если	ЗначениеЗаполнено(КлассIntegrationConnection.ПараметрыРаботы.ДатаИзмененияНастроек) Тогда
		ПараметрыОтправки.Вставить("update_date",	Формат(КлассIntegrationConnection.ПараметрыРаботы.ДатаИзмененияНастроек,"ДФ=""гггг-ММ-дд ЧЧ:мм:сс"""));
	КонецЕсли;
	//Если надо апдейтнуть меню по данным, то делаем только если сразу отправим на БЛ
	Если ФормированиеМеню Тогда
		РезультатГенерацииМеню = КлассIntegrationConnection_СформироватьСбисМеню(Кэш, КлассIntegrationConnection, ДопПараметры, Отказ);
		Если Отказ Тогда
			Возврат Кэш.ОбщиеФункции.СбисИсключение(РезультатГенерацииМеню, "ФайлыНастроекСервер.КлассIntegrationConnection.Записать");
		КонецЕсли;
	КонецЕсли;
	//Конвертнём и добавим в параметры ини к обновлению на сервисе
	Если ЕстьИниКЗаписи Тогда
		ДанныеСпискаИни = КлассIntegrationConnection_СписокИни(Кэш, КлассIntegrationConnection,  Новый Структура("Включено", "01"), Отказ);
		КонвертированныеИни	= Новый Структура;
		Для Каждого ИмяИниВО Из  КлассIntegrationConnection.ПараметрыРаботы.СбисИни.СписокОтправить Цикл
			Если Не КлассIntegrationConnection.Данные.Ини.Свойство(ИмяИниВО) Тогда
				Отказ = Истина;
				Возврат Кэш.ОбщиеФункции.СбисИсключение(,"ФайлыНастроекСервер.ЗаписатьConnection", 785, "Ошибка во входящих данных", "Отсутствует файл настроек " + ИмяИниВО + " в данных к отправке!");
			КонецЕсли;
			КонвертированныеИни.Вставить(ИмяИниВО, КлассIntegrationConnection.Данные.Ини[ИмяИниВО]);
		КонецЦикла;
		КонвертированныеИни = ПреобразованиеВОИни_JSONИни_ВыполнитьПреобразование(КонвертированныеИни);
		
		Для Каждого ИмяИниВО Из КлассIntegrationConnection.ПараметрыРаботы.СбисИни.СписокОтправить Цикл
			ЗаписьИни			= СбисОписаниеИни(Кэш);
			ЗначениеИни			= КонвертированныеИни[ИмяИниВО];
			СписокКлючейОчистить= Новый Массив;
			Для Каждого КлючИЗначениеЗначениеИни Из ЗначениеИни Цикл
				Если Лев(КлючИЗначениеЗначениеИни.Ключ, 4) = "Сбис" Тогда
					СписокКлючейОчистить.Добавить(КлючИЗначениеЗначениеИни.Ключ);
				КонецЕсли;
			КонецЦикла;
			Для Каждого КлючОчистить Из СписокКлючейОчистить Цикл
				ЗначениеИни.Удалить(КлючОчистить);
			КонецЦикла;
			
			ИмяИниJson	= ПолучитьИмяИни(Кэш.КэшНастроек.ПараметрыНастроек.СоответствиеНазваний, ИмяИниВО, "во_json");
			ЭлементКарты= ДанныеСпискаИни.Карта.НайтиПоЗначению(НРег(ИмяИниJson));
			Если ЭлементКарты = Неопределено Тогда
				//Нет такой ини в карте. Неизвестно, что это. Пропускаем.
				Продолжить;
			КонецЕсли;
			ДанныеСписка= ДанныеСпискаИни.Данные[ДанныеСпискаИни.Карта.Индекс(ЭлементКарты)];
			ЗаполнитьЗначенияСвойств(ЗаписьИни, ДанныеСписка);
		
			ЗаписьИни.data = Кэш.РаботаСJSON.ПреобразоватьЗначениеВJSON(ЗначениеИни);
			ini_array.Добавить(ЗаписьИни);
		КонецЦикла;
	КонецЕсли;
	//Добавим меню в список отправляемых ини
	Если ФормированиеМеню Тогда
		ЗаписьИни = СбисОписаниеИниМеню(Кэш);
		ЗаписьИни.data = Кэш.РаботаСJSON.ПреобразоватьЗначениеВJSON(КлассIntegrationConnection.Данные.Меню);
		ini_array.Добавить(ЗаписьИни);
		ВыполнитьЗапись = Истина;
	КонецЕсли;
	//Добавим СбисПараметры в отправку		
	Если	КлассIntegrationConnection.ПараметрыРаботы.СбисПараметры.Обновить
		И	КлассIntegrationConnection.ПараметрыРаботы.СбисПараметры.Отправлять
		И	КлассIntegrationConnection.Данные.Параметры.Количество() Тогда
		ПараметрыОтправки.Вставить("json_connection", Кэш.РаботаСJSON.ПреобразоватьЗначениеВJSON(КлассIntegrationConnection.Данные.Параметры));
		ВыполнитьЗапись = Истина;
	ИначеЕсли КлассIntegrationConnection.ПараметрыРаботы.Статус = "Новый" Тогда
		ОбязательныеПараметрыДляПодсключения = Новый Структура("Service4Config, nameSubsystem, comment");
		ЗаполнитьЗначенияСвойств(ОбязательныеПараметрыДляПодсключения, КлассIntegrationConnection.Данные.Параметры);
		ПараметрыОтправки.Вставить("json_connection", Кэш.РаботаСJSON.ПреобразоватьЗначениеВJSON(ОбязательныеПараметрыДляПодсключения));
		ВыполнитьЗапись = Истина;
	КонецЕсли;
	
	Если ВыполнитьЗапись Тогда
		ПараметрыОтправки = Новый Структура("props, ini", ПараметрыОтправки, ini_array);
		Если Не ТихийРежим Тогда
			Кэш.ГлавноеОкно.СбисПоказатьСостояние("Запись настроек", Кэш.ГлавноеОкно);
		КонецЕсли;
		Результат = Кэш.Интеграция.ЗаписатьConnection(Кэш, ПараметрыОтправки, СбисДополнительныеПараметры, Отказ);
		Если Не ТихийРежим Тогда
			Кэш.ГлавноеОкно.СбисСпрятатьСостояние(Кэш.ГлавноеОкно);
		КонецЕсли;
	КонецЕсли;
	Если Не Отказ Тогда
		//Обновить подключение после записи
		КлассIntegrationConnection.Идентификатор = Результат;
		КлассIntegrationConnection.ПараметрыРаботы.Изменен = Ложь;
		Если Не КлассIntegrationConnection.ПараметрыРаботы.ТипНастроек = "Шаблон" Тогда
			КлассIntegrationConnection.ПараметрыРаботы.ТипНастроек = "Пользовательские";
		КонецЕсли;
		КлассIntegrationConnection.ПараметрыРаботы.Статус = "Активен";
		КлассIntegrationConnection.ПараметрыРаботы.СбисИни.СписокОтправить.Очистить();
		Если КлассIntegrationConnection.ПараметрыРаботы.СбисПараметры.Отправлять Тогда
			КлассIntegrationConnection.ПараметрыРаботы.СбисПараметры.Обновить = Ложь;
		КонецЕсли;
		Если КлассIntegrationConnection.ПараметрыРаботы.СбисМеню.Отправлять Тогда
			КлассIntegrationConnection.ПараметрыРаботы.СбисМеню.Обновить = Ложь;
		КонецЕсли;
		//Здесь нужно для того, чтобы если в каталоге отключили узлы, то и в рабочих ини узлов быть не должно. После переполучения, ини очистятся в конверторе.
		Если ЕстьИниКЗаписи Тогда
			ОчиститьОтключенныеУзлы(КлассIntegrationConnection.Данные.Ини);
		КонецЕсли;
	КонецЕсли;

	Возврат	Результат;
КонецФункции

&НаКлиенте
Функция		_КлассIntegrationConnection_ОсновныеПоля(Кэш)
	//Статус				- возможные значнения: "Новый"(по-умолч), "Активен"(актуален), "Удален"(был удалён в процессе работы с БЛ)
	//ТипНастроек			- возможные значнения: "Стандартные"(по-умолч), "Пользовательские", "Шаблон", "Неизвестно"("Пользовательские"/"Шаблон", при чтении)
	//Автообновление		- возможные значнения: True/False - признак автооподбора config под текущую версию
	//Изменен				- возможные значнения: True/False - признак того, менялся ли класс из интерфейса
	//Инициирован			- возможные значнения: True/False - признак того, инитился ли класс по его слепку с БЛ
	//ДатаИзмененияНастроек - Дата. Последнее изменение настроек
	//Шаблон				- УИД шаблона коннекшена, если есть.
	//Пользователь			- ИД пользователя, которому принадлежит коннекшен.
	//ВерсияКонфиг			- Номер версии конфига, из которого был создан коннешен. При отключенном автообновлении берётся версия отсюда.
	

	ПараметрыРаботыIntegrationConnection = Новый Структура	
	("Статус,	ТипНастроек,	Автообновление,	Изменен,ИнициированаШапка,	ИнициированыДанные,	ДатаИзмененияНастроек, Шаблон, Пользователь, ВерсияКонфиг, Демо"
	,"Новый",	"Стандартные",	Истина,			Ложь,	Ложь,				Ложь,				ТекущаяДата());
	//Определяет работу с настройкой:
	//Отправлять- если нет необходимости записывать на сервис, то флаг переключить в ложь. Тогда изменения будут кэшироваться в выбранном подключении
	//Обновить	- флаг изменения в параметрах. Если переключен в истину, то будет проведена отправка на сервис.
	ПараметрыРаботыIntegrationConnection.Вставить("СбисПараметры",	Новый Структура("Обновить, Отправлять", Ложь, Истина));
	ПараметрыРаботыIntegrationConnection.Вставить("СбисМеню",		Новый Структура("Обновить, Отправлять", Ложь, Истина));
	//Список ини, которые требуется отправить на БЛ при записи.
	ПараметрыРаботыIntegrationConnection.Вставить("СбисИни",			Новый Структура("СписокОтправить", Новый Массив));
	Результат = Новый Структура(
	"ПараметрыРаботы,						Данные,									Название,	ПараметрыКонфигурации,	Идентификатор"
	,ПараметрыРаботыIntegrationConnection,	Новый Структура("Ини, Прочие, Меню, Параметры"),"");	
	Возврат Результат;
КонецФункции

//Функция заполняет класс по данным БЛ
&НаКлиенте
Функция		_КлассIntegrationConnection_ЗаполнитьПоДанным(Кэш, КлассIntegrationConnection, ДопПараметры, Отказ)
	Перем ДанныеИниНаЧтение, СтрокаJson, СписокНаКонтроль, ТипИни;
	СбисДанныеБЛ	= ДопПараметры.ДанныеБЛ;
	//Если указано, какие ини читали, то проконтролировать, что всё получено в полном объеме.
	КонтролироватьЧтениеИни = ДопПараметры.Свойство("КонтрольИни", СписокНаКонтроль);
	
	Если Не КлассIntegrationConnection.ПараметрыРаботы.ИнициированаШапка Тогда
		КлассIntegrationConnection.ПараметрыРаботы.ИнициированаШапка = Истина;
		Если СбисДанныеБЛ.Свойство("ID", КлассIntegrationConnection.Идентификатор) Тогда
			КлассIntegrationConnection.Идентификатор = Строка(КлассIntegrationConnection.Идентификатор);
			КлассIntegrationConnection.ПараметрыРаботы.Статус		= "Активен";
			КлассIntegrationConnection.ПараметрыРаботы.ТипНастроек	= "Шаблон";
		Иначе
			КлассIntegrationConnection.Идентификатор = "";
		КонецЕсли;
		ПараметрыКонфигурации	= Новый Структура("service,subsystem,url", СбисДанныеБЛ.service, СбисДанныеБЛ.subsystem);											
		ВерсияКонфига			=  ?(СбисДанныеБЛ.Свойство("version_config"), СбисДанныеБЛ.version_config, СбисДанныеБЛ.version);
		ПараметрыКонфигурации.Вставить("version", ВерсияКонфига);
		КлассIntegrationConnection.ПараметрыКонфигурации = ПараметрыКонфигурации;
		КлассIntegrationConnection.ПараметрыКонфигурации.version = Кэш.ОбщиеФункции.СериализоватьВерсию(КлассIntegrationConnection.ПараметрыКонфигурации.version);
		Если	Не ДопПараметры.Свойство("Перечитать")
			Или	Не ДопПараметры.Перечитать Тогда
			КлассIntegrationConnectionСуществующий = Кэш.КэшНастроек.КэшIntegrationConnection.Получить(КлассIntegrationConnection_Идентификатор(Кэш, КлассIntegrationConnection));
			Если Не КлассIntegrationConnectionСуществующий = Неопределено Тогда
				КлассIntegrationConnection = КлассIntegrationConnectionСуществующий;
				Возврат _КлассIntegrationConnection_ЗаполнитьПоДанным(Кэш, КлассIntegrationConnection, ДопПараметры, Отказ)
			КонецЕсли;
		КонецЕсли;
		
		Если Не СбисДанныеБЛ.Свойство("auto_update", КлассIntegrationConnection.ПараметрыРаботы.Автообновление) Тогда
			КлассIntegrationConnection.ПараметрыРаботы.Автообновление = Истина;
		ИначеЕсли ТипЗнч(КлассIntegrationConnection.ПараметрыРаботы.Автообновление) = Тип("Строка") Тогда
			КлассIntegrationConnection.ПараметрыРаботы.Автообновление = Кэш.РаботаСJSON.СбисПрочитатьJSON(КлассIntegrationConnection.ПараметрыРаботы.Автообновление);
		КонецЕсли;
		Если СбисДанныеБЛ.Свойство("user", КлассIntegrationConnection.ПараметрыРаботы.Пользователь) Тогда
			КлассIntegrationConnection.ПараметрыРаботы.ТипНастроек	= "Пользовательские";
		Иначе
			КлассIntegrationConnection.ПараметрыРаботы.Пользователь	= "";
		КонецЕсли;
		КлассIntegrationConnection.ПараметрыРаботы.ВерсияКонфиг = Кэш.ОбщиеФункции.СериализоватьВерсию(ВерсияКонфига);
		Если Не СбисДанныеБЛ.Свойство("name_connection", КлассIntegrationConnection.Название) Тогда
			КлассIntegrationConnection.Название	= СбисДанныеБЛ.name_config;
		Иначе//Так, как для полей в JSON идёт двойное экранирование, снимаем его для названия
			Попытка
				КлассIntegrationConnection.Название	= Кэш.РаботаСJSON.СбисПрочитатьJSON("""" + КлассIntegrationConnection.Название + """");
			Исключение
				//Некорректное название. Оставляем как есть?
			КонецПопытки;
		КонецЕсли;
		СбисДанныеБЛ.Свойство("parent", КлассIntegrationConnection.ПараметрыРаботы.Шаблон);
		
		Если СбисДанныеБЛ.Свойство("update_date", КлассIntegrationConnection.ПараметрыРаботы.ДатаИзмененияНастроек) Тогда//Дата последней правки настроек
			КлассIntegrationConnection.ПараметрыРаботы.ДатаИзмененияНастроек =	Дата(Лев(СтрЗаменить(СтрЗаменить(СтрЗаменить(КлассIntegrationConnection.ПараметрыРаботы.ДатаИзмененияНастроек,
													"-",""),
													" ",""),
													":", ""),
													14));
		Иначе
			КлассIntegrationConnection.ПараметрыРаботы.ДатаИзмененияНастроек = ТекущаяДата();
		КонецЕсли;
		
		Если Не ПустаяСтрока(КлассIntegrationConnection.Идентификатор) Тогда
			КлассIntegrationConnection.ПараметрыРаботы.ТипНастроек = ?(ПустаяСтрока(КлассIntegrationConnection.ПараметрыРаботы.Пользователь), "Шаблон", "Пользовательские");
		КонецЕсли;
		
		Если Не СбисДанныеБЛ.Свойство("url", ПараметрыКонфигурации.url) Тогда
			ПараметрыКонфигурации.Удалить("url");
		КонецЕсли;
		КлассIntegrationConnection.Данные.Параметры = Новый Структура;
	КонецЕсли;
	//Разбор и обновление сбисПараметров, в кэше всегда актуальные, не пересекаются с установленными
	Если	СбисДанныеБЛ.Свойство("json_connection", СтрокаJson)
		И	ЗначениеЗаполнено(СтрокаJson) Тогда
		СбисСтрокаJson = Кэш.РаботаСJSON.СбисПрочитатьJSON(СтрокаJson);
		Если Не ТипЗнч(СбисСтрокаJson) = Тип("Структура") Тогда
			Отказ = Истина;
			Возврат Кэш.ОбщиеФункции.СбисИсключение(,"ФайлыНастроекСервер.КлассIntegrationConnection.ЗаполнитьПоДанным", 785, "Ошибка во входящих данных", "Неизвестная структура параметров json_connection", СбисСтрокаJson);
		КонецЕсли;
		Если КлассIntegrationConnection.Данные.Параметры = Неопределено Тогда
			КлассIntegrationConnection.Данные.Параметры = Новый Структура;
		КонецЕсли;
		СтруктураРазобранныхПараметров = Кэш.ФормаНастроекОбщее.ОбработатьСтруктуруПараметров(СбисСтрокаJson); 
		Для Каждого ЭлементПараметра Из СтруктураРазобранныхПараметров Цикл
			КлассIntegrationConnection.Данные.Параметры.Вставить(ЭлементПараметра.Ключ, ЭлементПараметра.Значение);
		КонецЦикла;
	КонецЕсли;
	
	//Обработаем данные ини, если имеются
	Если	СбисДанныеБЛ.Свойство("data", ДанныеИниНаЧтение)
		И	ЗначениеЗаполнено(ДанныеИниНаЧтение) Тогда//При пакетном чтении ини, в data будет массив строк.
		Если Не ТипЗнч(ДанныеИниНаЧтение) = Тип("Массив") Тогда
			Списокdata = Новый Массив;
			Списокdata.Добавить(ДанныеИниНаЧтение);
			ДанныеИниНаЧтение = Списокdata;
		Иначе
			Списокdata = ДанныеИниНаЧтение;
		КонецЕсли;
		ДанныеИниНаЧтение = Новый Структура;
		Для Каждого Строкаdata Из Списокdata Цикл
			Попытка
				Соединениеdata = Кэш.РаботаСJSON.СбисПрочитатьJSON(Строкаdata);
				Для	Каждого КлючИЗначение Из Соединениеdata Цикл
					ИмяИни = КлючИЗначение.Ключ;
					Если	КонтролироватьЧтениеИни Тогда
						КлючКонтроля	= НРег(ИмяИни);
						ЗначениеКонтроля= СписокНаКонтроль.Получить(КлючКонтроля);
						Если ЗначениеКонтроля = Неопределено Тогда
							Отказ = Истина;
							Возврат	Кэш.ОбщиеФункции.СбисИсключение(, "ФайлыНастроекСервер.КлассIntegrationConnection.ЗаполнитьПоДанным", 100, "Ошибка разбора файлов настроек.", КлассIntegrationConnection.Название + СтрЗаменить(": Неизвестная ини {0} в ответе.", "{0}", ИмяИни));
						КонецЕсли;
						СписокНаКонтроль.Удалить(КлючКонтроля);
					КонецЕсли;
					ЗначениеИни = Неопределено;
					Если Не КлючИЗначение.Значение.Свойство("data", ЗначениеИни) Тогда
						ЗначениеИни = КлючИЗначение.Значение;
					КонецЕсли;
					//В меню флаги не нужны
					Если ИмяИни = "сбисМеню" Тогда
						КлассIntegrationConnection.Данные.Меню = ЗначениеИни;
						Продолжить;
					КонецЕсли;
					ДанныеИниНаЧтение.Вставить(ИмяИни, ЗначениеИни);
					//Флаг типовой ини. Если свойства нет, подразумевается, что это и так типовая
					Если КлючИЗначение.Значение.Свойство("standart") Тогда
						ДанныеИниНаЧтение[ИмяИни].Вставить("СбисЕстьТиповая",(КлючИЗначение.Значение.standart = 1));
					Иначе
						ДанныеИниНаЧтение[ИмяИни].Вставить("СбисЕстьТиповая",Истина);
					КонецЕсли;
					Если Не ДанныеИниНаЧтение[ИмяИни].Свойство("ТипИни") И КонтролироватьЧтениеИни Тогда
						ДанныеИниНаЧтение[ИмяИни].Вставить("ТипИни", Новый Структура("Значение", ЗначениеКонтроля.type));
					КонецЕсли;
					//Флаг пользовательской ини. Если свойства нет, подразумевается, что пользовательской тоже нет.
					ДанныеИниНаЧтение[ИмяИни].Вставить("СбисЕстьИзменения",	(КлючИЗначение.Значение.Свойство("custom") И КлючИЗначение.Значение.custom = 1));
					//Флаг автообновления ини. Если включено и есть типовая.
					ДанныеИниНаЧтение[ИмяИни].Вставить("СбисАвтообновление", (КлассIntegrationConnection.ПараметрыРаботы.Автообновление И ДанныеИниНаЧтение[ИмяИни].СбисЕстьТиповая));
					//Флаг указывает на то, есть ли вообще стандартная настрока
					ДанныеИниНаЧтение[ИмяИни].Вставить("СбисСтандартная", ДанныеИниНаЧтение[ИмяИни].СбисЕстьТиповая);
					//Флаг присутсвия доработок, либо полностью пользовательская настройка
					ДанныеИниНаЧтение[ИмяИни].Вставить("СбисПользовательская", НЕ ДанныеИниНаЧтение[ИмяИни].СбисЕстьТиповая ИЛИ ДанныеИниНаЧтение[ИмяИни].СбисЕстьИзменения);
				КонецЦикла;
			Исключение
				Отказ = Истина;
				Возврат	Кэш.ОбщиеФункции.СбисИсключение(, "ФайлыНастроекСервер.КлассIntegrationConnection.ЗаполнитьПоДанным", 100, "Ошибка разбора файлов настроек.", КлассIntegrationConnection.Название + ": " + ОписаниеОшибки());
			КонецПопытки;
		КонецЦикла;
		Если ЗначениеЗаполнено(ДанныеИниНаЧтение) Тогда
			ПараметрыКонвертации = Новый Структура("ОчищатьОтключенные", Истина);
			ДанныеИни = _КлассIntegrationConnection_ПреобразованиеJSONИниВОИни_Клиент(ДанныеИниНаЧтение, ПараметрыКонвертации);
			Для Каждого КлючИЗначениеИни Из ДанныеИни Цикл
				ИмяИни	= ПолучитьИмяИни(Кэш.КэшНастроек.ПараметрыНастроек.СоответствиеНазваний, КлючИЗначениеИни.Ключ);
				Если		КлючИЗначениеИни.Значение.Свойство("ТипИни", ТипИни)
					И	Не	Кэш.КэшНастроек.ПараметрыНастроек.ДоступныеТипыИни.Найти(ТипИни.Значение) = Неопределено Тогда
					Если КлассIntegrationConnection.Данные.Ини = Неопределено Тогда
						КлассIntegrationConnection.Данные.Ини = Новый Структура;
					КонецЕсли;
					КлассIntegrationConnection.Данные.Ини.Вставить(ИмяИни, КлючИЗначениеИни.Значение);
				Иначе
					Если КлассIntegrationConnection.Данные.Прочие = Неопределено Тогда
						КлассIntegrationConnection.Данные.Прочие = Новый Структура;
					КонецЕсли;
					КлассIntegrationConnection.Данные.Прочие.Вставить(ИмяИни, КлючИЗначениеИни.Значение);
				КонецЕсли;
			КонецЦикла;
		КонецЕсли;
	КонецЕсли;
	Если	КонтролироватьЧтениеИни
		И	СписокНаКонтроль.Количество() Тогда
		СтрокаОшибки = "";
		Для Каждого  ЭлементНаКонтроль Из СписокНаКонтроль Цикл
			СтрокаОшибки = СтрокаОшибки + ЭлементНаКонтроль.Значение.name + ", ";
		КонецЦикла;
		СтрокаОшибки = Лев(СтрокаОшибки, СтрДлина(СтрокаОшибки) - 2);
		Отказ = Истина;
		Возврат	Кэш.ОбщиеФункции.СбисИсключение(, "ФайлыНастроекСервер.КлассIntegrationConnection.ЗаполнитьПоДанным", 100, "Ошибка разбора файлов настроек.", КлассIntegrationConnection.Название + СтрЗаменить(": не получены файлы настроек {0}.", "{0}", СтрокаОшибки));
	КонецЕсли;
	
	Возврат Истина;
КонецФункции

//Функция возвращает ини "от класса"
&НаКлиенте
Функция		_КлассIntegrationConnection_ВыполнитьЧтениеСБЛ(Кэш, КлассIntegrationConnection, ДопПараметры, Отказ)
	Перем СписокИниПолучить, ЗначениеИни, ДопПараметрыЧтения;
	Если Не	ДопПараметры.Свойство("ДополнительныеПараметры", ДопПараметрыЧтения) Тогда
		ДопПараметрыЧтения = Новый Структура("ЕстьРезультат", Истина);
	КонецЕсли;
	ДопПараметры.Свойство("СписокИни", СписокИниПолучить);
	Если СписокИниПолучить = "все" Тогда
		СписокИниПолучить = Новый Массив;
	КонецЕсли;
	
	ПараметрыСообщения = Новый Структура();
	МетодЧтения = "ReadConnection";
	Если	КлассIntegrationConnection.ПараметрыРаботы.ТипНастроек = "Стандартные"
		Или	КлассIntegrationConnection.ПараметрыРаботы.Статус = "Новый" Тогда
		МетодЧтения = "ReadConfig";
	КонецЕсли;
		
	Если МетодЧтения = "ReadConfig" Тогда
		Запрос_Фильтр = ПараметрыСтандартнойКонфигурации(Кэш, КлассIntegrationConnection.ПараметрыКонфигурации);
		Запрос_Фильтр.Вставить("version", Формат(Кэш.ОбщиеФункции.СериализоватьВерсию(Запрос_Фильтр.version, "СтрокуВЧисло"), "ЧРГ=; ЧН=0; ЧГ=0"));
		
		ПараметрыСообщения = Новый Структура("props, ini", Запрос_Фильтр, СписокИниПолучить);
		
		Если ПустаяСтрока(ПараметрыСообщения.props.subsystem) Тогда//Это пользовательская конфигурация. Генерируем ряд обязательных параметров, всё остальное берётся по-умолчанию.
			ДанныеБЛ = Новый Структура
			("name_config,						auto_update,service,							subsystem,							version"
			,"Пользовательская конфигурация",	Ложь,		ПараметрыСообщения.props.service,	ПараметрыСообщения.props.subsystem,	ПараметрыСообщения.props.version);
		Иначе
			ДанныеБЛ = ВыполнитьПолучениеИни(Кэш, МетодЧтения, ПараметрыСообщения, ДопПараметрыЧтения, Отказ);//Получаем типовые конфиги.
			Если ДанныеБЛ = Неопределено Тогда
				Отказ = Истина;
				ИмяЗапрашиваемойКонфигурации = Кэш.ФормаНастроекОбщее.ОпределитьТипНастроекПоПрефиксу(Запрос_Фильтр.service, Кэш.ФормаНастроекОбщее.СформироватьПрефиксСистемы(Запрос_Фильтр));
				Возврат Кэш.ОбщиеФункции.СбисИсключение(, "ФайлыНастроекСервер.КлассIntegrationConnection.ВыполнитьЧтениеИни", 765, "Значение не найдено в таблице настроек", СтрЗаменить("Настройки {0} не найдены!", "{0}", ИмяЗапрашиваемойКонфигурации));
			КонецЕсли;
		КонецЕсли;
	Иначе
		Запрос_Фильтр = Новый Структура;
		Запрос_Фильтр.Вставить("id",		Строка(КлассIntegrationConnection_Идентификатор(Кэш, КлассIntegrationConnection, "Чтение")));
		Запрос_Фильтр.Вставить("version",	Формат(Кэш.ОбщиеФункции.СериализоватьВерсию(КлассIntegrationConnection.ПараметрыКонфигурации.Version,"СтрокуВЧисло"),"ЧРГ=; ЧН=0; ЧГ=0"));
		Если	ДопПараметры.Свойство("ТолькоПользовательские")
			И	ДопПараметры.ТолькоПользовательские Тогда
			//Если получаем только пользовательские изменения
			Запрос_Фильтр.Вставить("read_config", Ложь);
		КонецЕсли;	
		ПараметрыСообщения = Новый Структура("props, ini", Запрос_Фильтр, СписокИниПолучить);		
		ДанныеБЛ = ВыполнитьПолучениеИни(Кэш, МетодЧтения, ПараметрыСообщения, ДопПараметрыЧтения, Отказ);
	КонецЕсли;
	Если Отказ Тогда 
		Возврат	Кэш.ОбщиеФункции.СбисИсключение(ДанныеБЛ, "ФайлыНастроекСервер.КлассIntegrationConnection.ВыполнитьЧтениеСБЛ");
	КонецЕсли;
	Возврат ДанныеБЛ;
КонецФункции

&НаКлиенте                                  
Функция		_КлассIntegrationConnection_ИнитКоннекшен(Кэш, ДопПараметры) Экспорт
	
	ПараметрыВызова1 = Новый Структура(
	"ExtSysType,Connector, ExtSysSubtype, ExtSysSubtypeTitle, ExtSysSubtypeVersion, ProductId, ProductVersion, ExtSysUid, ConnectionId",
	"1С",		"Dom1C");
	ПараметрыВызова1.ExtSysSubtype			= Кэш.ПараметрыСистемы.Конфигурация.Имя;
	ПараметрыВызова1.ExtSysSubtypeTitle		= Кэш.ПараметрыСистемы.Конфигурация.ПодробнаяИнформация;
	ПараметрыВызова1.ExtSysSubtypeVersion	= Кэш.КэшНастроек.ПараметрыКонфигурации.version;//Берём от параметров конфигурации, т.к. тут очищенная версия
	ПараметрыВызова1.ExtSysUid				= Кэш.ПараметрыСистемы.Конфигурация.УИДИнтеграции;
	ПараметрыВызова1.ProductVersion			= Кэш.ПараметрыСистемы.Обработка.Версия;
	ПараметрыВызова1.ProductId				= Кэш.ПараметрыСистемы.Обработка.ИмяПродукта;
	Если ДопПараметры.Свойство("Идентификатор") Тогда
		ПараметрыВызова1.ConnectionId		= ДопПараметры.Идентификатор;
	КонецЕсли;
	
	ПараметрыВызова2	= Новый Структура("Format, Type", Кэш.КэшНастроек.ПараметрыКонфигурации.service, "Меню");
	ПараметрыИнит		= Новый Структура("Params, ExtSysSettings", ПараметрыВызова1, ПараметрыВызова2);
	ДопПараметрыВызова	= Новый Структура("Кэш, Отказ", Кэш, Ложь);
	РезультатВызова		= Кэш.Интеграция.АПИ3_ИнитКоннекшен(ПараметрыИнит, ДопПараметрыВызова);
	Если ДопПараметрыВызова.Отказ Тогда
		МодульОбъектаКлиент().ВызватьСбисИсключение(РезультатВызова, "ФайлыНастроекОбщее.Вызов_ИнитКоннекшен");
	КонецЕсли;
	
	Возврат РезультатВызова;
КонецФункции

//Процедура выполняет конвертацию полученных ини после их получения
&НаКлиенте
Функция		_КлассIntegrationConnection_ПреобразованиеJSONИниВОИни_Клиент(ДанныеИни, ПараметрыКонвертации)
	//#Если ТолстыйКлиентОбычноеПриложение Тогда
		Возврат _КлассIntegrationConnection_ПреобразованиеJSONИниВОИни(ДанныеИни, ПараметрыКонвертации);
	//#Иначе
	//	Возврат _КлассIntegrationConnection_ПреобразованиеJSONИниВОИни_Сервер(ДанныеИни, ПараметрыКонвертации);
	//#КонецЕсли	
КонецФункции

//Процедура выполняет конвертацию полученных ини после их получения
&НаКлиенте
Функция		_КлассIntegrationConnection_ПреобразованиеJSONИниВОИни_Сервер(Знач ДанныеИни, Знач ПараметрыКонвертации)
	Возврат _КлассIntegrationConnection_ПреобразованиеJSONИниВОИни(ДанныеИни, ПараметрыКонвертации)
КонецФункции

//Процедура выполняет конвертацию полученных ини после их получения
&НаКлиенте
Функция		_КлассIntegrationConnection_ПреобразованиеJSONИниВОИни(ДанныеИни, ПараметрыКонвертации)
	Ини = Новый Структура();
	Для Каждого КлючИЗначение Из ДанныеИни Цикл
		Если КлючИЗначение.Ключ = "СбисМеню" Тогда
			ЗначениеИни = КлючИЗначение.Значение;
		Иначе
 			ЗначениеИни = _КлассIntegrationConnection_ПреобразованиеJSONИниВОИни_ВыполнитьПреобразование(КлючИЗначение.Значение, ПараметрыКонвертации);
			Ини.Вставить(КлючИЗначение.Ключ , ЗначениеИни);
		КонецЕсли;
	КонецЦикла;
	Возврат Ини;
КонецФункции

//Функция преобразует структуру файлов настроек к "привычному" для обработки виду.
&НаКлиенте
Функция		_КлассIntegrationConnection_ПреобразованиеJSONИниВОИни_ВыполнитьПреобразование(КэшИни, ДопПараметры) Экспорт
	
	СтруктураНастроек	= Новый	Структура;//
	КонтекстКонвертации	= Новый Структура;
	Если Не ДопПараметры.Свойство("Уровень") Тогда
		КонтекстКонвертации.Вставить("Уровень", 0);
	КонецЕсли;
		Для Каждого КлючЗначениеПараметра Из ДопПараметры	Цикл 
			КонтекстКонвертации.Вставить(КлючЗначениеПараметра.Ключ, КлючЗначениеПараметра.Значение);
		КонецЦикла;
	КонтекстКонвертации.Уровень = КонтекстКонвертации.Уровень + 1;
	Для Каждого Элемент Из КэшИни Цикл
		Если	Элемент.Ключ="СписокДокументов" Тогда
			Продолжить;
		КонецЕсли;
		Если	ТипЗнч(Элемент.Значение) = Тип("Структура") Тогда
			ЭлементЗначение = Неопределено;
			Если	Элемент.Значение.Свойство("Значение",ЭлементЗначение)
				И	ТипЗнч(ЭлементЗначение) = Тип("Структура") Тогда
				СтруктураВставки = Новый Структура;
				ЭлементИни = Элемент.Значение;
				Для Каждого ЭлементСтруктуры Из ЭлементЗначение Цикл
					СтруктураВставки.Вставить(ЭлементСтруктуры.Ключ, ЭлементСтруктуры.Значение);//	
				КонецЦикла;
				СтруктураНастроек.Вставить(Элемент.Ключ, _КлассIntegrationConnection_ПреобразованиеJSONИниВОИни_ВыполнитьПреобразование(СтруктураВставки,КонтекстКонвертации));//					
			Иначе
				СтруктураНастроек.Вставить(Элемент.Ключ, _КлассIntegrationConnection_ПреобразованиеJSONИниВОИни_ВыполнитьПреобразование(Элемент.Значение,КонтекстКонвертации));//
			КонецЕсли;
		ИначеЕсли ТипЗнч(Элемент.Значение) = Тип("Массив") Тогда
			ПодСтруктура = Новый Структура;
			Для Каждого ЭлементМассива Из Элемент.Значение Цикл
				СтруктураЭлемента = Новый Структура;
				Для Каждого Поле Из ЭлементМассива Цикл
					Если Поле.Ключ<>"Имя" Тогда
						СтруктураЭлемента.Вставить(Поле.Ключ, Поле.Значение);	
					КонецЕсли;
				КонецЦикла;
				КлючПодструктуры = ЭлементМассива.Имя;
				ПодСтруктура.Вставить(КлючПодструктуры,СтруктураЭлемента);	
			КонецЦикла;
			КонтекстКонвертации.Вставить("УровеньМассив", КонтекстКонвертации.Уровень);
			КлючВставить	= Элемент.Ключ;
			ЗначениеВставить= _КлассIntegrationConnection_ПреобразованиеJSONИниВОИни_ВыполнитьПреобразование(ПодСтруктура,КонтекстКонвертации);//
			Если	КлючВставить = "Значение"
				И	КэшИни.Количество() = 1
				И	ДопПараметры.Свойство("УровеньМассив")
				И	КонтекстКонвертации.Уровень - ДопПараметры.УровеньМассив = 2 Тогда
				//На 2 уровеня выше был массив, значит это может быть структура с удаленным дублирующимся именем . Пример: <Сотрудник Имя="Сотрудник"><Элемент/></Сотрудник> Превращается в {"Сотрудник": {"Элемент"}}
				СтруктураНастроек = ЗначениеВставить;//
			Иначе
				СтруктураНастроек.Вставить(Элемент.Ключ, ЗначениеВставить);//
			КонецЕсли;
			КонтекстКонвертации.Удалить("УровеньМассив");
		ИначеЕсли Лев(Элемент.Ключ,6)="Отбор_" Тогда
			ИмяОтбора = Сред(Элемент.Ключ, 7);
			Если	Элемент.Значение = ""
				И	КонтекстКонвертации.Свойство("ОчищатьОтключенные")
				И	КонтекстКонвертации.ОчищатьОтключенные Тогда
				Продолжить;//Отключенные узлы отбора не попадают в итоговую инишку.
			КонецЕсли;
			Если Не СтруктураНастроек.Свойство("Отбор") Тогда
				СтруктураНастроек.Вставить("Отбор", Новый Структура(ИмяОтбора,Элемент.Значение));//			
			Иначе
				СтруктураНастроек.Отбор.Вставить(ИмяОтбора,Элемент.Значение);
			КонецЕсли;
		Иначе
			ЗначениеКонтекста = Неопределено;
			Если КонтекстКонвертации.Свойство("Удалять",ЗначениеКонтекста)
				И ЗначениеКонтекста = Элемент.Ключ Тогда
				Продолжить;
			ИначеЕсли	КонтекстКонвертации.Свойство("ОбернутьЗначение", ЗначениеКонтекста)
				И	Не	ЗначениеКонтекста = Элемент.Ключ Тогда
				СтруктураНастроек.Вставить(Элемент.Ключ, Новый Структура(ЗначениеКонтекста, Элемент.Значение));
			Иначе
				СтруктураНастроек.Вставить(Элемент.Ключ, Элемент.Значение);
			КонецЕсли;
		КонецЕсли;
	КонецЦикла;
	
	Возврат СтруктураНастроек
	
КонецФункции

//Функция преобразует структуру файлов настроек к "привычному" для обработки виду.
&НаКлиенте
Функция		_КлассIntegrationConnection_СтрукутраСБИСПараметровПоУмолчанию()
	Возврат Новый Структура("ДатаПоследнегоЗапросаСтатусов, ИдентификаторПоследнегоСобытия, ДатНачЧтенияСтатусов, ДатКнцЧтенияСтатусов", "", "", "", "");
КонецФункции


