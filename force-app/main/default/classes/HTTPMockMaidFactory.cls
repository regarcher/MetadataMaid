@isTest
public class HTTPMockMaidFactory implements HttpCalloutMock {
  //source: https://github.com/regarcher/MetadataMaid
  //This code is part of a package and should not be called from your custom code
  protected Integer code;
  protected String status;
  protected String body;
  protected Map<String, String> responseHeaders;
  public HTTPMockMaidFactory(Integer code, String status, String body, Map<String, String> responseHeaders) {
    this.code = code;
    this.status = status;
    this.body = body;
    this.responseHeaders = responseHeaders;
  }
  ///////////////////////////////////////////////////////
  public HTTPResponse respond(HTTPRequest req) {
    HttpResponse res = new HttpResponse();
    for (String key : this.responseHeaders.keySet()) {
      res.setHeader(key, this.responseHeaders.get(key));
    }
    res.setBody(this.body);
    res.setStatusCode(this.code);
    res.setStatus(this.status);
    return res;
  }
}