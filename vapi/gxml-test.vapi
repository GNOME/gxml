/* Solution provided by nemequ in #vala so gxml_test can find its data
 * files even when we use "make distcheck" which doesn't copy them
 * into its _build/test/ dir, where it runs gxml_test from.  Please
 * recommend a way to copy those files if you know one so we can avoid
 * this.
 *
 * This defines a string for Vala that we can then at compile time use
 * "-X -DTEST_DIR=$(top_srcdir)/test so gxml_test can find its
 * tests, similar to how libgdata does it in C. */
namespace GXmlTestConfig {
	[CCode (cname = "TEST_DIR")]
	public const string TEST_DIR;
	[CCode (cname = "TEST_SAVE_DIR")]
	public const string TEST_SAVE_DIR;
}
