
&НаКлиенте
Процедура УзелИнформационнойБазыПриИзменении(Элемент)
	
	Если Не ЗначениеЗаполнено( Запись.УзелИнформационнойБазы ) Тогда
		Запись.УзелИнформационнойБазы = Неопределено;
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ПередЗаписью(Отказ, ПараметрыЗаписи)
	
	Если Не ЗначениеЗаполнено( Запись.УзелИнформационнойБазы ) Тогда
		Запись.УзелИнформационнойБазы = Неопределено;
	КонецЕсли;
	
КонецПроцедуры
