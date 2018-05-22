//Adding a Comment


@isTest 
private class DemoTestclass4{
    static testMethod void validateHelloWorld() {
       Account a = new Account (Name='Behind the Cloud');
     

       // Insert book
       insert a;
    
       // Retrieve the new book
       a = [SELECT Name FROM Account WHERE Id =:a.Id];
     
    }
}