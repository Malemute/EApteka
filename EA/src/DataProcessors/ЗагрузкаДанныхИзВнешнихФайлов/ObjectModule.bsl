
#Область ОбработчикиСобытий

Процедура ОбработкаПроверкиЗаполнения(Отказ, ПроверяемыеРеквизиты)
	
	Если ПроверяемыеРеквизиты.Найти("Товары.Номенклатура") <> Неопределено Тогда
		ПроверяемыеРеквизиты.Удалить(ПроверяемыеРеквизиты.Найти("Товары.Номенклатура"));
	КонецЕсли;
	
	Если ВидИмпортируемыхДанных = Перечисления.ВидыИмпортируемыхДанных.СправочникТоваров Тогда
		Возврат;
	КонецЕсли;
	
	Если ВидИмпортируемыхДанных = Перечисления.ВидыИмпортируемыхДанных.Закупки Тогда
		ПроверяемыеРеквизиты.Добавить("Товары.Поставщик");
	КонецЕсли;
	
	Для Каждого СтрокаТЧ Из Товары Цикл
		Если ЗначениеЗаполнено(ВидИмпортируемыхДанных) И Не ЗначениеЗаполнено(СтрокаТЧ.НоменклатураПоставщика) Тогда
			ТекстСообщения = НСтр("ru='Не заполнена колонка ""Номенклатура поставщика"" в строке %1 списка ""Товары""'");
			ТекстСообщения = СтрШаблон(ТекстСообщения, Формат(Товары.Индекс(СтрокаТЧ) + 1, "ЧГ=0"));
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				ТекстСообщения,,
				"НоменклатураПоставщика",
				"Объект.Товары[" + Формат(Товары.Индекс(СтрокаТЧ), "ЧГ=0") + "]",
				Отказ);
		ИначеЕсли Не ЗначениеЗаполнено(ВидИмпортируемыхДанных) И Не ЗначениеЗаполнено(СтрокаТЧ.Номенклатура) Тогда
			ТекстСообщения = НСтр("ru='Не заполнена колонка ""Номенклатура"" в строке %1 списка ""Товары""'");
			ТекстСообщения = СтрШаблон(ТекстСообщения, Формат(Товары.Индекс(СтрокаТЧ) + 1, "ЧГ=0"));
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				ТекстСообщения,,
				"Номенклатура",
				"Объект.Товары[" + Формат(Товары.Индекс(СтрокаТЧ), "ЧГ=0") + "]",
				Отказ);
		КонецЕсли;
	КонецЦикла;
	
КонецПроцедуры

#КонецОбласти