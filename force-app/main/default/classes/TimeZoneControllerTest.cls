/*-------------------------------------------------------------------------------------------------
Name: TimeZoneController
Purpose: Use to convert standard VF page GMT timezone format to user time zone format test class.
---------------------------------------------------------------------------------------------------
VERSION          AUTHOR               DATE                  DETAIL            
---------     ---------------     --------------      -------------------
1.0 -        Ravikant Vijapure     23th Dec 2023      INITIAL DEVELOPMENT                
-------------------------------------------------------------------------------------------------*/
@isTest
public class TimeZoneControllerTest {
@isTest
    static void testGetFormattedDatetime() {
        TimeZoneController controller = new TimeZoneController();
    
        controller.date_time = DateTime.newInstance(2023, 11, 21, 02, 00, 00);
        System.debug('controller.date_time'+controller.date_time);
        controller.defined_format = 'yyyy-MM-dd HH:mm:ss';
        System.debug('controller.defined_format'+controller.defined_format);
 
        String formattedDatetime = controller.getFormattedDatetime();
        System.debug('formattedDatetime'+formattedDatetime);
 
        System.assertEquals('2023-11-21 02:00:00', formattedDatetime, 'Unexpected formatted datetime');
 
        // Test with null date_time
        controller.date_time = null;
        formattedDatetime = controller.getFormattedDatetime();
        System.assertEquals('', formattedDatetime, 'Expected empty string for null date_time');
 
        // Test with null defined_format
        controller.date_time = DateTime.newInstance(2023, 11, 21, 12, 30, 0);
        controller.defined_format = null;
        formattedDatetime = controller.getFormattedDatetime();
        System.assertNotEquals('', formattedDatetime, 'Expected non-empty string when defined_format is null');
    }
}