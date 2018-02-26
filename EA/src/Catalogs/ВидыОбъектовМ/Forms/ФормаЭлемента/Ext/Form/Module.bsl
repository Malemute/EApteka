﻿
&НаСервереБезКонтекста
Функция ПолучитьСписокВидовОбъектов( ТекущийТипОбъекта )

	Результат = Новый СписокЗначений;
	
	КоллекцияМетаданных = Перечисления.ТипыОбъектовМ.ПолучитьКоллекциюМетаданныхПоТипуОбъектаМ( ТекущийТипОбъекта );
	
	Если КоллекцияМетаданных <> Неопределено Тогда
		
		Для Каждого ЭлементКоллекции Из КоллекцияМетаданных Цикл
			Результат.Добавить( ЭлементКоллекции.Имя, ЭлементКоллекции.Синоним );
		КонецЦикла;
		
	КонецЕсли;
		
	Результат.СортироватьПоПредставлению();
	
	Возврат Результат;
	
КонецФункции

&НаКлиенте
Процедура ИдентификаторНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	
	Если Не ЗначениеЗаполнено(Объект.ТипОбъекта) Тогда
		Сообщить("Не указан тип объекта, для выбора вида следует указать тип!");
		Возврат;
	КонецЕсли;
	
	сзДанныеВыбора = ПолучитьСписокВидовОбъектов( Объект.ТипОбъекта );
	РезультатВыбора = сзДанныеВыбора.ВыбратьЭлемент( "Выберите объект", Элемент );
	
	Если РезультатВыбора <> Неопределено Тогда
		ИдентификаторОбработкаВыбора( Элемент, РезультатВыбора.Значение, Ложь );
		Объект.Идентификатор = РезультатВыбора.Значение;
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ИдентификаторОбработкаВыбора(Элемент, ВыбранноеЗначение, СтандартнаяОбработка)
	
	СписокОбъектов = ПолучитьСписокВидовОбъектов( Объект.ТипОбъекта );
	ТекЭлемент = СписокОбъектов.НайтиПоЗначению( ВыбранноеЗначение );
	Объект.Наименование = ТекЭлемент.Представление;
	
КонецПроцедуры

&НаКлиенте
Процедура ТипОбъектаПриИзменении(Элемент)
	
	Объект.Идентификатор = Неопределено;
	
КонецПроцедуры
