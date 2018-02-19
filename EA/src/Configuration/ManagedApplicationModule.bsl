
Перем Scan Экспорт;
Перем FR Экспорт;
Перем ВнешниеКомпонентыЗагружены Экспорт;
Перем ИД_РабочегоМеста Экспорт;
Перем FR_atol Экспорт;

// ПодключаемоеОборудование
Перем глПодключаемоеОборудование Экспорт; // для кэширования на клиенте
// Конец ПодключаемоеОборудование

Процедура ПередНачаломРаботыСистемы(Отказ)
	ВнешниеКомпонентыЗагружены = Ложь;
	ИД_РабочегоМеста = "";	
	
	// ПодключаемоеОборудование
	МенеджерОборудованияКлиент.ПередНачаломРаботыСистемы();
	// Конец ПодключаемоеОборудование
	
КонецПроцедуры

Процедура ПриНачалеРаботыСистемы()
	
	Экраны = ПолучитьИнформациюЭкрановКлиента();
	ВысотаЭкрана = Экраны[0].Высота;
	ШиринаЭкрана = Экраны[0].Ширина;
	ВнешниеКомпонентыЗагружены = Ложь;
	
	Если ВысотаЭкрана > 600 тогда
		Попытка
			ПодключитьВнешнююКомпоненту("Addin.DrvFR");
			FR = Новый("AddIn.DrvFR");
			ВнешниеКомпонентыЗагружены = Истина;
		Исключение
		КонецПопытки;
		Попытка
			ПодключитьВнешнююКомпоненту("AddIn.FPrnM8");
			FR_atol = Новый("AddIn.FPrnM8");
			FR_atol.LoadDevicesSettings();
			FR_atol.УстройствоВключено = 1;
			ВнешниеКомпонентыЗагружены = Истина;
		Исключение
		КонецПопытки;
	КонецЕсли;
	
	Попытка	
		ПодключитьВнешнююКомпоненту("AddIn.Scaner45");
		Scan = Новый ("AddIn.Scaner45");
		Scan.AutoDisable = 1;
		Scan.DataEventEnabled = 1;
		Scan.OldVersion = 1;
		
		Оповестить("КомпонентыДляРаботыТОЗагружены", , "ГлобальныйМодуль");
				
		РаботаСФормами.ВыполнитьНастройкуПанелей(ШиринаЭкрана, ВысотаЭкрана);
				
		ОбновитьИнтерфейс();
		Если РаботаСФормами.РольДоступнаСервер("ТСД") тогда
			ОткрытьФорму("Обработка.АптекаТСД.Форма.Форма",,,,,,,РежимОткрытияОкнаФормы.БлокироватьВесьИнтерфейс);
		КонецЕсли;
		
	Исключение	
		Сообщить(ОписаниеОшибки());
		ВнешниеКомпонентыЗагружены = Ложь;
	КонецПопытки;
	
	УстановитьЗаголовокКлиентскогоПриложения(ОбменАлгоритмыРИБД.ПолучитьИмяАптекиДляЗаголовка());	

	// ПодключаемоеОборудование
	МенеджерОборудованияКлиент.ПриНачалеРаботыСистемы();
	// Конец ПодключаемоеОборудование

КонецПроцедуры

Процедура ПередЗавершениемРаботыСистемы(Отказ)
	
	// ПодключаемоеОборудование
	МенеджерОборудованияКлиент.ПередЗавершениемРаботыСистемы();
	// Конец ПодключаемоеОборудование
	
КонецПроцедуры

Процедура ОбработкаВнешнегоСобытия(Источник, Событие, Данные)

	// ПодключаемоеОборудование
	// Подготовить данные
	
	ОписаниеСобытия = Новый Структура();
	ОписаниеОшибки  = "";
	
	ОписаниеСобытия.Вставить("Источник", Источник);
	ОписаниеСобытия.Вставить("Событие",  Событие);
	ОписаниеСобытия.Вставить("Данные",   Данные);
	
	// Передать на обработку данные.
	Результат = МенеджерОборудованияКлиент.ОбработатьСобытиеОтУстройства(ОписаниеСобытия, ОписаниеОшибки);
	Если Не Результат Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(НСтр("ru='При обработке внешнего события от устройства произошла ошибка.'")
		                                                 + Символы.ПС + ОписаниеОшибки);
	КонецЕсли;
	// Конец ПодключаемоеОборудование

КонецПроцедуры
