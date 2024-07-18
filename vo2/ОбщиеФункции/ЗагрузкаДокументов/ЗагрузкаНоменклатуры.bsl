
////////////////////////////////////////////////////
///////////////Загрузка номенклатуры////////////////
////////////////////////////////////////////////////

//Функция вынесена из СоздатьПерезаполнитьДокументы. Сопоставляет, либо загружает не сопоставленную номенклатуру в зависимости от выбранного режима:
//	Режим 0 Документ не загружается, если нет сопоставления.
//	Режим 1 Для несопоставленных позиций создавать карточки номенклатуры и контрагента.
//	Режим 2 В табличную часть загружать только сопоставленную номенклатуру.
//	режим 3 Для несопоставленной номенклатуры в табличной части не заполнять поле Номенклатура.
//Как результат идёт структура с описанием выполненного действия с номенклатурой. 
&НаКлиенте
Функция ЗаполнитьСопоставитьНоменклатуру(Кэш, СтрТабл, ПараметрыЗаполнения, Отказ) Экспорт
	
	СтрТаблНазвание = ?(СтрТабл.Свойство("Название"), СтрТабл.Название, "");
	Результат = Новый Структура("Название, Номенклатура, Новый, НеЗагружать", СтрТаблНазвание, Неопределено, Ложь, Ложь);
	
	НашаНоменклатура	= ПараметрыЗаполнения.НашаНоменклатура;
	СтруктураИниФайла	= ПараметрыЗаполнения.Вложение.СтруктураИниФайла;
	СтруктураФайла		= ПараметрыЗаполнения.Вложение.СтруктураФайла;
	
	//1189546150
	ДопПараметры = Новый Структура;
	ДопПараметры.Вставить("СтруктураИниФайла",СтруктураИниФайла);
	
	Если Не ЗначениеЗаполнено(СтрТаблНазвание) И ПараметрыЗаполнения.РежимНоменклатуры <> 0 Тогда // Если отсутствует атрибут Название, 
		РежимНоменклатуры = 3;                                                                 // то номенклатуру не добавляем, а в табличной части оставляем номенклатуру пустой
	Иначе
		РежимНоменклатуры = ПараметрыЗаполнения.РежимНоменклатуры;
	КонецЕсли;
	СтрКонтрагента		= ПараметрыЗаполнения.СтрКонтрагента;
	ПараметрыРезультат	= ПараметрыЗаполнения.ПараметрыРезультат;
	
	Если	Не СтрТабл.Свойство("Номенклатура", Результат.Номенклатура)
		Или	Не ЗначениеЗаполнено(Результат.Номенклатура) Тогда
		ДанныеНоменклатуры = Неопределено;
		Если ЗначениеЗаполнено(НашаНоменклатура) И СтрТабл.Свойство(НашаНоменклатура) Тогда
			ДанныеНоменклатуры = Кэш.ГлавноеОкно.сбисПолучитьФорму("Документ_Шаблон").РассчитатьЗначение(СтруктураИниФайла.НашаНоменклатура.Вычислить,Новый Структура("Ини, Документ, СтрТабл, Переменные, СтруктураФайла, СтрокаФайла", СтруктураИниФайла, , , , СтруктураФайла, СтрТабл),Кэш);
		КонецЕсли;
		Если НЕ ЗначениеЗаполнено(ДанныеНоменклатуры) Тогда
			Если ПараметрыЗаполнения.ДанныеНоменклатуры = Неопределено Тогда
				Попытка
					НоменклатураКонтрагентаИнфо = Новый Структура;
					Для Каждого Узел Из СтрТабл Цикл
						НоменклатураКонтрагентаИнфо.Вставить(Узел.Ключ, Узел.Значение);
					КонецЦикла;
					ДанныеНоменклатуры = ПараметрыЗаполнения.фрмНоменклатуры.НайтиНоменклатуруПоставщика(СтрКонтрагента, НоменклатураКонтрагентаИнфо, Кэш.Парам.КаталогНастроек, Кэш.Ини);
				Исключение
				КонецПопытки;
			Иначе//Берем предварительно найденное значение, если не удалось рассчитать. 
				ДанныеНоменклатуры = ПараметрыЗаполнения.ДанныеНоменклатуры;
			КонецЕсли;	
		КонецЕсли;	
		Если ЗначениеЗаполнено(ДанныеНоменклатуры) Тогда
			Результат.Номенклатура = ДанныеНоменклатуры.Номенклатура;
			ПараметрыРасшифровки = Новый Структура("Название, Ссылка, Тип, Состояние, Сообщение", СтрТаблНазвание, Результат.Номенклатура, Кэш.Ини.Конфигурация.НоменклатураПоставщиков.Значение, "Найден.", "Для позиции " + СтрТаблНазвание + " найдена подходящая номенклатура.");
			РезультатДействия_ДобавитьВРасшифровку(Кэш, "ЗагрузкаСправочника", ПараметрыЗаполнения.СтрокаДетализации, ПараметрыРасшифровки);
		Иначе
			Результат.Номенклатура = Неопределено;
		КонецЕсли;
		Если РежимНоменклатуры = 2 И Результат.Номенклатура=Неопределено Тогда 
			Результат.Вставить("НеЗагружать", Истина);
		Иначе                                         
			Если ЗначениеЗаполнено(ДанныеНоменклатуры) и ЗначениеЗаполнено(ДанныеНоменклатуры.Характеристика) Тогда
				Результат.Вставить("ХарактеристикаНоменклатуры", ДанныеНоменклатуры.Характеристика);
			КонецЕсли;
		КонецЕсли;	
	КонецЕсли;
	
	Если Результат.Номенклатура = Неопределено Тогда
		Если РежимНоменклатуры = 1 Тогда
			НоменклатураНов = ПараметрыЗаполнения.фрмСозданияНоменклатуры.СоздатьНоменклатуруПоДаннымПоставщика(Кэш,СтрТабл,СтруктураФайла, ДопПараметры);
			Если Не НоменклатураНов = Неопределено Тогда
				НазваниеНоменклатуры = Неопределено;
				Идентификатор = Неопределено;
				КодПокупателя = Неопределено;
				Если Не СтрТабл.Свойство("Название", НазваниеНоменклатуры) Тогда
					НазваниеНоменклатуры = "";
				КонецЕсли;
				Если Не СтрТабл.Свойство("Идентификатор", Идентификатор) Тогда
					Идентификатор = "";
				КонецЕсли;
				Если Не СтрТабл.Свойство("КодПокупателя", КодПокупателя) Тогда
					КодПокупателя = "";
				КонецЕсли;
				ДанныеНоменклатуры = Новый Структура("Название,Идентификатор,КодПокупателя,Номенклатура,Характеристика",НазваниеНоменклатуры,Идентификатор,КодПокупателя,НоменклатураНов,"");
				//Записываем соответствие
				фрм = Кэш.ГлавноеОкно.сбисНайтиФормуФункции("УстановитьСоответствиеНоменклатуры",Кэш.ФормаРаботыСНоменклатурой,"", Кэш);
				фрм.УстановитьСоответствиеНоменклатуры(СтрКонтрагента, ДанныеНоменклатуры, Кэш.Парам.КаталогНастроек, Кэш.Ини);
				
				Результат.Номенклатура = НоменклатураНов;
				Результат.Новый = Истина;			
			Иначе
				//ПараметрыЗаполнения.РежимНоменклатуры = 1;
				Результат.Вставить("ТекстОшибки", ПараметрыЗаполнения.СтрокаДетализации.Состояние);
				Отказ = Истина;//Не переключаем режим номенклатуры, а даём понять, что с номенклатурой что-то не так. Тогда вложение мы не обрабатываем и добавляем ошибку.
			КонецЕсли;
		ИначеЕсли РежимНоменклатуры = 0 Тогда
			Результат.Вставить("ТекстОшибки", "Не вся номенклатура сопоставлена." + ?(Не ПараметрыРезультат.ФормаВызова="ФормаПросмотрДокумента", " Для сопоставления откройте карточку документа.", ""));
			Отказ = Истина;
		КонецЕсли;
	КонецЕсли;
	Возврат Результат;	
	
КонецФункции

&НаКлиенте
Функция СоздатьНоменклатуруПоДаннымПоставщика(Кэш, СтрТабл, СтруктураФайла, ДопПараметры = Неопределено) Экспорт  	// сбисНикифоров  Функция создает Карточку номенклатуры по данным из файла
	//Проверяем вызов: если есть необходимость заполнения детализции, то формируем структуру ответа с детальным описанием обработчки карточки.
	Результат = Новый Структура("Название, Ссылка, Тип, Состояние, Сообщение, Ошибки", ?(СтрТабл.Свойство("Название"), СтрТабл.Название, ""), Неопределено, Неопределено,"", "", Ложь);
	ОшибкаСостояние = "Ошибка автоматического сопоставления/создания номенклатуры.";
	ОшибкаСообщение = "";
	//ОшибкаСообщение = "Автоматическое создание номенклатуры при загрузке не поддерживается для Вашей конфигурации.";
	ДанныеДетализации = РезультатДействия_ИзвлечьВременныеДанные(Кэш);
	//1189546150
	Если НЕ ДопПараметры = Неопределено
		И ДопПараметры.Свойство("СтруктураИниФайла") Тогда
		СтруктураИниФайла = ДопПараметры.СтруктураИниФайла;
	Иначе
		СтруктураИниФайла = Новый Структура;
	КонецЕсли;
	
	ИниКонфигурация = МодульОбъектаКлиент().ИниПоПараметрам("Конфигурация");
	Если ИниКонфигурация.Свойство("Номенклатура") Тогда  
		
		//Опция автоматического создания номенклатуры. Либо не указано, либо явно запрещено.
		СоставОграниченийТипов	= ТипыСправочниковНоменклатуры(СтруктураИниФайла);
		Результат.Тип			= ОпределитьИмяТипаОбъекта(СоставОграниченийТипов[0]); 	
		СправочникНоменклатура	= Результат.Тип;
		
	Иначе
		Если ДанныеДетализации.ЗаполнитьДетализацию Тогда
			ДанныеДетализации.Отказ = Истина;
			ДанныеДетализации.СтрокаДетализации.Состояние = ОшибкаСостояние;
			ДанныеДетализации.СтрокаДетализации.Сообщение = ОшибкаСообщение;
		КонецЕсли;
		Возврат Неопределено;
	КонецЕсли;
	
	Результат.Ссылка = сбисНайтиНоменклатуруПоНаименованию(СправочникНоменклатура, ?(СтрТабл.Свойство("Название"), СтрТабл.Название, ""));	//Пытаемся найти уже имеющуюся в базе по наименованию
	Если ЗначениеЗаполнено(Результат.Ссылка) Тогда
		Если ДанныеДетализации.ЗаполнитьДетализацию Тогда
			Результат.Состояние = "Найден.";
			Результат.Сообщение = "Для позиции " + Результат.Название + " найдена карточка номенклатуры с таким же названием.";
			РезультатДействия_ДобавитьВРасшифровку(Кэш, "ЗагрузкаСправочника", ДанныеДетализации.СтрокаДетализации, Результат);
		КонецЕсли;
		Возврат Результат.Ссылка;             										//Если находим то возвращаем уже существующую карточку
	КонецЕсли;
	
	//Иначе создаем новый элемент справочника
	СтруктураСправочника = Новый Структура();               		//Создаем структуру, где ключ - название реквизита справочника, а значение - значение из файла
	ЗаполнитьСтруктуруЭлементаСправочника(Кэш,СтрТабл,СтруктураФайла,СтруктураСправочника); //Заполняем ее
	Если ЗначениеЗаполнено(СтруктураСправочника) Тогда
		РезультатСоздания = СоздатьНоменклатуруИзСтруктуры(СправочникНоменклатура, СтруктураСправочника, ДанныеДетализации.Отказ);
	Иначе
		ДанныеДетализации.Отказ = Истина;
		РезультатСоздания = МодульОбъектаКлиент().НовыйСбисИсключение(762, "РаботаСДокументами1С.СоздатьНоменклатуруПоДаннымПоставщика",,,"Автоматическое создание номенклатуры при загрузке не поддерживается для Вашей конфигурации");
	КонецЕсли;
	Если ДанныеДетализации.Отказ Тогда
		Если ДанныеДетализации.ЗаполнитьДетализацию Тогда
			//Если не удаётся создать карточку номенклатуры, то не поддерживаем (как было раньше)
			ДанныеДетализации.СтрокаДетализации.Состояние = ОшибкаСостояние;
			ДанныеДетализации.СтрокаДетализации.Сообщение = ОшибкаСообщение;
			Результат.Состояние = РезультатСоздания.message;
			Результат.Сообщение = РезультатСоздания.details;
			Результат.Ошибки	= Истина;
			РезультатДействия_ДобавитьВРасшифровку(Кэш, "ЗагрузкаСправочника", ДанныеДетализации.СтрокаДетализации, Результат);
		Иначе
			Сообщить(РезультатСоздания.details);
		КонецЕсли;
		Возврат Неопределено;
	Иначе
		Если ДанныеДетализации.ЗаполнитьДетализацию Тогда
			Результат.Состояние = "Создан.";
			Результат.Сообщение = "Создана карточка номенклатуры " + РезультатСоздания;
			Результат.Ссылка	= РезультатСоздания;
			РезультатДействия_ДобавитьВРасшифровку(Кэш, "ЗагрузкаСправочника", ДанныеДетализации.СтрокаДетализации, Результат);
		КонецЕсли;
		Возврат РезультатСоздания;                                  	//Возвращаем ее
	КонецЕсли;
КонецФункции

&НаСервереБезКонтекста
Функция сбисНайтиНоменклатуруПоНаименованию(СправочникНоменклатура, Название)
	Запрос = Новый Запрос("ВЫБРАТЬ Ссылка Из Справочник."+СправочникНоменклатура+" ГДЕ Наименование = &Наим и Не ЭтоГруппа");
	Запрос.УстановитьПараметр("Наим", Название);
	Рез = Запрос.Выполнить().Выбрать();
	Если Рез.Следующий() Тогда
		Возврат Рез.Ссылка;		
	КонецЕсли;
КонецФункции

&НаСервереБезКонтекста
Функция СоздатьНоменклатуруИзСтруктуры(СправочникНоменклатура, СтруктураСправочника, Отказ)
	// Функция заполняет реквизиты документа 1С из одноименных полей структуры	
	Номенклатура = Справочники[СправочникНоменклатура].СоздатьЭлемент();
	Для Каждого Элемент Из СтруктураСправочника Цикл
		Если ТипЗнч(Элемент.Значение)<>Тип("Массив") Тогда
			Номенклатура[Элемент.Ключ] = Элемент.Значение;
		Иначе
			Номенклатура[Элемент.Ключ].Очистить();
			Для Каждого Строка Из Элемент.Значение Цикл
				НоваяСтрока = Номенклатура[Элемент.Ключ].Добавить();
				ЗаполнитьЗначенияСвойств(НоваяСтрока, Строка);
			КонецЦикла;
		КонецЕсли;
	КонецЦикла;
	Попытка
		Номенклатура.Записать();    								//Если карточка нормально записалась
	Исключение
		Отказ = Истина;
		Возврат Новый Структура("code, message, details", 100, "Ошибка записи номенклатуры.", "При записи карточки номенклатуры " + Номенклатура.Наименование + " возникла ошибка: " + ОписаниеОшибки());
	КонецПопытки;
	Возврат Номенклатура.Ссылка;
КонецФункции

// Функция возвращает список типов справочников для сопоставления номенклатуры
//
// Параметры:
//  СтруктураИниФайла - Структура - ини файл, разложенный в структуру значений  
// 
// Возвращаемое значение:
//  Массив - список типов справочников
//
&НаКлиенте
Функция ТипыСправочниковНоменклатуры(СтруктураИниФайла) Экспорт

	ВидыСправочниковНоменклатуры = МестныйКэш.ОбщиеФункции.РассчитатьЗначение("ВидыСправочниковНоменклатуры",СтруктураИниФайла, МестныйКэш); 
	СоставОграниченийТипов = Новый Массив;
	Если ВидыСправочниковНоменклатуры = Неопределено Тогда
		Если МестныйКэш.Ини.Конфигурация.Свойство("Номенклатура") Тогда
			ИмяСправочникаНоменклатуры = МестныйКэш.ОбщиеФункции.сбисСообщитьИмяРеквизита(МестныйКэш.Ини.Конфигурация.Номенклатура.Значение);
			ТипСправочникаНоменклатуры = "СправочникСсылка."+ИмяСправочникаНоменклатуры;
		Иначе
			ТипСправочникаНоменклатуры = "СправочникСсылка.Номенклатура";
		КонецЕсли;   
		СоставОграниченийТипов.Добавить(Тип(ТипСправочникаНоменклатуры));
	Иначе
		СписокИменСправочниковНоменклатуры = МестныйКэш.ОбщиеФункции.РазбитьСтрокуВМассивНаКлиенте(ВидыСправочниковНоменклатуры, ",");
		Для Каждого ТипСправочникаНоменклатуры Из СписокИменСправочниковНоменклатуры Цикл
			СоставОграниченийТипов.Добавить(Тип(ТипСправочникаНоменклатуры));
		КонецЦикла; 
	КонецЕсли;
	
	Возврат СоставОграниченийТипов;  
	
КонецФункции

// Функция возвращает тип справочника единиц для сопоставления номенклатуры по метаданным конфигурации
//
// 
// Возвращаемое значение:
//  Строка - тип справочника единиц
//
&НаСервереБезКонтекста
Функция ТипСправочникаЕдиницПоМетаданным() Экспорт

	Если НЕ Метаданные.Справочники.Найти("УпаковкиЕдиницыИзмерения") = Неопределено Тогда  // ЕРП, КА2, УТ11
		
		ТипСправочникаЕдиниц	= "УпаковкиЕдиницыИзмерения";
		
	ИначеЕсли НЕ Метаданные.Справочники.Найти("ЕдиницыИзмерения") = Неопределено Тогда // УПП, УТ10, УНФ, ШТРИХ
		
		ТипСправочникаЕдиниц	= "ЕдиницыИзмерения"; 

	Иначе	
		
		ТипСправочникаЕдиниц	= "КлассификаторЕдиницИзмерения"; // БП
		
	КонецЕсли;		

	
	Возврат ТипСправочникаЕдиниц;  
	
КонецФункции

&НаКлиенте
Процедура АвтоматическоеСопоставлениеНоменклатур(МестныйКэш, ОбогащенныеДанныеНоменклатурыДляСопоставления) Экспорт 
		
	// Поиск несопоставленной номенклатуры
	НесопоставленнаяНоменклатура = Новый Соответствие;
	КоличествоНеСопоставленнойНоменклатуры = 0;                    
	Счетчик = 0; 
	
	Пока Счетчик < ОбогащенныеДанныеНоменклатурыДляСопоставления.Количество() Цикл
		
		Если НЕ ОбогащенныеДанныеНоменклатурыДляСопоставления[Счетчик].Номенклатура1С.Количество() Тогда
			    НесопоставленнаяНоменклатура.Вставить(Счетчик, ОбогащенныеДанныеНоменклатурыДляСопоставления[Счетчик]);
				Счетчик = Счетчик + 1;
				Продолжить;
		КонецЕсли; 
			
		Номенклатуры1С = ОбогащенныеДанныеНоменклатурыДляСопоставления[Счетчик].Номенклатура1С;			
		
		Для Каждого Номенклатура1С Из Номенклатуры1С Цикл
			
			Если НЕ ЗначениеЗаполнено(Номенклатура1С.Ключ) Тогда
				
				НесопоставленнаяНоменклатура.Вставить(ОбогащенныеДанныеНоменклатурыДляСопоставления[Счетчик].НоменклатураСБИС.Наименование,
													  ОбогащенныеДанныеНоменклатурыДляСопоставления[Счетчик]);
				Счетчик = Счетчик + 1;									  
													  
			КонецЕсли;

			Прервать;
			
		КонецЦикла;
		
		Счетчик = Счетчик + 1;		
		
	КонецЦикла;
	
	// Вся номенклатура сопоставлена, сворачиваем лавочку
	Если НЕ НесопоставленнаяНоменклатура.Количество() Тогда
		Возврат;
	КонецЕсли;
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	// Заполнение списка реквизитов поиска и искомых значений 
	ОбогащенныеЗначенияПоиска = ОбогащенныеЗначенияПоиска(НесопоставленнаяНоменклатура);
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	Если МестныйКэш.Ини.Конфигурация.Свойство("Номенклатура") Тогда
		ИмяСправочникаНоменклатуры = СокрЛП(Сред(МестныйКэш.Ини.Конфигурация.Номенклатура.Значение, Найти(МестныйКэш.Ини.Конфигурация.Номенклатура.Значение, ".") + 1));
	Иначе
		ИмяСправочникаНоменклатуры = "Номенклатура";
	КонецЕсли;
	
	
	// Запрос номенклатуры
	КоличествоПолейСопоставления = ОбогащенныеЗначенияПоиска.Количество();
	
	СчетчикКоличестваВыполненныхЗапросов = 0;  
	
	ДанныеДляПоиска = Новый Структура;
	// Установка параметров и выполнение запроса. 
	Пока НесопоставленнаяНоменклатура.Количество() И СчетчикКоличестваВыполненныхЗапросов < КоличествоПолейСопоставления Цикл
		
		Для Каждого ВходящиеДанные Из ОбогащенныеЗначенияПоиска Цикл
			ПараметрПоиска = ВходящиеДанные.Ключ;
			СписокЗначенийПараметраПоиска = ВходящиеДанные.Значение;
			Прервать;
		КонецЦикла; 
		
		ДанныеДляПоиска.Очистить();
		ДанныеДляПоиска.Вставить("ПараметрПоиска", ПараметрПоиска);
		ДанныеДляПоиска.Вставить("СписокЗначенийПараметраПоиска", СписокЗначенийПараметраПоиска);
		
		ЗапроситьИСопоставитьНоменклатуруПоДанным1С(НесопоставленнаяНоменклатура, ДанныеДляПоиска, ОбогащенныеДанныеНоменклатурыДляСопоставления, ИмяСправочникаНоменклатуры);
				
		СчетчикКоличестваВыполненныхЗапросов = СчетчикКоличестваВыполненныхЗапросов + 1;
	КонецЦикла;
	
КонецПроцедуры

&НаСервере
Процедура ЗапроситьИСопоставитьНоменклатуруПоДанным1С(НесопоставленнаяНоменклатура, ДанныеДляПоиска, ОбогащенныеДанныеНоменклатурыДляСопоставления, ИмяСправочникаНоменклатуры)
	
	Если НЕ ДанныеДляПоиска.ПараметрПоиска = "Артикул" Тогда
		Возврат;
	КонецЕсли;
	
	// Формирование скелета запроса
	Запрос = Новый Запрос; 
	Запрос.Текст = "ВЫБРАТЬ
	|	Номенклатура.Ссылка КАК Номенклатура1С,
	|	Номенклатура.%ПараметрПоиска% КАК ЗначениеПараметраСопоставления
	|ИЗ
	|	Справочник.%СПРНоменклатура% КАК Номенклатура
	|ГДЕ
	|	Номенклатура.%ПараметрПоиска% В (&СписокЗначенийПараметраПоиска)";
	
	Запрос.Текст = СтрЗаменить(Запрос.Текст, "%СПРНоменклатура%", ИмяСправочникаНоменклатуры);
		
	Запрос.Текст = СтрЗаменить(Запрос.Текст, "%ПараметрПоиска%", ДанныеДляПоиска.ПараметрПоиска);
	Запрос.УстановитьПараметр("СписокЗначенийПараметраПоиска", ДанныеДляПоиска.СписокЗначенийПараметраПоиска);
	
	НайденнаяНоменклатура = Запрос.Выполнить().Выгрузить();
	
	// Если нашли номенклатуру - сразу сопоставим и удалим из списка несопоставленных найденный элемент
	Если НайденнаяНоменклатура.Количество() Тогда
		СопоставитьНоменклатуруИПересмотретьНесопоставленныеПозиции(НесопоставленнаяНоменклатура, ОбогащенныеДанныеНоменклатурыДляСопоставления, НайденнаяНоменклатура, ДанныеДляПоиска.ПараметрПоиска); 
	КонецЕсли;
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	//НайденнаяНоменклатураМассив = МодульОбъектаСервер().ТаблицаЗначенийВМассив(НайденнаяНоменклатура);
	//Возврат НайденнаяНоменклатураМассив;
	
КонецПроцедуры

&НаКлиенте
Функция ОбогащенныеЗначенияПоиска(НесопоставленнаяНоменклатура)
	
	ПорядокАвтоматическогоСопоставленияСтрока = МодульОбъектаКлиент().ПолучитьЗначениеПараметраСБИС("ПорядокАвтоматическогоСопоставления"); 
	Если ПорядокАвтоматическогоСопоставленияСтрока = Неопределено Тогда
		
		ПорядокАвтоматическогоСопоставления = Новый Массив;
		ПорядокАвтоматическогоСопоставления.Добавить("Артикул");
		ПорядокАвтоматическогоСопоставления.Добавить("КодПоставщика");
		ПорядокАвтоматическогоСопоставления.Добавить("КодПокупателя");
		ПорядокАвтоматическогоСопоставления.Добавить("GTIN");
		ПорядокАвтоматическогоСопоставления.Добавить("Идентификатор");
		
	Иначе 
		Разделитель = ",";
		ПорядокАвтоматическогоСопоставления = МодульОбъектаКлиент().СбисРазложитьСтрокуВМассивПодстрок(ПорядокАвтоматическогоСопоставленияСтрока, Разделитель); 
	КонецЕсли;
	
	ОбогащенныеЗначенияПоиска = Новый Структура;  
	Значения = Новый Массив;
	
	Для Каждого РеквизитСопоставления Из ПорядокАвтоматическогоСопоставления Цикл
		
		Значения.Очистить();
		
		Для Каждого ДанныеНоменклатуры Из НесопоставленнаяНоменклатура Цикл
			
			Если ДанныеНоменклатуры.Значение.НоменклатураСБИС.Свойство("ТипКода") 
				И ДанныеНоменклатуры.Значение.НоменклатураСБИС.ТипКода = РеквизитСопоставления Тогда
				
				Значения.Добавить(ДанныеНоменклатуры.Значение.НоменклатураСБИС.Код);
            	Продолжить;
				
			КонецЕсли;
			
			Если НЕ ДанныеНоменклатуры.Значение.НоменклатураСБИС.Свойство(РеквизитСопоставления) Тогда
				Продолжить;
			ИначеЕсли ЗначениеЗаполнено(ДанныеНоменклатуры.Значение.НоменклатураСБИС[РеквизитСопоставления]) Тогда
				Значения.Добавить(ДанныеНоменклатуры.Значение.НоменклатураСБИС[РеквизитСопоставления]);
			Иначе
				Продолжить;
			КонецЕсли;	
			
		КонецЦикла;
		
		Если Значения.Количество() Тогда  
			ЗначенияПослеСвертки = СвернутьМассив(Значения);
			ОбогащенныеЗначенияПоиска.Вставить(РеквизитСопоставления, ЗначенияПослеСвертки);
		КонецЕсли;
		
	КонецЦикла;                       
	
	Возврат ОбогащенныеЗначенияПоиска; 
КонецФункции

&НаСервере
Функция СвернутьМассив(МассивДляСворачивания)

	СвернутыйМассив = МодульОбъектаСервер().СбисСвернутьМассив(МассивДляСворачивания);
	Возврат СвернутыйМассив;
	
КонецФункции

&НаСервере
Процедура СопоставитьНоменклатуруИПересмотретьНесопоставленныеПозиции(НесопоставленнаяНоменклатура, ОбогащенныеДанныеНоменклатур, НайденнаяНоменклатура, ПараметрПоиска)
	
	//НайденнаяНоменклатура.Свернуть("ЗначениеПараметраСопоставления", "Номенклатура1С");		
	
	//Формируем описание класса Номенклатура1С, заполняем данными, запихиваем в класс данных сопоставления	
	          
	ПривестиНоменклатуруККлассуСопоставлений(НесопоставленнаяНоменклатура, НайденнаяНоменклатура, ПараметрПоиска);
	
	ЗаполнитьНоменклатуруДляЗагрузкиДокумента(НесопоставленнаяНоменклатура, ОбогащенныеДанныеНоменклатур);
	
КонецПроцедуры

&НаСервере
Процедура ПривестиНоменклатуруККлассуСопоставлений(НесопоставленнаяНоменклатура, НайденнаяНоменклатура, ПараметрПоиска)
	
	ОбогащенныеКлассыНоменклатуры1С = Новый ТаблицаЗначений;
	ОбогащенныеКлассыНоменклатуры1С.Колонки.Добавить(ПараметрПоиска);
	
	
	Для Каждого Номенклатура1С Из НайденнаяНоменклатура Цикл
		ОписаниеНоменклатуры1С = МодульОбъектаСервер().НовыйОписаниеНоменклатуры1ССервер();
		
		СопоставлениеДляЕдиницы = Новый Структура("Владелец, Единица", Номенклатура1С.Номенклатура1С, Неопределено); 
		КлючПоиска = "Единица";
		НайденнаяЕдиница = МодульОбъектаСервер().СопоставлениеДляЕдиницыСервер_Получить(СопоставлениеДляЕдиницы, КлючПоиска);
		
		Если ЗначениеЗаполнено(НайденнаяЕдиница) Тогда
			
			ЕдиницаОбъект = НайденнаяЕдиница.ПолучитьОбъект();
			Единица = Новый Структура("Код, Наименование, Владелец");
			
			Единица.Код = ЕдиницаОбъект.Код;
			Единица.Наименование = ЕдиницаОбъект.Наименование;
			Единица.Владелец = ЕдиницаОбъект.Владелец;
			
			СтруктураЕдиницы = Новый Структура("_класс, Коэффициент, ОКЕИ, Название, Ссылка, Владелец", "СопоставлениеДляЕдиницы", 1, Единица.Код, Единица.Наименование, НайденнаяЕдиница, Единица.Владелец);
			
			ОписаниеНоменклатуры1С.Вставить(НайденнаяЕдиница, СтруктураЕдиницы);
			
		КонецЕсли;
		
		ОбогащенныеКлассыНоменклатуры1С.Добавить();
		ОбогащенныеКлассыНоменклатуры1С.Вставить(Номенклатура1С.Номенклатура1С, ОписаниеНоменклатуры1С);
		
		МодульОбъектаСервер().ОписаниеНоменклатуры1ССервер_Заполнить(НесопоставленнаяНоменклатура, ОписаниеНоменклатуры1С);

	КонецЦикла;
	
	ПараметрыОтбора = Новый Структура();
	Для Каждого СтрокаДанныхНоменклатуры Из НесопоставленнаяНоменклатура Цикл
		
		Если НЕ СтрокаДанныхНоменклатуры.НоменклатураСБИС.Свойство(ПараметрПоиска) Тогда
			Продолжить;
		ИначеЕсли ЗначениеЗаполнено(СтрокаДанныхНоменклатуры.НоменклатураСБИС[ПараметрПоиска]) Тогда
			
			ПараметрыОтбора.Вставить(ПараметрПоиска, СтрокаДанныхНоменклатуры.НоменклатураСБИС[ПараметрПоиска]); 
			СтрокиСИскомойНоменклатурой = НайденнаяНоменклатура.НайтиСтроки(ПараметрыОтбора);
			ПараметрыОтбора.Очистить();
			
			Для Каждого СтрокаНоменклатуры ИЗ СтрокиСИскомойНоменклатурой Цикл
				СтрокаДанныхНоменклатуры.Номенклатура1С.Вставить(СтрокаНоменклатуры.Номенклатура1С, СтрокаНоменклатуры.ОписаниеНоменклатуры1С);
			КонецЦикла;
			
			СтрокаДанныхНоменклатуры.Номенклатура1С.Вставить(Номенклатура1С.Ссылка, ОписаниеНоменклатуры1С);
		Иначе
			Продолжить;
		КонецЕсли;
		
	КонецЦикла;
КонецПроцедуры 

&НаСервере
Процедура ЗаполнитьНоменклатуруДляЗагрузкиДокумента(НесопоставленнаяНоменклатура, ОбогащенныеДанныеНоменклатур)
	
	// Внесём данные в массив для загрузки и удалим сопоставленные данные, чтобы они снова не пошли в запрос
	Для Каждого НоменклатураДляСопоставления Из НесопоставленнаяНоменклатура Цикл
		
		Если НесопоставленнаяНоменклатура.ГотовоКСопоставлению Тогда
			ОбогащенныеДанныеНоменклатур[НоменклатураДляСопоставления.Ключ].Номенклатура1С = НоменклатураДляСопоставления.Номенклатура1С;
			НесопоставленнаяНоменклатура.Удалить(НоменклатураДляСопоставления.Ключ);
		КонецЕсли;
	
	КонецЦикла;

КонецПроцедуры

