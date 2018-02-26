﻿
#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	УстановитьВидимостьЭлементовФормы(ЭтотОбъект);
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовФормы

&НаКлиенте
Процедура ТипФайлаПриИзменении(Элемент)
	
	УстановитьВидимостьЭлементовФормы(ЭтотОбъект);
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаКлиентеНаСервереБезКонтекста
Процедура УстановитьВидимостьЭлементовФормы(Форма)
	
	ЭтоФорматXLS = Форма.Объект.ТипФайла = ПредопределенноеЗначение("Перечисление.ФорматыФайловОбмена.XLS");
	
	Форма.Элементы.НачальнаяСтрока.Видимость = ЭтоФорматXLS;
	Форма.Элементы.СоответствиеПолейНомерСтолбца.Видимость = ЭтоФорматXLS;
	Форма.Элементы.СоответствиеПолейИмяПоляФайла.Видимость = Не ЭтоФорматXLS;
	
КонецПроцедуры

#КонецОбласти