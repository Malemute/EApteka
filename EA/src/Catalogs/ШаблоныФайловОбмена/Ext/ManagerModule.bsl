﻿
#Область ПрограммныйИнтерфейс

Функция ПараметрыЗагрузкиФайловОбмена(Шаблон) Экспорт
	
	УстановитьПривилегированныйРежим(Истина);
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("Ссылка", Шаблон);
	
	Запрос.Текст =
	"ВЫБРАТЬ
	|	ШаблоныФайловОбмена.ТипФайла,
	|	ШаблоныФайловОбмена.НачальнаяСтрока
	|ИЗ
	|	Справочник.ШаблоныФайловОбмена КАК ШаблоныФайловОбмена
	|ГДЕ
	|	ШаблоныФайловОбмена.Ссылка = &Ссылка
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ШаблоныФайловОбменаСоответствиеПолей.Поле,
	|	ШаблоныФайловОбменаСоответствиеПолей.ИмяПоляФайла,
	|	ШаблоныФайловОбменаСоответствиеПолей.НомерСтолбца,
	|	ШаблоныФайловОбменаСоответствиеПолей.Поставщик
	|ИЗ
	|	Справочник.ШаблоныФайловОбмена.СоответствиеПолей КАК ШаблоныФайловОбменаСоответствиеПолей
	|ГДЕ
	|	ШаблоныФайловОбменаСоответствиеПолей.Ссылка = &Ссылка";
	
	МассивРезультатов = Запрос.ВыполнитьПакет();
	
	Шапка = МассивРезультатов[0].Выбрать();
	Шапка.Следующий();
	
	Результат = Новый Структура;
	Результат.Вставить("ТипФайла",          Шапка.ТипФайла);
	Результат.Вставить("НачальнаяСтрока",   Шапка.НачальнаяСтрока);
	Результат.Вставить("СоответствиеПолей", Новый Структура);
	
	Результат.СоответствиеПолей.Вставить("КодыПоставщиков", Новый Соответствие);
	
	Выборка = МассивРезультатов[1].Выбрать();
	Пока Выборка.Следующий() Цикл
		ПолеФайла = ?(Шапка.ТипФайла = Перечисления.ФорматыФайловОбмена.XLS, Выборка.НомерСтолбца, Выборка.ИмяПоляФайла);
		
		Если Выборка.Поле = Перечисления.ВидыИмпортируемыхПолей.КодПоставщика Тогда
			Результат.СоответствиеПолей.КодыПоставщиков.Вставить(Выборка.Поставщик, ПолеФайла);
		Иначе
			Результат.СоответствиеПолей.Вставить(ОбщегоНазначения.ИмяЗначенияПеречисления(Выборка.Поле), ПолеФайла);
		КонецЕсли;
	КонецЦикла;
	
	Возврат Результат;
	
КонецФункции

#КонецОбласти