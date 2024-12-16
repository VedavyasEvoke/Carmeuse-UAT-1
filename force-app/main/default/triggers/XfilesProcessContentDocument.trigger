trigger XfilesProcessContentDocument on ContentDocumentLink (after insert) {
    Map<Id,String> contentDocumentIdVsLinkId = new Map<Id,String>();
    Map<String,List<String>> objNameVsIdMap = new Map<String,List<String>>();
    
    // Update the key prefix to reflect the custom object 'SBQQ__Quote__c' with prefix 'a17'
    Map<String,String> keyPrefixVsObjNameMap = new Map<String,String>{'a17'=>'SBQQ__Quote__c'};

    for(ContentDocumentLink cdl : trigger.new) {
        if(keyPrefixVsObjNameMap.containsKey(String.valueOf(cdl.LinkedEntityId).substring(0,3))) {
            contentDocumentIdVsLinkId.put(cdl.ContentDocumentId, cdl.LinkedEntityId);
        }
    }

    Set<Id> contentDocumentIdSet = contentDocumentIdVsLinkId.keySet();

    if(!contentDocumentIdSet.isEmpty()) {
        for(ContentDocumentLink cdl : [
            SELECT Id, ContentDocumentId, LinkedEntityId, ContentDocument.ContentSize, ContentDocument.FileType 
            FROM ContentDocumentLink 
            WHERE ContentDocumentId IN :contentDocumentIdSet
        ]) {
            String objPrefix = String.valueOf(cdl.LinkedEntityId).substring(0,3);
            if(!keyPrefixVsObjNameMap.containsKey(objPrefix)
            || cdl.ContentDocument.ContentSize < 200
            || cdl.ContentDocument.FileType == 'SNOTE') {
                continue;
            }

            if(!objNameVsIdMap.containsKey(keyPrefixVsObjNameMap.get(objPrefix))) {
                objNameVsIdMap.put(keyPrefixVsObjNameMap.get(objPrefix), new List<String>());
            }
            objNameVsIdMap.get(keyPrefixVsObjNameMap.get(objPrefix)).add(cdl.Id);
        }

        if(!objNameVsIdMap.isEmpty()) {
            for(String objName : objNameVsIdMap.keySet()) {
                if(String.isNotBlank(objName)) {
                    XFILES.XfilesExportController.ExportParams exportParams = new XFILES.XfilesExportController.ExportParams();
                    exportParams.objectName = objName;
                    exportParams.fileOrAttIdsList = objNameVsIdMap.get(objName);
                    exportParams.replaceFiles = true; // pass true to replace files otherwise false (ONLY FOR SHAREPOINT AZURE)
					if(!Test.isRunningTest()) {
                    XFILES.XfilesExportController.invokeExportBatchJob(exportParams);
                }
                }
            }
        }
    }
}