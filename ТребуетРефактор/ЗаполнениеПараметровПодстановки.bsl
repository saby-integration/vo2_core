
// Нужно вынести специфику документа (УПД) на его форму формирования (форму тоже запилить)
&НаКлиенте
Процедура ЗаполнитьПоДокументПараметр(Док, Кэш) Экспорт
	ТекДокумент = Док.Файл.Документ;

	Если НЕ ТекДокумент.Свойство("Параметр") Тогда
		Возврат;
	КонецЕсли;
	НовыеПараметрыСгенерировать = Новый Массив;

	Для Каждого ТекСтрока ИЗ ТекДокумент.Параметр Цикл
		
		Если		ТекСтрока.Имя = "ИдГосКон" Тогда
			ТекДокумент.Вставить(ТекСтрока.Имя, ТекСтрока.Значение);
		ИначеЕсли	ТекСтрока.Имя = "СвТранГруз"  Тогда
			ТекДокумент.Вставить(ТекСтрока.Имя, ТекСтрока.Значение);
		ИначеЕсли	ТекСтрока.Имя = "ОснованиеДата" Тогда
            НовыеПараметрыСгенерировать.Добавить(Новый Структура("Имя, Значение", "НакладнаяДата", ТекСтрока.Значение));
		ИначеЕсли	ТекСтрока.Имя = "ОснованиеНомер" Тогда
            НовыеПараметрыСгенерировать.Добавить(Новый Структура("Имя, Значение", "НакладнаяНомер", ТекСтрока.Значение));
		КонецЕсли;
		
	КонецЦикла;
	
	Для Каждого ТекСтрока Из НовыеПараметрыСгенерировать Цикл
		ТекДокумент.Параметр.Добавить(ТекСтрока);
	КонецЦикла;
	
КонецПроцедуры

