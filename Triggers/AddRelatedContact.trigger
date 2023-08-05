trigger AddRelatedContact on Account (after insert, after update) {
  List<Contact> conList = new List<Contact>();
  
  if (Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)) {
    if (!Trigger.new.isEmpty()) {
      for (Account acc : Trigger.new) {
        if (acc.Create_Contact_Checkbox__c && (Trigger.isInsert || acc.Create_Contact_Checkbox__c != Trigger.oldMap.get(acc.Id).Create_Contact_Checkbox__c)) {
          Contact con = new Contact();
          con.FirstName = 'Test';
          con.LastName = acc.Name;
          con.Phone = acc.Phone;
          con.AccountId = acc.Id;
          conList.add(con);
        }
      }
    }

    if (!conList.isEmpty()) {
      insert conList;
    }
  }
}
