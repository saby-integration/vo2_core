
&НаКлиенте
Перем МестныйКэш, Кэш Экспорт;
Перем МассивЗакладок;

&НаКлиенте
Перем СтрокаТЧДоИзменения, СтрокаТЧУстановить;

#Область include_local_ПолучитьМодульОбъекта
#КонецОбласти

#Область include_core2_vo2_СистемныеИнтерфейсы_ОбщиеФункции
#КонецОбласти

#Область include_local_ФормаПросмотрДокумента
#КонецОбласти

#Область include_core2_vo2_Формы_ФормаПросмотрДокумента_Совместимость
#КонецОбласти

#Область include_core2_vo2_Формы_ФормаПросмотрДокумента_ВнешнийВызов
#КонецОбласти

#Область include_core2_vo2_Формы_ФормаПросмотрДокумента_Прочее
#КонецОбласти

#Область include_core2_vo2_Формы_ФормаПросмотрДокумента_ОбработчикиСобытий
#КонецОбласти

#Область include_local_Формы_ФормаПросмотрДокумента_События_ТабличнаяЧасть
#КонецОбласти

#Область include_core2_vo2_Формы_ФормаПросмотрДокумента_События_Форма
#КонецОбласти

#Область include_core2_vo2_Формы_ФормаПросмотрДокумента_События_ТабличнаяЧасть
#КонецОбласти

#Область include_core2_vo2_Формы_ФормаПросмотрДокумента_События_ТаблицаДокументов
#КонецОбласти

#Область include_core2_vo2_Формы_ФормаПросмотрДокумента_События_ТаблицаМаркировка
#КонецОбласти

#Область include_local_Формы_ФормаПросмотрДокумента_События_ТаблицаМаркировка
#КонецОбласти

#Область include_core2_vo2_Формы_ФормаПросмотрДокумента_Команды
#КонецОбласти

#Область include_core2_vo2_Формы_ФормаПросмотрДокумента_РасширенноеСопоставление_СлужебныеПроцедурыИФункции
#КонецОбласти

#Область include_core2_vo2_Формы_ФормаПросмотрДокумента_РасширенноеСопоставление_ОбработчикиСобытий
#КонецОбласти  

// alo EDI_ДозаписьЮЗДО >>
МассивЗакладок = Новый Массив;
МассивЗакладок.Добавить("Документы");
МассивЗакладок.Добавить("Загрузка");
МассивЗакладок.Добавить("Прохождение");  
МассивЗакладок.Добавить("Маркировка"); 
МассивЗакладок.Добавить("Прослеживаемость");

