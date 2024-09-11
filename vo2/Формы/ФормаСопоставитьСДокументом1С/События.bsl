
//Процедура сопоставляет выбранный документ 1С документу сбис	
&НаКлиенте
Процедура ПодходящиеДокументыВыбор(Элемент, ВыбраннаяСтрока, Колонка, СтандартнаяОбработка)
	
	Документ1С = Элемент.ТекущиеДанные.Документ1С;
	ПрименитьИзменениеИЗакрыть();
	
КонецПроцедуры

//Оформление таблицы подходящих документов ОФ	
&НаКлиенте
Процедура ПодходящиеДокументыПриВыводеСтроки(Элемент, ОформлениеСтроки, ДанныеСтроки)
	
	ОформлениеСтроки.Ячейки.Документ1С.Текст = МестныйКэш.ОбщиеФункции.СформироватьНазваниеВходящегоДокумента1С(ДанныеСтроки.Документ1С);
	
КонецПроцедуры

//Процедура устанавливает ограничения типов документов 1С, которые можно выбрать для сопоставления	
&НаКлиенте
Процедура УстановитьОграничениеТипа(Элемент, Типы1С)
	
	МассивТипов = Новый Массив;
	Для Каждого Тип1С Из Типы1С Цикл
		МассивТипов.Добавить(Тип("ДокументСсылка." + Тип1С.Значение));
	КонецЦикла;
	Элемент.ОграничениеТипа = Новый ОписаниеТипов(МассивТипов);
	
КонецПроцедуры

