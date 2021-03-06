jasmine.getFixtures().fixturesPath = "base/build/front-messages-ui/spec/fixtures"
jasmine.getJSONFixtures().fixturesPath = "base/build/front-messages-ui/spec/fixtures"

console.log 'Test started ->'

describe "Messages", ->

  beforeEach ->
    loadFixtures "base.html"

  it "should have jQuery and Underscore", ->
    expect($).toBeDefined()
    expect(_).toBeDefined()

  it "should create Messages obj", ->
    # Arrange
    # Act
    messages = new window.vtex.Messages.getInstance()

    # Assert
    expect(messages).toBeDefined()

  describe "-", ->
    messages = undefined

    beforeEach ->
      messages = new window.vtex.Messages.getInstance()
      $(window).trigger("clearMessages.vtex", [true])

    it "should add a Message object to messagesArray", ->
      # Arrange
      message =
        content:
          title: "Mensagem de teste"
          detail: "Mensagem de teste do tipo success"
        type: "success"

      # Act
      $(window).trigger("addMessage.vtex", [message, true])

      # Assert
      expect(messages.messagesArray.length).toBe(1)

    it "should remove all Messages", ->
      # Arrange
      # Act
      $(window).trigger("removeAllMessages.vtex", true)

      # Assert
      expect(messages.messagesArray.length).toBe(0)

    it "should show a Message", ->
      # Arrange
      message =
        content:
          title: "Mensagem de teste"
          detail: "Mensagem de teste do tipo success"
        type: "success"

      # Act
      $(window).trigger("addMessage.vtex", message)

      # Assert
      expect($(".vtex-front-messages-template", ".vtex-front-messages-placeholder")).toExist()
      expect($(".vtex-front-messages-template", ".vtex-front-messages-placeholder")).toBeVisible()

    it "should place many Messages in one placeholder", ->
      # Arrange
      message =
        content:
          title: "Sucesso - Mensagem de teste"
          detail: "Mensagem de teste do tipo success"
        type: "success"

      message2 =
        content:
          title: "Erro - Mensagem de teste!"
          detail: "Mensagem de teste do tipo error"
        type: "eroor"

      # Act
      $(window).trigger("addMessage.vtex", [message, true])
      $(window).trigger("addMessage.vtex", [message2, true])

      # Assert
      expect($(">", ".vtex-front-messages-placeholder").length).toBe(2)

    it "should show as modal when message type is fatal", ->
      # Arrange
      message =
        content:
          title: "Sucesso - Mensagem de teste no modal"
          detail: "Mensagem de teste do tipo success"
        type: "fatal"
        usingModal: false

      # Act
      $(window).trigger("addMessage.vtex", message)

      # Assert
      expect($(".vtex-front-messages-modal-template", "body")).toExist()

    it "should show message when adding with the visible true", ->
      # Arrange
      # Arrange
      message =
        content:
          title: ''
          detail: 'foo'
        visible: true

      # Act
      $(window).trigger("addMessage.vtex", [message, true]);

      # Assert
      expect($('.vtex-front-messages-template', '.vtex-front-messages-placeholder')).toBeVisible()

    it 'should hide the title if it is and empty string', ->
      # Arrange
      message =
        content:
          title: ''
          detail: 'foo'

      # Act
      $(window).trigger("addMessage.vtex", message);

      # Assert
      # expect($('.vtex-front-messages-title','.vtex-front-messages-template')).not.toBeVisible()
      expect($('.vtex-front-messages-detail', '.vtex-front-messages-template')).toBeVisible()

    it 'should show the message contents', ->
      # Arrange
      message =
        content:
          title: 'foo'
          detail: 'bar'

      # Act
      $(window).trigger("addMessage.vtex", [message, true]);

      # Assert
      expect($('.vtex-front-messages-title', '.vtex-front-messages-template')).toBeVisible()
      expect($('.vtex-front-messages-detail', '.vtex-front-messages-template')).toBeVisible()
      expect($('.vtex-front-messages-title', '.vtex-front-messages-template').html()).toMatch('foo')
      expect($('.vtex-front-messages-detail', '.vtex-front-messages-template').html()).toMatch('bar')

  describe "AJAX", ->

    ajaxResponses = {}
    messages = undefined

    beforeEach ->
#      loadJSONFixtures("messages-api.json")
#      responseJSON = fixtures["messages-api.json"]
      messages = new window.vtex.Messages.getInstance({ajaxError: true})
      $(window).trigger("clearMessages.vtex", [true])
      jasmine.Ajax.useMock()
      ajaxResponses = {
        "success": {
          "status": 200,
          "responseText": '{
            "messages": [
              {
                "code": "123",
                "text": "oi",
                "status": "fatal"
              }
            ]
          }'
        },
        "fatalError": {
          "status": 500,
          "responseHeaders": {
            "x-vtex-operation-id": "123",
            "x-vtex-error-message": "Rates and Benefits error 456"
          },
          "responseText": "An unexpected error."
        },
        "notFound": {
          "status": 404,
          "responseText": '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"><html xmlns="http://www.w3.org/1999/xhtml"><head><meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1"/><title>404 - File or directory not found.</title><style type="text/css"><!-- body{margin:0;font-size:.7em;font-family:Verdana, Arial, Helvetica, sans-serif;background:#EEEEEE;}fieldset{padding:0 15px 10px 15px;} h1{font-size:2.4em;margin:0;color:#FFF;}h2{font-size:1.7em;margin:0;color:#CC0000;} h3{font-size:1.2em;margin:10px 0 0 0;color:#000000;} #header{width:96%;margin:0 0 0 0;padding:6px 2% 6px 2%;font-family:"trebuchet MS", Verdana, sans-serif;color:#FFF;background-color:#555555;}#content{margin:0 0 0 2%;position:relative;}.content-container{background:#FFF;width:96%;margin-top:8px;padding:10px;position:relative;}--></style></head><body><div id="header"><h1>Server Error</h1></div><div id="content"> <div class="content-container"><fieldset>  <h2>404 - File or directory not found.</h2>  <h3>The resource you are looking for might have been removed, had its name changed, or is temporarily unavailable.</h3> </fieldset></div></div></body></html>'
        },
        "webApiError": {
          "status": 500,
          "responseHeaders": {
            "x-vtex-operation-id": "123",
            "x-vtex-error-message": "Rates and Benefits error 456"
            "Content-Type": "application/json; charset=UTF-8"
          },
          "responseText": {"error":{"code":"1","message":"{\"responseHeader\":{\"status\":500,\"QTime\":4,\"params\":{\"fl\":\"*\",\"wt\":\"json\",\"fq\":[\"{!frange l=0 u=222***22222 cache=false cost=100}zipCodeStart\",\"{!frange l=222***22222 u=99999999 cache=false cost=150}zipCodeEnd\",\"(accountId:\\\"c0111a50-ceb2-44e5-9c95-422870127a4f\\\" AND dockId:\\\"1_1_1\\\" AND country:BRA)\"],\"rows\":\"1000\"}},\"error\":{\"msg\":\"For input string: \\\"222***22222\\\"\",\"trace\":\"java.lang.NumberFormatException: For input string: \\\"222***22222\\\"\\n\\tat java.lang.NumberFormatException.forInputString(NumberFormatException.java:65)\\n\\tat java.lang.Integer.parseInt(Integer.java:492)\\n\\tat java.lang.Integer.parseInt(Integer.java:527)\\n\\tat org.apache.solr.util.NumberUtils.int2sortableStr(NumberUtils.java:51)\\n\\tat org.apache.solr.schema.SortableIntFieldSource$1.toTerm(SortableIntField.java:135)\\n\\tat org.apache.lucene.queries.function.docvalues.DocTermsIndexDocValues.getRangeScorer(DocTermsIndexDocValues.java:100)\\n\\tat org.apache.solr.search.FunctionRangeQuery$FunctionRangeCollector.setNextReader(FunctionRangeQuery.java:66)\\n\\tat org.apache.lucene.search.IndexSearcher.search(IndexSearcher.java:603)\\n\\tat org.apache.lucene.search.IndexSearcher.search(IndexSearcher.java:297)\\n\\tat org.apache.solr.search.SolrIndexSearcher.getDocListNC(SolrIndexSearcher.java:1491)\\n\\tat org.apache.solr.search.SolrIndexSearcher.getDocListC(SolrIndexSearcher.java:1366)\\n\\tat org.apache.solr.search.SolrIndexSearcher.search(SolrIndexSearcher.java:457)\\n\\tat org.apache.solr.handler.component.QueryComponent.process(QueryComponent.java:410)\\n\\tat org.apache.solr.handler.component.SearchHandler.handleRequestBody(SearchHandler.java:208)\\n\\tat org.apache.solr.handler.RequestHandlerBase.handleRequest(RequestHandlerBase.java:135)\\n\\tat org.apache.solr.core.SolrCore.execute(SolrCore.java:1816)\\n\\tat org.apache.solr.servlet.SolrDispatchFilter.execute(SolrDispatchFilter.java:656)\\n\\tat org.apache.solr.servlet.SolrDispatchFilter.doFilter(SolrDispatchFilter.java:359)\\n\\tat org.apache.solr.servlet.SolrDispatchFilter.doFilter(SolrDispatchFilter.java:155)\\n\\tat org.eclipse.jetty.servlet.ServletHandler$CachedChain.doFilter(ServletHandler.java:1307)\\n\\tat org.eclipse.jetty.servlet.ServletHandler.doHandle(ServletHandler.java:453)\\n\\tat org.eclipse.jetty.server.handler.ScopedHandler.handle(ScopedHandler.java:137)\\n\\tat org.eclipse.jetty.security.SecurityHandler.handle(SecurityHandler.java:560)\\n\\tat org.eclipse.jetty.server.session.SessionHandler.doHandle(SessionHandler.java:231)\\n\\tat org.eclipse.jetty.server.handler.ContextHandler.doHandle(ContextHandler.java:1072)\\n\\tat org.eclipse.jetty.servlet.ServletHandler.doScope(ServletHandler.java:382)\\n\\tat org.eclipse.jetty.server.session.SessionHandler.doScope(SessionHandler.java:193)\\n\\tat org.eclipse.jetty.server.handler.ContextHandler.doScope(ContextHandler.java:1006)\\n\\tat org.eclipse.jetty.server.handler.ScopedHandler.handle(ScopedHandler.java:135)\\n\\tat org.eclipse.jetty.server.handler.ContextHandlerCollection.handle(ContextHandlerCollection.java:255)\\n\\tat org.eclipse.jetty.server.handler.HandlerCollection.handle(HandlerCollection.java:154)\\n\\tat org.eclipse.jetty.server.handler.HandlerWrapper.handle(HandlerWrapper.java:116)\\n\\tat org.eclipse.jetty.server.Server.handle(Server.java:365)\\n\\tat org.eclipse.jetty.server.AbstractHttpConnection.handleRequest(AbstractHttpConnection.java:485)\\n\\tat org.eclipse.jetty.server.BlockingHttpConnection.handleRequest(BlockingHttpConnection.java:53)\\n\\tat org.eclipse.jetty.server.AbstractHttpConnection.headerComplete(AbstractHttpConnection.java:926)\\n\\tat org.eclipse.jetty.server.AbstractHttpConnection$RequestHandler.headerComplete(AbstractHttpConnection.java:988)\\n\\tat org.eclipse.jetty.http.HttpParser.parseNext(HttpParser.java:635)\\n\\tat org.eclipse.jetty.http.HttpParser.parseAvailable(HttpParser.java:235)\\n\\tat org.eclipse.jetty.server.BlockingHttpConnection.handle(BlockingHttpConnection.java:72)\\n\\tat org.eclipse.jetty.server.bio.SocketConnector$ConnectorEndPoint.run(SocketConnector.java:264)\\n\\tat org.eclipse.jetty.util.thread.QueuedThreadPool.runJob(QueuedThreadPool.java:608)\\n\\tat org.eclipse.jetty.util.thread.QueuedThreadPool$3.run(QueuedThreadPool.java:543)\\n\\tat java.lang.Thread.run(Thread.java:722)\\n\",\"code\":500}}\n","detail":"http://logger-graylog2.vtex.com.br/messages?filters%5Badditional%5D%5Bkeys%5D%5B%5D=LogId&filters%5Badditional%5D%5Bvalues%5D%5B%5D=f64b0698-739b-488f-bc25-4f07f5334361","exception":{"ClassName":"Vtex.Practices.ServiceModel.Client.Exceptions.InternalServerErrorException","Message":"{\"responseHeader\":{\"status\":500,\"QTime\":4,\"params\":{\"fl\":\"*\",\"wt\":\"json\",\"fq\":[\"{!frange l=0 u=222***22222 cache=false cost=100}zipCodeStart\",\"{!frange l=222***22222 u=99999999 cache=false cost=150}zipCodeEnd\",\"(accountId:\\\"c0111a50-ceb2-44e5-9c95-422870127a4f\\\" AND dockId:\\\"1_1_1\\\" AND country:BRA)\"],\"rows\":\"1000\"}},\"error\":{\"msg\":\"For input string: \\\"222***22222\\\"\",\"trace\":\"java.lang.NumberFormatException: For input string: \\\"222***22222\\\"\\n\\tat java.lang.NumberFormatException.forInputString(NumberFormatException.java:65)\\n\\tat java.lang.Integer.parseInt(Integer.java:492)\\n\\tat java.lang.Integer.parseInt(Integer.java:527)\\n\\tat org.apache.solr.util.NumberUtils.int2sortableStr(NumberUtils.java:51)\\n\\tat org.apache.solr.schema.SortableIntFieldSource$1.toTerm(SortableIntField.java:135)\\n\\tat org.apache.lucene.queries.function.docvalues.DocTermsIndexDocValues.getRangeScorer(DocTermsIndexDocValues.java:100)\\n\\tat org.apache.solr.search.FunctionRangeQuery$FunctionRangeCollector.setNextReader(FunctionRangeQuery.java:66)\\n\\tat org.apache.lucene.search.IndexSearcher.search(IndexSearcher.java:603)\\n\\tat org.apache.lucene.search.IndexSearcher.search(IndexSearcher.java:297)\\n\\tat org.apache.solr.search.SolrIndexSearcher.getDocListNC(SolrIndexSearcher.java:1491)\\n\\tat org.apache.solr.search.SolrIndexSearcher.getDocListC(SolrIndexSearcher.java:1366)\\n\\tat org.apache.solr.search.SolrIndexSearcher.search(SolrIndexSearcher.java:457)\\n\\tat org.apache.solr.handler.component.QueryComponent.process(QueryComponent.java:410)\\n\\tat org.apache.solr.handler.component.SearchHandler.handleRequestBody(SearchHandler.java:208)\\n\\tat org.apache.solr.handler.RequestHandlerBase.handleRequest(RequestHandlerBase.java:135)\\n\\tat org.apache.solr.core.SolrCore.execute(SolrCore.java:1816)\\n\\tat org.apache.solr.servlet.SolrDispatchFilter.execute(SolrDispatchFilter.java:656)\\n\\tat org.apache.solr.servlet.SolrDispatchFilter.doFilter(SolrDispatchFilter.java:359)\\n\\tat org.apache.solr.servlet.SolrDispatchFilter.doFilter(SolrDispatchFilter.java:155)\\n\\tat org.eclipse.jetty.servlet.ServletHandler$CachedChain.doFilter(ServletHandler.java:1307)\\n\\tat org.eclipse.jetty.servlet.ServletHandler.doHandle(ServletHandler.java:453)\\n\\tat org.eclipse.jetty.server.handler.ScopedHandler.handle(ScopedHandler.java:137)\\n\\tat org.eclipse.jetty.security.SecurityHandler.handle(SecurityHandler.java:560)\\n\\tat org.eclipse.jetty.server.session.SessionHandler.doHandle(SessionHandler.java:231)\\n\\tat org.eclipse.jetty.server.handler.ContextHandler.doHandle(ContextHandler.java:1072)\\n\\tat org.eclipse.jetty.servlet.ServletHandler.doScope(ServletHandler.java:382)\\n\\tat org.eclipse.jetty.server.session.SessionHandler.doScope(SessionHandler.java:193)\\n\\tat org.eclipse.jetty.server.handler.ContextHandler.doScope(ContextHandler.java:1006)\\n\\tat org.eclipse.jetty.server.handler.ScopedHandler.handle(ScopedHandler.java:135)\\n\\tat org.eclipse.jetty.server.handler.ContextHandlerCollection.handle(ContextHandlerCollection.java:255)\\n\\tat org.eclipse.jetty.server.handler.HandlerCollection.handle(HandlerCollection.java:154)\\n\\tat org.eclipse.jetty.server.handler.HandlerWrapper.handle(HandlerWrapper.java:116)\\n\\tat org.eclipse.jetty.server.Server.handle(Server.java:365)\\n\\tat org.eclipse.jetty.server.AbstractHttpConnection.handleRequest(AbstractHttpConnection.java:485)\\n\\tat org.eclipse.jetty.server.BlockingHttpConnection.handleRequest(BlockingHttpConnection.java:53)\\n\\tat org.eclipse.jetty.server.AbstractHttpConnection.headerComplete(AbstractHttpConnection.java:926)\\n\\tat org.eclipse.jetty.server.AbstractHttpConnection$RequestHandler.headerComplete(AbstractHttpConnection.java:988)\\n\\tat org.eclipse.jetty.http.HttpParser.parseNext(HttpParser.java:635)\\n\\tat org.eclipse.jetty.http.HttpParser.parseAvailable(HttpParser.java:235)\\n\\tat org.eclipse.jetty.server.BlockingHttpConnection.handle(BlockingHttpConnection.java:72)\\n\\tat org.eclipse.jetty.server.bio.SocketConnector$ConnectorEndPoint.run(SocketConnector.java:264)\\n\\tat org.eclipse.jetty.util.thread.QueuedThreadPool.runJob(QueuedThreadPool.java:608)\\n\\tat org.eclipse.jetty.util.thread.QueuedThreadPool$3.run(QueuedThreadPool.java:543)\\n\\tat java.lang.Thread.run(Thread.java:722)\\n\",\"code\":500}}\n","Data":null,"InnerException":{"ClassName":"System.Exception","Message":"{\"responseHeader\":{\"status\":500,\"QTime\":4,\"params\":{\"fl\":\"*\",\"wt\":\"json\",\"fq\":[\"{!frange l=0 u=222***22222 cache=false cost=100}zipCodeStart\",\"{!frange l=222***22222 u=99999999 cache=false cost=150}zipCodeEnd\",\"(accountId:\\\"c0111a50-ceb2-44e5-9c95-422870127a4f\\\" AND dockId:\\\"1_1_1\\\" AND country:BRA)\"],\"rows\":\"1000\"}},\"error\":{\"msg\":\"For input string: \\\"222***22222\\\"\",\"trace\":\"java.lang.NumberFormatException: For input string: \\\"222***22222\\\"\\n\\tat java.lang.NumberFormatException.forInputString(NumberFormatException.java:65)\\n\\tat java.lang.Integer.parseInt(Integer.java:492)\\n\\tat java.lang.Integer.parseInt(Integer.java:527)\\n\\tat org.apache.solr.util.NumberUtils.int2sortableStr(NumberUtils.java:51)\\n\\tat org.apache.solr.schema.SortableIntFieldSource$1.toTerm(SortableIntField.java:135)\\n\\tat org.apache.lucene.queries.function.docvalues.DocTermsIndexDocValues.getRangeScorer(DocTermsIndexDocValues.java:100)\\n\\tat org.apache.solr.search.FunctionRangeQuery$FunctionRangeCollector.setNextReader(FunctionRangeQuery.java:66)\\n\\tat org.apache.lucene.search.IndexSearcher.search(IndexSearcher.java:603)\\n\\tat org.apache.lucene.search.IndexSearcher.search(IndexSearcher.java:297)\\n\\tat org.apache.solr.search.SolrIndexSearcher.getDocListNC(SolrIndexSearcher.java:1491)\\n\\tat org.apache.solr.search.SolrIndexSearcher.getDocListC(SolrIndexSearcher.java:1366)\\n\\tat org.apache.solr.search.SolrIndexSearcher.search(SolrIndexSearcher.java:457)\\n\\tat org.apache.solr.handler.component.QueryComponent.process(QueryComponent.java:410)\\n\\tat org.apache.solr.handler.component.SearchHandler.handleRequestBody(SearchHandler.java:208)\\n\\tat org.apache.solr.handler.RequestHandlerBase.handleRequest(RequestHandlerBase.java:135)\\n\\tat org.apache.solr.core.SolrCore.execute(SolrCore.java:1816)\\n\\tat org.apache.solr.servlet.SolrDispatchFilter.execute(SolrDispatchFilter.java:656)\\n\\tat org.apache.solr.servlet.SolrDispatchFilter.doFilter(SolrDispatchFilter.java:359)\\n\\tat org.apache.solr.servlet.SolrDispatchFilter.doFilter(SolrDispatchFilter.java:155)\\n\\tat org.eclipse.jetty.servlet.ServletHandler$CachedChain.doFilter(ServletHandler.java:1307)\\n\\tat org.eclipse.jetty.servlet.ServletHandler.doHandle(ServletHandler.java:453)\\n\\tat org.eclipse.jetty.server.handler.ScopedHandler.handle(ScopedHandler.java:137)\\n\\tat org.eclipse.jetty.security.SecurityHandler.handle(SecurityHandler.java:560)\\n\\tat org.eclipse.jetty.server.session.SessionHandler.doHandle(SessionHandler.java:231)\\n\\tat org.eclipse.jetty.server.handler.ContextHandler.doHandle(ContextHandler.java:1072)\\n\\tat org.eclipse.jetty.servlet.ServletHandler.doScope(ServletHandler.java:382)\\n\\tat org.eclipse.jetty.server.session.SessionHandler.doScope(SessionHandler.java:193)\\n\\tat org.eclipse.jetty.server.handler.ContextHandler.doScope(ContextHandler.java:1006)\\n\\tat org.eclipse.jetty.server.handler.ScopedHandler.handle(ScopedHandler.java:135)\\n\\tat org.eclipse.jetty.server.handler.ContextHandlerCollection.handle(ContextHandlerCollection.java:255)\\n\\tat org.eclipse.jetty.server.handler.HandlerCollection.handle(HandlerCollection.java:154)\\n\\tat org.eclipse.jetty.server.handler.HandlerWrapper.handle(HandlerWrapper.java:116)\\n\\tat org.eclipse.jetty.server.Server.handle(Server.java:365)\\n\\tat org.eclipse.jetty.server.AbstractHttpConnection.handleRequest(AbstractHttpConnection.java:485)\\n\\tat org.eclipse.jetty.server.BlockingHttpConnection.handleRequest(BlockingHttpConnection.java:53)\\n\\tat org.eclipse.jetty.server.AbstractHttpConnection.headerComplete(AbstractHttpConnection.java:926)\\n\\tat org.eclipse.jetty.server.AbstractHttpConnection$RequestHandler.headerComplete(AbstractHttpConnection.java:988)\\n\\tat org.eclipse.jetty.http.HttpParser.parseNext(HttpParser.java:635)\\n\\tat org.eclipse.jetty.http.HttpParser.parseAvailable(HttpParser.java:235)\\n\\tat org.eclipse.jetty.server.BlockingHttpConnection.handle(BlockingHttpConnection.java:72)\\n\\tat org.eclipse.jetty.server.bio.SocketConnector$ConnectorEndPoint.run(SocketConnector.java:264)\\n\\tat org.eclipse.jetty.util.thread.QueuedThreadPool.runJob(QueuedThreadPool.java:608)\\n\\tat org.eclipse.jetty.util.thread.QueuedThreadPool$3.run(QueuedThreadPool.java:543)\\n\\tat java.lang.Thread.run(Thread.java:722)\\n\",\"code\":500}}\n","Data":null,"InnerException":null,"HelpURL":null,"StackTraceString":"   at Vtex.Commerce.Logistics.Common.Solr.Solr.<DoGetAsync>d__7.MoveNext() in d:\\BuildAgent3\\work\\8a96ee629e43baab\\src\\Vtex.Commerce.Logistics.Common\\Solr\\Solr.cs:line 202\r\n--- End of stack trace from previous location where exception was thrown ---\r\n   at System.Runtime.CompilerServices.TaskAwaiter.ThrowForNonSuccess(Task task)\r\n   at System.Runtime.CompilerServices.TaskAwaiter.HandleNonSuccessAndDebuggerNotification(Task task)\r\n   at Vtex.Commerce.Logistics.Persistence.Configuration.S3.FreightTablePersistenceConfigurationS3.<GetFreightValueDenormalized_NoCacheAsync>d__3e.MoveNext() in d:\\BuildAgent3\\work\\8a96ee629e43baab\\src\\Vtex.Commerce.Logistics.Persistence.Configuration\\S3\\FreightTablePersistenceS3.cs:line 240\r\n--- End of stack trace from previous location where exception was thrown ---\r\n   at System.Runtime.CompilerServices.TaskAwaiter.ThrowForNonSuccess(Task task)\r\n   at System.Runtime.CompilerServices.TaskAwaiter.HandleNonSuccessAndDebuggerNotification(Task task)\r\n   at Vtex.Commerce.Logistics.Persistence.Configuration.S3.FreightTablePersistenceConfigurationS3.<>c__DisplayClass39.<<GetFreightValueDenormalizedAsync>b__38>d__3b.MoveNext() in d:\\BuildAgent3\\work\\8a96ee629e43baab\\src\\Vtex.Commerce.Logistics.Persistence.Configuration\\S3\\FreightTablePersistenceS3.cs:line 0\r\n--- End of stack trace from previous location where exception was thrown ---\r\n   at System.Runtime.CompilerServices.TaskAwaiter.ThrowForNonSuccess(Task task)\r\n   at System.Runtime.CompilerServices.TaskAwaiter.HandleNonSuccessAndDebuggerNotification(Task task)\r\n   at Vtex.Commerce.Logistics.Persistence.Configuration.S3.FreightTablePersistenceConfigurationS3.<GetMaxDimensionForLocationAndSlaTypeAndDock>d__34.MoveNext() in d:\\BuildAgent3\\work\\8a96ee629e43baab\\src\\Vtex.Commerce.Logistics.Persistence.Configuration\\S3\\FreightTablePersistenceS3.cs:line 215\r\n--- End of stack trace from previous location where exception was thrown ---\r\n   at System.Runtime.CompilerServices.TaskAwaiter.ThrowForNonSuccess(Task task)\r\n   at System.Runtime.CompilerServices.TaskAwaiter.HandleNonSuccessAndDebuggerNotification(Task task)\r\n   at System.Runtime.CompilerServices.TaskAwaiter`1.GetResult()\r\n   at Vtex.Commerce.Logistics.Service.ShippingCalculation.<CalculateShippingAsync>d__9.MoveNext() in d:\\BuildAgent3\\work\\8a96ee629e43baab\\src\\Vtex.Commerce.Logistics.Service\\ShippingCalculation.cs:line 29\r\n--- End of stack trace from previous location where exception was thrown ---\r\n   at System.Runtime.CompilerServices.TaskAwaiter.ThrowForNonSuccess(Task task)\r\n   at System.Runtime.CompilerServices.TaskAwaiter.HandleNonSuccessAndDebuggerNotification(Task task)\r\n   at System.Runtime.CompilerServices.TaskAwaiter`1.GetResult()\r\n   at Vtex.Commerce.Logistics.Service.SlaInternal.<GetDeliveryByDockConsideringAllItemsShippingFromAllDocksAsync>d__35.MoveNext() in d:\\BuildAgent3\\work\\8a96ee629e43baab\\src\\Vtex.Commerce.Logistics.Service\\SlaInternal.cs:line 99\r\n--- End of stack trace from previous location where exception was thrown ---\r\n   at System.Runtime.CompilerServices.TaskAwaiter.ThrowForNonSuccess(Task task)\r\n   at System.Runtime.CompilerServices.TaskAwaiter.HandleNonSuccessAndDebuggerNotification(Task task)\r\n   at System.Runtime.CompilerServices.TaskAwaiter`1.GetResult()\r\n   at Vtex.Commerce.Logistics.Service.SlaInternal.<GetDeliveryPackagesBySlaTypeAsync>d__14.MoveNext() in d:\\BuildAgent3\\work\\8a96ee629e43baab\\src\\Vtex.Commerce.Logistics.Service\\SlaInternal.cs:line 62\r\n--- End of stack trace from previous location where exception was thrown ---\r\n   at System.Runtime.CompilerServices.TaskAwaiter.ThrowForNonSuccess(Task task)\r\n   at System.Runtime.CompilerServices.TaskAwaiter.HandleNonSuccessAndDebuggerNotification(Task task)\r\n   at System.Runtime.CompilerServices.TaskAwaiter`1.GetResult()\r\n   at Vtex.Commerce.Logistics.Service.DeliveryOption.<PopulateDeliveryPackagesPerSlaTypeAsync>d__c.MoveNext() in d:\\BuildAgent3\\work\\8a96ee629e43baab\\src\\Vtex.Commerce.Logistics.Service\\DeliveryOption.cs:line 102\r\n--- End of stack trace from previous location where exception was thrown ---\r\n   at System.Runtime.CompilerServices.TaskAwaiter.ThrowForNonSuccess(Task task)\r\n   at System.Runtime.CompilerServices.TaskAwaiter.HandleNonSuccessAndDebuggerNotification(Task task)\r\n   at Vtex.Commerce.Logistics.Service.DeliveryOption.<CalculateDeliveryPackagesPerSlaTypeAsync>d__1.MoveNext() in d:\\BuildAgent3\\work\\8a96ee629e43baab\\src\\Vtex.Commerce.Logistics.Service\\DeliveryOption.cs:line 90\r\n--- End of stack trace from previous location where exception was thrown ---\r\n   at System.Runtime.CompilerServices.TaskAwaiter.ThrowForNonSuccess(Task task)\r\n   at System.Runtime.CompilerServices.TaskAwaiter.HandleNonSuccessAndDebuggerNotification(Task task)\r\n   at Vtex.Commerce.Logistics.Service.DeliveryOption.<GetSlaPerExplodedItemInternalAsync>d__71.MoveNext() in d:\\BuildAgent3\\work\\8a96ee629e43baab\\src\\Vtex.Commerce.Logistics.Service\\DeliveryOption.cs:line 182\r\n--- End of stack trace from previous location where exception was thrown ---\r\n   at System.Runtime.CompilerServices.TaskAwaiter.ThrowForNonSuccess(Task task)\r\n   at System.Runtime.CompilerServices.TaskAwaiter.HandleNonSuccessAndDebuggerNotification(Task task)\r\n   at Vtex.Commerce.Logistics.Service.DeliveryOption.<GetSlaPerExplodedItemAsync>d__12.MoveNext() in d:\\BuildAgent3\\work\\8a96ee629e43baab\\src\\Vtex.Commerce.Logistics.Service\\DeliveryOption.cs:line 111\r\n--- End of stack trace from previous location where exception was thrown ---\r\n   at System.Runtime.CompilerServices.TaskAwaiter.ThrowForNonSuccess(Task task)\r\n   at System.Runtime.CompilerServices.TaskAwaiter.HandleNonSuccessAndDebuggerNotification(Task task)\r\n   at Vtex.Commerce.Logistics.Service.SlaInternal.<GetDeliverySlasAync>d__3d.MoveNext() in d:\\BuildAgent3\\work\\8a96ee629e43baab\\src\\Vtex.Commerce.Logistics.Service\\SlaInternal.cs:line 138\r\n--- End of stack trace from previous location where exception was thrown ---\r\n   at System.Runtime.CompilerServices.TaskAwaiter.ThrowForNonSuccess(Task task)\r\n   at System.Runtime.CompilerServices.TaskAwaiter.HandleNonSuccessAndDebuggerNotification(Task task)\r\n   at Vtex.Commerce.Logistics.Service.LogisticsInventoryServiceController.<GetDeliverySlasAsync>d__0.MoveNext() in d:\\BuildAgent3\\work\\8a96ee629e43baab\\src\\Vtex.Commerce.Logistics.Service\\LogisticsInventoryServiceController.cs:line 38","RemoteStackTraceString":null,"RemoteStackIndex":0,"ExceptionMethod":null,"HResult":-2146233088,"Source":"Vtex.Commerce.Logistics.Common","WatsonBuckets":null},"HelpURL":null,"StackTraceString":"   at Vtex.Practices.ServiceModel.Client.HttpResponseMessageExtensions.HandleErrors(HttpResponseMessage response)\r\n   at Vtex.Practices.ServiceModel.Client.HttpResponseMessageExtensions.ReadContentAsAsync[TResponse](HttpResponseMessage response)\r\n   at Vtex.Commerce.FulfillmentServices.FulfillmentConnector.<GetInfoAsync>d__0.MoveNext()\r\n--- End of stack trace from previous location where exception was thrown ---\r\n   at System.Runtime.ExceptionServices.ExceptionDispatchInfo.Throw()\r\n   at System.Runtime.CompilerServices.TaskAwaiter.HandleNonSuccessAndDebuggerNotification(Task task)\r\n   at System.Runtime.CompilerServices.TaskAwaiter`1.GetResult()\r\n   at Vtex.Commerce.Checkout.Fulfillment.FulfillmentService.<GetInfoAsync>d__19.MoveNext() in d:\\BuildAgent3\\work\\a4aa4609ea4cc312\\src\\VTEX Checkout\\Private Assemblies\\Vtex.Commerce.Checkout.Fulfillment\\FulfillmentService.cs:line 90\r\n--- End of stack trace from previous location where exception was thrown ---\r\n   at System.Runtime.ExceptionServices.ExceptionDispatchInfo.Throw()\r\n   at System.Runtime.CompilerServices.TaskAwaiter.HandleNonSuccessAndDebuggerNotification(Task task)\r\n   at Vtex.Commerce.Checkout.CheckoutPipeline.<ExecutePipelineAsync>d__14.MoveNext() in d:\\BuildAgent3\\work\\a4aa4609ea4cc312\\src\\VTEX Checkout\\Private Assemblies\\Vtex.Commerce.Checkout\\CheckoutPipeline.cs:line 76\r\n--- End of stack trace from previous location where exception was thrown ---\r\n   at System.Runtime.ExceptionServices.ExceptionDispatchInfo.Throw()\r\n   at System.Runtime.CompilerServices.TaskAwaiter.HandleNonSuccessAndDebuggerNotification(Task task)\r\n   at Vtex.Commerce.Checkout.CheckoutPipeline.<ExecutePipelineAsync>d__0.MoveNext() in d:\\BuildAgent3\\work\\a4aa4609ea4cc312\\src\\VTEX Checkout\\Private Assemblies\\Vtex.Commerce.Checkout\\CheckoutPipeline.cs:line 26\r\n--- End of stack trace from previous location where exception was thrown ---\r\n   at System.Runtime.ExceptionServices.ExceptionDispatchInfo.Throw()\r\n   at System.Runtime.CompilerServices.TaskAwaiter.HandleNonSuccessAndDebuggerNotification(Task task)\r\n   at Vtex.Commerce.Checkout.OrderForm.<SaveAsync>d__cc.MoveNext() in d:\\BuildAgent3\\work\\a4aa4609ea4cc312\\src\\VTEX Checkout\\Private Assemblies\\Vtex.Commerce.Checkout\\OrderForm.cs:line 1213\r\n--- End of stack trace from previous location where exception was thrown ---\r\n   at System.Runtime.ExceptionServices.ExceptionDispatchInfo.Throw()\r\n   at System.Runtime.CompilerServices.TaskAwaiter.HandleNonSuccessAndDebuggerNotification(Task task)\r\n   at Vtex.Commerce.Checkout.OrderForm.<UpdateAttachmentAsync>d__87.MoveNext() in d:\\BuildAgent3\\work\\a4aa4609ea4cc312\\src\\VTEX Checkout\\Private Assemblies\\Vtex.Commerce.Checkout\\OrderForm.cs:line 863\r\n--- End of stack trace from previous location where exception was thrown ---\r\n   at System.Runtime.ExceptionServices.ExceptionDispatchInfo.Throw()\r\n   at System.Runtime.CompilerServices.TaskAwaiter.HandleNonSuccessAndDebuggerNotification(Task task)\r\n   at Vtex.Commerce.Checkout.CheckoutApiController.<SendAttachmentAsync>d__63.MoveNext() in d:\\BuildAgent3\\work\\a4aa4609ea4cc312\\src\\VTEX Checkout\\Private Assemblies\\Vtex.Commerce.Checkout.WebApi\\CheckoutApiController.cs:line 492\r\n--- End of stack trace from previous location where exception was thrown ---\r\n   at System.Runtime.ExceptionServices.ExceptionDispatchInfo.Throw()\r\n   at System.Runtime.CompilerServices.TaskAwaiter.HandleNonSuccessAndDebuggerNotification(Task task)\r\n   at Vtex.Commerce.Checkout.CheckoutApiController.<SendAttachment>d__5a.MoveNext() in d:\\BuildAgent3\\work\\a4aa4609ea4cc312\\src\\VTEX Checkout\\Private Assemblies\\Vtex.Commerce.Checkout.WebApi\\CheckoutApiController.cs:line 454","RemoteStackTraceString":null,"RemoteStackIndex":0,"ExceptionMethod":"8\nHandleErrors\nVtex.Practices.ServiceModel.Client, Version=4.10.4.0, Culture=neutral, PublicKeyToken=null\nVtex.Practices.ServiceModel.Client.HttpResponseMessageExtensions\nVoid HandleErrors(System.Net.Http.HttpResponseMessage)","HResult":-2146233088,"Source":"Vtex.Practices.ServiceModel.Client","WatsonBuckets":null}}}
        }
      }

    it "should show modal Message when an AJAX error occurs", ->
      # Arrange
      $.support.transition = false

      # Act
      $.get("http://httpstat.us/500")
      request = mostRecentAjaxRequest()
      request.response(ajaxResponses.fatalError)

      # Assert
      expect($(".vtex-front-messages-template-modal-default", "body")).toExist()

    it "should not show a modal Message when a non-error AJAX occurs", ->
      # Arrange

      # Act
      $.ajax("http://httpstat.us/200")
      request1 = mostRecentAjaxRequest()
      request1.response(ajaxResponses.success)

      # Assert
      expect($(".vtex-front-messages-template-modal-default", "body")).not.toExist()

    it 'should show a modal Message when an AJAX error when API is using VTEX.WebApi', ->
      # Arrange
      $.support.transition = false

      # Act
      $.ajax("http://httpstat.us/500")
      request = mostRecentAjaxRequest()
      request.response(ajaxResponses.webApiError)

      # Assert
      expect(messages.messagesArray.length).toBe(1)
      message = messages.messagesArray[0]
      expect(message.usingModal).toBe(true)
      expect(message.content.detail).toMatch("solr")