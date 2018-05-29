//This trigger is being tested for MOVe!!!
//I'm adding an other comment
trigger Accounttrigger on Account (before insert,before update) {
List<Account> acclst=new List<Account>();
  for(account a:trigger.new){
    if(a.Site=='NewYork'&& a.BillingPostalCode!=null){
    a.ShippingPostalCode=a.BillingPostalCode;
        
    }
    }
    }