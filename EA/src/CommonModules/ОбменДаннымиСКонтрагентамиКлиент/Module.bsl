
#Область ПрограммныйИнтерфейс

Функция ЗагрузитьСправочникТоваров(Контрагент, ИмяФайла, ПараметрыЗагрузки) Экспорт
	
	Результат = ОбменДаннымиСКонтрагентамиКлиентСервер.РезультатЗагрузкиДанных();
	
	ДанныеЗагрузки = Новый Массив;
	ИдентификаторыПоставщиков = Новый Соответствие;
	
	Если ПараметрыЗагрузки.ТипФайла = ПредопределенноеЗначение("Перечисление.ФорматыФайловОбмена.XLS") Тогда
		ДанныеЗагрузки = ЗагрузитьИзExcel(ИмяФайла, ПараметрыЗагрузкиИзExcel(ПараметрыЗагрузки, ИдентификаторыПоставщиков));
	КонецЕсли;
	
	Если ДанныеЗагрузки.Количество() = 0 Тогда
		Возврат Результат;
	КонецЕсли;
	
	Результат = ОбменДаннымиСКонтрагентамиВызовСервера.ЗагрузитьСправочникТоваров(Контрагент, ДанныеЗагрузки, ИдентификаторыПоставщиков);
	
	ЗавершитьЗагрузкуДанных(Результат);
	
	Возврат Результат;
	
КонецФункции

Функция ЗагрузитьОстатки(Контрагент, ИмяФайла, ПараметрыЗагрузки) Экспорт
	
	Результат = ОбменДаннымиСКонтрагентамиКлиентСервер.РезультатЗагрузкиДанных();
	
	ДанныеЗагрузки = Новый Массив;
	
	Если ПараметрыЗагрузки.ТипФайла = ПредопределенноеЗначение("Перечисление.ФорматыФайловОбмена.XLS") Тогда
		ДанныеЗагрузки = ЗагрузитьИзExcel(ИмяФайла, ПараметрыЗагрузкиИзExcel(ПараметрыЗагрузки, Новый Соответствие));
	КонецЕсли;
	
	Если ДанныеЗагрузки.Количество() = 0 Тогда
		Возврат Результат;
	КонецЕсли;
	
	Результат = ОбменДаннымиСКонтрагентамиВызовСервера.ЗагрузитьОстатки(Контрагент, ДанныеЗагрузки);
	
	ЗавершитьЗагрузкуДанных(Результат);
	
	Возврат Результат;
	
КонецФункции

Функция ЗагрузитьЗакупки(Контрагент, ИмяФайла, ПараметрыЗагрузки) Экспорт
	
	Результат = ОбменДаннымиСКонтрагентамиКлиентСервер.РезультатЗагрузкиДанных();
	
	ДанныеЗагрузки = Новый Массив;
	
	Если ПараметрыЗагрузки.ТипФайла = ПредопределенноеЗначение("Перечисление.ФорматыФайловОбмена.XLS") Тогда
		ДанныеЗагрузки = ЗагрузитьИзExcel(ИмяФайла, ПараметрыЗагрузкиИзExcel(ПараметрыЗагрузки, Новый Соответствие));
	КонецЕсли;
	
	Если ДанныеЗагрузки.Количество() = 0 Тогда
		Возврат Результат;
	КонецЕсли;
	
	Результат = ОбменДаннымиСКонтрагентамиВызовСервера.ЗагрузитьЗакупки(Контрагент, ДанныеЗагрузки);
	
	ЗавершитьЗагрузкуДанных(Результат);
	
	Возврат Результат;
	
КонецФункции

Функция ЗагрузитьПродажи(Контрагент, ИмяФайла, ПараметрыЗагрузки) Экспорт
	
	Результат = ОбменДаннымиСКонтрагентамиКлиентСервер.РезультатЗагрузкиДанных();
	
	ДанныеЗагрузки = Новый Массив;
	
	Если ПараметрыЗагрузки.ТипФайла = ПредопределенноеЗначение("Перечисление.ФорматыФайловОбмена.XLS") Тогда
		ДанныеЗагрузки = ЗагрузитьИзExcel(ИмяФайла, ПараметрыЗагрузкиИзExcel(ПараметрыЗагрузки, Новый Соответствие));
	КонецЕсли;
	
	Если ДанныеЗагрузки.Количество() = 0 Тогда
		Возврат Результат;
	КонецЕсли;
	
	Результат = ОбменДаннымиСКонтрагентамиВызовСервера.ЗагрузитьПродажи(Контрагент, ДанныеЗагрузки);
	
	ЗавершитьЗагрузкуДанных(Результат);
	
	Возврат Результат;
	
КонецФункции

Функция ЗагрузитьИзExcel(ИмяФайла, ПараметрыЗагрузкиИзExcel) Экспорт
	
	Попытка
		COMОбъект = Новый COMОбъект("Excel.Application");
	Исключение
		СообщениеОбОшибке =
			НСтр("ru = 'Не удалось загрузить цены из файла Excel. 
				|Убедитесь, что на сервере установлена программа Microsoft Excel. 
				|Подробности:'") + "
				|" + КраткоеПредставлениеОшибки(ИнформацияОбОшибке());
		ВызватьИсключение СообщениеОбОшибке;
	КонецПопытки;
	
	Попытка
		Workbook      = COMОбъект.Workbooks.Open(ИмяФайла);
		Sheet         = Workbook.Worksheets(1);
	Исключение
		COMОбъект.Quit();
		COMОбъект = 0;
		СообщениеОбОшибке = НСтр("ru = 'Не удалось прочитать данные из файла. Подробности:'") + " "
		                    + КраткоеПредставлениеОшибки(ИнформацияОбОшибке());
		ВызватьИсключение СообщениеОбОшибке;
	КонецПопытки;
	
	СоответствиеКомментарии = Новый Соответствие;
	
	// Массивы структур
	ДанныеЗагрузки  = Новый Массив;
	
	ЕстьДобавленныеСтроки = Ложь;
	
	// Загрузка данных
	Попытка
		
		Если ПараметрыЗагрузкиИзExcel.Свойство("КолонкиПоиска") Тогда
			КолонкиПоиска = ПараметрыЗагрузкиИзExcel.КолонкиПоиска;
		Иначе
			КолонкиПоиска = Новый СписокЗначений;
		КонецЕсли;
		
		Если ПараметрыЗагрузкиИзExcel.Свойство("СтруктураПоиска") Тогда
			СтруктураПоиска = ПараметрыЗагрузкиИзExcel.СтруктураПоиска;
		Иначе
			СтруктураПоиска = Новый Структура;
		КонецЕсли;
		
		Для НомерКолонки=1 По Sheet.Cells.SpecialCells(11).Column Цикл
		
			КлючПоиска = "";
			Значение = Sheet.Cells(1, НомерКолонки).Value;
			Если ТипЗнч(Значение) = Тип("Строка") ИЛИ ТипЗнч(Значение) = Тип("Число") Тогда
				Если ТипЗнч(Значение) = Тип("Число") Тогда
					Значение = Формат(Значение, "ЧГ=0");
				КонецЕсли; 
				ЗначениеПоиска = СокрЛП(Значение);
				КолонкаПоиска = КолонкиПоиска.НайтиПоЗначению(ЗначениеПоиска);
				Если КолонкаПоиска <> Неопределено Тогда
					КлючПоиска = КолонкаПоиска.Представление;
				КонецЕсли; 
			КонецЕсли;
			Если ТипЗнч(Значение) = Тип("Дата") ИЛИ СтрНайти(КлючПоиска,"Период_") > 0 Тогда
				ИмяКолонки = "";
				Если СтрНайти(КлючПоиска,"Период_") > 0 Тогда
					ИмяКолонки = СтрЗаменить(КлючПоиска, "Период_", "");
					КлючПоиска = "";
				ИначеЕсли ПараметрыЗагрузкиИзExcel.Свойство("Периоды") Тогда
					НайденныеСтроки = ПараметрыЗагрузкиИзExcel.Периоды.НайтиСтроки(Новый Структура("ДатаНачала, Активная", Значение, Истина));
					Если НайденныеСтроки.Количество() > 0 Тогда
						ИмяКолонки = НайденныеСтроки[0].ИмяКолонки;
					КонецЕсли;
				КонецЕсли; 
				
				Если ЗначениеЗаполнено(ИмяКолонки) И ПараметрыЗагрузкиИзExcel.Свойство("РеквизитыПериода") Тогда
					СуфиксКолонки = 0;
					Для каждого РеквизитПериода Из ПараметрыЗагрузкиИзExcel.РеквизитыПериода Цикл
						СтруктураПоиска.Вставить(РеквизитПериода+ИмяКолонки, НомерКолонки+ СуфиксКолонки);
						СуфиксКолонки = СуфиксКолонки + 1;
						Если РеквизитПериода = "Количество_" Тогда
							СоответствиеКомментарии.Вставить(НомерКолонки, "Комментарий_" + ИмяКолонки);
						КонецЕсли;
					КонецЦикла; 
				КонецЕсли; 
			КонецЕсли; 
			
			Если ЗначениеЗаполнено(КлючПоиска) Тогда
				СтруктураПоиска.Вставить(КлючПоиска, НомерКолонки);
			КонецЕсли; 
			
			Если Значение = "Количество" Тогда
				СоответствиеКомментарии.Вставить(НомерКолонки, "Комментарий");
			КонецЕсли;
			
		КонецЦикла; 
		
		Если ПараметрыЗагрузкиИзExcel.Свойство("НомерСтрокиНачалаДанных") Тогда
			НомерСтроки = ПараметрыЗагрузкиИзExcel.НомерСтрокиНачалаДанных;
		Иначе
			НомерСтроки = 1;
		КонецЕсли; 
		
		Пока НомерСтроки <= Sheet.Cells.SpecialCells(11).Row Цикл
			
			НоваяСтрока = Новый Структура("КодСтроки");
			
			Для каждого КлючЗначение Из СтруктураПоиска Цикл
				
				Значение = Неопределено;
				Если КлючЗначение.Значение > 0 Тогда
					
					Значение = Sheet.Cells(НомерСтроки, КлючЗначение.Значение).Value;
					Если ТипЗнч(Значение) = Тип("Строка") 
						И (Найти(КлючЗначение.Ключ,"Количество") > 0
						ИЛИ СтрНайти(КлючЗначение.Ключ,"Цена") > 0
						ИЛИ СтрНайти(КлючЗначение.Ключ,"Сумма") > 0) Тогда
						
						Попытка
							Значение = Число(Значение);
						Исключение
						КонецПопытки;
					ИначеЕсли ТипЗнч(Значение) = Тип("Строка") 
						И СтрНайти(КлючЗначение.Ключ,"Дата") > 0 Тогда
						
						Попытка
							// Преобразование к дате для строки формата "dd.MM.yyyy"
							Значение = Дата(Прав(Значение,4) + Сред(Значение,4,2) + Лев(Значение,2)); 
						Исключение
						КонецПопытки;
						
					КонецЕсли; 
					
				КонецЕсли; 
				
				НоваяСтрока.Вставить(КлючЗначение.Ключ, Значение);
				
				ИмяКолонкиКомментарий = СоответствиеКомментарии.Получить(КлючЗначение.Значение);
				Если ИмяКолонкиКомментарий<>Неопределено Тогда
					Комментарий = Sheet.Cells(НомерСтроки, КлючЗначение.Значение).Comment;
					Если Комментарий <> Неопределено Тогда
						НоваяСтрока.Вставить(ИмяКолонкиКомментарий, Комментарий.Text());
					КонецЕсли;
				КонецЕсли;
				
			КонецЦикла;
			
			ДанныеЗагрузки.Добавить(НоваяСтрока);
			
			НомерСтроки = НомерСтроки + 1;
				
		КонецЦикла;
		
		Workbook.Close();
		
	Исключение
		COMОбъект.Quit();
		COMОбъект = 0;
		СообщениеОбОшибке = НСтр("ru = 'Не удалось прочитать данные из файла. Подробности:'") + " "
		                    + КраткоеПредставлениеОшибки(ИнформацияОбОшибке());
		ВызватьИсключение СообщениеОбОшибке;
	КонецПопытки;
	
	COMОбъект.Quit();
	COMОбъект = 0;
	
	Возврат ДанныеЗагрузки;
	
КонецФункции

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Функция ПараметрыЗагрузкиИзExcel(ПараметрыЗагрузки, ИдентификаторыПоставщиков)
	
	Результат = Новый Структура;
	Результат.Вставить("НомерСтрокиНачалаДанных", ПараметрыЗагрузки.НачальнаяСтрока);
	Результат.Вставить("СтруктураПоиска", Новый Структура);
	
	Для Каждого КлючЗначение Из ПараметрыЗагрузки.СоответствиеПолей Цикл
		Если ТипЗнч(КлючЗначение.Значение) = Тип("Соответствие") Тогда
			Для Каждого СоответствиеПоставщика Из КлючЗначение.Значение Цикл
				ИдентификаторПоставщика = "Поставщик" + СтрЗаменить(Строка(СоответствиеПоставщика.Ключ.УникальныйИдентификатор()), "-", "");
				Результат.СтруктураПоиска.Вставить(ИдентификаторПоставщика, СоответствиеПоставщика.Значение);
				
				ИдентификаторыПоставщиков.Вставить(ИдентификаторПоставщика, СоответствиеПоставщика.Ключ);
			КонецЦикла;
		Иначе
			Результат.СтруктураПоиска.Вставить(КлючЗначение.Ключ, КлючЗначение.Значение);
		КонецЕсли;
	КонецЦикла;
	
	Возврат Результат;
	
КонецФункции

Процедура ЗавершитьЗагрузкуДанных(Результат)
	
	ТекстСообщения = НСтр("ru='Импорт данных контрагента завершен.
	                      |Загружено %1 строк из %2'");
	ТекстСообщения = СтрШаблон(ТекстСообщения, Результат.ЗагруженоСтрок, Результат.ВсегоСтрок);
	
	ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ТекстСообщения);
	
	Если Результат.ДокументСсылка = Неопределено Тогда
		Оповестить("Запись_НоменклатураКонтрагентов");
	Иначе
		Оповестить("Запись_ИмпортДанныхКонтрагентов", Результат.ДокументСсылка);
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти