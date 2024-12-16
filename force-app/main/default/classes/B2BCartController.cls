/**
 * Created by kdreyer on 2/16/21.
 */

public with sharing class B2BCartController {
   //This method is used to get collection of items in a cart
    @AuraEnabled
    public static ConnectApi.CartItemCollection getCartItems(
            String communityId,
            String effectiveAccountId,
            String activeCartOrId,
            String pageParam,
            String sortParam
    ) {
        // Lookup the webstore ID associated with the community
        String webstoreId = B2BUtils.resolveCommunityIdToWebstoreId(communityId);
        // Get the ConnectApi.CartItemSortOrder enum value from string.
        // For the list of possible values, see:
        // see https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/connectAPI_enums.htm#cartItemSortOrderEnum
        ConnectApi.CartItemSortOrder resolvedSortParam = B2BUtils.resolveSortParam(
                sortParam
        );

        System.Debug('Effective Account ID: ' + effectiveAccountId);

        //added
        Id accountId = [
                SELECT AccountId
                FROM WebCart
                WHERE Id = :activeCartOrId
                LIMIT 1
        ].AccountId;

        effectiveAccountId = String.valueOf(accountId);

        // For more details, see:
        // https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_ConnectAPI_CommerceCart_static_methods.htm
        return ConnectApi.CommerceCart.getCartItems(
                webstoreId,
                effectiveAccountId,
                'current',
                pageParam,
                resolvedSortParam
        );
    }

    //This method is used to delete cart by passing cartId.
    @AuraEnabled
    public static void deleteCartRecord(Id cartId){
            try {
                if(cartId != null) {
                        WebCart cart = [SELECT Id FROM WebCart WHERE Id = :cartId LIMIT 1];

                        delete cart;
                }
            } catch (Exception e) {
                throw new AuraHandledException(e.getMessage());
            }
    }
}