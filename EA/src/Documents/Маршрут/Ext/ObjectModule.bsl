﻿
Процедура ОбработкаПроведения(Отказ, РежимПроведения)
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	МаршрутЗаказы.ДокДоставка КАК Заказ,
	|	МаршрутЗаказы.ДокДоставка.ТочкаСамовывоза.АдресХранения КАК АдресХранения,
	|	МаршрутНаАптеку.Ссылка КАК МаршрутНаАптеку,
	|	МаршрутЗаказы.Ссылка.Номер КАК Номер,
	|	МаршрутЗаказы.Ссылка.Дата КАК Дата,
	|	ЕСТЬNULL(НаклейкиМестЗаказа.Ссылка, ЗНАЧЕНИЕ(Справочник.НаклейкиМестЗаказа.ПустаяСсылка)) КАК МестоЗаказа
	|ИЗ
	|	Документ.Маршрут.Заказы КАК МаршрутЗаказы
	|		ЛЕВОЕ СОЕДИНЕНИЕ Документ.МаршрутНаАптеку КАК МаршрутНаАптеку
	|		ПО МаршрутЗаказы.Ссылка = МаршрутНаАптеку.ДокументОснование
	|			И МаршрутЗаказы.ДокДоставка.ТочкаСамовывоза.АдресХранения = МаршрутНаАптеку.АдресХранения
	|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.НаклейкиМестЗаказа КАК НаклейкиМестЗаказа
	|		ПО МаршрутЗаказы.ДокДоставка = НаклейкиМестЗаказа.Документ
	|ГДЕ
	|	МаршрутЗаказы.Ссылка = &Ссылка
	|	И МаршрутЗаказы.ДокДоставка <> ЗНАЧЕНИЕ(документ.Заказ.ПустаяСсылка)
	|
	|ОБЪЕДИНИТЬ ВСЕ
	|
	|ВЫБРАТЬ
	|	НЕОПРЕДЕЛЕНО,
	|	МаршрутКоробкиСборки.АдресХранения,
	|	МаршрутНаАптеку.Ссылка,
	|	МаршрутКоробкиСборки.Ссылка.Номер,
	|	МаршрутКоробкиСборки.Ссылка.Дата,
	|	NULL
	|ИЗ
	|	Документ.Маршрут.КоробкиСборки КАК МаршрутКоробкиСборки
	|		ЛЕВОЕ СОЕДИНЕНИЕ Документ.МаршрутНаАптеку КАК МаршрутНаАптеку
	|		ПО МаршрутКоробкиСборки.Ссылка = МаршрутНаАптеку.ДокументОснование
	|			И МаршрутКоробкиСборки.АдресХранения = МаршрутНаАптеку.АдресХранения
	|ГДЕ
	|	МаршрутКоробкиСборки.Ссылка = &Ссылка
	|ИТОГИ
	|	МАКСИМУМ(МаршрутНаАптеку),
	|	МАКСИМУМ(Номер),
	|	МАКСИМУМ(Дата)
	|ПО
	|	АдресХранения";
	Запрос.УстановитьПараметр("Ссылка",Ссылка);
	ВыборкаАХ = Запрос.Выполнить().Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
	Пока ВыборкаАХ.Следующий() Цикл
		Если НЕ ЗначениеЗаполнено(ВыборкаАХ.МаршрутНаАптеку) тогда
			МаршрутНаАптеку = Документы.МаршрутНаАптеку.СоздатьДокумент();
			МаршрутНаАптеку.ДокументОснование = Ссылка;
			МаршрутНаАптеку.АдресХранения = ВыборкаАХ.АдресХранения;
			МаршрутНаАптеку.Дата = ВыборкаАХ.Дата;
			МаршрутНаАптеку.НомерДокументаОснования = Формат(ВыборкаАХ.Номер,"ЧГ=");
		Иначе
			МаршрутНаАптеку = ВыборкаАХ.МаршрутНаАптеку.ПолучитьОбъект();
		КонецЕсли;
		СоставБыл = МаршрутНаАптеку.Состав.Выгрузить();
		МаршрутНаАптеку.Состав.Очистить();
		Выборка = ВыборкаАХ.Выбрать();
		Пока Выборка.Следующий() цикл
			Если Выборка.Заказ <> неопределено тогда
				НоваяСтрока = МаршрутНаАптеку.Состав.Добавить();
				НоваяСтрока.Заказ = Выборка.Заказ;
				НоваяСтрока.МестоЗаказа = Выборка.МестоЗаказа;
			КонецЕсли;
		КонецЦикла;
		СоставСтал = МаршрутНаАптеку.Состав.Выгрузить(); 
		ЗапросСравнение = Новый Запрос;
		ЗапросСравнение.Текст = 
		"ВЫБРАТЬ
		|	Было.Заказ,
		|	Было.МестоЗаказа
		|ПОМЕСТИТЬ втБыло
		|ИЗ
		|	&Было КАК Было
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	Стало.Заказ,
		|	Стало.МестоЗаказа
		|ПОМЕСТИТЬ втСтало
		|ИЗ
		|	&Стало КАК Стало
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	втБыло.Заказ,
		|	втБыло.МестоЗаказа,
		|	втСтало.МестоЗаказа КАК МестоЗаказа1,
		|	втСтало.Заказ КАК Заказ1
		|ИЗ
		|	втБыло КАК втБыло
		|		ПОЛНОЕ СОЕДИНЕНИЕ втСтало КАК втСтало
		|		ПО втБыло.Заказ = втСтало.Заказ
		|			И втБыло.МестоЗаказа = втСтало.МестоЗаказа
		|ГДЕ
		|	(втБыло.Заказ ЕСТЬ NULL 
		|			ИЛИ втСтало.Заказ ЕСТЬ NULL )";
		Запрос.УстановитьПараметр("Было",СоставБыл);
		Запрос.УстановитьПараметр("Стало",СоставСтал);
		Если Запрос.Выполнить().Пустой() и не КоробкиСборки.Количество() = 0 тогда
			Продолжить;
		КонецЕсли;
		МаршрутНаАптеку.Состав.Свернуть("Заказ,МестоЗаказа");
		
		МаршрутНаАптеку.КоробкиСборки.Очистить();
		
		СтрокиАХ = КоробкиСборки.НайтиСтроки(Новый Структура("АдресХранения",МаршрутНаАптеку.АдресХранения));
		Для каждого строка из СтрокиАХ цикл
			СтрКор = МаршрутНаАптеку.КоробкиСборки.Добавить();
			СтрКор.Коробка = Строка.Коробка;
		КонецЦикла;
		
		МаршрутНаАптеку.Записать(РежимЗаписиДокумента.Проведение);
		
		Если МаршрутНаАптеку.Проведен Тогда 
			СоздатьСчетаФактуры(МаршрутНаАптеку.Ссылка);
		КонецЕсли;
		
	КонецЦикла;
	
КонецПроцедуры

Процедура СоздатьСчетаФактуры(МаршрутНаАптекуСсылка);
	
	АдресХранения = МаршрутНаАптекуСсылка.АдресХранения;
	
	Если НЕ ОбщиеФункцииСервер.АдресХраненияПринадлежитФранчайзи(АдресХранения, МаршрутНаАптекуСсылка.Дата) Тогда
		  Возврат;
	КонецЕсли;
	
	МассивПакетов = МаршрутНаАптекуСсылка.Состав.ВыгрузитьКолонку("Заказ");
	
	Если МассивПакетов.Количество() = 0 Тогда
		Возврат;
	КонецЕсли;
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ РАЗЛИЧНЫЕ
	|	Заказ.ID_77 КАК ИдентификаторЗаказа
	|ИЗ
	|	Документ.Заказ КАК Заказ
	|ГДЕ
	|	Заказ.Ссылка В(&МассивПакетов)";
	
	Запрос.УстановитьПараметр("МассивПакетов", МассивПакетов);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	ВыборкаЗаказов = РезультатЗапроса.Выбрать();
	
	СтрокаУсловие = "";
	Пока ВыборкаЗаказов.Следующий() Цикл
		Если ЗначениеЗаполнено(ВыборкаЗаказов.ИдентификаторЗаказа) тогда
			СтрокаУсловие = СтрокаУсловие + "'"+ ВыборкаЗаказов.ИдентификаторЗаказа +"',";
		КонецЕсли;
	КонецЦикла;
	Если ЗначениеЗаполнено(СтрокаУсловие) тогда
		СтрокаУсловие = Лев(СтрокаУсловие,СтрДлина(СтрокаУсловие)-1);
	КонецЕсли;
	
	//	МассивКоробок = МаршрутНаАптекуСсылка.КоробкиСборки.ВыгрузитьКолонку("Коробка");
	//МассивПакетов = МаршрутНаАптекуСсылка.Состав.ВыгрузитьКолонку("Заказ");
	//
	//Если МассивКоробок.Количество() = 0 И МассивПакетов.Количество() = 0 Тогда
	//	Возврат;
	//КонецЕсли;
	//
	//Запрос = Новый Запрос;
	//Запрос.Текст = 
	//"ВЫБРАТЬ
	//|	СборкаТовары.Документ.ID_77 КАК ИдентификаторЗаказа
	//|ПОМЕСТИТЬ ВТ_СписокЗаказов
	//|ИЗ
	//|	Документ.Сборка.Товары КАК СборкаТовары
	//|ГДЕ
	//|	СборкаТовары.Ссылка В(&МассивКоробок)
	//|	И СборкаТовары.Документ ССЫЛКА Документ.Заказ
	//|
	//|ОБЪЕДИНИТЬ ВСЕ
	//|
	//|ВЫБРАТЬ
	//|	Заказ.ID_77
	//|ИЗ
	//|	Документ.Заказ КАК Заказ
	//|ГДЕ
	//|	Заказ.Ссылка В(&МассивПакетов)
	//|;
	//|
	//|////////////////////////////////////////////////////////////////////////////////
	//|ВЫБРАТЬ РАЗЛИЧНЫЕ
	//|	ВТ_СписокЗаказов.ИдентификаторЗаказа
	//|ИЗ
	//|	ВТ_СписокЗаказов КАК ВТ_СписокЗаказов";
	//
	//Запрос.УстановитьПараметр("МассивКоробок", МассивКоробок);
	//Запрос.УстановитьПараметр("МассивПакетов", МассивПакетов);
	//
	//РезультатЗапроса = Запрос.Выполнить();
	//
	//ВыборкаЗаказов = РезультатЗапроса.Выбрать();
	//
	//СтрокаУсловие = "";
	//Пока ВыборкаЗаказов.Следующий() Цикл
	//	Если ЗначениеЗаполнено(ВыборкаЗаказов.ИдентификаторЗаказа) тогда
	//		СтрокаУсловие = СтрокаУсловие + "'"+ ВыборкаЗаказов.ИдентификаторЗаказа +"',";
	//	КонецЕсли;
	//КонецЦикла;
	//Если ЗначениеЗаполнено(СтрокаУсловие) тогда
	//	СтрокаУсловие = Лев(СтрокаУсловие,СтрДлина(СтрокаУсловие)-1);
	//КонецЕсли;

	
	// Поиск и создание счетов фактур по найденным заказам
	
	ТекстЗапроса = 	
	"SELECT part.iddoc sf 
	|FROM Nagat..DH4287 part (nolock)
	|Inner Join Nagat.._1SJOURN Jr (nolock) ON Jr.Iddoc = part.iddoc
	|WHERE Right(part.SP4272,9)in("+СтрокаУсловие+") and Jr.ISMARK = 0";
	ТаблицаСчетовФактур = РаботаСSQL.ВыполнитьЗапросSQL(ТекстЗапроса,,Справочники.НастройкиПодключения.БазаCourierDS,Истина);
	
	МассивСчетовФактур = ТаблицаСчетовФактур.ВыгрузитьКолонку("sf");
	
	ОписаниеОбъекта77 = ОбменАлгоритмы77.ПолучитьОписаниеТаблицыВБазе77("Документ","СчетФактураВыданный");
	ТаблицаСчетовФактур = ОбменАлгоритмы77.ВыполнитьСверкуПоМетаданному(ОписаниеОбъекта77,100,,,МассивСчетовФактур,,Истина); 
	
	
	//Заполним в Счет фактуре для строк табличной части реквизит КлючСвязи
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	СчетФактураВыданный.Ссылка КАК СФ
	|ИЗ
	|	Документ.СчетФактураВыданный КАК СчетФактураВыданный
	|ГДЕ
	|	СчетФактураВыданный.ID_77 В (&ID_77)";
	
	Запрос.УстановитьПараметр("ID_77", МассивСчетовФактур);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	ТаблицаСФСсылки = РезультатЗапроса.Выгрузить();
	МассивСсылокДокументовСФ = ТаблицаСФСсылки.ВыгрузитьКолонку("СФ");
	Если НЕ МассивСсылокДокументовСФ.Количество() = 0 Тогда
		УстановитьИндентификаторСтрокиТЧ(МассивСсылокДокументовСФ, "Товар", "КлючСвязиПартия");
	КонецЕсли;
	
	
	//Формирование приходной накладной 
	
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	Заказ.Ссылка КАК СсылкаЗаказ,
	|	Заказ.Клиент,
	|	СчетФактураВыданный.Ссылка КАК СсылкаСФ,
	|	СчетФактураВыданный.Дата КАК ДатаСФ,
	|	СчетФактураВыданный.Номер КАК НомерСФ,
	|	Заказ.Дата КАК ДатаЗаказа,
	|	СчетФактураВыданный.Контрагент,
	|	ЕСТЬNULL(ТочкиСамовывоза.АдресХранения.ОсновнойСклад, ЗНАЧЕНИЕ(Справочник.МестаХранения.пустаяссылка)) КАК Отдел
	|ПОМЕСТИТЬ ВТ_СФЗаказ
	|ИЗ
	|	Документ.СчетФактураВыданный КАК СчетФактураВыданный
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Документ.Заказ КАК Заказ
	|			ЛЕВОЕ СОЕДИНЕНИЕ Справочник.ТочкиСамовывоза КАК ТочкиСамовывоза
	|			ПО Заказ.ТочкаСамовывоза = ТочкиСамовывоза.Ссылка
	|		ПО СчетФактураВыданный.ДокументОснование = Заказ.Ссылка
	|ГДЕ
	|	СчетФактураВыданный.ID_77 В(&ID_77)
	|	И СчетФактураВыданный.Проведен
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	СчетФактураВыданныйТовар.Товар,
	|	СчетФактураВыданныйТовар.Партия,
	|	СчетФактураВыданныйТовар.Количество,
	|	СчетФактураВыданныйТовар.Цена,
	|	СчетФактураВыданныйТовар.СтавкаНДС,
	|	СчетФактураВыданныйТовар.Сумма,
	|	СчетФактураВыданныйТовар.СуммаНДС,
	|	СчетФактураВыданныйТовар.Всего,
	|	СчетФактураВыданныйТовар.КлючСвязиПартия,
	|	ВТ_СФЗаказ.СсылкаЗаказ,
	|	ВТ_СФЗаказ.Клиент,
	|	ВТ_СФЗаказ.Отдел,
	|	ВТ_СФЗаказ.СсылкаСФ,
	|	ВТ_СФЗаказ.ДатаСФ,
	|	ВТ_СФЗаказ.НомерСФ,
	|	ВТ_СФЗаказ.ДатаЗаказа,
	|	ВТ_СФЗаказ.Контрагент
	|ПОМЕСТИТЬ ВТ_ТЧСФ
	|ИЗ
	|	ВТ_СФЗаказ КАК ВТ_СФЗаказ
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Документ.СчетФактураВыданный.Товар КАК СчетФактураВыданныйТовар
	|		ПО ВТ_СФЗаказ.СсылкаСФ = СчетФактураВыданныйТовар.Ссылка
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ЕСТЬNULL(Партии.Серия, """") КАК Серия,
	|	ЕСТЬNULL(Партии.ГоденДо, ДАТАВРЕМЯ(1, 1, 1)) КАК ГоденДо,
	|	ЕСТЬNULL(Партии.Производитель, ЗНАЧЕНИЕ(Справочник.Производители.ПустаяСсылка)) КАК Производитель,
	|	ЕСТЬNULL(Партии.Сертификат, """") КАК Сертификат,
	|	ЕСТЬNULL(Партии.СертификатДо, ДАТАВРЕМЯ(1, 1, 1)) КАК СертификатДо,
	|	ЕСТЬNULL(Партии.Выдан, """") КАК Выдан,
	|	ЕСТЬNULL(Партии.ЦенаПроизводителя, 0) КАК ЦенаПроизводителя,
	|	ЕСТЬNULL(Партии.НомерГТД, ЗНАЧЕНИЕ(Справочник.НомераГТД.ПустаяСсылка)) КАК НомерГТД,
	|	ЕСТЬNULL(Приходная.Ссылка, ЗНАЧЕНИЕ(Документ.Приходная.ПустаяСсылка)) КАК ПриходнаяНакладная,
	|	ВТ_ТЧСФ.Товар КАК Товар,
	|	ВТ_ТЧСФ.Количество КАК Количество,
	|	ВТ_ТЧСФ.Цена КАК Цена,
	|	ВТ_ТЧСФ.СтавкаНДС КАК СтавкаНДС,
	|	ВТ_ТЧСФ.Сумма КАК Сумма,
	|	ВТ_ТЧСФ.СуммаНДС КАК СуммаНДС,
	|	ВТ_ТЧСФ.Всего КАК Всего,
	|	ВТ_ТЧСФ.КлючСвязиПартия КАК КлючСвязиПартия,
	|	ВТ_ТЧСФ.СсылкаЗаказ КАК СсылкаЗаказ,
	|	ВТ_ТЧСФ.Отдел КАК Отдел,
	|	ВТ_ТЧСФ.СсылкаСФ КАК СчетФактура,
	|	ВТ_ТЧСФ.ДатаСФ КАК ДатаОснования,
	|	ВТ_ТЧСФ.НомерСФ КАК НомерОснования,
	|	ВТ_ТЧСФ.ДатаСФ КАК ДатаОплаты,
	|	ВТ_ТЧСФ.НомерСФ КАК НомерСЧФ,
	|	ВТ_ТЧСФ.ДатаЗаказа КАК ДатаЗаказа,
	|	ВТ_ТЧСФ.ДатаСФ КАК Дата,
	|	ВЫБОР
	|		КОГДА ВТ_ТЧСФ.СтавкаНДС = ЗНАЧЕНИЕ(Справочник.СтавкиНДС.НДС10)
	|			ТОГДА ВТ_ТЧСФ.СуммаНДС
	|		ИНАЧЕ 0
	|	КОНЕЦ КАК СуммаНДС10,
	|	ВЫБОР
	|		КОГДА ВТ_ТЧСФ.СтавкаНДС = ЗНАЧЕНИЕ(Справочник.СтавкиНДС.НДС18)
	|			ТОГДА ВТ_ТЧСФ.СуммаНДС
	|		ИНАЧЕ 0
	|	КОНЕЦ КАК СуммаНДС20,
	|	ВЫБОР
	|		КОГДА ВТ_ТЧСФ.СтавкаНДС = ЗНАЧЕНИЕ(Справочник.СтавкиНДС.НДС10)
	|			ТОГДА ВТ_ТЧСФ.Сумма
	|		ИНАЧЕ 0
	|	КОНЕЦ КАК Сумма10,
	|	ВЫБОР
	|		КОГДА ВТ_ТЧСФ.СтавкаНДС = ЗНАЧЕНИЕ(Справочник.СтавкиНДС.НДС18)
	|			ТОГДА ВТ_ТЧСФ.Сумма
	|		ИНАЧЕ 0
	|	КОНЕЦ КАК Сумма20,
	|	ВЫБОР
	|		КОГДА ВТ_ТЧСФ.СтавкаНДС = ЗНАЧЕНИЕ(Справочник.СтавкиНДС.НДС0)
	|			ТОГДА ВТ_ТЧСФ.Сумма
	|		ИНАЧЕ 0
	|	КОНЕЦ КАК Сумма0,
	|	ВТ_ТЧСФ.Контрагент КАК Клиент,
	|	ВТ_ТЧСФ.СсылкаЗаказ КАК Заказ,
	|	ЕСТЬNULL(Приходная.ТипПрихода, ЗНАЧЕНИЕ(Перечисление.ТипПрихода.СамовывозПакеты)) КАК ТипПрихода
	|ИЗ
	|	ВТ_ТЧСФ КАК ВТ_ТЧСФ
	|		ЛЕВОЕ СОЕДИНЕНИЕ Документ.Приходная КАК Приходная
	|		ПО ВТ_ТЧСФ.ДатаСФ = Приходная.ДатаОснования
	|			И ВТ_ТЧСФ.НомерСФ = Приходная.НомерОснования
	|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.Партии КАК Партии
	|		ПО ВТ_ТЧСФ.Партия = Партии.Ссылка
	|ИТОГИ
	|	КОЛИЧЕСТВО(РАЗЛИЧНЫЕ Серия),
	|	КОЛИЧЕСТВО(РАЗЛИЧНЫЕ ГоденДо),
	|	КОЛИЧЕСТВО(РАЗЛИЧНЫЕ Производитель),
	|	КОЛИЧЕСТВО(РАЗЛИЧНЫЕ Сертификат),
	|	КОЛИЧЕСТВО(РАЗЛИЧНЫЕ СертификатДо),
	|	КОЛИЧЕСТВО(РАЗЛИЧНЫЕ Выдан),
	|	СУММА(ЦенаПроизводителя),
	|	КОЛИЧЕСТВО(РАЗЛИЧНЫЕ НомерГТД),
	|	МАКСИМУМ(ПриходнаяНакладная),
	|	КОЛИЧЕСТВО(РАЗЛИЧНЫЕ Товар),
	|	СУММА(Количество),
	|	СУММА(Цена),
	|	КОЛИЧЕСТВО(РАЗЛИЧНЫЕ СтавкаНДС),
	|	СУММА(Сумма),
	|	СУММА(СуммаНДС),
	|	СУММА(Всего),
	|	КОЛИЧЕСТВО(РАЗЛИЧНЫЕ КлючСвязиПартия),
	|	МАКСИМУМ(СсылкаЗаказ),
	|	МАКСИМУМ(Отдел),
	|	МАКСИМУМ(ДатаОснования),
	|	МАКСИМУМ(НомерОснования),
	|	МАКСИМУМ(ДатаОплаты),
	|	МАКСИМУМ(НомерСЧФ),
	|	МАКСИМУМ(ДатаЗаказа),
	|	МАКСИМУМ(Дата),
	|	СУММА(СуммаНДС10),
	|	СУММА(СуммаНДС20),
	|	СУММА(Сумма10),
	|	СУММА(Сумма20),
	|	СУММА(Сумма0),
	|	МАКСИМУМ(Клиент),
	|	МАКСИМУМ(Заказ),
	|	МАКСИМУМ(ТипПрихода)
	|ПО
	|	СчетФактура";
	
	Запрос.УстановитьПараметр("ID_77", МассивСчетовФактур);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	ВыборкаГруппировка = РезультатЗапроса.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
	
	Пока ВыборкаГруппировка.Следующий() Цикл
		
		Если ЗначениеЗаполнено(ВыборкаГруппировка.ПриходнаяНакладная) Тогда
			ДокументПриходнаяНакладнаяСсылка = ВыборкаГруппировка.ПриходнаяНакладная;
			ДокументПриходнаяНакладная = ДокументПриходнаяНакладнаяСсылка.ПолучитьОбъект();
			ДокументПриходнаяНакладная.Товары.Очистить();
		Иначе
			ДокументПриходнаяНакладная = Документы.Приходная.СоздатьДокумент();
		КонецЕсли;
		
		ЗаполнитьЗначенияСвойств(ДокументПриходнаяНакладная,ВыборкаГруппировка);
		
		ДокументПриходнаяНакладная.ОрдернаяСхема = 1;
		Если ЗначениеЗаполнено(ДокументПриходнаяНакладная.ДатаОплаты) тогда
			ДокументПриходнаяНакладная.РазрешенаПриемка = Истина;
		КонецЕсли;
		Если ЗначениеЗаполнено(ВыборкаГруппировка.Клиент) Тогда
			Поставщик = ВыборкаГруппировка.Клиент;	
			ДокументПриходнаяНакладная.Упрощенка = Поставщик.Упрощенка;	
		КонецЕсли;
		
		Если ЗначениеЗаполнено(ДокументПриходнаяНакладная.Клиент) тогда
			ДокументПриходнаяНакладная.ДатаОплаты = ВыборкаГруппировка.ДатаОснования + ДокументПриходнаяНакладная.Клиент.Отсрочка*60*60*24;
		КонецЕсли;
		
		ВыборкаДетальныеЗаписи =  ВыборкаГруппировка.Выбрать(); 
		Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
			
			НоваяСтрока = ДокументПриходнаяНакладная.Товары.Добавить();
			ЗаполнитьЗначенияСвойств(НоваяСтрока,ВыборкаДетальныеЗаписи);
			
		КонецЦикла;
		
		ДокументПриходнаяНакладная.Записать(РежимЗаписиДокумента.Проведение);
		
		ЗаписатьПартииДокументов(ВыборкаГруппировка.СчетФактура,ВыборкаГруппировка.СсылкаЗаказ, ДокументПриходнаяНакладная.Ссылка);
		
	КонецЦикла;
	
КонецПроцедуры

Процедура УстановитьИндентификаторСтрокиТЧ(МассивДокументов, ИмяТЧ, ИмяКлюча)
	
	Для Каждого НоваяСтрМассива Из МассивДокументов Цикл
		Если  Документы.ТипВсеСсылки().СодержитТип(ТипЗнч(НоваяСтрМассива)) 
			И ЗначениеЗаполнено(НоваяСтрМассива)   Тогда
			ДокументОбъект = НоваяСтрМассива.ПолучитьОбъект();
			ДокументТЧ  = ДокументОбъект[ИмяТЧ];
			Если НЕ ДокументОбъект.Метаданные().ТабличныеЧасти.Найти(ИмяТЧ) = Неопределено Тогда
				Для Каждого НоваяСтрока Из ДокументТЧ Цикл
					НоваяСтрока[ИмяКлюча] = Новый УникальныйИдентификатор;
				КонецЦикла;
			КонецЕсли;
			ДокументОбъект.Записать(РежимЗаписиДокумента.Запись);
		КонецЕсли;
	КонецЦикла;
	
КонецПроцедуры

Процедура ЗаписатьПартииДокументов(СчетФактура, Заказ, ПриходнаяНакладная)
	
	Если ТипЗнч(Заказ) = Тип("ДокументСсылка.Заказ") Тогда
		ЗаказОбъект = Заказ.ПолучитьОбъект();
		ТЧЗаказ = ЗаказОбъект.Товар;
	Иначе
		Возврат;
	КонецЕсли;
	
	Если ТипЗнч(СчетФактура) = Тип("ДокументСсылка.СчетФактураВыданный") Тогда
		ТЧСф = СчетФактура.Товар;
	Иначе
		Возврат;
	КонецЕсли;
	
	Если ТипЗнч(ПриходнаяНакладная) = Тип("ДокументСсылка.Приходная") Тогда
		ТЧПриход = ПриходнаяНакладная.Товары;
	Иначе
		Возврат;
	КонецЕсли;
	
	ЕстьИзмененные = Ложь;
	Для Каждого НоваяСтрока Из ТЧПриход Цикл 
		СтрокаСФ = ТЧСф.Найти(НоваяСтрока.КлючСвязиПартия,"КлючСвязиПартия"); 
		Если НЕ СтрокаСФ = Неопределено Тогда
			СтруктураОтбора = Новый Структура("Товар,Партия",СтрокаСФ.Товар, СтрокаСФ.Партия);
			НайденныеСтрокиЗаказа = ТЧЗаказ.НайтиСтроки(СтруктураОтбора);
			Если НайденныеСтрокиЗаказа.Количество() > 0 Тогда
				НайденныеСтрокиЗаказа[0].Партия = НоваяСтрока.Партия;
				НайденныеСтрокиЗаказа[0].КлючСвязиПартия = НоваяСтрока.КлючСвязиПартия;
				НайденныеСтрокиЗаказа[0].Склад = ПриходнаяНакладная.Отдел;
				ЕстьИзмененные = Истина;
			КонецЕсли;
		КонецЕсли; 
	КонецЦикла;
	
	Если ЕстьИзмененные Тогда
		ЗаказОбъект.Записать(РежимЗаписиДокумента.Запись);
	КонецЕсли;
	
КонецПроцедуры
