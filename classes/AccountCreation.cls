//Adding a comment to test a Move !!!
public Class AccountCreation
{
public static Account createAccount(String name) //Method to Create Account. 
{
Account acc = new Account(); 
acc.Name = name;
system.debug('Test');
system.debug('Donna test');
return acc;
}

public Account secondAccount( String name)
{
Account demoacc= new Account(); 
demoacc.Name = name;
system.debug('Test');
system.debug('Donna test');
return demoacc;
}
}