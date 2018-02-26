﻿
#Область СлужебныеПроцедурыИФункции

Функция ШаблонФайлаОбменаКонтрагента(Контрагент, ВидИмпортируемыхДанных) Экспорт
	
	УстановитьПривилегированныйРежим(Истина);
	
	Запись = РегистрыСведений.ШаблоныФайловОбменаКонтрагентов.СоздатьМенеджерЗаписи();
	Запись.Контрагент = Контрагент;
	Запись.ВидИмпортируемыхДанных = ВидИмпортируемыхДанных;
	Запись.Прочитать();
	
	Если Запись.Выбран() Тогда
		Возврат Запись.ШаблонФайла;
	КонецЕсли;
	
	Возврат Неопределено;
	
КонецФункции

Функция ШаблоныФайловОбменаКонтрагента(Контрагент) Экспорт
	
	УстановитьПривилегированныйРежим(Истина);
	
	Результат = Новый Соответствие;
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("Контрагент", Контрагент);
	
	Запрос.Текст =
	"ВЫБРАТЬ
	|	ШаблоныФайловОбменаКонтрагентов.ВидИмпортируемыхДанных КАК ВидИмпортируемыхДанных,
	|	ШаблоныФайловОбменаКонтрагентов.ШаблонФайла КАК ШаблонФайла
	|ИЗ
	|	РегистрСведений.ШаблоныФайловОбменаКонтрагентов КАК ШаблоныФайловОбменаКонтрагентов
	|ГДЕ
	|	ШаблоныФайловОбменаКонтрагентов.Контрагент = &Контрагент";
	
	Выборка = Запрос.Выполнить().Выбрать();
	Пока Выборка.Следующий() Цикл
		Результат.Вставить(Выборка.ВидИмпортируемыхДанных, Выборка.ШаблонФайла);
	КонецЦикла;
	
	Возврат Результат;
	
КонецФункции

#КонецОбласти