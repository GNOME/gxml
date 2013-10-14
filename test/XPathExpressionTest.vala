/* -*- Mode: vala; indent-tabs-mode: t; c-basic-offset: 8; tab-width: 8 -*- */
using GXml;

class XPathExpressionTest : GXmlTest {

	public static void add_tests () {

		Test.add_func ("/gxml/xpath/expression/create_valid_w_resolver", () => {
				try {
					XPath.NSResolver r = new XPath.NSResolver(
						"xs", "http://www.w3.org/2001/XMLSchema",
						"m", "http://www.w3.org/1998/Math/MathML"
					);
					XPath.Expression e = new XPath.Expression("//Author", r);

				} catch (XPath.Error e) {
					Test.message("%s", e.message);
					assert_not_reached();
				}
			});

		Test.add_func ("/gxml/xpath/expression/create_invalid_w_resolver", () => {
				try {
					XPath.NSResolver r = new XPath.NSResolver(
						"xs", "http://www.w3.org/2001/XMLSchema",
						"m", "http://www.w3.org/1998/Math/MathML"
					);
					XPath.Expression e = new XPath.Expression("//A\\uthor", r);

					assert_not_reached();

				} catch (XPath.Error e) {
					assert (e is XPath.Error.INVALID_EXPRESSION);
				}
			});

		Test.add_func ("/gxml/xpath/expression/create_valid_wo_resolver", () => {
				try {
					XPath.Expression e = new XPath.Expression("//Author");

				} catch (XPath.Error e) {
					Test.message("%s", e.message);
					assert_not_reached();
				}
			});

		Test.add_func ("/gxml/xpath/expression/create_invalid_wo_resolver", () => {
				try {
					XPath.Expression e = new XPath.Expression("//Aut&hor");
					assert_not_reached();

				} catch (XPath.Error e) {
					assert (e is XPath.Error.INVALID_EXPRESSION);
				}
			});

		Test.add_func ("/gxml/xpath/expression/evaluate_wo_ns", () => {
				try {
					Document doc = get_doc ();
					XPath.Expression e = new XPath.Expression("//Author");
					var result = e.evaluate(doc);

					assert (result.result_type == XPath.ResultType.ORDERED_NODE_SNAPSHOT);
					var ns = result.nodeset_value;

					assert (ns.size == 2);
					assert (ns[0].node_type == NodeType.ELEMENT);
					assert (ns[0].node_name == "Author");
					assert (ns[1].node_type == NodeType.ELEMENT);
					assert (ns[1].node_name == "Author");

				} catch (XPath.Error e) {
					Test.message("%s", e.message);
					assert_not_reached();
				}
			});

		Test.add_func ("/gxml/xpath/expression/evaluate_w_ns_1", () => {
				try {
					Document doc = get_doc_with_ns ();
					XPath.NSResolver r = new XPath.NSResolver(
						"svg", "http://www.w3.org/2000/svg",
						"m", "http://www.w3.org/1998/Math/MathML",
						"r", "http://www.w3.org/1999/02/22-rdf-syntax-ns#"
					);
					XPath.Expression e = new XPath.Expression("//m:*", r);
					var result = e.evaluate(doc);

					assert (result.result_type == XPath.ResultType.ORDERED_NODE_SNAPSHOT);
					var ns = result.nodeset_value;

					assert (ns.size == 23);

				} catch (XPath.Error e) {
					stdout.printf("'%s'\n", e.message);
					Test.message("%s", e.message);
					assert_not_reached();
				}
			});

		Test.add_func ("/gxml/xpath/expression/evaluate_w_ns_2", () => {
				try {
					Document doc = get_doc_with_ns ();
					XPath.NSResolver r = new XPath.NSResolver(
						"svg", "http://www.w3.org/2000/svg",
						"r", "http://www.w3.org/1999/02/22-rdf-syntax-ns#"
					);
					XPath.Expression e = new XPath.Expression("/svg:svg/svg:metadata/r:RDF/r:Description", r);
					var result = e.evaluate(doc);

					assert (result.result_type == XPath.ResultType.ORDERED_NODE_SNAPSHOT);
					var ns = result.nodeset_value;

					assert (ns.size == 2);
					assert (ns[0].node_type == NodeType.ELEMENT);
					assert (ns[0].node_name == "Description");
					assert (ns[0] is Element);
					assert (((Element) ns[0]).get_attribute("id") == "description1");
					assert (ns[1].node_type == NodeType.ELEMENT);
					assert (ns[1].node_name == "Description");
					assert (ns[1] is Element);
					assert (((Element) ns[1]).get_attribute("id") == "description2");

				} catch (XPath.Error e) {
					Test.message("%s", e.message);
					assert_not_reached();
				}
			});

		Test.add_func ("/gxml/xpath/expression/evaluate_w_ns_3", () => {
				try {
					Document doc = get_doc_with_ns ();
					XPath.NSResolver r = new XPath.NSResolver(
						"math", "http://www.w3.org/1998/Math/MathML",
						"i", "proto:item-info"
					);
					XPath.Expression e = new XPath.Expression("//math:msqrt|//i:country", r);
					var result = e.evaluate(doc);

					assert (result.result_type == XPath.ResultType.ORDERED_NODE_SNAPSHOT);
					var ns = result.nodeset_value;

					assert (ns.size == 2);

					foreach (var node in ns) {
						assert (node.node_type == NodeType.ELEMENT);
						if (node.node_name == "msqrt") {
							assert (node is Element);
							assert (((Element) node).get_attribute("id") == "msqrt1");
						}
						else if (node.node_name == "country") {
							assert (node is Element);
							assert (((Element) node).get_attribute("id") == "country1");
						}
						else {
							assert_not_reached();
						}
					}

				} catch (XPath.Error e) {
					Test.message("%s", e.message);
					assert_not_reached();
				}
			});

		Test.add_func ("/gxml/xpath/expression/evaluate_to_bool", () => {
				try {
					Document doc = get_doc_with_ns ();
					XPath.NSResolver r = new XPath.NSResolver(
						"m", "http://www.w3.org/1998/Math/MathML",
						"i", "proto:item-info"
					);
					XPath.Expression e = new XPath.Expression("count(//i:*)=3", r);
					var result = e.evaluate(doc);

					assert (result.result_type == XPath.ResultType.BOOLEAN);
					assert (result.boolean_value == true);

					e = new XPath.Expression("//m:mi[2]/text()!=\"b\"", r);
					result = e.evaluate(doc);

					assert (result.result_type == XPath.ResultType.BOOLEAN);
					assert (result.boolean_value == false);

				} catch (XPath.Error e) {
					Test.message("%s", e.message);
					assert_not_reached();
				}
			});

		Test.add_func ("/gxml/xpath/expression/evaluate_to_number", () => {
				try {
					Document doc = get_doc_with_ns ();
					XPath.NSResolver r = new XPath.NSResolver(
						"rdf", "http://www.w3.org/1999/02/22-rdf-syntax-ns#"
					);
					XPath.Expression e = new XPath.Expression("count(//rdf:Description)", r);
					var result = e.evaluate(doc);

					assert (result.result_type == XPath.ResultType.NUMBER);
					assert (result.number_value == 2.0);

				} catch (XPath.Error e) {
					Test.message("%s", e.message);
					assert_not_reached();
				}
			});

		Test.add_func ("/gxml/xpath/expression/evaluate_to_string", () => {
				try {
					Document doc = get_doc_with_ns ();
					XPath.NSResolver r = new XPath.NSResolver(
						"m", "http://www.w3.org/1998/Math/MathML"
					);
					XPath.Expression e = new XPath.Expression("normalize-space(//m:mo[1]/text())", r);
					var result = e.evaluate(doc);

					assert (result.result_type == XPath.ResultType.STRING);
					assert (result.string_value == "=");

				} catch (XPath.Error e) {
					Test.message("%s", e.message);
					assert_not_reached();
				}
			});

		Test.add_func ("/gxml/xpath/expression/evaluate_w_ns_to_attr", () => {
				try {
					Document doc = get_doc_with_ns ();
					XPath.NSResolver r = new XPath.NSResolver(
						"svg", "http://www.w3.org/2000/svg",
						"m", "http://www.w3.org/1998/Math/MathML",
						"r", "http://www.w3.org/1999/02/22-rdf-syntax-ns#"
					);
					XPath.Expression e = new XPath.Expression("//svg:g/@id", r);
					XPath.Result result = null;
					Node context = null;

					result = e.evaluate(doc);
					assert (result.result_type == XPath.ResultType.ORDERED_NODE_SNAPSHOT);
					assert (result.nodeset_value.size == 3);
					/* For now result.nodeset_value[x] is null because of lack of
					 * implementation in Document.lookup_node for Attr nodes */
					assert (result.nodeset_value[0] != null);
					assert (result.nodeset_value[0] is Attr);
					context = result.nodeset_value[0];

				} catch (XPath.Error e) {
					Test.message("%s", e.message);
					assert_not_reached();
				}
			});

		Test.add_func ("/gxml/xpath/expression/evaluate_w_ns_in_element_context", () => {
				try {
					Document doc = get_doc_with_ns ();
					XPath.NSResolver r = new XPath.NSResolver(
						"svg", "http://www.w3.org/2000/svg",
						"m", "http://www.w3.org/1998/Math/MathML",
						"r", "http://www.w3.org/1999/02/22-rdf-syntax-ns#"
					);
					XPath.Expression e = new XPath.Expression("./svg:g", r);
					XPath.Result result = null;
					Node context = null;

					result = e.evaluate(doc.document_element);
					assert (result.result_type == XPath.ResultType.ORDERED_NODE_SNAPSHOT);
					assert (result.nodeset_value.size == 1);
					assert (result.nodeset_value[0] is Element);
					assert (((Element) result.nodeset_value[0]).get_attribute("id") == "g1");

					context = result.nodeset_value[0];
					result = e.evaluate(context);
					assert (result.result_type == XPath.ResultType.ORDERED_NODE_SNAPSHOT);
					assert (result.nodeset_value.size == 1);
					assert (result.nodeset_value[0] is Element);
					assert (((Element) result.nodeset_value[0]).get_attribute("id") == "g2");

					context = result.nodeset_value[0];
					result = e.evaluate(context);
					assert (result.result_type == XPath.ResultType.ORDERED_NODE_SNAPSHOT);
					assert (result.nodeset_value.size == 1);
					assert (result.nodeset_value[0] is Element);
					assert (((Element) result.nodeset_value[0]).get_attribute("id") == "g3");

				} catch (XPath.Error e) {
					Test.message("%s", e.message);
					assert_not_reached();
				}
			});

		Test.add_func ("/gxml/xpath/expression/evaluate_w_ns_in_attr_context", () => {
				try {
					Document doc = get_doc_with_ns ();
					XPath.Result result = null;
					Node context = null;

					result = doc.evaluate("//svg:g", new XPath.NSResolver("svg", "http://www.w3.org/2000/svg"));
					assert (result.result_type == XPath.ResultType.ORDERED_NODE_SNAPSHOT);
					assert (result.nodeset_value.size == 3);
					assert (result.nodeset_value[0] != null);
					assert (result.nodeset_value[0] is Element);

					context = result.nodeset_value[0].attributes["id"];
					assert (context != null);
					assert (context is Attr);

					result = context.evaluate("string-length(.)");
					assert (result.result_type == XPath.ResultType.NUMBER);
					assert (result.number_value == 2);

					result = context.evaluate("normalize-space(.)");
					assert (result.result_type == XPath.ResultType.STRING);
					assert (result.string_value == "g1");

				} catch (XPath.Error e) {
					Test.message("%s", e.message);
					assert_not_reached();
				}
			});

		Test.add_func ("/gxml/xpath/expression/evaluate_w_ns_in_text_context", () => {
				try {
					Document doc = get_doc_with_ns ();
					XPath.Result result = null;
					Node context = null;

					result = doc.evaluate("//i:year/text()", new XPath.NSResolver("i", "proto:item-info"));
					assert (result.result_type == XPath.ResultType.ORDERED_NODE_SNAPSHOT);
					assert (result.nodeset_value.size == 1);
					assert (result.nodeset_value[0] != null);
					assert (result.nodeset_value[0] is Text);

					context = result.nodeset_value[0];
					assert (context != null);
					assert (context is Text);

					result = context.evaluate("string-length(.)");
					assert (result.result_type == XPath.ResultType.NUMBER);
					assert (result.number_value == 4);

					result = context.evaluate("normalize-space(.)");
					assert (result.result_type == XPath.ResultType.STRING);
					assert (result.string_value == "1984");

				} catch (XPath.Error e) {
					Test.message("%s", e.message);
					assert_not_reached();
				}
			});
	}
}

