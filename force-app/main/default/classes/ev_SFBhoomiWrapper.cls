/***************************************************************************************************************************************************
# Class Name  = "ev_SFBhoomiWrapper"
# Author      = Naganjaneya Lakshman
# Description = This is wrapper class to integrate between Salesforce and Bhoomi.

# Change Log :
============================================================================================================
Date                     Changed By                        Change Description
============================================================================================================
20/03/2024               Naganjaneya Lakshman              Original Version
**************************************************************************************************************************************************/

public class ev_SFBhoomiWrapper {

        public Customer Customer;
        public Quote Quote;
        public List<QuoteLines> QuoteLines;

        public class Customer {
            public String CustomerNumber;
            public String Name;
            public String Legal_Name;
            public String ParentId;
            public String Customer_Group;
            public String MSD_Customer_Id;
        }

        public class Quote {
            public String SF_Quote_Id;
            public String MSD_Quote_ID;
        }
    
        public class QuoteLines {
            public String SF_QuoteLine_Id;
            public String SBQQ_ProductCode;
            public Decimal SBQQ_Quantity;
            public String MSD_QuoteLine_Id;
        }
    
}