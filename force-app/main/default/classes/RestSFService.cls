@RestResource(urlMapping='/sampleservices')
	global class RestSFService {   
                
    @HttpPost
    //This method is to check the response of API
    global static void createQuote(){
        String jsonString = RestContext.request.requestBody.toString();
        system.debug('JsonStringREST'+ JsonString);
    	}
}