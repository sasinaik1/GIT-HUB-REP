Global class cls_UnitedSIP {

public static string values{get;set;}
public static Account account { get; set; }


    global cls_UnitedSIP(){
    
    }
    
    //Comments
    @RemoteAction
    global static string getAccount() {
        account = [SELECT Id, Name, Phone, Type, NumberOfEmployees 
                   FROM Account limit 1];
        system.debug('account -->' + account);
        return JSON.serialize([SELECT Id, Name, Phone, Type, NumberOfEmployees 
                   FROM Account limit 1]);
    }

    @RemoteAction
    global static List<Contact> getContactsByAccountName(String name) {
        String strLikeFilter = '%' + name + '%';
        Account acc;
        
        acc = [SELECT Id, Name from Account Where Name like: strLikeFilter Limit 1];

        return [SELECT Id, Name, Email, Title, Phone from Contact WHERE AccountId =: acc.Id ];
    }
    
    @RemoteAction
    global static List<Contact> getContactsByAccountNameSite(String name,string site) {
        String strLikeFilter = '%' + name + '%';
        String strSiteLikeFilter = '%' + site + '%';
        Account acc;
        acc = [SELECT Id, Name from Account Where Name like: strLikeFilter and Site =: strSiteLikeFilter Limit 1];

        return [SELECT Id, Name, Email, Title, Phone from Contact WHERE AccountId =: acc.Id ];
    }

    @RemoteAction
    global static List<Account> getAccountByAccountName(String name) {
        String strLikeFilter = '%' + name + '%';

        return [SELECT Id, Name, Phone, Type, Service_Funds__c from Account WHERE Name like: strLikeFilter Limit 1];
    }

    @RemoteAction
    global static Boolean updateContacts(List<Contact> contacts) {
        try{
            System.debug(LoggingLevel.INFO, '*** contacts: ' + contacts);
            Boolean flagSuccess = FALSE;
            List<Database.SaveResult> results;
            if(contacts != NULL && !contacts.isEmpty()) {
                results = Database.update(contacts);
            } else {
                return FALSE;
            }

            for(Database.SaveResult result : results) {
                if(result.isSuccess()) {
                    flagSuccess = TRUE;
                } else {
                    flagSuccess = FALSE;
                    break;
                }
            }

            return flagSuccess;
        } catch(Exception ex) {
            System.debug(LoggingLevel.INFO, '*** ex.getMessage(): ' + ex.getMessage());
            return FALSE;
        }
    }

    @RemoteAction
    global static VFP_UnitedSIPEntity.VFP_UnitedSIPEntity_NoticeAlertForRy getNotices() {

        List<Travel_Waiver__c> lstTravelWaivers = [SELECT Id
                                                        , Name
                                                        , Event_Description__c
                                                        , End_Date_Time__c
                                                        , Start_Date_Time__c
                                                        , Waiver_Code__c
                                                        , Impacted_Airports__c
                                                        , CreatedDate
                                                    FROM Travel_Waiver__c];

        List<VFP_UnitedSIPEntity.VFP_UnitedSIPEntity_TravelWaiver> lstNoticeAlerts = new List<VFP_UnitedSIPEntity.VFP_UnitedSIPEntity_TravelWaiver>();
        VFP_UnitedSIPEntity.VFP_UnitedSIPEntity_NoticeAlertForRy returnNoticeAlert = new VFP_UnitedSIPEntity.VFP_UnitedSIPEntity_NoticeAlertForRy();
        for(Travel_Waiver__c tempOriginalWaiver : lstTravelWaivers) {
            VFP_UnitedSIPEntity.VFP_UnitedSIPEntity_TravelWaiver returnTravelWaiver = new VFP_UnitedSIPEntity.VFP_UnitedSIPEntity_TravelWaiver();
            returnTravelWaiver.impactedAirports = tempOriginalWaiver.Impacted_Airports__c;
            returnTravelWaiver.waiverSFId = tempOriginalWaiver.Id;
            returnTravelWaiver.publishDate = tempOriginalWaiver.CreatedDate != NULL ? String.valueOf(tempOriginalWaiver.CreatedDate) : '';
            returnTravelWaiver.startDateTime = tempOriginalWaiver.Start_Date_Time__c != NULL ? String.valueOf(tempOriginalWaiver.Start_Date_Time__c) : '';
            returnTravelWaiver.endDateTime = tempOriginalWaiver.End_Date_Time__c != NULL ? String.valueOf(tempOriginalWaiver.End_Date_Time__c) : '';
            returnTravelWaiver.eventDescription = tempOriginalWaiver.Event_Description__c;
            returnTravelWaiver.waiverCode = tempOriginalWaiver.Waiver_Code__c;
            lstNoticeAlerts.add(returnTravelWaiver);
        }

        if(!lstNoticeAlerts.isEmpty()) {
            returnNoticeAlert.travelWaivers = lstNoticeAlerts;
            VFP_UnitedSIPEntity.VFP_UnitedSIPEntity_Result result = new VFP_UnitedSIPEntity.VFP_UnitedSIPEntity_Result();
            result.isSuccessful = TRUE;
            result.erroMessage = '';
            returnNoticeAlert.result = result;
        }

        System.debug(LoggingLevel.INFO, '*** returnNoticeAlert: ' + returnNoticeAlert);
        System.debug(LoggingLevel.INFO, '*** returnNoticeAlert JSON: ' + JSON.serialize(returnNoticeAlert));
        return returnNoticeAlert;
    }
}