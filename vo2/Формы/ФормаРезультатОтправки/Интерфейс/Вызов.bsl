
&НаКлиенте
Функция ПоказатьРезультатОтправки(Кэш) Экспорт
	
	МестныйКэш = Кэш;
	РезультатОтправки = Кэш.РезультатОтправки;	
	
	Если Не ЭтаФорма.Открыта() Тогда
		ЭтаФорма.Открыть();
	Иначе
		ПриОткрытии("");
	КонецЕсли;
	
КонецФункции

