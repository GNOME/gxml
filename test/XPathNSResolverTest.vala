/* -*- Mode: vala; indent-tabs-mode: t; c-basic-offset: 8; tab-width: 8 -*- */
using GXml;

class XPathNSResolverTest : GXmlTest {
	public static void add_tests () {
		Test.add_func ("/gxml/xpath/nsresolver/lookup_namespace_uri", () => {
				XPath.NSResolver r = new XPath.NSResolver(
					"xs", "http://www.w3.org/2001/XMLSchema",
					"m", "http://www.w3.org/1998/Math/MathML"
				);

				assert (r["xs"] == "http://www.w3.org/2001/XMLSchema");
				assert (r["m"] == "http://www.w3.org/1998/Math/MathML");
				assert (r[""] == null);
				assert (r["other"] == null);
				assert (r.lookup_namespace_uri("xs") == "http://www.w3.org/2001/XMLSchema");
				assert (r.lookup_namespace_uri("m") == "http://www.w3.org/1998/Math/MathML");
				assert (r.lookup_namespace_uri("") == null);
				assert (r.lookup_namespace_uri("other") == null);
			});
	}
}
