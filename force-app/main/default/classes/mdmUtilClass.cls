public with sharing class mdmUtilClass {
    //source: https://github.com/regarcher/MetadataMaid
    //This code is part of a package and should not be called from your custom code
    public static string SanitizeString(String pString){
        String strRetVal = string.escapeSingleQuotes(pString);
        return strRetVal.replaceAll('[^\\w]','');
    }
}