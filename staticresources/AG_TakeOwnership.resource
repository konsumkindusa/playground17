crmc.require(["KendoPopup", "sfdc"], function(popup,sfdc){
crmc.addCustomAction({
  itemID: "TakeOwnership",
  isAvailable: function(context) {
    // This function is called before the action item is displayed and returns a boolean if the item should be displayed
    // By default determine availability based on Feature Security for this action
    var isEnabled = this.featureSecurity.getSetting(context.objectDescribe.name, this.itemID) !== false;
    var isAccessible = context.objectDescribe.name == "Case";
    var oneSelected = context.selectedRows && context.selectedRows.length > 0 && context.selectedRows.length < 2;
    return isAccessible && isEnabled && oneSelected;
  },
  isHeaderAvailable: function(context) {
    // This function determines if this item can be displayed from the column header menu
    return false;
  },
  isToolbarAvailable: function(context) {
    // This function determines if this item can be displayed in the Toolbar as a button
    return true;
  },
  getLabel: function(context) {
    // This function returns the display label of the action item and is called before the item is shown
    return "TakeOwnership";
  },
  createSubmenuItems: function(context) {
    // If this function returns additional action item objects, they will appear as submenu items
    return [];
  },
  "InvokeApexMethod": function(className, methodName, parameters) {
    if (sforce && sforce.apex && sforce.apex.execute) {
          sforce.apex.execute(className, methodName, parameters);
      }
    else {
        var that = this;
        sfdc.importScript("/soap/ajax/30.0/apex.js", function() {
        that.InvokeApexMethod(className, methodName, parameters);
        });
        }
  },
  click: function(context) {
    // This function calls the existing Case Custom Button logic for TakeOwnershipCase.
    // It passes the same arguments.
          var that = this;
          this.InvokeApexMethod("CustomButtonFunctions","TakeOwnershipCase",
          {caseId:context.selectedRows[0].Id,
           userId:sfdc.getUserInfo().userId});
          context.actionGrid.refresh();
      }
});
});