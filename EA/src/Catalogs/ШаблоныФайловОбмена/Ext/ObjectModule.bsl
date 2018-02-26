﻿
#Область ОбработчикиСобытий

Процедура ОбработкаПроверкиЗаполнения(Отказ, ПроверяемыеРеквизиты)
	
	Для Каждого СтрокаТЧ Из СоответствиеПолей Цикл
		Если СтрокаТЧ.Поле = Перечисления.ВидыИмпортируемыхПолей.КодПоставщика И СтрокаТЧ.Поставщик.Пустая() Тогда
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				НСтр("ru='Не указан поставщик'"),
				Ссылка,
				"Поставщик",
				"Объект.СоответствиеПолей[" + Формат(СоответствиеПолей.Индекс(СтрокаТЧ), "ЧГ=0") + "]",
				Отказ);
		КонецЕсли;
	КонецЦикла;
	
КонецПроцедуры

#КонецОбласти
