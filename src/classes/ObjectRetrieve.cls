public with sharing class ObjectRetrieve {

    public String displayFields { get; set; }
    public String currentObjectName{get;set;}
    public List<sObject> currentAnimals{get;set;}
    public List<String> selectFields{get;set;}
    public List<String> displayedFields{get;set;}
    
    public List<SelectOption> getobjNames(){
        List<Schema.SObjectType> globalDescribeValues = Schema.getGlobalDescribe().Values();
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('--None','--None--'));
        for(Schema.SObjectType sObjType : globalDescribeValues){
            if(sObjType.getDescribe().getName().contains('__c')){
                options.add(new SelectOption(sObjType.getDescribe().getName(),sObjType.getDescribe().getLabel()));
            }
        }
       return options;
    }
    public void getAllObjectsList(){
        //we only have the states the animal has been in, so we cant just query all of them
        //get all checklist fields
        Map<String, Schema.SObjectType> orgGlobalDescribe = Schema.getGlobalDescribe();
        Schema.SObjectType sObjType = orgGlobalDescribe.get(currentObjectName);
        //with an sObjectType, we can access fields
        Map<String, Schema.SObjectField> objFields = sObjType.getdescribe().fields.getmap();
        selectFields = new List<String>();
        displayedFields = new List<String>();
        selectFields.add('Name');
        displayedFields.add('Name');
        for(String fieldName :  objFields.keySet()){
            DescribeFieldResult fieldDescribe = objFields.get(fieldName).getDescribe();
            Boolean isCustom = fieldDescribe.isCustom();
            Schema.DisplayType fieldType = fieldDescribe.getType();
            if(fieldType == Schema.DisplayType.Boolean && isCustom == true){
                selectFields.add(fieldName);
                displayedFields.add(fieldDescribe.getLabel());
            }
        }
        String queryString = 'SELECT ' + String.join(selectFields, ', ') + ' FROM ' + currentObjectName;
        currentAnimals = Database.query(queryString);
    }
}