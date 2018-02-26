﻿
&НаСервере
Процедура ЗагрузитьОстаткиНаСервере()
	Подключение = РаботаСSQL.ПодключениеКСерверуSQLПоНастройке(Справочники.НастройкиПодключения.БазаCourierDS);
	
	УзелОбновления = ПланыОбмена.ПланОбменаОбновлениями.НайтиПоРеквизиту("АдресХранения",Объект.АдресХранения);
	Если не ЗначениеЗаполнено(УзелОбновления) тогда
		Сообщение = Новый СообщениеПользователю;
		Сообщение.Текст = "Узел обмена для текущего адреса хранения не найден!!!";
		Сообщение.Сообщить();
		Возврат;
	КонецЕсли;
	Узел = ПланыОбмена.ПланОбменаДанными.НайтиПоРеквизиту("ОсновнойУзел",УзелОбновления);
	Если не ЗначениеЗаполнено(Узел) тогда
		Сообщение = Новый СообщениеПользователю;
		Сообщение.Текст = "Узел обмена для текущего адреса хранения не найден!!!";
		Сообщение.Сообщить();
		Возврат;
	КонецЕсли;
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	МестаХранения.ID_77
	|ИЗ
	|	Справочник.МестаХранения КАК МестаХранения
	|ГДЕ
	|	МестаХранения.АдресХранения = &АдресХранения";
	Запрос.УстановитьПараметр("АдресХранения",Объект.АдресХранения);
	Выборка = Запрос.Выполнить().Выбрать();
	Условие = "";
	Пока Выборка.Следующий() цикл
		Условие = Условие + "'"+Выборка.ID_77+"',";
	КонецЦикла;
	Условие = Лев(Условие,СтрДлина(Условие)-1);
	
	ТекстЗапроса = 
	" set nocount on
	|DECLARE @period DATETIME
	|SELECT @period=MAX(period) FROM [Nagat].[dbo].[RG265]
	|SELECT 
	|     SP260 as tovar
	|     ,SP261 as otdel
	|     ,SP419 as partiya
	|     ,SUM(SP262) as ost
	|FROM [Nagat].[dbo].[RG265] (nolock)
	|WHERE SP261 IN ("+Условие+") and Period = @period
	|GROUP BY SP260
	|      ,SP261
	|      ,SP419
	|HAVING SUM(SP262) > 0";
	ТаблицаОстатков = РаботаСSQL.ВыполнитьЗапросSQL(ТекстЗапроса,Подключение,,Истина);
	
	МассивПартий = ТаблицаОстатков.ВыгрузитьКолонку("Partiya");
	МассивIDКЗагрузке = Новый Массив;
	Ит = 0;
	МассивID = Новый Массив;
	Для каждого строка из МассивПартий цикл
		Если Ит = 1000 тогда
			МассивIDКЗагрузке.Добавить(МассивID);
			Ит = 0;
			МассивID = Новый Массив;
		КонецЕсли;		
		МассивID.Добавить(строка);
		Ит = Ит + 1;
	КонецЦикла;
	
	МассивIDКЗагрузке.Добавить(МассивID);
	
	МассивСвязанныхЭлементов = Новый Массив;
	МассивСвязанныхЭлементов.Добавить(ОбменАлгоритмы77.ПолучитьОписаниеТаблицыВБазе77("Справочник","ЦеныПартии"));
	
	Для каждого массив из МассивIDКЗагрузке цикл
		ТаблицаПартий = ОбменАлгоритмы77.ВыполнитьСверкуПоМетаданному(ОбменАлгоритмы77.ПолучитьОписаниеТаблицыВБазе77("Справочник","Партии"),1000,МассивСвязанныхЭлементов,,Массив,Истина);
		
		МассивПартий = ТаблицаПартий.ВыгрузитьКолонку("Ссылка");
		
		Запрос = Новый Запрос;
		Запрос.Текст = 
		"ВЫБРАТЬ
		|	ЦеныПартии.Ссылка КАК ЦенаПартии,
		|	ЦеныПартии.Владелец КАК Партия
		|ИЗ
		|	Справочник.ЦеныПартии КАК ЦеныПартии
		|ГДЕ
		|	ЦеныПартии.Владелец В (&МассивПартий)";
		Запрос.УстановитьПараметр("МассивПартий",МассивПартий);		
		Выборка = Запрос.Выполнить().Выбрать();
		Пока Выборка.Следующий() цикл
			ПланыОбмена.ЗарегистрироватьИзменения(Узел,Выборка.Партия);	
			ПланыОбмена.ЗарегистрироватьИзменения(Узел,Выборка.ЦенаПартии);	
		КонецЦикла;
	КонецЦикла;
	
	НовыйОбъект = Документы.ВводНачальныхОстатков.СоздатьДокумент();
	НовыйОбъект.Дата = НачалоДня(ТекущаяДата());
	НовыйОбъект.АдресХранения = Объект.АдресХранения;
	
	Ит = 0;
	МассивОбрабатываемыхСтрок = Новый Массив;
	Для каждого строка из ТаблицаОстатков цикл
		МассивОбрабатываемыхСтрок.Добавить(Строка);
		Если Ит = 1000 тогда
			ТаблицаПорции = ТаблицаОстатков.Скопировать(МассивОбрабатываемыхСтрок);
			СоответствиеТовар = ПолучитьСоответствие("Справочник","Номенклатура",ТаблицаПорции.ВыгрузитьКолонку("tovar"));
			СоответствиеОтдел  = ПолучитьСоответствие("Справочник","МестаХранения",ТаблицаПорции.ВыгрузитьКолонку("otdel"));
			СоответствиеПартий  = ПолучитьСоответствие("Справочник","Партии",ТаблицаПорции.ВыгрузитьКолонку("partiya"));
			Для каждого строкаПорция из ТаблицаПорции цикл
				СтрокаОстаток = НовыйОбъект.Остатки.Добавить();
				СтрокаОстаток.Отдел = СоответствиеОтдел.Получить(строкаПорция.otdel);
				СтрокаОстаток.Товар = СоответствиеТовар.Получить(строкаПорция.tovar);
				СтрокаОстаток.Партия = СоответствиеПартий.Получить(строкаПорция.partiya);
				СтрокаОстаток.Остаток = строкаПорция.ost;
			КонецЦикла;
			МассивОбрабатываемыхСтрок.Очистить();
		КонецЕсли;
		Ит = Ит + 1;
	КонецЦикла;
	
	Если МассивОбрабатываемыхСтрок.Количество() > 0 тогда
		ТаблицаПорции = ТаблицаОстатков.Скопировать(МассивОбрабатываемыхСтрок);
		СоответствиеТовар = ПолучитьСоответствие("Справочник","Номенклатура",ТаблицаПорции.ВыгрузитьКолонку("tovar"));
		СоответствиеОтдел  = ПолучитьСоответствие("Справочник","МестаХранения",ТаблицаПорции.ВыгрузитьКолонку("otdel"));
		СоответствиеПартий  = ПолучитьСоответствие("Справочник","Партии",ТаблицаПорции.ВыгрузитьКолонку("partiya"));
		Для каждого строкаПорция из ТаблицаПорции цикл
			СтрокаОстаток = НовыйОбъект.Остатки.Добавить();
			СтрокаОстаток.Отдел = СоответствиеОтдел.Получить(строкаПорция.otdel);
			СтрокаОстаток.Товар = СоответствиеТовар.Получить(строкаПорция.tovar);
			СтрокаОстаток.Партия = СоответствиеПартий.Получить(строкаПорция.partiya);
			СтрокаОстаток.Остаток = строкаПорция.ost;
		КонецЦикла;
	КонецЕсли;
	
	ТекстЗапросаЗаказыОстатки = 
	"set nocount on    
	|declare @id_skl char(9), @period datetime 
	|select @period=max(period) from Nagat..RG2845 (Nolock)
	|select @id_skl=id from Nagat..sc69 skl (Nolock) where skl.code="+Объект.АдресХранения.ОсновнойСклад.Код+"
	|
	|select j.iddoc, j.docno, cast(left(j.date_time_iddoc,8) as datetime) as d_doc, z.SP897 as d_dost, 
	| z.SP3233 as n_zak_site, z.SP3232 as site, z.SP890 id_kl, 
	| cast(z.SP921 as money) as sum_zak,z.SP3215 id_tc,
	| z.SP2968, z.SP891, z.SP893, z.SP3227, z.SP904 as tel, z.SP903 as kl,
	| z.SP3289                AS qnt_ice,
	| z.SP3288                AS qnt_reg,
	| z.SP3861                AS z_weight
	|into #final
	|from Nagat..RG2845 rg (Nolock) 
	|inner join Nagat.._1sjourn j (Nolock) on j.iddocdef=888 and j.iddoc=right(SP2846,9)
	|inner join Nagat..dh888 z (Nolock) on j.iddoc=z.iddoc
	|inner join Nagat..SC3908 ts (Nolock) on z.SP3929=ts.id
	|inner join Nagat..SC4123 ah (Nolock) on ts.SP4145=ah.id
	|where rg.period=@period and rg.SP2849=1 and rg.SP3507='   26Z   ' and ah.SP4142=@id_skl
	|and z.SP2968=0 and z.SP891=0 and z.SP893=1 and z.SP3227='   2IW   '
	|
	|select f.iddoc
	|into #v
	|from #final f
	| inner join Nagat.._1scrdoc scr (Nolock) on scr.parentval='O1  OO'+f.iddoc+'        '
	| inner join Nagat.._1sjourn j (Nolock) ON scr.childid=j.iddoc
	|where scr.mdid=0 and j.iddocdef=1252 and j.closed>0
	|
	|SELECT  
	|	DISTINCT t1.iddoc
	|INTO #IsSMS
	|FROM t_sms AS t1 WITH (NOLOCK)
	|INNER JOIN #final t2 ON t1.iddoc = t2.iddoc
	|WHERE isnull(t1.type,0) = 1
	|
	|select f.iddoc, isnull(zsj.zsj,'') as ZSJ
	|from #final f
	| inner join t_tc tc (Nolock) on f.id_tc=tc.id_tc
	| left join #v v on f.iddoc=v.iddoc
	| LEFT JOIN #isSMS s ON  f.iddoc = s.iddoc
	| LEFT JOIN t_z_zsj zsj(Nolock) ON zsj.docno = f.docno AND zsj.d_doc = f.d_doc
	|where v.iddoc is null  --and isnull(zsj.zsj,'') <> ''
	|order by f.d_dost desc
	|
	|drop table #final, #v, #isSMS";
	
	ОстаткиЗаказов = РаботаСSQL.ВыполнитьЗапросSQL(ТекстЗапросаЗаказыОстатки,Подключение,,Истина);
	МассивIDЗаказов = ОстаткиЗаказов.ВыгрузитьКолонку("iddoc");
	МассивIDЗаказовНаклейки = ОстаткиЗаказов.ВыгрузитьКолонку("iddoc");
	
	ТекстЗапросаЗаказыОстаткиВозврат =  
	"set nocount on    
	|
	|declare @id_skl char(9)
	|
	|select @id_skl=id
	|from Nagat..sc69 skl (Nolock) 
	|where skl.code="+Объект.АдресХранения.ОсновнойСклад.Код+"
	|declare @d datetime select @d=dateadd(dd,-3,getdate())
	|
	|SELECT
	| j.iddoc,
	| CONVERT(datetime,z.SP1600,120) as DataProb,
	| Ltrim(rtrim(j.docno)) as NomerZakaza, cast(left(j.date_time_iddoc,8) as datetime) DataZakaza
	|INTO #ZakNom
	|from Nagat.._1sjourn j (Nolock)
	|inner join Nagat..dh888 z (Nolock) on j.iddoc=z.iddoc and j.iddocdef=888 and z.SP889 in (@id_skl) 
	|left join Nagat..sc65 kl (Nolock) on z.SP890=kl.id 
	|inner join t_tc tc (Nolock) on z.SP3215=tc.id_tc 
	|where CONVERT(datetime,z.SP1600,120) > @d and 
	| j.closed!=0 and z.SP891=1 and z.SP3227='   2IW   ' and z.SP890 not in ('  8Y9ING ','  TO6E   ') 
	| 
	|SELECT zn.iddoc,
	| zn.DataProb as ДатаПродажи, zn.DataZakaza ,chh.kkm as ККМ,chh.check_num AS НомерЧека,chh.check_kpk AS КПК, chh.SessionNumber as НомерСмены, ucs.card_id as НомерКарты, ucs.authcode, ucs.rrn  
	|FROM #ZakNom zn
	|INNER JOIN dbo.t_check chh ON zn.NomerZakaza = chh.docno AND zn.DataZakaza = chh.d_doc
	|LEFT JOIN dbo.t_check_ucs ucs ON  chh.check_num = ucs.НомерЧека AND chh.check_kpk = ucs.НомерКПК
	| 
	| 
	|DROP TABLE #ZakNom";

	ОстаткиЗаказовВозврат = РаботаСSQL.ВыполнитьЗапросSQL(ТекстЗапросаЗаказыОстаткиВозврат,Подключение,,Истина);
	
	Для каждого строка из ОстаткиЗаказовВозврат цикл
		МассивIDЗаказов.Добавить(Строка.iddoc);	
	КонецЦикла;
	
	ТаблицаЗагруженыхЗаказов = ОбменАлгоритмы77.ВыполнитьСверкуПоМетаданному(ОбменАлгоритмы77.ПолучитьОписаниеТаблицыВБазе77("Документ","Заказ"),,,,МассивIDЗаказов,Истина);
	
	НастройкаПодключения = справочники.НастройкиПодключенийКВебСервисам.Склад;
	Прокси = ОбщийМодульВебСервисы.ПодключитьсяКВебСервису(НастройкаПодключения);
	ТаблицаМестЗаказов = Прокси.GetOrderPlaces(ЗначениеВСтрокуВнутр(МассивIDЗаказовНаклейки));
	
	ТаблицаМестЗаказов = ЗначениеИзСтрокиВнутр(ТаблицаМестЗаказов);
	
	МассивУИДНаклеек = ТаблицаМестЗаказов.ВыгрузитьКолонку("УИД");
	МассивШКНаклеек = ТаблицаМестЗаказов.ВыгрузитьКолонку("Наименование");
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	НаклейкиМестЗаказа.Ссылка,
	|	НаклейкиМестЗаказа.УИД,
	|	НаклейкиМестЗаказа.Наименование
	|ИЗ
	|	Справочник.НаклейкиМестЗаказа КАК НаклейкиМестЗаказа
	|ГДЕ
	|	(НаклейкиМестЗаказа.УИД В (&МассивУИД)
	|				И НаклейкиМестЗаказа.УИД <> """"
	|			ИЛИ НаклейкиМестЗаказа.Наименование В (&МассивШК)
	|				И НаклейкиМестЗаказа.УИД = """")
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	МестаХранения.Ссылка,
	|	МестаХранения.ID_77
	|ИЗ
	|	Справочник.МестаХранения КАК МестаХранения";
	Запрос.УстановитьПараметр("МассивУИД",МассивУИДНаклеек);
	Запрос.УстановитьПараметр("МассивШК",МассивШКНаклеек);
	МассивРезультатов = Запрос.ВыполнитьПакет();
	
	ТаблицаМестЗаказовЗагр = МассивРезультатов[0].Выгрузить();
	ТаблицаСкладов = МассивРезультатов[1].Выгрузить();
	ТаблицаНаклеек = Новый ТаблицаЗначений;
	ТаблицаНаклеек.Колонки.Добавить("Заказ");
	ТаблицаНаклеек.Колонки.Добавить("Наклейка");
	
	Для каждого строка из ТаблицаМестЗаказов цикл
		СтрокаЗаказа = ТаблицаЗагруженыхЗаказов.Найти(Строка.ЗаказID_77,"ID_77");
		Если СтрокаЗаказа = Неопределено тогда
			Продолжить;
		КонецЕсли;
		Если ЗначениеЗаполнено(Строка.УИД) тогда
			СтрокаМестаЗаказа = ТаблицаМестЗаказовЗагр.Найти(Строка.УИД,"УИД");
		Иначе
			СтрокаМестаЗаказа = ТаблицаМестЗаказовЗагр.Найти(Строка.Наименование,"Наименование");
		КонецЕсли;
		Если СтрокаМестаЗаказа <> Неопределено тогда
			МестоЗаказа = СтрокаМестаЗаказа.Ссылка.ПолучитьОбъект();
		Иначе
			МестоЗаказа = Справочники.НаклейкиМестЗаказа.СоздатьЭлемент();
		КонецЕсли;
		МестоЗаказа.Наименование = Строка.Наименование;
		Если Лев(МестоЗаказа.Наименование,2) = "26" тогда
			МестоЗаказа.Код = Лев(Прав(МестоЗаказа.Наименование,7),6);
		КонецЕсли;
		МестоЗаказа.Холод = Строка.Холод;
		МестоЗаказа.Документ = СтрокаЗаказа.Ссылка;
		МестоЗаказа.НомерМеста = Строка.НомерМеста;
		МестоЗаказа.УИД = Строка.УИД;
		МестоЗаказа.Записать();
		ПланыОбмена.ЗарегистрироватьИзменения(Узел,МестоЗаказа);
		СтрокаЗаказНаклейка = ТаблицаНаклеек.Добавить();
		СтрокаЗаказНаклейка.Заказ = СтрокаЗаказа.Ссылка;
		СтрокаЗаказНаклейка.Наклейка = МестоЗаказа.Ссылка;
	КонецЦикла;   
	Склад = Объект.АдресХранения.ОсновнойСклад;	
	Для каждого Строка из ОстаткиЗаказов цикл
		Заказ = ТаблицаЗагруженыхЗаказов.Найти(Строка.iddoc,"ID_77");
		Если НЕ ЗначениеЗаполнено(Заказ) тогда
			Продолжить;
		КонецЕсли;
		Заказ = Заказ.Ссылка;
		СтрокиМест = ТаблицаНаклеек.НайтиСтроки(Новый Структура("Заказ",Заказ));
		Если СтрокиМест.Количество() > 0 тогда
			Для каждого СтрокаМеста из СтрокиМест цикл
				СтрокаЗаказа = НовыйОбъект.Заказы.Добавить();
				СтрокаЗаказа.Заказ = Заказ;
				СтрокаЗаказа.Склад = Склад;
				СтрокаЗаказа.МестоЗаказа = СтрокаМеста.Наклейка;
				СтрокаЗаказа.Количество = 1;
			КонецЦикла;
		Иначе
			Холод = Заказ.МестХолодных;
			Простых = Заказ.МестПростых;
			Для ит = 1 по Простых цикл		
				СтрокаЗаказа = НовыйОбъект.Заказы.Добавить();
				СтрокаЗаказа.Заказ = Заказ;
				СтрокаЗаказа.Склад = Склад;
				СтрокаЗаказа.МестоЗаказа = ПолучитьШК(Заказ,Склад,0,ит);
				СтрокаЗаказа.Количество = 1;	
				ПланыОбмена.ЗарегистрироватьИзменения(Узел,СтрокаЗаказа.МестоЗаказа);
			КонецЦикла;
			Для ит = 1 по Холод цикл		
				СтрокаЗаказа = НовыйОбъект.Заказы.Добавить();
				СтрокаЗаказа.Заказ = Заказ;
				СтрокаЗаказа.Склад = Склад;
				СтрокаЗаказа.МестоЗаказа = ПолучитьШК(Заказ,Склад,1,ит);
				СтрокаЗаказа.Количество = 1;	
				ПланыОбмена.ЗарегистрироватьИзменения(Узел,СтрокаЗаказа.МестоЗаказа);
			КонецЦикла;
		КонецЕсли;
	КонецЦикла;
	
	Для каждого Строка из ОстаткиЗаказовВозврат Цикл
		Заказ = ТаблицаЗагруженыхЗаказов.Найти(Строка.iddoc,"ID_77");
		Если НЕ ЗначениеЗаполнено(Заказ) тогда
			Продолжить;
		КонецЕсли;
		Заказ = Заказ.Ссылка;
		СтрокаЗаказа = НовыйОбъект.ЗаказыДляВозвратов.Добавить();
		ЗаполнитьЗначенияСвойств(СтрокаЗаказа,Строка);
		СтрокаЗаказа.ДатаПродажи = Строка.ДатаПродажи;
		СтрокаЗаказа.Заказ = Заказ;
		СтрокаЗаказа.ККМ = Справочники.ККМ.НайтиПоРеквизиту("ЗаводскойНомер",СокрЛП(Строка.ККМ));		
	КонецЦикла;
		
	НовыйОбъект.Записать(РежимЗаписиДокумента.Проведение);
	
	МассивЗаказовДляПартий = ТаблицаЗагруженыхЗаказов.ВыгрузитьКолонку("Ссылка");
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	ЗаказТовар.Партия
	|ИЗ
	|	Документ.Заказ.Товар КАК ЗаказТовар
	|ГДЕ
	|	ЗаказТовар.Ссылка В(&МассивЗаказов)
	|
	|СГРУППИРОВАТЬ ПО
	|	ЗаказТовар.Партия";
	Запрос.УстановитьПараметр("МассивЗаказов",МассивЗаказовДляПартий);
	Выборка = Запрос.Выполнить().Выбрать();
	Пока Выборка.Следующий() цикл
		ПланыОбмена.ЗарегистрироватьИзменения(Узел,Выборка.Партия);
	КонецЦикла;

	ЗагрузитьЗСЯ()
	
КонецПроцедуры

&НаСервере
Функция ПолучитьСоответствие(ТипМетаданного,ИмяМетаданного,Массив_id_77)
	
	Запрос=Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	Об.Ссылка,
	|   Об.ID_77 
	|ИЗ
	|	"+ТипМетаданного+"."+ИмяМетаданного+" КАК Об
	|ГДЕ
	|	Об.ID_77 в (&ID_77)";
	Запрос.УстановитьПараметр("ID_77",Массив_id_77);
	Выборка = Запрос.Выполнить().Выбрать();
	Соответствие = Новый Соответствие;
	Пока Выборка.Следующий() цикл
		Соответствие.Вставить(Выборка.ID_77,Выборка.Ссылка);
	КонецЦикла;
	Возврат Соответствие
	
КонецФункции

&НаСервере
Процедура ЗагрузитьЗСЯ()
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	МестаХранения.Ссылка,
	|	МестаХранения.ID_77
	|ИЗ
	|	Справочник.МестаХранения КАК МестаХранения
	|ГДЕ
	|	МестаХранения.АдресХранения = &АдресХранения";
	Запрос.УстановитьПараметр("АдресХранения",Объект.АдресХранения);
	ТаблицаСкладов = Запрос.Выполнить().Выгрузить();
	Условие = "";
	Для каждого строка из ТаблицаСкладов цикл
		Условие = Условие + "'"+Строка.ID_77+"',";
	КонецЦикла;
	Условие = Лев(Условие,СтрДлина(Условие)-1);
	
	ТекстSQLЗапроса = 
	"set nocount on
	|SELECT
	| c.PARENTEXT as nomID, Ltrim(Rtrim(zone.descr)) as z, c.sp4165 as s, c.SP4166 as j, c.SP4163 AS skl
	|from nagat..SC4161 c (NOLOCK)
	|inner JOIN nagat..SC2411 zone (NOLOCK) ON c.sp4164 = zone.id   
	|where 
	| c.SP4163 in ("+ Условие+")";
	
	ТаблицаЗСЯ = РаботаСSQL.ВыполнитьЗапросSQL(ТекстSQLЗапроса,,Справочники.НастройкиПодключения.БазаCourierDS,Истина);	
	
	Для каждого строка из ТаблицаЗСЯ цикл
		
		Склад = ТаблицаСкладов.Найти(Строка.skl,"ID_77").Ссылка;
		Запрос = Новый Запрос;
		Запрос.Текст = 
		"ВЫБРАТЬ
		|	Номенклатура.Ссылка
		|ИЗ
		|	Справочник.Номенклатура КАК Номенклатура
		|ГДЕ
		|	Номенклатура.ID_77 = &ID_77";
		Запрос.УстановитьПараметр("ID_77",строка.nomID);
		Выборка = Запрос.Выполнить().Выбрать();
		Пока Выборка.Следующий() цикл
			Номенклатура = Выборка.Ссылка;			
			Если ЗначениеЗаполнено(Номенклатура) тогда
				МенеджерЗаписи = РегистрыСведений.ЗСЯНоменклатуры.СоздатьМенеджерЗаписи();
				МенеджерЗаписи.Номенклатура = Номенклатура;
				МенеджерЗаписи.Склад = Склад;
				МенеджерЗаписи.Зона = строка.z;
				МенеджерЗаписи.Стеллаж = строка.s;
				МенеджерЗаписи.Ячейка = строка.j;
				МенеджерЗаписи.Записать();	
				//НомОбъект = Номенклатура.ПолучитьОбъект();
				//СтрокиЗСЯ = НомОбъект.ЗСЯ.НайтиСтроки(Новый Структура("Склад",Склад));
				//Для каждого строкаЗСЯ из СтрокиЗСЯ цикл
				//	НомОбъект.ЗСЯ.Удалить(строкаЗСЯ);
				//КонецЦикла;
				//НоваяСтрокаЗСЯ = НомОбъект.ЗСЯ.Добавить();
				//НоваяСтрокаЗСЯ.Зона = Строка.z;
				//НоваяСтрокаЗСЯ.Стеллаж = Строка.s;
				//НоваяСтрокаЗСЯ.Ячейка = Строка.j;
				//НоваяСтрокаЗСЯ.Склад = Склад;
				//НомОбъект.Записать();
			КонецЕсли;
		КонецЦикла;
	КонецЦикла;
	
КонецПроцедуры

&НаСервере
Функция ПолучитьШК(Док,Склад,Холод,Пакет)
	
	ШК = "1"+ВернутьКодСкладаДляШК(СокрЛП(Склад.Код))+Строка(Холод)+Строка(Пакет)+Добить(СокрЛП(Строка(Док.Номер)),7);
	ШК = ШК + КонтрольныйСимволEAN(ШК,13);
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	НаклейкиМестЗаказа.Ссылка
	|ИЗ
	|	Справочник.НаклейкиМестЗаказа КАК НаклейкиМестЗаказа
	|ГДЕ
	|	НаклейкиМестЗаказа.Наименование = &ШК
	|	И НаклейкиМестЗаказа.Документ = &Заказ
	|	И НЕ НаклейкиМестЗаказа.ПометкаУдаления";
	Запрос.УстановитьПараметр("ШК",ШК);
	Запрос.УстановитьПараметр("Заказ",Док.Ссылка);
	Результат = Запрос.Выполнить();
	Если Результат.Пустой() тогда
		МестоХранения = справочники.НаклейкиМестЗаказа.СоздатьЭлемент();
	Иначе
		Выборка = Результат.Выбрать();
		Пока Выборка.Следующий() цикл
			МестоХранения = Выборка.Ссылка.ПолучитьОбъект();
		КонецЦикла;
	КонецЕсли;
	
	МестоХранения.Наименование= ШК;
	МестоХранения.Документ = Док.Ссылка; 
	МестоХранения.Холод = Холод <> 0;
	МестоХранения.Уид = "самсоб";
	МестоХранения.Записать();
	
	Возврат МестоХранения.Ссылка;
	
КонецФункции	

&НаСервере
Функция ВернутьКодСкладаДляШК(КодСклада)
	
	Если СтрДлина(КодСклада) = 1 тогда
		Возврат "0"+КодСклада;
	КонецЕсли;
	
	Возврат КодСклада;
	
КонецФункции

&НаСервере
Функция Добить(Строка,Длина)
	
	Пока СтрДлина(Строка) < Длина цикл
		Строка = "0"+Строка;	
	КонецЦикла;
	
	Возврат Строка
	
КонецФункции

&НаСервере
Функция КонтрольныйСимволEAN(ШтрихКод, Тип) Экспорт
    
    Четн   = 0;
    Нечетн = 0;
    
    КоличествоИтераций = ?(Тип = 13, 6, 4);
    
    Для Индекс = 1 По КоличествоИтераций Цикл
        Если (Тип = 8) и (Индекс = КоличествоИтераций) Тогда
        Иначе
            Четн   = Четн   + Сред(ШтрихКод, 2 * Индекс, 1);
        КонецЕсли;
        Нечетн = Нечетн + Сред(ШтрихКод, 2 * Индекс - 1, 1);
    КонецЦикла;
    
    Если Тип = 13 Тогда
        Четн = Четн * 3;
    Иначе
        Нечетн = Нечетн * 3;
    КонецЕсли;
    
    КонтЦифра = 10 - (Четн + Нечетн) % 10;
    
    Возврат ?(КонтЦифра = 10, "0", Строка(КонтЦифра));
    
КонецФункции // КонтрольныйСимволEAN()


&НаКлиенте
Процедура ЗагрузитьОстатки(Команда)
	
	ЗагрузитьОстаткиНаСервере();
	
КонецПроцедуры

&НаКлиенте
Процедура ЗагрузитьЗСЯ1(Команда)
	
	ЗагрузитьЗСЯ();
	
КонецПроцедуры
