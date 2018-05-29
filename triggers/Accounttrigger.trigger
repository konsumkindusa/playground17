//This trigger is being moved with comment

trigger Accounttrigger on Account (before insert,before update) {
List<Account> acclst=new List<Account>();
  for(account a:trigger.new){
    if(a.Site=='NewYork'&& a.BillingPostalCode!=null){
    a.ShippingPostalCode=a.BillingPostalCode;
        
    }
    }
    }