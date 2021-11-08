//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Pausable.sol";
import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract ProjectJ is 
    ERC721, 
    ERC721Enumerable,
    ERC721Burnable,
    ERC721Pausable,
    AccessControlEnumerable 
{

    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdTracker;

    // Declare roles for AccessControl
    bytes32 public constant MODERATOR_ROLE = keccak256("MODERATOR_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

    string private _baseTokenURI;

    constructor(
        address[] memory _moderators,
        address[] memory _pausers,
        string memory baseTokenURI
    ) ERC721("ProjectJ","PRJ") {

        // Set base token URI
        _baseTokenURI = baseTokenURI;

        // Initialize default admin role
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);

        // Initialize moderators
        uint256 i;
        for (i = 0;i < _moderators.length; i++) {
            _setupRole(MODERATOR_ROLE,_moderators[i]);
        }

        // Initialize pausers
        for (i = 0;i < _pausers.length; i++) {
            _setupRole(PAUSER_ROLE,_pausers[i]);
        }
    }

    // Mapping of blacklisted accounts to allow deactivation of NFTs
    mapping(address => bool) public blacklist;

    // Modification of standing will emit target address, the new standing, and the address changing the standing
    event StandingModified(address target, bool newStanding, address changedBy);

    modifier inGoodStanding() {
        require(blacklist[msg.sender] == false,"Account is blacklisted.");
        _;
    }

    // Modify the standing of the target address. Cannot change own standing. Requires moderator role.
    function modifyStanding(address target, bool newStanding) inGoodStanding onlyRole(MODERATOR_ROLE) public {
        require(target != msg.sender,"User cannot modify their own standing.");
        blacklist[target] = newStanding;
        emit StandingModified(target, newStanding, msg.sender);
    }

    // Return standing of target address.
    function checkStanding(address _address) public view returns (bool) {
        return blacklist[_address];
    }

    function mint(address to) public inGoodStanding {
        _safeMint(to, _tokenIdTracker.current());
        _tokenIdTracker.increment();
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(AccessControlEnumerable, ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override(ERC721, ERC721Enumerable, ERC721Pausable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }

}
