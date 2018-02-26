﻿
#Область ОбработчикиСобытий

&НаКлиенте
Процедура ОбработкаКоманды(ПараметрКоманды, ПараметрыВыполненияКоманды)
	
	Отбор = Новый Структура;
	Отбор.Вставить("Контракт", ПараметрКоманды);
	
	ПараметрыФормы = Новый Структура("Отбор", Отбор);
	ОткрытьФорму(
		"Документ.УстановкаУчетныхЦенКонтрактов.ФормаСписка",
		ПараметрыФормы,
		ПараметрыВыполненияКоманды.Источник,
		ПараметрыВыполненияКоманды.Уникальность,
		ПараметрыВыполненияКоманды.Окно,
		ПараметрыВыполненияКоманды.НавигационнаяСсылка);
	
КонецПроцедуры

#КонецОбласти