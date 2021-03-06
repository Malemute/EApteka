﻿Процедура РасчитатьСтрокуТЗТовары(Строка, РасчетОтСуммы) Экспорт
	
	Если РасчетОтСуммы тогда
		Если Строка.Количество = 0 тогда
			Строка.Сумма = 0;
			Строка.Цена = 0;
		Иначе
			Строка.Цена = Окр(Строка.Сумма/Строка.Количество,2);
			Если (Строка.Количество-Строка.Недовоз-Строка.Перевоз-Строка.Брак)>0 тогда
				Строка.Сумма = Строка.Цена*(Строка.Количество-Строка.Недовоз-Строка.Перевоз-Строка.Брак);
			КонецЕсли;
		КонецЕсли;           
	Иначе
		Строка.Сумма = Строка.Цена*(Строка.Количество-Строка.Недовоз-Строка.Перевоз-Строка.Брак);		
	КонецЕсли;	
	
КонецПроцедуры

Процедура СоздатьПретензии(Приходная) Экспорт
	
	ИтогПретензии = Приходная.Товары.Итог("Недовоз")+Приходная.Товары.Итог("Перевоз")+Приходная.Товары.Итог("Брак")+Приходная.Товары.Итог("Лишний");
	ИтогПретензииНаСклад  = Приходная.Товары.Итог("Перевоз")+Приходная.Товары.Итог("Брак"); 
	ИтогПретензииБезСклада = Приходная.Товары.Итог("Недовоз")+Приходная.Товары.Итог("Лишний");   
	
	ДокПретензии = "";   
	ДокПрихода = "";
	
	ТЗпричин = Новый ТаблицаЗначений;
	ТЗпричин.Колонки.Добавить("Партия");
	ТЗпричин.Колонки.Добавить("Претензия");
	ТЗпричин.Колонки.Добавить("Количество");
	ДокПри = 0; 
	ДокПре = 0;
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	ПретензияТовары.Ссылка КАК Ссылка,
	|	ПретензияТовары.Партия,
	|	ПретензияТовары.Количество,
	|	ПретензияТовары.Претензия
	|ИЗ
	|	Документ.Претензия.Товары КАК ПретензияТовары
	|ГДЕ
	|	ПретензияТовары.Ссылка.ДокументОснование = &ДокументОснование
	|
	|ОБЪЕДИНИТЬ ВСЕ
	|
	|ВЫБРАТЬ
	|	ПриходнаяТовары.Ссылка,
	|	ПриходнаяТовары.Партия,
	|	ПриходнаяТовары.Количество,
	|	ПриходнаяТовары.Претензия
	|ИЗ
	|	Документ.Приходная.Товары КАК ПриходнаяТовары
	|ГДЕ
	|	ПриходнаяТовары.Ссылка.ДокументОснование = &ДокументОснование
	|
	|ОБЪЕДИНИТЬ ВСЕ
	|
	|ВЫБРАТЬ
	|	ПеремещениеТовары.Ссылка,
	|	ПеремещениеТовары.Партия,
	|	ПеремещениеТовары.Количество,
	|	ПеремещениеТовары.Претензия
	|ИЗ
	|	Документ.Перемещение.Товары КАК ПеремещениеТовары
	|ГДЕ
	|	ПеремещениеТовары.Ссылка.ДокументОснование = &ДокументОснование
	|ИТОГИ ПО
	|	Ссылка";
	Запрос.УстановитьПараметр("ДокументОснование",Приходная.Ссылка);
	
	ВыборкаДокумент = Запрос.Выполнить().Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
	
	Пока ВыборкаДокумент.Следующий() Цикл 
		Док = ВыборкаДокумент.Ссылка.ПолучитьОбъект();
		Если ТипЗнч(ВыборкаДокумент.Ссылка) = Тип("ДокументСсылка.Претензия") Тогда
			Если ИтогПретензии > 0 Тогда 
				Выборка = ВыборкаДокумент.Выбрать();
				Для каждого строка из Док.Товары цикл
					СтрокаПричина = ТЗпричин.Добавить();
					СтрокаПричина.Партия=строка.Партия;
					СтрокаПричина.Претензия=строка.Претензия;
					СтрокаПричина.Количество=строка.Количество;
				КонецЦикла;	
				Если Док.ПометкаУдаления Тогда
					Док.УстановитьПометкуУдаления(Ложь); 
				КонецЕсли;
				Если Док.Проведен Тогда
					Док.Записать(РежимЗаписиДокумента.ОтменаПроведения);
				КонецЕсли; 
				Если ДокПре = 0 Тогда
					ДокПретензии = Док.Ссылка; 
					ДокПре = 1;
				ИначеЕсли НЕ Док.ПометкаУдаления Тогда
					Док.Удалить();	  
				КонецЕсли; 
			Иначе
				Док.Удалить();
			КонецЕсли;
		ИначеЕсли ТипЗнч(ВыборкаДокумент.Ссылка) =  Тип("ДокументСсылка.Приходная")
			или  ТипЗнч(ВыборкаДокумент.Ссылка) =  Тип("ДокументСсылка.Перемещение") Тогда  
			Если ИтогПретензииНаСклад > 0 Тогда
				Если Док.ПометкаУдаления Тогда
					Док.УстановитьПометкуУдаления(Ложь); 
				КонецЕсли;
				Если Док.Проведен Тогда
					Док.Записать(РежимЗаписиДокумента.ОтменаПроведения);
				КонецЕсли; 
				Если ДокПри = 0 Тогда
					ДокПрихода = Док.Ссылка; 
					ДокПри = 1;
				ИначеЕсли НЕ Док.ПометкаУдаления Тогда
					//Док.Удалить();	  
				КонецЕсли; 
			Иначе
				//Док.Удалить(); 
			КонецЕсли;
		КонецЕсли;
	КонецЦикла;
	
	Если ИтогПретензииНаСклад > 0 Тогда 
		глДокументПриходаПретензии(ДокПрихода, Приходная);
	КонецЕсли;
	
	Если ИтогПретензии > 0 Тогда
		глФормированиеПретензии(ДокПрихода, ДокПретензии, Приходная,ТЗпричин);
	КонецЕсли;
	
КонецПроцедуры

Процедура глДокументПриходаПретензии(Претензия, Приходная) Экспорт 

	ОтделПретензий=Константы.АдресХраненияТекущейБазы.Получить().СкладПретензий;
	
	Если не ЗначениеЗаполнено(Претензия) Тогда  
		ДокументПретензия = Документы.Приходная.СоздатьДокумент();
	Иначе    
		ДокументПретензия = Претензия.ПолучитьОбъект(); 	
	КонецЕсли;
	
	//Если ПустоеЗначение(Д.Создан) = 1 Тогда
	//	Д.Создан 		= Пользователь;  
	//Иначе
	//	Д.Изменен 		= Пользователь;
	//КонецЕсли;
	
	ДокументПретензия.Дата 				= Приходная.Дата;
	ДокументПретензия.Отдел 			= ОтделПретензий;
	ДокументПретензия.Клиент 			= Приходная.Клиент;
	ДокументПретензия.Договор 			= Приходная.Договор; 
	ДокументПретензия.ВычНП 			= Приходная.ВычНП;
	ДокументПретензия.ТипНакладной 		= Перечисления.ТипыПрихНакл.Закупка;
	ДокументПретензия.НомерОснования	= Приходная.НомерОснования;
	ДокументПретензия.ДатаОснования		= Приходная.ДатаОснования;
	ДокументПретензия.ДатаЗаказа 		= Приходная.ДатаЗаказа;
	ДокументПретензия.БезЗаказа 		= Приходная.БезЗаказа;
	ДокументПретензия.ДокументОснование	= Приходная.Ссылка;  
	Наценка = 0;             

	тзРезультат = ДокументПретензия.Товары.Выгрузить();  
	тзДок = Приходная.Товары.Выгрузить();
	
	ДокументПретензия.Товары.Очистить();

	Для каждого строка из Приходная.Товары цикл
 
		ВыбКоличество = строка.Брак+строка.Перевоз;
		СтрокаБылаРанее = Ложь; 
		Если ВыбКоличество = 0 Тогда 
			Продолжить 
		КонецЕсли;

		СтрокиТоварСерияЦена = тзРезультат.НайтиСтроки(Новый Структура("Товар,Серия,Цена",строка.Товар, Строка.Серия, Строка.Цена));
		СтрокаТоварСерияЦена = неопределено;
		Для каждого СтрокаТоварСерияЦена из СтрокиТоварСерияЦена цикл
			Продолжить
		КонецЦикла;
		Если СтрокаТоварСерияЦена= неопределено Тогда 
			СтрокаТоварСерияЦена = тзРезультат.Добавить();  
		Иначе	
			СтрокаБылаРанее = Истина;
		КонецЕсли;
		
		Если  ВыбКоличество = 0 Тогда
			Если СтрокаБылаРанее Тогда
				тзРезультат.Удалить(СтрокаТоварСерияЦена);
			КонецЕсли;
			Продолжить 
		КонецЕсли;
		
		СтрокаТоварСерияЦена.Товар = строка.Товар;
		СтрокаТоварСерияЦена.Имп = строка.Имп;
		СтрокаТоварСерияЦена.Цена = строка.Цена;
		СтрокаТоварСерияЦена.Количество = ВыбКоличество; 
		СтрокаТоварСерияЦена.Претензия = строка.Претензия;
		СтрокаТоварСерияЦена.Сумма = СтрокаТоварСерияЦена.Цена*СтрокаТоварСерияЦена.Количество;
	//	ПроцНДС=тзРезультат.Товар.СтавкаНДС.Получить(Д.ДатаДок).Ставка;
	//	СтрокаТоварСерияЦена.СуммаНДС=(тзРезультат.Сумма)*ПроцНДС/(100+ПроцНДС); 
		СтрокаТоварСерияЦена.НаценкаПоставщика = строка.НаценкаПоставщика;
		СтрокаТоварСерияЦена.Серия = строка.Серия;
		СтрокаТоварСерияЦена.ГоденДо = строка.ГоденДо; 
		СтрокаТоварСерияЦена.ЦенаПроизводителя = строка.ЦенаПроизводителя;
		СтрокаТоварСерияЦена.РеестроваяЦена = строка.РеестроваяЦена;
		СтрокаТоварСерияЦена.НаценкаПроизводителя = строка.НаценкаПроизводителя;
		СтрокаТоварСерияЦена.НаценкаРеестра = строка.НаценкаРеестра;
		СтрокаТоварСерияЦена.Сертификат = строка.Сертификат;
		СтрокаТоварСерияЦена.СертификатДо = строка.СертификатДо;
		СтрокаТоварСерияЦена.Выдан = строка.Выдан; 
	КонецЦикла; 
	

	МассивУдаляемыхСтрок = Новый Массив;
	Для каждого строка из тзРезультат цикл
		Строки = тзДок.НайтиСтроки(Новый Структура("Товар,Серия,Цена",строка.Товар,строка.Серия,строка.Цена));
		Если Строки.Количество() = 0 Тогда  
			МассивУдаляемыхСтрок.Добавить(Строка);
		КонецЕсли;
	КонецЦикла;
	Для Каждого строка из МассивУдаляемыхСтрок цикл
		тзДок.Удалить(Строка);	
	КонецЦикла;
	
	ДокументПретензия.Товары.Загрузить(тзРезультат);
	ДокументПретензия.СуммаПоставщика = тзРезультат.Итог("Сумма");
	ДокументПретензия.Записать(РежимЗаписиДокумента.Проведение);
	
	НовДок = ДокументПретензия.Ссылка;
	
КонецПроцедуры
	
Процедура глФормированиеПретензии(ДокПрихода, НовДок, ДокОсн, ТЗпричин) Экспорт 
	
	
		             
	Если Тип("ДокументСсылка.Перемещение")=ТипЗнч(ДокОсн) Тогда
		ОтделПретензий=ДокОсн.Поставщик.АдресХранения.СкладПретензий;          
	Иначе
		ОтделПретензий = ДокОсн.Отдел.АдресХранения.СкладПретензий;
	КонецЕсли;	
	
	
	Если НовДок = "" Тогда 
		//Если ДокОсн.ДатаДок <= Константа.ДатаКорректировкиПретензий Тогда Возврат КонецЕсли;
		Док = документы.Претензия.СоздатьДокумент();
	Иначе
		Док = НовДок.ПолучитьОбъект();   
		Док.Записать(РежимЗаписиДокумента.ОтменаПроведения);
		//Если ДокОсн.ДатаДок <= Константа.ДатаКорректировкиПретензий Тогда 
		//	Док.Провести();
		//	Возврат;
		//КонецЕсли;
	КонецЕсли;
	//
	//Если ПустоеЗначение(Док.Создан) = 1 Тогда
	//	Док.Создан 		= Пользователь;  
	//Иначе
	//	Док.Изменен 	= Пользователь;
	//КонецЕсли;
	Док.Дата 		= ДокОсн.Дата;
	Если ТипЗнч(ДокОсн) = Тип("ДокументСсылка.Перемещение") Тогда
		Док.Отдел 			= ДокОсн.Получатель;
	Иначе
		Док.Отдел 			= ОтделПретензий;
	КонецЕсли;
	Док.ДокументОснование	= ДокОсн.Ссылка;   
	ПартияДокПрихода = "";
	Док.Товары.Очистить();
	
	Для каждого строка из ДокОсн.Товары Цикл
		//Если ТипЗнч(ДокОсн) = Тип("ДокументСсылка.Перемещение") Тогда
		//	Если (НЕ ЗначениеЗаполнено(строка.Претензия)) или (( ЗначениеЗаполнено(строка.Претензия)) и (НЕ строка.Претензия.ФормироватьДвижения)) Тогда
		//		Продолжить;
		//	КонецЕсли; 
		//	глНоваяСтрокаПретензии(Док, ДокОсн.Товар,ДокОсн.Партия.ЗакупочнаяЦена,ДокОсн.Партия,ДокОсн.Количество,ДокОсн.Партия.ЗакупочнаяЦена*ДокОсн.Количество,ДокОсн.Претензия);
		//	Продолжить;
		//Иначе 
			ПартияДокПрихода =  строка.Партия;	
		//КонецЕсли;
		
		Если строка.Недовоз>0 Тогда
			Причина=Справочники.Претензии.Недовоз;
			СтрокиПричин = ТЗпричин.НайтиСтроки(Новый Структура("Партия,Количество",строка.Партия, строка.Недовоз));
			Для каждого СтрокаПричины из СтрокиПричин цикл
				Причина = СтрокаПричины.Претензия;
			КонецЦикла;	
			глНоваяСтрокаПретензии(Док, строка.Товар,строка.Цена,строка.Партия,строка.Недовоз,строка.Недовоз*строка.Цена,Причина);
		КонецЕсли;
		
		Если строка.Перевоз>0 Тогда                          
			Причина=Справочники.Претензии.Перевоз;	
			СтрокиПричин = ТЗпричин.НайтиСтроки(Новый Структура("Партия,Количество",строка.Партия, строка.Перевоз));
			Для каждого СтрокаПричины из СтрокиПричин цикл
				Причина = СтрокаПричины.Претензия;
			КонецЦикла;

			глНоваяСтрокаПретензии(Док, строка.Товар,строка.Цена,ПартияДокПрихода,строка.Перевоз,строка.Перевоз*строка.Цена,Причина);
		КонецЕсли;
		
		Если строка.Брак>0 Тогда                              
			Причина=Справочники.Претензии.Брак;
			СтрокиПричин = ТЗпричин.НайтиСтроки(Новый Структура("Партия,Количество",строка.Партия, строка.Брак));
			Для каждого СтрокаПричины из СтрокиПричин цикл
				Причина = СтрокаПричины.Претензия;
			КонецЦикла;
			глНоваяСтрокаПретензии(Док, строка.Товар,строка.Цена,ПартияДокПрихода,строка.Брак,строка.Брак*строка.Цена,справочники.Претензии.Брак);
		КонецЕсли;
		
		Если строка.Лишний>0 Тогда
			Причина=Справочники.Претензии.Лишний;	
			СтрокиПричин = ТЗпричин.НайтиСтроки(Новый Структура("Партия,Количество",строка.Лишний, строка.Лишний));
			Для каждого СтрокаПричины из СтрокиПричин цикл
				Причина = СтрокаПричины.Претензия;
			КонецЦикла;
			глНоваяСтрокаПретензии(Док, строка.Товар,строка.Цена,строка.Партия,строка.Лишний,строка.Лишний*строка.Цена,справочники.Претензии.Лишний);
		КонецЕсли;

	КонецЦикла;
	Док.Записать(РежимЗаписиДокумента.Проведение);

КонецПроцедуры 

Процедура глНоваяСтрокаПретензии(Док, ВыбТовар,ВыбЦена,ВыбПартия,ВыбКоличество,ВыбСумма,ВыбПретензия) 
	
	Строка = Док.Товары.Добавить();
	Строка.Товар = ВыбТовар;
	Строка.Цена = ВыбЦена;
	Строка.Партия = ВыбПартия; 
	Строка.Количество = ВыбКоличество;
	Строка.Сумма = ВыбСумма;
	Строка.Претензия = ВыбПретензия;
	Если ТипЗнч(Док.ДокументОснование) = Тип("ДокументСсылка.Приходная") тогда
		Строка.Поставщик = ВыбПартия.Документ.Клиент;
	ИначеЕсли ТипЗнч(Док.ДокументОснование) = Тип("ДокументСсылка.Перемещение") тогда
		Строка.Поставщик = Док.ДокументОснование.Поставщик;
	КонецЕсли;
	Строка.НомерИДатаСчетФактуры = СокрЛП(ВыбПартия.Документ.НомерОснования) + " от " + ВыбПартия.Документ.ДатаОснования + " г.";
	
КонецПроцедуры