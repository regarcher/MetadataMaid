public with sharing class UtilityClass {
    public static string SanitizeString(String pString){
        String strRetVal = string.escapeSingleQuotes(pString);
        return strRetVal.replaceAll('[^\\w]','');
    }
}