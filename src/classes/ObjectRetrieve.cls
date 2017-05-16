public with sharing class ObjectRetrieve {

    public String displayFields { get; set; }
    public String currentObjectName{get;set;}
    public List<sObject> currentRecords{get;set;}
    public List<String> selectFields{get;set;}
    public List<String> displayedFields{get;set;}
    
    //populate the dropdown menu of custom objects
    public List<SelectOption> getobjNames(){
        //use the global describe because we need to select specific objects (custom objects) without knowing their name
        List<Schema.SObjectType> globalDescribeValues = Schema.getGlobalDescribe().Values();
        //create our list of options and add a default 'none'
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('--None','--None--'));
        for(Schema.SObjectType sObjType : globalDescribeValues){
            //when we describe our SObjectType, we get a DescribeSObjectResult object
            //here is one way to do it, take advantage of __c in custom obj name:
            //String sObjectName = sObjType.getDescribe().getName().contains('__c');
            //if(sObjectName.contains('__c')){
            //    options.add(new SelectOption(sObjectName,sObjType.getDescribe().getLabel()));
            //}

            //here is a better way to do it
            //use the isCustom() method on the DescribeSObjectResult object 
            if(sObjType.getDescribe().isCustom()){
                options.add(new SelectOption(sObjType.getDescribe().getName(),sObjType.getDescribe().getLabel()));
            }
        }
       return options;
    }

    //find all of the checkbox fields for the selected object type
    //find all of the objects for the selected type 
    public void getAllObjectsList(){
        //get all checklist fields
        Map<String, Schema.SObjectType> orgGlobalDescribe = Schema.getGlobalDescribe();
        Schema.SObjectType sObjType = orgGlobalDescribe.get(currentObjectName);
        //we've seen this algorthim for getting fields
        Map<String, Schema.SObjectField> objFields = sObjType.getdescribe().fields.getmap();
        //will use selectfields to construct a query and will use displayedFields to construct table
        selectFields = new List<String>();
        displayedFields = new List<String>();
        //we want all checklist fields + the Name of the record
        selectFields.add('Name');
        displayedFields.add('Name');
        
        //check out all the fields on the object
        for(Schema.SObjectField sObjField :  objFields.values()){
            //have a schema type, so now we can get the describe result
            Schema.DescribeFieldResult fieldDescribe = sObjField.getDescribe();
            //2 things matter - is the field custom and what is it's type?
            Boolean isCustom = fieldDescribe.isCustom();
            Schema.DisplayType fieldType = fieldDescribe.getType();
            if(fieldType == Schema.DisplayType.Boolean && isCustom == true){
                //we need to be able to query that field on records
                //and display it's name correctly
                selectFields.add(fieldDescribe.getName());
                displayedFields.add(fieldDescribe.getLabel());
            }
        }
        String queryString = 'SELECT ' + String.join(selectFields, ', ') + ' FROM ' + currentObjectName;
        currentRecords = Database.query(queryString);
    }
}