
&НаКлиенте
Процедура ВидОтчетаПриИзменении(Элемент)
	ВидОтчетаПриИзмененииНаСервере();
КонецПроцедуры

&НаСервере
Процедура ВидОтчетаПриИзмененииНаСервере()
	//ИДККМ = Отчет.КомпоновщикНастроек.Настройки.ПараметрыДанных.Элементы.Найти("ККМ").ИдентификаторПользовательскойНастройки;
	//ИДПериод = Отчет.КомпоновщикНастроек.Настройки.ПараметрыДанных.Элементы.Найти("Период").ИдентификаторПользовательскойНастройки;
	//ККМПараметр = Отчет.КомпоновщикНастроек.ПользовательскиеНастройки.Элементы.Найти(ИДККМ).Значение;
	//ПериодПараметр = Отчет.КомпоновщикНастроек.ПользовательскиеНастройки.Элементы.Найти(ИДПериод).Значение;
	
	ИДККМ = Отчет.КомпоновщикНастроек.Настройки.Отбор.Элементы.Получить(0).ИдентификаторПользовательскойНастройки;
	ККМПараметр = Отчет.КомпоновщикНастроек.ПользовательскиеНастройки.Элементы.Найти(ИДККМ).ПравоеЗначение;
	ИДПериод = Отчет.КомпоновщикНастроек.Настройки.ПараметрыДанных.Элементы.Найти("Период").ИдентификаторПользовательскойНастройки;
	ПериодПараметр = Отчет.КомпоновщикНастроек.ПользовательскиеНастройки.Элементы.Найти(ИДПериод).Значение;
	
	Если ВидОтчета=1 тогда
		Отчет.КомпоновщикНастроек.ЗагрузитьНастройки(РеквизитФормыВЗначение("Отчет").СхемаКомпоновкиДанных.ВариантыНастроек.НДС.Настройки);
	ИначеЕсли ВидОтчета=2 тогда
		Отчет.КомпоновщикНастроек.ЗагрузитьНастройки(РеквизитФормыВЗначение("Отчет").СхемаКомпоновкиДанных.ВариантыНастроек.Основной.Настройки);
	ИначеЕсли ВидОтчета=3 тогда
		Отчет.КомпоновщикНастроек.ЗагрузитьНастройки(РеквизитФормыВЗначение("Отчет").СхемаКомпоновкиДанных.ВариантыНастроек.ПоВидуЧека.Настройки);
	КонецЕсли;
	
	//Если не ЗначениеЗаполнено(ККМПараметр) тогда
	//	ККМПараметр = справочники.ККМ.ПустаяСсылка();
	//КонецЕсли;
	
	//ИДККМ = Отчет.КомпоновщикНастроек.Настройки.ПараметрыДанных.Элементы.Найти("ККМ").ИдентификаторПользовательскойНастройки;
	//ИДПериод = Отчет.КомпоновщикНастроек.Настройки.ПараметрыДанных.Элементы.Найти("Период").ИдентификаторПользовательскойНастройки;
	ИДККМ = Отчет.КомпоновщикНастроек.Настройки.Отбор.Элементы.Получить(0).ИдентификаторПользовательскойНастройки;
	ИДПериод = Отчет.КомпоновщикНастроек.Настройки.ПараметрыДанных.Элементы.Найти("Период").ИдентификаторПользовательскойНастройки;

	Отчет.КомпоновщикНастроек.ПользовательскиеНастройки.Элементы.Найти(ИДККМ).ПравоеЗначение = ККМПараметр;
	Отчет.КомпоновщикНастроек.ПользовательскиеНастройки.Элементы.Найти(ИДПериод).Значение = ПериодПараметр;
	Результат.Очистить();
КонецПроцедуры

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	ВидОтчета = 3;
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	ВидОтчетаПриИзмененииНаСервере();
КонецПроцедуры

