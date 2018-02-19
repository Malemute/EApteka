
&НаКлиенте
Процедура КомандаПодтвердить(Команда)
	Если Не ПустаяСтрока(Объект.КлиентТелефон) И Не ПустаяСтрока(Объект.КлиентФИО) Тогда
		ДопПараметры = Новый Структура( "Телефон,ФИО,Комментарий,ВидДоставки", СокрЛП(Объект.КлиентТелефон), СокрЛП(Объект.КлиентФИО), СокрЛП(Объект.КлиентКомментарий), СокрЛП(ВидДоставки) );
		ЭтаФорма.Закрыть( ДопПараметры );
	КонецЕсли;
КонецПроцедуры

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	Элементы.ВидДоставки.СписокВыбора.Добавить("Самовывоз");
	Элементы.ВидДоставки.СписокВыбора.Добавить("Доставка");
	ВидДоставки = "Самовывоз";
	Если Параметры.Свойство("Телефон") Тогда
		Объект.КлиентТелефон = Параметры.Телефон;
	КонецЕсли;
	Если Параметры.Свойство("ФИО") Тогда
		Объект.КлиентФИО = Параметры.ФИО;
		КонецЕсли;
	Если Параметры.Свойство("Комментарий") Тогда
		Объект.КлиентКомментарий = Параметры.Комментарий;
	КонецЕсли;
	Если Параметры.Свойство("ВидДоставки") Тогда
		Всп = Параметры.ВидДоставки;
		ЭлементСписка = Элементы.ВидДоставки.СписокВыбора.НайтиПоЗначению(Всп);
		Если ЭлементСписка = Неопределено Тогда
			Элементы.ВидДоставки.СписокВыбора.Добавить(Всп);
		КонецЕсли;
		ВидДоставки = Всп;
	КонецЕсли;
КонецПроцедуры
