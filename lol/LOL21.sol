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
  address public referee;
  address public operator;
  
  constructor()  {
    referee = msg.sender;
    operator = msg.sender;
  }
  
  function transferOwnership(address _new) public onlyReferee returns(bool){
      referee = _new;
      return true;
  }
  
  function changeOperator(address _new) public onlyReferee returns(bool){
      operator = _new;
      return true;
  }
  
  modifier onlyReferee() {
    require(msg.sender == referee);
    _;
  }
  modifier onlyOperator() {
    require(msg.sender == referee || msg.sender == operator);
    _;
  }

}

interface Lib {
    function transfer(address, uint) external returns (bool);
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool success);
    function balanceOf(address) external returns (uint);
    function addPoints(address _sponsor, uint _points) external returns(bool);
}

contract LOL21 is Ownable {
    using SafeMath for uint;
    using EnumerableSet for EnumerableSet.AddressSet;
    
    /* Constants and Mains */
    uint constant tournament_type = 1 ;
    string public constant tournament_name = 'LOL #21';
    string public constant start_date =  '12th Mar - 16:00 UTC';
    uint public prizepool = 0;
    uint public poolPerUser = 15000000000000000000;
    
    uint public constant timeLocked = 30 days;
    uint public constant timePaying = 5 days;
    uint public constant amountToLock = 2000000000000000000000;
    uint public pointsPerRegistration = 8;
    
    //uint public constant percentage = 450;
    uint public constant playersPerTeam = 2;
    uint public maxParticipants = 128;
    uint public numParticipants;
    
    /* UNIX date when register finish: 11th Mar 23:59 UTC */
    uint public register_date = 1647043199;
    
    /* Library */
    address private constant tokenAddress = 0x612C49b95c9121107BE3A2FE1fcF1eFC1C4730AD;
    address private sponsorLeague = 0xfa6124D12a6e673B9d9aF6Cf8d81c8Be7d8E2b08; 
    
    /* Team Data */
    struct teamSponsored {
        string name;
        uint256 timeLock;
        bool locked;
        uint256 reward_sponsor; // reward of sponsor
        uint256 reward_player; // reward of each player
        uint256 reward_team; // reward of team
        uint position;
        address[] players;
        string creatorCode;
        uint percentageSponsor;
        uint prevPercentageSponsor;
        bool accepted;
    }
    
    /* Sponsor Data */
    struct sponsor_data{
        uint256 numSponsored;
        uint256 total_reward; // total reward of all sponsored teams
        uint256 total_reward_sponsor; // total SPONSOR reward of all sponsored teams
        uint256 multiplierSponsor;
        uint256 multiplierGamer;
    }
    
    /* ******************** */
    /* Used for the SPONSOR */
    /* ******************** */
    
    mapping(uint => sponsor_data) public data;
    mapping(uint => mapping (uint => teamSponsored )) public sponsored;
    mapping(uint => mapping (uint => uint)) public team_score;
    mapping(uint256 => address) public sponsor_addr;
    mapping(address => uint256) public sponsor_index;
    uint256 public numSponsors;
    /* Used only for Top 5 */
    mapping(address => uint256) public extra_points_league;
    
    /* ******************** */
    /* Used for the GAMER */
    /* ******************** */
    
    mapping(uint256 => address) public gamer_addr;
    mapping(address => uint256) public gamer_index;
    uint256 public numGamers;
    mapping(address => uint256) public reward_gamer;
    mapping(address => uint256) public position_gamer;
    
    
    /* Aux */
    uint public total_score;
    uint256 public totalLockedAmount;
    uint256 public numPrematureUnlocks;
    bool public paused;
    uint256[] extraPoints = [25,20,15];
    uint256 public nameFee = 50000000000000000000;
    
    /* FUNCTIONS */
    function changeStatus(bool _status) public onlyOperator returns(bool){
        require(paused != _status);
        paused = _status;    
        return true;
    }
    
    function setPrizePool(uint256 _new) public onlyReferee returns(bool){
        prizepool = _new;
        return true;
    }
    
    function getGamerPosition(address _gamer) public view returns(uint256){
        if(!getIsGamer(_gamer)) return 0;
        return position_gamer[_gamer];
    }
    
    function getGamerReward(address _gamer) public view returns(uint256){
        if(!getIsGamer(_gamer)) return 0;
        return reward_gamer[_gamer];
    }
    
    function setMaxparticipants(uint256 _new) public onlyReferee returns(bool){
        maxParticipants = _new;
        return true;
    }
    
    function setRegisterDate(uint256 _new) public onlyReferee returns(bool){
        register_date = _new;
        return true;
    }
    
    function getNumSponsored(address _sponsor) public view returns(uint){
        uint aux_index = sponsor_index[_sponsor];
        return data[aux_index].numSponsored;
    }
    
    function getSponsored(address _sponsor, uint _index) public view returns (string memory, bool, uint[] memory, address[] memory) {
        uint aux_index = sponsor_index[_sponsor];
        require(_index < data[aux_index].numSponsored, "Index out of bounds.");
        
        uint[] memory _nums = new uint[](5);
        _nums[0] = sponsored[aux_index][_index].timeLock;
        _nums[1] = sponsored[aux_index][_index].reward_sponsor;
        _nums[2] = sponsored[aux_index][_index].reward_player;
        _nums[3] = sponsored[aux_index][_index].reward_team;
        _nums[4] = sponsored[aux_index][_index].position;
        
        return (sponsored[aux_index][_index].name, sponsored[aux_index][_index].locked, _nums, sponsored[aux_index][_index].players  );
    }

    function getSponsorData(address _sponsor) public view returns (uint[] memory){
        uint aux_index = sponsor_index[_sponsor];
        uint[] memory _res = new uint[](5);
        _res[0] = data[aux_index].numSponsored;
        _res[1] = data[aux_index].total_reward;
        _res[2] = data[aux_index].total_reward_sponsor;
        _res[3] = data[aux_index].multiplierSponsor;
        _res[4] = data[aux_index].multiplierGamer;
        return (_res);
    }
    
    function addParticipant(address _sponsor, address[] calldata _players, string memory _name, bool _invite, uint _sponsorPercent, string memory _ref) public returns (bool){
        require(!paused, "Tourney paused");
        require(_sponsor == msg.sender || referee == msg.sender);
        require(block.timestamp < register_date, "Registrations are closed.");
        require(numParticipants < maxParticipants, "Max teams reached");
        require(_players.length == playersPerTeam, "Incorrect number of gamers");
        require(_sponsorPercent > 29 && _sponsorPercent < 46 && _sponsorPercent % 5 == 0);
        uint aux_index = sponsor_index[_sponsor];
        if(aux_index == 0){
            numSponsors = numSponsors.add(1);
            sponsor_index[_sponsor] = numSponsors;
            aux_index = numSponsors;
            sponsor_addr[numSponsors] = _sponsor;
            
        }
        uint _newIndex = data[aux_index].numSponsored;
        
        if(_invite){
            require(msg.sender == referee);
        }else{
            require(Lib(tokenAddress).transferFrom(_sponsor, address(this) , amountToLock ) , "Error locking tokens");     
            sponsored[aux_index][_newIndex].locked = true;
            totalLockedAmount = totalLockedAmount.add(amountToLock);
        }
        sponsored[aux_index][_newIndex].timeLock = block.timestamp;
        
        //Sponsors League
        require(Lib(sponsorLeague).addPoints(_sponsor, pointsPerRegistration), "Sponsor League error");
        extra_points_league[_sponsor] = extra_points_league[_sponsor].add(pointsPerRegistration);

        uint _index = data[aux_index].numSponsored;
        
        sponsored[aux_index][_index].players = new address[](playersPerTeam);
        for(uint i = 0; i < playersPerTeam; i = i.add(1)){
            require(!getIsGamer(_players[i]) , "Gamer already registered");
            numGamers = numGamers.add(1);
            gamer_addr[numGamers] = _players[i];
            gamer_index[_players[i]] = numGamers;
            sponsored[aux_index][_index].players[i] = _players[i];
        }

        sponsored[aux_index][_index].percentageSponsor = _sponsorPercent.mul(100);
        sponsored[aux_index][_index].prevPercentageSponsor = _sponsorPercent.mul(100);
        sponsored[aux_index][_index].accepted = true;
        sponsored[aux_index][_index].creatorCode = _ref;
        sponsored[aux_index][_index].name = _name;
        data[aux_index].numSponsored = data[aux_index].numSponsored.add(1); 
        numParticipants = numParticipants.add(1);
        
        return true;
        
    }
    
    function setScore(address _sponsor, uint _index, uint _score, uint _pos) public onlyOperator returns(bool){
        uint aux_index = sponsor_index[_sponsor];
        require(aux_index > 0 && data[aux_index].numSponsored > _index);
       
        team_score[aux_index][_index] = _score;
        address _player;
        for (uint i = 0; i < playersPerTeam; i = i.add(1)) {
            _player = sponsored[aux_index][_index].players[i];
            position_gamer[_player] = _pos;
        }
        
        if(_pos >= 1 && _pos <= 3){
             uint _extra = extraPoints[_pos.sub(1)];
             require(Lib(sponsorLeague).addPoints(_sponsor, _extra), "Sponsor League error");
             extra_points_league[_sponsor] = extra_points_league[_sponsor].add(_extra);
        }        

        sponsored[aux_index][_index].position = _pos;
        total_score = total_score.add(_score);
        return true;
    }
    
    function setScores(address[] calldata _sponsor, uint[] calldata _index, uint[] calldata _score, uint[] calldata _position) public onlyOperator returns(bool){
        for(uint i = 0; i < _sponsor.length; i = i.add(1)){
            require(setScore(_sponsor[i], _index[i], _score[i], _position[i]));
        }
        return true;
    }
    
    function changeScore(address _sponsor, uint _index, uint _score, uint _pos) public onlyOperator returns(bool){
        uint aux_index = sponsor_index[_sponsor];
        require(aux_index > 0 && data[aux_index].numSponsored > _index);
        total_score = total_score.sub(team_score[aux_index][_index]);
        team_score[aux_index][_index] = _score;
        address _player;
        for (uint i = 0; i < playersPerTeam; i = i.add(1)) {
            _player = sponsored[aux_index][_index].players[i];
            position_gamer[_player] = _pos;
        }
        sponsored[aux_index][_index].position = _pos;
        total_score = total_score.add(_score);
        return true;
    }
    
    function changeScores(address[] calldata _sponsor, uint[] calldata _index, uint[] calldata _score, uint[] calldata _position) public onlyOperator returns(bool){
        for(uint i = 0; i < _sponsor.length; i = i.add(1)){
            require(changeScore(_sponsor[i], _index[i], _score[i], _position[i]));
        }
        return true;
    }
    
    function getTeamScore(address _sponsor, uint _index) public view returns(uint){
        uint aux_index = sponsor_index[_sponsor];
        return team_score[aux_index][_index];
    }
    
    function end() public onlyOperator returns (bool){
        uint share;
        address _current;
        
        uint fee;
        uint percent_s;
        uint _reward;
        uint _rewHolder;
        uint _rewGamer;
        
        address auxGamer;
        uint aux_index;
        for(uint i = 1; i <= numSponsors; i = i.add(1)){
            _current = sponsor_addr[i];
            for(uint j = 0; j < getNumSponsored(_current); j = j.add(1)){
                aux_index = sponsor_index[_current];
                if(team_score[aux_index][j] > 0){
                    
                    share = team_score[aux_index][j].mul(1e18).div(total_score);
                    _reward = share.mul(prizepool).div(1e18);
                    if(_reward > 0){

                        if(sponsored[aux_index][j].accepted){
                            percent_s = sponsored[aux_index][j].percentageSponsor;
                        }else{
                            percent_s = sponsored[aux_index][j].prevPercentageSponsor;
                        }

                        fee = _reward.mul(10).div(100);

                        _rewHolder = _reward.mul(percent_s).div(10000);
                        _rewGamer = (_reward.sub(_rewHolder).sub(fee)).div(playersPerTeam);
                        
                        
                                            
                        sponsored[aux_index][j].reward_team = _reward;
                        sponsored[aux_index][j].reward_sponsor = _rewHolder;
                        sponsored[aux_index][j].reward_player = _rewGamer;
                        
                        data[aux_index].total_reward = data[aux_index].total_reward.add(_reward);
                        data[aux_index].total_reward_sponsor = data[aux_index].total_reward_sponsor.add(_rewHolder);
                        
                        require(Lib(tokenAddress).transfer(referee, fee), "Error sending fee");
                        require(Lib(tokenAddress).transfer(_current, _rewHolder), "Error sending to sponsor");
                        for(uint k = 0; k < playersPerTeam; k = k.add(1)){
                            auxGamer = sponsored[aux_index][j].players[k];
                            require(Lib(tokenAddress).transfer(auxGamer, _rewGamer), "Error sending to gamer");
                            reward_gamer[auxGamer] = _rewGamer;
                        }
                    }
                }
            }
        }
        return true;
    }

    function canUnlock(address _dir) public view returns (bool){
        uint aux_index = sponsor_index[_dir];
        require(aux_index > 0, "Index error");
        for(uint i = 0; i < data[aux_index].numSponsored; i = i.add(1)){
            if(sponsored[aux_index][i].locked && block.timestamp.sub(sponsored[aux_index][i].timeLock) > timeLocked){
                return true;
            }
        }
        return false;
            
    }
    
    function unlockTeam(address _dir, uint _index) public returns (bool){
        uint aux_index = sponsor_index[_dir];
        require(msg.sender == _dir);
        require(aux_index > 0, "Index error");
        require(sponsored[aux_index][_index].locked, "No locked tokens");
        require(block.timestamp.sub(sponsored[aux_index][_index].timeLock) > timeLocked , "Not now" );
        
        sponsored[aux_index][_index].locked = false;
        require (Lib(tokenAddress).transfer(_dir, amountToLock ) );
        totalLockedAmount = totalLockedAmount.sub(amountToLock);
        
        return true;
    }
    
    function unlockTeamPaying(address _dir, uint _index) public returns (bool){
        uint aux_index = sponsor_index[_dir];
        require(msg.sender == _dir);
        require(aux_index > 0, "Index error");
        require(sponsored[aux_index][_index].locked, "No locked tokens");
        require(block.timestamp.sub(sponsored[aux_index][_index].timeLock) > timePaying && block.timestamp.sub(sponsored[aux_index][_index].timeLock) < timeLocked , "Not now");
        
        sponsored[aux_index][_index].locked = false;
        uint fee = amountToLock.div(10); 
        uint _send = amountToLock.sub(fee);
        
        require (Lib(tokenAddress).transfer(referee, fee ) );
        require (Lib(tokenAddress).transfer(_dir, _send ) );
        totalLockedAmount = totalLockedAmount.sub(amountToLock);
        
        numPrematureUnlocks = numPrematureUnlocks.add(1);
        
        return true;
    }
    
    function unlockAll(address _dir) public returns (bool){
        uint aux_index = sponsor_index[_dir];
        require(aux_index > 0);
        require(msg.sender == _dir);
        bool _confirmation = false;
        for(uint i = 0; i < data[aux_index].numSponsored; i = i.add(1)){
            if(sponsored[aux_index][i].locked && block.timestamp.sub(sponsored[aux_index][i].timeLock) > timeLocked){
                unlockTeam(_dir, i);
                _confirmation = true;
            }
        }
        
        require(_confirmation, "Amount unlockable is 0");
        return true;
    }
    
    function timeToFinishUnlock(address _dir, uint _index) public view returns (uint){
        uint aux_index = sponsor_index[_dir];
        require(aux_index > 0 && data[aux_index].numSponsored > _index);
        
        uint returnTime;
        
        if(sponsored[aux_index][_index].timeLock == 0 ){
            returnTime = 0;
        }else{
            returnTime = sponsored[aux_index][_index].timeLock.add(timeLocked);
        }
        
       
        return returnTime;
        
    }
    
    function getIsSponsor(address dir) public view returns (bool){
        uint aux_index = sponsor_index[dir];
        return aux_index > 0;
    }
    
    function getIsGamer(address dir) public view returns (bool){
        uint aux_index = gamer_index[dir];
        return aux_index > 0;
    }

    function getNumSponsors() public view returns (uint){
        return numSponsors;
    }
    
    function getNumGamers() public view returns (uint){
        return numGamers;
    }
    
    function getHolder(uint pos) public view returns (address){
        return sponsor_addr[pos];
    }
    
    function getGamer(uint pos) public view returns (address){
        return gamer_addr[pos];
    }
    
    function getGamers(uint pos, uint _index) public view returns (address[] memory){
        address _sponsor = sponsor_addr[pos];
        uint aux_index = sponsor_index[_sponsor];
        return sponsored[aux_index][_index].players;
    }
    
    /* Sponsor can change the Team's name */ 
    function changeNamePaying(string memory _new, address _sponsor, uint _index) public returns (bool){
        uint aux_index = sponsor_index[_sponsor];
        require(aux_index > 0, "Index error");
        require(block.timestamp < register_date, "Registrations are closed.");
        
        if(msg.sender != referee){
            require(_sponsor == msg.sender);
            require (Lib(tokenAddress).transferFrom(_sponsor, address(this), nameFee));
            require (Lib(tokenAddress).transfer(referee, nameFee));
        }
        sponsored[aux_index][_index].name= _new;
        return true;
    }
    
    /* Get names fees & leftover prizes */ 
    function recoverTokens(address _to, uint _amount) public onlyReferee returns (bool){
        require(Lib(tokenAddress).balanceOf(address(this)).sub(_amount) >= totalLockedAmount, "User funds Protector");
        Lib(tokenAddress).transfer(_to, _amount);
        
        return true;
    }
    
    /* Admin unlocking sponsors tokens for them */ 
    function recoverTokensReferee(address _dir, uint _index) public onlyReferee returns (bool){
        uint aux_index = sponsor_index[_dir];
        require(aux_index > 0, "Index error");
        require(block.timestamp.sub(sponsored[aux_index][_index].timeLock) > timeLocked);
        sponsored[aux_index][_index].locked = false;
        require (Lib(tokenAddress).transfer(_dir, amountToLock ) );
        totalLockedAmount = totalLockedAmount.sub(amountToLock);
        return true;
        
    }
    
    /* Migration of SponsorsLeague contract */
    function setSponsorsLeague(address _new) public onlyReferee returns(bool){
        sponsorLeague = _new;
        return true;
    }
    
    /* Change points per registration - Sponsors League */
    function setLeaguePoints(uint _new) public onlyReferee returns(bool){
        pointsPerRegistration = _new;
        return true;
    }

    function hasNotification( address _gamer) public view returns(bool){
        address auxGamer;
        address _current;
        uint aux_index;
        for(uint i = 1; i <= numSponsors; i = i.add(1)){
            _current = sponsor_addr[i];
            for(uint j = 0; j < getNumSponsored(_current); j = j.add(1)){
                aux_index = sponsor_index[_current];
                for(uint k = 0; k < playersPerTeam; k = k.add(1)){
                    auxGamer = sponsored[aux_index][j].players[k];
                    if( auxGamer == _gamer && !sponsored[aux_index][j].accepted){
                        return true;
                    }
                }
                
            }
        }
        return false;
    }

    function getSponsorPercent(address _sponsor, uint _team) public view returns(uint){
        uint aux_index = sponsor_index[_sponsor];
        return sponsored[aux_index][_team].percentageSponsor.div(100);
    }
    function getPrevSponsorPercent(address _sponsor, uint _team) public view returns(uint){
        uint aux_index = sponsor_index[_sponsor];
        return sponsored[aux_index][_team].prevPercentageSponsor.div(100);
    }

    function getGamerPercAndAccepted( address _gamer) public view returns(uint, bool, uint){
        address auxGamer;
        address _current;
        uint aux_index;
        uint _res = 0;
        uint _resPrev = 0;
        bool _acc;
        for(uint i = 1; i <= numSponsors; i = i.add(1)){
            _current = sponsor_addr[i];
            for(uint j = 0; j < getNumSponsored(_current); j = j.add(1)){
                aux_index = sponsor_index[_current];
                for(uint k = 0; k < playersPerTeam; k = k.add(1)){
                    auxGamer = sponsored[aux_index][j].players[k];
                    if( auxGamer == _gamer ){
                        _res = sponsored[aux_index][j].percentageSponsor.div(100);
                        _resPrev = sponsored[aux_index][j].prevPercentageSponsor.div(100);
                        _acc = sponsored[aux_index][j].accepted;
                    }
                }
                
            }
        }
        return (_res, _acc, _resPrev);
    }

    function getAccepted(address _sponsor, uint _team) public view returns(bool){
        uint aux_index = sponsor_index[_sponsor];
        return sponsored[aux_index][_team].accepted;
    }

    function acceptChangeDistrib( address _gamer) public returns(bool){
        require(_gamer == msg.sender);
        address auxGamer;
        address _current;
        uint aux_index;
        for(uint i = 1; i <= numSponsors; i = i.add(1)){
            _current = sponsor_addr[i];
            for(uint j = 0; j < getNumSponsored(_current); j = j.add(1)){
                aux_index = sponsor_index[_current];
                for(uint k = 0; k < playersPerTeam; k = k.add(1)){
                    auxGamer = sponsored[aux_index][j].players[k];
                    if( auxGamer == _gamer && !sponsored[aux_index][j].accepted){
                        sponsored[aux_index][j].accepted = true;
                    }
                }
                
            }
        }
        return false;
    }

    function rejectChangeDistrib( address _gamer) public returns(bool){
        require(_gamer == msg.sender);
        address auxGamer;
        address _current;
        uint aux_index;
        for(uint i = 1; i <= numSponsors; i = i.add(1)){
            _current = sponsor_addr[i];
            for(uint j = 0; j < getNumSponsored(_current); j = j.add(1)){
                aux_index = sponsor_index[_current];
                for(uint k = 0; k < playersPerTeam; k = k.add(1)){
                    auxGamer = sponsored[aux_index][j].players[k];
                    if( auxGamer == _gamer && !sponsored[aux_index][j].accepted){
                        sponsored[aux_index][j].accepted = true;
                        sponsored[aux_index][j].percentageSponsor = sponsored[aux_index][j].prevPercentageSponsor;
                    }
                }
                
            }
        }
        return false;
    }

    function changeDistrib(uint _newSponsorPercent, address _sponsor, uint _teamIndex) public returns(bool){
        uint aux_index = sponsor_index[_sponsor];
        require(aux_index > 0);
        require(_sponsor == msg.sender);
        require(sponsored[aux_index][_teamIndex].accepted, "Pending request exists");
        require(_newSponsorPercent > 29 && _newSponsorPercent < 46 && _newSponsorPercent % 5 == 0);
        require(block.timestamp < register_date, "Registrations are closed.");

        sponsored[aux_index][_teamIndex].accepted = false;
        sponsored[aux_index][_teamIndex].prevPercentageSponsor = sponsored[aux_index][_teamIndex].percentageSponsor;
        sponsored[aux_index][_teamIndex].percentageSponsor = _newSponsorPercent.mul(100);

        return true;
    }



    function setDistrib(uint _newSponsorPercent, address _sponsor, uint _teamIndex) public onlyOperator returns(bool){
        uint aux_index = sponsor_index[_sponsor];
        require(aux_index > 0);
        require(_newSponsorPercent > 29 && _newSponsorPercent < 46 && _newSponsorPercent % 5 == 0);
        sponsored[aux_index][_teamIndex].accepted = true;
        sponsored[aux_index][_teamIndex].prevPercentageSponsor = sponsored[aux_index][_teamIndex].percentageSponsor;
        sponsored[aux_index][_teamIndex].percentageSponsor = _newSponsorPercent.mul(100);
        return true;
    }
    
}
