trigger UpdateContactCountOnAccount on Contact (after insert, after update, after delete, after undelete) {
    
    Set<Id> accIds = new Set<Id>();

    if (trigger.isAfter && (trigger.isInsert || trigger.isUndelete)) {
        if (!trigger.new.isEmpty()) {
            // for (Contact each : trigger.new) {
            //     if (each.AccountId != null) {
            //         accIds.add(each.AccountId);
            //     }
            // }
            UpdateContactCountOnAccount_Helper.afterInsertDeleteAndUndeleteHandler(trigger.new);
        }
    }

    if (trigger.isAfter && trigger.isUpdate) {
        if (!trigger.new.isEmpty()) {
            // for (Contact each : trigger.new) {
            //     if (each.AccountId != trigger.oldMap.get(each.Id).AccountId) {
            //         if (trigger.oldMap.get(each.Id).AccountId != null) {
            //             accIds.add(trigger.oldMap.get(each.Id).AccountId);
            //         }

            //         if (each.AccountId != null) {
            //             accIds.add(each.AccountId);
            //         }
            //     }
            // }

            UpdateContactCountOnAccount_Helper.afterUpdateHandler(trigger.new, trigger.oldMap);
        }
    }

    if (trigger.isAfter && trigger.isDelete) {
        if (!trigger.old.isEmpty()) {
            // for (Contact each : trigger.old) {
            //     if (each.AccountId != null) {
            //         accIds.add(each.AccountId);
            //     }
            // }
            UpdateContactCountOnAccount_Helper.afterInsertDeleteAndUndeleteHandler(trigger.old);
        }
    }

    // if (!accIds.isEmpty()) {
    //     List<Account> accList = [SELECT Id, Number_Of_Contacts__c, (SELECT Id FROM Contacts) FROM Account WHERE Id IN :accIds];
    //     List<Account> accToUpdate = new List<Account>();

    //     if (!accList.isEmpty()) {
    //         for (Account acc : accList) {
    //             acc.Number_Of_Contacts__c = String.valueOf(acc.Contacts.size());
    //             accToUpdate.add(acc);
    //         }
    //     }

    //     if (!accToUpdate.isEmpty()) {
    //         update accToUpdate;
    //     }
    // }
}