window.addEventListener('load', function () {

    web3Provider = null;
    // Browsers modernos já injetam web3 automaticamente.
    if (window.ethereum) {
        web3Provider = window.ethereum;
        try {
            window.ethereum.enable();
        } catch (error) {
            console.error("User denied account access")
        }
    }
    // Browsers antigos com MetaMask
    else if (window.web3) {
        web3Provider = window.web3.currentProvider;
    }
    // Se não detectar instância web3, conectar ao Ganache local.
    else {
        console.log('No web3? You should consider trying MetaMask!')
        web3Provider = new Web3.providers.HttpProvider('http://localhost:7545');
    }
    web3 = new Web3(web3Provider);
    startApp()

})

var userAccount = null;

function startApp() {
    var eleicaoAddress = "0x0fF7f732f91357A5A5131207B3e15f7AA03713aa";

    eleicao = new web3.eth.Contract( abi, eleicaoAddress );

    web3.eth.getAccounts().then(function (result) { // Promises!
        userAccount = result[0];
        console.log(userAccount);

    })

    console.log(userAccount);

    document.body.innerHTML = userAccount;
}