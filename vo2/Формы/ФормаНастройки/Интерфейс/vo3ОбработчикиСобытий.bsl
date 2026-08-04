
#Область include_core_base_Авторизация_НастройкиПодключенияПрокси   
#КонецОбласти

#Область include_core_base_Helpers_FormGetters
#КонецОбласти

&НаКлиенте
Процедура ПереключитьСтраницуНастройкиПодключенияПрокси()
КонецПроцедуры

&НаКлиенте
Процедура СпособОбменаПриИзмененииПереопределяемый(Элемент)
КонецПроцедуры

&НаКлиенте
Процедура ОбновитьЗаголовок()
	ЭлФорм = ПолучитьЭлементыФормы();
	ЭлФорм.ПодключитьсяК.Заголовок = СтрЗаменить(api_url, "https://", "");
КонецПроцедуры

&НаКлиенте
Процедура ЗаполнитьПараметрыВО3() 
	// BSLLS:UnusedLocalVariable-off Переменная формы
	ТранспортИнтеграции = ПолучитьФормуТранспорта(ЭтаФорма.context_params);
	// BSLLS:UnusedLocalVariable-on
	ЗаполнитьСписокСтран();
	ПрочитатьНастройки();
	ЭтаФорма.AdvancedLog = get_prop(context_params, "AdvancedLog", ЭтаФорма.AdvancedLog);
	AdvancedLogПриИзменении(ЭтаФорма.AdvancedLog);
	ЭлементыФормочки = ПолучитьЭлементыФормы();
	Если ЭтаФорма.Country = "" Тогда
		ЭтаФорма.Country = ЭлементыФормочки.Country.СписокВыбора.Получить(0).Значение;
	КонецЕсли;
	ЗаполнитьСписокПриложений();
	ЗаполнитьСписокКонтуров();
	ЭтаФорма.Domain = Нрег(get_prop(context_params, "Domain", ЭтаФорма.Domain));
	ЭтаФорма.Contour = get_prop(context_params, "Contour", ЭтаФорма.Contour);
	УстановитьВидимостьВключенияГОСТШифрования();
	УстановитьВидимостьГОСТШифрования();
	ИзменитьЗаголовкиНастройкиПодключенияПрокси(); 
	СпособОбменаПриИзменении(Ложь);
КонецПроцедуры

&НаКлиенте
Процедура ИзменитьЗаголовкиНастройкиПодключенияПрокси()
	ЭлементыФормочки = ПолучитьЭлементыФормы();
	ЭлементыФормочки.РежимВходаПоЛогину1.Видимость = Ложь;
	ЭлементыФормочки.Настройки1.Видимость = Ложь;
	ЭлементыФормочки.Параметрыпрокси.Шрифт = Новый Шрифт(,,14);
КонецПроцедуры

&НаСервере
Процедура ПрочитатьНастройки() 
	Модуль = МодульОбъектаСервер();
	ЭтаФорма.context_params = Модуль.НастройкиПодключенияПрочитать();
	
	Если ЭтаФорма.context_params = Неопределено Тогда
		ЭтаФорма.context_params = Новый Структура();
	КонецЕсли;
	ЭтаФорма.password		 = get_prop(context_params, "password", "");
	ЭтаФорма.login			 = get_prop(context_params, "login", "");
	ЭтаФорма.api_url		 = get_prop(context_params, "ApiUrl", "");
	ЭтаФорма.exchange_method = get_prop(context_params, ИмяСвойстваТранспорта(), "API");
	ЭтаФорма.GostTls 		 = get_prop(context_params, "GostTls", Ложь);
	Если GostTls = Истина Тогда
		ЭтаФорма.ShowGostTls = 7;
	Иначе
		ЭтаФорма.ShowGostTls = 0;
	КонецЕсли;
	ЭтаФорма.Country 		 = Нрег(get_prop(context_params, "Country", ""));
	ЭтаФорма.ProxyType		 = get_prop(ЭтаФорма.context_params, "ProxyType", "SystemSettings");
	proxy					 = get_prop(ЭтаФорма.context_params, "Proxy");
	ЭтаФорма.ProxyProtocol	 = get_prop(proxy, "Protocol", "");
	ЭтаФорма.ProxyServer	 = get_prop(proxy, "Server", "");
	ЭтаФорма.ProxyPort		 = get_prop(proxy, "Port", 0);
	ЭтаФорма.ProxyLogin		 = get_prop(proxy, "User", "");
	ЭтаФорма.ProxyPassword	 = get_prop(proxy, "Password", "");
	ИспользоватьАутентификациюОС = get_prop(proxy, "ProxyUseOSAuthentication", Ложь);
	Если ИспользоватьАутентификациюОС Тогда
		ЭтаФорма.ProxyUseOSAuthentication = "Аутентификация через операционную систему";
	Иначе
		ЭтаФорма.ProxyUseOSAuthentication = "Базовая аутентификация";
	КонецЕсли;
	ЭтаФорма.ExchangeCatalog	 = get_prop(context_params, "ExchangeCatalog", "");
	ЭтаФорма.EncryptSelectively  = get_prop(context_params, "EncryptSelectively", Ложь);
	ЭтаФорма.Timeout 			 = get_prop(context_params, "Timeout", 60);
	ЭтаФорма.AdvancedLog		 = get_prop(context_params, "AdvancedLog", Ложь);
	ЭтаФорма.LoggingCatalog		 = get_prop(context_params, "LoggingCatalog", "");
	ЭтаФорма.AuthSSOUrl			 = get_prop(context_params, "AuthSSOUrl", "");
КонецПроцедуры

&НаСервере
Процедура СохранитьНастройкиПодключения(ПараметрыИзменено)
	Модуль = МодульОбъектаСервер();
	Если get_prop(ПараметрыИзменено, "ТребуетсяАвторизация") = Истина Тогда
		ЭтаФорма.context_params.Вставить("Session", Неопределено);
		ЭтаФорма.context_params.Вставить("SessionExtSdk", Неопределено);
	КонецЕсли;
	Модуль.НастройкиПодключенияЗаписать(ЭтаФорма.context_params);	
КонецПроцедуры


&НаКлиенте
Процедура ПереложитьНастройкиВО3вВО2()
	
	РазобранныйАдрес = СбисПолучитьСтруктуруРазобраногоАдреса();
	АдресСервера = МодульОбъектаКлиент().СбисСобратьАдресСервера(РазобранныйАдрес);
	// BSLLS:UnusedLocalVariable-off Реквизиты формы
	Если ProxyType = "SystemSettings" Тогда
		ТипПрокси = "Автоматически";
	ИначеЕсли ProxyType = "NotUse" Тогда
		ТипПрокси = "НеИспользовать";
	Иначе 
		ТипПрокси = "Вручную";
		Proxy = get_prop(context_params, "Proxy");
		Protocol = get_prop(Proxy, "Protocol");
		Server = get_prop(Proxy, "Server");
		Port = get_prop(Proxy, "Port");
		User = get_prop(Proxy, "User");
		Password = get_prop(Proxy, "Password");
		ПроксиСервер = ProxyServer;
		ПроксиПорт = ProxyPort;
		ПроксиЛогин = ProxyLogin;
		ПроксиПароль = ProxyPassword;
	КонецЕсли;
	
	Транспорт = exchange_method;
	Если Транспорт = "ExtSdk" Тогда
		СпособОбмена = 6;
	ИначеЕсли Транспорт = "ExtSdkCrypto" Тогда
		СпособОбмена = 7;
	ИначеЕсли Транспорт = "API" Тогда
		СпособОбмена = 3;
		ИнтеграцияAPIВызовыНаКлиенте = Ложь;
	ИначеЕсли Транспорт = "APIClient" Тогда
		СпособОбмена = 3;
		ИнтеграцияAPIВызовыНаКлиенте = Истина;
	ИначеЕсли Транспорт = "SabyHttpsClient" Тогда
		СпособОбмена = 9;
	ИначеЕсли Транспорт = "SabyPluginConnector" Тогда
		СпособОбмена = 8;
	Иначе
		СпособХраненияНастроек = 0;
		СпособОбмена = 1;
	КонецЕсли;
		
    ШифроватьВыборочно = EncryptSelectively;
	ВремяОжиданияОтвета = Timeout;
	КаталогОбмена = ExchangeCatalog;
	РежимОтладки = AdvancedLog;
	КаталогОтладки = LoggingCatalog;
	ЭтаФорма.context_params.Вставить("AdvancedLog", AdvancedLog);
	ЭтаФорма.context_params.Вставить("LoggingCatalog", LoggingCatalog);
	// BSLLS:UnusedLocalVariable-on
КонецПроцедуры


#Область include_core_base_Helpers_ПоказатьОповещениеПользователя
#КонецОбласти

#Область include_core_base_Helpers_Картинки
#КонецОбласти
