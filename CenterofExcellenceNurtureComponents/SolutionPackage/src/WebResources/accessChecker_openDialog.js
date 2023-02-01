function openAccessChecker(primaryControl, firstPrimaryItemId, primaryEntityTypeName) {
 var parameters = {
   "param_accesschecker_entityname":primaryEntityTypeName,
   "param_accesschecker_objectid":firstPrimaryItemId,
  };
  var options = {
    height: 800,
    width: 1200,
  };
  Xrm.Navigation.openDialog("AccessCheckerDialog", options, parameters);
}