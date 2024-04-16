public class ValuteArray : GXml.ArrayList {
    construct {
        try {
            initialize (typeof (Valute));
        } catch (Error e) {
            error (e.message);
        }
    }
}

public class ValCurs : GXml.Element {
    public ValuteArray valutes { get; set; }

    construct {
        try {
            initialize ("ValCurs");
            set_instance_property ("valutes");
        } catch (Error e) {
            error (e.message);
        }
    }
}

public class Valute : GXml.Element {
    public Name Name { get; set; }
    public Nominal Nominal { get; set; }
    public Value Value { get; set; }

    construct {
        try {
            initialize ("Valute");
        } catch (Error e) {
            error (e.message);
        }
    }
}

public class Name : GXml.Element {
    construct {
        try {
            initialize ("Name");
        } catch (Error e) {
            error (e.message);
        }
    }
    public string value () {
        return this.text_content;
    }
}

public class Nominal : GXml.Element {
    construct {
        try {
            initialize ("Nominal");
        } catch (Error e) {
            error (e.message);
        }
    }
    public double value () {
        return double.parse (this.text_content);
    }
}

public class Value : GXml.Element {
    construct {
        try {
            initialize ("Value");
        } catch (Error e) {
            error (e.message);
        }
    }
    public double value () {
        return double_comma_parse (this.text_content);
    }
}

public double double_comma_parse (string str) {
    return double.parse (str.replace (",", "."));
}