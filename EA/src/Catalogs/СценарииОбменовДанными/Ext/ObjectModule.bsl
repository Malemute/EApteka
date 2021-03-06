﻿#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область ОбработчикиСобытий

Процедура ПередЗаписью(Отказ)
	
	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;
	
	Если ПометкаУдаления Тогда
		
		ИспользоватьРегламентноеЗадание = Ложь;
		
	КонецЕсли;
	
КонецПроцедуры

Процедура ПриЗаписи(Отказ)
	
	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;
	
	// Удаляем регламентное задание при необходимости.
	Если ПометкаУдаления Тогда
		
		УдалитьРегламентноеЗадание(Отказ);
		
	КонецЕсли;
	
	// Обновляем кэш платформы для зачитывания актуальных настроек
	// сценария обмена данными процедурой ОбменДаннымиПовтИсп.ПолучитьСтруктуруНастроекОбмена.
	ОбновитьПовторноИспользуемыеЗначения();
	
КонецПроцедуры

Процедура ПриКопировании(ОбъектКопирования)
	
	РегламентноеЗаданиеGUID = "";
	
КонецПроцедуры

Процедура ПередУдалением(Отказ)
	
	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;
	
	УдалитьРегламентноеЗадание(Отказ);
	
КонецПроцедуры

Процедура ОбработкаПроверкиЗаполнения(Отказ, ПроверяемыеРеквизиты)
	
	Для Каждого СтрокаНастройкиОбмена Из ЭтотОбъект.НастройкиОбмена Цикл
	
		Если ЗначениеЗаполнено( СтрокаНастройкиОбмена.УзелИнформационнойБазы ) И СтрокаНастройкиОбмена.УзелИнформационнойБазы.ЭтотУзел = Истина Тогда
			СтрокаСообщения = НСтр( "ru = 'В строке %1 Настроек Обмена указан недопустимый узел.'" );
			СтрокаСообщения = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку( СтрокаСообщения, СтрокаНастройкиОбмена.НомерСтроки );
			ОбменДаннымиСервер.СообщитьОбОшибке( СтрокаСообщения, Отказ );
		КонецЕсли;
		
	КонецЦикла;
		
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

// Выполняет удаление регламентного задания.
//
// Параметры:
//  Отказ                     - Булево - флаг отказа. Если в процессе выполнения процедуры были обнаружены ошибки,
//                                       то флаг отказа устанавливается в значение Истина.
// 
Процедура УдалитьРегламентноеЗадание(Отказ)
	
	УстановитьПривилегированныйРежим(Истина);
	
	// Определяем регламентное задание.
	РегламентноеЗаданиеОбъект = ОбменДаннымиВызовСервера.НайтиРегламентноеЗаданиеПоПараметру(РегламентноеЗаданиеGUID);
	
	Если РегламентноеЗаданиеОбъект <> Неопределено Тогда
		
		Попытка
			РегламентноеЗаданиеОбъект.Удалить();
		Исключение
			СтрокаСообщения = НСтр("ru = 'Ошибка при удалении регламентного задания: %1'");
			СтрокаСообщения = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(СтрокаСообщения, КраткоеПредставлениеОшибки(ИнформацияОбОшибке()));
			ОбменДаннымиСервер.СообщитьОбОшибке(СтрокаСообщения, Отказ);
		КонецПопытки;
		
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#КонецЕсли
