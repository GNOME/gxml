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
public interface GXml.IXsdSchema : GLib.Object, DomElement {
  public const string SCHEMA_NODE_NAME = "schema";
  public const string SCHEMA_NAMESPACE_URI = "http://www.w3.org/2001/XMLSchema";
  public const string SCHEMA_NAMESPACE_PREFIX = "xs";
  public abstract IXsdListElements element_definitions { get; set; }
  public abstract IXsdListSimpleTypes simple_type_definitions { get; set; }
  public abstract IXsdListComplexTypes complex_type_definitions { get; set; }
}

/**
 * XSD schema Error codes for {@link IXsdSchema} objects
 */
public errordomain GXml.IXsdSchemaError {
  INVALIDATION_ERROR
}

public interface GXml.IXsdBaseType : Object {
  public abstract IXsdAnnotation anotation { get; set; }
}

public interface GXml.IXsdSimpleType: Object, DomElement, IXsdBaseType {
  public const string SCHEMA_NODE_NAME = "simpleType";
  /**
   * (#all | List of (list | union | restriction | extension))
   */
  public abstract string final { get; set; }
  public abstract string id { get; set; }
  public abstract string name { get; set; }
  public abstract IXsdAnnotation annotation { get; set; }
  public abstract IXsdTypeList list { get; set; }
  public abstract IXsdTypeUnion union { get; set; }
  public abstract IXsdTypeRestriction restriction { get; set; }
}
public interface GXml.IXsdTypeDef : Object {}
public interface GXml.IXsdTypeRestriction : Object, IXsdTypeDef {
  public const string SCHEMA_NODE_NAME = "restriction";
  public abstract string base { get; set; }
  public abstract string id { get; set; }
  public abstract IXsdSimpleType simple_type { get; set; }
  // TODO: Add all other definitons: like MinExclusive and others
  public abstract IXsdListTypeRestrictionEnumerations enumerations { get; set; }
  public abstract IXsdListTypeRestrictionWhiteSpaces white_spaces { get; set; }
}
public interface GXml.IXsdTypeList: Object, IXsdTypeDef {}
public interface GXml.IXsdTypeUnion : Object, IXsdTypeDef {}

public interface GXml.IXsdTypeRestrictionDef : Object {
  public abstract IXsdAnnotation annotation { get; set; }
}
public interface GXml.IXsdTypeRestrictionMinExclusive : Object, IXsdTypeRestrictionDef {}
public interface GXml.IXsdTypeRestrictionMinInclusive : Object, IXsdTypeRestrictionDef {}
public interface GXml.IXsdTypeRestrictionMaxExclusive : Object, IXsdTypeRestrictionDef {}
public interface GXml.IXsdTypeRestrictionMaxInclusive : Object, IXsdTypeRestrictionDef {}
public interface GXml.IXsdTypeRestrictionTotalDigits : Object, IXsdTypeRestrictionDef {}
public interface GXml.IXsdTypeRestrictionFractionDigits : Object, IXsdTypeRestrictionDef {}
public interface GXml.IXsdTypeRestrictionLength : Object, IXsdTypeRestrictionDef {}
public interface GXml.IXsdTypeRestrictionMinLength : Object, IXsdTypeRestrictionDef {}
public interface GXml.IXsdTypeRestrictionMaxLength : Object, IXsdTypeRestrictionDef {}
public interface GXml.IXsdTypeRestrictionEnumeration : Object, IXsdTypeRestrictionDef {
  public const string SCHEMA_NODE_NAME = "enumeration";
  public abstract string id { get; set; }
  public abstract string value { get; set; }
}
public interface GXml.IXsdTypeRestrictionWhiteSpace: Object, IXsdTypeRestrictionDef {
  public const string SCHEMA_NODE_NAME = "whiteSpace";
  public abstract bool fixed { get; set; default = false; }
  public abstract string id { get; set; }
  /**
   * (collapse | preserve | replace)
   */
  public abstract string value { get; set; }
}
public interface GXml.IXsdTypeRestrictionPattern : Object, IXsdTypeRestrictionDef {}
public interface GXml.IXsdTypeRestrictionAssertion : Object, IXsdTypeRestrictionDef {}
public interface GXml.IXsdTypeRestrictionExplicitTimezone : Object, IXsdTypeRestrictionDef {}

public interface GXml.IXsdComplexType : Object, DomElement, IXsdBaseType {
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
  public abstract bool mixed { get; set; }
  public abstract string name { get; set; }
  /**
   * defaultAttributesApply
   */
  public abstract bool default_attributes_apply { get; set; default = true; }
  /**
   * A {@link IXsdComplexType} or {@link IXsdSimpleType}
   */
  public abstract IXsdBaseContent content_type { get; set; }
  /**
   * List of {@link IXsdAttribute} definitions
   */
  public abstract IXsdListAttributes type_attributes { get; }
  /**
   * List of {@link IXsdAttributeGroup} definitions
   */
  public abstract IXsdListAttributesGroup group_attributes { get; }
}

public interface GXml.IXsdExtension : Object, DomElement {
  public const string SCHEMA_NODE_NAME = "extension";
  public abstract string base { get; set; }
}

public interface GXml.IXsdElement : Object, DomElement {
  public const string SCHEMA_NODE_NAME = "element";
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
  public abstract string? id { get; set; }
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
  public abstract IXsdAnnotation anotation { get; set; }
  public abstract IXsdSimpleType simple_type { get; set; }
  public abstract IXsdComplexType complex_type { get; set; }
  // TODO: Missing: ((simpleType | complexType)?, alternative*, (unique | key | keyref)*))
}

public interface GXml.IXsdAnnotation : Object {}

public interface GXml.IXsdBaseContent : Object {
  public abstract IXsdAnnotation anotation { get; set; }
}
public interface GXml.IXsdSimpleContent : Object, IXsdBaseContent {
  public const string SCHEMA_NODE_NAME = "simpleContent";
}
public interface GXml.IXsdComplexContent : Object, IXsdBaseContent {
  public const string SCHEMA_NODE_NAME = "complexContent";
}
public interface GXml.IXsdOpenContent : Object, IXsdBaseContent {}

public interface GXml.IXsdBaseAttribute : Object {
  public abstract IXsdAnnotation anotation { get; set; }
}
public interface GXml.IXsdAttribute : Object {
  public const string SCHEMA_NODE_NAME = "attribute";
}
public interface GXml.IXsdAttributeGroup : Object {
  public const string SCHEMA_NODE_NAME = "attributeGroup";
}

public interface GXml.IXsdList : Object, Collection {
  public abstract DomElement element { get; construct set; }
  public abstract Type items_type { get; construct set; }
  public abstract Type items_name { get; construct set; }
  public abstract int length { get; }
  public abstract DomElement? get_item (int index);
  public abstract void append (DomElement element);
  public abstract void remove (int index);
  public abstract int index_of (DomElement element);
}

public interface GXml.IXsdListElements : Object, IXsdList {}
public interface GXml.IXsdListSimpleTypes : Object, IXsdList {}
public interface GXml.IXsdListComplexTypes : Object, IXsdList {}
public interface GXml.IXsdListAttributes : Object, IXsdList {}
public interface GXml.IXsdListAttributesGroup : Object, IXsdList {}
public interface GXml.IXsdListTypeRestrictionEnumerations : Object, IXsdList {}
public interface GXml.IXsdListTypeRestrictionWhiteSpaces : Object, IXsdList {}
