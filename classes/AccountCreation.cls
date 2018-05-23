//Adding a comment for Move !!

public Class AccountCreation
{
public static Account createAccount(String name) //Method to Create Account. 
{
Account acc = new Account(); 
acc.Name = name;
system.debug('Test');
return acc;
}

public Account secondAccount( String name)
{
Account acc1 = new Account(); 
acc1.Name = name;
system.debug('Test');
system.debug('Donna test');
return acc1;
}
}