
// Функция записывает статистику стандартизированного формата
//
// Параметры:
//  params  - Структура - Параметры фильтрации метода
//  ДопПараметры  - Структура - Набор полей, работа с которыми может расширить результат работы функции.
//
// Возвращаемое значение:
//   Структура   - Результат вызова. Список объектов или ошибка
//
&НаКлиенте
Функция ExtSysMarking_SendStatisticData(params, ДопПараметры, Отказ=Ложь) Экспорт  
	
	Кэш = ДопПараметры.Кэш;
	ДопПараметрыВызова = Новый Структура("ВернутьОшибку, СообщатьПриОшибке", Истина, Ложь);  
	ПараметрыКоманды = Новый Структура("functional,context_data,action", params.Функционал,params.Контекст,params.Действие);  
	
	Результат = сбисОтправитьИОбработатьКоманду(Кэш, "ExtSysMarking.SendStatisticData", ПараметрыКоманды, ДопПараметрыВызова, Отказ);   
	Если Отказ Тогда
		Возврат Кэш.ОбщиеФункции.сбисИсключение(Результат,  Кэш.СБИС.ПараметрыИнтеграции.ИнтеграцияИмя + ".ExtSysMarking_SendStatisticData");
	КонецЕсли;
	Возврат Результат;
	
КонецФункции

