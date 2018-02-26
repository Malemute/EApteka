﻿
#Область ПрограммныйИнтерфейс

// Проверяет активна ли кассовая смена. Под активностью понимается соблюдение следующих условий:
// - кассовая смена не закрыта
// - с момента открытия кассовой смены прошло не более 24 часов
//
// Параметры:
//  КассоваяСмена - ДокументСсылка.КассоваяСмена - Кассовая смена, активность которой необходимо проверить
//
// Возвращаемое значение:
//  Булево - активность смены
Функция СменаАктивна(КассоваяСмена) Экспорт
	
	ОписаниеСмены = КассовыеСменыВызовСервера.ОписаниеКассовойСмены(КассоваяСмена);
	
	Если ОписаниеСмены = Неопределено Тогда
		Возврат Ложь;
	ИначеЕсли ОписаниеСмены.Статус = Перечисления.СтатусыКассовойСмены.Открыта
		и ОписаниеСмены.ДатаИстеченияСрокаДействия > ТекущаяДатаСеанса() Тогда
		Возврат Истина;
	Иначе
		Возврат Ложь;
	КонецЕсли;
	
КонецФункции

// Функция проверяет состояние кассовой смены на дату. Если смена не открыта - возвращается описание ошибки.
//
Функция СменаОткрыта(КассоваяСмена, Дата, ОписаниеОшибки = "") Экспорт
	
	СменаОткрыта = Ложь;
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ РАЗРЕШЕННЫЕ
	|	КассоваяСмена.Статус    КАК СтатусКассовойСмены,
	|	КассоваяСмена.НачалоКассовойСмены    КАК НачалоКассовойСмены,
	|	КассоваяСмена.ОкончаниеКассовойСмены КАК ОкончаниеКассовойСмены
	|ИЗ
	|	Документ.КассоваяСмена КАК КассоваяСмена
	|ГДЕ
	|	КассоваяСмена.Проведен
	|	И КассоваяСмена.Ссылка = &КассоваяСмена";
	
	Запрос.УстановитьПараметр("КассоваяСмена", КассоваяСмена);
	
	Результат = Запрос.Выполнить();
	Выборка = Результат.Выбрать();
	
	Если Выборка.Следующий() Тогда
		
		Если Выборка.СтатусКассовойСмены = Перечисления.СтатусыКассовойСмены.Открыта Тогда
			
			// Если смена открыта, то с момента открытия должно пройти не больше чем 24 часа.
			Если Дата - Выборка.НачалоКассовойСмены < 86400 Тогда
				
				СменаОткрыта = Истина;
				
			Иначе
				
				ОписаниеОшибки = НСтр("ru = 'С момента открытия кассовой смены истекло более 24 часов.'");
				СменаОткрыта = Ложь;
				
			КонецЕсли;
			
		ИначеЕсли ЗначениеЗаполнено(Выборка.СтатусКассовойСмены) Тогда
			
			Если Выборка.ОкончаниеКассовойСмены >= Дата И Выборка.НачалоКассовойСмены <= Дата Тогда
				
				СменаОткрыта = Истина;
				
			Иначе
				
				ОписаниеОшибки = НСтр("ru = 'Кассовая смена закрыта.'");
				СменаОткрыта = Ложь;
				
			КонецЕсли;
			
		КонецЕсли;
		
	Иначе
		
		ОписаниеОшибки = НСтр("ru = 'Кассовая смена не открыта.'");
		СменаОткрыта = Ложь;
		
	КонецЕсли;
	
	Возврат СменаОткрыта;
	
КонецФункции

// Проверяет закрыта ли кассовая смена.
//
// Параметры:
//  КассоваяСмена - ДокументСсылка.КассоваяСмена - Кассовая смена, активность которой необходимо проверить
//
// Возвращаемое значение:
//  Булево - Истина - смена закрыта, Ложь - смена не закрыта
Функция СменаЗакрыта(КассоваяСмена) Экспорт
	
	ОписаниеПоследнейСмены = КассовыеСменыВызовСервера.ОписаниеКассовойСмены(КассоваяСмена);
	
	Если ОписаниеПоследнейСмены = Неопределено Тогда
		Возврат Истина;
	ИначеЕсли не ОписаниеПоследнейСмены.Статус = Перечисления.СтатусыКассовойСмены.Открыта Тогда
		Возврат Истина;
	Иначе
		Возврат Ложь;
	КонецЕсли;
	
КонецФункции

// Получает реквизиты кассовой смены
//
// Параметры:
//  КассоваяСмена - ДокументСсылка.КассоваяСмена - Кассовая смена, активность которой необходимо проверить
//
// Возвращаемое значение:
//  Структура - реквизиты кассовой смены. Содержит следующие реквизиты:
//    КассоваяСмена - ДокументСсылка.КассоваяСмена - ссылка на кассовую смену
//    ФискальноеУстройство - СправочникСсылка.ПодключаемоеОборудование - ссылка на устройство, на котором открыта смена
//    НачалоКассовойСмены - Дата - дата открытия смены
//    ОкончаниеКассовойСмены - Дата - дата закрытия смены (если смена закрывалась)
//    ДатаИстеченияСрокаДействия - дата, в которую закончиться срок действия смены (дата открытия + 24 часа)
//    Организация - организация, указанная в документе КассоваяСмена
//    Статус - статус кассовой смены
Функция ОписаниеКассовойСмены(КассоваяСмена) Экспорт
	
	Запрос = Новый Запрос();
	Запрос.Текст =
	"ВЫБРАТЬ РАЗРЕШЕННЫЕ ПЕРВЫЕ 1
	|	КассоваяСмена.Ссылка КАК КассоваяСмена,
	|	КассоваяСмена.ФискальноеУстройство,
	|	КассоваяСмена.НачалоКассовойСмены,
	|	КассоваяСмена.ОкончаниеКассовойСмены,
	|	ДОБАВИТЬКДАТЕ(КассоваяСмена.НачалоКассовойСмены, ДЕНЬ, 1) КАК ДатаИстеченияСрокаДействия,
	|	КассоваяСмена.Организация,
	|	КассоваяСмена.Статус
	|ИЗ
	|	Документ.КассоваяСмена КАК КассоваяСмена
	|ГДЕ
	|	КассоваяСмена.Ссылка = &КассоваяСмена";
	Запрос.УстановитьПараметр("КассоваяСмена", КассоваяСмена);
	Результат = Запрос.Выполнить().Выгрузить();
	
	Если Результат.Количество() = 0 Тогда
		Возврат Неопределено;
	Иначе
		СтруктураРезультат = Новый Структура();
		Для Каждого КолонкаРезультата Из Результат.Колонки Цикл
			СтруктураРезультат.Вставить(КолонкаРезультата.Имя, Результат[0][КолонкаРезультата.Имя]);
		КонецЦикла;
		Возврат СтруктураРезультат;
	КонецЕсли;
	
КонецФункции

// По фискальному устройству определяет статус смены и проверяет ее активность. Под активностью понимается соблюдение следующих условий:
// - кассовая смена не закрыта
// - с момента открытия кассовой смены прошло не более 24 часов
//
// Параметры:
//  ФискальноеУстройство - СправочникСсылка.ПодключаемоеОборудование - фискальное устройство, для которого требуется определить активность смены
//
// Возвращаемое значение:
//  Результат - Структура
//    Открыта - Булево - Истина - смена открыта, Ложь - смена закрыта.
//    Активна - Булево - Истина - смена открыта, Ложь - смена закрыта, прошло более 24 часов с момента открытия или никогда не была открыта.
//    ТекущийНомерЧека - Число - текущий номер чека ККТ.
// 
Функция СтатусПоследнейСмены(ФискальноеУстройство) Экспорт
	
	РезультатОперации = Новый Структура();
	РезультатОперации.Вставить("Активна", Ложь);
	РезультатОперации.Вставить("Открыта", Ложь);
	РезультатОперации.Вставить("ТекущийНомерЧека");
	РезультатОперации.Вставить("НомерСмены");
	РезультатОперации.Вставить("КассоваяСмена");
	
	ОписаниеПоследнейСмены = ОписаниеПоследнейКассовойСмены(ФискальноеУстройство);
	
	Если Не (ОписаниеПоследнейСмены = Неопределено) Тогда
		РезультатОперации.Открыта = ОписаниеПоследнейСмены.Статус = Перечисления.СтатусыКассовойСмены.Открыта; 
		РезультатОперации.Активна = РезультатОперации.Открыта И ОписаниеПоследнейСмены.ДатаИстеченияСрокаДействия > ТекущаяДатаСеанса();
		РезультатОперации.ТекущийНомерЧека = ПолучитьТекущийНомерЧекаККТ(ФискальноеУстройство, ОписаниеПоследнейСмены.КассоваяСмена);
		РезультатОперации.КассоваяСмена    = ОписаниеПоследнейСмены.КассоваяСмена;
		РезультатОперации.НомерСмены       = ОписаниеПоследнейСмены.КассоваяСмена.Номер;
	КонецЕсли;
	
	Возврат РезультатОперации;
	
КонецФункции

// По фискальному устройству определяет последнюю смену и проверяет закрыта ли она.
//
// Параметры:
//  ФискальноеУстройство - СправочникСсылка.ПодключаемоеОборудование - фискальное устройство, для которого требуется определить закрыта ли смена
//
// Возвращаемое значение:
//  Булево - Истина - смена закрыта или никогда не была открыта, Ложь - смена не закрыта
Функция ПоследняяСменаЗакрыта(ФискальноеУстройство) Экспорт
	
	ОписаниеПоследнейСмены = ОписаниеПоследнейКассовойСмены(ФискальноеУстройство);
	
	Если ОписаниеПоследнейСмены = Неопределено Тогда
		
		Возврат Истина;
		
	ИначеЕсли не ОписаниеПоследнейСмены.Статус = Перечисления.СтатусыКассовойСмены.Открыта Тогда
		
		Возврат Истина;
		
	Иначе
		
		Возврат Ложь;
		
	КонецЕсли;
	
КонецФункции

// По фискальному устройству определяет последнюю смену и получает ее реквизиты.
//
// Параметры:
//  ФискальноеУстройство - СправочникСсылка.ПодключаемоеОборудование - фискальное устройство, для которого требуется определить активность смены.
//
// Возвращаемое значение:
//  Структура - реквизиты кассовой смены, Неопределено - если ни одной смены не было открыто. Содержит следующие реквизиты:
//    КассоваяСмена - ДокументСсылка.КассоваяСмена - ссылка на кассовую смену
//    ФискальноеУстройство - СправочникСсылка.ПодключаемоеОборудование - ссылка на устройство, на котором открыта смена
//    НачалоКассовойСмены - Дата - дата открытия смены
//    ОкончаниеКассовойСмены - Дата - дата закрытия смены (если смена закрывалась)
//    ДатаИстеченияСрокаДействия - дата, в которую закончиться срок действия смены (дата открытия + 24 часа)
//    Организация - организация, указанная в документе КассоваяСмена
//    Статус - статус кассовой смены
Функция ОписаниеПоследнейКассовойСмены(ФискальноеУстройство) Экспорт
	
	Запрос = Новый Запрос();
	Запрос.Текст =
	"ВЫБРАТЬ РАЗРЕШЕННЫЕ ПЕРВЫЕ 1
	|	КассоваяСмена.Ссылка КАК КассоваяСмена,
	|	КассоваяСмена.ФискальноеУстройство,
	|	КассоваяСмена.НачалоКассовойСмены,
	|	КассоваяСмена.ОкончаниеКассовойСмены,
	|	ДОБАВИТЬКДАТЕ(КассоваяСмена.НачалоКассовойСмены, ДЕНЬ, 1) КАК ДатаИстеченияСрокаДействия,
	|	КассоваяСмена.Организация,
	|	КассоваяСмена.Статус
	|ИЗ
	|	Документ.КассоваяСмена КАК КассоваяСмена
	|ГДЕ
	|	КассоваяСмена.ФискальноеУстройство = &ФискальноеУстройство
	|	И КассоваяСмена.Проведен
	|
	|УПОРЯДОЧИТЬ ПО
	|	КассоваяСмена.НачалоКассовойСмены УБЫВ";
	Запрос.УстановитьПараметр("ФискальноеУстройство", ФискальноеУстройство);
	Результат = Запрос.Выполнить().Выгрузить();
	
	Если Результат.Количество() = 0 Тогда
		Возврат Неопределено;
	Иначе
		СтруктураРезультат = Новый Структура();
		Для Каждого КолонкаРезультата Из Результат.Колонки Цикл
			СтруктураРезультат.Вставить(КолонкаРезультата.Имя, Результат[0][КолонкаРезультата.Имя]);
		КонецЦикла;
		Возврат СтруктураРезультат;
	КонецЕсли;
	
КонецФункции

// Получить текущий номер чека ККТ
//
// Параметры:
//  ФискальноеУстройство - СправочникСсылка.ПодключаемоеОборудование - фискальное устройство, для которого требуется определить номер чека.
//  КассоваяСмена - ДокументСсылка.КассоваяСмена - Кассовая смена в рамках которой необходимо получить текущий номер чека ККТ.
//
// Возвращаемое значение:
//  Результат - Число - Текущий номер чека ККТ.
//
Функция ПолучитьТекущийНомерЧекаККТ(ФискальноеУстройство, КассоваяСмена) Экспорт
	
	УстановитьПривилегированныйРежим(Истина);
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ ПЕРВЫЕ 1
	|	НумерацияЧековККТ.ПодключаемоеОборудование,
	|	НумерацияЧековККТ.КассоваяСмена,
	|	НумерацияЧековККТ.ПорядковыйНомер
	|ИЗ
	|	РегистрСведений.НумерацияЧековККТ КАК НумерацияЧековККТ
	|ГДЕ
	|	НумерацияЧековККТ.ПодключаемоеОборудование = &ПодключаемоеОборудование
	|	И НумерацияЧековККТ.КассоваяСмена = &КассоваяСмена";
	
	Запрос.УстановитьПараметр("ПодключаемоеОборудование", ФискальноеУстройство);
	Запрос.УстановитьПараметр("КассоваяСмена",    КассоваяСмена);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	ПорядковыйНомер = 1;
	
	Выборка = РезультатЗапроса.Выбрать();
	Если Выборка.Следующий() Тогда
		ПорядковыйНомер = Выборка.ПорядковыйНомер;
	КонецЕсли;
	
	Возврат ПорядковыйНомер;
	
КонецФункции

// Инкрементировать текущий номер чека ККТ
//
// Параметры:
//  ФискальноеУстройство - СправочникСсылка.ПодключаемоеОборудование - фискальное устройство,  для которого требуется инкрементировать номер чека.
//  КассоваяСмена - ДокументСсылка.КассоваяСмена - Кассовая смена в рамках которой необходимо получить текущий номер чека ККТ.
//
// Возвращаемое значение:
//  Результат - Число - Текущий номер чека ККТ.
//
Процедура ИнкрементироватьТекущийНомерЧекаККТ(ФискальноеУстройство, КассоваяСмена) Экспорт
	
	УстановитьПривилегированныйРежим(Истина);
	
	ПорядковыйНомер = ПолучитьТекущийНомерЧекаККТ(ФискальноеУстройство, КассоваяСмена);
	ПорядковыйНомер = ПорядковыйНомер + 1;
	
	МенеджерЗаписи = РегистрыСведений.НумерацияЧековККТ.СоздатьМенеджерЗаписи();
	МенеджерЗаписи.ПодключаемоеОборудование = ФискальноеУстройство;
	МенеджерЗаписи.КассоваяСмена = КассоваяСмена;
	МенеджерЗаписи.ПорядковыйНомер = ПорядковыйНомер;
	МенеджерЗаписи.Записать(Истина);
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

// Для внутреннего использования
Процедура ПослеВыполненияКомандыФискальнымУстройством(ПараметрыКоманды) Экспорт
	
	Если ПараметрыКоманды.ВыполняемаяКоманда = "OpenShift" Тогда
		
		КассоваяСменаОбъект = Документы.КассоваяСмена.СоздатьДокумент();
		КассоваяСменаОбъект.Дата = ТекущаяДатаСеанса();
		
		КассоваяСменаОбъект.ФискальноеУстройство = ПараметрыКоманды.ИдентификаторУстройства;
		КассоваяСменаОбъект.НачалоКассовойСмены = КассоваяСменаОбъект.Дата;
		КассоваяСменаОбъект.Организация = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(ПараметрыКоманды.ИдентификаторУстройства, "Организация");
		КассоваяСменаОбъект.Статус = Перечисления.СтатусыКассовойСмены.Открыта;
		Если ПараметрыКоманды.Свойство("ДополнительныеПараметры")
			И ПараметрыКоманды.ДополнительныеПараметры <> Неопределено Тогда
			ЗаполнитьЗначенияСвойств(КассоваяСменаОбъект, ПараметрыКоманды.ДополнительныеПараметры);
		КонецЕсли;
		
	ИначеЕсли ПараметрыКоманды.ВыполняемаяКоманда = "CloseShift" Тогда
		
		КассоваяСменаОбъект = ПараметрыКоманды.КассоваяСмена.ПолучитьОбъект();
		
		КассоваяСменаОбъект.Статус = Перечисления.СтатусыКассовойСмены.Закрыта;
		КассоваяСменаОбъект.ОкончаниеКассовойСмены = ТекущаяДатаСеанса();
		
	Иначе
		
		Возврат;
		
	КонецЕсли;
	
	Если ПараметрыКоманды.Свойство("ФискальныеДанныеСтруктура") Тогда
		ЗаполнитьЗначенияСвойств(КассоваяСменаОбъект, ПараметрыКоманды.ФискальныеДанныеСтруктура);
	КонецЕсли;
	
	Если ПараметрыКоманды.ВыполняемаяКоманда = "CloseShift" и ПараметрыКоманды.Свойство("ФискальныеДанныеXMLСтрока") Тогда
		КассоваяСменаОбъект.ФДОЗакрытииСмены = Новый ХранилищеЗначения(ПараметрыКоманды.ФискальныеДанныеXMLСтрока, Новый СжатиеДанных(9));
	КонецЕсли;
	
	КассоваяСменаОбъект.Записать(РежимЗаписиДокумента.Проведение);
	
КонецПроцедуры

// Для внутреннего использования
Функция НоваяКассоваяСмена(ФискальноеУстройство) Экспорт
	
	КассоваяСменаОбъект = Документы.КассоваяСмена.СоздатьДокумент();
	КассоваяСменаОбъект.Дата = ТекущаяДатаСеанса();
	
	КассоваяСменаОбъект.ФискальноеУстройство = ФискальноеУстройство;
	КассоваяСменаОбъект.НачалоКассовойСмены = КассоваяСменаОбъект.Дата;
	КассоваяСменаОбъект.Организация = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(ФискальноеУстройство, "Организация");
	КассоваяСменаОбъект.Статус = Перечисления.СтатусыКассовойСмены.Открыта;
	
	Если ПривилегированныйРежим() Тогда
		СнятьПривилегированныйРежим = Ложь;
	Иначе
		СнятьПривилегированныйРежим = Истина;
		УстановитьПривилегированныйРежим(Истина);
	КонецЕсли;
	
	КассоваяСменаОбъект.Записать(РежимЗаписиДокумента.Проведение);
	
	Если СнятьПривилегированныйРежим Тогда
		УстановитьПривилегированныйРежим(Ложь);
	КонецЕсли;
	
	Возврат КассоваяСменаОбъект.Ссылка;
	
КонецФункции

#КонецОбласти
