/* -*- Mode: vala; indent-tabs-mode: nil; c-basic-offset: 2; tab-width: 2 -*- */
/*
 *
 * Copyright (C) 2016  Yannick Inizan <inizan.yannick@gmail.com>
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
 *      Yannick Inizan <inizan.yannick@gmail.com>
 *      Daniel Espinosa <esodan@gmail.com>
 */

/**
 * Object type codes for  {@link XPathObject} objects
 */
public enum GXml.XPathObjectType {
  UNDEFINED,
  NODESET,
  BOOLEAN,
  NUMBER,
  STRING,
  POINT, // unused
  RANGE, // not implemented
  LOCATIONSET, // unused
  USERS, // unused
  XSLT_TREE // not implemented
}

/**
 * Parser Error codes for {@link XPathObject} objects
 */
public errordomain GXml.XPathError {
  EXPRESSION_OK,
  NUMBER_ERROR,
  UNFINISHED_LITERAL_ERROR,
  START_LITERAL_ERROR,
  VARIABLE_REF_ERROR,
  UNDEF_VARIABLE_ERROR,
  INVALID_PREDICATE_ERROR,
  EXPR_ERROR,
  UNCLOSED_ERROR,
  UNKNOWN_FUNC_ERROR,
  INVALID_OPERAND,
  INVALID_TYPE,
  INVALID_ARITY,
  INVALID_CTXT_SIZE,
  INVALID_CTXT_POSITION,
  MEMORY_ERROR,
  XPTR_SYNTAX_ERROR,
  XPTR_RESOURCE_ERROR,
  XPTR_SUB_RESOURCE_ERROR,
  UNDEF_PREFIX_ERROR,
  ENCODING_ERROR,
  INVALID_CHAR_ERROR,
  INVALID_CTXT
}

public interface GXml.XPathContext : GLib.Object {
  /**
   * Evaluate XPath expression.
   *
   * This method evaluates provided expression, registers provided namespaces
   * in resolver and returns an {@link GXml.XPathObject}.
   *
   * Resolver is a map where its key is the namespace's prefix and
   * its value is the namespace's URI
   *
   * Throw {@link GXml.XPathError} if one of provided namespaces is invalid.
   */
  public abstract GXml.XPathObject evaluate (string expression,
                                            Gee.Map<string,string>? resolver = null)
                                            throws GXml.XPathObjectError;

}

public errordomain GXml.XPathObjectError {
  INVALID_NAMESPACE_ERROR
}

public interface GXml.XPathObject : GLib.Object {
  /**
   *
   */
  public abstract GXml.XPathObjectType object_type { get; }
  /**
   *
   */
  public abstract bool boolean_value { get; }
  /**
   *
   */
  public abstract string string_value { get; }
  /**
   *
   */
  public abstract double number_value { get; }
  /**
   *
   */
  public abstract GXml.DomHTMLCollection nodeset { get; }
}

