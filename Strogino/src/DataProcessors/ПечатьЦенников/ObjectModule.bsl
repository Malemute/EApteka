Функция ПечатьЦенников() Экспорт

	ТД = Новый ТабличныйДокумент;
	МакетЦенник = Обработки.ПечатьЦенников.ПолучитьМакет("Ценник");
	ОбластьЦенник = МакетЦенник.ПолучитьОбласть("Ценник");
	
	ПараметрыШтрихКода = Новый Структура;
	ПараметрыШтрихКода.Вставить("Ширина",60);
	ПараметрыШтрихКода.Вставить("Высота",160);
	ПараметрыШтрихКода.Вставить("ОтображатьТекст",Истина);
	ПараметрыШтрихКода.Вставить("УголПоворота",270);
	ПараметрыШтрихКода.Вставить("ОтображатьТекст",Истина);
	ПараметрыШтрихКода.Вставить("ТипКода",1);
	ПараметрыШтрихКода.Вставить("ПрозрачныйФон");	
	
	ТДСтраница = Новый ТабличныйДокумент;
	ТДСтраница.Защита = Истина;
	ТДСтраница.ПолеСверху = 0;
	ТДСтраница.ПолеСнизу = 0;
	ТДСтраница.ПолеСлева = 0;
	ТДСтраница.ПолеСправа = 0;
	ТДСтраница.РазмерКолонтитулаСверху = 0; 
	ТДСтраница.РазмерКолонтитулаСнизу = 0;	

	МассивОбластейПрис = Новый Массив;
	МассивОбластейВывод = Новый Массив;
	Нстр = Истина;
	//Для каждого МестоЗСЯ из МассивМестЗСЯ цикл
	Для каждого Строка из Товары цикл
		ОбластьЦенник.Параметры.КодНоменклатуры = Формат(Число(Строка.Товар.Код),"ЧДЦ=; ЧН=0; ЧГ=");
		ОбластьЦенник.Параметры.Товар = Строка.Товар.КраткоеНаименование;
		ОбластьЦенник.Параметры.Цена = Строка.Цена;
		ОбластьЦенник.Параметры.Поставщик = Строка.Поставщик;
		ОбластьЦенник.Параметры.Производитель = Строка.Производитель;
		ОбластьЦенник.Параметры.Страна = Строка.Страна;
		ОбластьЦенник.Параметры.СрокГодности = Формат(Строка.СрокГодности,"ДФ=dd.MM.yyyy");
	
		МассивОбластейПрис.Добавить(ОбластьЦенник);
		Если не ТДСтраница.ПроверитьПрисоединение(МассивОбластейПрис) тогда
			МассивОбластейПрис.Очистить();
			МассивОбластейПрис.Добавить(ОбластьЦенник);
			МассивОбластейВывод.Добавить(ОбластьЦенник);
			Если не ТДСтраница.ПроверитьВывод(МассивОбластейВывод) тогда
				ТД.ВывестиГоризонтальныйРазделительСтраниц();
				МассивОбластейВывод.Очистить();
			КонецЕсли;
			ТД.Вывести(ОбластьЦенник);
		Иначе
			ТД.Присоединить(ОбластьЦенник);	
		КонецЕсли;
	КонецЦикла;
	Возврат ТД;

КонецФункции


Процедура ЗаполнитьТаблицуЦенниковПоМассиву(МассивНоменклатурыДляПечати,РегионРаботы,ТипЦены) Экспорт
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	Номенклатура.Ссылка КАК Ссылка
	|ПОМЕСТИТЬ ВТНоменклатураПоАдресации
	|ИЗ
	|	Справочник.Номенклатура КАК Номенклатура
	|ГДЕ
	|	Номенклатура.Ссылка В(&МассивНоменклатурыДляПечати)
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ОстаткиТовараОстатки.Товар,
	|	ОстаткиТовараОстатки.Партия
	|ПОМЕСТИТЬ ВТТоварИПартияДляПечати
	|ИЗ
	|	РегистрНакопления.ОстаткиТовара.Остатки(
	|			&Период,
	|			Отдел = &Склад
	|				И Товар В
	|					(ВЫБРАТЬ
	|						ВТНоменклатураПоАдресации.Ссылка
	|					ИЗ
	|						ВТНоменклатураПоАдресации КАК ВТНоменклатураПоАдресации)) КАК ОстаткиТовараОстатки
	|
	|СГРУППИРОВАТЬ ПО
	|	ОстаткиТовараОстатки.Товар,
	|	ОстаткиТовараОстатки.Партия
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ВТТоварИПартияДляПечати.Товар,
	|	ВТТоварИПартияДляПечати.Партия,
	|	ЦеныПрайсЛиста.Ссылка КАК ЦенаПартииПрайсЛиста,
	|	ЕСТЬNULL(ВТТоварИПартияДляПечати.Партия.Производитель.Родитель.Наименование, """") КАК Страна,
	|	ЕСТЬNULL(ВТТоварИПартияДляПечати.Партия.Документ.Клиент.Наименование, ЕСТЬNULL(ВТТоварИПартияДляПечати.Партия.Клиент.Наименование, """")) КАК Поставщик,
	|	ВТТоварИПартияДляПечати.Партия.ГоденДо КАК ГоденДо
	|ПОМЕСТИТЬ втТоварИЦенаПартииПрайсЛиста
	|ИЗ
	|	ВТТоварИПартияДляПечати КАК ВТТоварИПартияДляПечати
	|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.ЦеныПрайсЛиста КАК ЦеныПрайсЛиста
	|		ПО ВТТоварИПартияДляПечати.Товар = ЦеныПрайсЛиста.Владелец
	|			И (ЦеныПрайсЛиста.ТипЦены = &ТипЦены)
	|			И (ЦеныПрайсЛиста.РегионРаботы = &РегионРаботы)
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	втТоварИЦенаПартииПрайсЛиста.Товар,
	|	МИНИМУМ(втТоварИЦенаПартииПрайсЛиста.ГоденДо) КАК ГоденДо
	|ПОМЕСТИТЬ втМинимальныеСрокиГодности
	|ИЗ
	|	втТоварИЦенаПартииПрайсЛиста КАК втТоварИЦенаПартииПрайсЛиста
	|
	|СГРУППИРОВАТЬ ПО
	|	втТоварИЦенаПартииПрайсЛиста.Товар
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	втТоварИЦенаПартииПрайсЛиста.Товар КАК Товар,
	|	втТоварИЦенаПартииПрайсЛиста.ЦенаПартииПрайсЛиста,
	|	втТоварИЦенаПартииПрайсЛиста.Страна,
	|	втТоварИЦенаПартииПрайсЛиста.ГоденДо КАК СрокГодности,
	|	ВЫБОР
	|		КОГДА МАКСИМУМ(ВЫБОР
	|					КОГДА ЕСТЬNULL(ЦенаНоменклатурыСрезПоследних.СпецПредложение, 0) > 0
	|						ТОГДА ЦенаНоменклатурыСрезПоследних.СпецПредложение
	|					ИНАЧЕ 0
	|				КОНЕЦ) = 0
	|			ТОГДА МАКСИМУМ(ВЫБОР
	|						КОГДА ЕСТЬNULL(ЦенаНоменклатурыСрезПоследних.Цена, 0) > 0
	|							ТОГДА ЦенаНоменклатурыСрезПоследних.Цена
	|						ИНАЧЕ 0
	|					КОНЕЦ)
	|		ИНАЧЕ МАКСИМУМ(ВЫБОР
	|					КОГДА ЕСТЬNULL(ЦенаНоменклатурыСрезПоследних.СпецПредложение, 0) > 0
	|						ТОГДА ЦенаНоменклатурыСрезПоследних.СпецПредложение
	|					ИНАЧЕ 0
	|				КОНЕЦ)
	|	КОНЕЦ КАК Цена,
	|	втТоварИЦенаПартииПрайсЛиста.Поставщик КАК Поставщик,
	|	втТоварИЦенаПартииПрайсЛиста.Товар.Производитель.Наименование КАК Производитель
	|ИЗ
	|	втТоварИЦенаПартииПрайсЛиста КАК втТоварИЦенаПартииПрайсЛиста
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ РегистрСведений.ЦенаНоменклатуры.СрезПоследних(
	|				&Период,
	|				ЦенаПрайсЛиста В
	|					(ВЫБРАТЬ
	|						втТоварИЦенаПартииПрайсЛиста.ЦенаПартииПрайсЛиста
	|					ИЗ
	|						втТоварИЦенаПартииПрайсЛиста КАК втТоварИЦенаПартииПрайсЛиста)) КАК ЦенаНоменклатурыСрезПоследних
	|		ПО втТоварИЦенаПартииПрайсЛиста.ЦенаПартииПрайсЛиста = ЦенаНоменклатурыСрезПоследних.ЦенаПрайсЛиста
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ втМинимальныеСрокиГодности КАК втМинимальныеСрокиГодности
	|		ПО втТоварИЦенаПартииПрайсЛиста.Товар = втМинимальныеСрокиГодности.Товар
	|			И втТоварИЦенаПартииПрайсЛиста.ГоденДо = втМинимальныеСрокиГодности.ГоденДо
	|
	|СГРУППИРОВАТЬ ПО
	|	втТоварИЦенаПартииПрайсЛиста.Товар,
	|	втТоварИЦенаПартииПрайсЛиста.ЦенаПартииПрайсЛиста,
	|	втТоварИЦенаПартииПрайсЛиста.Поставщик,
	|	втТоварИЦенаПартииПрайсЛиста.Страна,
	|	втТоварИЦенаПартииПрайсЛиста.ГоденДо,
	|	втТоварИЦенаПартииПрайсЛиста.Товар.Производитель.Наименование
	|
	|ИМЕЮЩИЕ
	|	ВЫБОР
	|		КОГДА МАКСИМУМ(ВЫБОР
	|					КОГДА ЕСТЬNULL(ЦенаНоменклатурыСрезПоследних.СпецПредложение, 0) > 0
	|						ТОГДА ЦенаНоменклатурыСрезПоследних.СпецПредложение
	|					ИНАЧЕ 0
	|				КОНЕЦ) = 0
	|			ТОГДА МАКСИМУМ(ВЫБОР
	|						КОГДА ЕСТЬNULL(ЦенаНоменклатурыСрезПоследних.Цена, 0) > 0
	|							ТОГДА ЦенаНоменклатурыСрезПоследних.Цена
	|						ИНАЧЕ 0
	|					КОНЕЦ)
	|		ИНАЧЕ МАКСИМУМ(ВЫБОР
	|					КОГДА ЕСТЬNULL(ЦенаНоменклатурыСрезПоследних.СпецПредложение, 0) > 0
	|						ТОГДА ЦенаНоменклатурыСрезПоследних.СпецПредложение
	|					ИНАЧЕ 0
	|				КОНЕЦ)
	|	КОНЕЦ > 0";
	Запрос.УстановитьПараметр("МассивНоменклатурыДляПечати",МассивНоменклатурыДляПечати);
	Запрос.УстановитьПараметр("ТипЦены",ТипЦены);
	Запрос.УстановитьПараметр("РегионРаботы",РегионРаботы);
	Запрос.УстановитьПараметр("Период",ТекущаяДата());
	Запрос.УстановитьПараметр("Склад",ПараметрыСеанса.ОсновнойСклад);


	Выборка = Запрос.Выполнить().Выбрать();
	Пока Выборка.Следующий() цикл
		стр = Товары.Добавить();
		стр.Поставщик = Выборка.Поставщик;
		стр.СрокГодности = Выборка.СрокГодности;
		стр.Страна = Выборка.Страна;
		стр.Производитель = Выборка.Производитель;
		стр.Цена = Выборка.Цена;
		стр.Товар = Выборка.Товар;		
	КонецЦикла;
	
КонецПроцедуры