
Функция ОбновитьУдаленнуюБазуДанных(Узел,РасшифровкаРезультата = Неопределено) Экспорт
	
	Если ТипЗнч(Узел) <> Тип("ПланОбменаСсылка.ПланОбменаОбновлениями") или не ЗначениеЗаполнено(Узел) тогда
		РасшифровкаРезультата = "Передан не корректный узел обмена";
		Возврат Ложь;
	КонецЕсли;
	НастройкаВебСервиса = Узел.НастройкаВебСервиса;
	Если не ЗначениеЗаполнено(Узел.НастройкаВебСервиса) тогда
		РасшифровкаРезультата = "У узла "+Узел.Наименование+" не заполнена настройка для подключения к вебсервису!";
		Возврат Ложь;
	КонецЕсли;
	
	ТекстОшибки = "";
	ПодключениеWS = ОбщийМодульВебСервисы.ПодключитьсяКВебСервису(НастройкаВебСервиса,ТекстОшибки);
	Если ПодключениеWS = неопределено тогда
		РасшифровкаРезультата = "Ну удалось подключится к базе узла "+Узел.Наименование+" по причине:"+Символы.ПС+ТекстОшибки;
		Возврат Ложь;
	КонецЕсли;
	
	Конфигурация = ЗначениеВСтрокуВнутр(ВыгрузитьИзмененияКонфигурации(Узел));
	
	Результат = ПодключениеWS.ConfigExchange(Конфигурация); 	
	Если Результат = "ОК" тогда
		РасшифровкаРезультата = "Данные переданны в базу узла "+Узел.Наименование+", изменений в конфигурации нет";
	ИначеЕсли стрНайти(Результат,"Обновление может быть выполнено в режиме Конфигуратор.") <> 0 тогда
		РасшифровкаРезультата = "Данные переданны в базу узла "+Узел.Наименование+", изменения конфигурации загруженны, необходимо обновить удаленную базу";
	Иначе
		РасшифровкаРезультата = "При передачи данных в узел "+Узел.Наименование+" Произошла ошибка :" + символы.ПС+Результат;
		Возврат Ложь;
	КонецЕсли;
	
	ПланыОбмена.УдалитьРегистрациюИзменений(Узел);	
	
	Возврат Истина;
	
КонецФункции

Функция ВыгрузитьИзмененияКонфигурации(Узел)
	
	ИмяФайла = ПолучитьИмяВременногоФайла();
	ФайлXML = Новый ЗаписьXML;
	ФайлXML.УстановитьСтроку();
	ЗаписьСообщения = ПланыОбмена.СоздатьЗаписьСообщения();
	НомерСообщения  = ЗаписьСообщения.НомерСообщения;	
	ЗаписьСообщения.НачатьЗапись(ФайлXML,Узел);
	ПланыОбмена.ЗаписатьИзменения(ЗаписьСообщения);
	ЗаписьСообщения.ЗакончитьЗапись();
	Данные = ФайлXML.Закрыть();	
	Хранилище = Новый ХранилищеЗначения(Данные, Новый СжатиеДанных(9));
	
	Возврат Хранилище;
	
КонецФункции

Функция ЗагрузитьИзмененияКонфигурации(Хранилище) Экспорт
	
	Попытка
		ИзмененияВКонфигурации = Хранилище.Получить();	
		ЧтениеXML = Новый ЧтениеXML;
		ЧтениеXML.УстановитьСтроку(ИзмененияВКонфигурации);
		ЧтениеСообщения = ПланыОбмена.СоздатьЧтениеСообщения();
		ЧтениеСообщения.НачатьЧтение(ЧтениеXML);
		ПланыОбмена.ПрочитатьИзменения(ЧтениеСообщения);
		ЧтениеСообщения.ЗакончитьЧтение();
		ЧтениеXML.Закрыть();	
		Возврат "ОК";
	Исключение
		Возврат ОписаниеОшибки();
	КонецПопытки;
	
КонецФункции

Процедура Обмен_РИБД_РегистрыСведенийПриЗаписи(Источник, Отказ, Замещение) Экспорт
	Обмен_РИБДПриЗаписи(Источник, Отказ);
КонецПроцедуры

Процедура Обмен_РИБДПриЗаписи(Источник, Отказ) Экспорт
	Если Источник.ОбменДанными.Загрузка тогда
		Возврат;
	КонецЕсли;
	
	СтруктураСвязанныхОБъектов = ПометитьЭлементНаОбмен(Источник,Отказ);
	Если СтруктураСвязанныхОБъектов <> неопределено тогда
		//МассивПараметров = Новый Массив;
		//МассивПараметров.Добавить(СтруктураСвязанныхОБъектов.МассивСвязанныхОбъектов);
		//МассивПараметров.Добавить(СтруктураСвязанныхОБъектов.МассивИсключаемыхТипов);
		//МассивПараметров.Добавить(СтруктураСвязанныхОБъектов.МассивУзловДляРегистрации);
		//ФоновыеЗадания.Выполнить("ОбменАлгоритмыРИБД.ПометитьНаОбменСвязанныеОбъекты",МассивПараметров,,"Пометка на обмен объектов связанных с " + Строка(Источник));
		Попытка
			ПометитьНаОбменСвязанныеОбъекты(СтруктураСвязанныхОБъектов.МассивСвязанныхОбъектов,СтруктураСвязанныхОБъектов.МассивИсключаемыхТипов,СтруктураСвязанныхОБъектов.МассивУзловДляРегистрации);
		Исключение
		КонецПопытки;
	КонецЕсли;
	
КонецПроцедуры

Функция ПолучитьИмяАптекиДляЗаголовка() Экспорт
	Если ЭтоЦентральнаяБаза() тогда
		Возврат "Аптеки Центральная";
	Иначе
		Возврат "Аптеки "+Константы.АдресХраненияТекущейБазы.Получить().Наименование;
	КонецЕсли;	
КонецФункции

Процедура ПометитьНаОбменСвязанныеОбъекты(МассивСвязанныхОбъектов,МассивИсключаемыхТипов,МассивУзловДляРегистрации) Экспорт
	МассивСвязанныхОбъектовРекурсия = Новый Массив;
	Для каждого Объект из МассивСвязанныхОбъектов цикл
		СтруктураСвязанныхОБъектов = ПометитьЭлементНаОбмен(Объект,Ложь,Истина,МассивУзловДляРегистрации);
		Если СтруктураСвязанныхОБъектов <> неопределено тогда
			Для каждого ИсключаемыйТип из СтруктураСвязанныхОБъектов.МассивИсключаемыхТипов цикл
				Если МассивИсключаемыхТипов.Найти(ИсключаемыйТип) = неопределено тогда
					МассивИсключаемыхТипов.Добавить(ИсключаемыйТип);
				КонецЕсли;
			КонецЦикла;
			Для каждого ЗависимыйОбъект из СтруктураСвязанныхОБъектов.МассивСвязанныхОбъектов цикл
				Попытка
					Если МассивИсключаемыхТипов.Найти(ТипЗнч(ЗависимыйОбъект.Ссылка)) <> Неопределено тогда 
						Продолжить;
					Иначе
						МассивСвязанныхОбъектовРекурсия.Добавить(ЗависимыйОбъект);
					КонецЕсли;
				Исключение
					Продолжить;
				КонецПопытки;
			КонецЦикла;
		Иначе
			Продолжить;
		КонецЕсли;
	КонецЦикла;
	Если МассивСвязанныхОбъектовРекурсия.Количество() > 0 тогда
		ПометитьНаОбменСвязанныеОбъекты(МассивСвязанныхОбъектовРекурсия,МассивИсключаемыхТипов,МассивУзловДляРегистрации);
	КонецЕсли;
	
КонецПроцедуры

Функция ПометитьЭлементНаОбмен(Источник, Отказ,ЗависимыйЭлемент = ложь,МассивУзловДляРегистрации = Неопределено)
	
	Если не Метаданные.ПланыОбмена.ПланОбменаДанными.Состав.Содержит(Источник.Метаданные()) тогда
		Возврат неопределено;
	КонецЕсли;
	
	
	ЭтоЦентральнаяБаза = ЭтоЦентральнаяБаза();
	НаправлениеОбмена = Новый Массив;
	НаправлениеОбмена.Добавить(Перечисления.Обмен_НаправлениеОбмена.ПоАдресуХранения);
	Если ЭтоЦентральнаяБаза тогда
		НаправлениеОбмена.Добавить(Перечисления.Обмен_НаправлениеОбмена.ВПодчиненныйУзел);	
		Если ЗависимыйЭлемент = Истина тогда
			НаправлениеОбмена.Добавить(Перечисления.Обмен_НаправлениеОбмена.ВЦентральныйУзел);	
		КонецЕсли;
	Иначе
		НаправлениеОбмена.Добавить(Перечисления.Обмен_НаправлениеОбмена.ВЦентральныйУзел);
	КонецЕсли;
	Метаданное = Источник.Метаданные();
	ПолноеИмяМетаданого = Метаданное.ПолноеИмя();
	ПравилоОбмена = ПолучитьНастройкуОбъекта(ПолноеИмяМетаданого,НаправлениеОбмена);
	Если ПравилоОбмена.Количество() = 0 тогда
		Возврат Неопределено;
	КонецЕсли;
	
	
	ПравилоОбменаОбъекта = ПравилоОбмена[0];
	
	Если не ЭтоЦентральнаяБаза и ПравилоОбменаОбъекта.НаправлениеОбмена = Перечисления.Обмен_НаправлениеОбмена.ВПодчиненныйУзел тогда
		Сообщить("Объекты данного типа могут быть измененны только центральной базе!!!");		
		Отказ = Истина;
		Возврат Неопределено;
	КонецЕсли;
	
	Если  МассивУзловДляРегистрации = неопределено тогда
		АдресХранения = Неопределено;
		
		Если ПравилоОбменаОбъекта.НаправлениеОбмена = Перечисления.Обмен_НаправлениеОбмена.ПоАдресуХранения тогда
			Попытка
				Выполнить("АдресХранения = Источник."+ПравилоОбменаОбъекта.УсловиеПоАдресуХранения);
			Исключение
			КонецПопытки;
		КонецЕсли;
		
		Если (ПравилоОбменаОбъекта.НаправлениеОбмена = Перечисления.Обмен_НаправлениеОбмена.ВПодчиненныйУзел или ПравилоОбменаОбъекта.НаправлениеОбмена = Перечисления.Обмен_НаправлениеОбмена.ПоАдресуХранения и ЭтоЦентральнаяБаза)  
			и ЗначениеЗаполнено(ПравилоОбменаОбъекта.ПроизвольныйАлгоритм) тогда
			Попытка
				Выполнить(ПравилоОбменаОбъекта.ПроизвольныйАлгоритм);	
			Исключение
			КонецПопытки
		КонецЕсли;
		
		Если АдресХранения = Ложь тогда
			Возврат Неопределено;
		КонецЕсли;
		
		МассивУзловДляРегистрации = ПолучитьМассивУзловДляРегистрации(ЭтоЦентральнаяБаза,АдресХранения);
		
	КонецЕсли;
	Если не ТипЗнч(МассивУзловДляРегистрации) = тип("Массив") 
		или МассивУзловДляРегистрации.Количество() = 0 тогда
		Возврат Неопределено;
	КонецЕсли;
	
	МассивСвязанныхОбъектов = Новый Массив;
	
	Для каждого строка из ПравилоОбмена цикл
		Если Строка.Реквизит = "Ссылка" тогда
			Данные = Источник;
			Если Строка.НеЗависимыйРегистр тогда
				ИсключаемыйТип = ТипЗнч(Источник);
			Иначе
				ИсключаемыйТип = ТипЗнч(Источник.Ссылка);
			КонецЕсли;
			Если ЗначениеЗаполнено(Строка.АлгоритмОпределенияПроизвольныхСвязанныхОбъектов) тогда
				Попытка
					Выполнить(Строка.АлгоритмОпределенияПроизвольныхСвязанныхОбъектов);
				Исключение
					Описание = ОписаниеОшибки();
					Сообщить(Описание);
				КонецПопытки;
				Если ТипЗнч(МассивСвязанныхОбъектов) <> Тип("Массив") тогда
					МассивСвязанныхОбъектов = Новый Массив;	
				КонецЕсли;
			КонецЕсли;
		ИначеЕсли Строка.Движение тогда
			//Если Строка.Реквизит = "ТоварыКСборке" и 
			//	ТипЗнч(Источник.Ссылка) = Тип("ДокументСсылка.Заказ") 
			//	И ЭтоЦентральнаяБаза тогда
			//	Продолжить;
			//КонецЕсли;             
			Если строка.Ссылка.ТипОбъектаМетаданных = "РегистрНакопления" тогда
				Данные = РегистрыНакопления[Строка.Реквизит].СоздатьНаборЗаписей();
			ИначеЕсли строка.Ссылка.ТипОбъектаМетаданных = "РегистрСведений" тогда
				Данные = РегистрыСведений[Строка.Реквизит].СоздатьНаборЗаписей();
			Иначе
				Продолжить;
			КонецЕсли;
			Данные.Отбор.Регистратор.Значение = Источник.Ссылка;
			Данные.Отбор.Регистратор.Использование = Истина;
		ИначеЕсли ЗначениеЗаполнено(Строка.ИмяТабличнойЧасти) тогда
			Для каждого строкаТЧ из Источник[Строка.ИмяТабличнойЧасти] цикл
				СвязанныйОбъектСсылка = строкаТЧ[Строка.Реквизит];
				Если ЗначениеЗаполнено(СвязанныйОбъектСсылка) 
					и ТипЗнч(СвязанныйОбъектСсылка) <> ИсключаемыйТип тогда
					МассивСвязанныхОбъектов.Добавить(СвязанныйОбъектСсылка);
				КонецЕсли;
			КонецЦикла;
			Продолжить;
		Иначе
			СвязанныйОбъектСсылка = Источник[Строка.Реквизит];
			Если ЗначениеЗаполнено(СвязанныйОбъектСсылка) 
				и ТипЗнч(СвязанныйОбъектСсылка) <> ИсключаемыйТип тогда
				МассивСвязанныхОбъектов.Добавить(СвязанныйОбъектСсылка);
			КонецЕсли; 
			Продолжить;
		КонецЕсли;
		Попытка
			ПланыОбмена.ЗарегистрироватьИзменения(МассивУзловДляРегистрации,Данные);
		Исключение
			Описание = ОписаниеОшибки();
		КонецПопытки;
	КонецЦикла;
	МассивИсключаемыхТипов = Новый Массив;
	МассивИсключаемыхТипов.Добавить(ИсключаемыйТип);
	
	СтруктураСвязанныОбъектов = Новый Структура;
	СтруктураСвязанныОбъектов.Вставить("МассивСвязанныхОбъектов",МассивСвязанныхОбъектов);
	СтруктураСвязанныОбъектов.Вставить("МассивИсключаемыхТипов",МассивИсключаемыхТипов);
	СтруктураСвязанныОбъектов.Вставить("МассивУзловДляРегистрации",МассивУзловДляРегистрации);
	Возврат СтруктураСвязанныОбъектов;
	
КонецФункции

Функция ЭтоЦентральнаяБаза() Экспорт
	
	Возврат ПланыОбмена.ГлавныйУзел() = Неопределено;
	
КонецФункции

Функция ПолучитьМассивУзловДляРегистрации(ЭтоЦентральнаяБаза,АдресХранения=Неопределено)
	
	МассивУзлов = Новый Массив;
	
	Если ЭтоЦентральнаяБаза тогда
		Запрос = Новый Запрос;
		Запрос.Текст = 
		"ВЫБРАТЬ
		|	ПланОбменаОбновлениями.Ссылка
		|ПОМЕСТИТЬ втКорневыеУзлы
		|ИЗ
		|	ПланОбмена.ПланОбменаОбновлениями КАК ПланОбменаОбновлениями
		|ГДЕ
		|	НЕ ПланОбменаОбновлениями.ЭтотУзел
		|	И ПланОбменаОбновлениями.ВключитьОбмен
		|	И (ПланОбменаОбновлениями.АдресХранения в (&АдресХранения)
		|			ИЛИ &АдресХраненияПустой)
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	ПланОбменаДанными.Ссылка
		|ИЗ
		|	втКорневыеУзлы КАК втКорневыеУзлы
		|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ ПланОбмена.ПланОбменаДанными КАК ПланОбменаДанными
		|		ПО втКорневыеУзлы.Ссылка = ПланОбменаДанными.ОсновнойУзел";
		Запрос.УстановитьПараметр("АдресХранения", АдресХранения);
		Запрос.УстановитьПараметр("АдресХраненияПустой", ?(АдресХранения = Неопределено,Истина,Ложь));
		
		МассивУзлов = Запрос.Выполнить().Выгрузить().ВыгрузитьКолонку("Ссылка");    		
	Иначе
		МассивУзлов.Добавить(ПланыОбмена.ПланОбменаДанными.НайтиПоРеквизиту("ОсновнойУзел",ПланыОбмена.ГлавныйУзел()));
	КонецЕсли;
	
	Возврат МассивУзлов;
	
КонецФункции

Функция ПолучитьНастройкуОбъекта(ПолноеИмяМетаданного,НаправлениеОбмена)
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	НастройкиОбмена.Ссылка,
	|	НастройкиОбмена.НеЗависимыйРегистр
	|ПОМЕСТИТЬ втНастройкаОбмена
	|ИЗ
	|	Справочник.НастройкиОбмена КАК НастройкиОбмена
	|ГДЕ
	|	НастройкиОбмена.ВключитьВОбмен
	|	И НастройкиОбмена.НаправлениеОбмена В(&НаправлениеОбмена)
	|	И НастройкиОбмена.Наименование = &ПолноеИмяМетаданного
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	НастройкиОбмена.Ссылка,
	|	""Ссылка"" КАК Реквизит,
	|	ЛОЖЬ КАК Движение,
	|	втНастройкаОбмена.НеЗависимыйРегистр,
	|	НастройкиОбмена.УсловиеПоАдресуХранения,
	|	НастройкиОбмена.НаправлениеОбмена,
	|	НастройкиОбмена.ПроизвольныйАлгоритм,
	|	"""" КАК ИмяТабличнойЧасти,
	|	НастройкиОбмена.АлгоритмОпределенияПроизвольныхСвязанныхОбъектов
	|ИЗ
	|	втНастройкаОбмена КАК втНастройкаОбмена
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Справочник.НастройкиОбмена КАК НастройкиОбмена
	|		ПО втНастройкаОбмена.Ссылка = НастройкиОбмена.Ссылка
	|
	|ОБЪЕДИНИТЬ ВСЕ
	|
	|ВЫБРАТЬ
	|	НастройкиОбменаПодчиненныеОбъекты.ПодчиненныйОбъект,
	|	НастройкиОбменаПодчиненныеОбъекты.ИмяРеквизита,
	|	НастройкиОбменаПодчиненныеОбъекты.Движение,
	|	ЛОЖЬ,
	|	"""",
	|	"""",
	|	"""",
	|	НастройкиОбменаПодчиненныеОбъекты.ТабличнаяЧасть,
	|	""""
	|ИЗ
	|	втНастройкаОбмена КАК втНастройкаОбмена
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Справочник.НастройкиОбмена.ПодчиненныеОбъекты КАК НастройкиОбменаПодчиненныеОбъекты
	|		ПО втНастройкаОбмена.Ссылка = НастройкиОбменаПодчиненныеОбъекты.Ссылка
	|ГДЕ
	|	НастройкиОбменаПодчиненныеОбъекты.ПодчиненныйОбъект.ВключитьВОбмен
	|	И (НастройкиОбменаПодчиненныеОбъекты.Движение 
	|	или НастройкиОбменаПодчиненныеОбъекты.ПодчиненныйОбъект.НаправлениеОбмена В(&НаправлениеОбмена)
	|	или НастройкиОбменаПодчиненныеОбъекты.ПодчиненныйОбъект.НаправлениеОбмена = Значение(Перечисление.Обмен_НаправлениеОбмена.ВЦентральныйУзел))
	|	И НастройкиОбменаПодчиненныеОбъекты.МетитьНаОбмен = ИСТИНА";
	Запрос.УстановитьПараметр("ПолноеИмяМетаданного", ПолноеИмяМетаданного);
	Запрос.УстановитьПараметр("НаправлениеОбмена", НаправлениеОбмена);
	
	Возврат Запрос.Выполнить().Выгрузить();	
	
КонецФункции

Функция ЗагрузитьДанныеРИБД(DataString) Экспорт
	
	ТаблицаОшибок = Новый ТаблицаЗначений;
	ТаблицаОшибок.Колонки.Добавить("ПредставлениеОбъекта");
	ТаблицаОшибок.Колонки.Добавить("ОписаниеОшибки");
	ТаблицаОшибок.Колонки.Добавить("ИдОбъектаОбмена");
	
	ВсеСсылкиСправочники = Справочники.ТипВсеСсылки();
	ВсеСсылкиДокументы = Документы.ТипВсеСсылки();
	
	СтрокаДанных = ЗначениеИзСтрокиВнутр(DataString).Получить();
	ЧтениеJSON = Новый ЧтениеJSON;
	ЧтениеJSON.УстановитьСтроку(СтрокаДанных);
	ИдОбъектаОбмена = 0;
	МассивОбъектов = СериализаторXDTO.ПрочитатьJSON(ЧтениеJSON);
	
	Для каждого Объект из МассивОбъектов цикл
		Объект.ОбменДанными.Загрузка = Истина;
		ПредставлениеОбъекта = Строка(Объект);
		Попытка
			Если СтрНайти(Строка(ТипЗнч(Объект)),"Документ") <> 0 тогда
				Объект.Записать(РежимЗаписиДокумента.Запись);	
			Иначе
				Объект.Записать();		
			КонецЕсли;
		Исключение
			СтрокаОшибки = ТаблицаОшибок.Добавить();
			СтрокаОшибки.ПредставлениеОбъекта = ПредставлениеОбъекта;
			СтрокаОшибки.ОписаниеОшибки = ОписаниеОшибки();
			СтрокаОшибки.ИдОбъектаОбмена = ИдОбъектаОбмена;
		КонецПопытки;
		ИдОбъектаОбмена = ИдОбъектаОбмена + 1;
	КонецЦикла;
	
	
	Возврат ЗначениеВСтрокуВнутр(ТаблицаОшибок);
	
КонецФункции

Функция ВыгрузитьДанныеРИБД(Узел,РасшифровкаРезультата = неопределено,ФильтрВыгрузкиПоМетаданному = неопределено) Экспорт
	
	ВсеСправочники = Справочники.ТипВсеСсылки();
	ВсеДокументы = Документы.ТипВсеСсылки();
	Если не ЗначениеЗаполнено(Узел) тогда
		РасшифровкаРезультата = "Не выбран узел!";
		Возврат Ложь;
	КонецЕсли;
	
	Если Не ЗначениеЗаполнено(Узел.ОсновнойУзел) тогда
		РасшифровкаРезультата = "У выбранного узла не заполнен основной узел!";
		Возврат Ложь;
	КонецЕсли;
	
	Если не Узел.ОсновнойУзел.ВключитьОбмен тогда
		РасшифровкаРезультата = "У основного узла отключен обмен!";
		Возврат Ложь;
	КонецЕсли;
	
	Порция = Узел.ПорцияОбмена;
	Если Порция = 0 тогда
		Порция = 1000;
	КонецЕсли;
	
	НачалоЦикла = ТекущаяДата();
	Попытка
		КоличествоВОчереди = ПолучитьКоличествоОбъектовВОчередиНаОбмен(Узел,"ПланОбменаДанными");
		ЗаписатьЛогОбмена(НачалоЦикла,Узел, КоличествоВОчереди);
	Исключение
		Сообщить(ОписаниеОшибки());
		КоличествоВОчереди = 0;
	КонецПопытки;
	
	ТекстОшибки = "";
	Прокси = ОбщийМодульВебСервисы.ПодключитьсяКВебСервису(Узел.ОсновнойУзел.НастройкаВебСервиса,ТекстОшибки,90);
	Если Прокси = Неопределено тогда
		Попытка
			ЗаписатьЛогОбмена(НачалоЦикла,Узел,,,,ТекстОшибки);
		Исключение
			Сообщить(ОписаниеОшибки());
		КонецПопытки;
		Возврат Ложь;
	КонецЕсли;
	Выборка = ПланыОбмена.ВыбратьИзменения(Узел,0,ФильтрВыгрузкиПоМетаданному);	
	
	МассивВыгружаемыхЭлементов = Новый Массив;
	ИД = 0;
	ОбъектовВыгружено = 0;
	ОбъектовСОшибками = 0;
	Пока выборка.Следующий() цикл
		ОбъектовВыгружено = ОбъектовВыгружено + 1;
		Данные = Выборка.Получить();
		ТипДанных = Строка(ТипЗнч(Данные));
		МассивВыгружаемыхЭлементов.Добавить(Данные);	
		Если ИД = Порция тогда
			СтрокаДанных = СоздатьЗаписьJSON(МассивВыгружаемыхЭлементов);	
			Попытка
				Результат = Прокси.DataExchange(СтрокаДанных);
			Исключение
				ЗаписатьЛогОбмена(НачалоЦикла,Узел,,,,,ОписаниеОшибки());
				Результат = Неопределено;
			КонецПопытки;
			Если Результат <> неопределено тогда
				ТаблицаОшибок = ЗначениеИзСтрокиВнутр(Результат);
				ИДЭ = 0;
				Для каждого ЭлементМассива из МассивВыгружаемыхЭлементов Цикл
					Если ТаблицаОшибок.Найти(ИДЭ,"ИдОбъектаОбмена") = Неопределено тогда
						ПланыОбмена.УдалитьРегистрациюИзменений(Узел,ЭлементМассива);
					Иначе
						ОбъектовСОшибками = ОбъектовСОшибками + 1;
					КонецЕсли;
					ИДЭ = ИДЭ+1;
				КонецЦикла;
			КонецЕсли;
			Попытка
				ЗаписатьЛогОбмена(НачалоЦикла,Узел,ПолучитьКоличествоОбъектовВОчередиНаОбмен(Узел,"ПланОбменаДанными"),ОбъектовСОшибками,ОбъектовВыгружено);
			Исключение
				Сообщить(ОписаниеОшибки());
			КонецПопытки;
			ИД = 0;
			МассивВыгружаемыхЭлементов = Новый Массив;
		Иначе
			ИД = ИД+1;
		КонецЕсли;
	КонецЦикла;
	
	СтрокаДанных = СоздатьЗаписьJSON(МассивВыгружаемыхЭлементов);	
	Попытка
		Результат = Прокси.DataExchange(СтрокаДанных);
	Исключение
		ЗаписатьЛогОбмена(НачалоЦикла,Узел,,,,,ОписаниеОшибки());
		Результат = Неопределено;
	КонецПопытки;
	Если Результат <> неопределено тогда
		ТаблицаОшибок = ЗначениеИзСтрокиВнутр(Результат);
		ИД = 0;
		Для каждого ЭлементМассива из МассивВыгружаемыхЭлементов Цикл
			Если ТаблицаОшибок.Найти(ИД,"ИдОбъектаОбмена") = Неопределено тогда
				ПланыОбмена.УдалитьРегистрациюИзменений(Узел,ЭлементМассива);
			КонецЕсли;
			ИД = ИД+1;
		КонецЦикла;
	КонецЕсли;
	Попытка
		ЗаписатьЛогОбмена(НачалоЦикла,Узел,ПолучитьКоличествоОбъектовВОчередиНаОбмен(Узел,"ПланОбменаДанными"),ОбъектовСОшибками,ОбъектовВыгружено,Истина);
	Исключение
		Сообщить(ОписаниеОшибки());
	КонецПопытки;
	
	Возврат Истина;
	
КонецФункции

Процедура ЗаписатьЛогОбмена(Период, Узел, ОбъектовВОчереди=неопределено,ОбъектовСОшибками = Неопределено,ОбъектовВыгруженно=Неопределено,ЦиклОбменаЗавершен=Ложь,ОписаниеОшибки=Неопределено)
	МенеджерЗаписи = РегистрыСведений.ОбменРИБД_ЛогОбмена.СоздатьМенеджерЗаписи();
	МенеджерЗаписи.Период = Период;
	МенеджерЗаписи.Узел = Узел;
	МенеджерЗаписи.Прочитать();
	Если не МенеджерЗаписи.Выбран() тогда 
		МенеджерЗаписи = РегистрыСведений.ОбменРИБД_ЛогОбмена.СоздатьМенеджерЗаписи();
		МенеджерЗаписи.Период = Период;
		МенеджерЗаписи.Узел = Узел;
	КонецЕсли;
	
	Если ОбъектовВОчереди <> неопределено тогда
		МенеджерЗаписи.ОбъектовВОчереди = ОбъектовВОчереди;
	КонецЕсли;
	Если ОбъектовВыгруженно <> неопределено  тогда
		МенеджерЗаписи.ОбъектовВыгруженно = ОбъектовВыгруженно;
	КонецЕсли;
	Если ОбъектовСОшибками <> неопределено  тогда
		МенеджерЗаписи.ОбъектовСОшибками = ОбъектовСОшибками;
	КонецЕсли;
	МенеджерЗаписи.ЦиклОбменаЗавершен = ЦиклОбменаЗавершен;
	Если ОписаниеОшибки  <> неопределено  тогда
		МенеджерЗаписи.ОписаниеОшибки = ОписаниеОшибки;
	КонецЕсли;
	МенеджерЗаписи.Записать();
	
КонецПроцедуры

Функция ПолучитьКоличествоОбъектовВОчередиНаОбмен(Узел,ПланОбменаИмя) Экспорт
	
	СоставПланаОбмена = Метаданные.ПланыОбмена.ПланОбменаДанными.Состав;
	Запрос = Новый Запрос;
	Запрос.Текст = ОбменДаннымиПовтИсп.ПолучитьТекстЗапроса_КоличествоОбъектовВОчередиПоУзлуПланаОбмена(ПланОбменаИмя,"Таблица.Узел = &Узел и Таблица.Узел.ОсновнойУзел.ВключитьОбмен");
	Запрос.УстановитьПараметр("Узел",Узел);
	Результат = Запрос.Выполнить();
	Если Результат.Пустой() тогда
		Возврат 0;
	Иначе
		Выборка = Результат.Выбрать();
		Пока Выборка.Следующий() цикл
			Возврат Выборка.Количество;
		КонецЦикла;
	КонецЕсли;
	
КонецФункции

Функция СоздатьЗаписьJSON(МассивОбъектов)
	
	ЗаписьJSON = Новый ЗаписьJSON;
	ЗаписьJSON.УстановитьСтроку();
	СериализаторXDTO.ЗаписатьJSON(ЗаписьJSON,МассивОбъектов,НазначениеТипаXML.Явное);
	ТекстJSON = ЗаписьJSON.Закрыть();
	Возврат ЗначениеВСтрокуВнутр(Новый ХранилищеЗначения(ТекстJSON, Новый СжатиеДанных(9)));
	
КонецФункции

Процедура ВыполнитьПометкуОбъектовДляПервоначальногоЗаполнения(Узел) Экспорт
	
	Если НЕ ЭтоЦентральнаяБаза() тогда
		Сообщение = Новый СообщениеПользователю;
		Сообщение.Текст = "Выгрузку первоначального заполнения можно сделать только из центральной базы!";
		Сообщение.Сообщить();
		Возврат;
	КонецЕсли;
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	НастройкиОбмена.Ссылка,
	|	НастройкиОбмена.ИмяОбъектаМетаданных
	|ИЗ
	|	Справочник.Обмен_ОписаниеОбъектов77 КАК Обмен_ОписаниеОбъектов77
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Справочник.НастройкиОбмена КАК НастройкиОбмена
	|		ПО Обмен_ОписаниеОбъектов77.Наименование = НастройкиОбмена.Наименование
	|ГДЕ
	|	НастройкиОбмена.НаправлениеОбмена = &НаправлениеОбмена
	|	И НастройкиОбмена.ВключитьВОбмен
	|	И НастройкиОбмена.ТипОбъектаМетаданных = ""Справочник""";
	Запрос.УстановитьПараметр("НаправлениеОбмена",Перечисления.Обмен_НаправлениеОбмена.ВПодчиненныйУзел);
	Выборка = Запрос.Выполнить().Выбрать();
	Пока Выборка.Следующий() Цикл
		Метаданное = Метаданные.Справочники[Выборка.ИмяОбъектаМетаданных];
		ПланыОбмена.ЗарегистрироватьИзменения(Узел,Метаданное);
	КонецЦикла;
	
	ПланыОбмена.ЗарегистрироватьИзменения(Узел,Метаданные.Справочники.НастройкиПодключенийКВебСервисам);
	ПланыОбмена.ЗарегистрироватьИзменения(Узел,Метаданные.Справочники.СтавкиНДС);
	ПланыОбмена.ЗарегистрироватьИзменения(Узел,Метаданные.РегистрыСведений.t_astro_used_booklets);
	ПланыОбмена.ЗарегистрироватьИзменения(Узел,Метаданные.РегистрыСведений.t_check_ucs);
	ПланыОбмена.ЗарегистрироватьИзменения(Узел,Метаданные.РегистрыСведений.t_rr);
	ПланыОбмена.ЗарегистрироватьИзменения(Узел,Метаданные.РегистрыСведений.t_rr_sklad);
	ПланыОбмена.ЗарегистрироватьИзменения(Узел,Метаданные.РегистрыСведений.t_tc);
	ПланыОбмена.ЗарегистрироватьИзменения(Узел,Метаданные.РегистрыСведений.t_ucs);
	ПланыОбмена.ЗарегистрироватьИзменения(Узел,Метаданные.РегистрыСведений.НастройкаСозданияЦеныПартии);
	ПланыОбмена.ЗарегистрироватьИзменения(Узел,Метаданные.РегистрыСведений.СтавкиНДСПоНоменклатуре);
	//ПланыОбмена.ЗарегистрироватьИзменения(Узел,Метаданные.РегистрыСведений.ЦенаНоменклатуры);
	ПланыОбмена.ЗарегистрироватьИзменения(Узел,Метаданные.РегистрыСведений.ТабПродажиАстраЗенека);
	ПланыОбмена.ЗарегистрироватьИзменения(Узел,Метаданные.РегистрыСведений.astro_card_rules);
	ПланыОбмена.ЗарегистрироватьИзменения(Узел,Метаданные.РегистрыСведений.astro_card_types);
	ПланыОбмена.ЗарегистрироватьИзменения(Узел,Метаданные.РегистрыСведений.astro_card_block);
	ПланыОбмена.ЗарегистрироватьИзменения(Узел,Метаданные.Справочники.РегионРаботы);
	ПланыОбмена.ЗарегистрироватьИзменения(Узел,Метаданные.Справочники.ТипЦены);
	ПланыОбмена.ЗарегистрироватьИзменения(Узел,Метаданные.Справочники.НастройкиПодключения);
	
	
	
КонецПроцедуры

Процедура Обмен_РИБД_ВыгрузкаДанных(ФильтрВыгрузкиПоМетаданному = неопределено) Экспорт
	МассивУзлов = Новый Массив;
	ЭтоЦентральнаяБаза = ЭтоЦентральнаяБаза(); 
	Если ЭтоЦентральнаяБаза тогда
		МассивУзлов = ПолучитьМассивУзловДляРегистрации(ЭтоЦентральнаяБаза);	
	Иначе
		МассивУзлов.Добавить(ПланыОбмена.ПланОбменаДанными.НайтиПоКоду(ПланыОбмена.ГлавныйУзел().Код));		
	КонецЕсли;
	Для каждого Узел из МассивУзлов цикл
		ВыгрузитьДанныеРИБД(Узел,,ФильтрВыгрузкиПоМетаданному);	
	КонецЦикла;
КонецПроцедуры

Процедура Обмен_РИБД_ПрефиксацияОбъектов_ДокументыПриУстановкеНовогоНомера(Источник, СтандартнаяОбработка, Префикс) Экспорт
	Если Источник.ОбменДанными.Загрузка тогда
		Возврат;
	КонецЕсли;
	Префикс = ПараметрыСеанса.ТекущийПрефикс;
КонецПроцедуры

Процедура Обмен_РИБД_ВыгрузкаДанныхЗадание() Экспорт
	Обмен_РИБД_ВыгрузкаДанных();	
КонецПроцедуры