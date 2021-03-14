global class MetaMaidHttpCalloutMock implements HttpCalloutMock {
    //source: https://github.com/regarcher/MetadataMaid
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"example":"test"}');
        res.setStatusCode(204);
        return res;
    }
}