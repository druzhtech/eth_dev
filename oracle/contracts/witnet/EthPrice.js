import * as Witnet from "witnet-requests"

// Как только этот запрос будет принят оракулом Witnet, 
// эта часть будет инструктировать его посетить API Binance, 
// разобрать результат как объект JSON, получить поле цены как число 
// с плавающей точкой, умножить его на 10 000 00 и округлить результат до ближайшего целого числа.
const binance = new Witnet.Source("https://api.binance.US/api/v3/trades?symbol=ETHUSD")
    .parseJSONMap()
    .getFloat("price")
    .multiply(10 ** 6)
    .round()

// Добавление второго источника данных API (например, Coinbase) 
// требует только добавления нового блока Witnet.Source под предыдущим:
const coinbase = new Witnet.Source("https://api.coinbase.com/v2/exchange-rates?currency=ETH")
    .parseJSONMap()
    .getMap("data")
    .getMap("rates")
    .getFloat("USD")
    .multiply(10 ** 6)
    .round()

// Ещё
const kraken = new Witnet.Source("https://api.kraken.com/0/public/Ticker?pair=ETHUSD")
    .parseJSONMap()
    .getMap("result")
    .getMap("XETHZUSD")
    .getArray("a")
    .getFloat(0)
    .multiply(10 ** 6)
    .round()

// Указать как агрегировать различные источники данных
// Децентрализоация на основе источников данных
// При объединении нескольких источников данных всегда есть два этапа:
// Фильтр: указать, как проверить, является ли точка данных хорошей.
// Редуктор: указать, как объединить результаты, полученные  из нескольких источников данных. 
// Часто используют этот агрегатор, который, как правило, 
// очень хорошо работает для случаев использования ценовой ленты, 
// поскольку он сначала удаляет все точки данных, 
// которые слишком далеко отстоят от среднего значения более 
// чем в 1,5 раза от стандартного отклонения набора, 
// а затем просто вычисляет среднее среднее значение точек данных, прошедших фильтр:
const aggregator = Witnet.Aggregator.deviationAndMean(1.5)

// 7 определяние что считается точными данными
const tally = Witnet.Tally.deviationAndMean(2.5)

// Сборка запроса
// setQuorum 10 - указывает, что мы хотим, чтобы 10 узлов сети Witnet были случайно и тайно выбраны для решения этого запроса
// setQuorum 51 - чтобы запрос прервался, если менее 51% из них (6 из 10) согласны с результатом
// setFees 5 * 10 ** 9 указывает, сколько платить узлам-свидетелям за решение запроса (5 Wit за каждый узел) 
// setFees 10 ** 9 сколько платить майнерам за включение внутренних транзакций запроса в блоки (1 Wit за каждую транзакцию).
// setCollateralтребует, чтобы узлы-свидетели сделали ставки по 50 Wit каждый, чтобы участвовать в решении запроса
const query = new Witnet.Query()
    .addSource(binance)
    .addSource(coinbase)
    .addSource(kraken)
    .setAggregator(aggregator)
    .setTally(tally)
    .setQuorum(10, 51)
    .setFees(5 * 10 ** 9, 10 ** 9)
    .setCollateral(50 * 10 ** 9)

// const testPostSource = new Witnet.HttpPostSource(
//     "https://httpbin.org/post",
//     "This is the request body",
//     {
//         "Header-Name": "Header-Value"
//     }
// )
//     .parseJsonMap()
//     .getMap("headers")
//     .getString("Header-Name")

export { query as default }