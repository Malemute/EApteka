﻿#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область СлужебныеПроцедурыИФункции

Функция РасписаниеРегламентногоЗаданияПоУмолчанию() Экспорт
	
	Месяцы = Новый Массив;
	Месяцы.Добавить(1);
	Месяцы.Добавить(2);
	Месяцы.Добавить(3);
	Месяцы.Добавить(4);
	Месяцы.Добавить(5);
	Месяцы.Добавить(6);
	Месяцы.Добавить(7);
	Месяцы.Добавить(8);
	Месяцы.Добавить(9);
	Месяцы.Добавить(10);
	Месяцы.Добавить(11);
	Месяцы.Добавить(12);
	
	ДниНедели = Новый Массив;
	ДниНедели.Добавить(1);
	ДниНедели.Добавить(2);
	ДниНедели.Добавить(3);
	ДниНедели.Добавить(4);
	ДниНедели.Добавить(5);
	ДниНедели.Добавить(6);
	ДниНедели.Добавить(7);
	
	Расписание = Новый РасписаниеРегламентногоЗадания;
	Расписание.ДниНедели                = ДниНедели;
	Расписание.ПериодПовтораВТечениеДня = 900; // 15 минут
	Расписание.ПериодПовтораДней        = 1; // каждый день
	Расписание.Месяцы                   = Месяцы;
	
	Возврат Расписание;
КонецФункции

// Получает расписание регламентного задания.
// Если регламентное задание не задано, то возвращает пустое расписание (по умолчанию).
//
Функция ПолучитьРасписаниеВыполненияОбменаДанными(НастройкаВыполненияОбмена) Экспорт
	
	РегламентноеЗаданиеОбъект = ОбменДаннымиВызовСервера.НайтиРегламентноеЗаданиеПоПараметру(НастройкаВыполненияОбмена.РегламентноеЗаданиеGUID);
	
	Если РегламентноеЗаданиеОбъект <> Неопределено Тогда
		
		РасписаниеРегламентногоЗадания = РегламентноеЗаданиеОбъект.Расписание;
		
	Иначе
		
		РасписаниеРегламентногоЗадания = Новый РасписаниеРегламентногоЗадания;
		
	КонецЕсли;
	
	Возврат РасписаниеРегламентногоЗадания;
	
КонецФункции

Процедура ОбновитьДанныеРегламентногоЗадания(Отказ, РасписаниеРегламентногоЗадания, ТекущийОбъект) Экспорт
	
	// Получаем регламентное задание по идентификатору, если объект не находим, то создаем новый.
	РегламентноеЗаданиеОбъект = СоздатьРегламентноеЗаданиеПриНеобходимости(Отказ, ТекущийОбъект);
	
	Если Отказ Тогда
		Возврат;
	КонецЕсли;
	
	// обновляем свойства РЗ
	УстановитьПараметрыРегламентногоЗадания(РегламентноеЗаданиеОбъект, РасписаниеРегламентногоЗадания, ТекущийОбъект);
	
	// Записываем измененное задание.
	ЗаписатьРегламентноеЗадание(Отказ, РегламентноеЗаданиеОбъект);
	
	// Запоминаем GUID регламентное задания в реквизите объекта.
	ТекущийОбъект.РегламентноеЗаданиеGUID = Строка(РегламентноеЗаданиеОбъект.УникальныйИдентификатор);
	
КонецПроцедуры

Функция СоздатьРегламентноеЗаданиеПриНеобходимости(Отказ, ТекущийОбъект)
	
	РегламентноеЗаданиеОбъект = ОбменДаннымиВызовСервера.НайтиРегламентноеЗаданиеПоПараметру(ТекущийОбъект.РегламентноеЗаданиеGUID);
	
	// При необходимости создаем регламентное задание.
	Если РегламентноеЗаданиеОбъект = Неопределено Тогда
		
		РегламентноеЗаданиеОбъект = РегламентныеЗадания.СоздатьРегламентноеЗадание("СинхронизацияДанных");
		
	КонецЕсли;
	
	Возврат РегламентноеЗаданиеОбъект;
	
КонецФункции

Процедура УстановитьПараметрыРегламентногоЗадания(РегламентноеЗаданиеОбъект, РасписаниеРегламентногоЗадания, ТекущийОбъект)
	
	Если ПустаяСтрока(ТекущийОбъект.Код) Тогда
		
		ТекущийОбъект.УстановитьНовыйКод();
		
	КонецЕсли;
	
	ПараметрыРегламентногоЗадания = Новый Массив;
	ПараметрыРегламентногоЗадания.Добавить(ТекущийОбъект.Код);
	
	НаименованиеРегламентногоЗадания = НСтр("ru = 'Выполнение обмена по сценарию: %1'");
	НаименованиеРегламентногоЗадания = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(НаименованиеРегламентногоЗадания, СокрЛП(ТекущийОбъект.Наименование));
	
	РегламентноеЗаданиеОбъект.Наименование  = Лев(НаименованиеРегламентногоЗадания, 120);
	РегламентноеЗаданиеОбъект.Использование = ТекущийОбъект.ИспользоватьРегламентноеЗадание;
	РегламентноеЗаданиеОбъект.Параметры     = ПараметрыРегламентногоЗадания;
	
	// Обновляем расписание, если оно было изменено.
	Если РасписаниеРегламентногоЗадания <> Неопределено Тогда
		РегламентноеЗаданиеОбъект.Расписание = РасписаниеРегламентногоЗадания;
	КонецЕсли;
	
КонецПроцедуры

// Выполняет запись регламентного задания.
//
// Параметры:
//  Отказ                     - Булево - флаг отказа. Если в процессе выполнения процедуры были обнаружены ошибки,
//                                       то флаг отказа устанавливается в значение Истина.
//  РегламентноеЗаданиеОбъект - объект регламентного задания, которое необходимо записать.
// 
Процедура ЗаписатьРегламентноеЗадание(Отказ, РегламентноеЗаданиеОбъект)
	
	УстановитьПривилегированныйРежим(Истина);
	
	Попытка
		
		// записываем задание
		РегламентноеЗаданиеОбъект.Записать();
		
	Исключение
		
		СтрокаСообщения = НСтр("ru = 'Произошла ошибка при сохранении расписания выполнения обменов. Подробное описание ошибки: %1'");
		СтрокаСообщения = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(СтрокаСообщения, КраткоеПредставлениеОшибки(ИнформацияОбОшибке()));
		ОбменДаннымиСервер.СообщитьОбОшибке(СтрокаСообщения, Отказ);
		
	КонецПопытки;
	
КонецПроцедуры

//

Процедура ДобавитьВыгрузкуВСценарииОбменаДанными(СценарийОбменаДанными, УзелИнформационнойБазы) Экспорт
	
	НадоЗаписатьОбъект = Ложь;
	
	Если ТипЗнч(СценарийОбменаДанными) = Тип("СправочникСсылка.СценарииОбменовДанными") Тогда
		
		СценарийОбменаДанными = СценарийОбменаДанными.ПолучитьОбъект();
		
		НадоЗаписатьОбъект = Истина;
		
	КонецЕсли;
	
	ВидТранспортаОбмена = РегистрыСведений.НастройкиТранспортаОбмена.ВидТранспортаСообщенийОбменаПоУмолчанию(УзелИнформационнойБазы);
	
	НастройкиОбмена = СценарийОбменаДанными.НастройкиОбмена;
	
	// Добавляем выгрузку данных в цикле.
	МаксимальныйИндекс = НастройкиОбмена.Количество() - 1;
	
	Для Индекс = 0 По МаксимальныйИндекс Цикл
		
		ОбратныйИндекс = МаксимальныйИндекс - Индекс;
		
		СтрокаТаблицы = НастройкиОбмена[ОбратныйИндекс];
		
		// последняя строка выгрузки
		Если СтрокаТаблицы.ВыполняемоеДействие = Перечисления.ДействияПриОбмене.ВыгрузкаДанных Тогда
			
			НоваяСтрока = НастройкиОбмена.Вставить(ОбратныйИндекс + 1);
			
			НоваяСтрока.УзелИнформационнойБазы = УзелИнформационнойБазы;
			НоваяСтрока.ВидТранспортаОбмена    = ВидТранспортаОбмена;
			НоваяСтрока.ВыполняемоеДействие    = Перечисления.ДействияПриОбмене.ВыгрузкаДанных;
			
			Прервать;
		КонецЕсли;
		
	КонецЦикла;
	
	// Если в цикле строка выгрузки не была добавлена, то вставляем строку в конец таблицы.
	Отбор = Новый Структура("УзелИнформационнойБазы, ВыполняемоеДействие", УзелИнформационнойБазы, Перечисления.ДействияПриОбмене.ВыгрузкаДанных);
	Если НастройкиОбмена.НайтиСтроки(Отбор).Количество() = 0 Тогда
		
		НоваяСтрока = НастройкиОбмена.Добавить();
		
		НоваяСтрока.УзелИнформационнойБазы = УзелИнформационнойБазы;
		НоваяСтрока.ВидТранспортаОбмена    = ВидТранспортаОбмена;
		НоваяСтрока.ВыполняемоеДействие    = Перечисления.ДействияПриОбмене.ВыгрузкаДанных;
		
	КонецЕсли;
	
	Если НадоЗаписатьОбъект Тогда
		
		// Записываем изменения в объекте.
		СценарийОбменаДанными.Записать();
		
	КонецЕсли;
	
КонецПроцедуры

Процедура ДобавитьЗагрузкуВСценарииОбменаДанными(СценарийОбменаДанными, УзелИнформационнойБазы) Экспорт
	
	НадоЗаписатьОбъект = Ложь;
	
	Если ТипЗнч(СценарийОбменаДанными) = Тип("СправочникСсылка.СценарииОбменовДанными") Тогда
		
		СценарийОбменаДанными = СценарийОбменаДанными.ПолучитьОбъект();
		
		НадоЗаписатьОбъект = Истина;
		
	КонецЕсли;
	
	ВидТранспортаОбмена = РегистрыСведений.НастройкиТранспортаОбмена.ВидТранспортаСообщенийОбменаПоУмолчанию(УзелИнформационнойБазы);
	
	НастройкиОбмена = СценарийОбменаДанными.НастройкиОбмена;
	
	// Добавляем загрузку данных в цикле.
	Для каждого СтрокаТаблицы Из НастройкиОбмена Цикл
		
		Если СтрокаТаблицы.ВыполняемоеДействие = Перечисления.ДействияПриОбмене.ЗагрузкаДанных Тогда // первая строка загрузки
			
			НоваяСтрока = НастройкиОбмена.Вставить(НастройкиОбмена.Индекс(СтрокаТаблицы));
			
			НоваяСтрока.УзелИнформационнойБазы = УзелИнформационнойБазы;
			НоваяСтрока.ВидТранспортаОбмена    = ВидТранспортаОбмена;
			НоваяСтрока.ВыполняемоеДействие    = Перечисления.ДействияПриОбмене.ЗагрузкаДанных;
			
			Прервать;
		КонецЕсли;
		
	КонецЦикла;
	
	// Если в цикле строка загрузки не была добавлена, то вставляем строку в начало таблицы.
	Отбор = Новый Структура("УзелИнформационнойБазы, ВыполняемоеДействие", УзелИнформационнойБазы, Перечисления.ДействияПриОбмене.ЗагрузкаДанных);
	Если НастройкиОбмена.НайтиСтроки(Отбор).Количество() = 0 Тогда
		
		НоваяСтрока = НастройкиОбмена.Вставить(0);
		
		НоваяСтрока.УзелИнформационнойБазы = УзелИнформационнойБазы;
		НоваяСтрока.ВидТранспортаОбмена    = ВидТранспортаОбмена;
		НоваяСтрока.ВыполняемоеДействие    = Перечисления.ДействияПриОбмене.ЗагрузкаДанных;
		
	КонецЕсли;
	
	Если НадоЗаписатьОбъект Тогда
		
		// Записываем изменения в объекте.
		СценарийОбменаДанными.Записать();
		
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#КонецЕсли
