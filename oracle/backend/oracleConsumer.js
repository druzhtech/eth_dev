const consume = () => {
    contract.PriceUpdate((error, result) => {
        console.log("NEW PRICE DATA EVENT ON SMART CONTRACT");
        console.log("BLOCK NUMBER: ");
        console.log(" " + result.blockNumber);
        console.log("Price DATA: ");
        console.log(result.args);
        console.log("\n");
    });
}