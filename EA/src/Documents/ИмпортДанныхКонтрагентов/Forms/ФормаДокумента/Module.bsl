
#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Если ЭтоАдресВременногоХранилища(Параметры.АдресТоваровВХранилище) Тогда
		ТаблицаТоваров = ПолучитьИзВременногоХранилища(Параметры.АдресТоваровВХранилище);
		
		Если Параметры.ВидИмпортируемыхДанных = Перечисления.ВидыИмпортируемыхДанных.Остатки Тогда
			
			Для Каждого СтрокаТаблицы Из ТаблицаТоваров Цикл
				Если СтрокаТаблицы.ЗагружаемыйНачальныйОстаток <> 0 Или СтрокаТаблицы.ЗагружаемыйКонечныйОстаток <> 0 Тогда
					СтрокаТЧ = Объект.Остатки.Добавить();
					СтрокаТЧ.НоменклатураКонтрагента = СтрокаТаблицы.НоменклатураПоставщика;
					СтрокаТЧ.НачальныйОстаток = СтрокаТаблицы.ЗагружаемыйНачальныйОстаток;
					СтрокаТЧ.КонечныйОстаток = СтрокаТаблицы.ЗагружаемыйКонечныйОстаток;
				КонецЕсли;
			КонецЦикла;
			
		ИначеЕсли Параметры.ВидИмпортируемыхДанных = Перечисления.ВидыИмпортируемыхДанных.Закупки Тогда
			
			Для Каждого СтрокаТаблицы Из ТаблицаТоваров Цикл
				Если СтрокаТаблицы.Количество <> 0 Тогда
					СтрокаТЧ = Объект.Закупки.Добавить();
					СтрокаТЧ.Дата                    = СтрокаТаблицы.ЗагружаемаяДата;
					СтрокаТЧ.НоменклатураКонтрагента = СтрокаТаблицы.НоменклатураПоставщика;
					СтрокаТЧ.ПоставщикКонтрагента    = СтрокаТаблицы.Поставщик;
					СтрокаТЧ.Количество              = СтрокаТаблицы.Количество;
					СтрокаТЧ.Цена                    = СтрокаТаблицы.Цена;
					СтрокаТЧ.Сумма                   = ?(СтрокаТаблицы.Сумма = 0, СтрокаТЧ.Количество * СтрокаТЧ.Цена, СтрокаТаблицы.Сумма);
				КонецЕсли;
			КонецЦикла;
			
		ИначеЕсли Параметры.ВидИмпортируемыхДанных = Перечисления.ВидыИмпортируемыхДанных.Продажи Тогда
			
			Для Каждого СтрокаТаблицы Из ТаблицаТоваров Цикл
				Если СтрокаТаблицы.Количество <> 0 Тогда
					СтрокаТЧ = Объект.Продажи.Добавить();
					СтрокаТЧ.Дата                    = СтрокаТаблицы.ЗагружаемаяДата;
					СтрокаТЧ.НоменклатураКонтрагента = СтрокаТаблицы.НоменклатураПоставщика;
					СтрокаТЧ.Количество              = СтрокаТаблицы.Количество;
					СтрокаТЧ.ЦенаЗакупки             = СтрокаТаблицы.ЗагружаемаяЦенаЗакупки;
					СтрокаТЧ.ЦенаПродажи             = СтрокаТаблицы.ЗагружаемаяЦенаПродажи;
					СтрокаТЧ.СуммаЗакупки            = СтрокаТЧ.Количество * СтрокаТЧ.ЦенаЗакупки;
					СтрокаТЧ.СуммаПродажи            = СтрокаТЧ.Количество * СтрокаТЧ.ЦенаПродажи;
				КонецЕсли;
			КонецЦикла;
			
		КонецЕсли;
	КонецЕсли;
	
	Если Объект.Остатки.Количество() <> 0 Тогда
		Элементы.Страницы.ТекущаяСтраница = Элементы.СтраницаОстатки;
	ИначеЕсли Объект.Закупки.Количество() <> 0 Тогда
		Элементы.Страницы.ТекущаяСтраница = Элементы.СтраницаЗакупки;
	ИначеЕсли Объект.Продажи.Количество() <> 0 Тогда
		Элементы.Страницы.ТекущаяСтраница = Элементы.СтраницаПродажи;
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура УстановитьДатуПродажи(Команда)
	
	ПоказатьВводДаты(
		Новый ОписаниеОповещения("УстановитьДатуПродажиЗавершение", ЭтотОбъект),,
		НСтр("ru='Укажите дату продажи'"),
		ЧастиДаты.Дата);
	
КонецПроцедуры

&НаКлиенте
Процедура УстановитьДатуЗакупки(Команда)
	
	ПоказатьВводДаты(
		Новый ОписаниеОповещения("УстановитьДатуЗакупкиЗавершение", ЭтотОбъект),,
		НСтр("ru='Укажите дату закупки'"),
		ЧастиДаты.Дата);
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаКлиенте
Процедура УстановитьДатуПродажиЗавершение(Дата, ДополнительныеПараметры) Экспорт
	
	Если Не ЗначениеЗаполнено(Дата) Тогда
		Возврат;
	КонецЕсли;
	
	Для Каждого СтрокаТЧ Из Объект.Продажи Цикл
		СтрокаТЧ.Дата = Дата;
	КонецЦикла;
	
КонецПроцедуры

&НаКлиенте
Процедура УстановитьДатуЗакупкиЗавершение(Дата, ДополнительныеПараметры) Экспорт
	
	Если Не ЗначениеЗаполнено(Дата) Тогда
		Возврат;
	КонецЕсли;
	
	Для Каждого СтрокаТЧ Из Объект.Закупки Цикл
		СтрокаТЧ.Дата = Дата;
	КонецЦикла;
	
КонецПроцедуры

#КонецОбласти
