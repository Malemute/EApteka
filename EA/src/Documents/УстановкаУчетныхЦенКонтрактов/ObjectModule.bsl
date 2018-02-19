
#Область ОбработчикиСобытий

Процедура ОбработкаЗаполнения(ДанныеЗаполнения, ТекстЗаполнения, СтандартнаяОбработка)
	
	Если ТипЗнч(ДанныеЗаполнения) = Тип("Структура") И ДанныеЗаполнения.Свойство("Контракт") Тогда
		
		ДержательКонтракта = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(ДанныеЗаполнения.Контракт, "Владелец");
		
	КонецЕсли;
	
КонецПроцедуры

Процедура ОбработкаПроведения(Отказ, РежимПроведения)
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("Ссылка", Ссылка);
	
	Запрос.Текст =
	"ВЫБРАТЬ
	|	УстановкаУчетныхЦенКонтрактовТовары.Ссылка.Дата     КАК Период,
	|	УстановкаУчетныхЦенКонтрактовТовары.Ссылка          КАК Регистратор,
	|	УстановкаУчетныхЦенКонтрактовТовары.НомерСтроки     КАК НомерСтроки,
	|	УстановкаУчетныхЦенКонтрактовТовары.Номенклатура    КАК Номенклатура,
	|	УстановкаУчетныхЦенКонтрактовТовары.Ссылка.Контракт КАК Контракт,
	|	УстановкаУчетныхЦенКонтрактовТовары.Цена            КАК Цена
	|ИЗ
	|	Документ.УстановкаУчетныхЦенКонтрактов.Товары КАК УстановкаУчетныхЦенКонтрактовТовары
	|ГДЕ
	|	УстановкаУчетныхЦенКонтрактовТовары.Ссылка = &Ссылка
	|
	|УПОРЯДОЧИТЬ ПО
	|	НомерСтроки";
	
	Выборка = Запрос.Выполнить().Выбрать();
	Пока Выборка.Следующий() Цикл
		Движение = Движения.УчетныеЦеныНоменклатурыКонтрактов.Добавить();
		ЗаполнитьЗначенияСвойств(Движение, Выборка);
	КонецЦикла;
	
	Движения.УчетныеЦеныНоменклатурыКонтрактов.Записать();
	
КонецПроцедуры

#КонецОбласти