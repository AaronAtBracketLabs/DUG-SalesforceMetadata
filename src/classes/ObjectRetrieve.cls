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
        //get the Object type for the currentObjectName
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
/*
            if(fieldDescribe.isUpdateable()){
                updatableFields.add(fieldDescribe.getName());
            }
*/
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

    public void exampleQuestionOne(){
        /*
            Show me all of the fields in the Visible_Fields field set, for all objects
        */

        //globalDescribe will contain all ofthe sobjects
        Map<String, Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe();
        for(Schema.SObjectType sObjectInOrg : globalDescribe.values()){
            DescribeSObjectResult dsor = sObjectInOrg.getDescribe();
            //get the fieldSets map out of the DescribeSObjectResult
            Map<String, Schema.FieldSet> fieldSetsMap = dsor.fieldSets.getMap();
            //we look in the fieldsets map for the API name
            if(fieldSetsMap.get('Visible_Fields') != null){
                //here is where we finally have actual fieldset schema object for this sObject type
                Schema.FieldSet visibleFieldSet = fieldSetsMap.get('Visible_Fields');
                //the getFields() method will return a list of Schema.FieldSetMembers, so 
                for(Schema.FieldSetMember f : visibleFieldSet.getFields()) {
                    system.debug(f.getLabel());
                }
            }
        }

    }

    public void exampleQuestionTwo(){
        Map<String, Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe();
        for(Schema.SObjectType sObjectInOrg : globalDescribe.values()){
            DescribeSObjectResult dsor = sObjectInOrg.getDescribe();
            if(dsor.isCustom()){
                Map<String, Schema.SObjectField> fields = dsor.fields.getMap();
                for(Schema.SObjectField field : fields.values()){
                    Schema.DescribeFieldResult fieldDescribe = field.getDescribe();
                    if(fieldDescribe.getType() == Schema.DisplayType.Reference){
                        List<Schema.sObjectType> lookupTo = fieldDescribe.getReferenceTo();
                        for(Schema.sObjectType lookupFieldType : lookupTo){
                            DescribeSObjectResult lookupFieldDescribe = lookupFieldType.getDescribe();
                            if(lookupFieldDescribe.getName() == 'Account'){
                                system.debug(lookupFieldDescribe.getLabel());
                                system.debug(dsor.getLabel());
                                system.debug('***********************');
                            }
                        }
                    }
                }
            }
        }
    }

    public void save(){
        update currentRecords;
    }
}