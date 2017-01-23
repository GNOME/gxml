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
  public GomXsdListElements elements { get; set; }
  public GomXsdListSimpleTypes simple_type_definitions { get; set; }
  public GomXsdListComplexTypes complex_type_definitions { get; set; }
  construct {
    initialize_with_namespace (XsdSchema.SCHEMA_NAMESPACE_URI,
                              XsdSchema.SCHEMA_NAMESPACE_PREFIX,
                              XsdSchema.SCHEMA_NODE_NAME);
  }
}

public class GXml.GomXsdSimpleType : GomElement {
  /**
   * (#all | List of (list | union | restriction | extension))
   */
  public string final { get; set; }
  public string name { get; set; }
  public GomXsdAnnotation annotation { get; set; }
  public GomXsdSimpleTypeDefinition definition { get; set; }
  construct { initialize (GXml.XsdSimpleType.SCHEMA_NODE_NAME); }
}

public class GXml.GomXsdSimpleTypeDefinition : GomElement {
  public GomXsdAnnotation annotation { get; set; }
}
public class GXml.GomXsdTypeRestriction : GomXsdSimpleTypeDefinition {
  public string base { get; set; }
  public string id { get; set; }
  public GomXsdSimpleType simple_type { get; set; }
  /**
   * List of {link GomXsdTypeRestrictionDefinition} objects
   */
  public GomXsdList definition { get; set; }
}

public class GXml.GomXsdTypeRestrictionDefinition : GomElement {
  public GomXsdAnnotation annotation { get; set; }
}
public class GXml.GomXsdTypeRestrictionMinExclusive : GomXsdTypeRestrictionDefinition {}
public class GXml.GomXsdTypeRestrictionMinInclusive : GomXsdTypeRestrictionDefinition {}
public class GXml.GomXsdTypeRestrictionMaxExclusive : GomXsdTypeRestrictionDefinition {}
public class GXml.GomXsdTypeRestrictionMaxInclusive : GomXsdTypeRestrictionDefinition {}
public class GXml.GomXsdTypeRestrictionTotalDigits : GomXsdTypeRestrictionDefinition {}
public class GXml.GomXsdTypeRestrictionFractionDigits : GomXsdTypeRestrictionDefinition {}
public class GXml.GomXsdTypeRestrictionLength : GomXsdTypeRestrictionDefinition {}
public class GXml.GomXsdTypeRestrictionMinLength : GomXsdTypeRestrictionDefinition {}
public class GXml.GomXsdTypeRestrictionMaxLength : GomXsdTypeRestrictionDefinition {}
public class GXml.GomXsdTypeRestrictionEnumeration : GomXsdTypeRestrictionDefinition {
  public string id { get; set; }
  public string value { get; set; }
  construct { initialize (GXml.XsdTypeRestrictionEnumeration.SCHEMA_NODE_NAME); }
}
public class GXml.GomXsdTypeRestrictionWhiteSpace: GomXsdTypeRestrictionDefinition {}
public class GXml.GomXsdTypeRestrictionPattern : GomXsdTypeRestrictionDefinition {}
public class GXml.GomXsdTypeRestrictionAssertion : GomXsdTypeRestrictionDefinition {}
public class GXml.GomXsdTypeRestrictionExplicitTimezone : GomXsdTypeRestrictionDefinition {}

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
  construct { initialize (GXml.XsdComplexType.SCHEMA_NODE_NAME); }
}

public class GXml.GomXsdExtension : GomElement {
  public string base { get; set; }
  construct { initialize (GXml.XsdExtension.SCHEMA_NODE_NAME); }
}

public class GXml.GomXsdElement : GomElement {
  /**
  * attribute name = abstract
  */
  public bool abstract { get; set; }
  /**
   * (#all | List of (extension | restriction | substitution))
  */
  public string block { get; set; }
  public string default { get; set; }
  /**
   * (#all | List of (extension | restriction))
   */
  public string final { get; set; }
  public string fixed { get; set; }
  /**
   * (qualified | unqualified)
   */
  public string form { get; set; }
  /**
   * (nonNegativeInteger | unbounded)  : 1
   */
  public string maxOccurs { get; set; }
  /**
   * nonNegativeInteger : 1
   */
  public string minOccurs { get; set; }
  public string name { get; set; }
  public bool nillable { get; set; default = false; }
  public string ref { get; set; }
  /**
   * substitutionGroup
   */
  public DomTokenList substitution_group { get; set; }
  /**
   * targetNamespace
   */
  public string target_namespace { get; set; }
  /**
   * attribute name = 'type'
   */
  public string object_type { get; set; }
  public GomXsdAnnotation anotation { get; set; }
  public GomXsdListSimpleTypes simple_type_definitions { get; set; }
  public GomXsdListComplexTypes complex_type_definitions { get; set; }
  construct { initialize (GXml.XsdElement.SCHEMA_NODE_NAME); }
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
  construct { initialize (GXml.XsdSimpleContent.SCHEMA_NODE_NAME); }
}
public class GXml.GomXsdComplexContent : GomXsdBaseContent {
  construct { initialize (GXml.XsdComplexContent.SCHEMA_NODE_NAME); }
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
    element.remove_child (element.child_nodes.item (index));
  }
  public int index_of (DomElement element) {
    if (element.parent_node != this.element) return -1;
    for (int i = 0; i < this.length; i++) {
      if (get_item (i) == element) return i;
    }
    return -1;
  }/*
  public DomElement? GomXsdList.get_item (int index) {
    return (this as GomArrayList).get_item (index);
  }*/
}

public class GXml.GomXsdListElements : GomXsdList {
  construct { initialize (typeof (GomXsdElement)); }
}
public class GXml.GomXsdListSimpleTypes : GomXsdList {
  construct { initialize (typeof (GomXsdSimpleType)); }
}
public class GXml.GomXsdListComplexTypes : GomXsdList {
  construct { initialize (typeof (GomXsdComplexType)); }
}
