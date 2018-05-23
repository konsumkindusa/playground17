// Testing this Apex class! For Move
//Adding Test Comments
public Class AccountCreation
{
public Account createAccount(String name) //Method to Create Account. 
{
Account acc = new Account(); 
acc.Name = name;
system.debug('Test');
system.debug('Donna test');
return acc;
}
}