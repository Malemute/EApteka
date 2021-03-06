﻿
&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	УстановитьЭлементОтбораКоллекции();	
	
КонецПроцедуры

&НаСервере
Процедура УстановитьЭлементОтбораКоллекции()
	
	СписокФранчайзи.Отбор.Элементы.Очистить();
	ЭлементОтбора = СписокФранчайзи.Отбор.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
    ЭлементОтбора.ЛевоеЗначение    = Новый ПолеКомпоновкиДанных("Франчайзи");
    ЭлементОтбора.ВидСравнения     = ВидСравненияКомпоновкиДанных.Равно;
    ЭлементОтбора.Использование    = Истина;
    ЭлементОтбора.ПравоеЗначение   = Объект.Ссылка;
    ЭлементОтбора.РежимОтображения = РежимОтображенияЭлементаНастройкиКомпоновкиДанных.Недоступный;
    
КонецПроцедуры

&НаСервере
Процедура ПослеЗаписиНаСервере(ТекущийОбъект, ПараметрыЗаписи)
	УстановитьЭлементОтбораКоллекции();
КонецПроцедуры

