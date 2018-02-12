
&НаКлиенте
Процедура СогласованиеТаблицаПриАктивизацииСтроки(Элемент)
	Если Элемент.ТекущиеДанные <> неопределено тогда
		НаименованиеПоставщика = Элемент.ТекущиеДанные.НаименованиеПоставщика;
		НаименованиеНаше = Элемент.ТекущиеДанные.НаименованиеНаше;
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура ЗаполнитьТаблицуСогласованиеНаСервере()
	
	Согласование.Очистить();
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ 
	|   ТЗ.НомерСтроки,
	|	ТЗ.КодСтроки,
	|	ТЗ.Товар
	|ПОМЕСТИТЬ ВТТовар
	|ИЗ
	|	&ТЗ КАК ТЗ
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ВТТовар.НомерСтроки,
	|	ВТТовар.КодСтроки,
	|	ВТТовар.Товар,
	|	ВТТовар.Товар.Наименование,
	|	ВТТовар.Товар.Код,
	|	МАКСИМУМ(ВЫБОР
	|			КОГДА Деление.Ссылка ЕСТЬ NULL 
	|				ТОГДА ЛОЖЬ
	|			ИНАЧЕ ИСТИНА
	|		КОНЕЦ) КАК Деление
	|ИЗ
	|	ВТТовар КАК ВТТовар
	|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.Деление КАК Деление
	|		ПО (Деление.Владелец = ВТТовар.Товар
	|				ИЛИ Деление.ТоварПолучаемый = ВТТовар.Товар)
	|
	|СГРУППИРОВАТЬ ПО
	|	ВТТовар.НомерСтроки,
	|	ВТТовар.КодСтроки,
	|	ВТТовар.Товар";
	
	ТЗ = Объект.Товары.Выгрузить(,"НомерСтроки,КодСтроки,Товар");

	Запрос.УстановитьПараметр("ТЗ",ТЗ);
	
	ТаблицаУсловие = Запрос.Выполнить().Выгрузить(); 
	
	СтрокаУсловие = "";
	Для каждого строка из ТаблицаУсловие цикл
		Если ЗначениеЗаполнено(строка.КодСтроки) тогда 
			СтрокаУсловие = СтрокаУсловие + "'" + Формат(строка.КодСтроки,"ЧГ=") + "'" + ",";
		КонецЕсли;
	КонецЦикла;
	ДлинаУсловия = СтрДлина(СтрокаУсловие);
	Если ДлинаУсловия = 0 тогда
		Возврат
	КонецЕсли;
	СтрокаУсловие = Лев(СтрокаУсловие,ДлинаУсловия-1); 
	СтрокаУсловие = "("+СтрокаУсловие+")";
	
	ТекстЗапроса = 
	"set nocount on 
	|
	|if object_id('tempdb..#ovh_l') is not null drop table #ovh_l
	|
	|select id, name, firm, cntr, codepst, id_supplier  
	|into #ovh_l 
	|from ea5..overhead_list (nolock) 
	|where id in "+СтрокаУсловие+"
	|
	|if object_id('courierDS.dbo.t_product_matching') is not null 
	|SELECT ovh_l.id, ovh_l.name, ovh_l.firm, ovh_l.cntr, ovh_l.codepst, ovh_l.id_supplier, pm.update_date,  pm.code, 1 as t_product_matching    
	|FROM #ovh_l ovh_l
	|LEFT JOIN courierDS.dbo.t_product_matching pm (NOLOCK) ON ovh_l.id_supplier = pm.id_supplier
	|	AND ovh_l.codepst = pm.code_pst
	|else
	|SELECT ovh_l.id, ovh_l.name, ovh_l.firm, ovh_l.cntr, ovh_l.codepst, ovh_l.id_supplier, null as update_date,  null as code, 0 as t_product_matching     
	|FROM #ovh_l ovh_l
	|
	|if object_id('tempdb..#ovh_l') is not null drop table #ovh_l";
	
	РезультатТЗ = РаботаСSQL.ВыполнитьЗапросSQL(ТекстЗапроса,,Справочники.НастройкиПодключения.БазаCourierDS,Истина); 
		
	Если РезультатТЗ = Неопределено тогда
		Возврат
	КонецЕсли;
	ПроверочнаяДата = ДобавитьМесяц(НачалоДня(ТекущаяДата()),-3);
	Для каждого строка из ТаблицаУсловие цикл
		СтрокаТЗ = РезультатТЗ.Найти(строка.КодСтроки,"id");
		Если СтрокаТЗ <> неопределено тогда
					
			ПоставщикТовар		=	СтрокаТЗ.name;
			ПоставщикЗавод		=	СтрокаТЗ.firm;
			ПоставщикСтрана		=	СтрокаТЗ.cntr;
			ДатаАктуальности	=  ?(СтрокаТЗ.update_date = null, Дата(1,1,1),НачалоДня(СтрокаТЗ.update_date));
			КодНоменклатуры 	=  ?(СтрокаТЗ.code = null,"",СтрокаТЗ.code);
			ОшибкаСогласования  =  ?((СокрЛП(строка.ТоварКод) <> СокрЛП(КодНоменклатуры) или ДатаАктуальности < ПроверочнаяДата) и СтрокаТЗ.t_product_matching = 1,Истина,Ложь);
		
			Если ТолькоТребующиеСогласования и не ОшибкаСогласования тогда
				Продолжить;
			КонецЕсли;
			
			СтрокаСогласование = ЭтаФорма.Согласование.Добавить();
			
			СтрокаСогласование.КодСтроки 				= Строка.КодСтроки;
			СтрокаСогласование.НаименованиеПоставщика 	= НРег(ПоставщикТовар+?(СтрДлина(ПоставщикЗавод)=0,""," "+ПоставщикЗавод)+?(СтрДлина(ПоставщикСтрана)=0,""," "+ПоставщикСтрана));
			СтрокаСогласование.НаименованиеНаше 		= Строка.Товар;
			СтрокаСогласование.НаименованиеНашеСтрока   = НРег(Строка.ТоварНаименование);
			СтрокаСогласование.id_supplier              = Формат(СтрокаТЗ.id_supplier, "ЧДЦ=; ЧРД=; ЧРГ=; ЧГ=");  
			СтрокаСогласование.code_pst                 = СтрокаТЗ.codepst;
			СтрокаСогласование.ОшибкаСогласования		= ОшибкаСогласования;
			СтрокаСогласование.НомерСтроки 				= строка.НомерСтроки;			
		КонецЕсли;
	КонецЦикла;
	
	ЭтаФорма.Согласование.Сортировать("ОшибкаСогласования Убыв, НомерСтроки Возр");
	
КонецПроцедуры

&НаКлиенте
Процедура ЗаполнитьТаблицуСогласование(Команда)
	ЗаполнитьТаблицуСогласованиеНаСервере();
КонецПроцедуры

&НаКлиенте
Процедура СтраницыПриСменеСтраницы(Элемент, ТекущаяСтраница)
	Если ТекущаяСтраница = ЭтаФорма.Элементы.Согласование Тогда
		ЗаполнитьТаблицуСогласованиеНаСервере();
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура ФильтрПриИзменении(Элемент)
	ФильтрПриИзмененииНаСервере();
КонецПроцедуры

&НаСервере
Процедура ФильтрПриИзмененииНаСервере()
	ТоварДляПодмены.Очистить();
	Если СтрДлина(Фильтр) < 3 тогда
		Сообщение = Новый СообщениеПользователю;
		Сообщение.Текст = "Для фильтра необходимо ввести минимум 3 символа!";
		Сообщение.Сообщить();
		Возврат;
	КонецЕсли;
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	Номенклатура.Ссылка как Товар
	|ИЗ
	|	Справочник.Номенклатура КАК Номенклатура
	|ГДЕ
	|	Номенклатура.Наименование ПОДОБНО ""%"" + &Наименование + ""%""
	|
	|УПОРЯДОЧИТЬ ПО
	|	Номенклатура.Наименование";
	Запрос.УстановитьПараметр("Наименование",Фильтр);
	ТоварДляПодмены.Загрузить(Запрос.Выполнить().Выгрузить());
КонецПроцедуры

&НаКлиенте
Процедура СогласованиеТаблицаВыбор(Элемент, ВыбраннаяСтрока, Поле, СтандартнаяОбработка)
	ТоварНаш = Элемент.ТекущиеДанные.НаименованиеНаше;
	ТоварПринимали = ПоТоваруБылиПриняты(ТоварНаш);
	Если Объект.ВычНП или Объект.РазрешенаПриемка и ТоварПринимали тогда
		 Сообщение = Новый СообщениеПользователю;
		 Сообщение.Текст = "Редактирование согласования доступно только при снятом флаге ""Разрешена приемка""!";
		 Сообщение.Сообщить();
	Иначе
		СогласованиеТаблицаВыборНаСервере(Элемент.ТекущиеДанные.НаименованиеПоставщика);
	КонецЕсли;
КонецПроцедуры

&НаСервере
Функция ПоТоваруБылиПриняты(ТоварНаш)
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	Приемка_ТоварыВРаботе.Период КАК Период
	|ИЗ
	|	РегистрСведений.Приемка_ТоварыВРаботе КАК Приемка_ТоварыВРаботе
	|ГДЕ
	|	Приемка_ТоварыВРаботе.Документ = &Документ
	|	И Приемка_ТоварыВРаботе.Товар = &Товар";
	Запрос.УстановитьПараметр("Документ",Объект.Ссылка);
	Запрос.УстановитьПараметр("Товар",ТоварНаш);
	
	Возврат НЕ Запрос.Выполнить().Пустой();
	
КонецФункции

&НаСервере
Процедура СогласованиеТаблицаВыборНаСервере(СтрокаДляПоиска)
	
	Если КоличествоСимволовФильтра = 99 тогда
		НомерСимволаПробела = стрНайти(СтрокаДляПоиска," ")-1;
		Фильтр = Лев(СтрокаДляПоиска,НомерСимволаПробела);
	Иначе
		Фильтр = Лев(СтрокаДляПоиска,КоличествоСимволовФильтра);
	КонецЕсли;
	ФильтрПриИзмененииНаСервере();
	
КонецПроцедуры

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)

	Если Объект.ВычНП тогда
		ЭтаФорма.ТолькоПросмотр = Истина;
	КонецЕсли;
	ТолькоТребующиеСогласования = Истина;
	КоличествоСимволовФильтра = 10;  
	ЭтоОрдернаяСхема = Объект.ОрдернаяСхема = 1;
	УстановитьДоступностьЭлементов();	
	Отказ = не Заблокировать();
	
КонецПроцедуры

&НаСервере
Процедура УстановитьДоступностьЭлементов()
	
	ЭтоОрдернаяСхема = Объект.ОрдернаяСхема = 1;
	Элементы.РазрешенаПриемка.Доступность = ЭтоОрдернаяСхема;
	Элементы.ТоварыНакладная.ИзменятьПорядокСтрок = не ЭтоОрдернаяСхема; 
	Элементы.ТоварыНакладная.ИзменятьСоставСтрок = не ЭтоОрдернаяСхема;	
	Элементы.ТоварыТовар.ТолькоПросмотр = ЭтоОрдернаяСхема;
	Элементы.ТоварыСертификаты.ИзменятьПорядокСтрок = не ЭтоОрдернаяСхема; 
	Элементы.ТоварыСертификаты.ИзменятьСоставСтрок = не ЭтоОрдернаяСхема;	
	Элементы.ТоварыРеестр.ИзменятьПорядокСтрок = не ЭтоОрдернаяСхема; 
	Элементы.ТоварыРеестр.ИзменятьСоставСтрок = не ЭтоОрдернаяСхема;	
	Элементы.ТоварыПриемныйАкт.ИзменятьПорядокСтрок = не ЭтоОрдернаяСхема; 
	Элементы.ТоварыПриемныйАкт.ИзменятьСоставСтрок = не ЭтоОрдернаяСхема;
	Элементы.РассчитатьНДС.Доступность =  Объект.Товары.Итог("КодСтроки") = 0;
	Элементы.ОрдернаяСхема.Доступность = не Объект.ВычНП;
	Элементы.РазрешенаПриемка.Доступность = не Объект.ВычНП;
	Элементы.БракованнаяСерияПредупреждение.Видимость = Объект.Товары.НайтиСтроки(Новый Структура("БракованнаяСерия",Истина)).Количество() > 0; 
		
КонецПроцедуры

&НаКлиенте
Процедура ТоварДляПодменыВыбор(Элемент, ВыбраннаяСтрока, Поле, СтандартнаяОбработка)
	ТоварНаш = Элементы.СогласованиеТаблица.ТекущиеДанные.НаименованиеНаше;
	ТоварПринимали = ПоТоваруБылиПриняты(ТоварНаш);
	Если Объект.ВычНП или Объект.РазрешенаПриемка и ТоварПринимали тогда
		 Сообщение = Новый СообщениеПользователю;
		 Сообщение.Текст = "Редактирование согласования доступно только при снятом флаге ""Разрешена приемка""!";
		 Сообщение.Сообщить();
		 Возврат;
	КонецЕсли;

	ВыбраннаяНоменкалтура = Элемент.ТекущиеДанные.Товар;
	Если не ЗначениеЗаполнено(ВыбраннаяНоменкалтура) Тогда 
		Возврат;
	Иначе
		ПараметрыОповещения 	= Новый Структура("НоменклатураДляЗамены,КодСтроки",ВыбраннаяНоменкалтура,Элементы.СогласованиеТаблица.ТекущиеДанные.КодСтроки);
		Оповещение 	= Новый ОписаниеОповещения("ПослеЗакрытияВопроса", ЭтаФорма, ПараметрыОповещения);
		ПоказатьВопрос(Оповещение,"Вы уверены что хотите заменить позицию?",РежимДиалогаВопрос.ДаНет);
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура ПослеЗакрытияВопроса(Результат, Параметр) Экспорт
	Если Результат = КодВозвратаДиалога.Нет Тогда
		Возврат;
	КонецЕсли;
	
	Если НЕ Автоперебор Тогда
		Строки = Объект.Товары.НайтиСтроки(Новый Структура("КодСтроки",Параметр.КодСтроки));
		Для каждого строка из строки цикл
			строка.Товар = Параметр.НоменклатураДляЗамены;
			Если ЗначениеЗаполнено(Строка.Партия) тогда
				ЗаменитьВладельцаПартии(строка.Партия,Строка.Товар);
			КонецЕсли;
		КонецЦикла;
		Строки = Согласование.НайтиСтроки(Новый Структура("КодСтроки",Параметр.КодСтроки));
		Для каждого строка из строки цикл
			Строка.НаименованиеНаше = Параметр.НоменклатураДляЗамены; 
			Строка.НаименованиеНашеСтрока = Строка(Параметр.НоменклатураДляЗамены); 
		КонецЦикла;
		
	Иначе
		Строки = Объект.Товары.НайтиСтроки(Новый Структура("КодСтроки",Параметр.КодСтроки));
		ЗаменяемыйТовар = Строки[0].Товар;
		Строки = Объект.Товары.НайтиСтроки(Новый Структура("Товар",ЗаменяемыйТовар));
		Для Каждого Строка из Строки Цикл
			Строка.Товар = Параметр.НоменклатураДляЗамены;
			Если ЗначениеЗаполнено(Строка.Партия) тогда
				ЗаменитьВладельцаПартии(строка.Партия,Строка.Товар);
			КонецЕсли;
		КонецЦикла;
		Строки = Согласование.НайтиСтроки(Новый Структура("НаименованиеНаше",ЗаменяемыйТовар));
		Для Каждого Строка из Строки Цикл
			Строка.НаименованиеНаше = Параметр.НоменклатураДляЗамены;
			Строка.НаименованиеНашеСтрока = Строка(Параметр.НоменклатураДляЗамены); 
		КонецЦикла;		
	КонецЕсли;
КонецПроцедуры

&НаСервереБезКонтекста
Процедура ВыполнитьЗаменуСоответствияТовара(СтруктураЗамены,Соединение)
	ТекстЗапросаSQL = 
	"set nocount on  
	|
	|DECLARE @Nom_Cod varchar(8), @string_num integer,  @code_pst varchar(32), @id_supplier integer 
	|SET @Nom_Cod = '" + СокрЛП(СтруктураЗамены.ТоварКод) +"'
	|SET @string_num = "+СтруктураЗамены.КодСтроки+"
	|
	|SELECT @id_supplier = id_supplier,@code_pst = codepst FROM ea5..overhead_list WHERE id = @string_num
	|
	|IF object_id('[courierDS].[dbo].[t_product_matching]') is not null 
	|	BEGIN 
	|		DELETE FROM	[courierDS].[dbo].[t_product_matching]
	|		WHERE code_pst = @code_pst AND id_supplier = @id_supplier 
	|		
	|		INSERT INTO [courierDS].[dbo].[t_product_matching]
	|	    VALUES(@Nom_Cod,@code_pst,@id_supplier,NULL,'"+СтруктураЗамены.Пользователь+"')	
	|	END
	|	";
	РаботаСSQL.ВыполнитьЗапросSQL(ТекстЗапросаSQL,,Справочники.НастройкиПодключения.БазаCourierDS);
КонецПроцедуры

&НаСервере
Процедура ЗаменитьВладельцаПартии(ПартияСсылка, НовыйТовар)
	
	Партия = ПартияСсылка.ПолучитьОбъект();
	Партия.Владелец = НовыйТовар;
	Партия.Записать();
	
КонецПроцедуры

&НаКлиенте
Процедура ОрдернаяСхемаПриИзменении(Элемент)
	ОрдернаяСхемаПриИзмененииНаСервере();   
	УстановитьДоступностьЭлементов();
КонецПроцедуры

&НаСервере
Процедура ОрдернаяСхемаПриИзмененииНаСервере()
	
	Запрос = новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	Приемка_ТоварыВРаботе.Документ
	|ИЗ
	|	РегистрСведений.Приемка_ТоварыВРаботе КАК Приемка_ТоварыВРаботе
	|ГДЕ
	|	Приемка_ТоварыВРаботе.Документ = &Документ";
	Запрос.УстановитьПараметр("Документ",Объект.Ссылка);
	Результат = Запрос.Выполнить();
	ЗапретитьИзменениеСхемыПриемки = Ложь;
	//Если Результат <> неопределено тогда
	//	Если Результат.Количество() > 0 тогда
	//		ЗапретитьИзменениеСхемыПриемки = Истина;
	//	КонецЕсли;
	//КонецЕсли;
	Если НЕ Результат.Пустой() тогда
		ЗапретитьИзменениеСхемыПриемки = Истина;
	КонецЕсли;
	
	Если ЗапретитьИзменениеСхемыПриемки тогда
		//ПоказатьПредупреждение(,"По ордерной схеме уже были движения, менять схему нельзя!");
		ОрдернаяСхема=1; 
	КонецЕсли;
	
	Элементы.РазрешенаПриемка.Доступность = Объект.ОрдернаяСхема = 1;
	Если не Элементы.РазрешенаПриемка.Доступность тогда
		Объект.РазрешенаПриемка = Ложь;
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура РазрешенаПриемкаПриИзменении(Элемент)
	Если Объект.РазрешенаПриемка тогда
		Если не ЗначениеЗаполнено(Объект.ДатаОплаты) тогда
			ПоказатьПредупреждение(,"Необходимо заполнить дату оплаты!",,"Ошибка!");
			Объект.РазрешенаПриемка = Ложь;
			Возврат;
		ИначеЕсли Объект.ДатаОснования > ДобавитьМесяц(Объект.Дата,1) тогда
			ПоказатьПредупреждение(,"Некорректная дата оплаты!",,"Ошибка!");
			Объект.РазрешенаПриемка = Ложь;
			Возврат;
		КонецЕсли;
	КонецЕсли;
	
	РазрешенаПриемкаПриИзмененииНаСервере();
КонецПроцедуры

&НаСервере
Процедура РазрешенаПриемкаПриИзмененииНаСервере()
	Если Объект.РазрешенаПриемка тогда
		СтрокиСПустойПартией = Объект.Товары.НайтиСтроки(Новый Структура("Партия",Справочники.Партии.ПустаяСсылка()));
		Если СтрокиСПустойПартией.Количество() <> 0 тогда
			//ПоказатьПредупреждение(,"Не везде есть партии");
			Объект.РазрешенаПриемка = 0;
			Возврат;
		КонецЕсли;
		Для каждого строка из Объект.Товары цикл
			Прайс = Справочники.ПрайсЛист.НайтиПоРеквизиту("Товар",Строка.Товар);
			Если ЗначениеЗаполнено(Прайс) тогда
				Если Прайс.ЖВЛ тогда
					Если (строка.РеестроваяЦена>0) И (строка.ЦенаПроизводителя>0) Тогда
						Если (строка.РеестроваяЦена > строка.ЦенаПроизводителя*2) ИЛИ (строка.ЦенаПроизводителя > строка.РеестроваяЦена*2) Тогда
							Сообщить("На товар "+СокрЛП(строка.Товар.Наименование)+" проверьте цену Реестра и Производителя!");
						КонецЕсли;	
					КонецЕсли;	
				КонецЕсли;
			КонецЕсли;
		КонецЦикла;		
	КонецЕсли;
		
	
	ТЗстрок = Новый ТаблицаЗначений;
	ТЗстрок.Колонки.Добавить("Товар");
	ТЗстрок.Колонки.Добавить("Количество");
	Для Каждого СтрокаТовары Из Объект.Товары цикл
		НоваяСтрокаТЗстрок = ТЗстрок.Добавить();
		НоваяСтрокаТЗстрок.Товар = СтрокаТовары.Товар;
		НоваяСтрокаТЗстрок.Количество = СтрокаТовары.Количество - СтрокаТовары.Недовоз - СтрокаТовары.Перевоз - СтрокаТовары.Брак; 
	КонецЦикла;
	ТЗСтрок.Свернуть("Товар","Количество");
	
	//ТекстЗапроса=
	//"
	//|if not exists(select * from t_prih_order_enable (nolock) where docno="+Объект.Номер+" and d_doc='"+Формат(Объект.Дата,"ДФ=ггггММдд")+"')
	//|insert t_prih_order_enable (docno, d_doc, sotr, [Строк], [Штук]) values ("+Объект.Номер+",'"+Формат(Объект.Дата,"ДФ=ггггММдд")+"','"+ПараметрыСеанса.ТекущийПользователь.Код+"', "+Строка(ТЗстрок.Количество())+", "+Строка(ТЗстрок.Итог("Количество"))+") 
	//|";
		
	
	Если Объект.ОрдернаяСхема = 1 и объект.ТипНакладной <> перечисления.ТипыПрихНакл.ВводОстатков тогда
		СоединениеSQL = РаботаСSQL.ПодключениеКСерверуSQLПоНастройке(справочники.НастройкиПодключения.БазаCourierDS);
		Если СоединениеSQL = неопределено тогда 
			Возврат
		КонецЕсли;
		СтруктураВозврата = Новый Структура;
		ПользовательСтрока = ПараметрыСеанса.ТекущийПользователь.Наименование;
		Для каждого строка из Объект.Товары цикл
			Если Строка.КодСтроки = 0 тогда 
				Продолжить;
			КонецЕсли;
			СтруктураВозврата.Вставить("ТоварКод", СокрЛП(строка.Товар.Код));
			СтруктураВозврата.Вставить("КодСтроки", Формат(Строка.КодСтроки,"ЧРД=; ЧРГ=; ЧГ="));
			СтруктураВозврата.Вставить("Пользователь", ПользовательСтрока);
			ВыполнитьЗаменуСоответствияТовара(СтруктураВозврата,СоединениеSQL);
		КонецЦикла;
	КонецЕсли;
	
	
КонецПроцедуры

&НаСервере
Процедура ЗаполнитьДатуПоДоговоруНаСервере()
	
	Если ЗначениеЗаполнено(Объект.ДатаОснования) тогда
		Если ЗначениеЗаполнено(Объект.Клиент) тогда
			Объект.ДатаОплаты = Объект.ДатаОснования+Объект.Клиент.Отсрочка*60*60*24;
		КонецЕсли;
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ЗаполнитьДатуПоДоговору(Команда)
	ЗаполнитьДатуПоДоговоруНаСервере();
КонецПроцедуры

&НаКлиенте
Процедура ВычНППриИзменении(Элемент)
	Если (Объект.ОрдернаяСхема=0) Тогда
		Сообщить("Не выбрана схема приемки");
		Объект.ВычНП=Ложь;
		Возврат;
	КонецЕсли;
	Если (Объект.ОрдернаяСхема>0) И (Объект.РазрешенаПриемка<>Истина) Тогда
		Сообщить("Не проведена проверка");
		Объект.ВычНП=0;
		Возврат;
	КонецЕсли;
	
	Если не ЗначениеЗаполнено(Объект.ДатаОплаты) Тогда
		Сообщить("Не проставлена дата оплаты!");
		Объект.ВычНП=0;
		Возврат;
	КонецЕсли; 
	
	НеПроставленПроизводитель = Ложь;
	Если Объект.ВычНП = Истина Тогда
		Если НЕ	ВычНППриИзмененииНаСервере(НеПроставленПроизводитель) тогда
			ПоказатьПредупреждение(,"Не выполнен пуск в продажу",10,"Ошибка");
		КонецЕсли;
	КонецЕсли;
	Элементы.ОрдернаяСхема.Доступность = не Объект.ВычНП;
	Элементы.РазрешенаПриемка.Доступность = не Объект.ВычНП;
	
КонецПроцедуры

&НаСервере
Функция ВычНППриИзмененииНаСервере(НеПроставленПроизводитель)
	
	Если Объект.ОрдернаяСхема = 2 тогда
		Запрос = Новый Запрос;
		Запрос.Текст = 
		"ВЫБРАТЬ
		|	ПриемныйОрдер.Ссылка
		|ИЗ
		|	Документ.ПриемныйОрдер КАК ПриемныйОрдер
		|ГДЕ
		|	ПриемныйОрдер.ДокументОснование = &Ссылка
		|	И ПриемныйОрдер.Проведен";
		Запрос.УстановитьПараметр("Ссылка",Объект.Ссылка);
		Если Запрос.Выполнить().Пустой() и Объект.Товары.Итог("Сумма")>0 тогда
			Сообщение = Новый СообщениеПользователю;
			Сообщение.Текст = "По текущему документу не был сформирован Приходный ордер!
			|Товары не могут быть переданы в продажу!";
			Сообщение.Сообщить();
			Объект.ВычНП = Ложь;
			Возврат Ложь;
		КонецЕсли;
		
		ТоварыТЗ = Объект.Товары.Выгрузить(,"Партия,Количество,Недовоз,Перевоз,Брак");
		Запрос = Новый Запрос;
		Запрос.Текст = 
		"ВЫБРАТЬ
		|	Товары.Партия,
		|	Товары.Количество,
		|	Товары.Недовоз,
		|	Товары.Перевоз,
		|	Товары.Брак
		|ПОМЕСТИТЬ Товары
		|ИЗ
		|	&ТоварыТЗ КАК Товары
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	ПриемныйОрдерПринятыйТовар.Партия,
		|	СУММА(ПриемныйОрдерПринятыйТовар.Количество) КАК Количество
		|ПОМЕСТИТЬ втПриемныйОрдер
		|ИЗ
		|	Документ.ПриемныйОрдер.ПринятыйТовар КАК ПриемныйОрдерПринятыйТовар
		|ГДЕ
		|	ПриемныйОрдерПринятыйТовар.Ссылка.ДокументОснование = &Ссылка
		|	И ПриемныйОрдерПринятыйТовар.Ссылка.Проведен
		|
		|СГРУППИРОВАТЬ ПО
		|	ПриемныйОрдерПринятыйТовар.Партия
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	Товары.Партия.Владелец.Наименование КАК Наименование
		|ИЗ
		|	Товары КАК Товары
		|		ЛЕВОЕ СОЕДИНЕНИЕ втПриемныйОрдер КАК втПриемныйОрдер
		|		ПО Товары.Партия = втПриемныйОрдер.Партия
		|ГДЕ
		|	Товары.Количество - Товары.Недовоз - Товары.Перевоз - Товары.Брак - ЕСТЬNULL(втПриемныйОрдер.Количество, 0) > 0";
		Запрос.УстановитьПараметр("ТоварыТЗ",ТоварыТЗ);
		Запрос.УстановитьПараметр("Ссылка",Объект.Ссылка);
		ФлагЗапрет = Ложь;
		Результат = Запрос.Выполнить();	
		Если НЕ Результат.Пустой() тогда
			Выборка = Результат.Выбрать();
			Пока Выборка.Следующий() цикл
				Сообщение = Новый СообщениеПользователю;
				Сообщение.Текст = "По товару "+Выборка.Наименование+" имеет разность количества в приходной наклодной и в приемных ордерах";
				Сообщение.Сообщить();
				ФлагЗапрет = Истина;
			КонецЦикла;
		КонецЕсли;
		Если ФлагЗапрет тогда
			Объект.ВычНП = Ложь;
			Возврат Ложь;
		КонецЕсли;
		
	КонецЕсли;
	
	тчТовары = объект.Товары;
	Для каждого строка из тчТовары цикл
		Если не ЗначениеЗаполнено(Строка.Производитель) И не Объект.Клиент.НеТребоватьВводаПроизводителя Тогда
			НеПроставленПроизводитель = Истина;
		КонецЕсли; 
		Если НЕ ЗначениеЗаполнено(строка.ГоденДо) Тогда
			Если ДобавитьМесяц(Объект.ДатаДок,3)>Строка.ГоденДо Тогда
				Сообщение = Новый СообщениеПользователю;
				Сообщение.Текст ="Товар "+СокрЛП(Строка.Товар.Наименование)+" срок менее трех месяцев!";
				Сообщение.Сообщить();
			КонецЕсли;
		КонецЕсли;	
	КонецЦикла;
	Возврат Истина;
	
КонецФункции

&НаКлиенте
Процедура КлиентПриИзменении(Элемент)
	КлиентПриИзмененииНаСервере();
КонецПроцедуры

&НаСервере
Процедура КлиентПриИзмененииНаСервере()
	Если ЗначениеЗаполнено(Объект.Клиент) тогда
		Объект.Упрощенка = Объект.Клиент.Упрощенка;
		Если Объект.Упрощенка тогда
			Объект.НДСПоставщика = 0;
		КонецЕсли;
		Элементы.НДСПоставщика.Доступность = не Объект.Упрощенка;
		Элементы.РассчитатьНДС.Доступность = не Объект.Упрощенка;
	КонецЕсли;
КонецПроцедуры

&НаСервереБезКонтекста
Процедура РасчитатьСтрокуТЗТовары(Строка,РасчетОтСуммы)
	//Если Объект.РасчетОтСуммы тогда
	//	Если Строка.Количество = 0 тогда
	//		Строка.Сумма = 0;
	//		Строка.Цена = 0;
	//	Иначе
	//		Строка.Цена = Окр(Строка.Сумма/Строка.Количество,2);
	//		Если (Строка.Количество-Строка.Недовоз-Строка.Перевоз-Строка.Брак)>0 тогда
	//			Строка.Сумма = Строка.Цена*(Строка.Количество-Строка.Недовоз-Строка.Перевоз-Строка.Брак);
	//		КонецЕсли;
	//	КонецЕсли;
	//Иначе
	//	Строка.Сумма = Строка.Цена*(Строка.Количество-Строка.Недовоз-Строка.Перевоз-Строка.Брак);		
	//КонецЕсли;	
	//ОбщиеФункцииКлиент.РасчитатьСтрокуТЗТоварыКлиент(Строка,Объект.РасчетОтСуммы);
	ОбщиеФункцииКлиент.РасчитатьСтрокуТЗТовары(Строка,РасчетОтСуммы);
КонецПроцедуры

&НаКлиенте
Процедура РасчитатьСтрокуТЗТоварыКлиент(Строка,РасчетОтСуммы)
	
	Структура = Новый Структура("Количество,Сумма,Цена,Недовоз,Перевоз,Брак");
	ЗаполнитьЗначенияСвойств(Структура,Строка);
	РасчитатьСтрокуТЗТовары(Структура,Объект.РасчетОтСуммы);
	ЗаполнитьЗначенияСвойств(Строка,Структура);

	
КонецПроцедуры

&НаКлиенте
Процедура РассчитатьНДС(Команда)
	Для каждого строка из Объект.Товары цикл
		Если Объект.Упрощенка тогда
			ПроцентНДС = 0;
		Иначе
			ПроцентНДС = ПолучитьСтавкуНДСНоменклатуры(Строка.Товар,Объект.Дата);
		КонецЕсли;
		Строка.СуммаНДС = строка.Цена*Строка.Количество*ПроцентНДС/(100+ПроцентНДС); 
		РасчитатьСтрокуТЗТоварыКлиент(Строка, Объект.РасчетОтСуммы);
	КонецЦикла;
КонецПроцедуры

&НаСервере
Функция ПолучитьСтавкуНДСНоменклатуры(Товар,Дата)
	Возврат РегистрыСведений.СтавкиНДСПоНоменклатуре.ВернутьСтавкуНДСПоНоменклатуре(Товар,Дата,Истина);
КонецФункции

&НаКлиенте
Процедура ТоварыНакладнаяПриОкончанииРедактирования(Элемент, НоваяСтрока, ОтменаРедактирования)

	РасчитатьСтрокуТЗТоварыКлиент(Элемент.ТекущиеДанные,Объект.РасчетОтСуммы);

КонецПроцедуры

&НаКлиенте
Процедура СуммаПриИзменении(Элемент)
	Объект.СуммаПоставщика = Объект.Сумма0+Объект.Сумма10+Объект.Сумма20+Объект.СуммаНДС10+Объект.СуммаНДС20;
	Объект.НДСПоставщика = Объект.СуммаНДС10+Объект.СуммаНДС20; 
КонецПроцедуры

&НаСервере
Функция Заблокировать()
	Попытка
		ЭтотОбъект.ЗаблокироватьДанныеФормыДляРедактирования();
		Возврат Истина
	Исключение
		Сообщить(ОписаниеОшибки());
		ВОзврат Ложь
	КонецПопытки;
КонецФункции

&НаКлиенте
Процедура ТолькоТребующиеСогласованияПриИзменении(Элемент)
	ЗаполнитьТаблицуСогласованиеНаСервере();
КонецПроцедуры

&НаКлиенте
Процедура ТоварыНакладнаяПередОкончаниемРедактирования(Элемент, НоваяСтрока, ОтменаРедактирования, Отказ)
	
	ГоденДо = Элементы.ТоварыНакладная.ТекущиеДанные.ГоденДо;
	Если ЗначениеЗаполнено(ГоденДо) и Год(ГоденДо) < 2000 и не ОтменаРедактирования тогда
		Отказ = Истина;
		Сообщение = Новый СообщениеПользователю;
		Сообщение.Поле = "Объект.Товары["+Элементы.ТоварыНакладная.ТекущаяСтрока+"].ГоденДо";
		Сообщение.Текст = "Введена некоректная дата!";
		Сообщение.Сообщить();
	КонецЕсли;

КонецПроцедуры


&НаСервере
Процедура ПередЗаписьюНаСервере(Отказ, ТекущийОбъект, ПараметрыЗаписи)
	
	Если ТекущийОбъект.РазрешенаПриемка и (не ЗначениеЗаполнено(ТекущийОбъект.Ссылка)  или не ТекущийОбъект.Ссылка.РазрешенаПриемка) тогда
		МассивСтрокСПустойСерией = ТекущийОбъект.Товары.НайтиСтроки(Новый Структура("Серия",""));
		Для  каждого строка из МассивСтрокСПустойСерией цикл
			Сообщение = Новый СообщениеПользователю;
			Сообщение.Текст = "В строке " + Строка.НомерСтроки + " не заполнена серия!";
			Сообщение.Сообщить();
			Отказ = Истина;
		КонецЦикла;
	КонецЕсли;
КонецПроцедуры

