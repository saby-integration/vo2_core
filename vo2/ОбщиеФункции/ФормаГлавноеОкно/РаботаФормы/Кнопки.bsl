
&НаКлиенте
Процедура ВыйтиНажатие(Команда)
	сбисВыйти();
КонецПроцедуры

// Процедура запускает загрузку документов по отмеченным записям	
&НаКлиенте
Процедура ЗагрузитьВ1С(Команда)
	
	РезультатЗагрузки = Кэш.ОбщиеФункции.РезультатДействия_Получить(Кэш,Новый Структура("ПредставлениеОперации", "ЗагрузкаДокумента"),Истина);
	СписокОтмеченныхДокументов = ТаблДокПолучитьВыбранныеСтроки();
	Всего = СписокОтмеченныхДокументов.Количество();
	ОбновитьКонтент = Ложь;
	Если Всего>0 Тогда
		фрм = сбисНайтиФормуФункции("ЗагрузитьДокументыВ1С","Документ_Шаблон", "", Кэш);
		РезультатЗагрузки = фрм.ЗагрузитьДокументыВ1С(Кэш, СписокОтмеченныхДокументов, Новый Структура("РежимНоменклатуры, РежимДокументов", Кэш.Парам.СпособЗагрузки, Кэш.Парам.РежимЗагрузки));
		Если ТипЗнч(РезультатЗагрузки) = Тип("Структура") Тогда
			ПараметрыСообщить = Новый Структура("СообщитьНеВыполнено", Ложь);
			Кэш.ОбщиеФункции.РезультатДействия_СообщитьРезультат(РезультатЗагрузки, ПараметрыСообщить);
			
			Сообщить("Загружено комплектов "+строка(РезультатЗагрузки.Всего.Выполнено)+" из "+строка(Всего));
			ОбновитьКонтент = Булево(РезультатЗагрузки.Всего.Выполнено);
		Иначе//Если пришли не структура, то ЗагрузитьДокументыВ1С вынесена. Поддержка старых функций
			ОбновитьКонтент = РезультатЗагрузки;
		КонецЕсли;
	Иначе 
		Сообщить("Не выбран ни один документ");
	КонецЕсли;
	Кэш.Удалить("РезультатДействия");
	Если ОбновитьКонтент Тогда
		ОбновитьКонтент();
	КонецЕсли;

КонецПроцедуры

// Открывает помощь на sbis.ru
&НаКлиенте
Процедура НадписьНужнаПомощьНажатие(Команда)
	ЗапуститьПриложение("https://sbis.ru/help/integration/1C_set/modul");
КонецПроцедуры

//Нажатие на кнопку обновления обработки
&НаКлиенте
Процедура ОбновитьОбработкуОбщая(Команда)	
	сбисПроверитьНаличиеОбновлений(Новый Структура("Режим, ТекстДиалога", 
													"Ручной",
													"Обновление <ВерсияНаСервере> готово к установке. Продолжить?"));	
КонецПроцедуры

//Процедура открывает форму просмотра документа	
&НаКлиенте
Процедура ОткрытьДокумент(Команда) 
	Перем СбисИдДокумента;
	
	ТекущаяСтрока = Кэш.ТаблДок.ТекущиеДанные;
	ТекущийРаздел = Кэш.Разделы["р"+Кэш.Текущий.Раздел]; 
	
	//1189641556  
	Если Кэш.Парам.СоздаватьЧерновик И ТекущийРаздел = "Продажа" Тогда
		ПараметрыПакетаСБИС	= Кэш.ОбщиеФункции.ИдентификаторСБИСПоДокументу(Кэш, ТекущаяСтрока.СоставПакета[0].Значение);  
		Если ПараметрыПакетаСБИС.Свойство("ИдДокумента",СбисИдДокумента)
			И СбисИдДокумента = "" Тогда
			фрм = сбисНайтиФормуФункции("ОткрытьДокументОнлайнПоПакету","ФормаГлавноеОкно","",Кэш);
			фрм.ОткрытьДокументОнлайнПоПакету(ТекущаяСтрока.СоставПакета[0].Значение, Кэш);	
		КонецЕсли;
	КонецЕсли;
	
	фрм = сбисНайтиФормуФункции("ПоказатьДокумент","Раздел_"+ТекущийРаздел+"_"+Кэш.Текущий.ТипДок,"Раздел_"+ТекущийРаздел+"_Шаблон", Кэш);	
	фрм.ПоказатьДокумент(Кэш, ТекущаяСтрока);
КонецПроцедуры

//Открывает документы 1С по текущей строке таблицы документов	
&НаКлиенте
Процедура ОткрытьДокумент1С(Кнопка) Экспорт
	ТекущаяСтрока		= Кэш.ТаблДок.ТекущиеДанные;
	сбисДанныеОткрыть	= Новый Структура("Документ1С, Документы1С");
	сбисСписокОткрыть	= Новый Массив;
	ЗаполнитьЗначенияСвойств(сбисДанныеОткрыть, ТекущаяСтрока);
	Если ЗначениеЗаполнено(сбисДанныеОткрыть.Документ1С) Тогда
		сбисСписокОткрыть.Добавить(сбисДанныеОткрыть.Документ1С);
	КонецЕсли;
	Если ЗначениеЗаполнено(сбисДанныеОткрыть.Документы1С) Тогда
		Для Каждого СтрокаДокумент1С Из сбисДанныеОткрыть.Документы1С Цикл
			Если Не ЗначениеЗаполнено(СтрокаДокумент1С.Значение) Тогда
				Продолжить;
			КонецЕсли;
			сбисСписокОткрыть.Добавить(СтрокаДокумент1С.Значение);
		КонецЦикла;
	КонецЕсли;
	Если Не сбисСписокОткрыть.Количество() Тогда
		Сообщить("Нет связанных документов 1С");
		Возврат;
	КонецЕсли;
	Для Каждого сбисДокументОткрыть Из сбисСписокОткрыть Цикл
		Попытка
			#Если ТолстыйКлиентОбычноеПриложение Тогда
				ОткрытьЗначение(сбисДокументОткрыть);
			#Иначе
				ПоказатьЗначение(,сбисДокументОткрыть);
			#КонецЕсли
		Исключение
			Сообщить(ИнформацияОбОшибке().Описание);
		КонецПопытки;
	КонецЦикла;
КонецПроцедуры

//Процедура открывает карточку документа на сайте online.sbis.ru	
&НаКлиенте
Процедура ОткрытьДокументОнлайн(Команда)
	ТекущаяСтрока = Кэш.ТаблДок.ТекущиеДанные;
	ДопПараметры = Новый Структура("ОткрытьОнлайн",Истина);
	Если ТекущаяСтрока<>Неопределено Тогда
		фрм = сбисНайтиФормуФункции("ОткрытьДокументОнлайнПоПакету","ФормаГлавноеОкно","",Кэш);
		фрм.ОткрытьДокументОнлайнПоПакету(ТекущаяСтрока.СоставПакета[0].Значение, Кэш, ДопПараметры);
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура СравнитьДокументы(Команда)

	Обновить = Ложь;
	СписокОтмеченныхДокументов = Новый СписокЗначений;
	Для Каждого СтрокаДанныеФормы Из ТаблДокПолучитьВыбранныеСтроки() Цикл
		ДанныеСтроки = Новый Структура("СоставПакета, Статус");
		ЗаполнитьЗначенияСвойств(ДанныеСтроки, СтрокаДанныеФормы.Значение);
		СписокОтмеченныхДокументов.Добавить(ДанныеСтроки);
	КонецЦикла;	
	Если СписокОтмеченныхДокументов.Количество() Тогда

		ПараметрыПоказать	= Новый Структура("СписокДокументов, Режим, Владелец, Кэш", СписокОтмеченныхДокументов, "Сравнение", ЭтаФорма, Кэш);
		фрм					= сбисПолучитьФорму("ФормаСопоставитьСДокументами1С");
		фрм.ОписаниеОповещенияОЗакрытии = МодульОбъектаКлиент().НовыйСбисОписаниеОповещения("СравнитьДокументы_Завершение", ЭтаФорма);
		фрм.Показать(ПараметрыПоказать);

	Иначе 
		Сообщить("Не выбран ни один документ");
	КонецЕсли;

КонецПроцедуры

&НаКлиенте
Процедура СравнитьДокументы_Завершение(РезультатЗавершение, ДопПараметры=Неопределено) Экспорт
	
	Если РезультатЗавершение = Истина Тогда
		Обновить = Истина;
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура СопоставитьДокументы(Команда)

	Обновить = Ложь;
	СписокОтмеченныхДокументов = Новый СписокЗначений;
	Для Каждого СтрокаДанныеФормы Из ТаблДокПолучитьВыбранныеСтроки() Цикл
		ДанныеСтроки = Новый Структура("СоставПакета, Статус");
		ЗаполнитьЗначенияСвойств(ДанныеСтроки, СтрокаДанныеФормы.Значение);
		СписокОтмеченныхДокументов.Добавить(ДанныеСтроки);
	КонецЦикла;	
	Если СписокОтмеченныхДокументов.Количество() Тогда

		ПараметрыПоказать	= Новый Структура("СписокДокументов, Режим, Кэш", СписокОтмеченныхДокументов, "Сопоставление", Кэш);
		фрм					= сбисПолучитьФорму("ФормаСопоставитьСДокументами1С");
		фрм.ОписаниеОповещенияОЗакрытии = МодульОбъектаКлиент().НовыйСбисОписаниеОповещения("СравнитьДокументы_Завершение", ЭтаФорма);
		фрм.Показать(ПараметрыПоказать);

	Иначе 
		Сообщить("Не выбран ни один документ");
	КонецЕсли;

КонецПроцедуры

&НаКлиенте
Процедура СопоставитьДокументы_Завершение(Обновить, ДопПараметры) Экспорт

	Если Обновить = Истина Тогда
		ОбновитьКонтент();
	КонецЕсли;
	
КонецПроцедуры

// Процедура считает суммы документов сбис и сопоставленных им документов 1С	
&НаКлиенте
Процедура ПросуммироватьВыделенные(Кнопка)
	
	СписокОтмеченныхДокументов = ТаблДокПолучитьВыбранныеСтроки();
	СуммыПоВложениям = Новый Структура;
	Суммы1С = Новый Структура;
	Если Не СписокОтмеченныхДокументов.Количество() Тогда
		Сообщить("Не выбран ни один документ");
		Возврат;
	КонецЕсли;	
	
	Для Каждого Строка Из СписокОтмеченныхДокументов Цикл
		СоставПакета = Строка.Значение.СоставПакета[0].Значение;
		Если Не СоставПакета.Свойство("Вложение") Тогда
			Продолжить;
		КонецЕсли;
		Для Каждого Вложение Из СоставПакета.Вложение Цикл
			Если Не Вложение.Свойство("Служебный") или Вложение.Служебный = "Нет" Тогда
				Если ЗначениеЗаполнено(Вложение.Тип) Тогда
					Если Не СуммыПоВложениям.Свойство(Вложение.Тип) Тогда
						Название = Лев(Вложение.Название, Найти(Вложение.Название,"№")-2);
						Если Не ЗначениеЗаполнено(Название) Тогда
							Название = Вложение.Тип;	
						КонецЕсли;
						СуммыПоВложениям.Вставить(Вложение.Тип, Новый Структура("Название,Сумма",Название,0));
					КонецЕсли;
					Попытка
						Сумма = Число(Вложение.Сумма);
					Исключение
						Сумма=0;
					КонецПопытки;
					СуммыПоВложениям[Вложение.Тип].Сумма = СуммыПоВложениям[Вложение.Тип].Сумма+Сумма;
					Если Вложение.Свойство("Документы1С") и Вложение.Документы1С.Количество()>0 Тогда
						ИмяДок		= Кэш.ОбщиеФункции.ПолучитьРеквизитМетаданныхОбъекта(Вложение.Документы1С[0].Значение, "Имя");
						ИниЗагрузки	= МодульОбъектаКлиент().ИниПоПараметрам(Новый Структура("Тип1С, ТипИни", ИмяДок, "Загрузка"));
						Для Каждого КлючИЗначениеИни Из ИниЗагрузки Цикл
							Если	Не КлючИЗначениеИни.Значение.Свойство("мДокумент")
								Или Не КлючИЗначениеИни.Значение.мДокумент.Свойство(ИмяДок) Тогда
								Продолжить;
							КонецЕсли;
							ИниЗагрузки = КлючИЗначениеИни.Значение.мДокумент[ИмяДок];
							Прервать;
						КонецЦикла;
										
						//ИниЗагрузки = Кэш.ОбщиеФункции.сбисИниЗагрузкиПоДокументу1С(Кэш, Вложение.Документы1С[0].Значение);
						ИмяРеквизитаСуммы = Кэш.ОбщиеФункции.сбисИмяРеквизитаСуммыДокумента1С(ИниЗагрузки);
						ЗаполнитьСуммыДокументов1С(Суммы1С, Вложение.Документы1С[0].Значение, ИмяРеквизитаСуммы);	
					КонецЕсли;
				КонецЕсли;
			КонецЕсли;
		КонецЦикла;
	КонецЦикла;

	ТекстСообщения = "Сумма документов СБИС:"+Символы.ПС;
	Для Каждого Элемент Из СуммыПоВложениям Цикл
		ТекстСообщения = ТекстСообщения + Элемент.Значение.Название+": "+Элемент.Значение.Сумма+Символы.ПС;
	КонецЦикла;
	ТекстСообщения = ТекстСообщения + "   " + Символы.ПС + "Сумма документов 1С:" + Символы.ПС;
	Для Каждого Элемент Из Суммы1С Цикл
		ТекстСообщения = ТекстСообщения + Элемент.Значение.Название + ": " + Элемент.Значение.Сумма+Символы.ПС;
	КонецЦикла;
	Сообщить(ТекстСообщения);
	
КонецПроцедуры

//Процедура запускает загрузку отчетность по отмеченным записям	
&НаКлиенте
Процедура ЗагрузитьОтчетность(Команда)
	СбисОтвет = 1;
	ПараметрыКоманды = Новый Структура;
	Если	ОтметитьВсе 
		И	ЗаписейНаСтранице1С <> "все"
		И	(ФильтрСтраница <> 1 Или ФильтрЕстьЕще) Тогда // отмечены все записи на странице и есть еще страницы
		ТекстВопроса = "Загрузить отчеты только с текущей страницы или все документы списка?";
		Кнопки = Новый СписокЗначений;
		Кнопки.Добавить(1, "С текущей страницы");
		Кнопки.Добавить(2, "Все документы");
		#Если ТолстыйКлиентОбычноеПриложение Тогда
			СбисОтвет = Вопрос(ТекстВопроса, Кнопки);
		#Иначе
			ПоказатьВопрос(Новый ОписаниеОповещения("ЗагрузитьВыбранныеДокументыОтчетности", ЭтаФорма), ТекстВопроса, Кнопки);
			Возврат;
		#КонецЕсли
	КонецЕсли;
	ЗагрузитьВыбранныеДокументыОтчетности(СбисОтвет, ПараметрыКоманды);
КонецПроцедуры

&НаКлиенте
Процедура ОткрытьФормуДлительныхОпераций(Команда)
	фрм = сбисПолучитьФорму("ФормаДлительныеОперации",,,ЭтаФорма);
	фрм.Показать();
КонецПроцедуры

&НаКлиенте
Процедура ДоступнаНоваяВерсия(Команда)
	#Если ТолстыйКлиентОбычноеПриложение Тогда
		Если ЭлементыФормы.ПанельКнопкиОбновления.ТекущаяСтраница = ЭлементыФормы.ПанельКнопкиОбновления.Страницы["СтраницаПанельКнопкиОбновлениеПрошлоУспешно"] Тогда
			ТекстВопроса	= "Завершить работу в СБИС?";
			КнопкиДиалога	= РежимДиалогаВопрос.ДаНет;
			ТекстВопроса = ТекстВопроса + Символы.ПС + "Не забудьте перезапустить 1С:Предприятие для того, чтобы изменения вступили в силу.";
			Ответ	= Вопрос(ТекстВопроса,	КнопкиДиалога);
			ДоступнаНоваяВерсия_ПослеДиалога(Ответ);
			Возврат;
		КонецЕсли;			
	#Иначе
		Если Лев(сбисЭлементФормы(ЭтаФорма,"ВашаВерсияУстарела").Заголовок,25) = "Обновление прошло успешно" Тогда
			ТекстВопроса	= "Завершить работу в СБИС?";
			КнопкиДиалога	= РежимДиалогаВопрос.ДаНет;
			ПоказатьВопрос(Новый ОписаниеОповещения("ДоступнаНоваяВерсия_ПослеДиалога", ЭтаФорма),ТекстВопроса,КнопкиДиалога,,);
			Возврат;
		КонецЕсли;	
	#КонецЕсли	
	
	ЗапуститьПриложение("https://sbis.ru/help/integration/1C_set/modul/history/");
КонецПроцедуры

&НаКлиенте
Процедура ДоступнаНоваяВерсия_ПослеДиалога(Ответ, ДопПараметры = Неопределено) Экспорт
	Если Ответ = КодВозвратаДиалога.Да Тогда
		ЭтаФорма.Закрыть();
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура сбисИнформацияДляТП(Команда)
	ДиалогОткрытия = Новый ДиалогВыбораФайла(РежимДиалогаВыбораФайла.ВыборКаталога); 
	ДиалогОткрытия.МножественныйВыбор = Ложь; 
	ДиалогОткрытия.Заголовок = "Сохранить информацию для техподдержки в:"; 
	
	Если ДиалогОткрытия.Выбрать() Тогда 
		ПутьККаталогу = Кэш.ОбщиеФункции.СбисФорматКаталога(ДиалогОткрытия.Каталог, Кэш.ПараметрыСистемы.Клиент);
		Разделитель = Кэш.ОбщиеФункции.СбисФорматРазделителя(Кэш.ПараметрыСистемы.Клиент);
		ПутьККаталогу = ПутьККаталогу+Формат(ТекущаяДата(), "ДФ =гггг_ММ_дд_ЧЧ_мм_сс")+Разделитель;
		СоздатьКаталог(ПутьККаталогу);
		
		Если Кэш.Текущий.Раздел = "1" или Кэш.Текущий.Раздел = "2" или Кэш.Текущий.Раздел = "3" или Кэш.Текущий.Раздел = "4" Тогда
			СписокОтмеченныхДокументов = ТаблДокПолучитьВыбранныеСтроки();
			Если СписокОтмеченныхДокументов.Количество() = 1 Тогда
				Если Кэш.Текущий.Раздел = "3" или Кэш.Текущий.Раздел = "4" Тогда
					Кэш.ОбщиеФункции.СбисСформироватьИнформациюПоДокументам1С(Кэш, ПутьККаталогу, Разделитель, СписокОтмеченныхДокументов[0].Значение.СоставПакета); 
				ИначеЕсли Кэш.Текущий.Раздел = "1" или Кэш.Текущий.Раздел = "2" Тогда
					ТекстДок = Новый ТекстовыйДокумент;
					Кэш.ОбщиеФункции.сбисЗаписатьСтруктуруВТекстовыйДокумент(СписокОтмеченныхДокументов[0].Значение.СоставПакета[0].Значение, ТекстДок, "   ", Новый Массив);;
					ТекстДок.Записать(ПутьККаталогу + "СоставПакета.txt"); 
				КонецЕсли;
			КонецЕсли;
		КонецЕсли;
		
		Кэш.ОбщиеФункции.СбисСформироватьОбщуюИнформациюДляТП(Кэш, ПутьККаталогу);
		
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура КонтактыТП(Команда)
	ЗапуститьПриложение("https://sbis.ru/support");
КонецПроцедуры

&НаКлиенте
Процедура ОбращениеТП(Команда)
	ЗапуститьПриложение("https://online.sbis.ru/page/my-claims");
КонецПроцедуры

&НаКлиенте
Процедура РуководствоПользователя(Команда)
	ЗапуститьПриложение("https://sbis.ru/help/integration/1C_set/modul");
КонецПроцедуры

&НаКлиенте
Процедура ОткрытьФормуНастроек(Элемент) Экспорт    
	
	фрм = СбисПолучитьФорму("ФормаНастройки", , , ЭтаФорма);
	фрм.Показать(Новый Структура("РежимЗапуска, Кэш", "ОбщиеНастройки", Кэш));
	
	Если Фрм.ИзмененСпособИнтеграции Тогда
		ПерезапуститьГлавноеОкно(Фрм.ПараметрыИнтеграции, Истина, Ложь);	
	КонецЕсли;
	
КонецПроцедуры 

&НаКлиенте
Процедура ОткрытьФормуСервисов(Элемент) Экспорт
	
	ФормаНастройки = СбисПолучитьФорму("ФормаНастройки", , , ЭтаФорма);
	ФормаНастройки.Показать(Новый Структура("РежимЗапуска, Кэш", "Сервисы", Кэш));

КонецПроцедуры

&НаКлиенте
Процедура ОткрытьФормуФайловНастроек(Команда) Экспорт    
	
	МодульОбъектаКлиент().ЗапуститьРедакторИни();
	
КонецПроцедуры

&НаКлиенте
Процедура ИзменитьНоменклатуру()  
	ТекущаяСтрока = Кэш.ТаблДок.ТекущиеДанные;
	фрм = сбисПолучитьФорму("ФормаУстановкаСооответствияНоменклатуры");
	фрм.Показать(ТекущаяСтрока);
КонецПроцедуры

&НаКлиенте
Процедура ВыполнитьВСБИС(Команда)
	
	СписокВыделенныхДокументов = ТаблДокПолучитьВыбранныеСтроки();
	МодульОбъектаКлиент = МодульОбъектаКлиент();
	
	Если Не ЗначениеЗаполнено(СписокВыделенныхДокументов) Тогда
		ПараметрыСообщения = Новый Структура;
		ПараметрыСообщения.Вставить("Текст", "Не выбран ни один документ из реестра");
		ПараметрыСообщения.Вставить("СтатусСообщения", СтатусСообщения.Внимание);
		ПараметрыСообщения.Вставить("ЭлементНазначения", Команда);
		ПараметрыСообщения.Вставить("ФормаВладелец", ЭтаФорма);
		СбисСообщитьПользователю(ПараметрыСообщения, Кэш);
		Возврат;
	КонецЕсли;
	
	// Нужна инфа по первому документу
	Отказ = Ложь;
	ПервыйДокумент = Кэш.Интеграция.ПрочитатьДокумент(Кэш, СписокВыделенныхДокументов[0].Значение.ИдСБИС,, Отказ);
	
	Если Отказ Тогда 
		
		МодульОбъектаКлиент.СбисВызватьИсключенпие(ПервыйДокумент);
		
	ИначеЕсли Не (ПервыйДокумент.Свойство("Этап")
		И ЗначениеЗаполнено(ПервыйДокумент.Этап)
		И ПервыйДокумент.Этап[0].Свойство("Действие")
		И ТипЗнч(ПервыйДокумент.Этап[0].Действие) = Тип("Массив")) Тогда
	
	    // Нет этапа, нет действия. Делать нечего.
		Возврат;
		
	КонецЕсли;
	
	СписокВозможныхДействий = Новый СписокЗначений;
	Для Каждого ДействиеЭтапа Из ПервыйДокумент.Этап[0].Действие Цикл
		
		// Берем только те действия, где не надо выбирать исполнителя и комментарий
		Если НРег(ДействиеЭтапа.ТребуетИсполнителя) = "нет"
			И НРег(ДействиеЭтапа.ТребуетКомментария) = "нет" Тогда
			
			СписокВозможныхДействий.Добавить(ДействиеЭтапа, ДействиеЭтапа.Название);
			
		КонецЕсли;
		
	КонецЦикла;
	
	Обработчик = МодульОбъектаКлиент.НовыйСбисОписаниеОповещения("ПослеВыбораСбисДействия", ЭтаФорма, Новый Структура("СписокОтмеченныхДокументов", СписокВыделенныхДокументов));
	ДопПараметры = Новый Структура("Обработчик, Заголовок, Элемент", Обработчик, "Выберите действие", Неопределено);
	МодульОбъектаКлиент.СбисВыбратьИзСписка(СписокВозможныхДействий, ДопПараметры);
	
КонецПроцедуры

&НаКлиенте
Процедура Сопоставить(Команда)
	// Вставить содержимое обработчика.
КонецПроцедуры

&НаКлиенте
Процедура Выгрузить(Команда)
	// Вставить содержимое обработчика.
КонецПроцедуры

&НаКлиенте
Процедура УбратьСопоставление(Команда)
	// Вставить содержимое обработчика.
КонецПроцедуры

&НаКлиенте
Процедура Отключить(Команда)
	// Вставить содержимое обработчика.
КонецПроцедуры

