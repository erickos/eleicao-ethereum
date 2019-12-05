pragma  solidity  ^0.4.25;

import { Eleicao } from './Eleicao.sol';

contract Base {
    
    mapping (address => uint ) private addressToIndexEleitor;
    address[] public eleitores;
    
    mapping (address => uint ) private addressToIndexEleicao;
    mapping (address => string ) private eleicaoAddressToName;
    address[] public eleicoes;
    
    address private owner;
    
    event EleicaoCreated(address _eleicaoContractAddress, address _owner, string _nome);

    
    constructor() internal {
        
        // Adiciona na primeira posição o endereço invalido, pois 
            // caso o mapping retorne 0 quer dizer que o endereço ainda não é cadastrado
        eleitores.push(0x0);
        eleicoes.push(0x0);
        owner = msg.sender;
    
    }
    
    modifier onlyOwner {
        require(msg.sender == owner, "Somente o dono do contrato pode chamar essa função!");
        _;
    }
    
    function addEleitor( ) public payable {
        // caso nao esteja inscrito adiciona ao mapping e array
        if ( !eleitorEstaInscrito( msg.sender ) && msg.value >= 0.1 ether ) {
            // Adicionando um novo eleitor válido para a lista de eleitores cadastrados
            addressToIndexEleitor[ msg.sender ] = eleitores.length;
            eleitores.push( msg.sender );
            
        }
    }
    
    function eleitorEstaInscrito( address _eleitorAddress ) public view returns (bool) {
        
        // caso o eleitor não esteja no mapping, o mapping[key] retorna 0
        if( addressToIndexEleitor[ _eleitorAddress ] > 0 ) {
            return true;
        }
        return false;
        
    }
    
    function criarEleicao( string _nome ) public payable {
        
        address _novaEleicao = new Eleicao( _nome, msg.sender, eleitores );
        eleicoes.push( _novaEleicao );
        
        EleicaoCreated( _novaEleicao, msg.sender, _nome );
        
    }
    
    function allEleitores() constant returns (address[]) {
        return eleitores;
    }
}


