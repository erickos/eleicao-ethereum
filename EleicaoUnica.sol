pragma  solidity  ^0.4.25;

contract EleicaoUnica {
    
    struct Candidato {
        string nome;
        uint qtdVotos;
    }
    
    // estruturas para registro e controle de candidatos
    mapping (address =>  uint ) private addressToIndexCandidato;
    mapping (address => Candidato) private addressToCandidato;
    address[] private candidatos;
    
    // endereço do candidato vencedor
    address private addressVencedor;
    // marca o fim da eleição
    bool private eleicaoFinalizada = false;
    
    // estruturas para registro e controle de eleitores
    mapping (address => uint ) private addressToIndexEleitor;
    mapping (address => uint ) private addressToUnavailableToVoteEleitor;
    address[] private eleitores;
    
    // criador do contrato
    address private owner;
    
    constructor() public {
        
        // Adiciona na primeira posição o endereço invalido, pois 
            // caso o mapping retorne 0 quer dizer que o endereço ainda não é cadastrado
        eleitores.push(0x0);
        candidatos.push(0x0);
        owner = msg.sender;
    
    }
    
    modifier onlyOwner {
        require(msg.sender == owner, "Somente o dono do contrato pode chamar essa função!");
        _;
    }
    
    function addEleitor( ) public payable {
        // caso nao esteja inscrito adiciona ao mapping e array
        require( !eleitorEstaInscrito( msg.sender ), "Erro. Eleitor ja esta cadastrado" );
        require( msg.value >= 0.1 ether, "Taxa de inscricao para votar deve ser maior que 0.1 ether" );
        
        // Adicionando um novo eleitor válido para a lista de eleitores cadastrados
        addressToIndexEleitor[ msg.sender ] = eleitores.length;
        eleitores.push( msg.sender );
            
    }
    
    function eleitorEstaInscrito( address _eleitorAddress ) public view returns (bool) {
        
        // caso o eleitor não esteja no mapping, o mapping[key] retorna 0
        if( addressToIndexEleitor[ _eleitorAddress ] > 0 && _eleitorAddress != 0x0 ) {
            return true;
        }
        return false;
        
    }
    
    function eleitorPodeVotar( address _eleitorAddress ) public view returns (bool) {
        
        // se o eleitor nao estiver nesse mapping entao ele pode votar
        if( addressToUnavailableToVoteEleitor[ _eleitorAddress ] == 0 ) {
            return true;
        }
        
        return false;
    }
    
    function allEleitores() public constant returns (address[]) {
        return eleitores;
    }
    
    
    function votar( address _candidatoAddress ) public {
        
        require( eleitorPodeVotar( msg.sender ), "Eleitor já votou ou não é autorizado a participar desta eleição");
        require( candidatoEstaInscrito( _candidatoAddress ), "Candidato solicitado não está inscrito" );
        require( msg.sender != _candidatoAddress, "Não é possível votar em si mesmo" );
        
        addressToCandidato[ _candidatoAddress ].qtdVotos++; // vota no candidato
        addressToUnavailableToVoteEleitor[ msg.sender ] = 1; // apos o voto, marca o eleitor no mapping de indisponiveis

    }
    
    
    function addCandidato( string _nome ) public payable {
        
        // pagando 1 ou mais ether o endereço se torna candidato na eleição
        require( msg.sender != 0x0, "Deve ser um endereço valido, diferente de 0x0");
        require( !candidatoEstaInscrito( msg.sender ), "Nao eh possivel cadastrar o mesmo candidato mais de uma vez"); 
        require( msg.value >= 1 ether, "A taxa deve ser de no mínimo 1 ether para realizar o cadastro" );
        
        // Adicionando um novo candidato para a eleição
        addressToIndexCandidato[ msg.sender ] = candidatos.length;
        addressToCandidato[ msg.sender ] = Candidato( _nome, 0 );
        candidatos.push( msg.sender );
        
    }
    
    function candidatoEstaInscrito( address _candidatoAddress ) public view returns (bool) {
        
        // caso o candidato nao esteja no mapping, o mapping[key] retorna 0;
        if( addressToIndexCandidato[ _candidatoAddress ] > 0 ) {
            return true;
        }
        
        return false;
        
    }
    
    function calcularResultado( ) private {
        addressVencedor = candidatos[1]; //primeiro endereço cadastrado
        
        for( uint i=2; i<candidatos.length; i++ ) {
            if( addressToCandidato[ addressVencedor ].qtdVotos < addressToCandidato[ candidatos[ i ] ].qtdVotos ) {
                addressVencedor = candidatos[ i ];
            }
        }
    }
    
    function finalizarEleicao() public onlyOwner {
        calcularResultado();
        eleicaoFinalizada = true;
    }
    
    function resgatarCandidatoEleito( ) public view returns ( string nomeCandidato, uint qtdVotosCandidato ) {
        return ( addressToCandidato[ addressVencedor ].nome, addressToCandidato[ addressVencedor ].qtdVotos );
    }
    
    function todosCandidatos() public constant returns (address[]) {
        return candidatos;
    }
    
}