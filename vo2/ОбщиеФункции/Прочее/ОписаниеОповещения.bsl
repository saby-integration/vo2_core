
&НаКлиенте
Функция СбисОписаниеОповещения(Кэш, СбисПроцедура, СбисМодуль, СбисДопПараметры = Неопределено, СбисПроцедураИсключения = Неопределено, СбисМодульИсключения = Неопределено) Экспорт
	Возврат МодульОбъектаКлиент().НовыйСбисОписаниеОповещения(СбисПроцедура, СбисМодуль, СбисДопПараметры, СбисПроцедураИсключения, СбисМодульИсключения);	
КонецФункции

&НаКлиенте
Процедура СбисВыполнитьОписаниеОповещения(Кэш, РезультатВызова=Неопределено, СбисОписаниеОповещения) Экспорт
	МодульОбъектаКлиент().ВыполнитьСбисОписаниеОповещения(РезультатВызова, СбисОписаниеОповещения);	
КонецПроцедуры

