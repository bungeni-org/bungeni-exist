(:~
:    Copyright  Adam Retter 2009 <adam.retter@googlemail.com>
:    
:    Bungeni Configuration settings
:    
:    @author Adam Retter <adam.retter@googlemail.com>
:    @version 1.1
:)

module namespace error = "http://exist.bungeni.org/query/error";

declare namespace errors = "http://exist.bungeni.org/errors";

declare namespace request = "http://exist-db.org/xquery/request";

import module namespace config = "http://exist.bungeni.org/query/config" at "config.xqm";



declare function error:response($code as xs:string) as element(error:error)
{
    error:response($code, $config:default_language)
};

declare function error:response($code as xs:string, $language as xs:string) as element(error:error)
{
    let $error-response := error:__create-response($code, $language) return
        if($config:log-to-exist_log)then
        (
            util:log("error", $error-response),
            $error-response
        )
        else
        (
            $error-response
        )
};


(:~
: Attempts to lookup an error message for the provided error code and language. If the message
: is not found for the language, we fall back to the default language. If the message is still not found
: we return a generic unknown error
:)
declare function error:__create-response($code as xs:string, $language as xs:string) as element(error:error)
{
    let $int-error := collection($config:errors_collection)/errors:errors[@language eq $language]/errors:error[@code eq $code],
    $error := if(not(empty($int-error)))then
              (
                  $int-error
              )
              else
              (
                  collection($config:errors_collection)/errors[@language eq $config:default_language]/error[@code eq $code]
              )
    return
        
        <error:error timestamp="{current-dateTime()}">
            {
                if(not(empty($error)))then
                (
                    <error:code>{$code}</error:code>,
                    <error:message language="{$language}">{$error/text()}</error:message>
                )
                else
                (
                    <error:code>UNKN0001</error:code>,
                    <error:message language="eng">Unknown error for error code: {$code}</error:message>
                )
            }
            <error:http-context>
                <error:method>{request:get-method()}</error:method>
                <error:uri>{request:get-uri()}</error:uri>
                <error:parameters>
                    {
                        for $param in request:get-parameter-names() return
                            <error:parameter name="{$param}">
                                {
                                    for $param-value in request:get-parameter($param, ()) return
                                        <error:value>{$param-value}</error:value>
                                }
                            </error:parameter>
                    }
                </error:parameters>
            </error:http-context>
        </error:error>
};