/* -*- Mode: vala; indent-tabs-mode: t; c-basic-offset: 8; tab-width: 8 -*- */
/* XPathResult.vala
 *
 * Copyright (C) 2011-2013  Richard Schwarting <aquarichy@gmail.com>
 * Copyright (C) 2011  Daniel Espinosa <esodan@gmail.com>
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
 *      Richard Schwarting <aquarichy@gmail.com>
 *      Daniel Espinosa <esodan@gmail.com>
 */
namespace GXml.XPath {

	/**
	 * Data type of XPathResult (see [[http://www.w3.org/TR/2004/NOTE-DOM-Level-3-XPath-20040226/xpath.html#XPathResult]]).
	 */
	public enum ResultType {
		/**
		 * This code does not represent a specific type. An evaluation of an XPath
		 * expression will never produce this type. If this type is requested, then
		 * the evaluation returns whatever type naturally results from evaluation
		 * of the expression.
		 */
		ANY,
		NUMBER,
		STRING,
		BOOLEAN,
		UNORDERED_NODE_ITERATOR,
		ORDERED_NODE_ITERATOR,
		UNORDERED_NODE_SNAPSHOT,
		ORDERED_NODE_SNAPSHOT,
		ANY_UNORDERED_NODE,
		FIRST_ORDERED_NODE
	}

	/**
	 * Represents result of XPath expression evaluation.
	 */
	public class Result : GLib.Object {

		internal Gee.List<Node> nodeset;
		internal Xml.XPath.Object* object;
		/**
		 * Type of result value
		 */
		public ResultType  result_type { get; private set; }

		/**
		 * Returns value for number result
		 */
		public double number_value {
			get {
				// "properties throwing errors are not supported yet"
				// if (result_type != ResultType.NUMBER)
				// 	throw new XPath.Error.TYPE ("Result type is not number");
				return object->floatval;
			}
		}

		/**
		 * Returns value for string result
		 */
		public string string_value {
			get {
				// if (result_type != ResultType.STRING)
				// 	throw new XPath.Error.TYPE ("Result type is not string");
				return object->stringval;
			}
		}

		/**
		 * Returns value for boolean result
		 */
		public bool boolean_value {
			get {
				// if (result_type != ResultType.BOOLEAN)
				// 	throw new XPath.Error.TYPE ("Result type is not boolean");
				return object->boolval != 0;
			}
		}

		/**
		 * Returns value for node snapshot result
		 */
		public Gee.List<Node> nodeset_value {
			get {
				// if (result_type != ResultType.ORDERED_NODE_SNAPSHOT)
				// 	throw new XPath.Error.TYPE ("Result type is not node snapshot");
				return this.nodeset;
			}
		}

		/**
		 * Returns length of node snapshot
		 */
		public int snapshot_length {
			get {
				// if (result_type != ResultType.ORDERED_NODE_SNAPSHOT)
				// 	throw new XPath.Error.TYPE ("Result type is not node snapshot");
				return this.nodeset.size;
			}
		}

		/* protected for tests */
		/**
		 * Creates XPath result from libxml2 xmlXPathObject.
		 * @param doc owner document of context node
		 * @param object XPath result object from libxml2; created object takes
		 *   responsibility of deleting it
		 * @throws XPath.Error.TYPE when result type of object is invalid
		 */
		protected Result(Document doc, Xml.XPath.Object* object)
			throws XPath.Error
			requires (object != null)
		{
			this.object = object;

			switch (object->type) {
				case Xml.XPath.ObjectType.UNDEFINED:
					throw new XPath.Error.TYPE ("Result type cannot be undefined");

				case Xml.XPath.ObjectType.NODESET:
					result_type = ResultType.ORDERED_NODE_SNAPSHOT;
					nodeset = new Gee.ArrayList<Node> ();
					for (var i = 0, l = object->nodesetval->length (); i < l; ++i)
						nodeset.add (doc.lookup_node (object->nodesetval->item (i)));
					break;

				case Xml.XPath.ObjectType.BOOLEAN:
					result_type = ResultType.BOOLEAN;
					break;
				case Xml.XPath.ObjectType.NUMBER:
					result_type = ResultType.NUMBER;
					break;
				case Xml.XPath.ObjectType.STRING:
					result_type = ResultType.STRING;
					break;

				case Xml.XPath.ObjectType.POINT:
					/* *** Not implemented *** */
					break;
				case Xml.XPath.ObjectType.RANGE:
					/* *** Not implemented *** */
					break;
				case Xml.XPath.ObjectType.LOCATIONSET:
					/* *** Not implemented *** */
					break;
				case Xml.XPath.ObjectType.USERS:
					/* *** Not implemented *** */
					break;
				case Xml.XPath.ObjectType.XSLT_TREE:
					/* *** Not implemented *** */
					break;

				default:
					throw new XPath.Error.TYPE ("Unsupported result type");
			}
		}

		/* Destructor */
		~XPathResult () {
			delete object;
		}

		/**
		 * Returns n-th node from snapshot
		 */
		public Node snapshot_item(int n) throws XPath.Error {
			if (result_type != ResultType.ORDERED_NODE_SNAPSHOT)
				throw new XPath.Error.TYPE ("Result type is not node snapshot");
			return this.nodeset[n];
		}

		/**
		 * Converts XPath result value to bool.
		 */
		public bool to_bool() {
			 return Xml.XPath.cast_to_boolean (object);
		}

		/**
		 * Converts XPath result value to number.
		 */
		public double to_number () {
			 return Xml.XPath.cast_to_number (object);
		}

		/**
		 * Converts XPath result value to string.
		 */
		public string to_string () {
			 return Xml.XPath.cast_to_string (object);
		}

	}
}
