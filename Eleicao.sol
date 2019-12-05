pragma  solidity  ^0.4.25;

contract Eleicao {
    
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
    
    // estruturas para controle de eleitores
    mapping (address => uint ) private eleitoresAvailableToVote;
    address[] private listaEleitores;
    
    // marca o fim da eleição
    bool private eleicaoFinalizada = false;
    
    // informacoes gerais da eleicao
    string private tituloEleicao;
    address public eleicaoOwner;
    
    
    function Eleicao( string _tituloEleicao, address _owner, address[] _listaEleitores ) public {
   
        tituloEleicao  = _tituloEleicao;
        eleicaoOwner   = _owner;
        listaEleitores = _listaEleitores;
        candidatos.push(0x0);  // endereço invalido para candidatos
        
        // constroi um mapping de eleitores validos, para que assim que votem sejam retirados
        for( uint i=1; i < listaEleitores.length; i++ ) {
            eleitoresAvailableToVote[ listaEleitores[i] ] = i;
        }
   
    }
    
    modifier onlyEleicaoOwner {
        
        require(msg.sender == eleicaoOwner, "Somente o dono da eleição pode chamar essa função!");
        _;
        
    }
    
    function votar( address _candidatoAddress ) public {
        
        require( eleitoresAvailableToVote[ msg.sender ] != 0, "Eleitor já votou ou não é autorizado a participar desta eleição");
        require( candidatoEstaInscrito( _candidatoAddress ), "Candidato solicitado não está inscrito" );
        require( msg.sender != _candidatoAddress, "Não é possível votar em si mesmo" );
        
        addressToCandidato[ _candidatoAddress ].qtdVotos++; // vota no candidato
        delete eleitoresAvailableToVote[ msg.sender ]; // apos o voto, deleta o eleitor do mapping de eleitores validos

    }
    
    function addCandidato( string _nome ) public payable {
        // pagando 1 ou mais ether o endereço se torna candidato na eleição
        if( msg.sender != 0x0 && !candidatoEstaInscrito( msg.sender ) && msg.value >= 1 ether ) {
            // Adicionando um novo candidato para a eleição
            addressToIndexCandidato[ msg.sender ] = candidatos.length;
            addressToCandidato[ msg.sender ] = Candidato( _nome, 0 );
            candidatos.push( msg.sender );
        }
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
            if( addressToCandidato[ addressVencedor ].qtdVotos < addressToCandidato[ candidatos[i] ].qtdVotos ) {
                addressVencedor = candidatos[i];
            }
        }
    }
    
    function finalizarEleicao( ) public onlyEleicaoOwner {
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