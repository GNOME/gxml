/* -*- Mode: vala; indent-tabs-mode: nil; c-basic-offset: 2; tab-width: 2 -*- */
/*
 *
 * Copyright (C) 2017  Daniel Espinosa <esodan@gmail.com>
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.

 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.

 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, see <http://www.gnu.org/licenses/>.
 *
 * Authors:
 *      Daniel Espinosa <esodan@gmail.com>
 */
using GXml;

/**
 * Reference interfaces for XSD support.
 */
public class GXml.XsdSchema : GXml.Element {
  public XsdListElements element_definitions { get; set; }
  public XsdListSimpleTypes simple_type_definitions { get; set; }
  public XsdListComplexTypes complex_type_definitions { get; set; }
  construct {
    initialize_with_namespace (IXsdSchema.SCHEMA_NAMESPACE_URI,
                              IXsdSchema.SCHEMA_NAMESPACE_PREFIX,
                              IXsdSchema.SCHEMA_NODE_NAME);
  }
}

public class GXml.XsdSimpleType : GXml.Element {
  /**
   * (#all | List of (list | union | restriction | extension))
   */
  [Description (nick="::final")]
  public string final { get; set; }
  [Description (nick="::name")]
  public string name { get; set; }
  public XsdAnnotation annotation { get; set; }
  public XsdTypeList list { get; set; }
  public XsdTypeUnion union { get; set; }
  public XsdTypeRestriction restriction { get; set; }
  construct {
    initialize_with_namespace (IXsdSchema.SCHEMA_NAMESPACE_URI,
                              IXsdSchema.SCHEMA_NAMESPACE_PREFIX,
                              IXsdSimpleType.SCHEMA_NODE_NAME);
  }
}

public class GXml.XsdTypeDefinition : GXml.Element {
  public XsdAnnotation annotation { get; set; }
}
public class GXml.XsdTypeList : XsdTypeDefinition {}
public class GXml.XsdTypeUnion : XsdTypeDefinition {}
public class GXml.XsdTypeRestriction : XsdTypeDefinition {
  [Description (nick="::base")]
  public string base { get; set; }
  public XsdSimpleType simple_type { get; set; }
  public XsdListTypeRestrictionEnumerations enumerations { get; set; }
  public XsdListTypeRestrictionWhiteSpaces white_spaces { get; set; }
  construct {
    initialize_with_namespace (IXsdSchema.SCHEMA_NAMESPACE_URI,
                              IXsdSchema.SCHEMA_NAMESPACE_PREFIX,
                              IXsdTypeRestriction.SCHEMA_NODE_NAME);
  }
}

public class GXml.XsdTypeRestrictionDef : GXml.Element {
  public XsdAnnotation annotation { get; set; }
}
public class GXml.XsdTypeRestrictionMinExclusive : XsdTypeRestrictionDef {}
public class GXml.XsdTypeRestrictionMinInclusive : XsdTypeRestrictionDef {}
public class GXml.XsdTypeRestrictionMaxExclusive : XsdTypeRestrictionDef {}
public class GXml.XsdTypeRestrictionMaxInclusive : XsdTypeRestrictionDef {}
public class GXml.XsdTypeRestrictionTotalDigits : XsdTypeRestrictionDef {}
public class GXml.XsdTypeRestrictionFractionDigits : XsdTypeRestrictionDef {}
public class GXml.XsdTypeRestrictionLength : XsdTypeRestrictionDef {}
public class GXml.XsdTypeRestrictionMinLength : XsdTypeRestrictionDef {}
public class GXml.XsdTypeRestrictionMaxLength : XsdTypeRestrictionDef {}
public class GXml.XsdTypeRestrictionEnumeration : XsdTypeRestrictionDef {
  [Description (nick="::value")]
  public string value { get; set; }
  construct {
    initialize_with_namespace (IXsdSchema.SCHEMA_NAMESPACE_URI,
                              IXsdSchema.SCHEMA_NAMESPACE_PREFIX,
                              IXsdTypeRestrictionEnumeration.SCHEMA_NODE_NAME);
  }
}
public class GXml.XsdTypeRestrictionWhiteSpace: XsdTypeRestrictionDef {
  [Description (nick="::fixed")]
  public Fixed fixed { get; set; }
  /**
   * (collapse | preserve | replace)
   */
  [Description (nick="::value")]
  public string value { get; set; }
  construct {
    initialize_with_namespace (IXsdSchema.SCHEMA_NAMESPACE_URI,
                              IXsdSchema.SCHEMA_NAMESPACE_PREFIX,
                              IXsdTypeRestrictionWhiteSpace.SCHEMA_NODE_NAME);
  }
  public class Fixed : GXml.Boolean {}
}
public class GXml.XsdTypeRestrictionPattern : XsdTypeRestrictionDef {}
public class GXml.XsdTypeRestrictionAssertion : XsdTypeRestrictionDef {}
public class GXml.XsdTypeRestrictionExplicitTimezone : XsdTypeRestrictionDef {}

public class GXml.XsdComplexType : XsdBaseType {
  protected XsdList _type_attributes = null;
  protected XsdList _group_attributes = null;
  /**
  * attribute name = abstract
  */
  public bool abstract { get; set; default = false; }
  /**
  * (#all | List of (extension | restriction))
  */
  public string block { get; set; }
  /**
  * (#all | List of (extension | restriction))
  */
  public string final { get; set; }
  public bool mixed { get; set; }
  public string name { get; set; }
  /**
   * defaultAttributesApply
   */
  public bool default_attributes_apply { get; set; default = true; }
  /**
   * A {@link XsdComplexType} or {@link XsdSimpleType}
   */
  public XsdBaseContent content_type { get; set; }
  /**
   * List of type {@link XsdAttribute} definitions
   */
  public XsdList type_attributes { get { return _type_attributes; } }
  /**
   * List of group {@link XsdAttribute} definitions
   */
  public XsdList group_attributes { get { return _group_attributes; } }
  construct {
    initialize_with_namespace (IXsdSchema.SCHEMA_NAMESPACE_URI,
                              IXsdSchema.SCHEMA_NAMESPACE_PREFIX,
                              IXsdComplexType.SCHEMA_NODE_NAME);
  }
}

public class GXml.XsdExtension : GXml.Element {
  [Description (nick="::base")]
  public string base { get; set; }
  construct {
    initialize_with_namespace (IXsdSchema.SCHEMA_NAMESPACE_URI,
                              IXsdSchema.SCHEMA_NAMESPACE_PREFIX,
                              IXsdExtension.SCHEMA_NODE_NAME);
  }
}

public class GXml.XsdElement : GXml.Element {
  /**
  * attribute name = abstract
  */
  [Description (nick="::abstract")]
  public bool abstract { get; set; }
  /**
   * (#all | List of (extension | restriction | substitution))
  */
  [Description (nick="::block")]
  public string block { get; set; }
  [Description (nick="::default")]
  public string default { get; set; }
  /**
   * (#all | List of (extension | restriction))
   */
  [Description (nick="::final")]
  public string final { get; set; }
  [Description (nick="::fixed")]
  public string fixed { get; set; }
  /**
   * (qualified | unqualified)
   */
  [Description (nick="::form")]
  public string form { get; set; }
  /**
   * (nonNegativeInteger | unbounded)  : 1
   */
  [Description (nick="::maxOccurs")]
  public string max_occurs { get; set; }
  /**
   * nonNegativeInteger : 1
   */
  [Description (nick="::minOccurs")]
  public string min_occurs { get; set; }
  [Description (nick="::name")]
  public string name { get; set; }
  [Description (nick="::nillable")]
  public bool nillable { get; set; default = false; }
  [Description (nick="::ref")]
  public new string ref { get; set; }
  /**
   * substitutionGroup
   */
  [Description (nick="::substitutionGroup")]
  public DomTokenList substitution_group { get; set; }
  /**
   * targetNamespace
   */
  [Description (nick="::targetNamespace")]
  public string target_namespace { get; set; }
  /**
   * attribute name = 'type'
   */
  [Description (nick="::type")]
  public string object_type { get; set; }
  [Description (nick="::annotation")]
  public XsdAnnotation anotation { get; set; }
  [Description (nick="::SimpleType")]
  public XsdSimpleType simple_type { get; set; }
  [Description (nick="::ComplexType")]
  public XsdComplexType complex_type { get; set; }
  construct {
    initialize_with_namespace (IXsdSchema.SCHEMA_NAMESPACE_URI,
                              IXsdSchema.SCHEMA_NAMESPACE_PREFIX,
                              IXsdElement.SCHEMA_NODE_NAME);
  }
}


public class GXml.XsdAnnotation : GXml.Element {
}

public class GXml.XsdBaseType : GXml.Element {
  public XsdAnnotation anotation { get; set; }
}

public class GXml.XsdBaseContent : GXml.Element {
  public XsdAnnotation anotation { get; set; }
}
public class GXml.XsdSimpleContent : XsdBaseContent {
  construct { initialize (GXml.IXsdSimpleContent.SCHEMA_NODE_NAME); }
}
public class GXml.XsdComplexContent : XsdBaseContent {
  construct { initialize (GXml.IXsdComplexContent.SCHEMA_NODE_NAME); }
}
public class GXml.XsdOpenContent : XsdBaseContent {}

public class GXml.XsdBaseAttribute : GXml.Element  {
  public XsdAnnotation anotation { get; set; }
}
public class GXml.XsdAttribute : XsdBaseAttribute {}
public class GXml.XsdAttributeGroup : XsdBaseAttribute {}

public class GXml.XsdList : ArrayList {
  public new int length {
    get { return ((ArrayList) this).length; }
  }
  public void remove (int index) {
    try { element.remove_child (element.child_nodes.item (index)); }
    catch (GLib.Error e) {
      warning (_("Error removing Collection's element: %s").printf (e.message));
    }
  }
  public int index_of (DomElement element) {
    if (element.parent_node != this.element) return -1;
    for (int i = 0; i < this.length; i++) {
      try {
        if (get_item (i) == element) return i;
      } catch (GLib.Error e) {
        warning (_("Can't find element at position: %i: %s").printf (i,e.message));
      }
    }
    return -1;
  }/*
  public DomElement? XsdList.get_item (int index) {
    return (this as GXml.ArrayList).get_item (index);
  }*/
}

public class GXml.XsdListElements : XsdList {
  construct {
    try { initialize (typeof (XsdElement)); }
    catch (GLib.Error e) {
      warning (_("Collection type %s, initialization error: %s").printf (get_type ().name(), e.message));
    }
  }
}
public class GXml.XsdListSimpleTypes : XsdList {
  construct {
    try { initialize (typeof (XsdSimpleType)); }
    catch (GLib.Error e) {
      warning (_("Collection type %s, initialization error: %s").printf (get_type ().name(), e.message));
    }
  }
}
public class GXml.XsdListComplexTypes : XsdList {
  construct {
    try { initialize (typeof (XsdComplexType)); }
    catch (GLib.Error e) {
      warning (_("Collection type %s, initialization error: %s").printf (get_type ().name(), e.message));
    }
  }
}
public class GXml.XsdListTypeRestrictionEnumerations : XsdList {
  construct {
    try { initialize (typeof (XsdTypeRestrictionEnumeration)); }
    catch (GLib.Error e) {
      warning (_("Collection type %s, initialization error: %s").printf (get_type ().name(), e.message));
    }
  }
}
public class GXml.XsdListTypeRestrictionWhiteSpaces : XsdList {
  construct {
    try { initialize (typeof (XsdTypeRestrictionWhiteSpace)); }
    catch (GLib.Error e) {
      warning (_("Collection type %s, initialization error: %s").printf (get_type ().name(), e.message));
    }
  }
}
