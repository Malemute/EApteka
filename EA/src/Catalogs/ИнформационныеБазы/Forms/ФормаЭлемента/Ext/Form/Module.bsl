﻿
&НаКлиенте
Процедура КомментарийНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)

	ОбщегоНазначенияКлиент.ПоказатьФормуРедактированияКомментария( Элемент.ТекстРедактирования, ЭтаФорма, "Объект.Комментарий" );
		
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	Если Объект.Ссылка = ПредопределенноеЗначение( "Справочник.ИнформационныеБазы.ТекущаяБаза" ) Тогда
		Элементы.Комментарий.Заголовок = "Эталонная строка соединения";
	КонецЕсли;
	
КонецПроцедуры
