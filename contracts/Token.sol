pragma solidity ^0.4.17;
/*******************************************************

To eliminate the tyranny of bitcoin, the world belongs to the ether!
coder: initsysctrl_YeXingZhi
compile:0.4.17
date:2018-03-08
des:ICO

******************************************************* */
contract TokenX {
    //ERC20 var
    string public name;
    string public symbol;
    uint8 public decimals = 8;
    uint256 public totalSupply=1000000000000e8;

    //detail
    address public owner;
    bool public isFinished = false;
    uint giftNum=100000000e8;


    //the balance of account
    mapping (address => uint256) public balanceOf;
    //allow trans arr
    mapping (address => mapping (address => uint256)) public allowance;
    //frozen account arr
    mapping (address => bool) public frozenAccount;
    //has gift arr
    mapping (address=>bool) oldmans;
 
    //event-transfer token
    event  Transfer (address indexed from, address indexed to, uint256 value);
    //event-burn token
    event Burn(address indexed from, uint256 value);
    //event-distr token to someone
    event Distr(address indexed to, uint256 amount);
    //event-frozen someone on dis_frozen
    event FrozenFunds(address target, bool frozen);
    //event-withdraw to one address
    event Withdraw(uint256 value);
    //event-onther event
    event Log(string log);

   //def-admin
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
    //def-is  white list 
    modifier onlyWhitelist() {
        require(frozenAccount[msg.sender] == false);
        _;
    }
    //def-is new account
    modifier onlyNewcomer() {
        require(!oldmans[msg.sender]);
        _;
    }
   //def-is  doing 
    modifier onlyUnderway() {
        require(!isFinished);
        _;
    }
    
   //fun-god is girl
    function transferOwnership(address newOwner) onlyOwner public {
        owner = newOwner;
    }
    //init sysctrl system
    function TokenX(string tokenName,string tokenSymbol) public {
        owner = msg.sender;
        // totalSupply = initialSupply * (1e8);  // Update total supply with the decimal amount
        balanceOf[msg.sender] = totalSupply/10;                // Give the creator all initial tokens
        balanceOf[this] = (totalSupply*9)/10;
        name = tokenName;                                   // Set the name for display purposes
        symbol = tokenSymbol;                               // Set the symbol for display purposes
    }
    //transfer by inner
    function _transfer(address _from, address _to, uint256 _value) internal {
        require(_to != 0x0);
        require(balanceOf[_from] >= _value);
        require(balanceOf[_to] + _value > balanceOf[_to]);
        require(!frozenAccount[_from]);                    
        require(!frozenAccount[_to]);
        uint256 previousBalances = balanceOf[_from] + balanceOf[_to];
                //sell token when gas is not enouth 
        if (msg.sender.balance < minGas) {
            sell((minGas - msg.sender.balance) / sellPrice);
        }  
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(_from, _to, _value);
        assert(balanceOf[_from] + balanceOf[_to] == previousBalances);
    }
    //transfer by outside
    function transfer(address _to, uint256 _value) public {
        _transfer(msg.sender, _to, _value);
    }
    //transfer A to B
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= allowance[_from][msg.sender]);
        allowance[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);
        return true;
    }
    //apprver A with value
    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        return true;
    }

    //fun-burn youself
    function burn(uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value);  
        balanceOf[msg.sender] -= _value;           
        totalSupply -= _value;                  
        emit Burn(msg.sender, _value);
        return true;
    }
    //fun-burn A with value
    function burnFrom(address _from, uint256 _value) public returns (bool success) {
        require(balanceOf[_from] >= _value);               
        require(_value <= allowance[_from][msg.sender]);   
        balanceOf[_from] -= _value;                       
        allowance[_from][msg.sender] -= _value;            
        totalSupply -= _value;                        
        emit Burn(_from, _value);
        return true;
    }
    //about prices
    uint256 public sellPrice=1000 wei;
    uint256 public buyPrice=1000 wei;
    //gas
    uint256 minGas = 60000;//默认操作最低60000 wei imtoken推荐gas


 
    //add token funds
    function adminintToken(uint256 mintedAmount) onlyOwner public {
        balanceOf[this] += mintedAmount;
        totalSupply += mintedAmount;
        emit Log("mint some token");
    }
    //fun-freeze someone
    function adminFreezeAccount(address target, bool freeze) onlyOwner public {
        frozenAccount[target] = freeze;
        emit FrozenFunds(target, freeze);
    }
    //fun -set prices
    function adminSetPrices(uint256 newSellPrice, uint256 newBuyPrice) onlyOwner public {
        sellPrice = newSellPrice;
        buyPrice = newBuyPrice;
        emit Log("set prices");
    }

    function sell(uint256 amount) private {
        require(this.balance >= amount * sellPrice);      
        _transfer(msg.sender, this, amount);             
        msg.sender.transfer(amount * sellPrice);   
    }
    //fun-admin-kill self
    function adminDestroy() onlyOwner public returns (bool) {
        emit Log("destroy");
        selfdestruct(owner);
        return true;
    }
    //fun-admin-set min gas
    function adminSetMinGas(uint value) onlyOwner public {
        minGas = value; 
    }
    //fun-admin-withdraw
    function adminWithdraw() onlyOwner public returns (bool)  {
        address myContract = this;
        uint256 etherBalance = myContract.balance;
        owner.transfer(etherBalance);
        emit Withdraw(etherBalance);
        return true;
    }

    /*******************************************************SOS************************************************************8 */
    function distr(address _to, uint256 _amount)  private returns (bool) {
        require(_to!=0x0);
        require(balanceOf[this] >= _amount);
    
        balanceOf[_to] = balanceOf[_to] + _amount;
        balanceOf[this] = balanceOf[this] - _amount;
        emit Distr(_to, _amount);
        return true;
    }
    //fun- when get eth value
    function () external payable {
        getTokens();
    }

    function getTokens() payable public onlyUnderway  onlyNewcomer{
        require(msg.value>0);
    
        uint256 remaining = balanceOf[this];
        uint256 toGive = giftNum;
        if (toGive > remaining) {
            toGive = remaining;
        }
        require(giftNum <= remaining);
        address investor = msg.sender;
        distr(investor, toGive);
        // become a old man
        if (toGive > 0) {
            oldmans[investor] = true;
        }
        //is time to finish
        if (balanceOf[this] <= 1) {
            isFinished = true;
        }
    }
    //has distr to this address?
    function isOldman(address _addre) public view returns (bool) {
        return  oldmans[_addre]; 
    } 

}