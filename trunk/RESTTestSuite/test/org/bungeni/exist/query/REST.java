package org.bungeni.exist.query;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import org.apache.commons.httpclient.Credentials;
import org.apache.commons.httpclient.HttpClient;
import org.apache.commons.httpclient.HttpMethod;
import org.apache.commons.httpclient.HttpStatus;
import org.apache.commons.httpclient.UsernamePasswordCredentials;
import org.apache.commons.httpclient.auth.AuthScope;
import org.apache.commons.httpclient.methods.GetMethod;

/**
 * @author Adam Retter <adam.retter@googlemail.com>
 */
public class REST
{
    public final static String SERVER_URI = "http://localhost:8080";
    //private final static String SERVER_URI = "http://localhost:8088";

    public final static String EXIST_REST_URI = SERVER_URI + "/exist/rest";

    public final static String EDIT_URL = EXIST_REST_URI + "/db/bungeni/query/edit.xql";
    public final static String AN_URIHANDLER_URL = EXIST_REST_URI + "/db/bungeni/query/AkomaNtosoURIHandler.xql";
    public final static String PACKAGE_URL = EXIST_REST_URI + "/db/bungeni/query/package.xql";
    public final static String QUERY_URL = EXIST_REST_URI + "/db/bungeni/query/query.xql";

    public final static String DEFAULT_ERROR_MESSAGES_URI = EXIST_REST_URI + "/db/bungeni/errors/eng.xml";

    public final static String ERRORS_NAMESPACE_URI = "http://exist.bungeni.org/errors";
    public final static String ERRORS_NAMESPACE_PREFIX = "errors";

    public final static String ERROR_NAMESPACE_URI = "http://exist.bungeni.org/query/error";
    public final static String ERROR_NAMESPACE_PREFIX = "error";
    

    
    /**
     * Creates a HTTP Client with appropriate authentication credentials
     *
     * @param username Username
     * @param password Password
     *
     * @return HttpClient setup to authenticate with the provided username/password
     */
    public final static HttpClient getAuthenticatingHttpClient(String username, String password)
    {
        HttpClient http = new HttpClient();

        //username and password
        Credentials creds = new UsernamePasswordCredentials(username, password);
        http.getState().setCredentials(AuthScope.ANY, creds);
        http.getParams().setAuthenticationPreemptive(true);

        return http;
    }

    public final static byte[] getResponseBody(HttpMethod method) throws IOException
    {
        InputStream is = method.getResponseBodyAsStream();
        ByteArrayOutputStream os = new ByteArrayOutputStream();

        byte buf[] = new byte[1024];
        int read = -1;
        while((read = is.read(buf)) > -1)
        {
            os.write(buf, 0, read);
        }
        is.close();

        return os.toByteArray();
    }

    public final static void createCollectionFromPath(String newCollectionPath) throws IOException
    {
        HttpClient client = getAuthenticatingHttpClient(Database.DEFAULT_ADMIN_USERNAME, Database.DEFAULT_ADMIN_PASSWORD);

        GetMethod getCollection = null;
        GetMethod createCollection = null;
        String path = new String();

        for(String pathSeg : newCollectionPath.split("/"))
        {
            if(pathSeg.length() != 0)
            {
                path += "/" + pathSeg;
                createCollection = null;
                try
                {
                    getCollection = new GetMethod(EXIST_REST_URI + path);
                    int result = client.executeMethod(getCollection);
                    if(result == HttpStatus.SC_NOT_FOUND)
                    {
                        String parentColPath = path.substring(0, path.lastIndexOf("/"));
                        createCollection = new GetMethod(EXIST_REST_URI + parentColPath + "?_query=xmldb:create-collection('" + parentColPath + "','" + pathSeg + "')");
                        result = client.executeMethod(createCollection);
                        if(result != HttpStatus.SC_OK)
                            throw new IOException(createCollection.getResponseBodyAsString());
                    }
                }
                finally
                {
                    if(getCollection != null)
                        getCollection.releaseConnection();
                    if(createCollection != null)
                        createCollection.releaseConnection();
                }
            }
        }
    }
}
