
Функция ПолучитьТипПоВидуОбъектаМ( ВидОбъектаМ ) Экспорт
	
	Возврат ТипЗнч( ВидОбъектаМ.ПустаяСсылка );
	
КонецФункции

// Ищет ВидОбъектаМ по Объекту
// 		Объект может быть непосредственно Объектом, Ссылкой, Строкой с ПолнымИменемМетаданных или Метаданными
Функция ПолучитьСсылкуВидаОбъектаМПоОбъекту( Объект ) Экспорт
	
	Если ТипЗнч( Объект ) = Тип( "Строка" ) Тогда
		
		// Ищем по ПолномуИмениМетаданных
		Выборка = ПолучитьВыборкуВидовОбъектовМПоПолномуИмениМетаданных( Объект );
		
	ИначеЕсли ТипЗнч( Объект ) = Тип( "ОбъектМетаданных" ) Тогда
		
		// Ищем по ПолномуИмениМетаданных
		Выборка = ПолучитьВыборкуВидовОбъектовМПоПолномуИмениМетаданных( Объект.ПолноеИмя() );
		
	Иначе
	
		Попытка
			
			// получим пустую ссылку по которой будем искать
			МассивТипов = Новый Массив;
			МассивТипов.Добавить( ТипЗнч( Объект.Ссылка ) );
			ОписаниеТипов = Новый ОписаниеТипов( МассивТипов );
			
			ПустаяСсылка = ОписаниеТипов.ПривестиЗначение( Неопределено );
			
			// теперь найдем ВидОбъектаМ по ПустойСсылке
			Выборка = ПолучитьВыборкуВидовОбъектовМПоПустойСсылке( ПустаяСсылка );
			
		Исключение
			
			Попытка
				
				// все равно попробуем найти, только через Метаданные()
				Выборка = ПолучитьВыборкуВидовОбъектовМПоПолномуИмениМетаданных( Объект.Метаданные().ПолноеИмя() );
				
			Исключение
				Возврат Неопределено;
			КонецПопытки;
			
		КонецПопытки;
		
	КонецЕсли;
	
	Если Выборка.Следующий() Тогда
		Возврат Выборка.Ссылка;
	КонецЕсли;
	
	Возврат Неопределено;
	
КонецФункции

Функция ПолучитьВыборкуВидовОбъектовМПоПустойСсылке( ПустаяСсылка ) Экспорт
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр( "ПустаяСсылка", ПустаяСсылка );
	Запрос.Текст =
	"ВЫБРАТЬ
	|	ВидыОбъектовМ.Ссылка
	|ИЗ
	|	Справочник.ВидыОбъектовМ КАК ВидыОбъектовМ
	|ГДЕ
	|	ВидыОбъектовМ.ПометкаУдаления = ЛОЖЬ
	|	И ВидыОбъектовМ.ПустаяСсылка = &ПустаяСсылка";
	
	Возврат Запрос.Выполнить().Выбрать();
	
КонецФункции

Функция ПолучитьВыборкуВидовОбъектовМПоПолномуИмениМетаданных( ПолноеИмяМетаданных ) Экспорт
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр( "ПолноеИмяМетаданных", ПолноеИмяМетаданных );
	Запрос.Текст =
	"ВЫБРАТЬ
	|	ВидыОбъектовМ.Ссылка
	|ИЗ
	|	Справочник.ВидыОбъектовМ КАК ВидыОбъектовМ
	|ГДЕ
	|	ВидыОбъектовМ.ПометкаУдаления = ЛОЖЬ
	|	И ВидыОбъектовМ.ПолноеИмяМетаданных = &ПолноеИмяМетаданных";
	
	Возврат Запрос.Выполнить().Выбрать();
	
КонецФункции

Функция СоздатьВидОбъектаМПоТипуИИдетификатору( ТипОбъекта, Идентификатор ) Экспорт
	
	// проверка на правильность данных
	КоллекцияМетаданных = Перечисления.ТипыОбъектовМ.ПолучитьКоллекциюМетаданныхПоТипуОбъектаМ( ТипОбъекта );
	
	Если КоллекцияМетаданных = Неопределено Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	МетаданныеОбъекта = КоллекцияМетаданных.Найти( Идентификатор );
	
	Если МетаданныеОбъекта = Неопределено Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	// создадим и заполним ВидОбъектаМ
	НовыйВидОбъекта = Справочники.ВидыОбъектовМ.СоздатьЭлемент();
	
	НовыйВидОбъекта.ТипОбъекта = ТипОбъекта;
	НовыйВидОбъекта.Идентификатор = Идентификатор;
	НовыйВидОбъекта.Наименование = ?( ПустаяСтрока( МетаданныеОбъекта.Синоним ), МетаданныеОбъекта.Имя, МетаданныеОбъекта.Синоним );
	
	Попытка
		НовыйВидОбъекта.Записать();
	Исключение
		Возврат Неопределено;
	КонецПопытки;
	
	Возврат НовыйВидОбъекта.Ссылка;
	
КонецФункции