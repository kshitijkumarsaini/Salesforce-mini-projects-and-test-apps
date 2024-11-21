global class TerritoryForecastBatch implements Database.Batchable<SObject>, Database.Stateful, Schedulable {
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator('SELECT Id FROM ForecastingCustomData');
    }

    global void execute(Database.BatchableContext BC, List<ForecastingCustomData> scope) {
        if (!scope.isEmpty()) {
            delete scope;
            Database.emptyRecycleBin(scope);
        }
    }

    global void finish(Database.BatchableContext BC) {
        // Call the next batch to calculate the Forecast
        Database.executeBatch(new OpportunityForecastBatch(), 2000);
    }

    global void execute(SchedulableContext SC) {
        Database.executeBatch(new TerritoryForecastBatch(), 2000);
    }

    // Method to schedule the batch
    public static void scheduleBatch() {
        String cronExp = '0 0 21 ? * MON'; // The job will run every Monday at 9PM
        String jobName = 'TerritoryForecastBatchScheduler';

        System.schedule(jobName, cronExp, new TerritoryForecastBatch());
    }
}
