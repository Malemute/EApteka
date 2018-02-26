﻿
Процедура ПередЗаписью(Отказ)
	
	//ФонетическийКодСтрока = СобратьФонетическийКодПоСловам(КраткоеНаименование);
	//Справочники.Номенклатура.ПолучитьФонетическийКод(КраткоеНаименование);
	ФонетическийКодСтрока = СобратьФонетическийКодПоСловам(КраткоеНаименование);
	ФонетическийКодПолноеНаименование = СобратьФонетическийКодПоСловам(СокрЛП(ПолноеНаименование));

	ЗаполнитьСсылкуНаЗонуХранения();
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	ЗСЯНоменклатуры.Склад,
	|	ЗСЯНоменклатуры.Зона,
	|	ЗСЯНоменклатуры.Стеллаж,
	|	ЗСЯНоменклатуры.Ячейка,
	|	ЗСЯНоменклатуры.ЗонаСсылка
	|ИЗ
	|	РегистрСведений.ЗСЯНоменклатуры КАК ЗСЯНоменклатуры
	|ГДЕ
	|	ЗСЯНоменклатуры.Номенклатура = &Номенклатура";
	Запрос.УстановитьПараметр("Номенклатура",Ссылка);
	Выборка = Запрос.Выполнить().Выбрать();
	Пока Выборка.Следующий() цикл
		СтрокаЗСЯ = ЗСЯ.Добавить();
		ЗаполнитьЗначенияСвойств(СтрокаЗСЯ,Выборка);
	КонецЦикла;
	ЗСЯ.Свернуть("Склад,Зона,Стеллаж,Ячейка,ЗонаСсылка");
	
КонецПроцедуры

Процедура ЗаполнитьСсылкуНаЗонуХранения()
	
	Для каждого строка из ЗСЯ цикл
		
		Если не ЗначениеЗаполнено(Строка.ЗонаСсылка) тогда
			Строка.ЗонаСсылка = Справочники.ЗонаХранения.ПолучитьЗонуХраненияПоСкладуИНаименованию(Строка.Зона,Строка.Склад);
		КонецЕсли;
		
	КонецЦикла;
	
КонецПроцедуры

Процедура ПередУдалением(Отказ)
		Отказ = не ДополнительныеСвойства.Свойство("МнеМожно"); 
		Если Отказ тогда
			Сообщить("Нельзя удалять номенклатуру!");
		КонецЕсли;
КонецПроцедуры

Функция СобратьФонетическийКодПоСловам(Строка)
	ИтоговаяСтрока = "";
	МассивСлов = СтрРазделить(Строка," ");
	Для каждого Слово из МассивСлов цикл
		ИтоговаяСтрока = ИтоговаяСтрока + Справочники.Номенклатура.ПолучитьФонетическийКод(Слово);	
	КонецЦикла;
	Возврат ИтоговаяСтрока;
КонецФункции