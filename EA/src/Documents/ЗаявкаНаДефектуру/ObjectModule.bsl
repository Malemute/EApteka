Процедура ЗаполнитьНаСервере() Экспорт
	
	Запрос = Новый Запрос;
//	Запрос.УстановитьПараметр("Дата", Дата);
	Запрос.УстановитьПараметр("Склад", Склад);
	Запрос.УстановитьПараметр("Регистратор", Ссылка);
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	Товары.Товар КАК Товар,
		|	СУММА(Товары.Количество) КАК Количество
		|ИЗ
		|	(ВЫБРАТЬ
		|		ДефектураОстатки.Товар КАК Товар,
		|		ДефектураОстатки.КоличествоОстаток КАК Количество
		|	ИЗ
		|		РегистрНакопления.Дефектура.Остатки(
		|				,
		|				Склад = &Склад
		|					И Заказ = ЗНАЧЕНИЕ(Документ.Заказ.ПустаяСсылка)
		|					И Поставщик = ЗНАЧЕНИЕ(Справочник.Контрагенты.ПустаяСсылка)) КАК ДефектураОстатки
		|	
		|	ОБЪЕДИНИТЬ ВСЕ
		|	
		|	ВЫБРАТЬ
		|		ДефектураОбороты.Товар,
		|		ДефектураОбороты.КоличествоРасход
		|	ИЗ
		|		РегистрНакопления.Дефектура.Обороты(, , Авто, ) КАК ДефектураОбороты
		|	ГДЕ
		|		ДефектураОбороты.Регистратор = &Регистратор) КАК Товары
		|
		|СГРУППИРОВАТЬ ПО
		|	Товары.Товар";
		
	Товары.Загрузить(Запрос.Выполнить().Выгрузить());

КонецПроцедуры

Процедура ОбработкаПроведения(Отказ, РежимПроведения)

	Запрос = Новый Запрос;
	Запрос.МенеджерВременныхТаблиц = Новый МенеджерВременныхТаблиц;
	Запрос.УстановитьПараметр("Ссылка", ЭтотОбъект.Ссылка);
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	ВЫБОР
		|		КОГДА ЗаявкаНаДефектуруТовары.Ссылка.ТипЗаявки = ЗНАЧЕНИЕ(Перечисление.ТипыЗаявокНаДефектуру.ОформлениеПотребности)
		|			ТОГДА ЗНАЧЕНИЕ(ВиддвиженияНакопления.Приход)
		|		ИНАЧЕ ЗНАЧЕНИЕ(ВиддвиженияНакопления.Расход)
		|	КОНЕЦ КАК ВидДвижения,
		|	ЗаявкаНаДефектуруТовары.Ссылка.Дата КАК Период,
		|	ЗаявкаНаДефектуруТовары.Ссылка.Склад,
		|	ЗаявкаНаДефектуруТовары.Товар,
		|	ЗаявкаНаДефектуруТовары.Количество
		|ПОМЕСТИТЬ ВТ_Товары
		|ИЗ
		|	Документ.ЗаявкаНаДефектуру.Товары КАК ЗаявкаНаДефектуруТовары
		|ГДЕ
		|	ЗаявкаНаДефектуруТовары.Ссылка = &Ссылка
//		|	И ЗаявкаНаДефектуруТовары.Количество > 0
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	ВТ_Товары.ВидДвижения,
		|	ВТ_Товары.Период,
		|	ВТ_Товары.Склад,
		|	ВТ_Товары.Товар,
		|	ВТ_Товары.Количество
		|ИЗ
		|	ВТ_Товары КАК ВТ_Товары";

	Движения.Дефектура.Загрузить(Запрос.Выполнить().Выгрузить());
	Движения.Дефектура.Записывать = Истина;
	Движения.Записать();
	
	Если ЭтотОбъект.ТипЗаявки = Перечисления.ТипыЗаявокНаДефектуру.АннулированиеПотребности Тогда
		// Проверим образовался ли отрицательный остаток

		Запрос.Текст =
			"ВЫБРАТЬ
			|	Остатки.Товар КАК Товар,
			|	ПРЕДСТАВЛЕНИЕССЫЛКИ(Остатки.Товар) КАК ТоварПредставление,
			|	-Остатки.КоличествоОстаток КАК Дефецит
			|ИЗ
			|	РегистрНакопления.Дефектура.Остатки(
			|			,
			|			Товар В
			|				(ВЫБРАТЬ
			|					ВТ_Товары.Товар КАК Товар
			|				ИЗ
			|					ВТ_Товары КАК ВТ_Товары)
			|			И Заказ = ЗНАЧЕНИЕ(Документ.Заказ.ПустаяСсылка)
			|			И КлючСвязи = """"
			|			И Поставщик = ЗНАЧЕНИЕ(Справочник.Контрагенты.ПустаяСсылка)
			|			И ЦенаЗакупки = 0) КАК Остатки
			|ГДЕ
			|	Остатки.КоличествоОстаток < 0";

			РезультатЗапроса = Запрос.Выполнить();
			Если Не РезультатЗапроса.Пустой() Тогда

				Отказ = Истина;
				ВыборкаОшибки = РезультатЗапроса.Выбрать();
				Пока ВыборкаОшибки.Следующий() Цикл
					Сообщение = Новый СообщениеПользователю;
					Сообщение.Текст = "Товара " + ВыборкаОшибки.ТоварПредставление + " недостаточно в количестве " + ВыборкаОшибки.Дефецит + " шт.";
					Сообщение.Сообщить();
				КонецЦикла;

			КонецЕсли;

	КонецЕсли; 

КонецПроцедуры

Процедура ОбработкаУдаленияПроведения(Отказ)
	
	Если ЭтотОбъект.ТипЗаявки = Перечисления.ТипыЗаявокНаДефектуру.ОформлениеПотребности Тогда

		Запрос = Новый Запрос;
		
		ГраницаКонтроля = Новый Граница(МоментВремени(), ВидГраницы.Включая);
		Запрос.УстановитьПараметр("МоментВремени", ГраницаКонтроля);
		Запрос.УстановитьПараметр("Склад", ЭтотОбъект.Склад);
		Запрос.УстановитьПараметр("Ссылка", ЭтотОбъект.Ссылка);

		Запрос.Текст = 
			"ВЫБРАТЬ РАЗЛИЧНЫЕ
			|	ЗаявкаНаДефектуруТовары.Товар,
			|	СУММА(ЗаявкаНаДефектуруТовары.Количество) КАК Количество
			|ПОМЕСТИТЬ ВТ_Товары
			|ИЗ
			|	Документ.ЗаявкаНаДефектуру.Товары КАК ЗаявкаНаДефектуруТовары
			|ГДЕ
			|	ЗаявкаНаДефектуруТовары.Ссылка.Ссылка = &Ссылка
			|
			|СГРУППИРОВАТЬ ПО
			|	ЗаявкаНаДефектуруТовары.Товар
			|;
			|
			|////////////////////////////////////////////////////////////////////////////////
			|ВЫБРАТЬ
			|	ВТ_Товары.Товар.Наименование КАК Товар,
			|	ЕСТЬNULL(ДефектураОстатки.КоличествоОстаток, 0) - ВТ_Товары.Количество КАК Количество
			|ИЗ
			|	ВТ_Товары КАК ВТ_Товары
			|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрНакопления.Дефектура.Остатки(
			|				,
			|				Склад = &Склад
			|					И Товар В
			|						(ВЫБРАТЬ
			|							ВТ_Товары.Товар
			|						ИЗ
			|							ВТ_Товары)
			|					И Заказ = ЗНАЧЕНИЕ(Документ.Заказ.ПустаяСсылка)
			|					И КлючСвязи = """"
			|					И Поставщик = ЗНАЧЕНИЕ(Справочник.Контрагенты.ПустаяСсылка)
			|					И ЦенаЗакупки = 0) КАК ДефектураОстатки
			|		ПО ВТ_Товары.Товар = ДефектураОстатки.Товар
			|ГДЕ
			|	ЕСТЬNULL(ДефектураОстатки.КоличествоОстаток, 0) - ВТ_Товары.Количество < 0";

			РезультатЗапроса = Запрос.Выполнить();
			Если Не РезультатЗапроса.Пустой() Тогда
				Отказ = Истина;
				стрОписаниеОшибки = "При отмене проведения документа образуется отрицательный остаток по следующим товарам:
				|";
				ВыборкаОшибки = РезультатЗапроса.Выбрать();
				Пока ВыборкаОшибки.Следующий() Цикл
					стрОписаниеОшибки = стрОписаниеОшибки + ВыборкаОшибки.Товар + " в количестве " + ВыборкаОшибки.Количество + " шт.
					|";
				КонецЦикла;

				Сообщение = Новый СообщениеПользователю;
				Сообщение.Текст = стрОписаниеОшибки + "Документ не снят с проведения.";
				Сообщение.Сообщить();

				Возврат;

			КонецЕсли;

	КонецЕсли; 
	
	Движения.Дефектура.Записывать = Истина;
	Движения.Дефектура.Очистить();
	Движения.Дефектура.Записать();

КонецПроцедуры

