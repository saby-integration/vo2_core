
//Штатный обработчик строки подстановки
&НаКлиенте
Процедура ОбработчикДанных_ЗаполнитьСтрокуТабличнойЧастиДокумента(Аргумент, ДопПараметры) Экспорт
	ЗаполнитьТабличныеДанныеПоСуффиксу			(Аргумент, ДопПараметры);
	ЗаполнитьТабличныеДанныеСтранаПроизводства	(Аргумент, ДопПараметры); 
	ЗаполнитьТабличныеДанныеУпаковка			(Аргумент, ДопПараметры);
	ЗаполнитьТабличныеДанныеБрутто				(Аргумент, ДопПараметры);
	ЗаполнитьТабличныеДанныеRnptData			(Аргумент, ДопПараметры);
	ЗаполнитьТабличныеДанныеОбщие				(Аргумент, ДопПараметры);
	ЗаполнитьТабличныеДанныеАкциз				(Аргумент, ДопПараметры)
КонецПроцедуры

