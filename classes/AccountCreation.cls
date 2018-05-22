//Adding a test Comment- adding again
public Class AccountCreation
{
public Account createAccount(String name) //Method to Create Account. 
{
// This is an Apex class! For Move
Account acc = new Account(); 
acc.Name = name;
system.debug('Test');
system.debug('Donna test');
return acc;
}
}