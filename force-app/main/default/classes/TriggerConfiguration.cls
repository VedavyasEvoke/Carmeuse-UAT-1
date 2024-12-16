/*----------------------------------------------------------------------
Name:       TriggerConfiguration.cls
Purpose:    Use to activate and deactive trigger from test methods
------------------------------History----------------------------------
Version     Author          Date                    Detail Description 
-------     -------         --------------          ------------------
1.0         Priyanka         14-Feb-2022           Initial Development 
----------------------------------------------------------------------*/
public class TriggerConfiguration{
    public static Boolean doNotRunTrigger = false;

    public static void setDoNotRunTrigger(){
        doNotRunTrigger = true;
    }

    public static Boolean shouldRunTrigger() {
        return !doNotRunTrigger;
    }
}