
//Функция возвращает идентификатор СБИС по пакету 1С
&НаКлиенте
Функция ИдентификаторСБИСПоДокументу(Кэш, ДокументСсылка, ДопПараметры = Неопределено) Экспорт

	ДопПараметрыВызова = Новый Структура("СтруктураРаздела", Кэш.Текущий);
	
	Если ЗначениеЗаполнено(ДопПараметры)
			И ДопПараметры.Свойство("СоставПакета") Тогда
		ДопПараметрыВызова.Вставить("ИмяРегламента", МодульОбъектаКлиент().СоставПакета_Получить(ДопПараметры.СоставПакета, "РегламентНазвание"));
	КонецЕсли;
	
	Возврат МодульОбъектаКлиент().ПрочитатьСведенияОИдСБИСПоДокументу1С(ДокументСсылка, ДопПараметрыВызова);

КонецФункции

