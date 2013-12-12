/* -*- Mode: vala; indent-tabs-mode: t; c-basic-offset: 8; tab-width: 8 -*- */
using GXml;

class TestResult : GXml.XPath.Result {
	public TestResult (Document doc, Xml.XPath.Object* o) throws XPath.Error {
		base (doc, o);
	}
}

/* sizeof(Xml.XPath.Object) = sizeof(void*) */
public const int SIZEOF_XPATH_OBJECT = 56;

/*
 * calloc is used to allocate memory for Xml.XPath.Object as a workaround for
 * lack of constructor. This ensures that object->stringval will be null before
 * first assignment (this field would be g_free0d upon assignment, so if it had
 * some non-null value it would result in segfault).
 */
[CCode (cname="calloc")]
extern void* calloc(size_t num, size_t size);


class XPathResultTest : GXmlTest {

	public static void add_tests () {

		Test.add_func ("/gxml/xpath/result/create_type_number", () => {
				Document doc = get_doc ();
				Xml.XPath.Object* o = calloc (1, SIZEOF_XPATH_OBJECT);

				o->type = Xml.XPath.ObjectType.NUMBER;
				o->floatval = 4.0;

				try {
					TestResult result = new TestResult (doc, o);
					assert (result.result_type == XPath.ResultType.NUMBER);
					assert (result.number_value == 4.0);
					assert (result.to_bool () == true);
					assert (result.to_number () == 4.0);
					assert (result.to_string () == "4");

				} catch (XPath.Error e) {
					Test.message("%s", e.message);
					assert_not_reached ();
				}
			});

		Test.add_func ("/gxml/xpath/result/create_type_boolean_true", () => {
				Document doc = get_doc ();
				Xml.XPath.Object* o = calloc (1, SIZEOF_XPATH_OBJECT);

				o->type = Xml.XPath.ObjectType.BOOLEAN;
				o->boolval = (int) true;

				try {
					TestResult result = new TestResult (doc, o);
					assert (result.result_type == XPath.ResultType.BOOLEAN);
					assert (result.boolean_value == true);
					assert (result.to_bool () == true);
					assert (result.to_number () == 1.0);
					assert (result.to_string () == "true");

				} catch (XPath.Error e) {
					Test.message("%s", e.message);
					assert_not_reached ();
				}
			});

		Test.add_func ("/gxml/xpath/result/create_type_boolean_false", () => {
				Document doc = get_doc ();
				Xml.XPath.Object* o = calloc (1, SIZEOF_XPATH_OBJECT);

				o->type = Xml.XPath.ObjectType.BOOLEAN;
				o->boolval = (int) false;

				try {
					TestResult result = new TestResult(doc, o);
					assert (result.result_type == XPath.ResultType.BOOLEAN);
					assert (result.boolean_value == false);
					assert (result.to_bool () == false);
					assert (result.to_number () == 0.0);
					assert (result.to_string () == "false");

				} catch (XPath.Error e) {
					Test.message("%s", e.message);
					assert_not_reached ();
				}
			});

		Test.add_func ("/gxml/xpath/result/create_type_string_nan_true", () => {
				Document doc = get_doc ();
				Xml.XPath.Object* o = calloc (1, SIZEOF_XPATH_OBJECT);

				o->type = Xml.XPath.ObjectType.STRING;
				o->stringval = "SomeString";

				try {
					TestResult result = new TestResult (doc, o);
					assert (result.result_type == XPath.ResultType.STRING);
					assert (result.string_value == "SomeString");
					assert (result.to_bool () == true);
					assert (result.to_number ().is_nan());
					assert (result.to_string () == "SomeString");

				} catch (XPath.Error e) {
					Test.message("%s", e.message);
					assert_not_reached ();
				}
			});

		Test.add_func ("/gxml/xpath/result/create_type_string_nan_false", () => {
				Document doc = get_doc ();
				Xml.XPath.Object* o = calloc (1, SIZEOF_XPATH_OBJECT);

				o->type = Xml.XPath.ObjectType.STRING;
				o->stringval = "";

				try {
					TestResult result = new TestResult (doc, o);
					assert (result.result_type == XPath.ResultType.STRING);
					assert (result.string_value == "");
					assert (result.to_bool () == false);
					assert (result.to_number ().is_nan());
					assert (result.to_string () == "");

				} catch (XPath.Error e) {
					Test.message("%s", e.message);
					assert_not_reached ();
				}
			});

		Test.add_func ("/gxml/xpath/result/create_type_string_numeric", () => {
				Document doc = get_doc ();
				Xml.XPath.Object* o = calloc (1, SIZEOF_XPATH_OBJECT);

				o->type = Xml.XPath.ObjectType.STRING;
				o->stringval = "4e+1";

				try {
					TestResult result = new TestResult(doc, o);
					assert (result.result_type == XPath.ResultType.STRING);
					assert (result.string_value == "4e+1");
					assert (result.to_bool () == true);
					assert (result.to_number () == 40.0);
					assert (result.to_string () == "4e+1");

				} catch (XPath.Error e) {
					Test.message("%s", e.message);
					assert_not_reached ();
				}
			});
	}
}
