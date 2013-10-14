/* -*- Mode: vala; indent-tabs-mode: t; c-basic-offset: 8; tab-width: 8 -*- */
/* XPathExpression.vala
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
	 * Represents compiled XPath expression. Such expression can be then evaluated
	 * multiple times over one or multiple documents.
	 */
	public class Expression : Object {

		internal Xml.XPath.CompExpr* expression;

		/**
		 * Object used to resolve namespace prefixes in XPath expressions.
		 */
		public NSResolver ns_resolver;

		/**
		 * Creates compiled XPath expression from string with specified namespace
		 * resolver.
		 * @throws XPath.Error when provided expression is invalid XPath
		 */
		public Expression (string expr, NSResolver? ns_resolver = null) throws XPath.Error {
			expression = Xml.XPath.compile(expr);
			if (expression == null)
				throw new XPath.Error.INVALID_EXPRESSION (xml_error_msg ());
			this.ns_resolver = ns_resolver;
		}

		/* Destructor */
		~Expression () {
			delete expression;
		}

		/**
		 * Evaluates XPath expression over DOM node and returns XPath.Result object.
		 * @param context_node context node for the evaluation of this XPath expression
		 * @param res_type type to cast resulting value to
		 * @return XPath.Result object containing result type and value
		 * @throws DomError when node type is not supported as context of evaluation
		 * @throws XPath.Error when supplied with invalid XPath expression
		 */
		public Result evaluate (Node context_node,
			ResultType res_type = ResultType.ANY) throws XPath.Error, DomError
		{
			Document doc = (context_node is Document) ? (Document) context_node : context_node.owner_document;
			doc.sync_dirty_elements ();

			Xml.XPath.Context context = new Xml.XPath.Context (doc.xmldoc);

			/* Node types supported by XPath are: Document, Element, Attribute, Text,
			 * CDATASection, Comment, ProcessingInstruction and XPathNamespace.
			 * BackedNode covers Document, Element, Comment, Text and CDATASection.
			 */
			if (context_node is BackedNode) {
				context.node = ((BackedNode) context_node).node;
			}
			else if (context_node is Attr) {
				context.node = (Xml.Node *) ((Attr) context_node).node;
			}
			/* Not implemented */
			// else if (context_node is XPath.Namespace) {
			//  dunno
			// 	context.node = (Xml.Node *) ((Namespace) context_node).node;
			// }
			else if (context_node is ProcessingInstruction) {
				/* There is no Xml.Node* field in ProcessingInstruction implementation */
				throw new DomError.NOT_SUPPORTED("Not implemented");
			}

			if (ns_resolver != null)
				foreach (var entry in ns_resolver.entries) {
					if (entry.key == null || entry.value == null)
						throw new XPath.Error.INVALID_EXPRESSION ("Namespace prefix " +
							"and/or URI cannot be null");
					if (entry.key == "" || entry.value == "")
						throw new XPath.Error.INVALID_EXPRESSION ("Namespace prefix " +
							"and/or URI cannot be empty strings");
					if (context.register_ns (entry.key, entry.value) == -1)
						throw new XPath.Error.INVALID_EXPRESSION (xml_error_msg ());
				}

			Xml.XPath.Object* xml_result = context.compiled_eval (expression);
			if (xml_result == null)
				throw new XPath.Error.INVALID_EXPRESSION (xml_error_msg ());
			Result result = new Result (doc, xml_result);

			if (res_type != ResultType.ANY) {
				/* *** Not implemented *** */
				// result.cast(res_type)
			}

			return result;
		}

	}
}
