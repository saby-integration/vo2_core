
// Процедура - патчит дату, время, имя файла
//
// Параметры:
//  ФайлПропатчить		- Структура	- Вложение.СтруктураДокумента.Файл формируемого вложения
//  ВходящийКонтекст	- Структура
//		ФайлДанные		- Структура, грязный ини
//		ПолучательРоль	- Строка, роль получателя для поиска ИД
//		ОтправительРоль - Строка, роль отправителя для поиска ИД
//
&НаКлиенте
Процедура ПропатчитьФайлВложенияСБИС(ВложениеСБИС, ДопПараметры) Экспорт
	Перем ПолучательИд, ОтправительИд, ФайлИмяПропатчить, лДанныеСторон;
	
	ФайлПропатчить		= ВложениеСБИС.СтруктураДокумента.Файл;
	ДатаВремяСоздания	= ТекущаяДата();
	Если ДопПараметры.Свойство("ПутьКСторонам") Тогда
		лДанныеСторон = ПолучитьДанныеПоПути(Новый Структура("Данные, Путь", ФайлПропатчить, ДопПараметры.ПутьКСторонам));
	Иначе
		лДанныеСторон = ФайлПропатчить.Документ;
	КонецЕсли;
	Если ФайлПропатчить.Свойство("Имя", ФайлИмяПропатчить) Тогда
		Если	ДопПараметры.ГрязныйИни.Свойство("мСторона") 
			И	лДанныеСторон[ДопПараметры.ПолучательРоль].Свойство("Идентификатор",	ПолучательИД) 
			И	лДанныеСторон[ДопПараметры.ОтправительРоль].Свойство("Идентификатор",	ОтправительИД) Тогда
			ФайлИмяПропатчить = ФайлИмяПропатчить + ПолучательИД + "_" + ОтправительИД;
		Иначе
			ФайлИмяПропатчить = ФайлИмяПропатчить + "_";
		КонецЕсли;
		ФайлПропатчить.Имя = ФайлИмяПропатчить + "_" + Формат(ДатаВремяСоздания, "ДФ=ггггММдд") + "_" + Строка(Новый УникальныйИдентификатор());
	КонецЕсли;

	ФайлПерегенерируется = ИспользоватьГенераторДляВложения(ВложениеСБИС);
	//Патчим параметры для генератора или если есть XSLT, т.е. если документ ещё перегенерируется в процессе
	//В остальных случаях, документ грузится как есть и могут быть ошибки формата
	Если Не ФайлПерегенерируется Тогда
		ИмяXSLTВыгрузки		= ГлобальныйКэш.ТекущийСеанс.Модули.ФункцииДокументов.сбисИмяXSLTДляВложения(ГлавноеОкно.Кэш, ФайлПропатчить, ВложениеСБИС);
		ФайлПерегенерируется= ЗначениеЗаполнено(XSLTПоПараметрам(ИмяXSLTВыгрузки));
	КонецЕсли;
	Если ФайлПерегенерируется Тогда
		//Дополнить отсутствующие параметры
		Если Не ФайлПропатчить.Свойство("Дата") Тогда
			ФайлПропатчить.Вставить("Дата",	Формат(ДатаВремяСоздания, "ДФ=dd.MM.yyyy"));
			ФайлПропатчить.Вставить("Время",Формат(ДатаВремяСоздания, "ДФ=HH.mm.ss"));
		КонецЕсли;
		
		//Для ИнОрг поместисть данные стороны в спец. узел, откуда они будут прокинуты в требуемые поля документа.
		//Для отправки, функция разложит данные стороны обратно, чтобы ЗаписатьДокумент правильно поставил сторону.
		ПолучательИО = ПрочитатьДополнительныйПараметрСтороны(лДанныеСторон[ДопПараметры.ПолучательРоль], "ИностраннаяОрганизация") = Истина;
		Если ПолучательИО Тогда
			//СтруктураИНО = Новый Структура("Идентиф, Название", );
			лДанныеСтороны = лДанныеСторон[ДопПараметры.ПолучательРоль].СвЮЛ;
			лДанныеСтороны.Вставить("Идентиф", лДанныеСтороны.ИНН);
			лДанныеСтороны.Удалить("ИНН");
			лДанныеСторон[ДопПараметры.ПолучательРоль].Вставить("СвИН", лДанныеСтороны);
			лДанныеСторон[ДопПараметры.ПолучательРоль].Удалить("СвЮЛ");                                                          

		КонецЕсли; 
		
	Иначе
		
		ИмяФормыПоФормату = "Файл_"
			+ ГлобальныйКэш.ТекущийСеанс.Модули.ФункцииДокументов.сбисЗаменитьНедопустимыеСимволы(ДопПараметры.ГрязныйИни.Файл_Формат)
			+ "_"
			+ ГлобальныйКэш.ТекущийСеанс.Модули.ФункцииДокументов.сбисЗаменитьНедопустимыеСимволы(ДопПараметры.ГрязныйИни.Файл_ВерсияФормата);
		
		МодульФормата = НайтиФункциюСеансаОбработки("ПропатчитьСтруктуруВложения", ИмяФормыПоФормату);

		Если МодульФормата <> Ложь Тогда
			МодульФормата.ПропатчитьСтруктуруВложения(ВложениеСБИС, ДопПараметры);
		КонецЕсли;
		
	КонецЕсли;
	
КонецПроцедуры

//Функция возвращает ключ стороны для получения доп. параметров в кэше
&НаКлиенте
Функция	 КлючСтороныДляДопПараметров(мСторона)
	
	Перем СвФлЮл; 
	
	КлючИдентификатора = МодульОбъектаКлиент().Сторона_Получить(мСторона, "КлючИдентификатора");
	
	Если		мСторона.Свойство("СвЮЛ", СвФлЮл) Тогда
		Результат = СвФлЮл[КлючИдентификатора] + ?(СвФлЮл.Свойство("КПП"), "_" + СвФлЮл.КПП, "") + "_" + СвФлЮл.Название;
	ИначеЕсли   мСторона.Свойство("СвФЛ", СвФлЮл) Тогда 
		Результат = СвФлЮл[КлючИдентификатора];
	ИначеЕсли   мСторона.Свойство("СвИн", СвФлЮл) Тогда
		Результат = СвФлЮл[КлючИдентификатора] + "_" + СвФлЮл.Название;
	Иначе
		Возврат мСторона.Название;
	КонецЕсли;

	Если СвФлЮл.Свойство("КодФилиала") Тогда
		Результат = Результат + "_" + СвФлЮл.КодФилиала;
	КонецЕсли;
	Возврат Результат;
	
КонецФункции

// Процедура - Сохраняет посчитанные дополнительные параметры стороны
//
// Параметры:
//  ДанныеУчастник		 - Структура	 - содержит СвЮл/СвФЛ
//  ДопПараметрыСтороны	 - Соответствие	 - данные, которые надо сохранить
//
&НаКлиенте
Процедура СохранитьДополнительныеПараметрыСтороны(ДанныеУчастник, ДопПараметрыСтороны) Экспорт
	Если Не ДопПараметрыСтороны.Количество() Тогда
		Возврат;
	КонецЕсли;                                      
	
	КлючДляПараметров = КлючСтороныДляДопПараметров(ДанныеУчастник);
	ГлобальныйКэш.ТекущийСеанс.РасчитанныеЗначения.мСторона.Вставить(КлючДляПараметров, ДопПараметрыСтороны);
	
КонецПроцедуры

// Процедура - Сохраняет посчитанные дополнительные параметры стороны
//
// Параметры:
//  ДанныеУчастник		 - Структура	 - содержит СвЮл/СвФЛ
//  ДопПараметрыСтороны	 - Соответствие	 - данные, которые надо сохранить
//
&НаКлиенте
Функция ПрочитатьДополнительныйПараметрСтороны(ДанныеУчастник, КлючПараметры=Неопределено)  Экспорт
    Перем Результат;
	
	КлючДляДопПараметров = КлючСтороныДляДопПараметров(ДанныеУчастник);
	Если	Не ГлобальныйКэш.ТекущийСеанс.РасчитанныеЗначения.Свойство("мСторона", Результат) Тогда
		Возврат Неопределено;
	КонецЕсли;

	Результат = Результат.Получить(КлючДляДопПараметров);
	Если Результат = Неопределено Тогда 
		Возврат Неопределено
	КонецЕсли;
	
	Если КлючПараметры = Неопределено Тогда 
		Возврат Результат;
	КонецЕсли;
	Возврат Результат.Получить(КлючПараметры);
	
КонецФункции

// Функция возвращает описание идентификатора СБИС по ссылке 1С
//
// Параметры:
//  ДокументСсылка	 - Ссылка на документ 1С - Ссылка, на документ 1С, по которому требуется извлечь сведения о пакете
//  ДопПараметры	 - Структура			 - 
//		ИмяРегламента 		- Строка			- имя регламента, для доп. разреза хранения статусов, если есть
//		СтруктураРаздела	- СтруктураРазделаГО- структура раздела обработки, для авто. определения регламента.
// Возвращаемое значение:
//  Структура - ИдДокумента, ИдАккаунта
//
&НаКлиенте
Функция ПрочитатьСведенияОИдСБИСПоДокументу1С(ДокументСсылка, ДопПараметры=Неопределено) Экспорт
	Перем СтруктураРазделаГО, ИмяРегламентаДокумента;
	
	МассивСтатусРегламент	= ПолучитьЗначениеПараметраСбис("МассивСтатусРегламент");
	СтатусРегламент			= "";
	
	Если Не ДопПараметры = Неопределено Тогда
		ДопПараметры.Свойство("ИмяРегламента",		ИмяРегламентаДокумента);
		ДопПараметры.Свойство("СтруктураРаздела",	СтруктураРазделаГО);
	КонецЕсли;
	Если		ЗначениеЗаполнено(МассивСтатусРегламент)
		И		ПолучитьЗначениеПараметраСбис("СтатусыВРазрезеРегламента") Тогда
		
		Если		ЗначениеЗаполнено(ИмяРегламентаДокумента) Тогда
			Если НЕ	МассивСтатусРегламент.Найти(ИмяРегламентаДокумента) = Неопределено Тогда
				СтатусРегламент = ИмяРегламентаДокумента;
			КонецЕсли;
		ИначеЕсли	ЗначениеЗаполнено(СтруктураРазделаГО) Тогда
			//Взять от раздела
			ИниРеестра = ИниПоПараметрам(СтруктураРазделаГО.ТипДок).мФайл;
			//первый ини
			Для Каждого Файл из ИниРеестра Цикл
				РегламентНазвание = ГлобальныйКэш.ТекущийСеанс.Модули.ФункцииДокументов.РассчитатьЗначение("Регламент_Название", Файл.Значение);
				Если НЕ МассивСтатусРегламент.Найти(РегламентНазвание) = Неопределено Тогда 
					СтатусРегламент = РегламентНазвание;
				КонецЕсли;
				Прервать;
			КонецЦикла;
		Иначе
			//Регламента нет
		КонецЕсли;
		
    КонецЕсли;
	
	ПараметрыПрочитатьСвойство = Новый Структура("ДокументСсылка, Регламент", ДокументСсылка, СтатусРегламент);
	
	фрм = ГлавноеОкно.СбисНайтиФормуФункции("СбисПрочитатьСведенияОПакете", ПолучитьЗначениеПараметраСбис("ИмяМодуляРаботыСоСтатусами"));
	Возврат фрм.СбисПрочитатьСведенияОПакете(ПараметрыПрочитатьСвойство, ГлавноеОкно.Кэш);

КонецФункции

// Функция - читает стороны по данным 1С
//
// Параметры:
//  ДанныеПрочитатьВходящие	 - Массив	 - Организации, Контрагенты по которым нужно получить данные
//  ДопПараметры			 - Структура - возможность расширить
// 
// Возвращаемое значение:
//  Соответствие - Ключ - ссылка на справочник, Значение - структура Ошибка/Результат(посчитанная сторона)
//
&НаКлиенте
Функция ПрочитатьСтороныПоДанным1С(ДанныеПрочитатьВходящие, ДопПараметры=Неопределено) Экспорт 
	Перем УзелИниВСоответствие;
	
	ИниКонфигурации = ИниПоПараметрам("Конфигурация");
	МодульФункций	= ГлобальныйКэш.ТекущийСеанс.Модули.ФункцииДокументов;
	СоответствиеИни			= Новый Соответствие;
	СоответствиеПрочитать	= Новый Соответствие;
	СоответствиеРезультат	= Новый Соответствие;
	СоответствиеТипов		= Новый Соответствие;
	СоставПакета			= Новый СписокЗначений;
	// Распарсим файл ини.мСторона
	Если ИниКонфигурации.Свойство("мСторона") Тогда
		Для Каждого КлючИЗначение Из ИниКонфигурации.мСторона Цикл      
			СсылкаНаЭлемент = ПолучитьТипМетаданных(КлючИЗначение.Значение, "Сторона");      
			ИмяСправочника = СсылочныйТипСтрокой(СсылкаНаЭлемент);
			ИмяСправочника = СтрПолучитьСтроку(СтрЗаменить(ИмяСправочника, ".", Символы.ПС), 2);
			СоответствиеИни.Вставить(ИмяСправочника, КлючИЗначение.Значение);	
		КонецЦикла;
	КонецЕсли;
	
	Для Каждого СсылкаДанные Из ДанныеПрочитатьВходящие Цикл
		ТипСсылки				= ТипЗнч(СсылкаДанные);
		ПредставлениеТипаСсылки	= СоответствиеТипов.Получить(ТипСсылки);
		Если ПредставлениеТипаСсылки = Неопределено Тогда
			ПредставлениеТипаСсылки = МодульФункций.ПолучитьРеквизитМетаданныхОбъекта(СсылкаДанные, "Имя");
			СоответствиеТипов.Вставить(ТипСсылки, ПредставлениеТипаСсылки);
		КонецЕсли;
		УзелИниВСоответствие = СоответствиеИни.Получить(ПредставлениеТипаСсылки);
		Если УзелИниВСоответствие = Неопределено Тогда
			СбисФункция = "МодульОбъектаКлиент.ПрочитатьСтороныПоДанным1С";
			Детализация = "В файле настроек отсутствует узел для обработки участников " + ПредставлениеТипаСсылки;
			РезультатОшибка = НовыйСбисИсключение(, СбисФункция, , Детализация);
			СоответствиеРезультат.Вставить(СсылкаДанные, Новый Структура("Ошибка", РезультатОшибка));
			Продолжить;
		КонецЕсли;
		СоставПакета.Добавить(СсылкаДанные);
		СоответствиеПрочитать.Вставить(СсылкаДанные, Новый Структура("ИмяИни, ДокументДанные","Участник", УзелИниВСоответствие));
	КонецЦикла;
	МодульФункций.ПолучитьДанныеДокументов1С(СоответствиеПрочитать, Новый Структура("ТекущийПакет",Новый Структура), СоставПакета);

	Для Каждого Элемент Из СоответствиеПрочитать Цикл
		Сторона = МодульФункций.ПолучитьСторону(ГлавноеОкно.Кэш, Элемент.Значение.ДокументДанные);     
		Если Сторона = Неопределено Тогда
			РезультатОшибка	= НовыйСбисИсключение(721, "МодульОбъектаКлиент.ПрочитатьСтороныПоДанным1С",,,"У " + Элемент.Ключ + " не заполнен ИНН/КПП");
			СоответствиеРезультат.Вставить(Элемент.Ключ, Новый Структура("Ошибка", РезультатОшибка));
		Иначе
			СоответствиеРезультат.Вставить(Элемент.Ключ, Новый Структура("Результат", Сторона));
		КонецЕсли;
	КонецЦикла;
	Возврат СоответствиеРезультат;

КонецФункции

// Функция определяет тип идентификационного номера налогоплательцика, с учетом региональной особенности
//
// Параметры:
//  ИдентификационныйНомер	 - Строка	- идентификациооный номер стороны, определяемый ини файлом
// 
// Возвращаемое значение:
//  Структура - Ключ - строка, тип идентификациооного номера. Значение - булево, если определили тип, возвращаем Истина, если нет - Ложь.
//
&НаКлиенте
Функция ОпределитьТипИдентификационногоНомера(ИдентификационныйНомер) Экспорт
		
	СоставИдентификационныхНомеров = ПолучитьСоставИдентификационныхНомеров();
	
	ЭтоИНН = СбисИННСоответствуетТребованиямБезТипа(ИдентификационныйНомер)
		Или НЕ ЗначениеЗаполнено(ИдентификационныйНомер)
		Или СбисУНПСоответствуетТребованиям(ИдентификационныйНомер, Истина);
		
	Если ЭтоИНН Тогда
		СоставИдентификационныхНомеров.ИНН = Истина;
		Возврат СоставИдентификационныхНомеров;
	КонецЕсли;	
	
	ПроверочноеЧисло = Сред(ИдентификационныйНомер, 5, 1);	
		
	Если Найти("45", ПроверочноеЧисло) Тогда
		СоставИдентификационныхНомеров.БИН = Истина;
		Возврат СоставИдентификационныхНомеров;
	КонецЕсли;
	
	Если Найти("0123", ПроверочноеЧисло) Тогда
		СоставИдентификационныхНомеров.ИИН = Истина;
		Возврат СоставИдентификационныхНомеров;
	КонецЕсли;
	
	Возврат СоставИдентификационныхНомеров;
	
КонецФункции  

// Функция, по длине идентификационного номера, определяет тип лица и проверяет соответствие ИНН требованиям.
//
// Параметры:
//  ИНН 	- Строка - проверяемый индивидуальный номер налогоплательщика.
//
// Возвращаемое значение:
//  Булево	- Истина, если соответствует.
//
&НаКлиенте
Функция СбисИННСоответствуетТребованиямБезТипа(Знач ИНН) Экспорт
	
	ИННСтр = СокрЛП(ИНН);
	ДлинаИНН =  СтрДлина(ИННСтр);
	
	Если ДлинаИНН = 10 Тогда
		ЭтоЮридическоеЛицо = Истина;
	ИначеЕсли ДлинаИНН = 12 Тогда
		ЭтоЮридическоеЛицо = Ложь;
	Иначе
		Возврат Ложь;
	КонецЕсли;
	
	Возврат СбисИННСоответствуетТребованиям(ИНН, ЭтоЮридическоеЛицо);
	
КонецФункции

// Функция проверяет соответствие ИНН требованиям.
//
// Параметры:
//  ИНН                - Строка - проверяемый индивидуальный номер налогоплательщика.
//  ЭтоЮридическоеЛицо - Булево - признак, является ли владелец ИНН юридическим лицом.
//
// Возвращаемое значение:
//  Булево - Истина, если соответствует.
//
&НаКлиенте
Функция СбисИННСоответствуетТребованиям(Знач ИНН, ЭтоЮридическоеЛицо) Экспорт

	СоответствуетТребованиям = Истина;
	
	ИНН      = СокрЛП(ИНН);
	ДлинаИНН = СтрДлина(ИНН);

	Если ЭтоЮридическоеЛицо = Неопределено Тогда
		Возврат Ложь;
	КонецЕсли;  
	
	ТолькоЦифрыВСтроке = СбисТолькоЦифрыВСтроке(ИНН);
	
	Если НЕ ТолькоЦифрыВСтроке Тогда
		СоответствуетТребованиям = Ложь;
	КонецЕсли;

	Если  ЭтоЮридическоеЛицо И ДлинаИНН <> 10 Тогда
		СоответствуетТребованиям = Ложь;
	ИначеЕсли НЕ ЭтоЮридическоеЛицо И ДлинаИНН <> 12 Тогда
		СоответствуетТребованиям = Ложь;  
	Иначе
		//
	КонецЕсли;

	Если НЕ СоответствуетТребованиям Тогда
		Возврат Ложь;
	КонецЕсли;

	Если ЭтоЮридическоеЛицо Тогда

		КонтрольнаяСумма = 0;

		Для Индекс = 1 По 9 Цикл

			Если Индекс = 1 Тогда
				Множитель = 2;
			ИначеЕсли Индекс = 2 Тогда
				Множитель = 4;
			ИначеЕсли Индекс = 3 Тогда
				Множитель = 10;
			ИначеЕсли Индекс = 4 Тогда
				Множитель = 3;
			ИначеЕсли Индекс = 5 Тогда
				Множитель = 5;
			ИначеЕсли Индекс = 6 Тогда
				Множитель = 9;
			ИначеЕсли Индекс = 7 Тогда
				Множитель = 4;
			ИначеЕсли Индекс = 8 Тогда
				Множитель = 6;
			ИначеЕсли Индекс = 9 Тогда
				Множитель = 8;
			Иначе
				//
			КонецЕсли;

			Цифра = Число(Сред(ИНН, Индекс, 1));
			КонтрольнаяСумма = КонтрольнаяСумма + Цифра * Множитель;

		КонецЦикла;
		
		КонтрольныйРазряд = (КонтрольнаяСумма %11) %10;

		Если КонтрольныйРазряд <> Число(Сред(ИНН, 10, 1)) Тогда
			СоответствуетТребованиям = Ложь;
		КонецЕсли;

	Иначе

		КонтрольнаяСумма11 = 0;
		КонтрольнаяСумма12 = 0;

		Для Индекс = 1 По 11 Цикл

			// Расчет множителя для 11-го и 12-го разрядов.
			Если Индекс = 1 Тогда
				Множитель11 = 7;
				Множитель12 = 3;
			ИначеЕсли Индекс = 2 Тогда
				Множитель11 = 2;
				Множитель12 = 7;
			ИначеЕсли Индекс = 3 Тогда
				Множитель11 = 4;
				Множитель12 = 2;
			ИначеЕсли Индекс = 4 Тогда
				Множитель11 = 10;
				Множитель12 = 4;
			ИначеЕсли Индекс = 5 Тогда
				Множитель11 = 3;
				Множитель12 = 10;
			ИначеЕсли Индекс = 6 Тогда
				Множитель11 = 5;
				Множитель12 = 3;
			ИначеЕсли Индекс = 7 Тогда
				Множитель11 = 9;
				Множитель12 = 5;
			ИначеЕсли Индекс = 8 Тогда
				Множитель11 = 4;
				Множитель12 = 9;
			ИначеЕсли Индекс = 9 Тогда
				Множитель11 = 6;
				Множитель12 = 4;
			ИначеЕсли Индекс = 10 Тогда
				Множитель11 = 8;
				Множитель12 = 6;
			ИначеЕсли Индекс = 11 Тогда
				Множитель11 = 0;
				Множитель12 = 8; 
			Иначе
				//
			КонецЕсли;

			Цифра = Число(Сред(ИНН, Индекс, 1));
			КонтрольнаяСумма11 = КонтрольнаяСумма11 + Цифра * Множитель11;
			КонтрольнаяСумма12 = КонтрольнаяСумма12 + Цифра * Множитель12;

		КонецЦикла;

		КонтрольныйРазряд11 = (КонтрольнаяСумма11 %11) %10;
		КонтрольныйРазряд12 = (КонтрольнаяСумма12 %11) %10;

		Если КонтрольныйРазряд11 <> Число(Сред(ИНН, 11, 1)) Или КонтрольныйРазряд12 <> Число(Сред(ИНН, 12, 1)) Тогда
			СоответствуетТребованиям = Ложь;
		КонецЕсли;

	КонецЕсли;

	Возврат СоответствуетТребованиям;

КонецФункции 


&НаКлиенте
Функция ПолучитьСоставИдентификационныхНомеров()
	
	Результат = Новый Структура;
	Результат.Вставить("ИНН", Ложь);	
	Результат.Вставить("БИН", Ложь);	
	Результат.Вставить("ИИН", Ложь);	
	
	Возврат Результат;
	
КонецФункции

// Функция проверяет, содержит ли строка только цифры.
//
// Параметры:
//  Значение         - Строка - проверяемая строка.
//  ПробелыЗапрещены - Булево - если Ложь, то в строке допустимо наличие пробелов.
//
// Возвращаемое значение:
//   Булево - Истина - строка содержит только цифры или пустая, Ложь - строка содержит иные символы.
//
&НаКлиенте
Функция СбисТолькоЦифрыВСтроке(Знач Значение, ПробелыЗапрещены = Истина) Экспорт
	
	Если ТипЗнч(Значение) <> Тип("Строка") Тогда
		Возврат Ложь;
	КонецЕсли;
	
	Если Не ПробелыЗапрещены Тогда
		Значение = СтрЗаменить(Значение, " ", "");
	КонецЕсли;
		
	Если СтрДлина(Значение) = 0 Тогда
		Возврат Истина;
	КонецЕсли;
	
	// Если содержит только цифры, то в результате замен должна быть получена пустая строка.
	// Проверять при помощи ПустаяСтрока нельзя, так как в исходной строке могут быть пробельные символы.
	Возврат СтрДлина(
		СтрЗаменить( СтрЗаменить( СтрЗаменить( СтрЗаменить( СтрЗаменить(
		СтрЗаменить( СтрЗаменить( СтрЗаменить( СтрЗаменить( СтрЗаменить( 
			Значение, "0", ""), "1", ""), "2", ""), "3", ""), "4", ""), "5", ""), "6", ""), "7", ""), "8", ""), "9", "")) = 0;
	
КонецФункции

// Функция проверяет соответствие УНП требованиям.
//
// Параметры:
//  УНП                - Строка - проверяемый индивидуальный номер налогоплательщика.
//  ЭтоЮридическоеЛицо - Булево - признак, является ли владелец УНП юридическим лицом.
//
// Возвращаемое значение:
//  Булево - Истина, если соответствует.
//
&НаКлиенте
Функция СбисУНПСоответствуетТребованиям(Знач УНП, ЭтоЮридическоеЛицо) Экспорт
	
	УНП = СокрЛП(УНП); 
	ДлинаУНП = СтрДлина(УНП); 
	КорректнаяДлинаУНП = 9;
	Знаменатель = 11;
	
	Если НЕ СбисТолькоЦифрыВСтроке(УНП) Тогда
		Возврат Ложь;
	КонецЕсли;
	
	Если ДлинаУНП = КорректнаяДлинаУНП 
		И ЭтоЮридическоеЛицо Тогда
		
		КонтрольнаяСумма = 0;
		
		Для Индекс = 1 По 8 Цикл
			
			Множитель = ПолучитьМножительПоИндексу(Индекс);	
			Цифра = Число(Сред(УНП, Индекс, 1));
			КонтрольнаяСумма = КонтрольнаяСумма + Цифра * Множитель;
			
		КонецЦикла;
		
		КонтрольныйРазряд = (КонтрольнаяСумма % Знаменатель);
		
		Если КонтрольныйРазряд <> Число(Сред(УНП, 9, 1)) 
			Или КонтрольныйРазряд = 10 Тогда
			Возврат Ложь;
		КонецЕсли;
		
	ИначеЕсли ДлинаУНП = КорректнаяДлинаУНП 
		И НЕ ЭтоЮридическоеЛицо Тогда
		
		КонтрольнаяСумма = 0;
		
		Для Индекс = 1 По 8 Цикл 
			
			Множитель = ПолучитьМножительПоИндексу(Индекс); 
			Буква = Сред(УНП, Индекс, 1); 
			 
			Цифра = ПолучитьКонтрольнуюЦифру(Индекс, Буква); 
			
			Если Цифра = Ложь Тогда
				Цифра = Число(Сред(УНП, Индекс, 1));  
			КонецЕсли;		
						
			КонтрольнаяСумма = КонтрольнаяСумма + Цифра * Множитель;
			
		КонецЦикла;
		
		КонтрольныйРазряд = (КонтрольнаяСумма % Знаменатель);
		
		Если КонтрольныйРазряд <> Число(Сред(УНП, 9, 1)) 
			Или КонтрольныйРазряд = 10 Тогда
			Возврат Ложь;
		КонецЕсли;
		
	Иначе
		
		Возврат Ложь;
		
	КонецЕсли;
	
	Возврат Истина;	
	
КонецФункции  

&НаКлиенте
Функция ПолучитьМножительПоИндексу(Индекс)     
	
	МассивМножителей = Новый Массив;
	
	МассивМножителей.Добавить(29);
	МассивМножителей.Добавить(23);
	МассивМножителей.Добавить(19);
	МассивМножителей.Добавить(17);
	МассивМножителей.Добавить(13);
	МассивМножителей.Добавить(7);
	МассивМножителей.Добавить(5);
	МассивМножителей.Добавить(3);  
	
	Если МассивМножителей.Количество() < Индекс Тогда
		Возврат Ложь;
	Иначе
		Возврат МассивМножителей[Индекс - 1];
	КонецЕсли;
			
КонецФункции    

&НаКлиенте
Функция ПолучитьКонтрольнуюЦифру(Индекс, Буква)  
	
	МассивИндексов = Новый Массив; 
	
	СоставПервичныхКлючей = Новый Соответствие;
	СоставПервичныхКлючей.Вставить("А", 10);
	СоставПервичныхКлючей.Вставить("В", 11); 
	СоставПервичныхКлючей.Вставить("С", 12);
	СоставПервичныхКлючей.Вставить("Е", 14);
	СоставПервичныхКлючей.Вставить("Н", 17);
	СоставПервичныхКлючей.Вставить("К", 10);
	СоставПервичныхКлючей.Вставить("М", 22); 
	
	СоставВторичныхКлючей = Новый Соответствие; 
	СоставВторичныхКлючей.Вставить("А", 0);
	СоставВторичныхКлючей.Вставить("В", 1); 
	СоставВторичныхКлючей.Вставить("С", 2);
	СоставВторичныхКлючей.Вставить("Е", 3);
	СоставВторичныхКлючей.Вставить("Н", 4);
	СоставВторичныхКлючей.Вставить("К", 5);
	СоставВторичныхКлючей.Вставить("М", 6); 
	СоставВторичныхКлючей.Вставить("О", 7);
	СоставВторичныхКлючей.Вставить("Р", 8);
	СоставВторичныхКлючей.Вставить("Т", 9); 

	
	МассивИндексов.Добавить(СоставПервичныхКлючей);
	МассивИндексов.Добавить(СоставВторичныхКлючей);
	
	Если МассивИндексов.Количество() < Индекс Тогда
		Возврат Ложь;
	Иначе
		Возврат МассивИндексов[Индекс - 1].Получить(Буква);
	КонецЕсли;
			
КонецФункции

