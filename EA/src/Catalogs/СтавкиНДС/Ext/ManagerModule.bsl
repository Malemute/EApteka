﻿Функция ВернутьСтавкуНДС(ЗначениеСтавки) Экспорт
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	СтавкиНДС.Ссылка
	|ИЗ
	|	Справочник.СтавкиНДС КАК СтавкиНДС
	|ГДЕ
	|	СтавкиНДС.Код = &ЗначениеСтавки";
	Запрос.УстановитьПараметр("ЗначениеСтавки",ЗначениеСтавки);
	Выборка = Запрос.Выполнить().Выбрать();
	Пока Выборка.Следующий() цикл
		Возврат Выборка.Ссылка;
	КонецЦикла;
	Возврат Справочники.СтавкиНДС.ПустаяСсылка();
КонецФункции