
void easy_xpath_way () {
    prin (Log.METHOD);

    try {
        var document = new GXml.XDocument.from_uri ("http://www.cbr.ru/scripts/XML_daily.asp");
        // not implemented yet?
        // var value = ((GXml.XPathContext) document).evaluate ("/ValCurs/Valute[@ID=\"R01200\"]/Name").string_value;
        // var nominal = ((GXml.XPathContext) document).evaluate ("/ValCurs/Valute[@ID=\"R01200\"]/Nominal").number_value;

        var name = ((GXml.XPathContext)document)
                    .evaluate ("/ValCurs/Valute[@ID=\"R01200\"]/Name")
                    .nodeset.to_array ()[0].text_content;
        var nominal = ((GXml.XPathContext)document)
                    .evaluate ("/ValCurs/Valute[@ID=\"R01200\"]/Nominal")
                    .nodeset.to_array ()[0].text_content;
        var value = ((GXml.XPathContext)document)
                    .evaluate ("/ValCurs/Valute[@ID=\"R01200\"]/Value")
                    .nodeset.to_array ()[0].text_content;

        double double_value = double_comma_parse (value);
		double double_nominal = double.parse (nominal);
		double result = double_value / double_nominal;

        prin (@"Name    = $name");
        prin (@"Value   = $double_value");
        prin (@"Nominal = $double_nominal");
        stdout.printf (@"Hong Kong dollar to Russian ruble exchange rate = %.5lf\n", result);
    } catch (Error e) {
        error (@"Bad URL: $(e.message)");
    }
}

void mapping_way () {
    prin (Log.METHOD);

    var file = File.new_for_uri ("http://www.cbr.ru/scripts/XML_daily.asp");
    var s = new ValCurs ();
    try {
        s.read_from_file (file);
		double result = 0.0;

        foreach (var _valute in s.valutes) {
            var valute = _valute as Valute;
            if (valute.Name.text_content == "Гонконгских долларов") {
                result = valute.Value.value () / valute.Nominal.value ();
            }
        }
        stdout.printf ("Hong Kong dollar to Russian ruble exchange rate = %.5lf\n", result);
    } catch (Error e) {
        error (e.message);
    }
}

void main () {
	easy_xpath_way ();
	prin("\n");
    mapping_way ();
}

// Automatically adds to_string to each argument and concatenates them.
[Print]
void prin (string s) {
    stdout.printf (s + "\n");
    stdout.flush ();
}