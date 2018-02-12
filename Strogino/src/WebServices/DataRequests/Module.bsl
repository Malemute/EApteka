
Функция Accounting_GetSales(PeriodStart, PeriodEnd, KKMNumber)
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	РеализацияОбороты.Организация.ИНН КАК Фирма,
	|	НАЧАЛОПЕРИОДА(РеализацияОбороты.Период, ДЕНЬ) КАК ДатаДокумента,
	|	РеализацияОбороты.ККМ.ЗаводскойНомер КАК НаимККМ,
	|	ВЫБОР
	|		КОГДА РеализацияОбороты.Товар.ID_77 = ""  13ZB   ""
	|			ТОГДА ""Доставка""
	|		КОГДА РеализацияОбороты.Партия.Комиссия
	|			ТОГДА ""Комиссия""
	|		КОГДА ЕСТЬNULL(РеализацияОбороты.СтавкаНДС.Ставка, 0) = 0
	|			ТОГДА ""ТоварыБезНДС""
	|		КОГДА ЕСТЬNULL(РеализацияОбороты.СтавкаНДС.Ставка, 0) = 10
	|			ТОГДА ""Товары10""
	|		ИНАЧЕ ""Товары18""
	|	КОНЕЦ КАК КодСпрНом,
	|	СУММА(РеализацияОбороты.КоличествоОборот) КАК Количество,
	|	СУММА(ВЫБОР
	|			КОГДА РеализацияОбороты.ТипОплаты = ЗНАЧЕНИЕ(Перечисление.ТипОплаты.Наличные)
	|				ТОГДА 0
	|			ИНАЧЕ ВЫРАЗИТЬ(РеализацияОбороты.ВсегоОборот КАК ЧИСЛО(10, 2))
	|		КОНЕЦ) КАК СуммаЧека_БН,
	|	СУММА(ВЫРАЗИТЬ(РеализацияОбороты.ВсегоОборот КАК ЧИСЛО(10, 2))) КАК СуммаПоСтроке,
	|	СУММА(ВЫРАЗИТЬ(ВЫБОР
	|				КОГДА РеализацияОбороты.Товар.ID_77 = ""  13ZB   ""
	|					ТОГДА (ВЫРАЗИТЬ(РеализацияОбороты.ВсегоОборот КАК ЧИСЛО(10, 2))) / 118 * 18
	|				КОГДА РеализацияОбороты.Партия.Комиссия
	|					ТОГДА (ВЫРАЗИТЬ(РеализацияОбороты.ВсегоОборот КАК ЧИСЛО(10, 2))) / 110 * 10
	|				КОГДА ЕСТЬNULL(РеализацияОбороты.СтавкаНДС.Ставка, 0) = 0
	|					ТОГДА 0
	|				КОГДА ЕСТЬNULL(РеализацияОбороты.СтавкаНДС.Ставка, 0) = 10
	|					ТОГДА (ВЫРАЗИТЬ(РеализацияОбороты.ВсегоОборот КАК ЧИСЛО(10, 2))) / 110 * 10
	|				ИНАЧЕ (ВЫРАЗИТЬ(РеализацияОбороты.ВсегоОборот КАК ЧИСЛО(10, 2))) / 118 * 18
	|			КОНЕЦ КАК ЧИСЛО(10, 2))) КАК СуммаНДС,
	|	СУММА(ВЫРАЗИТЬ(ВЫБОР
	|				КОГДА ПОДСТРОКА(РеализацияОбороты.Партия.Фирма.ИНН, 1, 10) = ПОДСТРОКА(РеализацияОбороты.ККМ.Фирма.ИНН, 1, 10)
	|					ТОГДА ВЫБОР
	|							КОГДА РеализацияОбороты.Товар.ID_77 = ""  13ZB   ""
	|								ТОГДА 0
	|							КОГДА РеализацияОбороты.Партия.Комиссия
	|								ТОГДА РеализацияОбороты.КоличествоОборот * РеализацияОбороты.Партия.ЗакупочнаяЦена
	|							КОГДА ЕСТЬNULL(РеализацияОбороты.СтавкаНДС.Ставка, 0) = 0
	|								ТОГДА РеализацияОбороты.КоличествоОборот * РеализацияОбороты.Партия.ЗакупочнаяЦена
	|							КОГДА ЕСТЬNULL(РеализацияОбороты.СтавкаНДС.Ставка, 0) = 10
	|								ТОГДА (ВЫРАЗИТЬ(РеализацияОбороты.КоличествоОборот * РеализацияОбороты.Партия.ЗакупочнаяЦена КАК ЧИСЛО(10, 2))) / 110 * 10
	|							ИНАЧЕ (ВЫРАЗИТЬ(РеализацияОбороты.КоличествоОборот * РеализацияОбороты.Партия.ЗакупочнаяЦена КАК ЧИСЛО(10, 2))) / 118 * 18
	|						КОНЕЦ
	|				ИНАЧЕ ВЫБОР
	|						КОГДА РеализацияОбороты.СуммаОборот - РеализацияОбороты.СебеСтоимостьОборот - РеализацияОбороты.СкидкаОборот > 0
	|							ТОГДА ВЫБОР
	|									КОГДА РеализацияОбороты.Товар.ID_77 = ""  13ZB   ""
	|										ТОГДА 0
	|									КОГДА РеализацияОбороты.Партия.Комиссия
	|										ТОГДА РеализацияОбороты.СебеСтоимостьОборот + (РеализацияОбороты.СуммаОборот - РеализацияОбороты.СебеСтоимостьОборот - РеализацияОбороты.СкидкаОборот) * &ПроцентМаржи
	|									КОГДА ЕСТЬNULL(РеализацияОбороты.СтавкаНДС.Ставка, 0) = 0
	|										ТОГДА РеализацияОбороты.СебеСтоимостьОборот + (РеализацияОбороты.СуммаОборот - РеализацияОбороты.СебеСтоимостьОборот - РеализацияОбороты.СкидкаОборот) * &ПроцентМаржи
	|									КОГДА ЕСТЬNULL(РеализацияОбороты.СтавкаНДС.Ставка, 0) = 10
	|										ТОГДА (ВЫРАЗИТЬ(РеализацияОбороты.СебеСтоимостьОборот + (РеализацияОбороты.СуммаОборот - РеализацияОбороты.СебеСтоимостьОборот - РеализацияОбороты.СкидкаОборот) * &ПроцентМаржи КАК ЧИСЛО(10, 2))) / 110 * 10
	|									ИНАЧЕ (ВЫРАЗИТЬ(РеализацияОбороты.СебеСтоимостьОборот + (РеализацияОбороты.СуммаОборот - РеализацияОбороты.СебеСтоимостьОборот - РеализацияОбороты.СкидкаОборот) * &ПроцентМаржи КАК ЧИСЛО(10, 2))) / 118 * 18
	|								КОНЕЦ
	|						ИНАЧЕ ВЫБОР
	|								КОГДА РеализацияОбороты.Товар.ID_77 = ""  13ZB   ""
	|									ТОГДА 0
	|								КОГДА РеализацияОбороты.Партия.Комиссия
	|									ТОГДА РеализацияОбороты.СебеСтоимостьОборот + (РеализацияОбороты.СуммаОборот - РеализацияОбороты.СебеСтоимостьОборот - РеализацияОбороты.СкидкаОборот) * 0.99
	|								КОГДА ЕСТЬNULL(РеализацияОбороты.СтавкаНДС.Ставка, 0) = 0
	|									ТОГДА РеализацияОбороты.СебеСтоимостьОборот + (РеализацияОбороты.СуммаОборот - РеализацияОбороты.СебеСтоимостьОборот - РеализацияОбороты.СкидкаОборот) * 0.99
	|								КОГДА ЕСТЬNULL(РеализацияОбороты.СтавкаНДС.Ставка, 0) = 10
	|									ТОГДА (ВЫРАЗИТЬ(РеализацияОбороты.СебеСтоимостьОборот + (РеализацияОбороты.СуммаОборот - РеализацияОбороты.СебеСтоимостьОборот - РеализацияОбороты.СкидкаОборот) * 0.99 КАК ЧИСЛО(10, 2))) / 110 * 10
	|								ИНАЧЕ (ВЫРАЗИТЬ(РеализацияОбороты.СебеСтоимостьОборот + (РеализацияОбороты.СуммаОборот - РеализацияОбороты.СебеСтоимостьОборот - РеализацияОбороты.СкидкаОборот) * 0.99 КАК ЧИСЛО(10, 2))) / 118 * 18
	|							КОНЕЦ
	|					КОНЕЦ
	|			КОНЕЦ КАК ЧИСЛО(10, 2))) КАК СебестоимостьБезНДС,
	|	ВЫБОР
	|		КОГДА РеализацияОбороты.Операция = ЗНАЧЕНИЕ(Перечисление.ТорговыеОперации.ВозвратОтПокупателя)
	|			ТОГДА ЕСТЬNULL(РеализацияОбороты.Регистратор.ДокументОснование.Номер, """")
	|		ИНАЧЕ """"
	|	КОНЕЦ КАК НомерВозврата,
	|	ВЫБОР
	|		КОГДА ТИПЗНАЧЕНИЯ(РеализацияОбороты.Регистратор.ДокументОснование) = ТИП(Документ.Чеки)
	|				И РеализацияОбороты.Регистратор.ДокументОснование <> ЗНАЧЕНИЕ(Документ.Чеки.ПустаяСсылка)
	|			ТОГДА НАЧАЛОПЕРИОДА(ВЫРАЗИТЬ(РеализацияОбороты.Регистратор.ДокументОснование КАК Документ.Чеки).Дата, ДЕНЬ)
	|		ИНАЧЕ НАЧАЛОПЕРИОДА(РеализацияОбороты.Период, ДЕНЬ)
	|	КОНЕЦ КАК ДатаОснования,
	|	ВЫБОР
	|		КОГДА РеализацияОбороты.Операция = ЗНАЧЕНИЕ(Перечисление.ТорговыеОперации.ВозвратОтПокупателя)
	|			ТОГДА РеализацияОбороты.Регистратор
	|		ИНАЧЕ ЗНАЧЕНИЕ(Документ.Чеки.ПустаяСсылка)
	|	КОНЕЦ КАК Регистратор
	|ПОМЕСТИТЬ втДанные
	|ИЗ
	|	РегистрНакопления.Реализация.Обороты(
	|			&НачалоПериода,
	|			&КонецПериода,
	|			Регистратор,
	|			(ТипОплаты = ЗНАЧЕНИЕ(Перечисление.ТипОплаты.БК)
	|				ИЛИ ТипОплаты = ЗНАЧЕНИЕ(Перечисление.ТипОплаты.Наличные))
	|				И (Операция = ЗНАЧЕНИЕ(Перечисление.ТорговыеОперации.Продажа)
	|					ИЛИ Операция = ЗНАЧЕНИЕ(Перечисление.ТорговыеОперации.ВозвратОтПокупателя))
	|				И (ККМ.ЗаводскойНомер = &ЗаводскойНомер
	|					ИЛИ &ЗаводскойНомер = """")) КАК РеализацияОбороты
	|ГДЕ
	|	ЕСТЬNULL(ВЫРАЗИТЬ(РеализацияОбороты.Регистратор.ДокументОснование КАК Документ.Заказ).ТипДоставки, НЕОПРЕДЕЛЕНО) <> ЗНАЧЕНИЕ(Перечисление.ТипДоставки.Партнеры)
	|	И ЕСТЬNULL(ВЫРАЗИТЬ(ВЫРАЗИТЬ(РеализацияОбороты.Регистратор.ДокументОснование КАК Документ.Чеки).ДокументОснование КАК Документ.ВозвратОтПокупателя).ДокументОснование.ТипДоставки, НЕОПРЕДЕЛЕНО) <> ЗНАЧЕНИЕ(Перечисление.ТипДоставки.Партнеры)
	|	И НЕ ЕСТЬNULL(РеализацияОбороты.Партия.Комиссия, ЛОЖЬ)
	|	И (ВЫРАЗИТЬ(РеализацияОбороты.ВсегоОборот КАК ЧИСЛО(10, 2))) <> 0
	|
	|СГРУППИРОВАТЬ ПО
	|	РеализацияОбороты.Организация.ИНН,
	|	ВЫБОР
	|		КОГДА РеализацияОбороты.Товар.ID_77 = ""  13ZB   ""
	|			ТОГДА ""Доставка""
	|		КОГДА РеализацияОбороты.Партия.Комиссия
	|			ТОГДА ""Комиссия""
	|		КОГДА ЕСТЬNULL(РеализацияОбороты.СтавкаНДС.Ставка, 0) = 0
	|			ТОГДА ""ТоварыБезНДС""
	|		КОГДА ЕСТЬNULL(РеализацияОбороты.СтавкаНДС.Ставка, 0) = 10
	|			ТОГДА ""Товары10""
	|		ИНАЧЕ ""Товары18""
	|	КОНЕЦ,
	|	РеализацияОбороты.ККМ.ЗаводскойНомер,
	|	ВЫБОР
	|		КОГДА РеализацияОбороты.Операция = ЗНАЧЕНИЕ(Перечисление.ТорговыеОперации.ВозвратОтПокупателя)
	|			ТОГДА ЕСТЬNULL(РеализацияОбороты.Регистратор.ДокументОснование.Номер, """")
	|		ИНАЧЕ """"
	|	КОНЕЦ,
	|	ВЫБОР
	|		КОГДА РеализацияОбороты.Операция = ЗНАЧЕНИЕ(Перечисление.ТорговыеОперации.ВозвратОтПокупателя)
	|			ТОГДА РеализацияОбороты.Регистратор
	|		ИНАЧЕ ЗНАЧЕНИЕ(Документ.Чеки.ПустаяСсылка)
	|	КОНЕЦ,
	|	НАЧАЛОПЕРИОДА(РеализацияОбороты.Период, ДЕНЬ),
	|	ВЫБОР
	|		КОГДА ТИПЗНАЧЕНИЯ(РеализацияОбороты.Регистратор.ДокументОснование) = ТИП(Документ.Чеки)
	|				И РеализацияОбороты.Регистратор.ДокументОснование <> ЗНАЧЕНИЕ(Документ.Чеки.ПустаяСсылка)
	|			ТОГДА НАЧАЛОПЕРИОДА(ВЫРАЗИТЬ(РеализацияОбороты.Регистратор.ДокументОснование КАК Документ.Чеки).Дата, ДЕНЬ)
	|		ИНАЧЕ НАЧАЛОПЕРИОДА(РеализацияОбороты.Период, ДЕНЬ)
	|	КОНЕЦ
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	втДанные.Фирма,
	|	втДанные.ДатаДокумента,
	|	втДанные.НаимККМ,
	|	втДанные.КодСпрНом,
	|	СУММА(втДанные.Количество) КАК Количество,
	|	СУММА(втДанные.СуммаЧека_БН) КАК СуммаЧека_БН,
	|	СУММА(втДанные.СуммаПоСтроке) КАК СуммаПоСтроке,
	|	СУММА(втДанные.СуммаНДС) КАК СуммаНДС,
	|	СУММА(втДанные.СебестоимостьБезНДС) КАК СебестоимостьБезНДС,
	|	ВЫБОР
	|		КОГДА Чеки.Ссылка ЕСТЬ NULL 
	|			ТОГДА """"
	|		ИНАЧЕ втДанные.НомерВозврата
	|	КОНЕЦ КАК НомерВозврата,
	|	ВЫБОР
	|		КОГДА Чеки.Ссылка ЕСТЬ NULL 
	|			ТОГДА втДанные.ДатаОснования
	|		ИНАЧЕ НАЧАЛОПЕРИОДА(Чеки.Дата, ДЕНЬ)
	|	КОНЕЦ КАК ДатаОснования,
	|	ВЫБОР
	|		КОГДА Чеки.Ссылка ЕСТЬ NULL 
	|			ТОГДА ЗНАЧЕНИЕ(документ.Чеки.ПустаяСсылка)
	|		ИНАЧЕ втДанные.Регистратор
	|	КОНЕЦ КАК Регистратор
	|ИЗ
	|	втДанные КАК втДанные
	|		ЛЕВОЕ СОЕДИНЕНИЕ Документ.Чеки КАК Чеки
	|		ПО (ВЫБОР
	|				КОГДА ТИПЗНАЧЕНИЯ(ВЫРАЗИТЬ(втДанные.Регистратор КАК Документ.Чеки).ДокументОснование) = ТИП(Документ.ВозвратОтПокупателя)
	|					ТОГДА ВЫРАЗИТЬ(втДанные.Регистратор.ДокументОснование КАК Документ.ВозвратОтПокупателя).ДокументОснование = Чеки.ДокументОснование
	|							И НАЧАЛОПЕРИОДА(втДанные.Регистратор.Дата, ДЕНЬ) <> НАЧАЛОПЕРИОДА(Чеки.Дата, ДЕНЬ)
	|							И Чеки.Проведен
	|				КОГДА ТИПЗНАЧЕНИЯ(ВЫРАЗИТЬ(втДанные.Регистратор КАК Документ.Чеки).ДокументОснование) = ТИП(Документ.Чеки)
	|					ТОГДА (ВЫРАЗИТЬ(втДанные.Регистратор.ДокументОснование КАК Документ.Чеки)) = Чеки.Ссылка
	|							И НАЧАЛОПЕРИОДА(втДанные.Регистратор.Дата, ДЕНЬ) <> НАЧАЛОПЕРИОДА(Чеки.Дата, ДЕНЬ)
	|							И Чеки.Проведен
	|				ИНАЧЕ ЛОЖЬ
	|			КОНЕЦ)
	|
	|СГРУППИРОВАТЬ ПО
	|	ВЫБОР
	|		КОГДА Чеки.Ссылка ЕСТЬ NULL 
	|			ТОГДА втДанные.ДатаОснования
	|		ИНАЧЕ НАЧАЛОПЕРИОДА(Чеки.Дата, ДЕНЬ)
	|	КОНЕЦ,
	|	ВЫБОР
	|		КОГДА Чеки.Ссылка ЕСТЬ NULL 
	|			ТОГДА ЗНАЧЕНИЕ(документ.Чеки.ПустаяСсылка)
	|		ИНАЧЕ втДанные.Регистратор
	|	КОНЕЦ,
	|	втДанные.Фирма,
	|	втДанные.ДатаДокумента,
	|	втДанные.НаимККМ,
	|	втДанные.КодСпрНом,
	|	ВЫБОР
	|		КОГДА Чеки.Ссылка ЕСТЬ NULL 
	|			ТОГДА """"
	|		ИНАЧЕ втДанные.НомерВозврата
	|	КОНЕЦ
	|
	|ИМЕЮЩИЕ
	|	СУММА(втДанные.СуммаПоСтроке) > 0";
	
	Запрос.УстановитьПараметр("НачалоПериода",НачалоДня(PeriodStart));
	Запрос.УстановитьПараметр("КонецПериода",КонецДня(PeriodEnd));
	Запрос.УстановитьПараметр("ЗаводскойНомер",KKMNumber);
	Запрос.УстановитьПараметр("ПроцентМаржи",0.9);
	
	Результат = Запрос.Выполнить().Выгрузить();
	
	Результат.Колонки.Добавить("ID_Возврата",Новый ОписаниеТипов("Строка",,Новый КвалификаторыСтроки(36)));
	Результат.Колонки.Добавить("id_Key",Новый ОписаниеТипов("Строка",,Новый КвалификаторыСтроки(66)));
	
	Для каждого строка из Результат цикл
		Если  ЗначениеЗаполнено(Строка.НомерВозврата) тогда
			строка.ID_Возврата = Строка(Строка.Регистратор.УникальныйИдентификатор());		
		КонецЕсли;
		строка.id_Key = строка.НаимККМ + " " + Формат(строка.ДатаДокумента,"ДФ=dd.MM.yyyy") + Формат(строка.ДатаОснования,"ДФ=dd.MM.yyyy")+строка.ID_Возврата;
	КонецЦикла;
	Результат.Колонки.Удалить("Регистратор");
	
	Возврат ЗначениеВСтрокуВнутр(Результат)
	
КонецФункции

Функция Accounting_GetConsignment(PeriodStart, PeriodEnd,DocumentNumber = неопределено,INN = неопределено)
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	ВЫБОР
	|		КОГДА Приходная.Отдел.ID_77 = ""    1ONG ""
	|			ТОГДА 1
	|		ИНАЧЕ 2
	|	КОНЕЦ КАК Отдел,
	|	Приходная.Клиент.Наименование КАК Поставщик,
	|	Приходная.Номер КАК НомерПриходнойНакл,
	|	НАЧАЛОПЕРИОДА(Приходная.Дата, ДЕНЬ) КАК ДатаПриходнойНакл,
	|	Приходная.Ссылка,
	|	СУММА(ПриходнаяТовары.Количество) КАК Количество,
	|	ЕСТЬNULL(ПриходнаяТовары.Партия.Комиссия, ЛОЖЬ) КАК Комиссия,
	|	Приходная.Клиент.ИНН КАК ИНН,
	|	Приходная.Клиент.Упрощенка КАК Упрощенец,
	|	ВЫБОР
	|		КОГДА Приходная.НомерСЧФ = """"
	|			ТОГДА Приходная.НомерОснования
	|		ИНАЧЕ Приходная.НомерСЧФ
	|	КОНЕЦ КАК НомерСФПоставщика,
	|	Приходная.НомерОснования,
	|	Приходная.ДатаОснования,
	|	386 КАК iddocdef,
	|	СУММА(ПриходнаяТовары.Сумма) КАК СуммаДокумента,
	|	СУММА(ПриходнаяТовары.СуммаНДС) КАК НДСДокумента,
	|	Приходная.СуммаПоставщика,
	|	Приходная.НДСПоставщика,
	|	Приходная.СуммаНДС10,
	|	Приходная.СуммаНДС20,
	|	Приходная.Сумма0 КАК СуммаТоваровБезНДС,
	|	Приходная.Сумма10 КАК СуммаТоваров10БезНДС,
	|	Приходная.Сумма20 КАК СуммаТоваров20БезНДС,
	|	Приходная.ДатаОплаты,
	|	ЕСТЬNULL(Приходная.Фирма.ИНН, ""7704865540/770401001"") КАК ИНН_Фирмы
	|ИЗ
	|	Документ.Приходная.Товары КАК ПриходнаяТовары
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Документ.Приходная КАК Приходная
	|		ПО ПриходнаяТовары.Ссылка = Приходная.Ссылка
	|ГДЕ
	|	Приходная.Проведен
	|	И Приходная.ВычНП
	|	И Приходная.Клиент.ID_77 <> ""  THGW   ""
	|	И НЕ Приходная.ВведенАвтоматическиПоПретензии
	|	И Приходная.ДатаОснования МЕЖДУ &ДатаНачала И &ДатаОкончания
	|	И ВЫБОР
	|			КОГДА &НомерОснования <> НЕОПРЕДЕЛЕНО
	|				ТОГДА Приходная.НомерОснования = &НомерОснования
	|			ИНАЧЕ ИСТИНА
	|		КОНЕЦ
	|	И ВЫБОР
	|			КОГДА &ИНН = """"""""
	|				ТОГДА ИСТИНА
	|			ИНАЧЕ Приходная.Фирма.ИНН ПОДОБНО &ИНН
	|		КОНЕЦ
	|
	|СГРУППИРОВАТЬ ПО
	|	Приходная.Ссылка,
	|	ЕСТЬNULL(ПриходнаяТовары.Партия.Комиссия, ЛОЖЬ),
	|	ВЫБОР
	|		КОГДА Приходная.Отдел.ID_77 = ""    1ONG ""
	|			ТОГДА 1
	|		ИНАЧЕ 2
	|	КОНЕЦ,
	|	Приходная.Клиент.Наименование,
	|	Приходная.Номер,
	|	НАЧАЛОПЕРИОДА(Приходная.Дата, ДЕНЬ),
	|	Приходная.Клиент.ИНН,
	|	Приходная.Клиент.Упрощенка,
	|	ВЫБОР
	|		КОГДА Приходная.НомерСЧФ = """"
	|			ТОГДА Приходная.НомерОснования
	|		ИНАЧЕ Приходная.НомерСЧФ
	|	КОНЕЦ,
	|	Приходная.НомерОснования,
	|	Приходная.ДатаОснования,
	|	Приходная.СуммаПоставщика,
	|	Приходная.НДСПоставщика,
	|	Приходная.СуммаНДС10,
	|	Приходная.СуммаНДС20,
	|	Приходная.Сумма0,
	|	Приходная.Сумма10,
	|	Приходная.Сумма20,
	|	Приходная.ДатаОплаты,
	|	ЕСТЬNULL(Приходная.Фирма.ИНН, ""7704865540/770401001"")";
	Запрос.УстановитьПараметр("ДатаНачала",НачалоДня(PeriodStart));
	Запрос.УстановитьПараметр("ДатаОкончания",КонецДня(PeriodEnd));
	Запрос.УстановитьПараметр("НомерОснования", ?(ЗначениеЗаполнено(DocumentNumber),DocumentNumber,Неопределено));
	Запрос.УстановитьПараметр("ИНН",?(ЗначениеЗаполнено(INN),INN+"%",""));
	
	Результат = Запрос.Выполнить().Выгрузить();
	
	Результат.Колонки.Добавить("iddoc",Новый ОписаниеТипов("Строка",,Новый КвалификаторыСтроки(36)));
	Для каждого строка из Результат цикл
		строка.iddoc = Строка(Строка.Ссылка.УникальныйИдентификатор());	
	КонецЦикла;
	
	Результат.Колонки.Удалить("Ссылка");
	
	Возврат ЗначениеВСтрокуВнутр(Результат);
	
КонецФункции

Функция Accounting_SalesRevise(PeriodStart, PeriodEnd, ReportType, KKMNumber, INN = "")
	
	Если СтрНайти("12",Строка(ReportType)) = 0 тогда
		Возврат Новый ТаблицаЗначений;
	КонецЕсли;
	
	Запрос = Новый Запрос;
	Запрос.Текст = ПолучитьТекстЗапроса(ReportType); 
	Запрос.УстановитьПараметр("НачалоПериода",НачалоДня(PeriodStart));
	Запрос.УстановитьПараметр("КонецПериода",КонецДня(PeriodEnd));
	Запрос.УстановитьПараметр("ЗаводскойНомер",KKMNumber);
	Запрос.УстановитьПараметр("ПроцентМаржи",0.9);
	Запрос.УстановитьПараметр("ИНН",?(ЗначениеЗаполнено(INN),INN+"%",""));
	Результат = Запрос.Выполнить().Выгрузить();
	Если ReportType = 2 тогда
		Результат.Колонки.Добавить("ID_Возврата",Новый ОписаниеТипов("Строка",,Новый КвалификаторыСтроки(36)));
		Для каждого строка из Результат цикл
			Строка.ID_Возврата = Строка(Строка.Регистратор.УникальныйИдентификатор());	
		КонецЦикла;
		Результат.Колонки.Удалить("Регистратор");
	КонецЕсли;
			
	Возврат ЗначениеВСтрокуВнутр(Результат);
	
КонецФункции

Функция ПолучитьТекстЗапроса(ReportType)
	//Тип отчета - 1 реализация, 2 - возвраты	
	Если ReportType = 1 тогда
		Возврат
		"ВЫБРАТЬ
		|	""ККМ"" КАК IDDOC,
		|	0 КАК DOCNO,
		|	NULL КАК ДатаДок,
		|	РеализацияОбороты.ККМ.Наименование КАК Покупатель,
		|	РеализацияОбороты.Организация.ИНН КАК ИНН,
		|	РеализацияОбороты.ККМ.ЗаводскойНомер КАК НаимККМ,
		|	РеализацияОбороты.Организация.Наименование КАК Подразделение,
		|	""Наличные"" КАК ТипОплаты,
		|	НАЧАЛОПЕРИОДА(РеализацияОбороты.Период, ДЕНЬ) КАК ДатаПродажи,
		|	СУММА(ВЫБОР
		|			КОГДА РеализацияОбороты.ТипОплаты = ЗНАЧЕНИЕ(Перечисление.ТипОплаты.БК)
		|				ТОГДА ВЫРАЗИТЬ(РеализацияОбороты.ВсегоОборот КАК ЧИСЛО(10, 2))
		|			ИНАЧЕ 0
		|		КОНЕЦ) КАК СуммаБК,
		|	СУММА(ВЫРАЗИТЬ(РеализацияОбороты.ВсегоОборот КАК ЧИСЛО(10, 2))) КАК СуммаПоСтроке,
		|	СУММА(ВЫРАЗИТЬ(ВЫБОР
		|				КОГДА РеализацияОбороты.Товар.ID_77 = ""  13ZB   ""
		|					ТОГДА (ВЫРАЗИТЬ(РеализацияОбороты.ВсегоОборот КАК ЧИСЛО(10, 2))) / 118 * 18
		|				КОГДА РеализацияОбороты.Партия.Комиссия
		|					ТОГДА (ВЫРАЗИТЬ(РеализацияОбороты.ВсегоОборот КАК ЧИСЛО(10, 2))) / 110 * 10
		|				КОГДА ЕСТЬNULL(РеализацияОбороты.СтавкаНДС.Ставка, 0) = 0
		|					ТОГДА 0
		|				КОГДА ЕСТЬNULL(РеализацияОбороты.СтавкаНДС.Ставка, 0) = 10
		|					ТОГДА (ВЫРАЗИТЬ(РеализацияОбороты.ВсегоОборот КАК ЧИСЛО(10, 2))) / 110 * 10
		|				ИНАЧЕ (ВЫРАЗИТЬ(РеализацияОбороты.ВсегоОборот КАК ЧИСЛО(10, 2))) / 118 * 18
		|			КОНЕЦ КАК ЧИСЛО(10, 2))) КАК СуммаНДС,
		|	СУММА(ВЫРАЗИТЬ(ВЫБОР
		|				КОГДА ПОДСТРОКА(РеализацияОбороты.Партия.Фирма.ИНН,1,10) = ПОДСТРОКА(РеализацияОбороты.ККМ.Фирма.ИНН,1,10)
		|					ТОГДА ВЫБОР
		|							КОГДА РеализацияОбороты.Товар.ID_77 = ""  13ZB   ""
		|								ТОГДА 0
		|							КОГДА РеализацияОбороты.Партия.Комиссия
		|								ТОГДА РеализацияОбороты.КоличествоОборот * РеализацияОбороты.Партия.ЗакупочнаяЦена
		|							КОГДА ЕСТЬNULL(РеализацияОбороты.СтавкаНДС.Ставка, 0) = 0
		|								ТОГДА РеализацияОбороты.КоличествоОборот * РеализацияОбороты.Партия.ЗакупочнаяЦена
		|							КОГДА ЕСТЬNULL(РеализацияОбороты.СтавкаНДС.Ставка, 0) = 10
		|								ТОГДА (ВЫРАЗИТЬ(РеализацияОбороты.КоличествоОборот * РеализацияОбороты.Партия.ЗакупочнаяЦена КАК ЧИСЛО(10, 2))) / 110 * 10
		|							ИНАЧЕ (ВЫРАЗИТЬ(РеализацияОбороты.КоличествоОборот * РеализацияОбороты.Партия.ЗакупочнаяЦена КАК ЧИСЛО(10, 2))) / 118 * 18
		|						КОНЕЦ
		|				ИНАЧЕ ВЫБОР
		|						КОГДА РеализацияОбороты.СуммаОборот - РеализацияОбороты.СебеСтоимостьОборот - РеализацияОбороты.СкидкаОборот > 0
		|							ТОГДА ВЫБОР
		|									КОГДА РеализацияОбороты.Товар.ID_77 = ""  13ZB   ""
		|										ТОГДА 0
		|									КОГДА РеализацияОбороты.Партия.Комиссия
		|										ТОГДА РеализацияОбороты.СебеСтоимостьОборот + (РеализацияОбороты.СуммаОборот - РеализацияОбороты.СебеСтоимостьОборот - РеализацияОбороты.СкидкаОборот) * &ПроцентМаржи
		|									КОГДА ЕСТЬNULL(РеализацияОбороты.СтавкаНДС.Ставка, 0) = 0
		|										ТОГДА РеализацияОбороты.СебеСтоимостьОборот + (РеализацияОбороты.СуммаОборот - РеализацияОбороты.СебеСтоимостьОборот - РеализацияОбороты.СкидкаОборот) * &ПроцентМаржи
		|									КОГДА ЕСТЬNULL(РеализацияОбороты.СтавкаНДС.Ставка, 0) = 10
		|										ТОГДА (ВЫРАЗИТЬ(РеализацияОбороты.СебеСтоимостьОборот + (РеализацияОбороты.СуммаОборот - РеализацияОбороты.СебеСтоимостьОборот - РеализацияОбороты.СкидкаОборот) * &ПроцентМаржи КАК ЧИСЛО(10, 2))) / 110 * 10
		|									ИНАЧЕ (ВЫРАЗИТЬ(РеализацияОбороты.СебеСтоимостьОборот + (РеализацияОбороты.СуммаОборот - РеализацияОбороты.СебеСтоимостьОборот - РеализацияОбороты.СкидкаОборот) * &ПроцентМаржи КАК ЧИСЛО(10, 2))) / 118 * 18
		|								КОНЕЦ
		|						ИНАЧЕ ВЫБОР
		|								КОГДА РеализацияОбороты.Товар.ID_77 = ""  13ZB   ""
		|									ТОГДА 0
		|								КОГДА РеализацияОбороты.Партия.Комиссия
		|									ТОГДА РеализацияОбороты.СебеСтоимостьОборот + (РеализацияОбороты.СуммаОборот - РеализацияОбороты.СебеСтоимостьОборот - РеализацияОбороты.СкидкаОборот) * 0.99
		|								КОГДА ЕСТЬNULL(РеализацияОбороты.СтавкаНДС.Ставка, 0) = 0
		|									ТОГДА РеализацияОбороты.СебеСтоимостьОборот + (РеализацияОбороты.СуммаОборот - РеализацияОбороты.СебеСтоимостьОборот - РеализацияОбороты.СкидкаОборот) * 0.99
		|								КОГДА ЕСТЬNULL(РеализацияОбороты.СтавкаНДС.Ставка, 0) = 10
		|									ТОГДА (ВЫРАЗИТЬ(РеализацияОбороты.СебеСтоимостьОборот + (РеализацияОбороты.СуммаОборот - РеализацияОбороты.СебеСтоимостьОборот - РеализацияОбороты.СкидкаОборот) * 0.99 КАК ЧИСЛО(10, 2))) / 110 * 10
		|								ИНАЧЕ (ВЫРАЗИТЬ(РеализацияОбороты.СебеСтоимостьОборот + (РеализацияОбороты.СуммаОборот - РеализацияОбороты.СебеСтоимостьОборот - РеализацияОбороты.СкидкаОборот) * 0.99 КАК ЧИСЛО(10, 2))) / 118 * 18
		|							КОНЕЦ
		|					КОНЕЦ
		|			КОНЕЦ КАК ЧИСЛО(10, 2))) КАК СебестоимостьБезНДС
		|ИЗ
		|	РегистрНакопления.Реализация.Обороты(
		|			&НачалоПериода,
		|			&КонецПериода,
		|			Регистратор,
		|			(ТипОплаты = ЗНАЧЕНИЕ(Перечисление.ТипОплаты.БК)
		|				ИЛИ ТипОплаты = ЗНАЧЕНИЕ(Перечисление.ТипОплаты.Наличные))
		|				И Операция = ЗНАЧЕНИЕ(Перечисление.ТорговыеОперации.Продажа)
		|				И (ККМ.ЗаводскойНомер = &ЗаводскойНомер или &ЗаводскойНомер = """")
		|				И ВЫБОР
		|					КОГДА &ИНН = """"
		|						ТОГДА ИСТИНА
		|					ИНАЧЕ Организация.ИНН ПОДОБНО &ИНН
		|				КОНЕЦ) КАК РеализацияОбороты
		|ГДЕ
		|	ЕСТЬNULL(ВЫРАЗИТЬ(РеализацияОбороты.Регистратор.ДокументОснование КАК Документ.Заказ).ТипДоставки, НЕОПРЕДЕЛЕНО) <> ЗНАЧЕНИЕ(Перечисление.ТипДоставки.Партнеры)
		|	И ЕСТЬNULL(ВЫРАЗИТЬ(ВЫРАЗИТЬ(РеализацияОбороты.Регистратор.ДокументОснование КАК Документ.Чеки).ДокументОснование КАК Документ.ВозвратОтПокупателя).ДокументОснование.ТипДоставки, НЕОПРЕДЕЛЕНО) <> ЗНАЧЕНИЕ(Перечисление.ТипДоставки.Партнеры)
		|	И НЕ ЕСТЬNULL(РеализацияОбороты.Партия.Комиссия, ЛОЖЬ)
		|	И (ВЫРАЗИТЬ(РеализацияОбороты.ВсегоОборот КАК ЧИСЛО(10, 2))) <> 0
		|
		|СГРУППИРОВАТЬ ПО
		|	РеализацияОбороты.ККМ.ЗаводскойНомер,
		|	НАЧАЛОПЕРИОДА(РеализацияОбороты.Период, ДЕНЬ),
		|	РеализацияОбороты.Организация.ИНН,
		|	РеализацияОбороты.ККМ.Наименование,
		|	РеализацияОбороты.Организация.Наименование";
	ИначеЕсли ReportType = 2 тогда
		Возврат
		"ВЫБРАТЬ
		|	РеализацияОбороты.Организация.ИНН КАК Фирма,
		|	ВЫБОР
		|		КОГДА РеализацияОбороты.Операция = ЗНАЧЕНИЕ(Перечисление.ТорговыеОперации.ВозвратОтПокупателя)
		|			ТОГДА РеализацияОбороты.Регистратор
		|		ИНАЧЕ ЗНАЧЕНИЕ(Документ.Чеки.ПустаяСсылка)
		|	КОНЕЦ КАК Регистратор,
		|	ВЫБОР
		|		КОГДА РеализацияОбороты.Операция = ЗНАЧЕНИЕ(Перечисление.ТорговыеОперации.ВозвратОтПокупателя)
		|			ТОГДА ЕСТЬNULL(РеализацияОбороты.Регистратор.ДокументОснование.Номер, """")
		|		ИНАЧЕ """"
		|	КОНЕЦ КАК НомерВозврата,
		|	РеализацияОбороты.ККМ.ЗаводскойНомер КАК НаимККМ,
		|	НАЧАЛОПЕРИОДА(РеализацияОбороты.Период, ДЕНЬ) КАК ДатаДокумента,
		|	-СУММА(ВЫРАЗИТЬ(РеализацияОбороты.ВсегоОборот КАК ЧИСЛО(10, 2))) КАК СуммаПоСтроке,
		|	-СУММА(ВЫРАЗИТЬ(ВЫБОР
		|				КОГДА РеализацияОбороты.Товар.ID_77 = ""  13ZB   ""
		|					ТОГДА ВЫРАЗИТЬ(РеализацияОбороты.ВсегоОборот КАК ЧИСЛО(10, 2))
		|				ИНАЧЕ 0
		|			КОНЕЦ КАК ЧИСЛО(10, 2))) КАК СуммаДоставки,
		|	-СУММА(ВЫРАЗИТЬ(ВЫБОР
		|				КОГДА ПОДСТРОКА(РеализацияОбороты.Партия.Фирма.ИНН,1,10) = ПОДСТРОКА(РеализацияОбороты.ККМ.Фирма.ИНН,1,10)
		|					ТОГДА ВЫБОР
		|							КОГДА РеализацияОбороты.Товар.ID_77 = ""  13ZB   ""
		|								ТОГДА 0
		|							КОГДА РеализацияОбороты.Партия.Комиссия
		|								ТОГДА РеализацияОбороты.КоличествоОборот * РеализацияОбороты.Партия.ЗакупочнаяЦена
		|							КОГДА ЕСТЬNULL(РеализацияОбороты.СтавкаНДС.Ставка, 0) = 0
		|								ТОГДА РеализацияОбороты.КоличествоОборот * РеализацияОбороты.Партия.ЗакупочнаяЦена
		|							КОГДА ЕСТЬNULL(РеализацияОбороты.СтавкаНДС.Ставка, 0) = 10
		|								ТОГДА (ВЫРАЗИТЬ(РеализацияОбороты.КоличествоОборот * РеализацияОбороты.Партия.ЗакупочнаяЦена КАК ЧИСЛО(10, 2))) / 110 * 10
		|							ИНАЧЕ (ВЫРАЗИТЬ(РеализацияОбороты.КоличествоОборот * РеализацияОбороты.Партия.ЗакупочнаяЦена КАК ЧИСЛО(10, 2))) / 118 * 18
		|						КОНЕЦ
		|				ИНАЧЕ ВЫБОР
		|						КОГДА РеализацияОбороты.СуммаОборот - РеализацияОбороты.СебеСтоимостьОборот - РеализацияОбороты.СкидкаОборот > 0
		|							ТОГДА ВЫБОР
		|									КОГДА РеализацияОбороты.Товар.ID_77 = ""  13ZB   ""
		|										ТОГДА 0
		|									КОГДА РеализацияОбороты.Партия.Комиссия
		|										ТОГДА РеализацияОбороты.СебеСтоимостьОборот + (РеализацияОбороты.СуммаОборот - РеализацияОбороты.СебеСтоимостьОборот - РеализацияОбороты.СкидкаОборот) * &ПроцентМаржи
		|									КОГДА ЕСТЬNULL(РеализацияОбороты.СтавкаНДС.Ставка, 0) = 0
		|										ТОГДА РеализацияОбороты.СебеСтоимостьОборот + (РеализацияОбороты.СуммаОборот - РеализацияОбороты.СебеСтоимостьОборот - РеализацияОбороты.СкидкаОборот) * &ПроцентМаржи
		|									КОГДА ЕСТЬNULL(РеализацияОбороты.СтавкаНДС.Ставка, 0) = 10
		|										ТОГДА (ВЫРАЗИТЬ(РеализацияОбороты.СебеСтоимостьОборот + (РеализацияОбороты.СуммаОборот - РеализацияОбороты.СебеСтоимостьОборот - РеализацияОбороты.СкидкаОборот) * &ПроцентМаржи КАК ЧИСЛО(10, 2))) / 110 * 10
		|									ИНАЧЕ (ВЫРАЗИТЬ(РеализацияОбороты.СебеСтоимостьОборот + (РеализацияОбороты.СуммаОборот - РеализацияОбороты.СебеСтоимостьОборот - РеализацияОбороты.СкидкаОборот) * &ПроцентМаржи КАК ЧИСЛО(10, 2))) / 118 * 18
		|								КОНЕЦ
		|						ИНАЧЕ ВЫБОР
		|								КОГДА РеализацияОбороты.Товар.ID_77 = ""  13ZB   ""
		|									ТОГДА 0
		|								КОГДА РеализацияОбороты.Партия.Комиссия
		|									ТОГДА РеализацияОбороты.СебеСтоимостьОборот + (РеализацияОбороты.СуммаОборот - РеализацияОбороты.СебеСтоимостьОборот - РеализацияОбороты.СкидкаОборот) * 0.99
		|								КОГДА ЕСТЬNULL(РеализацияОбороты.СтавкаНДС.Ставка, 0) = 0
		|									ТОГДА РеализацияОбороты.СебеСтоимостьОборот + (РеализацияОбороты.СуммаОборот - РеализацияОбороты.СебеСтоимостьОборот - РеализацияОбороты.СкидкаОборот) * 0.99
		|								КОГДА ЕСТЬNULL(РеализацияОбороты.СтавкаНДС.Ставка, 0) = 10
		|									ТОГДА (ВЫРАЗИТЬ(РеализацияОбороты.СебеСтоимостьОборот + (РеализацияОбороты.СуммаОборот - РеализацияОбороты.СебеСтоимостьОборот - РеализацияОбороты.СкидкаОборот) * 0.99 КАК ЧИСЛО(10, 2))) / 110 * 10
		|								ИНАЧЕ (ВЫРАЗИТЬ(РеализацияОбороты.СебеСтоимостьОборот + (РеализацияОбороты.СуммаОборот - РеализацияОбороты.СебеСтоимостьОборот - РеализацияОбороты.СкидкаОборот) * 0.99 КАК ЧИСЛО(10, 2))) / 118 * 18
		|							КОНЕЦ
		|					КОНЕЦ
		|			КОНЕЦ КАК ЧИСЛО(10, 2))) КАК СебестоимостьБезНДС
		|ПОМЕСТИТЬ ВТ1
		|ИЗ
		|	РегистрНакопления.Реализация.Обороты(
		|			&НачалоПериода,
		|			&КонецПериода,
		|			Регистратор,
		|			(ТипОплаты = ЗНАЧЕНИЕ(Перечисление.ТипОплаты.БК)
		|				ИЛИ ТипОплаты = ЗНАЧЕНИЕ(Перечисление.ТипОплаты.Наличные))
		|				И (Операция = ЗНАЧЕНИЕ(Перечисление.ТорговыеОперации.Продажа)
		|					ИЛИ Операция = ЗНАЧЕНИЕ(Перечисление.ТорговыеОперации.ВозвратОтПокупателя))
		|				И (ККМ.ЗаводскойНомер = &ЗаводскойНомер или &ЗаводскойНомер = """")
		|				И Операция = ЗНАЧЕНИЕ(Перечисление.ТорговыеОперации.ВозвратОтПокупателя)
		|				И ВЫБОР
		|					КОГДА &ИНН = """"
		|						ТОГДА ИСТИНА
		|					ИНАЧЕ Организация.ИНН Подобно (&ИНН)
		|				КОНЕЦ) КАК РеализацияОбороты
		|ГДЕ
		|	ЕСТЬNULL(ВЫРАЗИТЬ(РеализацияОбороты.Регистратор.ДокументОснование КАК Документ.Заказ).ТипДоставки, НЕОПРЕДЕЛЕНО) <> ЗНАЧЕНИЕ(Перечисление.ТипДоставки.Партнеры)
		|	И ЕСТЬNULL(ВЫРАЗИТЬ(ВЫРАЗИТЬ(РеализацияОбороты.Регистратор.ДокументОснование КАК Документ.Чеки).ДокументОснование КАК Документ.ВозвратОтПокупателя).ДокументОснование.ТипДоставки, НЕОПРЕДЕЛЕНО) <> ЗНАЧЕНИЕ(Перечисление.ТипДоставки.Партнеры)
		|	И НЕ ЕСТЬNULL(РеализацияОбороты.Партия.Комиссия, ЛОЖЬ)
		|	И (ВЫРАЗИТЬ(РеализацияОбороты.ВсегоОборот КАК ЧИСЛО(10, 2))) <> 0
		|
		|СГРУППИРОВАТЬ ПО
		|	РеализацияОбороты.Организация.ИНН,
		|	РеализацияОбороты.ККМ.ЗаводскойНомер,
		|	ВЫБОР
		|		КОГДА РеализацияОбороты.Операция = ЗНАЧЕНИЕ(Перечисление.ТорговыеОперации.ВозвратОтПокупателя)
		|			ТОГДА ЕСТЬNULL(РеализацияОбороты.Регистратор.ДокументОснование.Номер, """")
		|		ИНАЧЕ """"
		|	КОНЕЦ,
		|	ВЫБОР
		|		КОГДА РеализацияОбороты.Операция = ЗНАЧЕНИЕ(Перечисление.ТорговыеОперации.ВозвратОтПокупателя)
		|			ТОГДА РеализацияОбороты.Регистратор
		|		ИНАЧЕ ЗНАЧЕНИЕ(Документ.Чеки.ПустаяСсылка)
		|	КОНЕЦ,
		|	НАЧАЛОПЕРИОДА(РеализацияОбороты.Период, ДЕНЬ)
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	ВТ1.Фирма,
		|	ВТ1.Регистратор,
		|	ВТ1.НомерВозврата,
		|	ВТ1.НаимККМ,
		|	ВТ1.ДатаДокумента,
		|	ВТ1.СуммаДоставки КАК СуммаДоставки,
		|	(ВТ1.СуммаПоСтроке - ВТ1.СуммаДоставки) КАК СуммаВозврата,
		|	ВТ1.СуммаПоСтроке КАК СуммаРКО,
		|	ВТ1.СебестоимостьБезНДС КАК Себестоимость_7
		|ИЗ
		|	ВТ1 КАК ВТ1";  		
	КонецЕсли;
	
КонецФункции

Функция Accounting_ConsignmentRevise(PeriodStart, PeriodEnd, INN = "")
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	Приходная.Клиент.Наименование КАК Поставщик,
	|	Приходная.Номер КАК НомерПриходнойНакл,
	|	Приходная.Дата КАК ДатаПриходнойНакл,
	|	""                                    "" КАК iddoc,
	|	Приходная.ДатаОплаты,
	|	Приходная.НомерОснования,
	|	Приходная.ДатаОснования,
	|	СУММА(ПриходнаяТовары.Сумма) КАК СуммаДокумента,
	|	СУММА(ПриходнаяТовары.СуммаНДС) КАК НДСДокумента,
	|	Приходная.СуммаПоставщика,
	|	Приходная.НДСПоставщика,
	|	Приходная.Ссылка
	|ИЗ
	|	Документ.Приходная.Товары КАК ПриходнаяТовары
	|		ЛЕВОЕ СОЕДИНЕНИЕ Документ.Приходная КАК Приходная
	|		ПО ПриходнаяТовары.Ссылка = Приходная.Ссылка
	|ГДЕ
	|	Приходная.Проведен
	|	И Приходная.ВычНП
	|	И Приходная.Клиент.ID_77 <> ""  THGW   ""
	|	И НЕ Приходная.ВведенАвтоматическиПоПретензии
	|	И Приходная.ДатаОснования МЕЖДУ &ДатаНачала И &ДатаОкончания
	|	И Приходная.Сумма0 + Приходная.Сумма10 + Приходная.Сумма20 > 0
	|	И (Приходная.Фирма.ИНН ПОДОБНО &ИНН
	|			ИЛИ &ИНН = """")
	|
	|СГРУППИРОВАТЬ ПО
	|	Приходная.Ссылка,
	|	Приходная.Клиент.Наименование,
	|	Приходная.Номер,
	|	Приходная.Дата,
	|	Приходная.ДатаОплаты,
	|	Приходная.НомерОснования,
	|	Приходная.ДатаОснования,
	|	Приходная.СуммаПоставщика,
	|	Приходная.НДСПоставщика
	|";
	Запрос.УстановитьПараметр("ДатаНачала",НачалоДня(PeriodStart));
	Запрос.УстановитьПараметр("ДатаОкончания",КонецДня(PeriodEnd));
	Запрос.УстановитьПараметр("ИНН", INN);
	
	Результат = Запрос.Выполнить().Выгрузить();
	
//	Результат.Колонки.Вставить(3,"iddoc",Новый ОписаниеТипов("Строка",,Новый КвалификаторыСтроки(36)));
	Для каждого строка из Результат цикл
		строка.iddoc = Строка(Строка.Ссылка.УникальныйИдентификатор());	
	КонецЦикла;
	
	Результат.Колонки.Удалить("Ссылка");
	
	Возврат ЗначениеВСтрокуВнутр(Результат);

	
КонецФункции

Функция Pharmacy_SendPromoCode(PromoRequest)
	
	Данные = ЗначениеИзСтрокиВнутр(PromoRequest);
	
	Если ТипЗнч(Данные) = Тип("Структура") и Данные.Свойство("Телефон")
		и Данные.Свойство("Документ") и Данные.Свойство("Дата") и Данные.Свойство("Аптека") тогда
		Возврат ОбщийМодульВебСервисы.ОтправитьСМСПромо(Данные);
	Иначе 
		Возврат Ложь;
	КонецЕсли;
	
КонецФункции