
#Область include_core2_vo2_СистемныеИнтерфейсы_ИнтерфейсныйМодуль
#КонецОбласти

#Область include_core2_vo2_СистемныеИнтерфейсы_Формы_ИнтерфейсныйМодуль_Перегрузка_СбисЗаблокироватьИнтерфейс
#КонецОбласти

#Область include_core2_vo2_СистемныеИнтерфейсы_Формы_ИнтерфейсныйМодуль_Перегрузка_СбисРазблокироватьИнтерфейс
#КонецОбласти

#Область include_core2_vo2_Формы_ФормаПредупреждения_СистемныйИнтерфейс
#КонецОбласти

&НаКлиенте
Процедура ПредупреждениеСсылкаНажатие(Элемент, СтандартнаяОбработка)

	СтандартнаяОбработка = Ложь;
	ЗапуститьПриложение(ПредупреждениеАдресСсылка);
	
КонецПроцедуры

