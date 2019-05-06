pragma solidity ^0.4.24;

import './utility/Owned.sol';
import './utility/TokenHolder.sol';
import './server/MainServer.sol';

contract NickTalk is Owned, TokenHolder {
    uint8 public clientVersion = 1;
    string public updateMsg = "Need update the client.";

    uint16 public maxPersonalMessageBoxLength = 500;

    struct Message {
        address from;
        string  content;
        uint    timestamp;
    }

    event newMessage(address indexed _to, address indexed _from, string _content, uint _timestamp);

    mapping(address => uint16) messageBoxPointer;
    mapping(address => Message[]) messageBox;

    modifier versionSuits(uint8 _clientVersion) {
        require(_clientVersion >= clientVersion, updateMsg);
        _;
    }

    function setVersion(uint8 _clientVersion) public ownerOnly {
        clientVersion = _clientVersion;
    }

    function setUpdateMsg(string _updateMsg) public ownerOnly {
        updateMsg = _updateMsg;
    }

    function setMaxPersonalMessageBoxLength(uint16 _length) ownerOnly {
        maxPersonalMessageBoxLength = _length;
    }

    function sendMsg(address _toAddress, string _content, uint8 _clientVersion) public versionSuits(_clientVersion) {
        messageBox[_toAddress].push(Message(msg.sender, _content, now));

        emit newMessage(_toAddress, msg.sender, _content, now);

        if (messageBox[_toAddress].length >= (maxPersonalMessageBoxLength * 2)) {
            Message[] newMessageBox;
            for (uint16 i=0; i<= maxPersonalMessageBoxLength; i++) {
                newMessageBox.push(messageBox[_toAddress][i]);
            }

            messageBox[_toAddress].length = 0;
            messageBox[_toAddress] = newMessageBox;
        }
    }

}