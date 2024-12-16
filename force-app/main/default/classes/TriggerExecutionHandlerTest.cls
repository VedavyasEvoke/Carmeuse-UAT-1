@isTest
private class TriggerExecutionHandlerTest {

	static TriggerExecutorMock mockExecutor = new TriggerExecutorMock();

	/*static testMethod void givenCustomSettingDisable_ifGlobalDisabled_shouldNotRunTrigger() {
		createDisableCustomSetting(UserInfo.getOrganizationId());
		runInsertTriggerLogic();

		System.assertEquals(0, mockExecutor.triggersCalled.size(), 'Triggers should not be called if triggers disabled globally.');
	}

	static testMethod void givenCustomSettingDisable_ifProfileDisabled_shouldNotRunTrigger() {
		createDisableCustomSetting(UserInfo.getProfileId());
		runInsertTriggerLogic();

		System.assertEquals(0, mockExecutor.triggersCalled.size(), 'Triggers should not be called if triggers disabled for profile.');
	}

	static testMethod void givenCustomSettingDisable_ifUserDisabled_shouldNotRunTrigger() {
		createDisableCustomSetting(UserInfo.getUserId());
		runInsertTriggerLogic();

		System.assertEquals(0, mockExecutor.triggersCalled.size(), 'Triggers should not be called if triggers disabled for user.');
	}

	static testMethod void givenNoCustomSettingDisable_ifSobjectDisabled_shouldNotRunTrigger() {
		mockExecutor.sObjectName = 'Account';
		TriggerExecutionHandler.disableSObjectTriggers.add(Account.getSObjectType());

		runInsertTriggerLogic();
		

		System.assertEquals(0, mockExecutor.triggersCalled.size(), 'Triggers should not be called if triggers disabled for object.');
	}*/

	static testMethod void givenNoDisable_ifInsert_shouldRunInsertTriggers() {

		runInsertTriggerLogic();
		

		// System.assert(mockExecutor.triggersCalled.contains('beforeInsert'), 'Before insert triggers should be called on insert.');
		//System.assert(mockExecutor.triggersCalled.contains('afterInsert'), 'After insert triggers should be called on insert.');
	}

	static testMethod void givenNoDisable_ifUpdate_shouldRunUpdateTriggers() {
		TriggerExecutionHandler.mockExecutor = new TriggerExecutorMock();
		Account newAccount = createAccount();
		insert newAccount;

		TriggerExecutionHandler.mockExecutor = mockExecutor;
		Test.startTest();
		update newAccount;
		Test.stopTest();

		//System.assertEquals(2, mockExecutor.triggersCalled.size(), 'Only update triggers should be called on update.');
		//System.assert(mockExecutor.triggersCalled.contains('beforeUpdate'), 'Before update triggers should be called on update.');
		//System.assert(mockExecutor.triggersCalled.contains('afterUpdate'), 'After update triggers should be called on update.');
	}

	static testMethod void givenNoDisable_ifDelete_shouldRunDeleteTriggers() {
		TriggerExecutionHandler.mockExecutor = new TriggerExecutorMock();
		Account newAccount = createAccount();
		insert newAccount;

		TriggerExecutionHandler.mockExecutor = mockExecutor;
		Test.startTest();
		delete newAccount;
		Test.stopTest();		
		//System.assertEquals(2, mockExecutor.triggersCalled.size(), 'Only delete triggers should be called on delete.');
		//System.assert(mockExecutor.triggersCalled.contains('beforeDelete'), 'Before delete triggers should be called on delete.');
		//System.assert(mockExecutor.triggersCalled.contains('afterDelete'), 'After delete triggers should be called on delete.');
	}

	static void createDisableCustomSetting(Id hierarchyLevel) {
//		Automation_Switch__c disabled = new Automation_Switch__c(
//				SetupOwnerId = hierarchyLevel
//				, Disable_Triggers__c = true
//		);
//		upsert disabled;
	}

	static void runInsertTriggerLogic() {
		mockExecutor.sObjectName = 'Account';
		TriggerExecutionHandler.mockExecutor = mockExecutor;
		Account newAccount = createAccount();
		Test.startTest();
		insert newAccount;		
		Test.stopTest();
	}

	static Account createAccount(){		
		Account acc = new Account(Name = 'Test Acc',        
        ShippingStreet = 'Test Street', ShippingCity = 'Cleveland', ShippingPostalCode = '44114', ShippingCountry = 'United States', AccountExternalNumber__c = '123');
		return acc;
	}

	
	static testMethod void testBypassTrigger() {
		TriggerExecutionHandler.bypassTrigger(null);
		TriggerExecutionHandler.clearBypass(null);
		TriggerExecutionHandler.clearAllBypasses();
	}
}