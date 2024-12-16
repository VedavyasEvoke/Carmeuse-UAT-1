/**
* Class Name         : Ev_CPQPricingConditionControllerTest
* Developer          : D Sridhar           
* Created Date       : 07-05-2024
* @description       : Custom Controller for ev_CPQPricingCondition VisualForce Page
* Last Modified Date : 
*/
public class Ev_CPQPricingConditionController {
    /**
* @description Navigates from Pricing Condition Component Page to Quote Line Editor page.
* @return Returns the PageReference of the Quote Line Editor Page.
*/
    public PageReference navigateToUrl() {
        PageReference pageRef = new PageReference('/apex/sbqq__sb?id=' + Apexpages.currentPage().getParameters().get('Id'));
        pageRef.setRedirect(true);
        return pageRef;
    }
}