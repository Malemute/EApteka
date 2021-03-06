
&НаКлиенте
Процедура ВидОбъектаРезультатаСвязиПриИзменении(Элемент)
	
	ВидОбъектаРезультатаСвязиПриИзмененииНаСервере();
	
КонецПроцедуры

&НаСервере
Процедура ВидОбъектаРезультатаСвязиПриИзмененииНаСервере()
	
	ПривестиЗначениеОбъектаРезультатаКТипуЗаданномуВидом();
	
КонецПроцедуры

&НаСервере
Процедура ПривестиЗначениеОбъектаРезультатаКТипуЗаданномуВидом()
	
	Если Не ЗначениеЗаполнено( Объект.ВидОбъектаРезультатаСвязи ) Тогда
		
		Элементы.ОбъектРезультатСвязи.ДоступныеТипы = Новый ОписаниеТипов( "Неопределено" );
		Объект.ОбъектРезультатСвязи = Неопределено;
		
	Иначе	
		
		МассивТипов = Новый Массив;
		МассивТипов.Добавить( Справочники.ВидыОбъектовМ.ПолучитьТипПоВидуОбъектаМ( Объект.ВидОбъектаРезультатаСвязи ) );
		
		ОписаниеТекущегоТипаОбъекта = Новый ОписаниеТипов( МассивТипов );
		
		Элементы.ОбъектРезультатСвязи.ДоступныеТипы = ОписаниеТекущегоТипаОбъекта;
		Объект.ОбъектРезультатСвязи = ОписаниеТекущегоТипаОбъекта.ПривестиЗначение( Объект.ОбъектРезультатСвязи );
		
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	ПривестиЗначениеОбъектаРезультатаКТипуЗаданномуВидом();
	
КонецПроцедуры
