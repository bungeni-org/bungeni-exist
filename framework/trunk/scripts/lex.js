/*** This is only for javascript stuff that cannot be loaded XQuery **/

function getLexQueryString(queryArr) {
    var retQuery = '';
    var i = 0;
    for (key in queryArr) {
        if (i > 0 ) {
            retQuery = retQuery + '&'  + key + "=" + queryArr[key] ;
        } else {
            retQuery = key + "=" + queryArr[key] ;
        }
        i  = i + 1;
    }
    return retQuery;

}

 
 function adsSearchIn(){
    var srchIn = new Array();
    if (Dom.get("ads-title").checked) {
       srchIn.push("Title");
    }
    if (Dom.get("ads-desc").checked) {
        srchIn.push("Description");
    }
    if (srchIn.length == 0 ) {
        srchIn.push("FullText");
    }
    
    return srchIn;
  }
 
 
 /***
 Used in advanced search tab
 ****/
  function adsSearchBuild() {
        var srchForText = YAHOO.util.Dom.get("ads-searchfor").value ;
        srchForText = srchForText.trim();
        var srchTitle = false;
        var srchDesc = false;
        var srchBody = false;
        var srchString = '';
        //init all input booleans 
        if (Dom.get("ads-title").checked)  {
           srchTitle = true;
         }
        if (Dom.get("ads-desc").checked) {
           srchDesc = true;    
         }
        if (srchTitle == false && srchDesc == false ) {
            srchBody = true;
            //search in body 
        } 
        //init all predicates 
        var predTitle = "@id='ActTitle'"
        var predDesc = "@id='ActLongTitle'"
        var fldTitle = '//docTitle'
        
        if (srchTitle == true && srchDesc == false) {
              srchString = fldTitle + '[' + predTitle + ']';
        }
        if (srchTitle == false && srchDesc == true ) {
              srchString = fldTitle + '[' + predDesc + ']' ;
        }
        if (srchTitle == true && srchDesc == true  ) {
              srchString = fldTitle + '[' + predTitle + ' or ' + predDesc + ']' ;
        }
        if (srchBody == true ) {
              srchString = '//akomaNtoso' ;
        }
        
        //build ft Query
        var ftQuery = "[ft:query(.,'" + escapeQuery(srchForText) + "')]";
        var params = srchString + ftQuery;
        return params ;        
    }

