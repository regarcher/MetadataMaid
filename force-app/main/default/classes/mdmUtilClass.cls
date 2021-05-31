public with sharing class mdmUtilClass {
    public static string SanitizeString(String pString){
        String strRetVal = string.escapeSingleQuotes(pString);
        return strRetVal.replaceAll('[^\\w]','');
    }
}
