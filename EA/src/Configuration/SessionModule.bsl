Процедура УстановкаПараметровСеанса(ТребуемыеПараметры)
	
	Если НЕ ПустаяСтрока(ПользователиИнформационнойБазы.ТекущийПользователь().Имя) Тогда
		
		Запрос = Новый Запрос;
		Запрос.Текст = "ВЫБРАТЬ ПЕРВЫЕ 1
		|	Сотрудники.Ссылка КАК Ссылка
		|ИЗ
		|	Справочник.Сотрудники КАК Сотрудники
		|ГДЕ
		|	Сотрудники.Наименование = &Наименование";
		
		Запрос.Параметры.Вставить("Наименование", ПользователиИнформационнойБазы.ТекущийПользователь().Имя);
		Результат = Запрос.Выполнить();
		Если Результат.Пустой() Тогда
			ПараметрыСеанса.ТекущийПользователь = Справочники.Сотрудники.ПустаяСсылка();
		Иначе
			Выборка = Результат.Выбрать();
			Выборка.Следующий();
			ПараметрыСеанса.ТекущийПользователь = Выборка.Ссылка;
		КонецЕсли;
		
	КонецЕсли;
	ПараметрыСеанса.ТекущийАдресХранения = Константы.АдресХраненияТекущейБазы.Получить();
	ПараметрыСеанса.РегионРаботы = ПараметрыСеанса.ТекущийАдресХранения.РегионРаботы;
	ПараметрыСеанса.ОсновнойСклад = ПараметрыСеанса.ТекущийАдресХранения.ОсновнойСклад;
	ПараметрыСеанса.ТекущийПрефикс = ПланыОбмена.ПланОбменаОбновлениями.ЭтотУзел().Префикс;
	ПараметрыСеанса.ОсновнаяОрганизация = ?(ЗначениеЗаполнено(ПараметрыСеанса.ТекущийАдресХранения),ПараметрыСеанса.ТекущийАдресХранения.Фирма,Справочники.Фирмы.ПустаяСсылка());
	ПараметрыСеанса.БуферОбмена = Новый ФиксированнаяСтруктура(Новый Структура("Источник, Данные"));

	// Переопределяемый блок

	// ПодключаемоеОборудование
	УстановленныеПараметры = Новый Массив();
	МенеджерОборудованияВызовСервера.УстановитьПараметрыСеансаПодключаемогоОборудования("РабочееМестоКлиента", УстановленныеПараметры);
	// Конец ПодключаемоеОборудование

	// Конец переопределяемого блока.
		
КонецПроцедуры
