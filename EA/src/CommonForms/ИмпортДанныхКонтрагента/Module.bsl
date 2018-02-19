
&НаКлиенте
Перем ЛогОшибок;

#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Контрагент = Параметры.Контрагент;
	
	ЗаполнитьШаблоныФайловОбмена(ЭтотОбъект);
	
	ИмпортСправочникаТоваров = Параметры.ИмпортСправочникаТоваров;
	ИмпортОстатков           = Параметры.ИмпортОстатков;
	ИмпортЗакупок            = Параметры.ИмпортЗакупок;
	ИмпортПродаж             = Параметры.ИмпортПродаж;
	
	УстановитьДоступностьЭлементовФормы(ЭтотОбъект);
	
	Элементы.ПоказатьЛогОшибок.Видимость = Ложь;
	
КонецПроцедуры

&НаСервере
Процедура ОбработкаПроверкиЗаполненияНаСервере(Отказ, ПроверяемыеРеквизиты)
	
	Если ИмпортСправочникаТоваров Тогда
		ПроверяемыеРеквизиты.Добавить("ИмяФайлаСправочникаТоваров");
		ПроверяемыеРеквизиты.Добавить("ШаблонСправочникаТоваров");
	КонецЕсли;
	
	Если ИмпортОстатков Тогда
		ПроверяемыеРеквизиты.Добавить("ИмяФайлаОстатков");
		ПроверяемыеРеквизиты.Добавить("ШаблонОстатков");
	КонецЕсли;
	
	Если ИмпортЗакупок Тогда
		ПроверяемыеРеквизиты.Добавить("ИмяФайлаЗакупок");
		ПроверяемыеРеквизиты.Добавить("ШаблонЗакупок");
	КонецЕсли;
	
	Если ИмпортПродаж Тогда
		ПроверяемыеРеквизиты.Добавить("ИмяФайлаПродаж");
		ПроверяемыеРеквизиты.Добавить("ШаблонПродаж");
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКоманд

&НаКлиенте
Процедура ЗагрузитьДанные(Команда)
	
	Если Не ПроверитьЗаполнение() Тогда
		Возврат;
	КонецЕсли;
	
	СписокШаблонов = Новый Массив;
	
	Если ИмпортСправочникаТоваров Тогда
		СписокШаблонов.Добавить(ШаблонСправочникаТоваров);
	КонецЕсли;
	
	Если ИмпортОстатков Тогда
		СписокШаблонов.Добавить(ШаблонОстатков);
	КонецЕсли;
	
	Если ИмпортЗакупок Тогда
		СписокШаблонов.Добавить(ШаблонЗакупок);
	КонецЕсли;
	
	Если ИмпортПродаж Тогда
		СписокШаблонов.Добавить(ШаблонПродаж);
	КонецЕсли;
	
	Если СписокШаблонов.Количество() = 0 Тогда
		Возврат;
	КонецЕсли;
	
	ЛогОшибок = Новый ТекстовыйДокумент;
	
	КоличествоОшибок = 0;
	
	ПараметрыЗагрузкиФайловОбмена = ПараметрыЗагрузкиФайловОбмена(СписокШаблонов);
	
	Если ИмпортСправочникаТоваров Тогда
		ПараметрыЗагрузки = ПараметрыЗагрузкиФайловОбмена[ШаблонСправочникаТоваров];
		
		РезультатЗагрузки = ОбменДаннымиСКонтрагентамиКлиент.ЗагрузитьСправочникТоваров(Контрагент, ИмяФайлаСправочникаТоваров, ПараметрыЗагрузки);
		ДобавитьОшибкиВЛог(РезультатЗагрузки.СтрокиСОшибками, ПараметрыЗагрузки.НачальнаяСтрока, НСтр("ru='#Импорт справочника товаров'"));
		КоличествоОшибок = КоличествоОшибок + РезультатЗагрузки.СтрокиСОшибками.Количество();
	КонецЕсли;
	
	Если ИмпортОстатков Тогда
		ПараметрыЗагрузки = ПараметрыЗагрузкиФайловОбмена[ШаблонОстатков];
		
		РезультатЗагрузки = ОбменДаннымиСКонтрагентамиКлиент.ЗагрузитьОстатки(Контрагент, ИмяФайлаОстатков, ПараметрыЗагрузки);
		ДобавитьОшибкиВЛог(РезультатЗагрузки.СтрокиСОшибками, ПараметрыЗагрузки.НачальнаяСтрока, НСтр("ru='#Импорт остатков'"));
		КоличествоОшибок = КоличествоОшибок + РезультатЗагрузки.СтрокиСОшибками.Количество();
	КонецЕсли;
	
	Если ИмпортЗакупок Тогда
		ПараметрыЗагрузки = ПараметрыЗагрузкиФайловОбмена[ШаблонЗакупок];
		
		РезультатЗагрузки = ОбменДаннымиСКонтрагентамиКлиент.ЗагрузитьЗакупки(Контрагент, ИмяФайлаЗакупок, ПараметрыЗагрузки);
		ДобавитьОшибкиВЛог(РезультатЗагрузки.СтрокиСОшибками, ПараметрыЗагрузки.НачальнаяСтрока, НСтр("ru='#Импорт закупок'"));
		КоличествоОшибок = КоличествоОшибок + РезультатЗагрузки.СтрокиСОшибками.Количество();
	КонецЕсли;
	
	Если ИмпортПродаж Тогда
		ПараметрыЗагрузки = ПараметрыЗагрузкиФайловОбмена[ШаблонПродаж];
		
		РезультатЗагрузки = ОбменДаннымиСКонтрагентамиКлиент.ЗагрузитьПродажи(Контрагент, ИмяФайлаПродаж, ПараметрыЗагрузки);
		ДобавитьОшибкиВЛог(РезультатЗагрузки.СтрокиСОшибками, ПараметрыЗагрузки.НачальнаяСтрока, НСтр("ru='#Импорт продаж'"));
		КоличествоОшибок = КоличествоОшибок + РезультатЗагрузки.СтрокиСОшибками.Количество();
	КонецЕсли;
	
	Если КоличествоОшибок > 0 Тогда
		ЗаголовокЭлемента = НСтр("ru='Показать лог ошибок (%1)'");
		ЗаголовокЭлемента = СтрШаблон(ЗаголовокЭлемента, КоличествоОшибок);
	Иначе
		ЗаголовокЭлемента = НСтр("ru='Показать лог ошибок'");
	КонецЕсли;
	
	Элементы.ПоказатьЛогОшибок.Заголовок = ЗаголовокЭлемента;
	Элементы.ПоказатьЛогОшибок.Видимость = КоличествоОшибок > 0;
	
	ПоказатьПредупреждение(, НСтр("ru='Загрузка данных завершена'"));
	
КонецПроцедуры

&НаКлиенте
Процедура ПоказатьЛогОшибок(Команда)
	
	Если ТипЗнч(ЛогОшибок) = Тип("ТекстовыйДокумент") И ЛогОшибок.КоличествоСтрок() > 0 Тогда
		ЛогОшибок.Показать(НСтр("ru='Лог ошибок'"));
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовФормы

&НаКлиенте
Процедура ИмпортСправочникаТоваровПриИзменении(Элемент)
	
	УстановитьДоступностьЭлементовФормы(ЭтотОбъект);
	
КонецПроцедуры

&НаКлиенте
Процедура ИмпортОстатковПриИзменении(Элемент)
	
	УстановитьДоступностьЭлементовФормы(ЭтотОбъект);
	
КонецПроцедуры

&НаКлиенте
Процедура ИмпортЗакупокПриИзменении(Элемент)
	
	УстановитьДоступностьЭлементовФормы(ЭтотОбъект);
	
КонецПроцедуры

&НаКлиенте
Процедура ИмпортПродажПриИзменении(Элемент)
	
	УстановитьДоступностьЭлементовФормы(ЭтотОбъект);
	
КонецПроцедуры

&НаКлиенте
Процедура ИмяФайлаСправочникаТоваровНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	
	ДиалогВыбораФайла = Новый ДиалогВыбораФайла(РежимДиалогаВыбораФайла.Открытие);
	ДиалогВыбораФайла.Фильтр = ФильтрОбменаДиалогаВыбораФайла(ШаблонСправочникаТоваров);
	ДиалогВыбораФайла.Показать(Новый ОписаниеОповещения("ИмяФайлаСправочникаТоваровНачалоВыбораЗавершение", ЭтотОбъект));
	
КонецПроцедуры

&НаКлиенте
Процедура ИмяФайлаОстатковНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	
	ДиалогВыбораФайла = Новый ДиалогВыбораФайла(РежимДиалогаВыбораФайла.Открытие);
	ДиалогВыбораФайла.Фильтр = ФильтрОбменаДиалогаВыбораФайла(ШаблонОстатков);
	ДиалогВыбораФайла.Показать(Новый ОписаниеОповещения("ИмяФайлаОстатковНачалоВыбораЗавершение", ЭтотОбъект));
	
КонецПроцедуры

&НаКлиенте
Процедура ИмяФайлаЗакупокНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	
	ДиалогВыбораФайла = Новый ДиалогВыбораФайла(РежимДиалогаВыбораФайла.Открытие);
	ДиалогВыбораФайла.Фильтр = ФильтрОбменаДиалогаВыбораФайла(ШаблонЗакупок);
	ДиалогВыбораФайла.Показать(Новый ОписаниеОповещения("ИмяФайлаЗакупокНачалоВыбораЗавершение", ЭтотОбъект));
	
КонецПроцедуры

&НаКлиенте
Процедура ИмяФайлаПродажНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	
	ДиалогВыбораФайла = Новый ДиалогВыбораФайла(РежимДиалогаВыбораФайла.Открытие);
	ДиалогВыбораФайла.Фильтр = ФильтрОбменаДиалогаВыбораФайла(ШаблонПродаж);
	ДиалогВыбораФайла.Показать(Новый ОписаниеОповещения("ИмяФайлаПродажНачалоВыбораЗавершение", ЭтотОбъект));
	
КонецПроцедуры

&НаКлиенте
Процедура КонтрагентПриИзменении(Элемент)
	
	ЗаполнитьШаблоныФайловОбмена(ЭтотОбъект);
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаКлиенте
Функция ФильтрОбменаДиалогаВыбораФайла(Шаблон)
	
	СписокФильтров = Новый Массив;
	СписокФильтров.Добавить(НСтр("ru='Файлы обмена|*.xls;*.xlsx;*.dbf;*.xml'"));
	СписокФильтров.Добавить(НСтр("ru='Все файлы|*.*'"));
	
	Если ЗначениеЗаполнено(Шаблон) Тогда
		ТипФайла = ТипФайлаШаблона(Шаблон);
		Если ТипФайла = ПредопределенноеЗначение("Перечисление.ФорматыФайловОбмена.DBF") Тогда
			СписокФильтров.Вставить(0, НСтр("ru='Файлы таблиц|*.dbf'"));
		ИначеЕсли ТипФайла = ПредопределенноеЗначение("Перечисление.ФорматыФайловОбмена.XLS") Тогда
			СписокФильтров.Вставить(0, НСтр("ru='Файлы Excel|*.xls;*.xlsx'"));
		ИначеЕсли ТипФайла = ПредопределенноеЗначение("Перечисление.ФорматыФайловОбмена.XML") Тогда
			СписокФильтров.Вставить(0, НСтр("ru='Файлы XML|*.xml'"));
		КонецЕсли;
	КонецЕсли;
	
	Возврат СтрСоединить(СписокФильтров, "|");
	
КонецФункции

&НаСервереБезКонтекста
Функция ТипФайлаШаблона(Шаблон)
	
	Возврат ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Шаблон, "ТипФайла");
	
КонецФункции

&НаКлиентеНаСервереБезКонтекста
Процедура ЗаполнитьШаблоныФайловОбмена(Форма)
	
	Если Не ЗначениеЗаполнено(Форма.Контрагент) Тогда
		Возврат;
	КонецЕсли;
	
	ШаблоныФайлов = ШаблоныФайловОбменаКонтрагента(Форма.Контрагент);
	
	Если ШаблоныФайлов[ПредопределенноеЗначение("Перечисление.ВидыИмпортируемыхДанных.СправочникТоваров")] <> Неопределено Тогда
		Форма.ШаблонСправочникаТоваров = ШаблоныФайлов[ПредопределенноеЗначение("Перечисление.ВидыИмпортируемыхДанных.СправочникТоваров")];
	КонецЕсли;
	
	Если ШаблоныФайлов[ПредопределенноеЗначение("Перечисление.ВидыИмпортируемыхДанных.Остатки")] <> Неопределено Тогда
		Форма.ШаблонОстатков = ШаблоныФайлов[ПредопределенноеЗначение("Перечисление.ВидыИмпортируемыхДанных.Остатки")];
	КонецЕсли;
	
	Если ШаблоныФайлов[ПредопределенноеЗначение("Перечисление.ВидыИмпортируемыхДанных.Закупки")] <> Неопределено Тогда
		Форма.ШаблонЗакупок = ШаблоныФайлов[ПредопределенноеЗначение("Перечисление.ВидыИмпортируемыхДанных.Закупки")];
	КонецЕсли;
	
	Если ШаблоныФайлов[ПредопределенноеЗначение("Перечисление.ВидыИмпортируемыхДанных.Продажи")] <> Неопределено Тогда
		Форма.ШаблонПродаж = ШаблоныФайлов[ПредопределенноеЗначение("Перечисление.ВидыИмпортируемыхДанных.Продажи")];
	КонецЕсли;
	
КонецПроцедуры

&НаСервереБезКонтекста
Функция ШаблоныФайловОбменаКонтрагента(Контрагент)
	
	Возврат РегистрыСведений.ШаблоныФайловОбменаКонтрагентов.ШаблоныФайловОбменаКонтрагента(Контрагент);
	
КонецФункции

&НаСервереБезКонтекста
Функция ПараметрыЗагрузкиФайловОбмена(СписокШаблонов)
	
	Результат = Новый Соответствие;
	
	Для Каждого Шаблон Из СписокШаблонов Цикл
		Результат.Вставить(Шаблон, Справочники.ШаблоныФайловОбмена.ПараметрыЗагрузкиФайловОбмена(Шаблон));
	КонецЦикла;
	
	Возврат Результат;
	
КонецФункции

&НаКлиентеНаСервереБезКонтекста
Процедура УстановитьДоступностьЭлементовФормы(Форма)
	
	Форма.Элементы.ИмяФайлаСправочникаТоваров.ТолькоПросмотр = Не Форма.ИмпортСправочникаТоваров;
	Форма.Элементы.ШаблонСправочникаТоваров.ТолькоПросмотр   = Не Форма.ИмпортСправочникаТоваров;
	
	Форма.Элементы.ИмяФайлаОстатков.ТолькоПросмотр           = Не Форма.ИмпортОстатков;
	Форма.Элементы.ШаблонОстатков.ТолькоПросмотр             = Не Форма.ИмпортОстатков;
	
	Форма.Элементы.ИмяФайлаЗакупок.ТолькоПросмотр            = Не Форма.ИмпортЗакупок;
	Форма.Элементы.ШаблонЗакупок.ТолькоПросмотр              = Не Форма.ИмпортЗакупок;
	
	Форма.Элементы.ИмяФайлаПродаж.ТолькоПросмотр             = Не Форма.ИмпортПродаж;
	Форма.Элементы.ШаблонПродаж.ТолькоПросмотр               = Не Форма.ИмпортПродаж;
	
КонецПроцедуры

&НаКлиенте
Процедура ИмяФайлаСправочникаТоваровНачалоВыбораЗавершение(ВыбранныеФайлы, ДополнительныеПараметры) Экспорт
	
	Если ВыбранныеФайлы = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	ИмяФайлаСправочникаТоваров = ВыбранныеФайлы[0];
	
КонецПроцедуры

&НаКлиенте
Процедура ИмяФайлаОстатковНачалоВыбораЗавершение(ВыбранныеФайлы, ДополнительныеПараметры) Экспорт
	
	Если ВыбранныеФайлы = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	ИмяФайлаОстатков = ВыбранныеФайлы[0];
	
КонецПроцедуры

&НаКлиенте
Процедура ИмяФайлаЗакупокНачалоВыбораЗавершение(ВыбранныеФайлы, ДополнительныеПараметры) Экспорт
	
	Если ВыбранныеФайлы = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	ИмяФайлаЗакупок = ВыбранныеФайлы[0];
	
КонецПроцедуры

&НаКлиенте
Процедура ИмяФайлаПродажНачалоВыбораЗавершение(ВыбранныеФайлы, ДополнительныеПараметры) Экспорт
	
	Если ВыбранныеФайлы = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	ИмяФайлаПродаж = ВыбранныеФайлы[0];
	
КонецПроцедуры

&НаКлиенте
Процедура ДобавитьОшибкиВЛог(СтрокиСОшибками, НачальнаяСтрока, ЗаголовокРаздела)
	
	Если СтрокиСОшибками.Количество() = 0 Тогда
		Возврат;
	КонецЕсли;
	
	Если ЛогОшибок.КоличествоСтрок() > 0 Тогда
		ЛогОшибок.ДобавитьСтроку(Символы.ПС);
	КонецЕсли;
	
	ЛогОшибок.ДобавитьСтроку(ЗаголовокРаздела);
	
	Для Каждого СтрокаСОшибкой Из СтрокиСОшибками Цикл
		ТекстОшибки = НСтр("ru='Строка %1: %2'");
		ТекстОшибки = СтрШаблон(ТекстОшибки, Формат(НачальнаяСтрока + СтрокаСОшибкой.НомерСтроки - 1, "ЧГ=0"), СтрокаСОшибкой.ТекстОшибки);
		
		ЛогОшибок.ДобавитьСтроку(ТекстОшибки);
	КонецЦикла;
	
КонецПроцедуры

#КонецОбласти