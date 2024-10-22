
&НаКлиенте
Функция РаботаСГосКонтрактами(СоставПакета) Экспорт
	
	// Допилить позже на доп параметры состава пакета, когда будет приходить
	Возврат ПолучитьЗначениеПараметраСБИС("ПоддержкаОбменаЕИС")
		И НРег(СоставПакета_Получить(СоставПакета, "РеализацияЕИС")) = "да";
	
КонецФункции

&НаКлиенте
Функция ПозГКПоОписаниюНоменклатурыДокумента(СтрокаДокумента, ДопПараметры = Неопределено) Экспорт

	Если ТипЗнч(СтрокаДокумента) <> Тип("Структура") Тогда
		Возврат 0;
	КонецЕсли;

	ПараметрыНоменклатуры = Неопределено;

	Если Не СтрокаДокумента.Свойство("НоменклатураДокументаРасш_Параметры", ПараметрыНоменклатуры) Тогда
		Возврат 0;
	КонецЕсли;

	ПараметрыСоответствием = РазобратьСтрокуПараметровСбис(ПараметрыНоменклатуры);
	
	Если ПараметрыСоответствием.Получить("ПозГК") = Неопределено Тогда
		Возврат 0;
	Иначе
		Возврат Число(ПараметрыСоответствием.Получить("ПозГК"));
	КонецЕсли;

КонецФункции

&НаКлиенте
Процедура ДополнитьСпецификациейПоГосКонтракту(СоставПакета, ДопПараметры = Неопределено) Экспорт
	
	ОснованияДокумента = СоставПакета_Получить(СоставПакета, "ДокументОснование");
	Договор = НовыйСоставПакета(Новый Структура);

	Для каждого Основание Из ОснованияДокумента Цикл
		Если Основание.ВидСвязи = "Договор" Тогда

			ПараметрыОбновления = Новый Структура("ДопПоля", Основание.Документ);
			СоставПакета_Обновить(Договор, ПараметрыОбновления);
			Прервать;

		КонецЕсли;
	КонецЦикла;

	ИдДоговора = СоставПакета_Получить(Договор, "Идентификатор");
	
	Если НЕ ЗначениеЗаполнено(ИдДоговора) Тогда
		Возврат;
	КонецЕсли;

	ПараметрыССпецификации = Новый Структура("doc_uuid", ИдДоговора);
	Кэш = ПолучитьТекущийЛокальныйКэш();
	Отказ = Ложь;
	ОписаниеГосКонтракта = ГлобальныйКэш.ТекущийСеанс.Модули.Интеграция.ZakupkiGovAPI_GetContractInfo(Кэш, ПараметрыССпецификации, Неопределено, Отказ);
	
	Если Отказ Тогда
		ВызватьСбисИсключение(ОписаниеГосКонтракта, "МодульОбъектаКлиент.ДополнитьСпецификациейПоГосКонтракту");
	КонецЕсли;
	
	Если НЕ ЗначениеЗаполнено(ОписаниеГосКонтракта) Тогда
		
		ПараметрыСообщения = Новый Структура("Текст", "В документе не указан договор");
		СбисСообщить(ПараметрыСообщения);
		
	КонецЕсли;
	
	Спецификация = ОписаниеГосКонтракта.nom_items;
	ПараметрыОбновления = Новый Структура("ДопПоля", Новый Структура);
	ПараметрыОбновления.ДопПоля.Вставить("Спецификация", Спецификация);
	СоставПакета_Обновить(Договор, ПараметрыОбновления);
	
	ПараметрыОбновления = Новый Структура("ДопПоля", Новый Структура);
	ПараметрыОбновления.ДопПоля.Вставить("Госконтракт", Договор);
	СоставПакета_Обновить(СоставПакета, ПараметрыОбновления);

КонецПроцедуры
