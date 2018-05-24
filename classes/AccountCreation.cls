//Adding a comment to test a Move !!!
public Class AccountCreation
{
//Adding a method to crate an account
public static Account createAccount(String name) 
{
Account acc = new Account(); 
acc.Name = name;
system.debug('Test');
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