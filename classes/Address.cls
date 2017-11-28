/**
 *author Original: Archana Lohar - Cloud Sherpas/Mathworks, Last Modified: Archana Lohar - Cloud Sherpas/Mathworks
 *date Original: 14 May 2014, Last Modified: 14 May 2014
 *description This  is handler class for Address . 
 */
public class Address {
 
    String street;
    String city;
    String postalCode;
    String country;
    String state;
    String county;
    String name;
    String stateCode;

    public String getCountry() {
        return country;
    }

    public void setCountry(String country_a) {
    Logger.push('setCountry','Address ');
        country =country_a;
    Logger.pop();   
    }

    public String getState() {
        return state;
    }

    public void setState(String state_a) {
    Logger.push('setState','Address ');
        state = state_a;
    Logger.pop();
    }

    public void setName(String name_a) {
    Logger.push('setName','Address ');
        name = name_a;
    Logger.pop();
    }
    
    public String getStateCode() {
        return stateCode;
    }

    public void setStateCode(String stateCode_a) {
    Logger.push('setStateCode','Address ');
        stateCode = stateCode_a;
    Logger.pop();
    }
    
}