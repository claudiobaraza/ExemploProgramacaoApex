public class AccountTaskGPSController {
    private ApexPages.StandardController ctr;
    private Account acc;
    public Task newTask {get; private set;}
    public String valueLong { get; set; }
    public String valueLat { get; set; }
    public AccountTaskGPSController(ApexPages.StandardController controller){
        this.ctr = controller;
        newTask = new Task();
        newTask.WhatId = ctr.getId();
    } 
    public PageReference salvaAtividade(){
        newTask.Latitude__c = valueLat;
        newTask.Longitude__c = valueLong;
        insert newTask;
        PageReference pageRef = new PageReference('/'+ctr.getId());        
        pageRef.getParameters().put('inline','0');
        pageRef.setRedirect(true);
        return pageRef;
    }
}