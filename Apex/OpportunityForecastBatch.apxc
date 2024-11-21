global class OpportunityForecastBatch implements Database.Batchable <sObject>, Database.Stateful {
    Integer recordsProcessed=0;
    Integer records;
    Integer recordsfailed=0;
    public List<Period> periodList;
    public Map<Id, Period> periodMap;
    public Map<Id, Map<Id, ForecastingCustomData>> terrIdVsDateWiseMlWinSum;
    public Set<Id> allPeriods;
    List<ForecastingType> forecastingList;

    // Constructor
    public OpportunityForecastBatch() {
        terrIdVsDateWiseMlWinSum = new Map<Id, Map<Id, ForecastingCustomData>>();
        allPeriods = new Set<Id>();
        forecastingList = [SELECT ID, MasterLabel 
                           FROM ForecastingType 
                           WHERE MasterLabel =:LABEL.Forecasting_Type_Category 
                           LIMIT 1];
        periodList = [SELECT Id, StartDate, EndDate, Number 
                      FROM Period 
                      WHERE Type = 'Quarter' 
                      AND StartDate >= LAST_YEAR 
                      AND StartDate <= NEXT_YEAR];
        periodMap = new Map<Id,Period>(periodList);
    }

    public Database.QueryLocator start(Database.BatchableContext BC){
        String query;
        if (Test.isRunningTest()) {
            query = 'SELECT ID, Territory2Id, Forecast_Category1__c,Prediction_TCV__c, Territory2.ForecastUserId, Territory2.ParentTerritory2.ForecastUserId, StageName, Predicted_Win_TCV__c, CloseDate FROM Opportunity';
        } else {
            query = 'SELECT ID, Territory2Id, Territory2.ForecastUserId,Prediction_TCV__c, Territory2.ParentTerritory2.ForecastUserId, Predicted_Win_TCV__c, CloseDate FROM Opportunity WHERE Territory2Id != null AND ';
            query += 'CloseDate >= LAST_YEAR AND CloseDate <= NEXT_YEAR AND Forecast_Category1__c != \'Omitted\' ';
            query += 'AND StageName Not In (\'Prediscover\', \'7. Lost\', \'8. Dropped\')';
        }

        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<Opportunity> opportunityList){
        if (!opportunityList.isEmpty()) {
            try {
                for (Opportunity opp : opportunityList) {
                    for (Period pr : periodList) {
                        if (opp.CloseDate >= pr.StartDate && opp.CloseDate <= pr.EndDate) {
                            Integer year = opp.CloseDate.Year();
                            Integer month = pr.Number == 1 ? 1 : pr.Number == 2 ? 4 : pr.Number == 3 ? 7 : 10;
                            if (!terrIdVsDateWiseMlWinSum.containsKey(opp.Territory2Id)) {
                                terrIdVsDateWiseMlWinSum.put(opp.Territory2Id, new Map<Id, ForecastingCustomData>());
                            }

                            if (terrIdVsDateWiseMlWinSum.containsKey(opp.Territory2Id) &&
                                !terrIdVsDateWiseMlWinSum.get(opp.Territory2Id).containsKey(pr.Id)) {
                                    ForecastingCustomData rec = new ForecastingCustomData();
                                    rec.Territory2Id = opp.Territory2Id;
                                    rec.StartDate = pr.StartDate;
                                    rec.Einstein_Prediction_Score__c = opp.Prediction_TCV__c;
                                    rec.ForecastingTypeId = forecastingList[0].Id;
                                    rec.ForecastOwnerId = opp.Territory2.ForecastUserId;
                                    terrIdVsDateWiseMlWinSum.get(opp.Territory2Id).put(pr.Id, rec);
                                } else {
                                    terrIdVsDateWiseMlWinSum.get(opp.Territory2Id).get(pr.Id).Einstein_Prediction_Score__c +=opp.Prediction_TCV__c;
                                }
                            allPeriods.add(pr.Id);
                        }
                    }
                }
            } catch(Exception ex) {
                system.debug(ex.getMessage() + '  :::::  ' + ex.getLineNumber());
            }
        }
    }

    public void finish(Database.BatchableContext BC) {
        if (!terrIdVsDateWiseMlWinSum.isEmpty() && terrIdVsDateWiseMlWinSum.keySet().size() > 0) {
            List<ForecastingCustomData> listToInsert = new List<ForecastingCustomData>();
            calculateParentLevelHierarchyValue();

            for (Id terrId : terrIdVsDateWiseMlWinSum.keySet()) {
                for (Id periodInstance : terrIdVsDateWiseMlWinSum.get(terrId).keySet()) {
                     listToInsert.add(terrIdVsDateWiseMlWinSum.get(terrId).get(periodInstance));
                }
            }

            List<String> errorList = new List<String>();
            if (!listToInsert.isEmpty()) {
                Database.saveResult[] insResp = Database.insert(listToInsert, false);
                for (Database.SaveResult sr : insResp) {
                    if (!sr.isSuccess()) {
                        // Operation failed, so get all errors                
                        for(Database.Error err : sr.getErrors()) {
                            System.debug('The following error has occurred.');                    
                            System.debug(err.getStatusCode() + ' ::::: ' + err.getMessage());
                            System.debug('Forecast fields that affected this error: ' + err.getFields());
                        }
                    }
                }
            }
        }
    }

    /**
     * 1. Getting all Territories
     * 2. Looping all territories and creating a map of parent territory and List of all child territories - EX: {'HEALTH CARE':
['JINICHI','SUKETH'],'SUKETH':['Krishnakumar','Rohit','Sam','Thomas'],'Thomas','Kate','Satinderbir'}
     * 3. Creating all territories and identify the last territories(No childs) the hierarchy and prepare List. It helps to do bottom up
approach to calculate values
     * 4. Loop all the LastHierarchyTerritory territories and call calculate Hierarchy
     * 5. Update child values to its parent
     * 6. Update ForecastingCustomData
     * 7. Remove all child territory from all territory and again calculate child territories
     * 8. Repeat till u reach parent
     */

    public void calculateParentLevelHierarchyValue() {

        Map<Id, Territory2> territoryIdValueMap = new Map<Id, Territory2>([SELECT Id, ForecastUserId, ParentTerritory2Id, ParentTerritory2.ForecastUserId FROM Territory2]);
        List<Id> allTerritoryIds = new List<Id>(territoryIdValueMap.keySet());

        // create forecastingCustomData record for the territories not having opportunity records.
        for(Id territoryId : allTerritoryIds) {
            Territory2 t = territoryIdValueMap.get(territoryId);
            if(t.ParentTerritory2Id != null) {
                if(!terrIdVsDateWiseMlWinSum.containsKey(t.ParentTerritory2Id)) {
                    terrIdVsDateWiseMlWinSum.put(t.ParentTerritory2Id, new Map<Id, ForecastingCustomData>());
                }

                if (!terrIdVsDateWiseMlWinSum.containsKey(territoryId)) {
                    terrIdVsDateWiseMlWinSum.put(territoryId, new Map<Id, ForecastingCustomData>());
                }

                for(Id p : allPeriods) {
                    if(!terrIdVsDateWiseMlWinSum.get(t.ParentTerritory2Id).containsKey(p)) {
                        ForecastingCustomData fccdParent = new ForecastingCustomData();
                        fccdParent.Territory2Id = t.ParentTerritory2Id;
                        fccdParent.StartDate = periodMap.get(p).StartDate;
                        fccdParent.Einstein_Prediction_Score__c = 0; // Initialize with 0
                        fccdParent.ForecastingTypeId = forecastingList[0].Id;
                        fccdParent.ForecastOwnerId = t.ParentTerritory2.ForecastUserId;
                        terrIdVsDateWiseMlWinSum.get(t.ParentTerritory2Id).put(p, fccdParent);
                    }

                    if (!terrIdVsDateWiseMlWinSum.get(territoryId).containsKey(p)) {
                        ForecastingCustomData fccdChild = new ForecastingCustomData();
                        fccdChild.Territory2Id = territoryId;
                        fccdChild.StartDate = periodMap.get(p).StartDate;
                        fccdChild.Einstein_Prediction_Score__c = 0;
                        fccdChild.ForecastingTypeId = forecastingList[0].Id;
                        fccdChild.ForecastOwnerId = t.ForecastUserId;
                        terrIdVsDateWiseMlWinSum.get(territoryId).put(p,fccdChild);
                    }
                }
            }
        }

        while(allTerritoryIds.size() != 0) {
            List<Id> lastLinkTerritoriesIds = getLastNodesOfHierarchy(allTerritoryIds,territoryIdValueMap);
            if(lastLinkTerritoriesIds.size() > 0) {
                for(Id lastlinkT : lastLinkTerritoriesIds) {
                    calculateHierarchyValue(lastlinkT,territoryIdValueMap);
                }
                removeChildNodes(allTerritoryIds,lastLinkTerritoriesIds);
            }

            if(lastLinkTerritoriesIds.size() == 0) {
                allTerritoryIds = new List<Id>();
            }
        }
    }

    public List<Id> getLastNodesOfHierarchy(List<Id> allTerritoryIds, Map<Id,Territory2> territoryIdValueMap) {
        Map<Id,List<Id>> parentIdChildIdsTerritoryMap = new Map<Id,List<Id>>();
        List<Id> lastLinkTerritoriesIds = new List<Id>();

        for(Id territoryId : allTerritoryIds) {
            Territory2 t = territoryIdValueMap.get(territoryId);
            if(parentIdChildIdsTerritoryMap.containsKey(t.ParentTerritory2Id)) {
                parentIdChildIdsTerritoryMap.get(t.ParentTerritory2Id).add(t.Id);
            } else if(t.ParentTerritory2Id == null) {
                parentIdChildIdsTerritoryMap.put(t.Id,new List<Id>());
            }else{
                parentIdChildIdsTerritoryMap.put(t.ParentTerritory2Id,new List<Id>{t.Id});
            }
        }

        for(Id territoryId : allTerritoryIds) {
            Territory2 t = territoryIdValueMap.get(territoryId);
            if(!parentIdChildIdsTerritoryMap.containsKey(t.Id)) {
                lastLinkTerritoriesIds.add(t.Id);
            }
        }
        return lastLinkTerritoriesIds;
    }

    public void calculateHierarchyValue(Id territoryId, Map<Id,Territory2> territoryIdValueMap) {
        Territory2 lastlinkT = territoryIdValueMap.get(territoryId);
        if(lastlinkT.ParentTerritory2Id != null) {
            for(Id p : allPeriods) {
                if (terrIdVsDateWiseMlWinSum.containsKey(lastlinkT.ParentTerritory2Id) && 
                    terrIdVsDateWiseMlWinSum.get(lastlinkT.ParentTerritory2Id).containsKey(p) && 
                    terrIdVsDateWiseMlWinSum.containsKey(lastlinkT.Id) && terrIdVsDateWiseMlWinSum.get(lastlinkT.Id).containsKey(p) ) {
                        ForecastingCustomData fccdParent = terrIdVsDateWiseMlWinSum.get(lastlinkT.ParentTerritory2Id).get(p);
                        ForecastingCustomData fccdChild = terrIdVsDateWiseMlWinSum.get(lastlinkT.Id).get(p);
                        fccdParent.Einstein_Prediction_Score__c = fccdParent.Einstein_Prediction_Score__c +
                            fccdChild.Einstein_Prediction_Score__c;
                    }
            }
        }
    }

    public void removeChildNodes(List<Id> allTerritoryIds,List<Id> lastLinkTerritoriesIds) {
        for(Id tId : lastLinkTerritoriesIds) {
            for(Integer i = 0; i < allTerritoryIds.size(); i++) {
                if(allTerritoryIds[i] == tId) {
                    allTerritoryIds.remove(i);
                }
            }
        }
    }
}
