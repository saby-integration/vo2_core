
&НаКлиенте
Функция ПолучитьТабличнуюЧастьДокумента1С(Кэш,Контекст) Экспорт
	
	ИмяДокумента = Кэш.ОбщиеФункции.ПолучитьРеквизитМетаданныхОбъекта(Контекст.Документ, "Имя");
	фрм = Кэш.ГлавноеОкно.сбисНайтиФормуФункции("ПолучитьТабличнуюЧастьДокумента1С","Документ_"+ИмяДокумента,"Файл_Шаблон", Кэш);
	фрм.ПолучитьТабличнуюЧастьДокумента1С(Кэш,Контекст);
	
КонецФункции
