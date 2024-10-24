
// Процедура - обработчик разворачивания строки списка маркируемых позиций 
//
&НаКлиенте
Процедура ТаблицаМаркировкаПередРазворачиванием(Элемент, Строка, Отказ)  
	
	Если НЕ ПараметрыРаботы.Свойство("МаркировкаЗаполнена") Тогда
		Возврат;
	КонецЕсли;
	
	#Если Не ТолстыйКлиентОбычноеПриложение Тогда
		Строка = ТаблицаМаркировка.НайтиПоИдентификатору(Строка); 
	#КонецЕсли
	Если НЕ Строка = Неопределено Тогда  
		МестныйКэш.ГлавноеОкно.СбисПолучитьЭлементФормы(Строка, "Строки").Очистить();
		
		ТаблицаФормы = МестныйКэш.ГлавноеОкно.СбисПолучитьЭлементФормы(ЭтаФорма, "ТаблицаМаркировка");
		
		МестныйКэш.ГлавноеОкно.СбисПолучитьЭлементФормы(ТаблицаФормы, "КодМаркировки").Видимость = Истина;
		МестныйКэш.ГлавноеОкно.СбисПолучитьЭлементФормы(ТаблицаФормы, "ИндикаторКодаМаркировки").Видимость = Истина; 
		
		Попытка

			//Если поэкземплярный учет, то вычитываем НДР
			ДопПараметры = Новый Структура("НоменклатураСбис", Строка.НоменклатураСбис);
			ПараметрыНоменклатуры = МодульОбъектаКлиент().ВернутьПараметрыНоменклатуры(СоставПакета, ДопПараметры);  

		Исключение
			МодульОбъектаКлиент().СообщитьСбисИсключение(ИнформацияОбОшибке(), "ТаблицаМаркировкаПередРазворачиванием");
		КонецПопытки;
		
		Если ПараметрыНоменклатуры = Неопределено ИЛИ НЕ ПараметрыНоменклатуры.Количество() Тогда
			Возврат;
		КонецЕсли;
		
		Для Каждого ЭлСтр ИЗ ПараметрыНоменклатуры Цикл
			НоваяСтрока = МестныйКэш.ГлавноеОкно.СбисПолучитьЭлементФормы(Строка, "Строки").Добавить();   
			НоваяСтрока.КодМаркировки = ЭлСтр.Number;
			Если ЭлСтр.Свойство("IndicatorData") 
				И ТипЗнч(ЭлСтр.IndicatorData) = Тип("Массив")
				И ЗначениеЗаполнено(ЭлСтр.IndicatorData) Тогда
				НоваяСтрока.ИндикаторКодаМаркировки = ЭлСтр.IndicatorData[0].Error;    
				НоваяСтрока.ИндексКартинкиКод = 1;
			КонецЕсли;
		КонецЦикла;  
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура ПозГКПриИзменении(Элемент)
	
	СоставПакета.Вставить("ПерегенерироватьВложения", Истина);
	
КонецПроцедуры
