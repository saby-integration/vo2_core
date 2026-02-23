
&НаКлиенте
Функция НовыйMappingObject(ДопПараметры) Экспорт

	MappingObject = _MappingObject_Структура(ДопПараметры);
	MappingObject.Вставить("_класс", "MappingObject");
	MappingObject.Integration = ПолучитьИдИнтеграции();
	
	Если ДопПараметры.Свойство("ДанныеОбъекта") Тогда
		НовыйMappingObject_ПоДаннымОбъекта(MappingObject, ДопПараметры);
	КонецЕсли;
	
	Возврат MappingObject;

КонецФункции

#Область include_core2_vo2_МодульОбъекта_Клиент_Классы_MappingObject_private
#КонецОбласти

