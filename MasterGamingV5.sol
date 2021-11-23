/**
 *Submitted for verification at BscScan.com on 2021-11-23
*/

pragma solidity >=0.8.0;

// SPDX-License-Identifier: BSD-3-Clause

library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

library EnumerableSet {

    struct Set {
        // Storage of set values
        bytes32[] _values;

        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping (bytes32 => uint256) _indexes;
    }

    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We read and store the value's index to prevent multiple reads from the same storage slot
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) { // Equivalent to contains(set, value)
            
            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            bytes32 lastvalue = set._values[lastIndex];

            set._values[toDeleteIndex] = lastvalue;
            set._indexes[lastvalue] = toDeleteIndex + 1; // All indexes are 1-based

            set._values.pop();

            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        require(set._values.length > index, "EnumerableSet: index out of bounds");
        return set._values[index];
    }

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner,  bytes32(uint(uint160(value))));
    }

    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner,  bytes32(uint(uint160(value))));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner,  bytes32(uint(uint160(value))));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint(_at(set._inner, index))));
    }


    // UintSet

    struct UintSet {
        Set _inner;
    }

    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

   
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }
}

contract Ownable {
  address public owner;

  constructor()  {
    owner = msg.sender;
  }

  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

}

interface TournamentV2 {
    function getNumSponsored(address _sponsor) external view returns(uint);
    function getSponsored(address _sponsor, uint _index) external view returns (string memory, bool, uint[] memory, address[] memory);
    function getSponsorData(address _sponsor) external view returns (uint[] memory);
    function canUnlock(address _dir) external view returns (bool);
    function unlockAll(address _dir) external returns (bool);
    function tournament_type() external view returns (uint);
    function getIsSponsor(address dir) external view returns (bool);
    function getIsGamer(address dir) external view returns (bool);
    function start_date() external view returns (string memory);
    function tournament_name() external view returns (string memory);
    function prizepool() external view returns (uint);
    function playersPerTeam() external view returns (uint);
    function maxParticipants() external view returns (uint);
    function numParticipants() external view returns (uint);
    function register_date() external view returns (uint);
    
    function getGamerPosition(address _gamer) external view returns(uint256);
    function getGamerReward(address _gamer) external view returns(uint256);
}

contract MasterGamingV5 is Ownable {
    using SafeMath for uint;
    using EnumerableSet for EnumerableSet.AddressSet;
    
    address null_address = 0x0000000000000000000000000000000000000000;
    
    struct tournament{
        address contract_address;
        string name;
        bool active;
    }
    
    mapping(uint => tournament) public contractData;
    mapping(address => uint) public index;
    uint public numTournaments;
    
    
    function addContract(address _new, string memory _name) public onlyOwner returns(bool){
        require(index[_new] == 0 );
        numTournaments = numTournaments.add(1);
        index[_new] = numTournaments;
        
        contractData[numTournaments].contract_address = _new;
        contractData[numTournaments].name = _name;
        contractData[numTournaments].active = true;
        
        return true;
    }
    
    function addContractsInBatch(address[] memory _new, string[] memory _names) public onlyOwner returns(bool){
        address current;
        uint aux;
        for(uint i = 0; i < _new.length; i = i.add(1)){
            current = _new[i];
            aux = index[current];
            require(aux == 0);
            numTournaments = numTournaments.add(1);
            
            index[current] = numTournaments;
            contractData[numTournaments].contract_address = current;
            contractData[numTournaments].name = _names[i];
            contractData[numTournaments].active = true;
         } 
        return true;
    }
    
    function removeContract(address _toRemove) public onlyOwner returns(bool){
        uint aux = index[_toRemove];
        require(aux != 0 );
        
        index[_toRemove] = 0;
        contractData[aux].contract_address = null_address;
        contractData[aux].name = "";
        contractData[aux].active = false;
        numTournaments = numTournaments.sub(1);
        return true;
    }
    
    function getContract(uint _index) public view returns (address){
        return contractData[_index].contract_address;
    }
    
    function checkContracts() public view onlyOwner returns (address[] memory, string[] memory, bool[] memory){
        uint length = numTournaments;
        address[] memory _res1 = new address[](length);
        string[] memory _res2 = new string[](length);
        bool[] memory _res3 = new bool[](length);
        for(uint i = 1; i <= length; i = i.add(1)){
           _res1[i.sub(1)] = contractData[i].contract_address;
           _res2[i.sub(1)] = contractData[i].name;
           _res3[i.sub(1)] = contractData[i].active;
        }
        return (_res1, _res2, _res3);
    }
    
    function getContractInfo(uint _index) public view returns (address, string memory, string memory, uint[] memory) {
        address _contract = contractData[_index].contract_address;
        string memory _name = TournamentV2(_contract).tournament_name();
        string memory _date = TournamentV2(_contract).start_date();
        uint[] memory _numbers = new uint [](5);
        _numbers[0] = TournamentV2(_contract).prizepool();
        _numbers[1] = TournamentV2(_contract).playersPerTeam();
        _numbers[2] = TournamentV2(_contract).maxParticipants();
        _numbers[3] = TournamentV2(_contract).numParticipants();
        _numbers[4] = TournamentV2(_contract).register_date();
        return (_contract, _name, _date, _numbers);
    }
      
    function getNumActiveContracts() public view returns (uint){
        uint _res;
        for(uint i = 1; i <= numTournaments; i = i.add(1)){
            if(contractData[i].active){
                _res = _res.add(1);
            }
         }
         return _res;
    }
    
    function getType(address _contract) public view returns (uint){
        return TournamentV2(_contract).tournament_type();
    }
    
    /* 
    @dev returns the total number of teams sponsored by _sponsor 
        used by "getTotalSponsored()"
    */
    function getTotalSponsored(address _sponsor) public view returns (uint){
        uint _res;
        
        address _tournamentAddr;
        for(uint i = 1; i<= numTournaments; i = i.add(1)){
            _tournamentAddr = contractData[i].contract_address;
            _res = _res.add(TournamentV2(_tournamentAddr).getNumSponsored(_sponsor));
        }
        return _res;
    }
    
    /* 
    @dev returns the number of teams sponsored by _sponsor in a tournament
    */
    function getTotalSponsoredTour(address _sponsor, address _tour) public view returns (uint){
    
        return (TournamentV2(_tour).getNumSponsored(_sponsor));
    }
    
    /* 
    @dev returns the data for all the teams sponsored by _sponsor 
    */
    function getUserData( address _sponsor) public view returns (string[] memory, bool[] memory, uint[][] memory, address[][] memory){
        uint _tam = getTotalSponsored(_sponsor);
        string[] memory _names = new string[](_tam);
        bool[] memory _locked = new bool[](_tam);
        uint[][] memory _nums = new uint[][](_tam);
        address[][] memory _players = new address[][](_tam);
        address _tournamentAddr;
        uint _indexAux;
        for(uint i = 1; i <= numTournaments; i = i.add(1)){
            _tournamentAddr = contractData[i].contract_address;
            for(uint j = 0; j< TournamentV2(_tournamentAddr).getNumSponsored(_sponsor); j = j.add(1)){
                (_names[_indexAux], _locked[_indexAux], _nums[_indexAux] , _players[_indexAux]) = TournamentV2(_tournamentAddr).getSponsored(_sponsor, j);
                _indexAux = _indexAux.add(1);
            }
         }
         
         return (_names, _locked, _nums, _players);
        
    }
    
    function getSponsorTotalRewards( address _sponsor) public view returns (uint, uint){
        uint _tam = getTotalSponsored(_sponsor);
        uint[][] memory _nums = new uint[][](_tam);
        
        uint _totalReward;
        uint totalTeamsRewards;
        
        address _tournamentAddr;
        uint _indexAux;
        for(uint i = 1; i <= numTournaments; i = i.add(1)){
            _tournamentAddr = contractData[i].contract_address;
            for(uint j = 0; j< TournamentV2(_tournamentAddr).getNumSponsored(_sponsor); j = j.add(1)){
                (, , _nums[_indexAux] ,) = TournamentV2(_tournamentAddr).getSponsored(_sponsor, j);
                _totalReward = _totalReward.add(_nums[_indexAux][2]);
                totalTeamsRewards = totalTeamsRewards.add(_nums[_indexAux][1]);
                _indexAux = _indexAux.add(1);
            }
         }
         
         return (_totalReward, totalTeamsRewards);
        
    }
  
    /*
    @dev returns the data for all the teams sponsored by _sponsor in _tour tournament
    */
    function getUserDataTournament( address _sponsor, address _tour) public view returns (string[] memory, bool[] memory, uint[][] memory, address[][] memory){
        uint _tam = TournamentV2(_tour).getNumSponsored(_sponsor);
        string[] memory _names = new string[](_tam);
        bool[] memory _locked = new bool[](_tam);
        uint[][] memory _nums = new uint[][](_tam);
        address[][] memory _players = new address[][](_tam);
        
        uint _indexAux;
        for(uint j = 0; j< _tam; j = j.add(1)){
            (_names[_indexAux], _locked[_indexAux], _nums[_indexAux] , _players[_indexAux]) = TournamentV2(_tour).getSponsored(_sponsor, j);
            _indexAux = _indexAux.add(1);
        }
         
         return (_names, _locked, _nums, _players);
        
    }
    
    /*
    @dev@ returns the total number of tournaments in which _sponsor is a sponsor 
          used by "getSponsorData()"
    */
    function getNumTournamentsIn(address _sponsor) public view returns (uint){
        uint _res;
        address _tournamentAddr;
        for(uint i = 1; i <= numTournaments; i = i.add(1)){
            _tournamentAddr = contractData[i].contract_address;
            if(TournamentV2(_tournamentAddr).getIsSponsor(_sponsor)){
                _res = _res.add(1);
            }
        }
        return _res;
    }
    
    /* 
    @dev returns the sponsor data for all the tournaments 
    */
    function getSponsorData( address _sponsor) public view returns (uint[][] memory){
        require(getNumTournamentsIn(_sponsor) > 0 , "Not a sponsor.");
        
        uint _tam = getNumTournamentsIn(_sponsor);
        uint[][] memory _data = new uint[][](_tam);
        
        address _tournamentAddr;
        uint _indexAux;
        for(uint i = 1; i <= numTournaments; i = i.add(1)){
            _tournamentAddr = contractData[i].contract_address;
            if(contractData[i].active){
                _data[_indexAux] = TournamentV2(_tournamentAddr).getSponsorData(_sponsor);
                _indexAux = _indexAux.add(1);
            }
            
         }
         
         return _data;
    }
    
    function isSponsorOrGamer(address _dir) public view returns (bool[] memory, bool[] memory){
        
         bool[] memory _isSponsor = new bool[](numTournaments);
         bool[] memory _isGamer = new bool[](numTournaments);
         
         address _tournamentAddr;
         
         for(uint i = 1; i <= numTournaments; i = i.add(1)){
             //Check if is a sponsor
             _tournamentAddr = contractData[i].contract_address;
             if(TournamentV2(_tournamentAddr).getIsSponsor(_dir) && contractData[i].active){
                 _isSponsor[i.sub(1)] = true;
             }else{
                 _isSponsor[i.sub(1)] = false;
             }
             //Check if is a gamer
             if(TournamentV2(_tournamentAddr).getIsGamer(_dir) && contractData[i].active){
                 _isGamer[i.sub(1)] = true;
             }else{
                 _isGamer[i.sub(1)] = false;
             }
            
           
         }
         return (_isSponsor, _isGamer);
    }
    
    /*
    @dev@ returns the total number of tournaments in which _gamer is a gamer 
    */
    function getNumTournamentsInGamer(address _gamer) public view returns (uint){
        uint _res;
        address _tournamentAddr;
        for(uint i = 1; i <= numTournaments; i = i.add(1)){
            _tournamentAddr = contractData[i].contract_address;
            if(TournamentV2(_tournamentAddr).getIsGamer(_gamer) && contractData[i].active){
                _res = _res.add(1);
            }
        }
        return _res;
    }
    
    function getGamerData(address _gamer) public view returns (uint, uint, uint[] memory){
        uint _numTours = getNumTournamentsInGamer(_gamer);
        uint _reward;
        uint _teamRewards;
        uint[] memory _positions = new uint[](_numTours);
        uint _indexAux;
        address _tournamentAddr;
        for(uint i = 1; i <= numTournaments; i = i.add(1)){
            _tournamentAddr = contractData[i].contract_address;
            if(TournamentV2(_tournamentAddr).getIsGamer(_gamer) && contractData[i].active){
                _reward = _reward.add(TournamentV2(_tournamentAddr).getGamerReward(_gamer));
                _teamRewards = _teamRewards.mul(TournamentV2(_tournamentAddr).playersPerTeam());
                _positions[_indexAux] = TournamentV2(_tournamentAddr).getGamerPosition(_gamer);
                _indexAux = _indexAux.add(1);
                
            }
        }
        return (_numTours, _reward, _positions);
    }
    
    function getGamerDataTournament(address _gamer, address _tour) public view returns (uint, uint){
        
        uint _reward;
        uint _position;
        
        uint _indexAux = index[_tour];
        
        if(TournamentV2(_tour).getIsGamer(_gamer) && contractData[_indexAux].active){
            _reward = TournamentV2(_tour).getGamerReward(_gamer);
            _position = TournamentV2(_tour).getGamerPosition(_gamer);
        }
        
        return (_reward, _position);
    }
    
}