package org.exist.xquery.modules.epub;

import java.util.List;
import java.util.Map;
import org.exist.xquery.AbstractInternalModule;
import org.exist.xquery.FunctionDef;

/**
 *
 * @author Sam
 */

public class EpubModule extends AbstractInternalModule {

	public final static String NAMESPACE_URI = "http://exist-db.org/xquery/epub";
	
	public final static String PREFIX = "epub";
    public final static String INCLUSION_DATE = "2012-09-06";
    public final static String RELEASED_IN_VERSION = "eXist-2.0";

	private final static FunctionDef[] functions = {
		new FunctionDef(ScribaEbookMakerFunction.signature, ScribaEbookMakerFunction.class)
	};
	
	public EpubModule(Map<String, List<? extends Object>> parameters) {
		super(functions, parameters);
	}

	public String getNamespaceURI() {
		return NAMESPACE_URI;
	}

	public String getDefaultPrefix() {
		return PREFIX;
	}

	public String getDescription() {
		return "A epub tester";
	}

    public String getReleaseVersion() {
        return RELEASED_IN_VERSION;
    }

}
