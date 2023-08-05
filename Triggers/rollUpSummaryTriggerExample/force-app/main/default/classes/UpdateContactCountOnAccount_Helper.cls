public without sharing class UpdateContactCountOnAccount_Helper {
    public static void afterInsertDeleteAndUndeleteHandler(List<Contact> conRecords) {
        Set<Id> accIds = new Set<Id>();

        for (Contact each : conRecords) {
            if (each.AccountId != null) {
                accIds.add(each.AccountId);
            }
        }

        if (!accIds.isEmpty()) {
            updateNumberOfContactsOnAccount(accIds);
        }
    }

    public static void afterUpdateHandler(List<Contact> conRecords, Map<Id,Contact> conOldRecordMap) {
        Set<Id> accIds = new Set<Id>();

        for (Contact each : conRecords) {
            if (each.AccountId != conOldRecordMap.get(each.Id).AccountId) {
                if (conOldRecordMap.get(each.Id).AccountId != null) {
                    accIds.add(conOldRecordMap.get(each.Id).AccountId);
                }

                if (each.AccountId != null) {
                    accIds.add(each.AccountId);
                }
            }
        }

        if (!accIds.isEmpty()) {
            updateNumberOfContactsOnAccount(accIds);
        }
    }

    private static void updateNumberOfContactsOnAccount(Set<Id> accIds) {
        List<Account> accList = [SELECT Id, Number_Of_Contacts__c, (SELECT Id FROM Contacts) FROM Account WHERE Id IN :accIds];
        List<Account> accToUpdate = new List<Account>();

        if (!accList.isEmpty()) {
            for (Account acc : accList) {
                acc.Number_Of_Contacts__c = String.valueOf(acc.Contacts.size());
                accToUpdate.add(acc);
            }
        }

        if (!accToUpdate.isEmpty()) {
            update accToUpdate;
        }
    }
}