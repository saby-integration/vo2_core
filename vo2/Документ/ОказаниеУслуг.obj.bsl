
&НаКлиенте
Функция ПрочитатьДокумент(Кэш,Контекст) Экспорт
// Функция формирует пакеты документов по файлу настроек
// Особенность документа в том, что по одному документу формируется несколько пакетов
	ОказаниеУслугДокумент = Контекст.Документ;
	Контекст.Вставить("ФайлДанные", Новый Структура);
	ЧтоНибудьВыгрузилось = Ложь;
	СчетФактуры = Новый Массив;
	// перебираем мФайлы из файла настроек
	Для Каждого Файл Из Контекст.ДокументДанные.мФайл Цикл
		Файл = Файл.Значение;
		Контекст.ФайлДанные = Файл;
		Стр = 0;
		Для каждого ВидДокумента из Контекст.ФайлДанные.мДокумент Цикл
			ВидДокумента = ВидДокумента.Значение;
			// перебираем табличну часть, по каждой строке формируется отдельный пакет документов
			Для СчСтр = 1 по ВидДокумента.Количество() Цикл
				Контекст.Вставить("Документ", ОказаниеУслугДокумент);
				Контекст.Вставить("СоставПакета",Новый Структура);
				Кэш.КэшЗначенийИни.ТекущийПакет.Очистить();
				Контекст.СоставПакета.Вставить("Вложение",Новый Массив);
				Контекст.ФайлДанные = ВидДокумента[СчСтр-1];
				Файл_Формат = Кэш.ОбщиеФункции.РассчитатьЗначение("Файл_Формат", ВидДокумента[СчСтр-1], Кэш);
				Файл_ВерсияФормата = СтрЗаменить(СтрЗаменить(ВидДокумента[СчСтр-1].Файл_ВерсияФормата,".","_"), " ", "");
				//Подготовим контекст
				мТаблДок = Новый Структура; //В мТаблДок скопируем структуру для табличной части из корня контекста
				Кэш.ОбщиеФункции.сбисСкопироватьСтруктуруНаКлиенте(мТаблДок, ВидДокумента[СчСтр-1].мТаблДок.Услуги);
				МассивСтрок = Новый Массив;
				МассивСтрок.Добавить(мТаблДок);
				Контекст.ФайлДанные.Вставить("мТаблДок", Новый Структура("Услуги", МассивСтрок));
				
				Документ = ВидДокумента[СчСтр-1];
				Документ_Номер = Кэш.ОбщиеФункции.РассчитатьЗначение("Документ_Номер", ВидДокумента[СчСтр-1], Кэш);
				Документ.Документ_Номер = СокрЛП(Документ_Номер) + "/" + СчСтр; //Присвоим номер с дробной частью
				//В корень контекста скопируем структуру для шапки документа
				Кэш.ОбщиеФункции.сбисСкопироватьСтруктуруНаКлиенте(Контекст.ФайлДанные, Документ);
				
				фрм = Кэш.ГлавноеОкно.сбисНайтиФормуФункции("ПолучитьДанныеИзДокумента1С","Файл_"+Файл_Формат+"_"+Файл_ВерсияФормата,"Файл_Шаблон", Кэш);
				Если фрм.ПолучитьДанныеИзДокумента1С(Кэш,Контекст) Тогда //если хотябы что-то не выгрузилось - отбой
					Если Документ.Свойство("СчетФактура") и ЗначениеЗаполнено(Документ.СчетФактура) Тогда
						ИмяДокумента = Кэш.ОбщиеФункции.ПолучитьРеквизитМетаданныхОбъекта(Документ.СчетФактура, "Имя");
						Если Кэш.ини.Свойство(ИмяДокумента) Тогда
							ЗначениеИни = Кэш.ФормаНастроек.Ини(Кэш, ИмяДокумента);
							Контекст.Вставить("Документ", Документ.СчетФактура);
							ЗначениеИни.Вставить("Формат2016", Новый Структура("Значение,РассчитанноеЗначение", Истина, Истина));
							ЗначениеИни.Вставить("Формат2019", Новый Структура("Значение,РассчитанноеЗначение", Истина, Истина));
							ЗначениеИни.Вставить("ИспользоватьШтрихкодыНоменклатурыКонтрагентов",	Новый Структура("Значение,РассчитанноеЗначение", Кэш.Парам.ИспользоватьШтрихкодыНоменклатурыКонтрагентов, Кэш.Парам.ИспользоватьШтрихкодыНоменклатурыКонтрагентов));
							Контекст.Вставить("ДокументДанные", Кэш.ОбщиеФункции.ПолучитьДанныеДокумента1С(ЗначениеИни, Документ.СчетФактура,Кэш.КэшЗначенийИни, Кэш.Парам));  // alo Меркурий
							Для Каждого Файл Из Контекст.ДокументДанные.мФайл Цикл
								Файл = Файл.Значение;
								Контекст.ФайлДанные = Файл;
								Файл.Файл_Формат = Кэш.ОбщиеФункции.РассчитатьЗначение("Файл_Формат", Файл, Кэш);
								Файл_Формат = Файл.Файл_Формат;
								Файл_ВерсияФормата = СтрЗаменить(СтрЗаменить(Файл.Файл_ВерсияФормата,".","_"), " ", "");
								// в табличную часть СФ копируем табличную часть сформированного по строке документа акта
								СтруктураТаблДок = Новый Структура;
								Кэш.ОбщиеФункции.сбисСкопироватьСтруктуруНаКлиенте(СтруктураТаблДок, Контекст.СоставПакета.Вложение[0].СтруктураДокумента.Файл.Документ.ТаблДок);
								Контекст.Вставить("ТаблДок",СтруктураТаблДок);
								//+++ МАИ 14.09.2021 Добавляем в контекст постфикс для правильного формирования номера СчФ
								Если Контекст.ФайлДанные.мОснование.Свойство("ДокПодтвОтгр") Тогда
									Если ТипЗнч(Контекст.ФайлДанные.мОснование.ДокПодтвОтгр) = Тип("Массив") Тогда
										Для каждого СтрДокПодтвОтгр Из Контекст.ФайлДанные.мОснование.ДокПодтвОтгр Цикл
											СтрДокПодтвОтгр.Вставить("НомДокПостфикс", СчСтр);	
										КонецЦикла;
									Иначе
										Контекст.ФайлДанные.мОснование.ДокПодтвОтгр.Вставить("НомДокПостфикс", СчСтр);
										Контекст.ФайлДанные.Вставить("НомДокПостфикс", СчСтр);
									КонецЕсли;
								КонецЕсли;
								//--- МАИ 14.09.2021
								фрм = Кэш.ГлавноеОкно.сбисНайтиФормуФункции("ПолучитьШапкуИзДокумента1С","Файл_"+Файл_Формат+"_"+Файл_ВерсияФормата,"Файл_Шаблон",Кэш);			
								Если фрм <> Ложь И Не фрм.ПолучитьШапкуИзДокумента1С(Кэш,Контекст) Тогда //если хотябы что-то не выгрузилось - отбой
									ВсеВыгрузилось = Ложь;
								КонецЕсли;
							КонецЦикла;
							
						КонецЕсли;
					КонецЕсли;
					ИмяДокумента = Кэш.ОбщиеФункции.ПолучитьРеквизитМетаданныхОбъекта(Контекст.Документ, "Имя");
					Контекст.СоставПакета.Вставить("ПользовательскийИдентификатор", ИмяДокумента+":"+строка(Контекст.Документ.УникальныйИдентификатор())+"_"+Формат(СчСтр, "ЧГ=0"));
					Контекст.МассивПакетов.Добавить(Контекст.СоставПакета);
					ЧтоНибудьВыгрузилось = Истина;
				КонецЕсли;
			КонецЦикла;	
		КонецЦикла;				
	КонецЦикла;
	Возврат ЧтоНибудьВыгрузилось;
КонецФункции
&НаКлиенте
Функция ПрочитатьТабличнуюЧасть(Кэш,Контекст) Экспорт
// Функция формирует табличную часть документа	
	ИмяДокумента = Кэш.ОбщиеФункции.ПолучитьРеквизитМетаданныхОбъекта(Контекст.Документ, "Имя");
	ВсеВыгрузилось = Истина;
	Если Кэш.ини.Свойство(ИмяДокумента) Тогда
		Для Каждого Файл Из Контекст.ДокументДанные.мФайл Цикл
			Файл = Файл.Значение;
			Контекст.ФайлДанные = Файл;
			Стр = 0;
			Для каждого ВидДокумента из Контекст.ФайлДанные.мДокумент Цикл
				ВидДокумента = ВидДокумента.Значение;
				Для СчСтр = 1 по ВидДокумента.Количество() Цикл
					Если ВидДокумента[СчСтр-1].СчетФактура = Контекст.СФ Тогда
						Контекст.Вставить("СоставПакета",Новый Структура);
						Кэш.КэшЗначенийИни.ТекущийПакет.Очистить();
						Контекст.СоставПакета.Вставить("Вложение",Новый Массив);
						Контекст.ФайлДанные = ВидДокумента[СчСтр-1];
						Файл_Формат = Кэш.ОбщиеФункции.РассчитатьЗначение("Файл_Формат", ВидДокумента[СчСтр-1], Кэш);
						Файл_ВерсияФормата = СтрЗаменить(СтрЗаменить(ВидДокумента[СчСтр-1].Файл_ВерсияФормата,".","_"), " ", "");
						мТаблДок = Новый Структура; //В мТаблДок скопируем структуру для табличной части из корня контекста
						Кэш.ГлавноеОкно.сбисПолучитьФорму("РаботаСДокументами1С").сбисСкопироватьСтруктуру(мТаблДок, ВидДокумента[СчСтр-1].мТаблДок.Услуги);
						МассивСтрок = Новый Массив;
						МассивСтрок.Добавить(мТаблДок);
						Контекст.ФайлДанные.Вставить("мТаблДок", Новый Структура("Услуги", МассивСтрок));

						фрм = Кэш.ГлавноеОкно.сбисНайтиФормуФункции("ПолучитьТабличнуюЧастьДокумента1С","Файл_"+Файл_Формат+"_"+Файл_ВерсияФормата,"Файл_Шаблон",Кэш);			
						фрм.ПолучитьТабличнуюЧастьДокумента1С(Кэш,Контекст)
            		КонецЕсли;
			    КонецЦикла;
			КонецЦикла;
		КонецЦикла;
	Иначе
		Сообщить("Не найдены настройки для документа: "+ИмяДокумента);
		ВсеВыгрузилось = Ложь;
	КонецЕсли;
	Возврат ВсеВыгрузилось;
КонецФункции