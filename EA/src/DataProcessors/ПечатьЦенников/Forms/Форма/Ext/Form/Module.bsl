﻿
&НаСервере
Процедура Команда1НаСервере()
	Об = РеквизитФормыВЗначение("Объект");
	Об.ПечатьЦенников().Показать();
	
КонецПроцедуры

&НаКлиенте
Процедура Команда1(Команда)
	Команда1НаСервере();
КонецПроцедуры
