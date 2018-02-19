
Функция ПолучитьТипПоВидуОбъектаМ( ВидОбъектаМ ) Экспорт
	
	УстановитьПривилегированныйРежим( Истина );
	
	Возврат Справочники.ВидыОбъектовМ.ПолучитьТипПоВидуОбъектаМ( ВидОбъектаМ );
	
КонецФункции

// Ищет ВидОбъектаМ по Объекту
// 		Объект может быть непосредственно Объектом, Ссылкой, Строкой с ПолнымИменемМетаданных или Метаданными
Функция ПолучитьСсылкуВидаОбъектаМПоОбъекту( Объект ) Экспорт
	
	УстановитьПривилегированныйРежим( Истина );
	
	Возврат Справочники.ВидыОбъектовМ.ПолучитьСсылкуВидаОбъектаМПоОбъекту( Объект );
	
КонецФункции
