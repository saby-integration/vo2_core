
// функция возвращает код региона по названию из регистра сведений (АдресныйКлассификатор или АдресныеОбъекты)
Функция ПолучитьКодРегионаПоНазваниюНаСервере(НазваниеРегиона) Экспорт
	
	ИмяРегистра = ?(Метаданные.РегистрыСведений.Найти("АдресныеОбъекты") <> Неопределено, "АдресныеОбъекты", "АдресныйКлассификатор");
	ИмяУровня = ?(Метаданные.РегистрыСведений[ИмяРегистра].Измерения.Найти("ТипАдресногоЭлемента") <> Неопределено,"ТипАдресногоЭлемента",?(Метаданные.РегистрыСведений[ИмяРегистра].Реквизиты.Найти("ТипАдресногоЭлемента") <> Неопределено,"ТипАдресногоЭлемента","Уровень"));
	НазваниеКода = ?(Метаданные.РегистрыСведений[ИмяРегистра].Измерения.Найти("КодСубъектаРФ") <> Неопределено,"КодСубъектаРФ",?(Метаданные.РегистрыСведений[ИмяРегистра].Измерения.Найти("КодРегионаВКоде") <> Неопределено,"КодРегионаВКоде","КодАдресногоОбъектаВКоде"));
	Если Метаданные.РегистрыСведений[ИмяРегистра].Реквизиты.Найти("Сокращение") <> Неопределено
			Или Метаданные.РегистрыСведений[ИмяРегистра].Ресурсы.Найти("Сокращение") <> Неопределено Тогда
		РеквизитСокращение = "Сокращение";
	Иначе
		РеквизитСокращение = "ТипОбъекта";
	КонецЕсли;
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	|	АдресныйКлассификатор."+НазваниеКода+" КАК КодРегион
	|ИЗ
	|	РегистрСведений."+ИмяРегистра+" КАК АдресныйКлассификатор
	|ГДЕ
	|	АдресныйКлассификатор."+ИмяУровня+" = 1
	|И  АдресныйКлассификатор.Наименование + "" "" + АдресныйКлассификатор." + РеквизитСокращение + " = &НазваниеРегиона";
	Запрос.УстановитьПараметр("НазваниеРегиона", НазваниеРегиона);
	Выборка = Запрос.Выполнить().Выбрать();
	
	Пока Выборка.Следующий() Цикл
		КодРегион = Выборка.КодРегион;
		Если Число(КодРегион)<10 Тогда
			КодРегион = "0"+Строка(КодРегион);
		КонецЕсли;
		Возврат КодРегион;
	КонецЦикла;
	
	Возврат "";
	
КонецФункции

Функция ПодобратьЕдиницуИзмеренияПоОКЕИ(ОКЕИ, Номенклатура = Неопределено, ДопПараметры = Неопределено) Экспорт
	
	Перем КлассификаторЕдиницИзмерения, ЕдиницыИзмеренияНоменклатуры, РеквизитЕдиницаПоКлассификатору, Результат;

	Если НЕ Метаданные.Справочники.Найти("УпаковкиЕдиницыИзмерения") = Неопределено Тогда  //ЕРП, КА2, УТ11
		
		ЕдиницыИзмеренияНоменклатуры	= "УпаковкиЕдиницыИзмерения";
		РеквизитЕдиницаПоКлассификатору	= "ЕдиницаИзмерения"; 
		КлассификаторЕдиницИзмерения	= ЕдиницыИзмеренияНоменклатуры; //В ЕРП, УТ11 Базовые единицы хранятся в том же справочнике
		
	ИначеЕсли НЕ Метаданные.Справочники.Найти("ЕдиницыИзмерения") = Неопределено Тогда //УПП, УТ10
		
		ЕдиницыИзмеренияНоменклатуры	= "ЕдиницыИзмерения"; 
		РеквизитЕдиницаПоКлассификатору	= "ЕдиницаПоКлассификатору"; 
		
	КонецЕсли;		
	
	
	Если НЕ Метаданные.Справочники.Найти("КлассификаторЕдиницИзмерения") = Неопределено Тогда
		КлассификаторЕдиницИзмерения = "КлассификаторЕдиницИзмерения";
	КонецЕсли;
	
	Если ЗначениеЗаполнено(КлассификаторЕдиницИзмерения) Тогда
		ЕдиницаКлассификатора = Справочники[КлассификаторЕдиницИзмерения].НайтиПоКоду(ОКЕИ);
		Возврат ЕдиницаКлассификатора;
	КонецЕсли;
	
	Если НЕ ЗначениеЗаполнено(ЕдиницыИзмеренияНоменклатуры) Тогда
		
		Результат = ЕдиницаКлассификатора;  //Для Конфигураций, где учет по единицам классификатора
		
	Иначе
		
		Запрос = Новый Запрос;
		Запрос.Текст = 
			"ВЫБРАТЬ ПЕРВЫЕ 1
			|	ЕдиницыИзмерения.Ссылка
			|ИЗ
			|	Справочник."+ЕдиницыИзмеренияНоменклатуры+" КАК ЕдиницыИзмерения
			|ГДЕ
			|	ЕдиницыИзмерения.Владелец = &Владелец
			|	И ЕдиницыИзмерения."+РеквизитЕдиницаПоКлассификатору+" = &ЕдиницаКлассификатора
			|	И НЕ ЕдиницыИзмерения.ПометкаУдаления";
		
		
		Запрос.УстановитьПараметр("Владелец", Номенклатура);
		Запрос.УстановитьПараметр("ЕдиницаКлассификатора", ЕдиницаКлассификатора);
		
		РезультатЗапроса 		= Запрос.Выполнить();		
		ВыборкаДетальныеЗаписи	= РезультатЗапроса.Выбрать();
		
		Если ВыборкаДетальныеЗаписи.Следующий() Тогда
			Результат = ВыборкаДетальныеЗаписи.Ссылка; 
		КонецЕсли;
		
	КонецЕсли;
	
	Возврат Результат;
	
КонецФункции

