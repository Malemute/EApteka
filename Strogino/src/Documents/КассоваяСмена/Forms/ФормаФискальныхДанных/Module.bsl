
#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Если Параметры.Свойство("КассоваяСмена") Тогда
		
		КассоваяСмена = Параметры.КассоваяСмена;
		
		Запрос = Новый Запрос();
		Запрос.Текст = 
		"ВЫБРАТЬ
		|	КассоваяСмена.ФДОЗакрытииСмены КАК ФДОЗакрытииСмены
		|ИЗ
		|	Документ.КассоваяСмена КАК КассоваяСмена
		|ГДЕ
		|	КассоваяСмена.Ссылка = &КассоваяСмена";
		Запрос.УстановитьПараметр("КассоваяСмена", КассоваяСмена);
		
		Результат = Запрос.Выполнить().Выбрать();
		
		Результат.Следующий();
		
		XMLСтрока = Результат.ФДОЗакрытииСмены.Получить();
		Если XMLСтрока = Неопределено Или Не ТипЗнч(XMLСтрока) = Тип("Строка") Или XMLСтрока = "" Тогда
			Отказ = Истина;
			ТекстПредупреждения = НСтр("ru = 'Нет фискальных данных'");
		Иначе
			ЗаполнитьДеревоЗначенийПоXMLСтроке(ДеревоВсехДанных, XMLСтрока);
		КонецЕсли;
		
	Иначе
		ТекстПредупреждения = НСтр("ru = 'Форма фискальных данных пердназначена для открытия из элемента Кассовой смены'");
		ВызватьИсключение ТекстПредупреждения;
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаСервере
Процедура ЗаполнитьДеревоЗначенийПоXMLСтроке(ДеревоВсехДанных, XMLСтрока)
	
	ЧтениеXML = Новый ЧтениеXML;
	ЧтениеXML.УстановитьСтроку(XMLСтрока);
	
	ЗаполнитьЭлементыИзЧтенияXML(ЧтениеXML, ДеревоВсехДанных);
	
КонецПроцедуры

&НаСервере
Процедура ЗаполнитьЭлементыИзЧтенияXML(ЧтениеXML, ТекущийЭлементДерева)
	
	Пока ЧтениеXML.Прочитать() Цикл
		
		Если ЧтениеXML.ТипУзла = ТипУзлаXML.НачалоЭлемента Тогда
			
			НовыйЭлемент = ТекущийЭлементДерева.ПолучитьЭлементы().Добавить();
			НовыйЭлемент.Реквизит = ЧтениеXML.Имя;
			НовыйЭлемент.Значение = ЧтениеXML.Значение;
			
			ЗаполнитьАтрибутыИзЧтенияXML(ЧтениеXML, НовыйЭлемент);
			
			ЗаполнитьЭлементыИзЧтенияXML(ЧтениеXML, НовыйЭлемент);
			
		ИначеЕсли ЧтениеXML.ТипУзла = ТипУзлаXML.Текст Тогда
			
			ТекущийЭлементДерева.Значение = ЧтениеXML.Значение;
			
		ИначеЕсли ЧтениеXML.ТипУзла = ТипУзлаXML.КонецЭлемента Тогда
			
			Прервать;
			
		КонецЕсли;
		
	КонецЦикла;
	
КонецПроцедуры

&НаСервере
Процедура ЗаполнитьАтрибутыИзЧтенияXML(ЧтениеXML, ТекущийЭлементДерева)
	
	Если Не ЧтениеXML.КоличествоАтрибутов() = 0 Тогда
		
		Для НомерАтрибута = 0 По ЧтениеXML.КоличествоАтрибутов() - 1 Цикл
			НовыйЭлемент = ТекущийЭлементДерева.ПолучитьЭлементы().Добавить();
			НовыйЭлемент.Реквизит = ЧтениеXML.ИмяАтрибута(НомерАтрибута);
			НовыйЭлемент.Значение = ЧтениеXML.ЗначениеАтрибута(НомерАтрибута);
		КонецЦикла;
		
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти
