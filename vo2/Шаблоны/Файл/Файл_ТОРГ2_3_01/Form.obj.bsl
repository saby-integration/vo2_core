
&НаКлиенте
Перем Файл_Шаблон_Модуль;

#Область include_local_ПолучитьМодульОбъекта
#КонецОбласти

//Функция запускает создание документа по ТОРГ-2 с предварительным поиском существующего документа
&НаКлиенте
Функция СоздатьДокумент(Кэш, Вложение, ИниДок, СоставПакета, МассивОснований, Документ1С = Неопределено) Экспорт

	Попытка
		
		Документ1СПроверка	= Документ1С;
		ПараметрыПоиска		= Новый Структура("СоставПакета", СоставПакета);
		Документ1СПроверка	= МодульОбъектаКлиент().ВложениеСБИС_Получить(Вложение, "ПодходящийДокумент", ПараметрыПоиска);
		Если		Документ1С = Неопределено
			И 	Не	Документ1СПроверка = Неопределено Тогда
			
			Документ1С			= Документ1СПроверка;
			ТекстСообщения		= "Найден подходящий документ " + Строка(Документ1С);
			ДанныеДозаполнить	= Кэш.ОбщиеФункции.РезультатДействия_ИзвлечьВременныеДанные(Кэш);
			
			Если ДанныеДозаполнить.ЗаполнитьДетализацию Тогда
				
				ПараметыЗаполнения = Новый Структура("Ссылка, Тип, Состояние, Сообщение", Документ1С, ИниДок.Документ.Значение, "Найден.", ТекстСообщения);
				Кэш.ОбщиеФункции.РезультатДействия_ДобавитьВРасшифровку(Кэш, "ЗагрузкаДокумента", ДанныеДозаполнить.СтрокаДетализации, ПараметыЗаполнения);
				ДанныеДозаполнить.СтрокаДетализации.Сообщение = "Найден существуюущий подходящий документ. Повторите загрузку для перезаполнения.";
				
			Иначе
				
				Сообщить("Для документа " + Вложение.Название + " н" + Сред(ТекстСообщения, 2));
				
			КонецЕсли;
			
			Возврат Документ1С;
			
		ИначеЕсли Документ1СПроверка = Неопределено Тогда
			
			//Нет в основании подходящего
			
		ИначеЕсли Не Документ1СПроверка = Документ1С Тогда
		
			ТекстСообщения		= "Документ " + Строка(Документ1С) + " не подходит для заполнения";
			ДанныеДозаполнить	= Кэш.ОбщиеФункции.РезультатДействия_ИзвлечьВременныеДанные(Кэш);
			
			Если ДанныеДозаполнить.ЗаполнитьДетализацию Тогда
				
				ДанныеДозаполнить.Отказ = Истина;
				ПараметыЗаполнения = Новый Структура("Ссылка, Тип, Состояние, Сообщение", Документ1С, ИниДок.Документ.Значение, "Найден.", ТекстСообщения);
				Кэш.ОбщиеФункции.РезультатДействия_ДобавитьВРасшифровку(Кэш, "ЗагрузкаДокумента", ДанныеДозаполнить.СтрокаДетализации, ПараметыЗаполнения);
				ДанныеДозаполнить.СтрокаДетализации.Сообщение = "Сопоставленный документ не подходит для выбранной настройки.";
				
			Иначе
				
				Сообщить(ТекстСообщения);
				
			КонецЕсли;
			
			Возврат Неопределено;
			
		КонецЕсли; 
		
		//ЗаполнитьДокументыОснования(Кэш, Вложение, ИниДок, СоставПакета, МассивОснований, Документ1С);
				
	Исключение
		
		СбисИсключение	= МодульОбъектаКлиент().НовыйСбисИсключение(ИнформацияОбОшибке(), "Файл_ТОРГ2_3_01.СоздатьДокумент");
		Если СбисИсключение.code = 760 Тогда
			
			МодульОбъектаКлиент().СообщитьСбисИсключение(СбисИсключение, Новый Структура("СтатусСообщения", "message"));
			
		Иначе
			
			МодульОбъектаКлиент().СообщитьСбисИсключение(СбисИсключение);
			Возврат Неопределено;
			
		КонецЕсли;
		
	КонецПопытки;
	
	Возврат Кэш.ГлавноеОкно.сбисПолучитьФорму("Документ_Шаблон").СоздатьДокумент(Кэш, Вложение, ИниДок, СоставПакета, МассивОснований, Документ1С);
	
КонецФункции

&НаКлиенте
Процедура ЗаполнитьДокументыОснования(Кэш, Вложение, ИниДок, СоставПакета, МассивОснований, Документ1С)
	Перем УзелИниОснования;
	
	Если Документ1С = Неопределено Тогда
		Возврат;//Есть установленный документ, который перезаполняем
	КонецЕсли;
	
	ПараметрыПОискаОснований	= Новый ФиксированнаяСтруктура("ВложениеСБИС", Вложение);
	ОснованиПоПакету			= МодульОбъектаКлиент().СоставПакета_Получить(СоставПакета, "ДокументОснованиеДляВложения", ПараметрыПОискаОснований);
	
	Если ЗначениеЗаполнено(ОснованиПоПакету) Тогда
		
		МассивОснований.Добавить(ОснованиПоПакету);
		
		ИниРаздела = МодульОбъектаКлиент().ВложениеСБИС_Получить(Вложение, "УстановленныйПодразделИни");
		ИмяРеквизитаОснования = МодульОбъектаКлиент().СтроковоеЗначениеУзлаИни(ИниРаздела, Новый Структура("ИмяРеквизита", Истина));
		
		
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Функция ПолучитьДанныеИзДокумента1С(Кэш,Контекст) Экспорт
	// Функция формирует структуру выгружаемого файла и добавляет его в состав пакета
	Попытка	
		Контекст.Вставить("ТаблДок",Новый Структура());
		Контекст.ТаблДок.Вставить("ИтогТабл",Новый Массив);
		Контекст.ТаблДок.Вставить("СтрТабл",Новый Массив);
		Контекст.Вставить("ИтогСумма",0);
		Контекст.Вставить("ИтогСуммаБезНалога",0);
		Контекст.Вставить("ИтогСуммаНДС",0);
		Контекст.Вставить("ИтогКоличество",0);
		Контекст.Вставить("ИтогБрутто",0);
		Контекст.Вставить("ИтогНетто",0);
		Контекст.Вставить("ИтогКолМест",0);
		
		Контекст.Вставить("ПредИтогСумма",0);
		Контекст.Вставить("ПредИтогСуммаБезНалога",0);
		Контекст.Вставить("ПредИтогСуммаНДС",0);
		Контекст.Вставить("НДСИсчисляетсяАгентом", Кэш.ОбщиеФункции.РассчитатьЗначение("НДСИсчисляетсяАгентом", Контекст.ФайлДанные) = Истина);
		НоменклатураКодКонтрагента = Кэш.ОбщиеФункции.РассчитатьЗначение("НоменклатураКодКонтрагента", Контекст.ФайлДанные,Кэш);  // надо сопоставить номенклатуру перед отправкой
		Если ЗначениеЗаполнено(НоменклатураКодКонтрагента) Тогда
			Контекст.Вставить("НоменклатураКодКонтрагента",НоменклатураКодКонтрагента);	
		КонецЕсли;
		                      
		фрм = МодульОбъектаКлиент().НайтиФункциюСеансаОбработки("ПолучитьТабличнуюЧастьДокумента1С","Файл_Шаблон");
		фрм.ПолучитьТабличнуюЧастьДокумента1С(Кэш,Контекст);
		Если Контекст.ТаблДок.СтрТабл.Количество() = 0 Тогда//нет такого документа
			Возврат Истина;
		КонецЕсли;
		
		Если Контекст.ФайлДанные.Свойство("мТаблДетал") Тогда
			Контекст.Вставить("ТаблДетал",Новый Структура());                 
			Контекст.ТаблДетал.Вставить("СтрТабл",Новый Массив);
			фрм = МодульОбъектаКлиент().НайтиФункциюСеансаОбработки("ПолучитьДетализациюТабЧастиДокумента1С","Файл_Шаблон");
			фрм.ПолучитьДетализациюТабЧастиДокумента1С(Кэш,Контекст);
		КонецЕсли;
		
		ИтогТабл=Новый Структура;
		ИтогТабл.Вставить("Кол_во", Формат(Контекст.ИтогКоличество, "ЧЦ=17; ЧДЦ=3; ЧРД=.; ЧГ=0; ЧН=0.000"));
		ИтогТабл.Вставить("Сумма", Формат(Контекст.ИтогСумма, "ЧЦ=17; ЧДЦ=2; ЧРД=.; ЧГ=0; ЧН=0.00"));	
		ИтогТабл.Вставить("СуммаБезНал", Формат(Контекст.ИтогСуммаБезНалога, "ЧЦ=17; ЧДЦ=2; ЧРД=.; ЧГ=0; ЧН=0.00"));
		ИтогТабл.Вставить("НДС",Новый Структура);
		ИтогТабл.НДС.Вставить("Сумма",Формат(Контекст.ИтогСуммаНДС, "ЧЦ=17; ЧДЦ=2; ЧРД=.; ЧГ=0; ЧН=0.00"));	
		Если Контекст.ИтогКолМест>0 Тогда
			ИтогТабл.Вставить("Упаковка",Новый Структура);
			ИтогТабл.Упаковка.Вставить("КолМест",Формат(Контекст.ИтогКолМест, "ЧЦ=17; ЧДЦ=0; ЧРД=.; ЧГ=0; ЧН=0"));	
		КонецЕсли;
		
		Если Контекст.ФайлДанные.Свойство("ЕдиницаИзмеренияВеса") Тогда
			ЕдиницаИзмеренияВеса = Контекст.ФайлДанные.ЕдиницаИзмеренияВеса;
				ИтогТаблБрутто = Новый Структура;
			Если Контекст.ФайлДанные.Свойство("МассаБруттоИтогПрописью") Тогда
				ИтогТаблБрутто.Вставить("Прописью", Кэш.ОбщиеФункции.РассчитатьЗначение("МассаБруттоИтогПрописью", Контекст.ФайлДанные,Кэш));  
				ИтогТабл.Вставить("Брутто", ИтогТаблБрутто);
			ИначеЕсли Контекст.ИтогБрутто > 0 Тогда
				ИтогТаблБрутто.Вставить("Кол_во", Формат(Контекст.ИтогБрутто, "ЧЦ=17; ЧДЦ=3; ЧРД=.; ЧГ=0; ЧН=0.00"));
				Если Контекст.ФайлДанные.Свойство("МассаИтогПрописью") Тогда
					Контекст.ФайлДанные.Вставить("МассаИтог", Контекст.ИтогБрутто);
					ИтогТаблБрутто.Вставить("Прописью", Кэш.ОбщиеФункции.РассчитатьЗначение("МассаИтогПрописью", Контекст.ФайлДанные,Кэш));
				Иначе	
					ИтогТаблБрутто.Вставить("Прописью", ЧислоПрописью(Контекст.ИтогБрутто, ,",,,,,,,,0")+ " " + СокрЛП(ЕдиницаИзмеренияВеса) + ".");
				КонецЕсли;	
				ИтогТабл.Вставить("Брутто", ИтогТаблБрутто);
			КонецЕсли;
			
			Если Контекст.ИтогНетто > 0 Тогда
				ИтогТаблНетто = Новый Структура;
				ИтогТаблНетто.Вставить("Кол_во", Формат(Контекст.ИтогНетто, "ЧЦ=17; ЧДЦ=3; ЧРД=.; ЧГ=0; ЧН=0.00"));
				Если Контекст.ФайлДанные.Свойство("МассаИтогПрописью") Тогда
					Контекст.ФайлДанные.Вставить("МассаИтог", Контекст.ИтогНетто);
					ИтогТаблНетто.Вставить("Прописью", Кэш.ОбщиеФункции.РассчитатьЗначение("МассаИтогПрописью", Контекст.ФайлДанные,Кэш));
				Иначе	
					ИтогТаблНетто.Вставить("Прописью", ЧислоПрописью(Контекст.ИтогНетто, ,",,,,,,,,0")+ " " + СокрЛП(ЕдиницаИзмеренияВеса) + ".");
				КонецЕсли;	
				ИтогТабл.Вставить("Нетто", ИтогТаблНетто);
			КонецЕсли;
		КонецЕсли;
		
		Если Контекст.Свойство("ЕстьПредыдущиеДанные") Тогда
			ПредИтогТабл=Новый Структура;
			ПредИтогТабл.Вставить("Сумма", Формат(Контекст.ПредИтогСумма, "ЧЦ=17; ЧДЦ=2; ЧРД=.; ЧГ=0; ЧН=0.00"));	
			ПредИтогТабл.Вставить("СуммаБезНал", Формат(Контекст.ПредИтогСуммаБезНалога, "ЧЦ=17; ЧДЦ=2; ЧРД=.; ЧГ=0; ЧН=0.00"));
			ПредИтогТабл.Вставить("НДС",Новый Структура);
			ПредИтогТабл.НДС.Вставить("Сумма",Формат(Контекст.ПредИтогСуммаНДС, "ЧЦ=17; ЧДЦ=2; ЧРД=.; ЧГ=0; ЧН=0.00"));	
			ИтогТабл.Вставить("ПредИтогТабл",ПредИтогТабл);
		КонецЕсли;
		
		//Контекст.ТаблДок.Вставить("ИтогТабл",Новый Массив);
		Контекст.ТаблДок.ИтогТабл.Добавить(ИтогТабл);
		
		
		Док  = Новый Структура;
		Док.Вставить("Файл",Новый Структура);
		Кэш.ОбщиеФункции.ЗаполнитьАтрибуты(Кэш,"Файл",Контекст.ФайлДанные,Док.Файл);
		Док.Файл.Вставить("Документ",Новый Структура);
		Кэш.ОбщиеФункции.ЗаполнитьАтрибуты(Кэш,"Документ",Контекст.ФайлДанные,Док.Файл.Документ);
		Док.Файл.Документ.Вставить("Основание",Новый Массив);
		
		Валюта =  Кэш.ОбщиеФункции.РассчитатьЗначение("Валюта_КодОКВ", Контекст.ФайлДанные, Кэш);
		Если ЗначениеЗаполнено(Валюта) Тогда
			Док.Файл.Документ.Вставить("Валюта",Новый Структура);
			Кэш.ОбщиеФункции.ЗаполнитьАтрибуты(Кэш,"Валюта",Контекст.ФайлДанные,Док.Файл.Документ.Валюта);
		КонецЕсли;
		
		Отправитель = "";
		Получатель = "";
		ЗапретРедакций = Ложь;
		ОтправительРоль=Кэш.ОбщиеФункции.РассчитатьЗначение("Отправитель_Роль", Контекст.ФайлДанные, Кэш);
		ПолучательРоль=Кэш.ОбщиеФункции.РассчитатьЗначение("Получатель_Роль", Контекст.ФайлДанные, Кэш);
		Если Не ЗначениеЗаполнено(ОтправительРоль) Тогда
			ОтправительРоль = "Отправитель";
		КонецЕсли;
		Если Не ЗначениеЗаполнено(ПолучательРоль) Тогда
			ПолучательРоль = "Получатель";
		КонецЕсли;
		Если Контекст.ФайлДанные.Свойство("мСторона") Тогда
			Для Каждого Параметр Из Контекст.ФайлДанные.мСторона Цикл
				Если Параметр.Значение.Свойство("Роль") Тогда
					Роль = Кэш.ОбщиеФункции.РассчитатьЗначение("Роль",Параметр.Значение,Кэш);
				Иначе
					Роль = Кэш.ОбщиеФункции.РассчитатьЗначение("Сторона_Роль",Параметр.Значение,Кэш);
				КонецЕсли;
				Если Роль = ОтправительРоль Тогда
					Сертификат = Кэш.ОбщиеФункции.РассчитатьЗначение("Сертификат",Параметр.Значение,Кэш);
				КонецЕсли;
				Если Роль = ПолучательРоль Тогда
					ЗапретРедакций = Кэш.ОбщиеФункции.РассчитатьЗначение("ЗапретРедакций",Параметр.Значение,Кэш);
				КонецЕсли;
				Сторона = Кэш.ОбщиеФункции.ПолучитьСторону(Кэш,Параметр.Значение);     //?????
				Если Сторона<>Неопределено Тогда
					Док.Файл.Документ.Вставить(Роль,Сторона);
				КонецЕсли;
			КонецЦикла;
			Если Не Док.Файл.Документ.Свойство(ПолучательРоль) Тогда
				МодульОбъектаКлиент().ВызватьСбисИсключение(721, "Файл_Шаблон.ПолучитьШапкуИзДокумента1С",,,"Не удалось определить ИНН получателя документа " + Строка(Контекст.Документ));
			КонецЕсли;
			Если Не Док.Файл.Документ.Свойство(ОтправительРоль) Тогда
				МодульОбъектаКлиент().ВызватьСбисИсключение(721, "Файл_Шаблон.ПолучитьШапкуИзДокумента1С",,,"Не удалось определить ИНН отправителя документа " + Строка(Контекст.Документ));
			КонецЕсли;
			// Если Грузоотправитель и грузополучатель нужны, но они не попали в файл, то берем их с отправителя и получателя
			Если Не Контекст.Свойство("ЗаполнятьГрузотпрГрузполуч") или (Контекст.Свойство("ЗаполнятьГрузотпрГрузполуч") и Контекст.ЗаполнятьГрузотпрГрузполуч = Истина) Тогда
				Если Контекст.ФайлДанные.мСторона.Свойство("Грузоотправитель") и Не Док.Файл.Документ.Свойство("Грузоотправитель") Тогда
					КопироватьГрузоотправителяС = ОтправительРоль; 
					Если Контекст.ФайлДанные.Свойство("КопироватьГрузоотправителяС") Тогда
						КопироватьГрузоотправителяС=Кэш.ОбщиеФункции.РассчитатьЗначение("КопироватьГрузоотправителяС", Контекст.ФайлДанные, Кэш);  
					КонецЕсли;
					Если Док.Файл.Документ.Свойство(КопироватьГрузоотправителяС) Тогда
						Док.Файл.Документ.Вставить("Грузоотправитель",Новый Структура);		
						Кэш.ОбщиеФункции.сбисСкопироватьСтруктуруНаКлиенте(Док.Файл.Документ.Грузоотправитель,Док.Файл.Документ[КопироватьГрузоотправителяС]);
					КонецЕсли;	
				КонецЕсли;
				Если Контекст.ФайлДанные.мСторона.Свойство("Грузополучатель") и Не Док.Файл.Документ.Свойство("Грузополучатель") Тогда
					КопироватьГрузополучателяС = ПолучательРоль; 
					Если Контекст.ФайлДанные.Свойство("КопироватьГрузополучателяС") Тогда
						КопироватьГрузополучателяС=Кэш.ОбщиеФункции.РассчитатьЗначение("КопироватьГрузополучателяС", Контекст.ФайлДанные, Кэш);  
					КонецЕсли;
					Если Док.Файл.Документ.Свойство(КопироватьГрузополучателяС) Тогда
						Док.Файл.Документ.Вставить("Грузополучатель",Новый Структура);		
						Кэш.ОбщиеФункции.сбисСкопироватьСтруктуруНаКлиенте(Док.Файл.Документ.Грузополучатель,Док.Файл.Документ[КопироватьГрузополучателяС]);   
					КонецЕсли;
				КонецЕсли;
			КонецЕсли;
			Отправитель = Кэш.ОбщиеФункции.сбисСкопироватьОбъектНаКлиенте(Док.Файл.Документ[ОтправительРоль]); 
			Получатель = Кэш.ОбщиеФункции.сбисСкопироватьОбъектНаКлиенте(Док.Файл.Документ[ПолучательРоль]); 
			Если ЗапретРедакций = Истина Тогда
				Получатель.Вставить("ЗапретРедакций", Истина);		
			КонецЕсли;
		КонецЕсли;
		
		Если Контекст.ФайлДанные.Свойство("АдресДоставки") И Контекст.ФайлДанные.АдресДоставки <> Неопределено Тогда
			Док.Файл.Документ.Вставить("АдресДоставки", Кэш.ОбщиеФункции.РассчитатьЗначение("АдресДоставки", Контекст.ФайлДанные, Кэш));
		КонецЕсли;
		Если Контекст.ФайлДанные.Свойство("АдресПогрузки") И Контекст.ФайлДанные.АдресПогрузки <> Неопределено Тогда
			Док.Файл.Документ.Вставить("АдресПогрузки", Кэш.ОбщиеФункции.РассчитатьЗначение("АдресПогрузки", Контекст.ФайлДанные, Кэш));
		КонецЕсли;
		
		Если Контекст.ФайлДанные.Свойство("мОснование") Тогда
			//НайтиФункциюСеансаОбработки(СбисИмяФункции, СбисОсновныеФормы, ДопПараметры = Неопределено) Экспорт
			фрм = МодульОбъектаКлиент().НайтиФункциюСеансаОбработки("ПолучитьДанныеИзДокумента1С_мОснование", "Файл_Шаблон");
			фрм.ПолучитьДанныеИзДокумента1С_мОснование(Кэш, Док, Контекст);
		КонецЕсли;
		
		Если Контекст.ФайлДанные.Свойство("мПараметр") Тогда
			Док.Файл.Документ.Вставить("Параметр",Новый Массив);
			Для Каждого Элемент Из Контекст.ФайлДанные.мПараметр Цикл
				Кэш.ОбщиеФункции.сбисСкопироватьСтруктуруНаКлиенте(Контекст.ФайлДанные,Элемент.Значение);
				Параметр = Новый Структура();
				Кэш.ОбщиеФункции.ЗаполнитьАтрибуты(Кэш,"Параметр",Контекст.ФайлДанные,Параметр);
				Док.Файл.Документ.Параметр.Добавить(Параметр);
			КонецЦикла;
		КонецЕсли; 
		
		Если Контекст.ФайлДанные.Свойство("мТранспортноеСредство") Тогда
			Док.Файл.Документ.Вставить("ТранспортноеСредство",Новый Массив);
			Для Каждого Элемент Из Контекст.ФайлДанные.мТранспортноеСредство Цикл
				Кэш.ОбщиеФункции.сбисСкопироватьСтруктуруНаКлиенте(Контекст.ФайлДанные,Элемент.Значение);
				ТранспортноеСредство = Новый Структура();
				Кэш.ОбщиеФункции.ЗаполнитьАтрибуты(Кэш,"ТранспортноеСредство",Контекст.ФайлДанные,ТранспортноеСредство);
				Док.Файл.Документ.ТранспортноеСредство.Добавить(ТранспортноеСредство);
			КонецЦикла;
		КонецЕсли;   
		
		Если Контекст.ФайлДанные.Свойство("СодСоб") Тогда
			
			 Док.Файл.Документ.Вставить("СодСоб","Настоящий Акт составлен комиссией, которая произвела осмотр прибывшего груза и установила: доставлен товар по сопроводительному {номер} {дата} документу");
			
		КонецЕсли;
		
		ОтветственныйСтруктура = Кэш.ОбщиеФункции.ПолучитьСтруктуруОтветственного(Кэш,Контекст);
		ПодразделениеСтруктура = Кэш.ОбщиеФункции.ПолучитьСтруктуруПодразделения(Кэш,Контекст);
		РегламентСтруктура = Кэш.ОбщиеФункции.ПолучитьСтруктуруРегламента(Кэш,Контекст);
		ОснованияМассив = Кэш.ОбщиеФункции.ПолучитьМассивОснований(Кэш,Контекст);  
		СвязанныеДокументы1С = Кэш.ОбщиеФункции.сбисПолучитьСвязанныеДокументы1С(Кэш,Контекст);
		ДатаВложения = ?(Док.Файл.Документ.Свойство("Дата"), Док.Файл.Документ.Дата, "");
		НомерВложения = ?(Док.Файл.Документ.Свойство("Номер"), Док.Файл.Документ.Номер, "");
		Если Контекст.НДСИсчисляетсяАгентом Тогда
			СуммаВложения = Формат(Контекст.ИтогСуммаБезНалога, "ЧЦ=17; ЧДЦ=2; ЧРД=.; ЧГ=0; ЧН=0.00");
		Иначе
			СуммаВложения = Формат(Контекст.ИтогСумма, "ЧЦ=17; ЧДЦ=2; ЧРД=.; ЧГ=0; ЧН=0.00");
		КонецЕсли;
		НазваниеВложения = ?(Док.Файл.Документ.Свойство("Название"), Док.Файл.Документ.Название+" № "+НомерВложения+" от "+ДатаВложения+" на сумму "+СуммаВложения, "");
		Тип = Кэш.ОбщиеФункции.РассчитатьЗначение("Вложение_Тип", Контекст.ФайлДанные,Кэш);
		ПодТип = Кэш.ОбщиеФункции.РассчитатьЗначение("Вложение_ПодТип", Контекст.ФайлДанные,Кэш);
		ВерсияФормата = Кэш.ОбщиеФункции.РассчитатьЗначение("Вложение_ВерсияФормата", Контекст.ФайлДанные,Кэш);
		ПодВерсияФормата = Кэш.ОбщиеФункции.РассчитатьЗначение("Вложение_ПодВерсияФормата", Контекст.ФайлДанные,Кэш);
		Примечание = Кэш.ОбщиеФункции.РассчитатьЗначение("Примечание", Контекст.ФайлДанные,Кэш);
		Провести = Кэш.ОбщиеФункции.РассчитатьЗначение("Провести", Контекст.ФайлДанные,Кэш); // alo Провести
		ИспользоватьГенератор = Кэш.ОбщиеФункции.РассчитатьЗначение("ИспользоватьГенератор", Контекст.ФайлДанные,Кэш);
		
		
		Док.Файл.Документ.Вставить("ТаблДок", Контекст.ТаблДок);
		Если Контекст.Свойство("ТаблДетал") И Контекст.ТаблДетал.СтрТабл.Количество() > 0 Тогда
			Док.Файл.Документ.Вставить("ТаблДетал", Контекст.ТаблДетал);
		КонецЕсли;
		Вложение = Новый Структура("СтруктураДокумента,Отправитель,Получатель,Ответственный,Подразделение,Регламент,ДокументОснование, Документ1С, Название, Тип, ПодТип, ВерсияФормата,ПодВерсияФормата,Дата,Номер,Сумма", Док,Отправитель,Получатель,ОтветственныйСтруктура,ПодразделениеСтруктура,РегламентСтруктура,ОснованияМассив, Контекст.Документ, НазваниеВложения, Тип, ПодТип, ВерсияФормата,ПодВерсияФормата,ДатаВложения,НомерВложения,СуммаВложения);
		Вложение.Вставить("ТребуетПодписания", Истина);
		Если ЗначениеЗаполнено(НоменклатураКодКонтрагента) Тогда
			Вложение.Вставить("НоменклатураКодКонтрагента",НоменклатураКодКонтрагента);	
		КонецЕсли;
		Если ЗначениеЗаполнено(Примечание) Тогда
			Вложение.Вставить("Примечание",Примечание);	
		КонецЕсли;
		Если ЗначениеЗаполнено(Сертификат) Тогда
			Вложение.Вставить("Сертификат",Сертификат);	
		КонецЕсли;
		Если ТипЗнч(ИспользоватьГенератор) = Тип("Булево") Тогда
			Вложение.Вставить("ИспользоватьГенератор", ИспользоватьГенератор);
		КонецЕсли;
		
		МодульОбъектаКлиент().ПропатчитьФайлВложенияСБИС(Вложение, Новый Структура("ГрязныйИни, ПолучательРоль, ОтправительРоль", Контекст.ФайлДанные, ПолучательРоль, ОтправительРоль));
				
		ДопПоля= Новый Структура;	// alo ДопПоля
		Кэш.ОбщиеФункции.ЗаполнитьАтрибуты(Кэш,"ДопПоля",Контекст.ФайлДанные,ДопПоля);
		Если ЗначениеЗаполнено(ДопПоля) Тогда
			Вложение.Вставить("ДопПоля",ДопПоля);
		Конецесли;
		Если ЗначениеЗаполнено(Провести) Тогда // alo Провести
			Вложение.Вставить("Провести",Провести);	
		КонецЕсли;   
		Если ЗначениеЗаполнено(СвязанныеДокументы1С) Тогда
			СвязанныеДокументы1С.Вставить(0, Контекст.Документ);
			Вложение.Вставить("Документы1С",СвязанныеДокументы1С);	
		КонецЕсли;
		Контекст.СоставПакета.Вложение.Добавить(Вложение);
		
		ИмяФормыПоФормату = "Файл_"+Кэш.ОбщиеФункции.сбисЗаменитьНедопустимыеСимволы(Контекст.ФайлДанные.Файл_Формат)+"_"+Кэш.ОбщиеФункции.сбисЗаменитьНедопустимыеСимволы(Контекст.ФайлДанные.Файл_ВерсияФормата);
		фрм = Кэш.ГлавноеОкно.сбисНайтиФормуФункции("сбисПослеФормированияДокумента", ИмяФормыПоФормату, "Файл_Шаблон", Кэш);
		Если фрм<>Ложь Тогда
			фрм.сбисПослеФормированияДокумента(Док, Кэш, Контекст);	
			Вложение.СтруктураДокумента = Док; // на случай, если Док поменялся в функции сбисПослеФормированияДокумента
		КонецЕсли;
		Возврат Истина;
		
	Исключение
		ИсключениеФормирования = МодульОбъектаКлиент().НовыйСбисИсключение(ИнформацияОбОшибке(), "Файл_Шаблон.ПолучитьШапкуИзДокумента1С");
		Контекст.СоставПакета.Вставить("Ошибка", ИсключениеФормирования);
		Возврат Ложь;
	КонецПопытки;
КонецФункции

&НаКлиенте
Функция СформироватьДокументДляГенератора(ПараметрыФормированияВходящие, Кэш) Экспорт
	
	Док		= ПараметрыФормированияВходящие.Документ;
	Вложение= ПараметрыФормированияВходящие.Вложение;  
	
	Файл_Шаблон_Модуль = Кэш.ГлавноеОкно.СбисПолучитьФорму("Файл_Шаблон");
	
	ТекДокумент = Док.Файл.Документ;
	ТекДокумент.Вставить("ДефНомИспрСФ",  "-");
	ТекДокумент.Вставить("ДефДатаИспрСФ", "-");
	ТекДокумент.Вставить("ПоФактХЖ", 	Вложение.Название);
	ТекДокумент.Вставить("НаимДокОпр", 	ТекДокумент.Название);
	
	Возврат Док;
	
КонецФункции

&НаКлиенте
Функция СформироватьРасхождение(ДанныеВложений, Кэш) Экспорт
	СтруктураФайлаКонтрагента	= ДанныеВложений.СтруктураФайлаКонтрагента;
	СтруктураФайлаНаша			= ДанныеВложений.ВложениеНаше.СтруктураДокумента;
	Док							= СформироватьРасхождениеНаСервере(СтруктураФайлаКонтрагента, СтруктураФайлаНаша);
	ОшибкаПреобразования = Ложь;
	
	ПараметрыСгенерироватьВходящие = Новый Структура;
	ПараметрыСгенерироватьВходящие.Вставить("Вложение", 			ДанныеВложений.ВложениеНаше);
	ПараметрыСгенерироватьВходящие.Вставить("СтруктураДокумента",	Док);
	ПараметрыСгенерироватьВходящие.Вставить("МетодПодготовки",		"СформироватьДокументДляГенератора");
	Попытка
		НаборВложений = МодульОбъектаКлиент().СгенерироватьНаборВложенийВПакет(ПараметрыСгенерироватьВходящие);
	Исключение
		МодульОбъектаКлиент().СообщитьСбисИсключение(ИнформацияОбОшибке(), Новый Структура("ИмяКоманды", "Файл_Шаблон.СформироватьРасхождение"));
		Возврат Неопределено;
	КонецПопытки;
	
	//Первое вложение - основное.
	ВложениеРасхождения	= НаборВложений[0];
	ВложениеРасхождения.Документы1С.Очистить();
	ТекстHTML = Кэш.Интеграция.ПолучитьHTMLПоXML(Кэш, ВложениеРасхождения);
	ВложениеРасхождения.Вставить("ТекстHTML", ТекстHTML);
	Возврат ВложениеРасхождения;
КонецФункции

Функция СформироватьРасхождениеНаСервере(СтруктураФайлаКонтрагента, СтруктураФайлаНаша) Экспорт
	Док  = Новый Структура;
	Док.Вставить("Файл",Новый Структура);
	Док.Файл.Вставить("Формат",СтруктураФайлаНаша.Файл.Формат);
	Док.Файл.Вставить("ВерсияФормата",СтруктураФайлаНаша.Файл.ВерсияФормата);
	Док.Файл.Вставить("Имя",СтруктураФайлаНаша.Файл.Имя);
	Если СтруктураФайлаНаша.Файл.Свойство("КодФормы") тогда
		Док.Файл.Вставить("КодФормы",СтруктураФайлаНаша.Файл.КодФормы);
	КонецЕсли;
	Док.Файл.Вставить("Документ",Новый Структура);
	Для Каждого Элемент Из СтруктураФайлаНаша.Файл.Документ Цикл
		Если ТипЗнч(Элемент.Значение)<>Тип("Структура") и ТипЗнч(Элемент.Значение)<>Тип("Массив") Тогда
			Док.Файл.Документ.Вставить(Элемент.Ключ, Элемент.Значение);	
		КонецЕсли;
	КонецЦикла;
	
	// Вставим примечание из заказа-основания, если не заполняется явно в ИНИ
	Если (СтруктураФайлаКонтрагента.Файл.Формат = "Заказ")
		И (НЕ Док.Файл.Документ.Свойство("Примечание") ИЛИ НЕ ЗначениеЗаполнено(Док.Файл.Документ.Примечание))
		И СтруктураФайлаКонтрагента.Файл.Документ.Свойство("Примечание") Тогда
		
			Док.Файл.Документ.Вставить("Примечание", СтруктураФайлаКонтрагента.Файл.Документ.Примечание);
			
	КонецЕсли;
	
	Док.Файл.Документ.Вставить("Основание",Новый Массив);
	Если (СтруктураФайлаКонтрагента.Файл.Формат = "Заказ") Тогда
		Док.Файл.Документ.Основание.Добавить(Новый Структура("Дата,Номер,Название",СтруктураФайлаКонтрагента.Файл.Документ.Дата,СтруктураФайлаКонтрагента.Файл.Документ.Номер,СтруктураФайлаКонтрагента.Файл.Формат));
	Иначе
		Док.Файл.Документ.Основание.Добавить(Новый Структура("Дата,Номер",СтруктураФайлаКонтрагента.Файл.Документ.Дата,СтруктураФайлаКонтрагента.Файл.Документ.Номер));
	КонецЕсли;
	Если СтруктураФайлаКонтрагента.Файл.Документ.Свойство("Отправитель") Тогда
		Док.Файл.Документ.Вставить("Отправитель",СтруктураФайлаКонтрагента.Файл.Документ.Отправитель);
		ПреобразоватьПараметрыВМассив(Док.Файл.Документ.Отправитель);
	КонецЕсли;
	Если СтруктураФайлаКонтрагента.Файл.Документ.Свойство("Получатель") Тогда
		Док.Файл.Документ.Вставить("Получатель",СтруктураФайлаКонтрагента.Файл.Документ.Получатель);
		ПреобразоватьПараметрыВМассив(Док.Файл.Документ.Получатель);
	КонецЕсли;
	Если СтруктураФайлаКонтрагента.Файл.Документ.Свойство("Грузоотправитель") Тогда
		Док.Файл.Документ.Вставить("Грузоотправитель",СтруктураФайлаКонтрагента.Файл.Документ.Грузоотправитель);
		ПреобразоватьПараметрыВМассив(Док.Файл.Документ.Грузоотправитель);
	КонецЕсли;
	Если СтруктураФайлаКонтрагента.Файл.Документ.Свойство("Грузополучатель") Тогда
		Док.Файл.Документ.Вставить("Грузополучатель",СтруктураФайлаКонтрагента.Файл.Документ.Грузополучатель);
		ПреобразоватьПараметрыВМассив(Док.Файл.Документ.Грузополучатель);
	КонецЕсли;
	Если СтруктураФайлаКонтрагента.Файл.Документ.Свойство("Поставщик") Тогда
		Док.Файл.Документ.Вставить("Поставщик",СтруктураФайлаКонтрагента.Файл.Документ.Поставщик);
		ПреобразоватьПараметрыВМассив(Док.Файл.Документ.Поставщик);
	КонецЕсли;
	Если СтруктураФайлаКонтрагента.Файл.Документ.Свойство("Покупатель") Тогда
		Док.Файл.Документ.Вставить("Покупатель",СтруктураФайлаКонтрагента.Файл.Документ.Покупатель);
		ПреобразоватьПараметрыВМассив(Док.Файл.Документ.Покупатель);
	КонецЕсли;
	
	// Заполним параметры заказа по документу контрагента
	Если (СтруктураФайлаКонтрагента.Файл.Формат = "Заказ") 
		И СтруктураФайлаКонтрагента.Файл.Документ.Свойство("Параметр") Тогда
		ПараметрыКЗаполнению = СтруктураФайлаКонтрагента.Файл.Документ.Параметр;
		МассивПараметров = Новый Массив;
		Если ТипЗнч(ПараметрыКЗаполнению) = Тип("Структура") Тогда
			Для Каждого ПараметрКЗаполнению Из ПараметрыКЗаполнению Цикл
				СтруктураПараметр = Новый Структура("Имя, Значение",ПараметрКЗаполнению.Ключ,ПараметрКЗаполнению.Значение);
				МассивПараметров.Добавить(СтруктураПараметр);
			КонецЦикла;
		ИначеЕсли ТипЗнч(ПараметрыКЗаполнению) = Тип("Массив") Тогда
			МассивПараметров = ПараметрыКЗаполнению;		
		КонецЕсли;
		Док.Файл.Документ.Вставить("Параметр", МассивПараметров);
	КонецЕсли;
	
	Если СтруктураФайлаНаша.Файл.Документ.Свойство("Параметр") Тогда
		// Для заказа произведем замену параметров, которые заполнились из СтруктураФайлаКонтрагента
		Если (СтруктураФайлаКонтрагента.Файл.Формат = "Заказ") И Док.Файл.Документ.Свойство("Параметр") Тогда
			КолвоПараметровКонтрагента = Док.Файл.Документ.Параметр.Количество();
			Для Каждого Параметр Из СтруктураФайлаНаша.Файл.Документ.Параметр Цикл
				ПараметрОбновлен = Ложь;
				Для ПозицияОбхода = 0 По КолвоПараметровКонтрагента - 1 Цикл
					Если Док.Файл.Документ.Параметр.Получить(ПозицияОбхода).Имя = Параметр.Имя Тогда
						Док.Файл.Документ.Параметр.Получить(ПозицияОбхода).Значение = Параметр.Значение;
						ПараметрОбновлен = Истина;
						Прервать;
					КонецЕсли;
				КонецЦикла;
				Если НЕ ПараметрОбновлен Тогда
					Док.Файл.Документ.Параметр.Добавить(Параметр);
				КонецЕсли;
			КонецЦикла;
		Иначе
			Док.Файл.Документ.Вставить("Параметр", СтруктураФайлаНаша.Файл.Документ.Параметр);
		КонецЕсли;
	КонецЕсли;
	
	ТабЧастьНаша = МассивСтруктурВТаблицуЗначений(СтруктураФайлаНаша.Файл.Документ.ТаблДок.СтрТабл);
	ТабЧастьНаша.Колонки.Добавить("ЕстьВФайлеКонтрагента", Новый ОписаниеТипов("Булево"));
	ЕстьПорНомерВФайлеКонтрагента = Ложь;
	Если СтруктураФайлаНаша.Файл.Документ.ТаблДок.СтрТабл[0].Свойство("ПорНомерВФайлеКонтрагента") Тогда
		ЕстьПорНомерВФайлеКонтрагента = Истина;	
	КонецЕсли;
	
	ТабЧастьКонтрагента = Новый Соответствие;   // сворачиваем табличную часть по идентификатору строки
	Для Каждого СтрТабл Из СтруктураФайлаКонтрагента.Файл.Документ.ТаблДок.СтрТабл Цикл
		Если СтрТабл.Свойство("Идентификатор") и ЗначениеЗаполнено(СтрТабл.Идентификатор) И НЕ ЕстьПорНомерВФайлеКонтрагента Тогда
			СтрокаСоответствия = ТабЧастьКонтрагента.Получить(СтрТабл.Идентификатор);
			Если СтрокаСоответствия = Неопределено Тогда
				ТабЧастьКонтрагента.Вставить(СтрТабл.Идентификатор, СтрТабл);	
			Иначе
				Если СтрТабл.Свойство("Кол_во") и СтрокаСоответствия.Свойство("Кол_во") Тогда
					СтрокаСоответствия.Кол_во = Формат(Число(СтрокаСоответствия.Кол_во)+Число(СтрТабл.Кол_во),"ЧЦ=17; ЧДЦ=3; ЧРД=.; ЧГ=0; ЧН=0.000");
				КонецЕсли;
				Если СтрТабл.Свойство("СуммаБезНал") и СтрокаСоответствия.Свойство("СуммаБезНал") Тогда
					СтрокаСоответствия.СуммаБезНал = Формат(Число(СтрокаСоответствия.СуммаБезНал)+Число(СтрТабл.СуммаБезНал),"ЧЦ=17; ЧДЦ=2; ЧРД=.; ЧГ=0; ЧН=0.00");
				КонецЕсли;
				Если СтрТабл.Свойство("Сумма") и СтрокаСоответствия.Свойство("Сумма") Тогда
					СтрокаСоответствия.Сумма = Формат(Число(СтрокаСоответствия.Сумма)+Число(СтрТабл.Сумма),"ЧЦ=17; ЧДЦ=2; ЧРД=.; ЧГ=0; ЧН=0.00");
				КонецЕсли;
				Если СтрТабл.Свойство("НДС") и СтрТабл.НДС.Свойство("Сумма") и СтрокаСоответствия.Свойство("НДС") и СтрокаСоответствия.НДС.Свойство("Сумма") Тогда
					СтрокаСоответствия.НДС.Сумма = Формат(Число(СтрокаСоответствия.НДС.Сумма)+Число(СтрТабл.НДС.Сумма),"ЧЦ=17; ЧДЦ=2; ЧРД=.; ЧГ=0; ЧН=0.00");
				КонецЕсли;
				
			КонецЕсли;
		Иначе
			ТабЧастьКонтрагента.Вставить(Новый УникальныйИдентификатор, СтрТабл);	
		КонецЕсли;
	КонецЦикла;
	
	ИтогСумма = 0;
	ИтогКоличество = 0;
	ИтогСуммаБезНал = 0;
	ИтогНДС = 0;
	СтрОтклонения = Новый Массив;
	Для Каждого СтрокаСоответствия Из ТабЧастьКонтрагента Цикл
		СтрТабл = СтрокаСоответствия.Значение;
		НоваяСтрока = Новый Структура();
		Если СтрТабл.Свойство("КодПокупателя") Тогда
			НоваяСтрока.Вставить("КодПокупателя", СтрТабл.КодПокупателя);
		КонецЕсли;
		Если СтрТабл.Свойство("КодПоставщика") Тогда
			НоваяСтрока.Вставить("КодПоставщика", СтрТабл.КодПоставщика);
		КонецЕсли;
		Номенклатура = Неопределено;
		ОКЕИ = Неопределено;
		ХарактеристикаНоменклатуры = Неопределено;
		СтрТабл.Свойство("Номенклатура", Номенклатура);
		//СтрТабл.Свойство("ОКЕИ", ОКЕИ);
		СтрТабл.Свойство("ХарактеристикаНоменклатуры", ХарактеристикаНоменклатуры);
		//Отбор = Новый Структура("Номенклатура, ОКЕИ", Номенклатура, ОКЕИ);
		Если ЕстьПорНомерВФайлеКонтрагента Тогда
			Отбор = Новый Структура("ПорНомерВФайлеКонтрагента", СтрТабл.ПорНомер);
		Иначе
			Отбор = Новый Структура("Номенклатура", Номенклатура);
			
			Если ТабЧастьНаша.Колонки.Найти("ХарактеристикаНоменклатуры")<>Неопределено Тогда
				Если ЗначениеЗаполнено(ХарактеристикаНоменклатуры) Тогда
					Отбор.Вставить("ХарактеристикаНоменклатуры", ХарактеристикаНоменклатуры);
				Иначе
					Отбор.Вставить("ХарактеристикаНоменклатуры", Справочники.ХарактеристикиНоменклатуры.ПустаяСсылка());
				КонецЕсли;
			КонецЕсли;                
		КонецЕсли;
		НайденныеСтроки = ТабЧастьНаша.НайтиСтроки(Отбор);
		Если НайденныеСтроки.Количество()>0 Тогда
			НайденнаяСтрока = НайденныеСтроки[0];
			НайденнаяСтрока.ЕстьВФайлеКонтрагента = Истина;
			Для Каждого Поле Из СтруктураФайлаНаша.Файл.Документ.ТаблДок.СтрТабл[0] Цикл
				Если Поле.Ключ<>"Номенклатура" и Поле.Ключ<>"ХарактеристикаНоменклатуры" и Поле.Ключ<>"ПорНомерВФайлеКонтрагента" Тогда
					НоваяСтрока.Вставить(Поле.Ключ, НайденнаяСтрока[Поле.Ключ]);
				КонецЕсли;
			КонецЦикла;
			Попытка
				ИтогСумма = ИтогСумма+НайденнаяСтрока.Сумма;
				ИтогКоличество = ИтогКоличество+НайденнаяСтрока.Кол_во;
				ИтогСуммаБезНал = ИтогСуммаБезНал+НайденнаяСтрока.СуммаБезНал;
				ИтогНДС = ИтогНДС+НайденнаяСтрока.НДС.Сумма;
			Исключение
			КонецПопытки;
		Иначе     // если удалили строки в загруженном документе
			НоваяСтрока.Вставить("Название", ?(СтрТабл.Свойство("Название"),СтрТабл.Название,""));
			НоваяСтрока.Вставить("Кол_во", "0");
			НоваяСтрока.Вставить("Цена", "0");                 
			НоваяСтрока.Вставить("СуммаБезНал", "0");
			НоваяСтрока.Вставить("Сумма", "0");  
			Если СтрТабл.Свойство("GTIN") Тогда
				НоваяСтрока.Вставить("GTIN", СтрТабл.GTIN);	
			КонецЕсли;  
			Если СтрТабл.Свойство("ОКЕИ") Тогда
				НоваяСтрока.Вставить("ОКЕИ", СтрТабл.ОКЕИ);	
			КонецЕсли;  
			Если СтрТабл.Свойство("ЕдИзм") Тогда
				НоваяСтрока.Вставить("ЕдИзм", СтрТабл.ЕдИзм);	
			КонецЕсли;
		КонецЕсли;
		ПредСтрТабл = Новый Структура;
		Для Каждого Поле Из СтрТабл Цикл
			Если Поле.Ключ<>"Номенклатура" и Поле.Ключ<>"ХарактеристикаНоменклатуры"
				И Поле.Ключ<>"ИмяТЧ"
				И Поле.Ключ<>"НомерСтрокиТЧ"
				И Поле.Ключ<>"НеЗагружать" Тогда   // эти поля добавляются в структуру файла при загрузке, при выгрузке расхождения они не нужны
				ПредСтрТабл.Вставить(Поле.Ключ, Поле.Значение);
			КонецЕсли;
		КонецЦикла;
		ПреобразоватьПараметрыВМассив(ПредСтрТабл);
		НоваяСтрока.Вставить("ПредСтрТабл", ПредСтрТабл);
		СтрОтклонения.Добавить(НоваяСтрока);
	КонецЦикла;
	// Если добавились строки, которых не было в файле контрагента
	НашиСтроки = ТабЧастьНаша.НайтиСтроки(Новый Структура("ЕстьВФайлеКонтрагента", Ложь)); 
	Для Каждого СтрТабл Из НашиСтроки Цикл
		НоваяСтрока = Новый Структура();
		Для Каждого Поле Из СтруктураФайлаНаша.Файл.Документ.ТаблДок.СтрТабл[0] Цикл
			Если Поле.Ключ<>"Номенклатура" и Поле.Ключ<>"ХарактеристикаНоменклатуры" и Поле.Ключ<>"ПорНомерВФайлеКонтрагента" Тогда
				НоваяСтрока.Вставить(Поле.Ключ, СтрТабл[Поле.Ключ]);
			КонецЕсли;
		КонецЦикла;
		СтрОтклонения.Добавить(НоваяСтрока);
		Попытка
			ИтогСумма = ИтогСумма+СтрТабл.Сумма;
			ИтогКоличество = ИтогКоличество+СтрТабл.Кол_во;
			ИтогСуммаБезНал = ИтогСуммаБезНал+СтрТабл.СуммаБезНал;
			ИтогНДС = ИтогНДС+СтрТабл.НДС.Сумма;
		Исключение
		КонецПопытки;
	КонецЦикла;
	Док.Файл.Документ.Вставить("ТаблДок", Новый Структура);
	Док.Файл.Документ.ТаблДок.Вставить("ИтогТабл",Новый Массив);
	ИтогТабл = Новый Структура("Сумма,Кол_во,СуммаБезНал,НДС",ИтогСумма,ИтогКоличество,ИтогСуммаБезНал,Новый Структура("Сумма",ИтогНДС));
	Если СтруктураФайлаКонтрагента.Файл.Документ.ТаблДок.Свойство("ИтогТабл") Тогда
		ИтогТабл.Вставить("ПредИтогТабл", СтруктураФайлаКонтрагента.Файл.Документ.ТаблДок.ИтогТабл);
	КонецЕсли;
	Док.Файл.Документ.ТаблДок.ИтогТабл.Добавить(ИтогТабл);
	Док.Файл.Документ.ТаблДок.Вставить("СтрТабл", СтрОтклонения);
	Возврат Док;
КонецФункции

Функция ПреобразоватьПараметрыВМассив(СтруктураУчастника)
	Если СтруктураУчастника.Свойство("Параметр") и ТипЗнч(СтруктураУчастника.Параметр) = Тип("Структура") Тогда
		МассивПараметров = Новый Массив;
		Для Каждого Элемент Из СтруктураУчастника.Параметр Цикл
			СтруктураПараметра = Новый Структура("Имя, Значение", Элемент.Ключ, Элемент.Значение);
			Массивпараметров.Добавить(СтруктураПараметра);
		КонецЦикла;
		СтруктураУчастника.Вставить("Параметр", Массивпараметров);
	КонецЕсли;
КонецФункции

Функция МассивСтруктурВТаблицуЗначений(МассивСтруктур)
	// преобразует массив структур в таблицу значений	
	Результат = Новый ТаблицаЗначений;
	Если МассивСтруктур = Неопределено Или МассивСтруктур.Количество() = 0 Тогда
		Возврат Результат;
	Иначе 
		Образец = МассивСтруктур[0];
		Для Каждого  Стр из Образец Цикл
			Результат.Колонки.Добавить(Стр.Ключ );
		КонецЦикла;
	КонецЕсли;
	
	Для Каждого Стр Из МассивСтруктур Цикл
		СтрТ = Результат.Добавить();
		ЗаполнитьЗначенияСвойств(СтрТ, Стр);
		Попытка
			СтрТ.ОКЕИ = СокрЛП(СтрТ.ОКЕИ);	
		Исключение
		КонецПопытки;
	КонецЦикла;
	Возврат Результат;
КонецФункции

//Штатный обработчик строки подстановки
&НаКлиенте
Процедура ОбработчикДанных_ЗаполнитьСтрокуТабличнойЧастиДокумента(Аргумент, ДопПараметры) Экспорт

	Файл_Шаблон_Модуль.ОбработчикДанных_ЗаполнитьСтрокуТабличнойЧастиДокумента	(Аргумент, ДопПараметры);
	Файл_Шаблон_Модуль.ЗаполнитьТабличныеДанныеПредСтрТабл						(Аргумент, ДопПараметры);
	
КонецПроцедуры
