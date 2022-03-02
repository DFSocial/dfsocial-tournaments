/**
 *Submitted for verification at BscScan.com on 2022-03-02
*/

// File: @openzeppelin/contracts/utils/introspection/IERC165.sol


// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// File: @openzeppelin/contracts/utils/introspection/ERC165.sol


// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;


/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

// File: @openzeppelin/contracts/utils/Strings.sol


// OpenZeppelin Contracts v4.4.1 (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}

// File: @openzeppelin/contracts/utils/Context.sol


// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// File: @openzeppelin/contracts/access/IAccessControl.sol


// OpenZeppelin Contracts v4.4.1 (access/IAccessControl.sol)

pragma solidity ^0.8.0;

/**
 * @dev External interface of AccessControl declared to support ERC165 detection.
 */
interface IAccessControl {
    /**
     * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`
     *
     * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite
     * {RoleAdminChanged} not being emitted signaling this.
     *
     * _Available since v3.1._
     */
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    /**
     * @dev Emitted when `account` is granted `role`.
     *
     * `sender` is the account that originated the contract call, an admin role
     * bearer except when using {AccessControl-_setupRole}.
     */
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Emitted when `account` is revoked `role`.
     *
     * `sender` is the account that originated the contract call:
     *   - if using `revokeRole`, it is the admin role bearer
     *   - if using `renounceRole`, it is the role bearer (i.e. `account`)
     */
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) external view returns (bool);

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {AccessControl-_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been granted `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) external;
}

// File: @openzeppelin/contracts/access/AccessControl.sol


// OpenZeppelin Contracts (last updated v4.5.0) (access/AccessControl.sol)

pragma solidity ^0.8.0;





/**
 * @dev Contract module that allows children to implement role-based access
 * control mechanisms. This is a lightweight version that doesn't allow enumerating role
 * members except through off-chain means by accessing the contract event logs. Some
 * applications may benefit from on-chain enumerability, for those cases see
 * {AccessControlEnumerable}.
 *
 * Roles are referred to by their `bytes32` identifier. These should be exposed
 * in the external API and be unique. The best way to achieve this is by
 * using `public constant` hash digests:
 *
 * ```
 * bytes32 public constant MY_ROLE = keccak256("MY_ROLE");
 * ```
 *
 * Roles can be used to represent a set of permissions. To restrict access to a
 * function call, use {hasRole}:
 *
 * ```
 * function foo() public {
 *     require(hasRole(MY_ROLE, msg.sender));
 *     ...
 * }
 * ```
 *
 * Roles can be granted and revoked dynamically via the {grantRole} and
 * {revokeRole} functions. Each role has an associated admin role, and only
 * accounts that have a role's admin role can call {grantRole} and {revokeRole}.
 *
 * By default, the admin role for all roles is `DEFAULT_ADMIN_ROLE`, which means
 * that only accounts with this role will be able to grant or revoke other
 * roles. More complex role relationships can be created by using
 * {_setRoleAdmin}.
 *
 * WARNING: The `DEFAULT_ADMIN_ROLE` is also its own admin: it has permission to
 * grant and revoke this role. Extra precautions should be taken to secure
 * accounts that have been granted it.
 */
abstract contract AccessControl is Context, IAccessControl, ERC165 {
    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    /**
     * @dev Modifier that checks that an account has a specific role. Reverts
     * with a standardized message including the required role.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     *
     * _Available since v4.1._
     */
    modifier onlyRole(bytes32 role) {
        _checkRole(role, _msgSender());
        _;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) public view virtual override returns (bool) {
        return _roles[role].members[account];
    }

    /**
     * @dev Revert with a standard message if `account` is missing `role`.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     */
    function _checkRole(bytes32 role, address account) internal view virtual {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        Strings.toHexString(uint160(account), 20),
                        " is missing role ",
                        Strings.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) public view virtual override returns (bytes32) {
        return _roles[role].adminRole;
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been revoked `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) public virtual override {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event. Note that unlike {grantRole}, this function doesn't perform any
     * checks on the calling account.
     *
     * [WARNING]
     * ====
     * This function should only be called from the constructor when setting
     * up the initial roles for the system.
     *
     * Using this function in any other way is effectively circumventing the admin
     * system imposed by {AccessControl}.
     * ====
     *
     * NOTE: This function is deprecated in favor of {_grantRole}.
     */
    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    /**
     * @dev Sets `adminRole` as ``role``'s admin role.
     *
     * Emits a {RoleAdminChanged} event.
     */
    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        bytes32 previousAdminRole = getRoleAdmin(role);
        _roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * Internal function without access restriction.
     */
    function _grantRole(bytes32 role, address account) internal virtual {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * Internal function without access restriction.
     */
    function _revokeRole(bytes32 role, address account) internal virtual {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}

// File: Torneos_Marzo/Reven.sol



pragma solidity >=0.8.0;

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

interface Oracle {
    function getPrice() external view returns(uint);
    function inUSD() external view returns(uint);
}

interface Token {
    function transfer(address, uint) external returns (bool);
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool success);
}


contract Event is AccessControl{

    using SafeMath for uint;

    /*Events */
    event Created(uint index);
    event Registration(address indexed _sponsor, address indexed _gamer, string _username, uint[] index_tourneys);
    event GamerUpdated(address indexed _gamer, address indexed _newGamer);
    event StatusChanged(bool _status);
    event SetScores(uint _index);
    event DatesChanged(uint _startsAt, uint _endsAt);
    event EventFinished();

    /* Structs */
    struct Tourney {
        address winner;
        uint num_gamers;
        uint max_gamers;        
        uint reg_startsAt;
        uint reg_endsAt;
        bool paused;
        bool finished;
    }

    struct Gamer {
        address wallet;
        string username;
        uint n_tourneys;
    }

    struct GamerData {
        uint registeredAt;
        uint position;        
    }

    /* GENERAL DATA */
    address public immutable DFSG = 0x612C49b95c9121107BE3A2FE1fcF1eFC1C4730AD; 
    address public immutable burnAddress = 0x000000000000000000000000000000000000dEaD; 
    address public immutable team = 0xF05148Bc87EcF2Ca04218C2dc6F397BB8c231daf;
    Oracle DFSG_Oracle;

    uint[] public packs = [10000000000000000000, 18000000000000000000, 24000000000000000000, 28000000000000000000];
    uint public num_tourneys;
    uint public max_tourneys = 4;

    uint public prizePool;
    uint public total_burned;
    uint public total_team;

    /* Mappings */

    /* tourneys indexes and registered gamers */
    mapping(uint => Tourney) public tourneys;
    mapping(uint => mapping(uint => bool)) public tourney_gamers;

    /* Manage tourney gamers (tourney-gamer-gamerInfo) */
    mapping(uint => mapping(uint => GamerData)) public gamer_data;

    /* Manage tourneys gamer-sponsor */
    mapping(uint => mapping(uint => uint)) public sponsoredBy;

    /* Gamers mapping */
    mapping(address => uint) public gamer_index;
    mapping(uint => Gamer) public gamer_profile;
    uint public num_gamers;

    /* Sponsors mapping */
    mapping(address => uint) public sponsor_index;
    mapping(uint => address) public sponsor_address;
    uint public num_sponsors;

    /* tourney -> sponsor_index -> index -> datos gamer*/
    mapping(uint => mapping(uint => mapping(uint => uint))) public playerSponsored;
    mapping(uint => mapping(uint => uint)) public sponsoredCounter;

    bytes32 public constant REFEREE_ROLE = keccak256("REFEREE_ROLE");

    constructor(address _oracleAddr){
        DFSG_Oracle = Oracle(_oracleAddr);
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(REFEREE_ROLE, msg.sender);
    }
    

    /* FUNCTIONS */

    /* Tourneys creation */
    function createTourney(uint _startsAt, uint _endsAt) external returns(bool){
        require(hasRole(REFEREE_ROLE, msg.sender), "Caller is not a referee");
        uint index = num_tourneys;
        require(index < max_tourneys, "Can not create more tourneys");
        require(_startsAt <= _endsAt, "Wrong dates");
        
        num_tourneys = num_tourneys.add(1);
        index = num_tourneys;
        tourneys[index] = Tourney(address(0), 0, 2048, _startsAt, _endsAt, false, false);

        emit Created(index);
        return true;
    }

    /* Tourney registration */
    function _addgamer(uint _index, address _sponsor, address _gamer, string calldata _username) internal returns(bool){

        /* tourney checks */
        Tourney memory tourney = tourneys[_index];
        require(block.timestamp >= tourney.reg_startsAt, "Tourney registrations are closed");
        require(block.timestamp < tourney.reg_endsAt, "Tourney registrations already finished");
        require(!tourney.paused, "Tourney registrations are paused");
        require(tourney.num_gamers < tourney.max_gamers, "Tourney is full");

        /* If sponsor is not in contract, add it to sponsors mapping*/
        if(!isSponsor(_sponsor)){
            num_sponsors = num_sponsors.add(1);
            sponsor_address[num_sponsors] = _sponsor;
            sponsor_index[_sponsor] = num_sponsors;
        }

        /* If gamer is not in contract, add it to gamers mapping and create new Gamer*/
        uint aux_index = gamer_index[_gamer]; 
        if(!isGamer(_gamer)) {
            num_gamers = num_gamers.add(1);
            aux_index = num_gamers;
            gamer_index[_gamer] = aux_index;
            gamer_profile[aux_index] = Gamer(_gamer, _username, 0);
        } 
        else{
            require(!isWinner(aux_index), "Gamer is a winner");
            require(!isRegistered(_index, aux_index), "Gamer already registered");
        }

        /* Update tourney values */
        tourneys[_index].num_gamers = tourney.num_gamers.add(1);
        tourney_gamers[_index][aux_index] = true;

        /* Create team and add it to tourney */
        gamer_data[_index][aux_index] = GamerData(block.timestamp, 0);

        /* Add new sponsored */ 
        uint index_sponsor = sponsor_index[_sponsor];
        uint aux_counter = sponsoredCounter[_index][index_sponsor].add(1);

        sponsoredCounter[_index][index_sponsor] = aux_counter;
        playerSponsored[_index][index_sponsor][aux_counter] = aux_index;
        sponsoredBy[_index][aux_index] = index_sponsor;

        /* Update user profile */
        gamer_profile[aux_index].n_tourneys = gamer_profile[aux_index].n_tourneys.add(1);

        return true;
    }

    /* Main registration (includes multiple tourneys) */
    function register(address _sponsor, address _gamer, string calldata _username, uint[] calldata _indexes) external returns(bool){

        /* General conditions */
        require(_sponsor == _msgSender(), "Caller is not sponsor");
        require(_indexes.length > 0 && _indexes.length <= num_tourneys, "Check tourneys inputs");

        uint aux_index = gamer_index[_gamer];

        /* Check gamer resgistrations */
        (uint gamer_regs,) = registeredIn(aux_index);
        require(gamer_regs.add(_indexes.length) <= num_tourneys, "Exceeds number of tourneys");

        for(uint i = 0; i < _indexes.length; i = i.add(1)){
            /* Check if tourney exists before calling _addgamer */
            require(_indexes[i] >= 1 && _indexes[i] <= num_tourneys, "Tourney does not exist");
            _addgamer(_indexes[i], _sponsor, _gamer, _username);
        }

        if(!hasRole(REFEREE_ROLE, _sponsor)){
            
            /* Distribute amount of tokens (depends on the pack the user picked) */
            uint DFSG_price = DFSG_Oracle.getPrice();
            uint amountToPay = (packs[_indexes.length.sub(1)].mul(1e18)).div(DFSG_price);

            /* 80% prizepool, 10% burn, 10% DFSocial team */
            uint burnAmount = amountToPay.mul(10).div(100);
            uint teamAmount = amountToPay.mul(10).div(100);
            uint poolAmount = amountToPay.mul(80).div(100);

            /* Increment total amounts */
            total_burned = total_burned.add(burnAmount);
            total_team = total_team.add(teamAmount);
            prizePool = prizePool.add(poolAmount);

            /* Transfers */
            require(Token(DFSG).transferFrom(_sponsor, address(this), poolAmount), "Error sending to pool");
            require(Token(DFSG).transferFrom(_sponsor, burnAddress , burnAmount), "Error sending to zero address");
            require(Token(DFSG).transferFrom(_sponsor, team, teamAmount), "Error sending to team");
        }
        

        emit Registration(_sponsor, _gamer, _username, _indexes);
        return true;
    }

    /*Update tourney registration period*/
    function setDates(uint _index, uint _startsAt, uint _endsAt) external returns(bool){
        require(hasRole(REFEREE_ROLE, msg.sender), "Caller is not a referee");
        require(_startsAt <= _endsAt, "Wrong dates");
        require(block.timestamp < tourneys[_index].reg_endsAt, "Registrations already finished");
        
        tourneys[_index].reg_startsAt = _startsAt;
        tourneys[_index].reg_endsAt = _endsAt;

        emit DatesChanged(_startsAt, _endsAt);
        return true;
    }

    /* Pause or unpause tourney resgitrations (only for emergency) */
    function changeStatus(uint _index, bool _status) external returns(bool){
        require(hasRole(REFEREE_ROLE, msg.sender), "Caller is not a referee");
        require(tourneys[_index].paused != _status, "Same status");
        tourneys[_index].paused = _status;

        emit StatusChanged(_status);
        return true;
    }

    /* Finish tourney and set scores */
    function setScores(uint _index, uint[] calldata _indexes, uint[] calldata _positions) external returns(bool){
        require(hasRole(REFEREE_ROLE, msg.sender), "Caller is not a referee");
        require(block.timestamp > tourneys[_index].reg_endsAt, "Can not set scores yet");
        require(!tourneys[_index].finished, "Scores already set");

        tourneys[_index].finished = true;
        for(uint i = 0; i < _indexes.length; i = i.add(1)){

            gamer_data[_index][_indexes[i]].position = _positions[i];

            if(_positions[i] == 1) tourneys[_index].winner = gamer_profile[_indexes[i]].wallet;
        }

        emit SetScores(_index);
        return true;
    }

    /* Send rewards to winners (players and sponsors) */
    function sendRewards(address[] calldata _gamers, address[] calldata _sponsors, uint[] calldata _amounts) external returns(bool){
        require(hasRole(REFEREE_ROLE, msg.sender), "Caller is not a referee");
        for(uint i = 1; i <= num_tourneys; i = i.add(1)){
            require(tourneys[i].finished);
        }

        for(uint i = 0; i < _gamers.length; i++){

            if(_gamers[i] == _sponsors[i]) require(Token(DFSG).transfer(_gamers[i], _amounts[i]), "Fail sending to gamer");
            else{
                uint dividedAmount = _amounts[i].mul(50).div(100);
                require(Token(DFSG).transfer(_gamers[i], dividedAmount), "Fail sending to gamer");
                require(Token(DFSG).transfer(_sponsors[i], dividedAmount), "Fail sending to sponsor");
            }
        }

        emit EventFinished();
        return true;
    }

    /* GETTERS */

    /* Check if sponsor is already in contract */
    function isSponsor(address _dir) public view returns (bool){
        return sponsor_index[_dir] > 0;
    }

    /* Check if gamer is already in contract */
    function isGamer(address _dir) public view returns (bool){
        return gamer_index[_dir] > 0;
    }

    /* Get gamers username */
    function getUsername(uint index_gamer) public view returns (string memory){
        return gamer_profile[index_gamer].username;
    }

    /* Check if gamer is registered in particular tourney */
    function isRegistered(uint _index, uint index_gamer) public view returns(bool){
        return tourney_gamers[_index][index_gamer];
    }

    /* Check if gamer is a winner */
    function hasWon(uint _index, uint index_gamer) public view returns(bool){
        return (tourneys[_index].winner == gamer_profile[index_gamer].wallet);
    }

    /* Check if gamer is a winner */
    function isWinner(uint index_gamer) public view returns(bool){
        address _gamer = gamer_profile[index_gamer].wallet;
        for(uint i = 1; i <= num_tourneys; i = i.add(1)){
            if(tourneys[i].winner == _gamer) return true;
        }
        return false;
    }

    /* Get tourney winner */
    function getWinner(uint _index) public view returns(address, address){
        address _winner = tourneys[_index].winner;
        uint index_sponsor = sponsoredBy[_index][gamer_index[_winner]];
        return (_winner, sponsor_address[index_sponsor]);
    }

    /* Get gamer tourneys */
    function registeredIn(uint index_gamer) public view returns(uint, uint[] memory){
        uint[] memory registrations = new uint[](gamer_profile[index_gamer].n_tourneys);
        uint j = 0;
        for(uint i = 1; i <= num_tourneys; i = i.add(1)){
            if(tourney_gamers[i][index_gamer]){
                registrations[j] = i;
                j = j.add(1);
            }
        }
        return (registrations.length, registrations);
    }

    /* Get tourney players sponsored by user */
    function getSponsored(uint _index, uint index_sponsor) public view returns(address[] memory){
        uint length = sponsoredCounter[_index][index_sponsor];
        address[] memory _gamers = new address[](length);

        for(uint i = 1; i <= length; i = i.add(1)){
            uint index_gamer = playerSponsored[_index][index_sponsor][i];
            _gamers[i.sub(1)] = gamer_profile[index_gamer].wallet;
        }
        return _gamers;
    } 

    /* Get team info from tourney */
    function getTeam(uint _index, uint index_gamer) public view returns(address, string memory, address, uint, uint){
        string memory _username;
        address _gamer;
        uint index_sponsor;

        _gamer = gamer_profile[index_gamer].wallet;
        _username = gamer_profile[index_gamer].username;
        index_sponsor = sponsoredBy[_index][index_gamer];
        GamerData memory data = gamer_data[_index][index_gamer];

        return (_gamer, _username, sponsor_address[index_sponsor], data.registeredAt, data.position);
    }

    /* Aux function to compare strings */
    function equals(string memory s1, string memory s2) private pure returns(bool){
        return keccak256(abi.encodePacked(s1)) == keccak256(abi.encodePacked(s2));
    }
    
}
