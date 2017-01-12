public Class ARApexClass4
{
public Account createAccount(String name)  //method to create account
{
//Add Cooment1
// additional comment to check
Account acc121 = new Account();

System.debug('another comment to see how things go' + acc121);
acc121.Name = name;
return acc121;
//this is the test comment
}
}