
&НаКлиенте
Процедура ЗаполнитьТоварыПоставщика(Команда)

	Если НЕ ЗначениеЗаполнено(Запись.ИсходныйКлючЗаписи) Тогда
		ПоказатьПредупреждение(, "Сохраните текущую запись", 15);
		Возврат;
	КонецЕсли;

	Если Запись.supplier_id = 0 Тогда
		Сообщение = Новый СообщениеПользователю;
		Сообщение.Текст = "Не указан 'Идентификатор' поставщика";
		Сообщение.Поле = "Запись.supplier_id";
		Сообщение.Сообщить(); 
		Возврат;
	КонецЕсли;

	Если НЕ ЗначениеЗаполнено(Запись.Поставщик) Тогда
		Сообщение = Новый СообщениеПользователю;
		Сообщение.Текст = "Не выбран поставщик";
		Сообщение.Поле = "Запись.Поставщик";
		Сообщение.Сообщить(); 
		Возврат;
	КонецЕсли;

	ОбщийМодульЗакупкиТовара.ЗаполнитьТоварыВТоварахПоставщика(Запись.Поставщик);

КонецПроцедуры
