(:~
:    Copyright  Adam Retter 2008 <adam.retter@googlemail.com>
:    
:    Bungeni Configuration settings
:    
:    @author Adam Retter <adam.retter@googlemail.com>
:    @version 1.0.1
:)

module namespace error = "http://exist.bungeni.org/query/error";

declare function error:response($message as xs:string, $uri as xs:string?) as element()
{
    <error:error>
        <error:message>{$message}</error:message>
        <error:params>
            <error:uri>{$uri}</error:uri>
        </error:params>
    </error:error>
};