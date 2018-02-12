
Функция ReservationReserv(Запрос)
	
	ТекстJSON = Запрос.ПараметрыЗапроса.Получить("Order");
	Ответ = Неопределено;
	Если ТекстJSON = неопределено тогда
		Ответ = Новый HTTPСервисОтвет("400");
		Ответ.УстановитьТелоИзСтроки("The Order parameter is not set.");
	КонецЕсли;
	Если Ответ = неопределено тогда
		ЧтениеJSON = новый ЧтениеJSON;
		ЧтениеJSON.УстановитьСтроку(ТекстJSON);	
		Попытка
			СтруктураЗаказа = ПрочитатьJSON(ЧтениеJSON,Ложь); 
		Исключение
		   Ответ = Новый HTTPСервисОтвет("401");
		   Ответ.УстановитьТелоИзСтроки("Invalid Order parameter:"+Символы.ПС+ОписаниеОшибки());
		КонецПопытки;
	КонецЕсли;
	
	Если Ответ = Неопределено тогда
		Попытка
		Если СборкаИКомплектацияСамовывозовАлгоритмы.ЗарезервироватьТовар(СтруктураЗаказа) тогда
			Ответ = Новый HTTPСервисОтвет(201);
			Ответ.УстановитьТелоИзСтроки("The order is created, the product is reserved.");
		Иначе
			Ответ = Новый HTTPСервисОтвет(202);
			Ответ.УстановитьТелоИзСтроки("There is no rest for reservation, no order has been created.");
		КонецЕсли;
		Исключение
			Ответ = Новый HTTPСервисОтвет(500);
			Ответ.УстановитьТелоИзСтроки("There was an error creating the order:"+Символы.ПС+ОписаниеОшибки());
		КонецПопытки;
	КонецЕсли;
	Возврат Ответ;
КонецФункции