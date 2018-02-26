﻿
// Функция - Получить ссылку описателя типа по идентификатору
//     Возвращает ссылку описателя типа для информационной базы по идентификатору, если подходящего нет, то будет создан новый
//
// Параметры:
//  ИнформационнаяБаза	 - СправочникСсылка.ИнформационныеБазы - информационная база, владелец типа
//  ИдентификаторТипа	 - Строка - идентификатор типа информационной базы
// 
// Возвращаемое значение:
//   - СправочникСсылка.ОписателиТиповИнформационныхБаз - полученная ссылка описателя типа
//
Функция ПолучитьСсылкуОписателяТипаПоИдентификатору( ИнформационнаяБаза, Знач ИдентификаторТипа ) Экспорт
	
	ИдентификаторТипа = СокрЛП( ВРег( ИдентификаторТипа ) );
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр( "Владелец", ИнформационнаяБаза );
	Запрос.УстановитьПараметр( "ИдентификаторТипа", ИдентификаторТипа );
	Запрос.УстановитьПараметр( "ИдентификаторТипаУИД", ВычислитьУИДдляИдентификатораТипа( ИдентификаторТипа ) ); 
	Запрос.Текст =
	"ВЫБРАТЬ
	|	ОписателиТиповИнформационныхБаз.Ссылка КАК Ссылка,
	|	ОписателиТиповИнформационныхБаз.ИдентификаторТипа КАК ИдентификаторТипа
	|ПОМЕСТИТЬ табНайденныхПоУИД
	|ИЗ
	|	Справочник.ОписателиТиповИнформационныхБаз КАК ОписателиТиповИнформационныхБаз
	|ГДЕ
	|	ОписателиТиповИнформационныхБаз.Владелец = &Владелец
	|	И ОписателиТиповИнформационныхБаз.ИдентификаторТипаУИД = &ИдентификаторТипаУИД
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ ПЕРВЫЕ 1
	|	табНайденныхПоУИД.Ссылка КАК Ссылка
	|ИЗ
	|	табНайденныхПоУИД КАК табНайденныхПоУИД
	|ГДЕ
	|	табНайденныхПоУИД.ИдентификаторТипа = &ИдентификаторТипа";
	
	Выборка = Запрос.Выполнить().Выбрать();
	
	Если Выборка.Следующий() Тогда
		Возврат Выборка.Ссылка;
	КонецЕсли;
	
	СтруктураРеквизитов = Новый Структура( "ИдентификаторТипа", ИдентификаторТипа );
	
	Возврат СоздатьОписательТипа( ИнформационнаяБаза, СтруктураРеквизитов );
	
КонецФункции

// Функция - Создать описатель типа
//     создает новый описатель типа с заданными значениями реквизитов
//
// Параметры:
//  ИнформационнаяБаза	 - СправочникСсылка.ИнформационныеБазы - информационная база, владелец типа
//  СтруктураРеквизитов	 - Структура - содержит значения реквизитов
// 
// Возвращаемое значение:
//   - СправочникСсылка.ОписателиТиповИнформационныхБаз - ссылка созданного описателя типа
//
Функция СоздатьОписательТипа( ИнформационнаяБаза, СтруктураРеквизитов ) Экспорт
	
	Если ПустаяСтрока( СтруктураРеквизитов.ИдентификаторТипа ) Тогда
		СтрокаСообщения = НСтр( "ru='Ошибка создания описателя типа для базы %1. Идентификатор не должен быть пустым.'" );
		СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку( СтрокаСообщения, ИнформационнаяБаза );
		ВызватьИсключение СтрокаСообщения;
	КонецЕсли;
	
	ОписательТипаОбъект = Справочники.ОписателиТиповИнформационныхБаз.СоздатьЭлемент();
	
	ОписательТипаОбъект.Владелец = ИнформационнаяБаза;
	ОписательТипаОбъект.ИдентификаторТипа = СтруктураРеквизитов.ИдентификаторТипа;
	
	Если Не СтруктураРеквизитов.Свойство( "Наименование", ОписательТипаОбъект.Наименование ) Тогда
		ОписательТипаОбъект.Наименование = СокрЛП( СтруктураРеквизитов.ИдентификаторТипа );
	КонецЕсли;
	
	СтруктураРеквизитов.Свойство( "Комментарий", ОписательТипаОбъект.Комментарий );
	
	ОписательТипаОбъект.Записать();
	
	Возврат ОписательТипаОбъект.Ссылка;
	
КонецФункции

// Функция - Вычислить УИД для идентификатора типа
//
// Параметры:
//  ИдентификаторТипа	 - Строка - идентификатор типа
// 
// Возвращаемое значение:
//   - УникальныйИдентификатор 
//
Функция ВычислитьУИДдляИдентификатораТипа( ИдентификаторТипа ) Экспорт
	
	// генерируем строку для формирования УИД в виде XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX с использованием хэш-функции
	ХешированиеДанных = Новый ХешированиеДанных( ХешФункция.CRC32 );
	ХешированиеДанных.Добавить( ИдентификаторТипа );
	
	СтрокаУИД = Формат( ХешированиеДанных.ХешСумма, "ЧЦ=32; ЧДЦ=; ЧРГ=-; ЧН=; ЧВН=; ЧГ=12,4" );
	СтрокаУИД = Лев( СтрокаУИД, 4 ) + Сред( СтрокаУИД, 6 );
	
	УИД = Новый УникальныйИдентификатор( СтрокаУИД );  
	
	Возврат УИД;
	
КонецФункции