
&НаКлиенте
Функция ПолучитьДанныеИзДокумента1С(Кэш,Контекст) Экспорт
// Функция формирует структуру выгружаемого файла и добавляет его в состав пакета
	Попытка	
				
		Док  = Новый Структура;
		МассивСтатусРегламент = Новый Массив;
		ЗапретРедакций = Ложь;
		Если Контекст.ФайлДанные.Свойство("мСторона") Тогда
			Для Каждого Параметр Из Контекст.ФайлДанные.мСторона Цикл
				Роль = Кэш.ОбщиеФункции.РассчитатьЗначение("Роль",Параметр.Значение,Кэш);
				Сторона = Кэш.ОбщиеФункции.ПолучитьСторону(Кэш,Параметр.Значение);  
				Если Роль = "Отправитель" Тогда
					Сертификат = Кэш.ОбщиеФункции.РассчитатьЗначение("Сертификат",Параметр.Значение,Кэш);
				КонецЕсли;    
				Если Роль = "Получатель" Тогда
					ЗапретРедакций = Кэш.ОбщиеФункции.РассчитатьЗначение("ЗапретРедакций",Параметр.Значение,Кэш);
				КонецЕсли;
				Если Сторона<>Неопределено Тогда
					Если Сторона.Свойство("Подразделение") и Сторона.Подразделение.Свойство("Идентификатор") Тогда
						Если Сторона.Свойство("СвЮЛ") Тогда
							Сторона.СвЮЛ.Вставить("КодФилиала", Сторона.Подразделение.Идентификатор);
						ИначеЕсли Сторона.Свойство("СвФЛ") Тогда
							Сторона.СвФЛ.Вставить("КодФилиала", Сторона.Подразделение.Идентификатор);
						КонецЕсли;
					КонецЕсли;
					Док.Вставить(Роль,Сторона);
				КонецЕсли;
			КонецЦикла;
		КонецЕсли;
		// Если грузополучатель является филиалом получателя, то получаетелем пакета ставим грузополучателя
		Если Док.Свойство("Грузополучатель") Тогда
			Если Док.Грузополучатель.Свойство("СвЮЛ") и Док.Получатель.Свойство("СвЮЛ") и Док.Грузополучатель.СвЮЛ.ИНН = Док.Получатель.СвЮЛ.ИНН и Док.Грузополучатель.СвЮЛ.КПП <> Док.Получатель.СвЮЛ.КПП Тогда
				//Попытка
				//	оГрузополучатель = Кэш.Интеграция.ПолучитьИнформациюОКонтрагенте(Кэш, Док.Грузополучатель);
				//	оПолучатель = Кэш.Интеграция.ПолучитьИнформациюОКонтрагенте(Кэш, Док.Получатель);
				//	Если оПолучатель.Идентификатор = оГрузополучатель.Идентификатор Тогда
						Док.Получатель = Док.Грузополучатель;
				//	КонецЕсли;
				//Исключение
				//КонецПопытки;
			КонецЕсли;
		КонецЕсли; 
		НеЗапускатьВДокументооборот = Кэш.ОбщиеФункции.РассчитатьЗначение("НеЗапускатьВДокументооборот", Контекст.ФайлДанные,Кэш);		
		Тип = Кэш.ОбщиеФункции.РассчитатьЗначение("Тип", Контекст.ФайлДанные,Кэш);
		Подтип = Кэш.ОбщиеФункции.РассчитатьЗначение("Подтип", Контекст.ФайлДанные,Кэш);
		ОтветственныйСтруктура = Кэш.ОбщиеФункции.ПолучитьСтруктуруОтветственного(Кэш,Контекст);
		ПодразделениеСтруктура = Кэш.ОбщиеФункции.ПолучитьСтруктуруПодразделения(Кэш,Контекст);
		РегламентСтруктура = Кэш.ОбщиеФункции.ПолучитьСтруктуруРегламента(Кэш,Контекст);
		ОснованияМассив = Кэш.ОбщиеФункции.ПолучитьМассивОснований(Кэш,Контекст);
		Примечание = Кэш.ОбщиеФункции.РассчитатьЗначение("Примечание", Контекст.ФайлДанные,Кэш);
		Дата = Кэш.ОбщиеФункции.РассчитатьЗначение("Документ_Дата", Контекст.ФайлДанные,Кэш);
		Номер = Кэш.ОбщиеФункции.РассчитатьЗначение("Документ_Номер", Контекст.ФайлДанные,Кэш);
		Сумма = Кэш.ОбщиеФункции.РассчитатьЗначение("Документ_Сумма", Контекст.ФайлДанные,Кэш);
		Провести = Кэш.ОбщиеФункции.РассчитатьЗначение("Провести", Контекст.ФайлДанные,Кэш); // alo Провести
					
		фрм = Кэш.ГлавноеОкно.сбисНайтиФормуФункции("сбисПослеФормированияДокумента","Файл_"+Контекст.ФайлДанные.Файл_Формат+"_"+СтрЗаменить(СтрЗаменить(Контекст.ФайлДанные.Файл_ВерсияФормата, ".", "_"), " ", ""),"Файл_Шаблон", Кэш);
		Если фрм<>Ложь Тогда
			фрм.сбисПослеФормированияДокумента(Док, Кэш, Контекст);	
		КонецЕсли;
		Если НЕ ЗначениеЗаполнено(Сертификат) Тогда
			Сертификат = Новый Структура;	
		КонецЕсли;
		ИмяДокумента = Кэш.ОбщиеФункции.ПолучитьРеквизитМетаданныхОбъекта(Контекст.Документ, "Имя");
		ПользовательскийИдентификатор = Кэш.ОбщиеФункции.РассчитатьЗначение("Документ_ПользовательскийИдентификатор", Контекст.ФайлДанные, Кэш);
		
		//KES 050751151 Статусы в разрезе регламентов (ОТПРАВКА ПАКЕТА ДОКУМЕНТОВ)-->  39 +
		Если Кэш.ФормаРаботыСоСтатусами = "Статусы_Регистры" 
			И (Кэш.Парам.СпособОбмена = 0 ИЛИ Кэш.Парам.СпособОбмена = 3)
			И Кэш.ини.Конфигурация.Свойство("СтатусРегламент") Тогда
			МассивСтатусРегламент = Кэш.ОбщиеФункции.РазбитьСтрокуВМассивНаКлиенте(Кэш.ини.Конфигурация.СтатусРегламент.Значение,",");
		КонецЕсли;
		//<-- KES 050751151 Статусы в разрезе регламентов (ОТПРАВКА ПАКЕТА ДОКУМЕНТОВ)

		//KES 050751151 Статусы в разрезе регламентов (ОТПРАВКА ПАКЕТА ДОКУМЕНТОВ) --> 40 +
		Если ЗначениеЗаполнено(РегламентСтруктура) 
			И РегламентСтруктура.Свойство("Название") 
			И НЕ МассивСтатусРегламент.Найти(РегламентСтруктура.Название) = Неопределено Тогда
			//проверка, нет ли ранее сохраненного ид редакция
			фрм = Кэш.ГлавноеОкно.сбисНайтиФормуФункции("ПрочитатьПараметрыДокументаСБИС",Кэш.ФормаРаботыСоСтатусами,"",Кэш);
			ИдДок = фрм.ПрочитатьПараметрыДокументаСБИС(Контекст.Документ,Кэш.ГлавноеОкно.Кэш.Парам.КаталогНастроек,РегламентСтруктура.Название+"ДокументСБИС_Ид",Кэш.Ини);
			//если первая отправка - новый ид
			ПользовательскийИдентификатор= ИмяДокумента+":"+?( ЗначениеЗаполнено(ИдДок), ИдДок,строка(Новый УникальныйИдентификатор) );	
		КонецЕсли;
					
		Если НЕ ЗначениеЗаполнено(	ПользовательскийИдентификатор ) Тогда
			ПользовательскийИдентификатор = ИмяДокумента+":"+строка(Контекст.Документ.УникальныйИдентификатор());
		КонецЕсли;
		//<--KES 050751151 Статусы в разрезе регламентов (ОТПРАВКА ПАКЕТА ДОКУМЕНТОВ)

		Если Док.Свойство("Получатель") Тогда 
			Если ЗапретРедакций = Истина Тогда
				Док.Получатель.Вставить("ЗапретРедакций", Истина);		
			КонецЕсли;
			Вложение = Новый Структура("НашаОрганизация,Контрагент,Ответственный,Подразделение,Регламент,Тип,Подтип,ДокументОснование,Примечание,Сертификат,ПользовательскийИдентификатор,НеЗапускатьВДокументооборот,Дата,Номер,Сумма", Док.Отправитель,Док.Получатель,ОтветственныйСтруктура,ПодразделениеСтруктура,РегламентСтруктура,Тип,Подтип,ОснованияМассив, Примечание,Сертификат,ПользовательскийИдентификатор,НеЗапускатьВДокументооборот,Дата,Номер,Сумма);
		Иначе
			Вложение = Новый Структура("НашаОрганизация,Ответственный,Подразделение,Регламент,Тип,Подтип,ДокументОснование,Примечание,Сертификат,ПользовательскийИдентификатор,НеЗапускатьВДокументооборот,Дата,Номер,Сумма", Док.Отправитель,ОтветственныйСтруктура,ПодразделениеСтруктура,РегламентСтруктура,Тип,Подтип,ОснованияМассив, Примечание,Сертификат,ПользовательскийИдентификатор,НеЗапускатьВДокументооборот,Дата,Номер,Сумма);
		КонецЕсли;
		ДопПоля= Новый Структура;	// alo ДопПоля
		Кэш.ОбщиеФункции.ЗаполнитьАтрибуты(Кэш,"ДопПоля",Контекст.ФайлДанные,ДопПоля);
		Если ЗначениеЗаполнено(ДопПоля) Тогда
			Вложение.Вставить("ДопПоля",ДопПоля);
		Конецесли;
		Если ЗначениеЗаполнено(Провести) Тогда // alo Провести
			Вложение.Вставить("Провести",Провести);	
		КонецЕсли;
		Контекст.СоставПакета.Вставить("Конверт",Вложение);
		Возврат Истина;
		
	Исключение
		Если Кэш.Свойство("РезультатОтправки") Тогда
			Кэш.РезультатОтправки.НеСформировано = Кэш.РезультатОтправки.НеСформировано+1;
			Кэш.РезультатОтправки.ОшибкиДоОтправки = Кэш.РезультатОтправки.ОшибкиДоОтправки + 1;
			Кэш.ОбщиеФункции.ДобавитьОшибкуВРезультатОтправки(Кэш, "Документ не сформирован", ОписаниеОшибки(), Контекст.Документ, 726)
		КонецЕсли;
		Сообщить(ОписаниеОшибки());
		Возврат Ложь;
	КонецПопытки;
КонецФункции