
&НаКлиенте
Процедура ПереопределитьСпособыОбмена()
	ЭлементыФормочки = ПолучитьЭлементыФормы();
	#Если ВебКлиент Тогда
		ExtSdkCrypto = ЭлементыФормочки.exchange_method.СписокВыбора.НайтиПоЗначению("ExtSdkCrypto");
		Если ExtSdkCrypto <> Неопределено Тогда
			ЭлементыФормочки.exchange_method.СписокВыбора.Удалить(ExtSdkCrypto);
		КонецЕсли;	
		SabyConnect = ЭлементыФормочки.exchange_method.СписокВыбора.НайтиПоЗначению("SabyConnect");
		Если SabyConnect <> Неопределено Тогда
			ЭлементыФормочки.exchange_method.СписокВыбора.Удалить(SabyConnect);
		КонецЕсли;	
	    ExtSdk = ЭлементыФормочки.exchange_method.СписокВыбора.НайтиПоЗначению("ExtSdk");
		Если ExtSdk <> Неопределено Тогда
			ЭлементыФормочки.exchange_method.СписокВыбора.Удалить(ExtSdk);
		КонецЕсли;
		SabyPluginConnector = ЭлементыФормочки.exchange_method.СписокВыбора.НайтиПоЗначению("SabyPluginConnector");
		Если SabyPluginConnector <> Неопределено Тогда
			ЭлементыФормочки.exchange_method.СписокВыбора.Удалить(SabyPluginConnector);
		КонецЕсли;
	#КонецЕсли
	#Если ТолстыйКлиентОбычноеПриложение Тогда
		APIClient = ЭлементыФормочки.exchange_method.СписокВыбора.НайтиПоЗначению("APIClient");
		Если APIClient <> Неопределено Тогда
			ЭлементыФормочки.exchange_method.СписокВыбора.Удалить(APIClient);
		КонецЕсли;
		APIServer = ЭлементыФормочки.exchange_method.СписокВыбора.НайтиПоЗначению("API");
		Если APIServer <> Неопределено Тогда
			APIServer.Представление = "API";	
		КонецЕсли;
		ЭтаФорма.exchange_method = get_prop(context_params, ИмяСвойстваТранспорта(), "API");
	#КонецЕсли	
КонецПроцедуры
