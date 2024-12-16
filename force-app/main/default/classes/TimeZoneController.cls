/*-------------------------------------------------------------------------------------------------
Name: TimeZoneController
Purpose: Use to convert standard VF page GMT timezone format to user time zone format.
---------------------------------------------------------------------------------------------------
VERSION          AUTHOR               DATE                  DETAIL            
---------     ---------------     --------------      -------------------
1.0 -        Ravikant Vijapure     23th Dec 2023      INITIAL DEVELOPMENT                
-------------------------------------------------------------------------------------------------*/
public class TimeZoneController
{   
    public DateTime date_time { get; set; } //property that reads the datetime value from component attribute tag
    public String defined_format { get; set;} //property that reads the string value from component attribute tag
    TimeZone userTimeZone = UserInfo.getTimeZone();
    public String getFormattedDatetime()
    {
        if (date_time == null) {return ''; }
        else { 
            if (defined_format == null) {
                return date_time.format(); //return the full date/time in user's locale and time zone'
            }
            else { 
                return date_time.format(defined_format, userTimeZone.toString()); //Specify Time zone like IST,CST
            }
        }
    }
}