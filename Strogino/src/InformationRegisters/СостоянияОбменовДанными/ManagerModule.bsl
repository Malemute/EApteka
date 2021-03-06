#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область ПрограммныйИнтерфейс

// Удаляет набор записей в регистре по переданным значениям структуры.
//
// Параметры:
//  СтруктураЗаписи - Структура - структура, по значениям которой необходимо удалить набор записей.
// 
Процедура УдалитьЗапись(СтруктураЗаписи) Экспорт
	
	ОбменДаннымиСервер.УдалитьНаборЗаписейВРегистреСведений(СтруктураЗаписи, "СостоянияОбменовДанными");
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

// Процедура добавляет запись в регистр по переданным значениям структуры.
Процедура ДобавитьЗапись(СтруктураЗаписи) Экспорт
	
	ОбменДаннымиСервер.ДобавитьЗаписьВРегистрСведений(СтруктураЗаписи, "СостоянияОбменовДанными");
	
КонецПроцедуры

#КонецОбласти

#КонецЕсли