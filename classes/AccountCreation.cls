//Testing this class for a move

public Class AccountCreation
{
public static Account createAccount(String name) 
{
Account acc = new Account(); 
acc.Name = name;
system.debug('Test');
system.debug('Donna test');
return acc;
}
//Adding a second method to crate an account
public Account secondAccount( String name)
{
Account demoacc= new Account(); 
demoacc.Name = name;
system.debug('Test');
system.debug('Donna test');
return demoacc;
}
}