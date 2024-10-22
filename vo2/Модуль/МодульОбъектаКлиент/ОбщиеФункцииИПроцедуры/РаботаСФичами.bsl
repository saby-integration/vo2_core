
// Проверить, подклюена ли фича
//
// Параметры:
//  ПараметрыФичи  - Структура - Обязательный ключ НазваниеФичи со строковым значением
//                 
//  ДопПараметры   - Структура, Неопределено - Доп параметры
//                 (Если вдруг однажды понадобятся)
//
// Возвращаемое значение:
//   Булево   - Истина - фича вклюена
//
&НаКлиенте
Функция ПолучитьЗначениеФичи(ПараметрыФичи, ДопПараметры = Неопределено) Экспорт 
    Перем КлючФичи;

	Если ТипЗнч(ПараметрыФичи) = Тип("Строка") Тогда
		КлючФичи = ПараметрыФичи;
	Иначе
		КлючФичи = ПараметрыФичи.НазваниеФичи;
	КонецЕсли;
	
	ЗначениеФичи = ПолучитьЗначениеПараметраСбис(КлючФичи);
	Если ЗначениеФичи = Неопределено Тогда
		
		СоответствиеФич = ПолучитьСписокФичИПредставлений();
		ПараметрыВызова = Новый Структура("НазваниеФичи", СоответствиеФич[КлючФичи]);
		Попытка
			ЗначениеФичи = ГлобальныйКэш.ТекущийСеанс.Модули.Интеграция.ExtSys_FeatureIsOn(ПараметрыВызова, Новый Структура("Кэш", ГлавноеОкно.Кэш));
		Исключение
			ВызватьСбисИсключение(ИнформацияОбОшибке(), "МодульОбъектаКлиент.ПолучитьЗначениеФичи");
		КонецПопытки;
		
		//фича не получина, не кэшировать значение, т.к. значит что пока не ходили за ней
		Если ЗначениеФичи = Неопределено Тогда
			ЗначениеФичи = Ложь;
		Иначе
			ИзменитьПараметрСбис(КлючФичи, ЗначениеФичи, Новый Структура("Адрес", "СБИС.ПараметрыИнтеграции"));
		КонецЕсли;
			
	КонецЕсли;
	
	Возврат ЗначениеФичи;
	
КонецФункции // ПолуитьЗначениеФии()

// Возвращаетсписок доступных фич с их представлением во
// внешней обработке
//
//
// Возвращаемое значение:
//  Структура    - Ключ		- предстваление в 1С
//                 Значение	- имя в СБИС 
//
&НаКлиенте
Функция ПолучитьСписокФичИПредставлений()

	СписокФич = Новый Структура;
	
	СписокФич.Вставить("ПоддержкаМаркировки",													"1c_marking");  
	СписокФич.Вставить("ПоддержкаПрослеживаемости",												"external_trcb_state");
	СписокФич.Вставить("РасширенныйФункционалСопоставленияНоменклатуры",						"1c_nom_extension");
	СписокФич.Вставить("РасширенныйФункционалСопоставленияНоменклатуры_ОбратноеСопоставление",	"1c_nom_extension_rev");
	СписокФич.Вставить("НовыеКонтрагенты",														"1c_new_contractors"); 
	СписокФич.Вставить("ПоддержкаНовойМаркировки", 												"1c_marking_new"); 
	СписокФич.Вставить("НовоеАннулированиеЗаказов", 											"order_cancellation");
	СписокФич.Вставить("АннулированиеБезПодписания", 											"oneway_cancel");
	
	Возврат СписокФич;

КонецФункции // ПолучитьСписокФичИПредставлений()

// Сбрасывает значения фич
//
&НаКлиенте
Функция ОчиститьЗначенияФич() Экспорт 
	
	Кэш = ГлавноеОкно.Кэш;
	
	Для Каждого Фича Из ПолучитьСписокФичИПредставлений() Цикл
		
		Если Кэш.СБИС.ПараметрыИнтеграции.Свойство(Фича.Ключ) Тогда
			
			Кэш.СБИС.ПараметрыИнтеграции.Удалить(Фича.Ключ);
			
		КонецЕсли;
		
	КонецЦикла;

КонецФункции // ОчиститьЗначенияФич()

