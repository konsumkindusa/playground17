// Testing this Apex class! For Move
public Class AccountCreation
{
public Account createAccount(String name) //Method to Create Account. 
{
Account acc = new Account(); 
acc.Name = name;
system.debug('Test');
return acc;
}
}