/* -*- Mode: vala; indent-tabs-mode: t; c-basic-offset: 8; tab-width: 8 -*- */

namespace GXml.Dom {
	/**
	 * Describes the features available in this
	 * implementation. This can be accessed from a Document
	 * object. Provided a possible feature and the feature's
	 * version, it can tell the client whether it is here
	 * implemented.
	 * For more, see: [[http://www.w3.org/TR/DOM-Level-1/level-one-core.html#ID-102161490]]
	 */
	public class Implementation {
		internal Implementation () {
		}

		/**
		 * Reports whether we support a feature at a given version level.
		 *
		 * @param feature A feature we might support, usually something like 'xml' or 'html'.
		 * @param version A possible version of the feature, or null if any version will do.
		 *
		 * @return true if we support the specified feature, false otherwise.
		 */
		public bool has_feature (string feature, string? version = null) {
			/* Level 1 is limited to "xml" and "html" (icase) */
			switch (feature) {
			case "xml": // TODO find better way to handle case insensitivity
			case "XML":
				switch (version) {
				case null:
				case "1.0":
					return true;
				default:
					return false;
				}
			case "html":
			case "HTML":
				// TODO: do we support HTML?
			default:
				return false;
			}
		}
	}
}
