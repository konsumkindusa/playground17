public Class NewClass
{
public Account NewClass(String name) //Method to Create Account. 
{

// This is an Apex class! For Mathworks Evaluation
Account acc = new Account(); 
acc.Name = name;
system.debug('Test');
system.debug('Donna test');
return acc;
}
}