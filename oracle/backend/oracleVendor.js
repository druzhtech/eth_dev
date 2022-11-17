const options = { uri: process.env.PRICE_URL, json: true };

const start = () => {
    request(options)
        .then(parseData)
        .then(updatePrice)
        .then(restart)
        .catch(error);
};

const parseData = (body) => {
    return new Promise((resolve, reject) => {
        const price = body.main.price.toString();
        resolve({ price });
    });
};

const updatePrice = ({ price }) => {
    return new Promise((resolve, reject) => {
        account().then(account => {
            contract.updatePrice(price, { from: account }, (err, res) => {
                resolve(res);
            });
        });
    });
};

const restart = () => {
    wait(process.env.TIMEOUT).then(start);
};