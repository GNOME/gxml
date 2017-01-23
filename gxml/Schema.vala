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

public interface GXml.XsdSchema : GLib.Object, DomElement {
  public const string SCHEMA_NODE_NAME = "schema";
  public const string SCHEMA_NAMESPACE_URI = "http://www.w3.org/2001/XMLSchema";
  public const string SCHEMA_NAMESPACE_PREFIX = "xs";
  public abstract XsdList elements { get; set; }
  public abstract XsdList simple_types { get; set; }
}

public errordomain GXml.SchemaError {
  INVALIDATION_ERROR
}
public interface GXml.XsdSimpleType: Object, DomElement, XsdBaseType {
  public const string SCHEMA_NODE_NAME = "simpleType";
  /**
   * (#all | List of (list | union | restriction | extension))
   */
  public abstract string final { get; set; }
  public abstract string id { get; set; }
  public abstract string name { get; set; }
  public abstract XsdAnnotation annotation { get; set; }
}
public interface GXml.XsdSimpleTypeDefinition : Object {}
public interface GXml.XsdTypeRestriction : Object, XsdSimpleTypeDefinition {
  public abstract string base { get; set; }
  public abstract string id { get; set; }
  public abstract XsdAnnotation annotation { get; set; }
  public abstract XsdSimpleType simple_type { get; set; }
  /**
   * List of {link XsdTypeRestrictionDefinition} objects
   */
  public abstract XsdList definition { get; set; }
}
public interface GXml.XsdTypeList: Object {}
public interface GXml.XsdTypeUnion : Object {}

public interface GXml.XsdTypeRestrictionDefinition : Object {
  public abstract XsdAnnotation annotation { get; set; }
}
public interface GXml.XsdTypeRestrictionMinExclusive : Object, XsdTypeRestrictionDefinition {}
public interface GXml.XsdTypeRestrictionMinInclusive : Object, XsdTypeRestrictionDefinition {}
public interface GXml.XsdTypeRestrictionMaxExclusive : Object, XsdTypeRestrictionDefinition {}
public interface GXml.XsdTypeRestrictionMaxInclusive : Object, XsdTypeRestrictionDefinition {}
public interface GXml.XsdTypeRestrictionTotalDigits : Object, XsdTypeRestrictionDefinition {}
public interface GXml.XsdTypeRestrictionFractionDigits : Object, XsdTypeRestrictionDefinition {}
public interface GXml.XsdTypeRestrictionLength : Object, XsdTypeRestrictionDefinition {}
public interface GXml.XsdTypeRestrictionMinLength : Object, XsdTypeRestrictionDefinition {}
public interface GXml.XsdTypeRestrictionMaxLength : Object, XsdTypeRestrictionDefinition {}
public interface GXml.XsdTypeRestrictionEnumeration : Object, XsdTypeRestrictionDefinition {
  public const string SCHEMA_NODE_NAME = "enumeration";
  public abstract string id { get; set; }
  public abstract string value { get; set; }
}
public interface GXml.XsdTypeRestrictionWhiteSpace: Object, XsdTypeRestrictionDefinition {}
public interface GXml.XsdTypeRestrictionPattern : Object, XsdTypeRestrictionDefinition {}
public interface GXml.XsdTypeRestrictionAssertion : Object, XsdTypeRestrictionDefinition {}
public interface GXml.XsdTypeRestrictionExplicitTimezone : Object, XsdTypeRestrictionDefinition {}

public interface GXml.XsdComplexType : Object, DomElement, XsdBaseType {
  public const string SCHEMA_NODE_NAME = "complexType";
  /**
  * attribute name = abstract
  */
  public abstract bool abstract { get; set; default = false; }
  /**
  * (#all | List of (extension | restriction))
  */
  public abstract string block { get; set; }
  /**
  * (#all | List of (extension | restriction))
  */
  public abstract string final { get; set; }
  public abstract string id { get; set; }
  public abstract bool mixed { get; set; }
  public abstract string name { get; set; }
  /**
   * defaultAttributesApply
   */
  public abstract bool default_attributes_apply { get; set; default = true; }
  public abstract XsdList anotations { get; set; }
  /**
   * A {@link XsdComplexType} or {@link XsdSimpleType}
   */
  public abstract XsdBaseContent content_type { get; set; }
  /**
   * List of type {@link XsdAttribute} definitions
   */
  public abstract XsdList attributes { get; set; }
  /**
   * List of type {@link XsdGroupAttribute} definitions
   */
  public abstract XsdList group_attributes { get; set; }
}

public interface GXml.XsdExtension : Object, DomElement {
  public const string SCHEMA_NODE_NAME = "extension";
  public abstract string base { get; set; }
}

public interface GXml.XsdElement : Object, DomElement {
  public const string SCHEMA_NODE_NAME = "simpleType";
  /**
  * attribute name = abstract
  */
  public abstract bool abstract { get; set; }
  /**
   * (#all | List of (extension | restriction | substitution))
  */
  public abstract string block { get; set; }
  public abstract string default { get; set; }
  /**
   * (#all | List of (extension | restriction))
   */
  public abstract string final { get; set; }
  public abstract string fixed { get; set; }
  /**
   * (qualified | unqualified)
   */
  public abstract string form { get; set; }
  public abstract string id { get; set; }
  /**
   * (nonNegativeInteger | unbounded)  : 1
   */
  public abstract string maxOccurs { get; set; }
  /**
   * nonNegativeInteger : 1
   */
  public abstract string minOccurs { get; set; }
  public abstract string name { get; set; }
  public abstract bool nillable { get; set; default = false; }
  public abstract string ref { get; set; }
  /**
   * substitutionGroup
   */
  public abstract DomTokenList substitution_group { get; set; }
  /**
   * targetNamespace
   */
  public abstract string target_namespace { get; set; }
  /**
   * attribute name = 'type'
   */
  public abstract string object_type { get; set; }
  public abstract XsdAnnotation anotation { get; set; }
  /**
   * A {@link XsdComplexType} or {@link XsdSimpleType} list of elements
   */
  public abstract XsdList type_definition { get; set; }
  // TODO: Missing: ((simpleType | complexType)?, alternative*, (unique | key | keyref)*))
}

public interface GXml.XsdAnnotation : Object {}

public interface GXml.XsdBaseType : Object {}

public interface GXml.XsdBaseContent : Object {}
public interface GXml.XsdSimpleContent : Object, XsdBaseContent {
  public const string SCHEMA_NODE_NAME = "simpleContent";
}
public interface GXml.XsdComplexContent : Object, XsdBaseContent {
  public const string SCHEMA_NODE_NAME = "complexContent";
}
public interface GXml.XsdOpenContent : Object, XsdBaseContent {}

public interface GXml.XsdBaseAttribute : Object {}
public interface GXml.XsdAttribute : Object {}
public interface GXml.XsdAttributeGroup : Object {}

public interface GXml.XsdList : Object {
  public abstract Type item_type { get; construct set; }
  public abstract Type item_node_name { get; construct set; }
  public abstract int length { get; }
  public abstract DomElement? index (int index);
  public abstract void add (DomElement element);
  public abstract void remove (int index);
  public abstract int index_of (DomElement element);
}
