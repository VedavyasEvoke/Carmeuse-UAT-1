({
    handleClick : function(component, event, helper) {
        console.log('inside');
    },

    closeQuickAction : function(component, event, helper) {
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
    }
})