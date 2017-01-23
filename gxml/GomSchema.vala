/* -*- Mode: vala; indent-tabs-mode: nil; c-basic-offset: 2; tab-width: 2 -*- */
/*
 *
 * Copyright (C) 2016  Daniel Espinosa <esodan@gmail.com>
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
  public XsdList elements { get; set; }
  public XsdList simple_types { get; set; }
  construct {
    initialize (XsdSchema.SCHEMA_NODE_NAME);
    set_attribute_ns ("http://www.w3.org/2000/xmlns/",
                      "xmlns:"+XsdSchema.SCHEMA_NAMESPACE_PREFIX,
                      XsdSchema.SCHEMA_NAMESPACE_URI);
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

public class GXml.GomXsdComplexType : GomElement, DomElement, XsdBaseType {
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
  public XsdList anotations { get; set; }
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

public class GXml.GomXsdExtension : GomElement, DomElement {
  public string base { get; set; }
  construct { initialize (GXml.XsdExtension.SCHEMA_NODE_NAME); }
}

public class GXml.GomXsdElement : GomElement, DomElement {
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
  public XsdList type_definition { get; set; }
  construct { initialize (GXml.XsdElement.SCHEMA_NODE_NAME); }
}

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
