//this is a comment to test the Move !!
trigger newaccounttrigger on Account (before insert,before update) {


List<Account> acclst=new List<Account>();
  for(account a:trigger.new){
    if(a.Site=='Bangalore'&& a.BillingPostalCode!=null){
    a.ShippingPostalCode=a.BillingPostalCode;
        
    }
    }
    }