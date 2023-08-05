trigger CheckDuplicateAccountTrigger on Account (before insert, before update) {
  Set<String> accNames = new Set<String>();

  if (trigger.isBefore && (trigger.isInsert || trigger.isUpdate)) {
    if(!trigger.new.isEmpty()) {
      for(Account acc : trigger.new) {
        accNames.add(acc.Name);
      }
    }
  }

  if (!accName.isEmpty()) {
    List<Account> accRecords = [Select Id, Name from Account where Name IN :accNames];
    Map<String, Account> existingAccMap = new Map<String, Account>();

    if(!accRecords.isEmpty()) {
      for (Account acc : accRecords) {
        existingAccMap.put(acc.Name, acc);
      }

      if (!trigger.new.isEmpty()) {
        for (Account accObj : trigger.new) {
          if (existingAccMap.containsKey(accObj.Name)) {
            accObj.addError('Account Name already exists!');
          }
        }
      }
    }
  }
}
