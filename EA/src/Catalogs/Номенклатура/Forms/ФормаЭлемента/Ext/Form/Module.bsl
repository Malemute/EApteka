﻿
&НаКлиенте
Процедура ПриОткрытии(Отказ)
	ЗСЯ.Параметры.УстановитьЗначениеПараметра("Номенклатура",Объект.Ссылка);
	Элементы.ЗСЯ.Обновить();
КонецПроцедуры

&НаКлиенте
Процедура ПослеЗаписи(ПараметрыЗаписи)
	ЗСЯ.Параметры.УстановитьЗначениеПараметра("Номенклатура",Объект.Ссылка);
	Элементы.ЗСЯ.Обновить();
КонецПроцедуры
