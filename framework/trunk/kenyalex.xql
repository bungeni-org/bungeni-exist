xquery version "1.0";

import module namespace json="http://www.json.org";

declare option exist:serialize "method=xhtml media-type=text/html";

let $xml1 := <json>{collection("/db/kenyalex")/akomaNtoso//docTitle[@id='ActTitle']}</json>

return
    <html xmlns="http://www.w3.org/1999/xhtml">
      <head>
        <title>XML 2 JSON Test</title>
          <!-- Dependencies -->
        <!-- Source File -->
        <script type="text/javascript" src="json-test.js"></script>
        <style type="text/css">.view-source {{ margin: 1em 0 1em 0; }}</style>
      </head>
      <body>
        <h1>Running XML2JSON Tests</h1>
    
        <script type="text/javascript">
            var data1 = {json:xml-to-json($xml1)};
        </script>
        <div class="view-source"><a href="json-test.xql/source">Show Source</a></div>
      </body>
    </html>