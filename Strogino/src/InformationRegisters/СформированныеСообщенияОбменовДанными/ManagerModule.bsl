
// Функция - Получить следующее сообщение для выгрузки
//     Возвращает следующее сообщение, требующее выгрузки
//
// Параметры:
//  УзелИнформационнойБазы	 - ПланыОбменаСсылка - ссылка узла плана обмена
// 
// Возвращаемое значение:
//   - Структура,Неопределено - Неопределено, если нет сообщений для выгрузки,
//                              если есть сообщение, требующее выгрузки, то возвращается Структура с описанием сообщения
//
Функция ПолучитьСледующееСообщениеДляВыгрузки( УзелИнформационнойБазы ) Экспорт
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр( "УзелИнформационнойБазы", УзелИнформационнойБазы );
	
	// сначала поищем наличие сообщений вне очереди
	Запрос.Текст =
	"ВЫБРАТЬ
	|	СформированныеСообщенияОбменовДаннымиСрезПервых.*
	|ИЗ
	|	РегистрСведений.СформированныеСообщенияОбменовДанными.СрезПервых(
	|			,
	|			ВнеОчередиСообщений = ИСТИНА
	|				И УзелИнформационнойБазы = &УзелИнформационнойБазы
	|				И Выгружено = ЛОЖЬ) КАК СформированныеСообщенияОбменовДаннымиСрезПервых";
	
	РезультатЗапроса = Запрос.Выполнить();
	
	Если Не РезультатЗапроса.Пустой() Тогда
		Возврат ОбщегоНазначения.РезультатЗапросаВСтруктуру( РезультатЗапроса );
	КонецЕсли;
	
	// если нет сообщений вне очереди, то попытаемся выбрать следующее сообщение в очереди
	Запрос.Текст =
	"ВЫБРАТЬ
	|	СформированныеСообщенияОбменовДаннымиСрезПоследних.*
	|ИЗ
	|	РегистрСведений.СформированныеСообщенияОбменовДанными.СрезПоследних(
	|			,
	|			ВнеОчередиСообщений = ЛОЖЬ
	|				И УзелИнформационнойБазы = &УзелИнформационнойБазы) КАК СформированныеСообщенияОбменовДаннымиСрезПоследних
	|ГДЕ
	|	СформированныеСообщенияОбменовДаннымиСрезПоследних.Выгружено = ЛОЖЬ";
	
	РезультатЗапроса = Запрос.Выполнить();
	
	Если Не РезультатЗапроса.Пустой() Тогда
		Возврат ОбщегоНазначения.РезультатЗапросаВСтруктуру( РезультатЗапроса );
	КонецЕсли;
	
	// если сообщений нет, то возвращаем Неопределено
	Возврат Неопределено;
	
КонецФункции

// Процедура - Обновить добавить запись
//      Обновляет или добавляет запись в регстр
//
// Параметры:
//  СтруктураЗначенийЗаписи	 - Структура - структура, содержащая значения записи, обязательно должна содержать значения всех измерений
//
Процедура ОбновитьДобавитьЗапись( СтруктураЗначенийЗаписи ) Экспорт
	
	НаборЗаписей = РегистрыСведений.СформированныеСообщенияОбменовДанными.СоздатьНаборЗаписей();
	
	Для Каждого Отбор Из НаборЗаписей.Отбор Цикл
		Отбор.Установить( СтруктураЗначенийЗаписи[ Отбор.Имя ] );
	КонецЦикла;
	
	НаборЗаписей.Прочитать();
	
	Если НаборЗаписей.Количество() = 0 Тогда
		Запись = НаборЗаписей.Добавить();
	Иначе
		Запись = НаборЗаписей[0];
	КонецЕсли;
	
	ЗаполнитьЗначенияСвойств( Запись, СтруктураЗначенийЗаписи );
	
	НаборЗаписей.Записать( Истина );
	
КонецПроцедуры
