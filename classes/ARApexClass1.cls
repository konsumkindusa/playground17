public Class ARApexClass1
{
public Account createAccount(String name)  //method to create account
{
//Comment1
//leela comment
//comment2
Account acc112 = new Account();
acc112.Name = name;
System.debug('This is just a new line to test the difference'+acc112);
Contact con=new Contact();
return acc112;
}
}