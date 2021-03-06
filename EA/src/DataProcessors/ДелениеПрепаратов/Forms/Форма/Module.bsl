
&НаКлиенте
Процедура ВнешнееСобытие(Источник, Событие, Данные)
	//Если Источник = "BarCodeScaner" тогда
	//	Если Событие = "BarCodeValue" тогда
	//		Scan.ПосылкаДанных = 1;   
	//		Если ЭтаФорма.ВводДоступен() тогда
	//			Сообщение = "";
	//			ОбработатьВводШтрихкода(Строка(Данные),Сообщение);	
	//			Если ЗначениеЗаполнено(Сообщение) тогда
	//				ПоказатьПредупреждение(,Сообщение);
	//			КонецЕсли;
	//		КонецЕсли;
	//	КонецЕсли;
	//КонецЕсли;
	
	// ЕМ ********************************************
	// ПодключаемоеОборудование
	Если //Источник = "ПодключаемоеОборудование"
		//И 
		ВводДоступен() Тогда
		//Если Событие = "ScanData" Тогда
		Если Событие = "Штрихкод" Тогда
			Если ЭтаФорма.ВводДоступен() тогда
				Сообщение = "";
				ОбработатьВводШтрихкода(Строка(Данные),Сообщение);	
				Если ЗначениеЗаполнено(Сообщение) тогда
					ПоказатьПредупреждение(,Сообщение);
				КонецЕсли;
			КонецЕсли;
		КонецЕсли;
	КонецЕсли;
	// Конец ПодключаемоеОборудование
	//******************************************** ЕМ 
	
КонецПроцедуры

&НаСервере
Процедура ОбработатьВводШтрихкода(ШК,СообщениеВозврата)
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	ЗаводскиеШК.Владелец
	|ПОМЕСТИТЬ ВТШК
	|ИЗ
	|	Справочник.ЗаводскиеШК КАК ЗаводскиеШК
	|ГДЕ
	|	ЗаводскиеШК.Наименование ПОДОБНО &ШК
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ОстаткиТовараОстатки.Товар КАК ТоварДелимый,
	|	ОстаткиТовараОстатки.Партия,
	|	ОстаткиТовараОстатки.ОстатокОстаток КАК Количество,
	|	Деление.Владелец КАК ТоварПолучаемый,
	|	Деление.Коэффициент,
	|	Деление.Ссылка КАК ПравилоДеления,
	|	ОстаткиТовараОстатки.ОстатокОстаток КАК Остаток
	|ИЗ
	|	РегистрНакопления.ОстаткиТовара.Остатки(
	|			,
	|			Отдел = &Отдел
	|				И Товар В
	|					(ВЫБРАТЬ
	|						ВТШК.Владелец
	|					ИЗ
	|						ВТШК КАК ВТШК)) КАК ОстаткиТовараОстатки
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Справочник.Деление КАК Деление
	|		ПО ОстаткиТовараОстатки.Товар = Деление.ТоварПолучаемый
	|			И (Деление.Коэффициент > 0)
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ВТШК.Владелец КАК Товар,
	|	ЕСТЬNULL(Деление.Ссылка, ЗНАЧЕНИЕ(справочник.Деление.ПустаяСсылка)) КАК Деление
	|ИЗ
	|	ВТШК КАК ВТШК
	|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.Деление КАК Деление
	|		ПО ВТШК.Владелец = Деление.ТоварПолучаемый
	|			И (Деление.Коэффициент > 0)
	|
	|УПОРЯДОЧИТЬ ПО
	|	Деление УБЫВ";
	Запрос.УстановитьПараметр("ШК", "%"+ШК+"%");
	Запрос.УстановитьПараметр("Отдел", Объект.Отдел);
	МассивРезультатов = Запрос.ВыполнитьПакет();
	ТаблицаДеления = МассивРезультатов[2].Выгрузить();
	Если ТаблицаДеления.Количество() = 0 тогда
		СообщениеВозврата = "Товар с таким штрихкодом не найден!";
		Возврат;
	Иначе
		Для каждого строка из ТаблицаДеления цикл
			Если не ЗначениеЗаполнено(Строка.Деление) тогда
				СообщениеВозврата = "Товар " + строка.Товар.КраткоеНаименование + " не может быть разделен!";
				Возврат;
			Иначе
				Продолжить;
			КонецЕсли;
		КонецЦикла;
	КонецЕсли;
	Выборка = МассивРезультатов[1].Выбрать();
	Пока Выборка.Следующий() цикл
		Если Объект.Деление.НайтиСтроки(Новый Структура("Партия",Выборка.Партия)).Количество() = 0 тогда
			Стр = Объект.Деление.Добавить();		
			ЗаполнитьЗначенияСвойств(Стр,Выборка);
			Стр.КоличествоПолучаемое = стр.Количество*Стр.Коэффициент;
		КонецЕсли;
	КонецЦикла;	
	
КонецПроцедуры


#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	Объект.Отдел = ПараметрыСеанса.ОсновнойСклад;
	
	ИспользоватьПодключаемоеОборудование = МенеджерОборудованияВызовСервераПереопределяемый.ИспользоватьПодключаемоеОборудование();
	
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	// ПодключаемоеОборудование
	ОповещенияПриПодключении = Новый ОписаниеОповещения("ПодключитьОборудованиеЗавершение", ЭтотОбъект);
	МенеджерОборудованияКлиент.НачатьПодключениеОборудованиеПриОткрытииФормы(ОповещенияПриПодключении, ЭтотОбъект, "СканерШтрихкода");
	// Конец ПодключаемоеОборудование
	
КонецПроцедуры

&НаКлиенте
Процедура ПодключитьОборудованиеЗавершение(РезультатВыполнения, Параметры) Экспорт
	
	Если Не РезультатВыполнения.Результат Тогда
		ЗаголовокИнформации = НСтр("ru = 'При подключении оборудования произошла ошибка: '; en = 'An error occurred while connecting the equipment: '");
		ТекстСообщения     = РезультатВыполнения.ОписаниеОшибки;
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ЗаголовокИнформации + ТекстСообщения);
	КонецЕсли;
	
КонецПроцедуры


&НаКлиенте
Процедура ПриЗакрытии(ЗавершениеРаботы)
	
	// ПодключаемоеОборудование
	ОповещенияПриОтключении = Новый ОписаниеОповещения("ОтключитьОборудованиеЗавершение", ЭтотОбъект); 
	МенеджерОборудованияКлиент.НачатьОтключениеОборудованиеПриЗакрытииФормы(ОповещенияПриОтключении, ЭтотОбъект);
	// Конец ПодключаемоеОборудование
	
КонецПроцедуры

&НаКлиенте
Процедура ОтключитьОборудованиеЗавершение(РезультатВыполнения, Параметры) Экспорт
   
   Если Не РезультатВыполнения.Результат Тогда
      ТекстСообщения = НСтр( "ru = 'При отключении оборудования произошла ошибка: ""%ОписаниеОшибки%"".'");
      ТекстСообщения = СтрЗаменить(ТекстСообщения, "%ОписаниеОшибки%" , РезультатВыполнения.ОписаниеОшибки);
      Сообщить(ТекстСообщения);
   КонецЕсли;

КонецПроцедуры

#КонецОбласти

//&НаКлиенте
//Процедура ДелениеПриОкончанииРедактирования(Элемент, НоваяСтрока, ОтменаРедактирования)
//		
//	ТекущаяСтрока = Элементы.Деление.ТекущиеДанные;
//	
//	Если ТекущаяСтрока <> неопределено тогда
//		ТекущаяСтрока.КоличествоПолучаемое = ТекущаяСтрока.Количество * ТекущаяСтрока.Коэффициент;
//	КонецЕсли;
//	
//КонецПроцедуры

&НаСервере
Процедура ВыполнитьДелениеНаСервере()
	Если Объект.Деление.Итог("КоличествоПолучаемое") = 0 тогда
		Возврат;
	КонецЕсли;
	ОбменТовара = Документы.ОбменТовара.СоздатьДокумент();
	ОбменТовара.Дата = ТекущаяДата();
	ОбменТовара.Отдел = Объект.Отдел;
	ОбменТовара.Ответственный = ПараметрыСеанса.ТекущийПользователь;
	Для каждого строка из Объект.Деление цикл
		Если Строка.КоличествоПолучаемое > 0 и Строка.Количество > 0 тогда
			СтрокаДел = ОбменТовара.Товары.Добавить();
			СтрокаДел.Товар = строка.ТоварДелимый;
			СтрокаДел.Партия = строка.Партия;
			СтрокаДел.Количество = строка.Количество;
			СтрокаДел.ПравилоДеления = строка.ПравилоДеления;
			СтрокаДел.НовыйТовар = строка.ТоварПолучаемый;
			СтрокаДел.НовоеКоличество = строка.КоличествоПолучаемое; 
			СтрокаДел.Коэффициент = строка.Коэффициент;
		КонецЕсли;
	КонецЦикла;
	НачатьТранзакцию();
	Попытка
		ОбменТовара.Записать(РежимЗаписиДокумента.Проведение);
		Сообщить("Создан документ " + Строка(ОбменТовара));
		Объект.Деление.Очистить();
		ЗафиксироватьТранзакцию();
	Исключение
		ОтменитьТранзакцию();
		Сообщить("Не удалось создать документ!");
	КонецПопытки;
КонецПроцедуры

&НаКлиенте
Процедура ВыполнитьДеление(Команда)
	ВыполнитьДелениеНаСервере();
КонецПроцедуры



&НаКлиенте
Процедура УдалитьСтрокуВопрос(Результат, Параметры) Экспорт
	Если Результат = КодВозвратаДиалога.Нет тогда
		Возврат;
	КонецЕсли;
	Объект.Деление.Удалить(Объект.Деление.НайтиПоИдентификатору(Параметры.ИдентификаторСтроки));	
КонецПроцедуры


&НаКлиенте
Процедура ДелениеКоличествоПриИзменении(Элемент)
	
	ТекущаяСтрока = Элементы.Деление.ТекущиеДанные;
	ДанныеВыбора = ТекущаяСтрока.Количество;	
	
	Если ДанныеВыбора > ТекущаяСтрока.Остаток тогда
		ТекущаяСтрока.Количество = ТекущаяСтрока.Остаток;
		ТекущаяСтрока.КоличествоПолучаемое = ТекущаяСтрока.Количество * ТекущаяСтрока.Коэффициент;
		ПоказатьПредупреждение(,"Указанное количество больше остатка!");
		Возврат;
	КонецЕсли;
	
	Если ТекущаяСтрока <> неопределено тогда
		ТекущаяСтрока.Количество = ДанныеВыбора;
		ТекущаяСтрока.КоличествоПолучаемое = ТекущаяСтрока.Количество * ТекущаяСтрока.Коэффициент;
	КонецЕсли;
	
	Если ДанныеВыбора = 0 тогда
		Оповещение = Новый ОписаниеОповещения("УдалитьСтрокуВопрос",ЭтаФорма,Новый Структура("ИдентификаторСтроки",ТекущаяСтрока.ПолучитьИдентификатор()));
		ПоказатьВопрос(Оповещение,"При делении строки с нулевым количеством не будут обрабатываться."+Символы.ПС+"Удалить строку?",РежимДиалогаВопрос.ДаНет);
	КонецЕсли;

КонецПроцедуры



