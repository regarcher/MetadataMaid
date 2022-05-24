global class MetaMaidHttpCalloutMock implements HttpCalloutMock {
    //source: https://github.com/regarcher/MetadataMaid
    //This code is part of a package and should not be called from your custom code
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"example":"test"}');
        res.setStatusCode(204);
        return res;
    }
}