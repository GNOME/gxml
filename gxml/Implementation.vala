/* -*- Mode: vala; indent-tabs-mode: t; c-basic-offset: 8; tab-width: 8 -*- */

namespace GXml.Dom {
	public class Implementation {
		internal Implementation () {
		}

		public bool has_feature (string feature, string? version) {
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
