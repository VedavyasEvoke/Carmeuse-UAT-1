/********************************************************************************************************************************************
Author : Priyanka Shinde
Description : User utils class with all User related methods
----------------------------------------------------------------------------------------------------------------------------------------------
VERSION 	ISSUE NUMBER 	  DATE 		   AUTHOR 			 DETAIL
1                          17/08/2022    Priyanka Shinde   User utils class with all User related methods.
**********************************************************************************************************************************************/

public class UserUtils {
    @testVisible 
    private static Boolean showException = false;
    // Returns boolean, to show the user guide pop-up.
    @AuraEnabled
    public static Boolean getUserDetails(Id userId){
        Boolean showPopUp = true;       
        try {
            if(Test.isRunningTest() && showException==true){
                Exception e;
                throw e;
            }
            if(userId != null) {
                User userObj = [SELECT Id,Show_Pop_Up__c FROM User WHERE Id = :userId LIMIT 1];
                if(userObj != null) {                   
                    showPopUp = userObj.Show_Pop_Up__c;
                }                       
            }                
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return showPopUp;
    } 

    // Updates the user to close the pop-up.
    @AuraEnabled
    public static void closeModal(Id userId){
        Boolean showPopUp = false;       
        try {
            if(Test.isRunningTest() && showException==true){
                Exception e;
                throw e;
            }
            if(userId != null) {
                User userObj = [SELECT Id,Show_Pop_Up__c FROM User WHERE Id = :userId LIMIT 1];
                if(userObj != null) {
                    userObj.Show_Pop_Up__c = true;
                    update userObj;
                }                       
            }                
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
            
        }
    } 

    // Updates the users email preferences from the poratl.
    @AuraEnabled
    public static boolean updateUserEmailPreferences(Id userId,Boolean isSubmit,Boolean isConfirmed,Boolean isCancelled,Boolean isNoEmail,Boolean isAllSubmit,Boolean isAllConfirmed,Boolean isAllCancelled){
        String emailPreferences = '';
        try {
            if(Test.isRunningTest() && showException==true){
                Exception e;
                throw e;
            }
            if(userId != null) {
                User updateUserObj = new User();
                User userObj = [SELECT Id,Email_Preferences__c FROM User WHERE Id = :userId LIMIT 1];
                if(userObj != null) {
                    if(isSubmit == TRUE){
                        emailPreferences += 'Order Submission;';
                    }if(isConfirmed == TRUE){
                        emailPreferences += 'Order Confirmation;';
                    }if(isCancelled == TRUE){
                        emailPreferences += 'Order Cancellation;';
                    }if(isAllSubmit == TRUE){
                        emailPreferences += 'All Order Submission;';
                    }if(isAllConfirmed == TRUE){
                        emailPreferences += 'All Order Confirmation;';
                    }if(isAllCancelled == TRUE){
                        emailPreferences += 'All Order Cancellation;';
                    }if(isNoEmail == TRUE){
                        emailPreferences = 'No Email';
                    }                   
                    updateUserObj.Id = userObj.Id;
                    updateUserObj.Email_Preferences__c = emailPreferences;
                    update updateUserObj;                   
                } 
            }               
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return true;
    } 
    
    // Check what email preferences are assigned to the user and returns comma seperated string.
    @AuraEnabled
    public static String getUserEmailPreferences(Id userId){
        String emailPreferences = '';
        try {
            if(Test.isRunningTest() && showException==true){
                Exception e;
                throw e;
            }
            if(userId != null) {
                User updateUserObj = new User();
                User userObj = [SELECT Id,Email_Preferences__c FROM User WHERE Id = :userId LIMIT 1];
                if(userObj != null) {
                    emailPreferences = userObj.Email_Preferences__c;             
                } 
            }               
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return emailPreferences;
    }  
    
    // Returns a list of shipTos to override the tonnage limit.
    @AuraEnabled
    public static List <Ship_To_Override_Tonnage_Limits__c > getShipToOverrideTonnageLimit(){
        try {
            if(Test.isRunningTest() && showException==true){
                Exception e;
                throw e;
            }
            
            return [ SELECT Ship_To__c FROM Ship_To_Override_Tonnage_Limits__c ];
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    // Returns a list of shipTos to override the gallon limit.
    @AuraEnabled
    public static List<Ship_To_With_Gallon_Products__c> getShipToOverrideGallonLimit(){
        try {
            if(Test.isRunningTest() && showException==true){
                Exception e;
                throw e;
            }
            
            return [SELECT ShipTo__c FROM Ship_To_With_Gallon_Products__c];
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    // Returns lis of ordering rule, based on rules we have added validations on the portal.
    @AuraEnabled
    public static List<Ordering_Rule__c> getPlantCodesForValidation(String plantCode,String productCode){
        try {
            if(Test.isRunningTest() && showException==true){
                Exception e;
                throw e;
            }
            List<Ordering_Rule__c> lstOrderingRule = [SELECT Ordering_Rule_Days__c,No_Weekend_Order__c,Same_Day_Order__c FROM Ordering_Rule__c WHERE Plant_Code__c =: plantCode AND Product_Code__c =: productCode LIMIT 1];
            return lstOrderingRule;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    // This method returns the details of SPC, to show the SPC details on the portal.
    @AuraEnabled(cacheable=true)
    public static User getSPCDetails(Id accountId){
        User spcUser = new User();   
        String to = null;
        try {
            if(Test.isRunningTest() && showException==true){
                Exception e;
                throw e;
            }
            if(accountId != null) {
                Account objAccount = [SELECT Id,SPC_Email__c FROM Account WHERE Id  =: AccountId LIMIT 1];
                if(objAccount.SPC_Email__c != null) {  
                    for(User obj : [SELECT Id, ContactId, AccountId, FirstName, LastName,Phone,Email FROM User WHERE  Email =: objAccount.SPC_Email__c]){
                        spcUser = obj;
                        spcUser.Email = objAccount.SPC_Email__c;
                    }
                }
            }                
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return spcUser;
    } 
}