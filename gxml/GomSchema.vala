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

public class GXml.GomXsdSchema : GomElement, XsdSchema {
  public XsdListElements elements { get; set; }
  public XsdListSimpleTypes simple_types { get; set; }
  construct {
    initialize_with_namespace (XsdSchema.SCHEMA_NAMESPACE_URI,
                              XsdSchema.SCHEMA_NAMESPACE_PREFIX,
                              XsdSchema.SCHEMA_NODE_NAME);
  }
}

public class GXml.GomXsdSimpleType : GomElement,
                DomElement, XsdSimpleType, XsdBaseType
{
  /**
   * (#all | List of (list | union | restriction | extension))
   */
  public string final { get; set; }
  public string name { get; set; }
  public XsdAnnotation annotation { get; set; }
  public XsdSimpleTypeDefinition definition { get; set; }
  construct { initialize (GXml.XsdSimpleType.SCHEMA_NODE_NAME); }
}
public class GXml.GomXsdTypeRestriction : GomElement, XsdTypeRestriction, XsdSimpleTypeDefinition {
  public string base { get; set; }
  public string id { get; set; }
  public XsdAnnotation annotation { get; set; }
  public XsdSimpleType simple_type { get; set; }
  /**
   * List of {link XsdTypeRestrictionDefinition} objects
   */
  public XsdList definition { get; set; }
}

public class GXml.GomXsdTypeRestrictionDefinition : GomElement,
              XsdTypeRestrictionDefinition {
  public XsdAnnotation annotation { get; set; }
}
public class GXml.GomXsdTypeRestrictionMinExclusive : GomXsdTypeRestrictionDefinition,
              XsdTypeRestrictionMinExclusive {}
public class GXml.GomXsdTypeRestrictionMinInclusive : GomXsdTypeRestrictionDefinition,
              XsdTypeRestrictionMinInclusive {}
public class GXml.GomXsdTypeRestrictionMaxExclusive : GomXsdTypeRestrictionDefinition,
              XsdTypeRestrictionMaxExclusive {}
public class GXml.GomXsdTypeRestrictionMaxInclusive : GomXsdTypeRestrictionDefinition,
              XsdTypeRestrictionMaxInclusive {}
public class GXml.GomXsdTypeRestrictionTotalDigits : GomXsdTypeRestrictionDefinition,
              XsdTypeRestrictionTotalDigits {}
public class GXml.GomXsdTypeRestrictionFractionDigits : GomXsdTypeRestrictionDefinition,
              XsdTypeRestrictionFractionDigits {}
public class GXml.GomXsdTypeRestrictionLength : GomXsdTypeRestrictionDefinition,
              XsdTypeRestrictionLength {}
public class GXml.GomXsdTypeRestrictionMinLength : GomXsdTypeRestrictionDefinition,
              XsdTypeRestrictionMinLength {}
public class GXml.GomXsdTypeRestrictionMaxLength : GomXsdTypeRestrictionDefinition,
              XsdTypeRestrictionMaxLength {}
public class GXml.GomXsdTypeRestrictionEnumeration : GomXsdTypeRestrictionDefinition,
              XsdTypeRestrictionEnumeration {
  public string id { get; set; }
  public string value { get; set; }
  construct { initialize (GXml.XsdTypeRestrictionEnumeration.SCHEMA_NODE_NAME); }
}
public class GXml.GomXsdTypeRestrictionWhiteSpace: GomXsdTypeRestrictionDefinition,
              XsdTypeRestrictionWhiteSpace {}
public class GXml.GomXsdTypeRestrictionPattern : GomXsdTypeRestrictionDefinition,
              XsdTypeRestrictionPattern {}
public class GXml.GomXsdTypeRestrictionAssertion : GomXsdTypeRestrictionDefinition,
              XsdTypeRestrictionAssertion {}
public class GXml.GomXsdTypeRestrictionExplicitTimezone : GomXsdTypeRestrictionDefinition,
              XsdTypeRestrictionExplicitTimezone {}

public class GXml.GomXsdComplexType : GomXsdBaseType, XsdComplexType {
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
   * List of type {@link XsdGroupAttribute} definitions
   */
  public XsdList group_attributes { get { return _group_attributes; } }
  construct { initialize (GXml.XsdComplexType.SCHEMA_NODE_NAME); }
}

public class GXml.GomXsdExtension : GomElement, XsdExtension {
  public string base { get; set; }
  construct { initialize (GXml.XsdExtension.SCHEMA_NODE_NAME); }
}

public class GXml.GomXsdElement : GomElement, XsdElement {
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
  public XsdAnnotation anotation { get; set; }
  /**
   * A {@link XsdComplexType} or {@link XsdSimpleType} list of elements
   */
  public XsdListBaseTypes type_definitions { get; set; }
  construct { initialize (GXml.XsdElement.SCHEMA_NODE_NAME); }
}


public class GXml.GomXsdAnnotation : GomElement, XsdAnnotation {
}

public class GXml.GomXsdBaseType : GomElement, XsdBaseType {
  public XsdAnnotation anotation { get; set; }
}

public class GXml.GomXsdBaseContent : GomElement, XsdBaseContent {
  public XsdAnnotation anotation { get; set; }
}
public class GXml.GomXsdSimpleContent : GomXsdBaseContent, XsdBaseContent {
  construct { initialize (GXml.XsdSimpleContent.SCHEMA_NODE_NAME); }
}
public class GXml.GomXsdComplexContent : GomXsdBaseContent, XsdBaseContent {
  construct { initialize (GXml.XsdComplexContent.SCHEMA_NODE_NAME); }
}
public class GXml.GomXsdOpenContent : GomXsdBaseContent, XsdBaseContent {}

public class GXml.GomXsdBaseAttribute : GomElement, XsdBaseAttribute  {
  public XsdAnnotation anotation { get; set; }
}
public class GXml.GomXsdAttribute : GomXsdBaseAttribute, XsdAttribute {}
public class GXml.GomXsdAttributeGroup : GomXsdBaseAttribute, XsdAttributeGroup {}

public class GXml.GomXsdList : GomArrayList, XsdList {
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
  }
  public DomElement? XsdList.get_item (int index) {
    return (this as GomArrayList).get_item (index);
  }
}

public class GXml.GomXsdListElements : GomXsdList, XsdListElements {
  construct { initialize (typeof (GomXsdElement)); }
}
public class GXml.GomXsdListSimpleTypes : GomXsdList, XsdListSimpleTypes {
  construct { initialize (typeof (GomXsdSimpleType)); }
}
public class GXml.GomXsdListBaseTypes : GomXsdList, XsdListBaseTypes {
  construct { initialize (typeof (GomXsdBaseType)); }
}
