
&НаКлиенте
Процедура ВнешнееСобытие(Источник, Событие, Данные)
	//Если Источник = "BarCodeScaner" тогда
	//	Если Событие = "BarCodeValue" тогда
	//		Scan.ПосылкаДанных = 1;   
	//		Если ЭтаФорма.ВводДоступен() тогда
	//			ВнешнееСобытиеНаСервере("%"+Строка(Данные)+"%");	
	//		КонецЕсли;
	//	КонецЕсли;
	//КонецЕсли;
	
	// ЕМ ********************************************
	// ПодключаемоеОборудование
	Если //Источник = "ПодключаемоеОборудование"
		//И 
		ВводДоступен() Тогда
		//Если Событие = "ScanData" Тогда
		Если Событие = "Штрихкод" Тогда
			Если Не ОбработатьПолученныйШКНаКлиенте(Данные) Тогда
				СообщитьОбОшибке(Данные)
			КонецЕсли;
		КонецЕсли;
	КонецЕсли;
	// Конец ПодключаемоеОборудование
	//******************************************** ЕМ 
	
КонецПроцедуры

&НаСервере
Процедура ВнешнееСобытиеНаСервере(ШК)
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	Сотрудники.Ссылка
	|ИЗ
	|	Справочник.Сотрудники КАК Сотрудники
	|ГДЕ
	|	Сотрудники.ШтрихКод ПОДОБНО &ШК";
	Запрос.УстановитьПараметр("ШК",ШК);
	Выборка = Запрос.Выполнить().Выбрать();
	МассивНоменклатуры = Новый Массив;
	Пока Выборка.Следующий() цикл
		МассивНоменклатуры.Добавить(Выборка.Ссылка);
	КонецЦикла;
	Список.Отбор.Элементы.Очистить();
	Если МассивНоменклатуры.Количество() > 0 тогда
		ЭлементОтбора = Список.Отбор.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
		ЭлементОтбора.ЛевоеЗначение = Новый ПолеКомпоновкиДанных("Ссылка");
		ЭлементОтбора.ВидСравнения = ВидСравненияКомпоновкиДанных.ВСписке;
		ЭлементОтбора.Использование = Истина;
		ЭлементОтбора.ПравоеЗначение = МассивНоменклатуры;	
	Иначе
		Сообщить("Сотрудник не найден!");
	КонецЕсли;
КонецПроцедуры


// Функция обрабатывает полученный штрихкод от сканера штрихкодов на клиенте.
//
&НаКлиенте
Функция ОбработатьПолученныйШКНаКлиенте(ТекКод)
	
	Результат = Истина;
	Элемент = ОбработатьПолученныйШКНаСервере(ТекКод);
	Если Элемент <> Неопределено Тогда
		//Элемент = НайтиЭлементСправочникаНаСервере(КодЭлемента);
		
		//ПараметрыОткрытия = Новый Структура("Ключ", Элемент);
		//ОткрытьФорму("Справочник.Сотрудники.Форма.ФормаЭлемента",ПараметрыОткрытия);
		Элементы.Список.ТекущаяСтрока = Элемент;
	Иначе
		Результат = Ложь;
	КонецЕсли;
	
	Возврат Результат;
	
КонецФункции

// Функция обрабатывает полученный штрихкод от сканера штрихкодов на сервере.
//
&НаСервере
Функция ОбработатьПолученныйШКНаСервере(ТекКод)
	
	ТабЭлементов = ПоискПоШтрихкоду(ТекКод);
	Если ТабЭлементов.Количество() Тогда
		Результат = ТабЭлементов[0].Сотрудник;
	Иначе
		Результат = Неопределено;
	КонецЕсли;
	Возврат Результат;
	
КонецФункции

// Функция возвращает результат поиска по штрихкоду в справочнике Номенклатура.
//
// Параметры:
// ШКод - Строка - проверяемый штрихкод.
// ТольКод - Булево - признак изменения текста запроса.
//
// Возвращаемое значение зависит от входного параметра ТолькоКод:
//
//   ТолькоКод = Ложь:
//    ТаблицаЗначений - колонки: Номенклатура, Цена, ЕдиницаИзмерения, Весовой.
//
//   ТолькоКод = Истина
//    ТаблицаЗначений - колонки: Код.
//
Функция ПоискПоШтрихкоду(ШКод) Экспорт
	
	//ТипШК = ОпределитьТипШтрихкода(ШКод);
	
	Запрос = Новый Запрос();
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	Сотрудники.Ссылка КАК Сотрудник
	|ИЗ
	|	Справочник.Сотрудники КАК Сотрудники
	//|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.ЗаводскиеШК КАК Штрихкоды
	//|		ПО (Штрихкоды.Владелец.Ссылка = СпрНоменклатура.Ссылка)
	|ГДЕ
	//|	Штрихкоды.ТипШтрихкода = &ТипШК
	|	Сотрудники.Штрихкод = &ШКод";
	
	//Если ТолькоКод Тогда
	//	ЗаменяемыйТекст = "
	//	|	Штрихкоды.Владелец КАК Номенклатура";
	//	ТекстЗамены = "
	//	|	СпрНоменклатура.Код";
	//	Запрос.Текст = СтрЗаменить(Запрос.Текст, ЗаменяемыйТекст, ТекстЗамены);
	//КонецЕсли;
	
	//Запрос.УстановитьПараметр("ТипШК", ТипШК);
	Запрос.УстановитьПараметр("ШКод", ШКод);
	
	Результат = Запрос.Выполнить();
	Возврат Результат.Выгрузить();
	
КонецФункции

// Функция возвращает элемент справочника (СправочникСсылка.Номенклатура).
//
&НаСервере
Функция НайтиЭлементСправочникаНаСервере(КодЭлемента)
	
	Возврат Справочники.Сотрудники.НайтиПоКоду(КодЭлемента);
	
КонецФункции

&НаКлиенте
Процедура СообщитьОбОшибке(ТекКод)
	
	ТекстСообщения = НСтр("ru = 'Позиция номенклатуры не найдена'");
	ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ТекстСообщения);
	
КонецПроцедуры


#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	ИспользоватьПодключаемоеОборудование = МенеджерОборудованияВызовСервераПереопределяемый.ИспользоватьПодключаемоеОборудование();
	
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	// ПодключаемоеОборудование
	ОповещенияПриПодключении = Новый ОписаниеОповещения("ПодключитьОборудованиеЗавершение", ЭтотОбъект);
	МенеджерОборудованияКлиент.НачатьПодключениеОборудованиеПриОткрытииФормы(ОповещенияПриПодключении, ЭтотОбъект, "СканерШтрихкода");
	// Конец ПодключаемоеОборудование
	
КонецПроцедуры

&НаКлиенте
Процедура ПодключитьОборудованиеЗавершение(РезультатВыполнения, Параметры) Экспорт
	
	Если Не РезультатВыполнения.Результат Тогда
		ЗаголовокИнформации = НСтр("ru = 'При подключении оборудования произошла ошибка: '; en = 'An error occurred while connecting the equipment: '");
		ТекстСообщения     = РезультатВыполнения.ОписаниеОшибки;
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ЗаголовокИнформации + ТекстСообщения);
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ПриЗакрытии()
	
	// ПодключаемоеОборудование
	ОповещенияПриОтключении = Новый ОписаниеОповещения("ОтключитьОборудованиеЗавершение", ЭтотОбъект); 
	МенеджерОборудованияКлиент.НачатьОтключениеОборудованиеПриЗакрытииФормы(ОповещенияПриОтключении, ЭтотОбъект);
	// Конец ПодключаемоеОборудование
	
КонецПроцедуры

&НаКлиенте
Процедура ОтключитьОборудованиеЗавершение(РезультатВыполнения, Параметры) Экспорт
   
   Если Не РезультатВыполнения.Результат Тогда
      ТекстСообщения = НСтр( "ru = 'При отключении оборудования произошла ошибка: ""%ОписаниеОшибки%"".'");
      ТекстСообщения = СтрЗаменить(ТекстСообщения, "%ОписаниеОшибки%" , РезультатВыполнения.ОписаниеОшибки);
      Сообщить(ТекстСообщения);
   //Иначе
   //   ТекстСообщения = НСтр("ru = 'Оборудование отключено.'" );
   //   Сообщить(ТекстСообщения);
   КонецЕсли;

КонецПроцедуры

#КонецОбласти
