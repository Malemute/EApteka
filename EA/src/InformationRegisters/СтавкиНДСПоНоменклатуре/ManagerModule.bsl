Процедура УстановитьСтавкуНДСДляНоменклатуры(Номенклатура,Ставка,Период) Экспорт
	
	МенеджерЗаписи = РегистрыСведений.СтавкиНДСПоНоменклатуре.СоздатьМенеджерЗаписи();
	МенеджерЗаписи.Период = НачалоДня(Период);
	МенеджерЗаписи.СтавкаНДС = Ставка;
	МенеджерЗаписи.Товар = Номенклатура;
	МенеджерЗаписи.Записать(Истина);
	
КонецПроцедуры

//Функция возвращает ставку НДС или процент НДС
//Параметры:
//НоменклатураПартия - ссылка на номенклатуру или партию;
//Период - дата на которую будет получена ставка НДС;
//Число - если Истина возвращает ставку НДС в виде числа, если Ложь ссылку на ставку;
//Приход - при получении ставки НДС для партии, если Истина - получает закупочную ставку НДС, иначе НДС для продажи;

Функция ВернутьСтавкуНДСПоНоменклатуре(НоменклатураПартия,Период,Число = Ложь,Приход = Ложь) Экспорт
	
	Номенклатура = справочники.Номенклатура.ПустаяСсылка();
	Партия = Справочники.Партии.ПустаяСсылка();
	Если ТипЗнч(НоменклатураПартия) = Тип("СправочникСсылка.Партии") тогда
		Партия = НоменклатураПартия;
	ИначеЕсли ТипЗнч(НоменклатураПартия) = Тип("СправочникСсылка.Номенклатура") тогда
		Номенклатура = НоменклатураПартия;
	КонецЕсли;
	
	Если не ЗначениеЗаполнено(НоменклатураПартия) тогда 
		Если Число тогда
			Возврат 0;
		Иначе
			Возврат Справочники.СтавкиНДС.НДС0;
		КонецЕсли;
	КонецЕсли;
	
	Запрос = Новый Запрос;
	Если ЗначениеЗаполнено(Партия) тогда
		Запрос.Текст = 
		"ВЫБРАТЬ
		|	Партии.Владелец КАК Номенклатура
		|ПОМЕСТИТЬ втНоменклатура
		|ИЗ
		|	Справочник.Партии КАК Партии
		|ГДЕ
		|	Партии.Ссылка = &Партия
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ ПЕРВЫЕ 1
		|	ВложенныйЗапрос.СтавкаНДС,
		|	ВложенныйЗапрос.Процент,
		|	ВложенныйЗапрос.Приоритет КАК Приоритет
		|ИЗ
		|	(ВЫБРАТЬ
		|		Партии.СтавкаНДС КАК СтавкаНДС,
		|		Партии.СтавкаНДС.Ставка КАК Процент,
		|		4 КАК Приоритет
		|	ИЗ
		|		Справочник.Партии КАК Партии
		|	ГДЕ
		|		Партии.Ссылка = &Партия
		|		И &Приход
		|	
		|	ОБЪЕДИНИТЬ ВСЕ
		|	
		|	ВЫБРАТЬ
		|		СтавкиНДСПоНоменклатуреСрезПоследних.СтавкаНДС,
		|		СтавкиНДСПоНоменклатуреСрезПоследних.СтавкаНДС.Ставка,
		|		3
		|	ИЗ
		|		РегистрСведений.СтавкиНДСПоНоменклатуре.СрезПоследних(
		|				&Период,
		|				Товар В
		|					(ВЫБРАТЬ
		|						втНоменклатура.Номенклатура
		|					ИЗ
		|						втНоменклатура КАК втНоменклатура)) КАК СтавкиНДСПоНоменклатуреСрезПоследних
		|	
		|	ОБЪЕДИНИТЬ ВСЕ
		|	
		|	ВЫБРАТЬ
		|		СтавкиНДСПоНоменклатуреСрезПоследних.СтавкаНДС,
		|		СтавкиНДСПоНоменклатуреСрезПоследних.СтавкаНДС.Ставка,
		|		2
		|	ИЗ
		|		РегистрСведений.СтавкиНДСПоНоменклатуре.СрезПоследних(
		|				&ТекущаяДата,
		|				НЕ &Приход
		|					И Товар В
		|						(ВЫБРАТЬ
		|							втНоменклатура.Номенклатура
		|						ИЗ
		|							втНоменклатура КАК втНоменклатура)) КАК СтавкиНДСПоНоменклатуреСрезПоследних
		|	
		|	ОБЪЕДИНИТЬ ВСЕ
		|	
		|	ВЫБРАТЬ
		|		ЗНАЧЕНИЕ(Справочник.СтавкиНДС.ПустаяСсылка),
		|		0,
		|		1) КАК ВложенныйЗапрос
		|ГДЕ
		|	&Закупка
		|
		|УПОРЯДОЧИТЬ ПО
		|	Приоритет УБЫВ";
		Запрос.УстановитьПараметр("ТекущаяДата", ТекущаяДата());
		Запрос.УстановитьПараметр("Партия", Партия);
		Запрос.УстановитьПараметр("Приход", Приход);
	ИначеЕсли ЗначениеЗаполнено(Номенклатура) тогда			
		Запрос = Новый Запрос;
		Запрос.Текст = 
		"ВЫБРАТЬ
		|	СтавкиНДСПоНоменклатуреСрезПоследних.СтавкаНДС,
		|	СтавкиНДСПоНоменклатуреСрезПоследних.СтавкаНДС.Ставка КАК Процент
		|ИЗ
		|	РегистрСведений.СтавкиНДСПоНоменклатуре.СрезПоследних(&Период, Товар = &Товар) КАК СтавкиНДСПоНоменклатуреСрезПоследних";
		Запрос.УстановитьПараметр("Товар",Номенклатура);
	КонецЕсли;
	Запрос.УстановитьПараметр("Период",КонецДня(Период));
	Результат = Запрос.Выполнить();
	Если не Результат.Пустой() тогда
		Выборка = Результат.Выбрать();
		Пока Выборка.Следующий() цикл
			Если Число тогда
				Возврат Выборка.Процент;
			Иначе
				Возврат Выборка.СтавкаНДС;
			КонецЕсли;
		КонецЦикла;
	КонецЕсли;
	Если Число тогда
		Возврат 18;
	Иначе
		Возврат Справочники.СтавкиНДС.НДС18;
	КонецЕсли;

КонецФункции