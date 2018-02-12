
&НаСервере
Процедура ПолучитьДанныеНаСервере(ИмяКоманды)
	Объект.ЗаказыСамовывоз.Очистить();
	Элементы.ЗаказыСамовывоз.Обновить();
	
	Отбор = СтрЗаменить(СокрЛП(Строка(ЭтаФорма.ПолеПоиска)),Символы.НПП,"");
	
	Если ИмяКоманды = "Номер1с" Тогда
		ФильтрПоиска = "2";
	ИначеЕсли ИмяКоманды = "НомерСайт" Тогда
		ФильтрПоиска = "3";
	ИначеЕсли ИмяКоманды = "Телефон" Тогда
		ФильтрПоиска = "4";
	ИначеЕсли ИмяКоманды = "Покупатель" Тогда
		ФильтрПоиска = "1";
	КонецЕсли;	
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	ЗаказДокумент.Ссылка,
	|	ЗаказДокумент.Номер,
	|	ЗаказДокумент.Дата,
	|	ЗаказДокумент.НомерЗаказаСайта,
	|	ЗаказДокумент.Сайт,
	|	ЗаказДокумент.Всего,
	|	ЗаказДокумент.ТипЦены,
	//|	ЗаказДокумент.СтатусЗаказа,
	|	ЗаказДокумент.Пробит,
	|	ЗаказДокумент.Собран,
	|	ЗаказДокумент.ТипДоставки,
	|	ЗаказДокумент.Телефон,
	|	ЗаказДокумент.ДокументОснование,
	|	ЗаказДокумент.ОтправленоСМС,
	|	ЗаказДокумент.Покупатель,
	|	ЗаказДокумент.ДатаДоставки,
	|	ЗаказДокумент.МестПростых,
	|	ЗаказДокумент.МестХолодных,
	|	ЗаказДокумент.ВесЗаказа,
	|	СУММА(ВЫБОР
	|			КОГДА ВозвратОтПокупателя.Ссылка ЕСТЬ NULL 
	|				ТОГДА 0
	|			ИНАЧЕ 1
	|		КОНЕЦ) КАК Возвраты,
	|	ЗаказДокумент.СтатусыОбработкиЗаказа.Наименование КАК СтатусОбработки
	|ПОМЕСТИТЬ втЗаказы
	|ИЗ
	|	РегистрНакопления.ХранениеЗСЯ.Остатки КАК ХранениеЗСЯОстатки
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Документ.Заказ КАК ЗаказДокумент
	|			ЛЕВОЕ СОЕДИНЕНИЕ Справочник.НаклейкиМестЗаказа КАК НаклейкиМестЗаказа
	|			ПО (НаклейкиМестЗаказа.Документ = ЗаказДокумент.Ссылка)
	|			ЛЕВОЕ СОЕДИНЕНИЕ Документ.ВозвратОтПокупателя КАК ВозвратОтПокупателя
	|			ПО ЗаказДокумент.Ссылка = ВозвратОтПокупателя.ДокументОснование
	|				И (ЗаказДокумент.Ссылка.Проведен)
	|		ПО ХранениеЗСЯОстатки.Заказ = ЗаказДокумент.Ссылка
	|ГДЕ
	|	ЗаказДокумент.Проведен
	|	И НЕ ЗаказДокумент.Пробит
	//|	И ЗаказДокумент.СтатусЗаказа = 0
	|	И ЗаказДокумент.Собран
	|	И ЗаказДокумент.ТипДоставки = ЗНАЧЕНИЕ(Перечисление.ТипДоставки.Самовывоз)
	|
	|СГРУППИРОВАТЬ ПО
	|	ЗаказДокумент.Ссылка,
	|	ЗаказДокумент.Номер,
	|	ЗаказДокумент.Дата,
	|	ЗаказДокумент.НомерЗаказаСайта,
	|	ЗаказДокумент.Сайт,
	|	ЗаказДокумент.Всего,
	|	ЗаказДокумент.ТипЦены,
	//|	ЗаказДокумент.СтатусЗаказа,
	|	ЗаказДокумент.Пробит,
	|	ЗаказДокумент.Собран,
	|	ЗаказДокумент.ТипДоставки,
	|	ЗаказДокумент.Телефон,
	|	ЗаказДокумент.Покупатель,
	|	ЗаказДокумент.ДокументОснование,
	|	ЗаказДокумент.ОтправленоСМС,
	|	ЗаказДокумент.ДатаДоставки,
	|	ЗаказДокумент.МестПростых,
	|	ЗаказДокумент.МестХолодных,
	|	ЗаказДокумент.ВесЗаказа
	|
	|ИМЕЮЩИЕ
	|	КОЛИЧЕСТВО(РАЗЛИЧНЫЕ ХранениеЗСЯОстатки.МестоЗаказа) = КОЛИЧЕСТВО(РАЗЛИЧНЫЕ ЕСТЬNULL(НаклейкиМестЗаказа.Ссылка, 0)) И
	|	СУММА(ВЫБОР
	|			КОГДА ВозвратОтПокупателя.Ссылка ЕСТЬ NULL 
	|				ТОГДА 0
	|			ИНАЧЕ 1
	|		КОНЕЦ) = 0
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	втЗаказы.Ссылка,
	|	втЗаказы.Номер,
	|	втЗаказы.Дата,
	|	втЗаказы.НомерЗаказаСайта,
	|	втЗаказы.Сайт,
	|	втЗаказы.Всего,
	|	втЗаказы.ТипЦены,
	//|	втЗаказы.СтатусЗаказа,
	|	втЗаказы.Пробит,
	|	втЗаказы.Собран,
	|	втЗаказы.ТипДоставки,
	|	втЗаказы.Телефон,
	|	втЗаказы.Покупатель,
	|	втЗаказы.ДокументОснование,
	|	втЗаказы.ОтправленоСМС,
	|	втЗаказы.ДатаДоставки КАК ДатаДоставки,
	|	втЗаказы.МестПростых,
	|	втЗаказы.МестХолодных,
	|	втЗаказы.ВесЗаказа,
	|	втЗаказы.СтатусОбработки
	|ПОМЕСТИТЬ втСамовывозы
	|ИЗ
	|	втЗаказы КАК втЗаказы
	|		ЛЕВОЕ СОЕДИНЕНИЕ втЗаказы КАК втЗаказы1
	|		ПО втЗаказы.ДокументОснование = втЗаказы1.Ссылка
	|ГДЕ
	|	втЗаказы1.Ссылка ЕСТЬ NULL 
	|	И ВЫБОР
	|			КОГДА &ТипФильтра = ""1""
	|				ТОГДА втЗаказы.Покупатель ПОДОБНО &Отбор
	|			КОГДА &ТипФильтра = ""2""
	|				ТОГДА втЗаказы.Номер ПОДОБНО &Отбор
	|			КОГДА &ТипФильтра = ""3""
	|				ТОГДА втЗаказы.НомерЗаказаСайта ПОДОБНО &Отбор
	|			КОГДА &ТипФильтра = ""4""
	|				ТОГДА втЗаказы.Телефон ПОДОБНО &Отбор
	|			ИНАЧЕ ИСТИНА
	|		КОНЕЦ
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	втСамовывозы.Ссылка,
	|	втСамовывозы.Номер,
	|	втСамовывозы.Дата,
	|	втСамовывозы.НомерЗаказаСайта,
	|	втСамовывозы.Сайт,
	|	втСамовывозы.Всего,
	|	втСамовывозы.ТипЦены,
	//|	втСамовывозы.СтатусЗаказа,
	|	втСамовывозы.Пробит,
	|	втСамовывозы.Собран,
	|	втСамовывозы.ТипДоставки,
	|	втСамовывозы.Телефон,
	|	втСамовывозы.Покупатель,
	|	втСамовывозы.ДокументОснование,
	|	втСамовывозы.ОтправленоСМС,
	|	втСамовывозы.ДатаДоставки,
	|	втСамовывозы.МестПростых,
	|	втСамовывозы.МестХолодных,
	|	втСамовывозы.ВесЗаказа,
	|	втСамовывозы.СтатусОбработки
	|ИЗ
	|	втСамовывозы КАК втСамовывозы
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ХранениеЗСЯОстатки.Заказ,
	|	ХранениеЗСЯОстатки.ЗСЯ.Зона КАК Зона,
	|	ХранениеЗСЯОстатки.ЗСЯ.Стеллаж КАК Стеллаж,
	|	ХранениеЗСЯОстатки.ЗСЯ.Ячейка КАК Ячейка
	|ИЗ
	|	РегистрНакопления.ХранениеЗСЯ.Остатки(
	|			,
	|			Заказ В
	|				(ВЫБРАТЬ
	|					втСамовывозы.Ссылка
	|				ИЗ
	|					втСамовывозы КАК втСамовывозы)) КАК ХранениеЗСЯОстатки
	|
	|СГРУППИРОВАТЬ ПО
	|	ХранениеЗСЯОстатки.Заказ,
	|	ХранениеЗСЯОстатки.ЗСЯ.Зона,
	|	ХранениеЗСЯОстатки.ЗСЯ.Ячейка,
	|	ХранениеЗСЯОстатки.ЗСЯ.Стеллаж
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	НаклейкиМестЗаказа.Документ КАК Заказ,
	|	ВЫБОР
	|		КОГДА ПОДСТРОКА(НаклейкиМестЗаказа.Наименование, 1, 1) = ""1""
	|			ТОГДА ""Накл""
	|		ИНАЧЕ НаклейкиМестЗаказа.Код
	|	КОНЕЦ КАК КодМестаЗаказа
	|ИЗ
	|	втСамовывозы КАК втСамовывозы
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Справочник.НаклейкиМестЗаказа КАК НаклейкиМестЗаказа
	|		ПО втСамовывозы.Ссылка = НаклейкиМестЗаказа.Документ
	|
	|СГРУППИРОВАТЬ ПО
	|	ВЫБОР
	|		КОГДА ПОДСТРОКА(НаклейкиМестЗаказа.Наименование, 1, 1) = ""1""
	|			ТОГДА ""Накл""
	|		ИНАЧЕ НаклейкиМестЗаказа.Код
	|	КОНЕЦ,
	|	НаклейкиМестЗаказа.Документ"; 
	Запрос.УстановитьПараметр("ТипФильтра",ФильтрПоиска);
	Запрос.УстановитьПараметр("Отбор","%"+Отбор+"%");
	
	МассивРезультатов = Запрос.ВыполнитьПакет();
	Выборка = МассивРезультатов[2].Выбрать();
	ТаблицаЗСЯ = МассивРезультатов[3].Выгрузить();
	ТаблицаКодМестаЗаказа = МассивРезультатов[4].Выгрузить();
	
	Пока Выборка.Следующий() цикл
		НоваяСтрока = Объект.ЗаказыСамовывоз.Добавить();
		НоваяСтрока.Клиент=Выборка.Покупатель;
		НоваяСтрока.НомерДок=Выборка.Номер;
		НоваяСтрока.ДатаДок=Выборка.Дата;
		НоваяСтрока.ТипЦены=Выборка.ТипЦены;
		НоваяСтрока.ДатаДоставки=Выборка.ДатаДоставки;
		НоваяСтрока.НомерСайта=Выборка.НомерЗаказаСайта;
		НоваяСтрока.Сайт=Выборка.Сайт;
		НоваяСтрока.Сумма=Выборка.Всего;
		НоваяСтрока.Телефон=Выборка.Телефон;
		НоваяСтрока.ВесЗаказа = Выборка.ВесЗаказа;
		НоваяСтрока.КолХолодМест = Выборка.МестХолодных;
		НоваяСтрока.КолОбычМест = Выборка.МестПростых;
		НоваяСтрока.СМС = Выборка.ОтправленоСМС; 
		НоваяСтрока.Заказ = Выборка.Ссылка; 
		НоваяСтрока.СтатусОбработки=Выборка.СтатусОбработки;
		НоваяСтрока.ЗСЯ = СформироватьСтрокуЗСЯ(Выборка.Ссылка,ТаблицаЗСЯ);
		НоваяСтрока.НомераПакетов = СформироватьСтрокуКодов(Выборка.Ссылка,ТаблицаКодМестаЗаказа);	
	КонецЦикла; 
	Элементы.ЗаказыСамовывоз.Обновить();
		
КонецПроцедуры

&НаСервере
Функция СформироватьСтрокуКодов(Заказ,ТаблицаКодМестаЗаказа)
	СтрокаМестаЗаказа = "";
	СтрокиМестаЗаказа = ТаблицаКодМестаЗаказа.НайтиСтроки(Новый Структура("Заказ",Заказ));
	ИТ = 0;
	Для каждого строка из СтрокиМестаЗаказа цикл
		СтрокаМестаЗаказа =СтрокаМестаЗаказа+?(ИТ <>0,Символы.ПС,"")+строка.КодМестаЗаказа;
		ИТ = ИТ+1;
	КонецЦикла;
	Возврат СтрокаМестаЗаказа;

КонецФункции

&НаСервере
Функция СформироватьСтрокуЗСЯ(Заказ,ТаблицаЗСЯ)
	СтрокаЗСЯ = "";
	СтрокиЗСЯ = ТаблицаЗСЯ.НайтиСтроки(Новый Структура("Заказ",Заказ));
	ИТ = 0;
	Для каждого строка из СтрокиЗСЯ цикл
		СтрокаЗСЯ =СтрокаЗСЯ+?(ИТ <>0,Символы.ПС,"")+ строка.Зона+"_"+строка.Стеллаж+"_"+строка.Ячейка;
		ИТ = ИТ+1;
	КонецЦикла;
	Возврат СтрокаЗСЯ;
КонецФункции


&НаКлиенте
Процедура ПолучитьДанные(Команда)
	Если СтрДлина(Строка(ЭтаФорма.ПолеПоиска))>=5 Тогда
		ПолучитьДанныеНаСервере(Команда.Имя);
	Иначе
		ПоказатьПредупреждение(,"Необходимо ввести минимум 5 символов в строке поиска!");
	КонецЕсли;
КонецПроцедуры

