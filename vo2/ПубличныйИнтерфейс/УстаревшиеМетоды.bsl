
// НЕ ИСПОЛЬЗОВАТЬ МЕТОДЫ ИЗ ОБЛАСТИ УСТАРЕВШИХ!

//Использовать сбисЗапуститьОтправку
// Функция выполняет отправку документов
//Параметры
//	Кэш:						структура, кэш обработки Sbis1C
//	МассивСтрок:				список значений, содержащий структуры СоставПакета в качестве значения.
//								где СоставПакета - список значений, содержащий ссылки на документы 1С в качестве значения и наименование файла настройки для расчета документа в качестве представления для возможности точечной корректировки (если не указано, то определяется по типу документа).
//	ДополнительныеПараметры:	необязательная структура, может содержать поле ИниРеестра с имененем ТипДок для изменения настройки формирования для всех документов
//
//Возвращает
//	Истина, если ини прошли проверку и успешно установлены.
&НаКлиенте
Функция сбисОтправка(Кэш, МассивСтрок, ДополнительныеПараметры = Неопределено) Экспорт	
	
	фрм = МодульОбъектаКлиент().ПолучитьФормуОбработки("Документ_Шаблон");
	Кэш.Текущий.Вставить("Форма", МодульОбъектаКлиент().ПолучитьФормуОбработки("Раздел_Продажа_Шаблон"));
	Если ТипЗнч(ДополнительныеПараметры) = Тип("Структура") и ДополнительныеПараметры.Свойство("ИниРеестра") Тогда
		Кэш.Текущий.ТипДок = ДополнительныеПараметры.ИниРеестра;
	КонецЕсли;
	фрм.ОтправитьДокументы(Кэш,МассивСтрок);
	Возврат Кэш.РезультатОтправки;
	
КонецФункции

// Использовать сбисПолучитьРеестрДокументовОнлайна.
//Функция получает список документов/событий для построения реестра.
//Параметры
//	Кэш 					- Структура - кэш обработки Sbis1C
//	ФильтрВходящий			- Структура - Может содержать поля, одноименные полям фильтра на главном окне. По заданному фильтру будут отбираться документы для сопоставления.
//	ДопПараметры			- Структура - 
//		Раздел - Строка - Представление кнопки раздела, по которому будет "построен" раздел. Посмотреть соответствие раздела с его названием можно в макете "СтруктураАккордеона"
//
//Возвращает
//	Структура с полем "Таблица_РеестрДокументов/Таблица_РеестрСобытий" с массивом документов
//	Вызывает исключение в формате: сообщение об ошибке (детализация ошибки) при ошибке
//
&НаКлиенте
Функция сбисПолучитьСписокДокументов(Кэш, Фильтр, ДополнительныеПараметры = Неопределено) Экспорт
	Раздел = Неопределено;
	Если	Не ТипЗнч(ДополнительныеПараметры) = Тип("Структура")
		Или	Не ДополнительныеПараметры.Свойство("Раздел",Раздел) Тогда
		Раздел = "АккордеонПолученные11";
	КонецЕсли;
	Кэш.Текущий = Кэш.ГлавноеОкно.сбисСтруктураВыбранногоРаздела(Кэш, Раздел);
	
	Если Фильтр = Неопределено Тогда
		Фильтр = Кэш.ОбщиеФункции.ПолучитьФильтрСобытий(Кэш, Новый Структура("Тип", Кэш.Текущий.ТипДок));
	КонецЕсли;
	
	СписокДокументов = Кэш.Интеграция.сбисПолучитьСписокДокументовПоФильтру(Кэш, Фильтр, Кэш.ГлавноеОкно);
	Возврат СписокДокументов;
КонецФункции

