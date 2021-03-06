
Процедура ОбработкаПроведения(Отказ, РежимПроведения)
	Если ТипКомплектацииЗаказа = Перечисления.ТипКомплектацииЗаказа.СборкаИКомплектацияВАптеке
		или ТипКомплектацииЗаказа = Перечисления.ТипКомплектацииЗаказа.СборкаНаСкладеВКоробку_КомплектацияВАптеке тогда
		
		Если ТипКомплектацииЗаказа = Перечисления.ТипКомплектацииЗаказа.СборкаИКомплектацияВАптеке тогда
			Движения.ОстаткиТовара.Записывать = Истина;
			Движения.ОстаткиТовара.Очистить();
		КонецЕсли;
		
		Движения.ТоварыКСборке.Записывать = Истина;
		Движения.ТоварыКСборке.Очистить();	
		
		ОтделДляДвижений = ТочкаСамовывоза.АдресХранения.ОсновнойСклад;
		Для каждого строка из Товар цикл
			КоличествоСписываемое = ?(Строка.КоличествоПриОформлении = 0, строка.Количество, Строка.КоличествоПриОформлении);
			
			Если ТипКомплектацииЗаказа = Перечисления.ТипКомплектацииЗаказа.СборкаИКомплектацияВАптеке тогда		
				Движение = Движения.ОстаткиТовара.ДобавитьРасход();
				Движение.Отдел = ОтделДляДвижений;
				Движение.Период = Дата;
				Движение.Товар = Строка.Товар;
				Движение.Партия = Строка.Партия;
				Движение.Остаток = КоличествоСписываемое;
				
				Движение = Движения.ОстаткиТовара.ДобавитьПриход();
				Движение.Отдел = ОтделДляДвижений;
				Движение.Период = Дата;
				Движение.Товар = Строка.Товар;
				Движение.Партия = Строка.Партия;
				Движение.ДокументРезерва = Ссылка;
				Движение.Резерв = КоличествоСписываемое;						
				
			КонецЕсли;
			
			Если не Строка.Товар.ВиртуальныйТовар тогда
				Движение = Движения.ТоварыКСборке.ДобавитьПриход();
				Движение.Документ = Ссылка;
				Движение.Склад = ОтделДляДвижений;
				Движение.Период = Дата;
				Движение.Товар = Строка.Товар;
				Если ТипКомплектацииЗаказа = Перечисления.ТипКомплектацииЗаказа.СборкаИКомплектацияВАптеке тогда
					Движение.ТипСборки = перечисления.ТипСборки.СборкаЗаказа;
					Движение.Партия = Строка.Партия;
				Иначе
					Движение.ТипСборки = перечисления.ТипСборки.СборкаЗаказовИзКоробки;
				КонецЕсли;
				Движение.КоличествоКСборке = КоличествоСписываемое;
				Движение.КоличествоНаКомплектации = 0;
			КонецЕсли;
		КонецЦикла;
	КонецЕсли;
	
	
	Движения.ОтправкаСМС.Прочитать();

	Если СтатусыОбработкиЗаказа = Справочники.СтатусыОбработкиЗаказа.ЗаказВТочкеСамовывоза
		И ОбменАлгоритмыРИБД.ЭтоЦентральнаяБаза()
		И Движения.ОтправкаСМС.Количество() = 0	
		И СтатусыДокументов.ПолучитьСтатусАктуальностиЗаказа(Ссылка) = Справочники.СтатусыАктуальностиЗаказов.Актуален тогда
		Движения.ОтправкаСМС.Записывать = Истина;
		ТелефонПер = СокрЛП(Лев(Телефон,10));
		Если СтрДлина(ТелефонПер) < 10 тогда
			Возврат;
		КонецЕсли;
		Если Лев(ТелефонПер,3) = "495" или Лев(ТелефонПер,3) = "499"
			или Лев(ТелефонПер,3) = "496" или Лев(ТелефонПер,3) = "812" тогда
			Возврат;
		КонецЕсли;
		Движение = Движения.ОтправкаСМС.Добавить();
		Движение.Период = ТекущаяДата();
		Движение.created = "Администратор";
		Движение.phone = ТелефонПер;
		//---%%% Тарасков - 12.09.2017 - Начало
		//Движение.sms = СокрЛП("Заказ №"+СокрЛП(Номер)+" ожидает в аптеке EAPTEKA "+СокрЛП(ТочкаСамовывоза.АдресХранения.Адрес))+". Сумма "+Формат(Товар.Итог("Всего"),"ЧДЦ=2")+" р.";
		//Движение.sms = СокрЛП("Заказ №"+СокрЛП(Номер)+" ожидает в аптеке EAPTEKA "+СокрЛП(ТочкаСамовывоза.АдресХранения.Адрес)) + ", Пн-Вс 8-23. Сумма " + Формат( Товар.Итог( "Всего" ) - 0.5, "ЧДЦ=" ) + " р.";
		Движение.sms = СокрЛП("Заберите заказ №"+СокрЛП(Номер)+" в аптеке EAPTEKA "+СокрЛП(ТочкаСамовывоза.АдресХранения.Адрес)) + ", с 8 до 23. Сумма " + Формат(Товар.Итог( "Всего" ) - 0.5, "ЧДЦ=; ЧГ=0" ) + " р.";
		//---%%% Тарасков - 12.09.2017 - Конец
		Движение.approved = "auto";
		Движение.id_t_tc = СокрЛП(Строка(ТипЦены.Код));
		Движение.iddoc = ID_77;
		Движение.type = 1;
		//Движение.АдресХранения = ТочкаСамовывоза.АдресХранения;
	КонецЕсли;
	//Если ДополнительныеСвойства.Свойство("ПометитьНаОбмен") тогда
	//	НЗ = РегистрыСведений.ЗаказыСИзменившемсяСатусом.СоздатьНаборЗаписей();	
	//	НЗ.Отбор.Заказ.Значение = Ссылка;
	//	НЗ.Отбор.Заказ.Использование = Истина;
	//	Запись = НЗ.Добавить();
	//	Запись.Заказ = Ссылка;
	//	НЗ.Записать(Истина);
	//КонецЕсли;
КонецПроцедуры

Процедура ПередЗаписью(Отказ, РежимЗаписи, РежимПроведения)
	
	СуммаДокумента =  Товар.Итог("Всего");
	
КонецПроцедуры
