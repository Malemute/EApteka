
// Открывает форму записи регистра сведений по заданному отбору.
Процедура ОткрытьФормуЗаписиРегистраСведенийПоОтбору(
												Отбор,
												ЗначенияЗаполнения,
												Знач ИмяРегистра,
												ФормаВладелец,
												Знач ИмяФормы = "",
												ПараметрыФормы = Неопределено,
												ОповещениеОЗакрытии = Неопределено) Экспорт
	
	Перем КлючЗаписи;
	
	НаборЗаписейПустой = ОбменДаннымиВызовСервера.НаборЗаписейРегистраПустой(Отбор, ИмяРегистра);
	
	Если Не НаборЗаписейПустой Тогда
		// Создаем через тип, так как находимся на клиенте.
		
		ТипЗначения = Тип("РегистрСведенийКлючЗаписи." + ИмяРегистра);
		Параметры = Новый Массив(1);
		Параметры[0] = Отбор;
		
		КлючЗаписи = Новый(ТипЗначения, Параметры);
	КонецЕсли;
	
	ПараметрыЗаписи = Новый Структура;
	ПараметрыЗаписи.Вставить("Ключ",               КлючЗаписи);
	ПараметрыЗаписи.Вставить("ЗначенияЗаполнения", ЗначенияЗаполнения);
	
	Если ПараметрыФормы <> Неопределено Тогда
		
		Для Каждого Элемент Из ПараметрыФормы Цикл
			
			ПараметрыЗаписи.Вставить(Элемент.Ключ, Элемент.Значение);
			
		КонецЦикла;
		
	КонецЕсли;
	
	Если ПустаяСтрока(ИмяФормы) Тогда
		
		ПолноеИмяФормы = "РегистрСведений.[ИмяРегистра].ФормаЗаписи";
		ПолноеИмяФормы = СтрЗаменить(ПолноеИмяФормы, "[ИмяРегистра]", ИмяРегистра);
		
	Иначе
		
		ПолноеИмяФормы = "РегистрСведений.[ИмяРегистра].Форма.[ИмяФормы]";
		ПолноеИмяФормы = СтрЗаменить(ПолноеИмяФормы, "[ИмяРегистра]", ИмяРегистра);
		ПолноеИмяФормы = СтрЗаменить(ПолноеИмяФормы, "[ИмяФормы]", ИмяФормы);
		
	КонецЕсли;
	
	// открываем форму записи РС
	Если ОповещениеОЗакрытии <> Неопределено Тогда
		ОткрытьФорму(ПолноеИмяФормы, ПараметрыЗаписи, ФормаВладелец, , , , ОповещениеОЗакрытии);
	Иначе
		ОткрытьФорму(ПолноеИмяФормы, ПараметрыЗаписи, ФормаВладелец);
	КонецЕсли;
	
КонецПроцедуры

// Открывает диалог для выбора файлового каталога, запрашивая установку расширения для работы с файлами.
//
// Параметры:
//     Объект                - Произвольный       - Объект, в котором будет установлено выбираемое свойство.
//     ИмяСвойства           - Строка             - Имя свойства с именем файла, устанавливаемого в объекте. Источник
//                                                  начального значения.
//     СтандартнаяОбработка  - Булево             - Флаг стандартной обработки, устанавливается в Ложь.
//     ПараметрыДиалога      - Структура          - Необязательные дополнительные параметры диалога выбора каталога.
//     ОповещениеЗавершения  - ОписаниеОповещения - Необязательное оповещение, которое будет вызвано со следующими
//                                                  параметрами:
//                                 Результат               - Строка - Выбранное значение (массив строк, если был
//                                                                    множественный выбор);
//                                 ДополнительныеПараметры - Неопределено.
//
Процедура ОбработчикВыбораФайловогоКаталога(Объект, Знач ИмяСвойства, СтандартнаяОбработка = Ложь, Знач ПараметрыДиалога = Неопределено, ОповещениеЗавершения = Неопределено) Экспорт
	СтандартнаяОбработка = Ложь;
	
	УмолчанияДиалога = Новый Структура;
	УмолчанияДиалога.Вставить("Заголовок", НСтр("ru = 'Укажите каталог'") );
	
	УстановитьЗначенияСтруктурыПоУмолчанию(ПараметрыДиалога, УмолчанияДиалога);
	
	ТекстПредупреждения = НСтр("ru = 'Для данной операции необходимо установить расширение для веб-клиента 1С:Предприятие.'");
	
	ДополнительныеПараметры = Новый Структура;
	ДополнительныеПараметры.Вставить("Объект",               Объект);
	ДополнительныеПараметры.Вставить("ИмяСвойства",          ИмяСвойства);
	ДополнительныеПараметры.Вставить("ПараметрыДиалога",     ПараметрыДиалога);
	ДополнительныеПараметры.Вставить("ОповещениеЗавершения", ОповещениеЗавершения);
	
	Оповещение = Новый ОписаниеОповещения("ОбработчикВыбораФайловогоКаталогаЗавершение", ЭтотОбъект, ДополнительныеПараметры);
	ОбщегоНазначенияКлиент.ПоказатьВопросОбУстановкеРасширенияРаботыСФайлами(Оповещение, ТекстПредупреждения, Ложь);
КонецПроцедуры

// Обработчик немодального завершения диалога выбора каталога.
//
Процедура ОбработчикВыбораФайловогоКаталогаЗавершение(Знач Результат, Знач ДополнительныеПараметры) Экспорт
	Если Результат <> Истина Тогда
		Возврат;
	КонецЕсли;
	
	ИмяСвойства = ДополнительныеПараметры.ИмяСвойства;
	Объект      = ДополнительныеПараметры.Объект;
	
	Диалог = Новый ДиалогВыбораФайла(РежимДиалогаВыбораФайла.ВыборКаталога);
	ЗаполнитьЗначенияСвойств(Диалог, ДополнительныеПараметры.ПараметрыДиалога);
	
	Диалог.Каталог = Объект[ИмяСвойства];
	Если Диалог.Выбрать() Тогда
		Объект[ИмяСвойства] = Диалог.Каталог;
		
		Если ДополнительныеПараметры.ОповещениеЗавершения <> Неопределено Тогда
			Результат = ?(Диалог.МножественныйВыбор, Диалог.ВыбранныеФайлы, Диалог.Каталог);
			ВыполнитьОбработкуОповещения(ДополнительныеПараметры.ОповещениеЗавершения, Результат);
		КонецЕсли;
	КонецЕсли;
	
КонецПроцедуры

// Добавляет поля в целевую структуру, если их там нет.
//
// Параметры:
//     Результат           - Структура - Целевая структура.
//     ЗначенияПоУмолчанию - Структура - Значения по умолчанию.
//
Процедура УстановитьЗначенияСтруктурыПоУмолчанию(Результат, Знач ЗначенияПоУмолчанию)
	
	Если Результат = Неопределено Тогда
		Результат = Новый Структура;
	КонецЕсли;
	
	Для Каждого КлючЗначение Из ЗначенияПоУмолчанию Цикл
		ИмяСвойства = КлючЗначение.Ключ;
		Если Не Результат.Свойство(ИмяСвойства) Тогда
			Результат.Вставить(ИмяСвойства, КлючЗначение.Значение);
		КонецЕсли;
	КонецЦикла;
	
КонецПроцедуры

// Открывает файл в ассоциированном приложении операционной системы.
//
// Параметры:
//     Объект               - Произвольный - Объект из которого по имени свойства будет получено имя файла для открытия.
//     ИмяСвойства          - Строка       - Имя свойства объекта из которого будет получено имя файла для открытия.
//     СтандартнаяОбработка - Булево       - Флаг стандартной обработки, устанавливается в Ложь.
//
Процедура ОбработчикОткрытияФайлаИлиКаталога(Объект, ИмяСвойства, СтандартнаяОбработка = Ложь) Экспорт
	СтандартнаяОбработка = Ложь;
	
	ПолноеИмяФайла = Объект[ИмяСвойства];
	Если ПустаяСтрока(ПолноеИмяФайла) Тогда
		Возврат;
	КонецЕсли;
	
	Оповещение = Новый ОписаниеОповещения("ОбработчикОткрытияФайлаИлиКаталогаПослеНачалаЗапускаПриложения", ЭтотОбъект);
	НачатьЗапускПриложения(Оповещение, ПолноеИмяФайла);
	
КонецПроцедуры

// Продолжение процедуры (см. выше).
Процедура ОбработчикОткрытияФайлаИлиКаталогаПослеНачалаЗапускаПриложения(КодВозврата, ДополнительныеПараметры) Экспорт
	// Обработка не требуется.
КонецПроцедуры

