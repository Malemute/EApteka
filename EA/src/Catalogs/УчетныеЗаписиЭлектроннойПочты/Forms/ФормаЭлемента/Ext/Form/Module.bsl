﻿
&НаСервере
Процедура ПроверитьНастройкиНаСервере()
	Справочники.УчетныеЗаписиЭлектроннойПочты.ПодключитсяКЭлектроннойПочтеПоУчетнойЗаписи(Объект.Ссылка);
КонецПроцедуры

&НаКлиенте
Процедура ПроверитьНастройки(Команда)
	ПроверитьНастройкиНаСервере();
КонецПроцедуры
