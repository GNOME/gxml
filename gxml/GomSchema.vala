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
public class GXml.GomXsdSchema : GomElement {
  public GomXsdListElements element_definitions { get; set; }
  public GomXsdListSimpleTypes simple_type_definitions { get; set; }
  public GomXsdListComplexTypes complex_type_definitions { get; set; }
  construct {
    initialize_with_namespace (IXsdSchema.SCHEMA_NAMESPACE_URI,
                              IXsdSchema.SCHEMA_NAMESPACE_PREFIX,
                              IXsdSchema.SCHEMA_NODE_NAME);
  }
}

public class GXml.GomXsdSimpleType : GomElement {
  /**
   * (#all | List of (list | union | restriction | extension))
   */
  [Description (nick="::final")]
  public string final { get; set; }
  [Description (nick="::name")]
  public string name { get; set; }
  public GomXsdAnnotation annotation { get; set; }
  public GomXsdTypeList list { get; set; }
  public GomXsdTypeUnion union { get; set; }
  public GomXsdTypeRestriction restriction { get; set; }
  construct {
    initialize_with_namespace (IXsdSchema.SCHEMA_NAMESPACE_URI,
                              IXsdSchema.SCHEMA_NAMESPACE_PREFIX,
                              IXsdSimpleType.SCHEMA_NODE_NAME);
  }
}

public class GXml.GomXsdTypeDefinition : GomElement {
  public GomXsdAnnotation annotation { get; set; }
}
public class GXml.GomXsdTypeList : GomXsdTypeDefinition {}
public class GXml.GomXsdTypeUnion : GomXsdTypeDefinition {}
public class GXml.GomXsdTypeRestriction : GomXsdTypeDefinition {
  [Description (nick="::base")]
  public string base { get; set; }
  public GomXsdSimpleType simple_type { get; set; }
  public GomXsdListTypeRestrictionEnumerations enumerations { get; set; }
  public GomXsdListTypeRestrictionWhiteSpaces white_spaces { get; set; }
  construct {
    initialize_with_namespace (IXsdSchema.SCHEMA_NAMESPACE_URI,
                              IXsdSchema.SCHEMA_NAMESPACE_PREFIX,
                              IXsdTypeRestriction.SCHEMA_NODE_NAME);
  }
}

public class GXml.GomXsdTypeRestrictionDef : GomElement {
  public GomXsdAnnotation annotation { get; set; }
}
public class GXml.GomXsdTypeRestrictionMinExclusive : GomXsdTypeRestrictionDef {}
public class GXml.GomXsdTypeRestrictionMinInclusive : GomXsdTypeRestrictionDef {}
public class GXml.GomXsdTypeRestrictionMaxExclusive : GomXsdTypeRestrictionDef {}
public class GXml.GomXsdTypeRestrictionMaxInclusive : GomXsdTypeRestrictionDef {}
public class GXml.GomXsdTypeRestrictionTotalDigits : GomXsdTypeRestrictionDef {}
public class GXml.GomXsdTypeRestrictionFractionDigits : GomXsdTypeRestrictionDef {}
public class GXml.GomXsdTypeRestrictionLength : GomXsdTypeRestrictionDef {}
public class GXml.GomXsdTypeRestrictionMinLength : GomXsdTypeRestrictionDef {}
public class GXml.GomXsdTypeRestrictionMaxLength : GomXsdTypeRestrictionDef {}
public class GXml.GomXsdTypeRestrictionEnumeration : GomXsdTypeRestrictionDef {
  [Description (nick="::value")]
  public string value { get; set; }
  construct {
    initialize_with_namespace (IXsdSchema.SCHEMA_NAMESPACE_URI,
                              IXsdSchema.SCHEMA_NAMESPACE_PREFIX,
                              IXsdTypeRestrictionEnumeration.SCHEMA_NODE_NAME);
  }
}
public class GXml.GomXsdTypeRestrictionWhiteSpace: GomXsdTypeRestrictionDef {
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
  public class Fixed : GomBoolean {}
}
public class GXml.GomXsdTypeRestrictionPattern : GomXsdTypeRestrictionDef {}
public class GXml.GomXsdTypeRestrictionAssertion : GomXsdTypeRestrictionDef {}
public class GXml.GomXsdTypeRestrictionExplicitTimezone : GomXsdTypeRestrictionDef {}

public class GXml.GomXsdComplexType : GomXsdBaseType {
  protected GomXsdList _type_attributes = null;
  protected GomXsdList _group_attributes = null;
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
   * A {@link GomXsdComplexType} or {@link GomXsdSimpleType}
   */
  public GomXsdBaseContent content_type { get; set; }
  /**
   * List of type {@link GomXsdAttribute} definitions
   */
  public GomXsdList type_attributes { get { return _type_attributes; } }
  /**
   * List of type {@link GomXsdGroupAttribute} definitions
   */
  public GomXsdList group_attributes { get { return _group_attributes; } }
  construct {
    initialize_with_namespace (IXsdSchema.SCHEMA_NAMESPACE_URI,
                              IXsdSchema.SCHEMA_NAMESPACE_PREFIX,
                              IXsdComplexType.SCHEMA_NODE_NAME);
  }
}

public class GXml.GomXsdExtension : GomElement {
  [Description (nick="::base")]
  public string base { get; set; }
  construct {
    initialize_with_namespace (IXsdSchema.SCHEMA_NAMESPACE_URI,
                              IXsdSchema.SCHEMA_NAMESPACE_PREFIX,
                              IXsdExtension.SCHEMA_NODE_NAME);
  }
}

public class GXml.GomXsdElement : GomElement {
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
  public GomXsdAnnotation anotation { get; set; }
  [Description (nick="::SimpleType")]
  public GomXsdSimpleType simple_type { get; set; }
  [Description (nick="::ComplexType")]
  public GomXsdComplexType complex_type { get; set; }
  construct {
    initialize_with_namespace (IXsdSchema.SCHEMA_NAMESPACE_URI,
                              IXsdSchema.SCHEMA_NAMESPACE_PREFIX,
                              IXsdElement.SCHEMA_NODE_NAME);
  }
}


public class GXml.GomXsdAnnotation : GomElement {
}

public class GXml.GomXsdBaseType : GomElement {
  public GomXsdAnnotation anotation { get; set; }
}

public class GXml.GomXsdBaseContent : GomElement {
  public GomXsdAnnotation anotation { get; set; }
}
public class GXml.GomXsdSimpleContent : GomXsdBaseContent {
  construct { initialize (GXml.IXsdSimpleContent.SCHEMA_NODE_NAME); }
}
public class GXml.GomXsdComplexContent : GomXsdBaseContent {
  construct { initialize (GXml.IXsdComplexContent.SCHEMA_NODE_NAME); }
}
public class GXml.GomXsdOpenContent : GomXsdBaseContent {}

public class GXml.GomXsdBaseAttribute : GomElement  {
  public GomXsdAnnotation anotation { get; set; }
}
public class GXml.GomXsdAttribute : GomXsdBaseAttribute {}
public class GXml.GomXsdAttributeGroup : GomXsdBaseAttribute {}

public class GXml.GomXsdList : GomArrayList {
  public new int length {
    get { return (this as GomArrayList).length; }
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
        warning (_("Can't find element at position: %i : %s").printf (i,e.message));
      }
    }
    return -1;
  }/*
  public DomElement? GomXsdList.get_item (int index) {
    return (this as GomArrayList).get_item (index);
  }*/
}

public class GXml.GomXsdListElements : GomXsdList {
  construct {
    try { initialize (typeof (GomXsdElement)); }
    catch (GLib.Error e) {
      warning (_("Collection type %s, initialization error: %s").printf (get_type ().name(), e.message));
    }
  }
}
public class GXml.GomXsdListSimpleTypes : GomXsdList {
  construct {
    try { initialize (typeof (GomXsdSimpleType)); }
    catch (GLib.Error e) {
      warning (_("Collection type %s, initialization error: %s").printf (get_type ().name(), e.message));
    }
  }
}
public class GXml.GomXsdListComplexTypes : GomXsdList {
  construct {
    try { initialize (typeof (GomXsdComplexType)); }
    catch (GLib.Error e) {
      warning (_("Collection type %s, initialization error: %s").printf (get_type ().name(), e.message));
    }
  }
}
public class GXml.GomXsdListTypeRestrictionEnumerations : GomXsdList {
  construct {
    try { initialize (typeof (GomXsdTypeRestrictionEnumeration)); }
    catch (GLib.Error e) {
      warning (_("Collection type %s, initialization error: %s").printf (get_type ().name(), e.message));
    }
  }
}
public class GXml.GomXsdListTypeRestrictionWhiteSpaces : GomXsdList {
  construct {
    try { initialize (typeof (GomXsdTypeRestrictionWhiteSpace)); }
    catch (GLib.Error e) {
      warning (_("Collection type %s, initialization error: %s").printf (get_type ().name(), e.message));
    }
  }
}
