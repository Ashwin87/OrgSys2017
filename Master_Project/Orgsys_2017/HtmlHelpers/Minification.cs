//using System.Web;
//using System.Web.Mvc;

//namespace MinificationBuildEvent.HtmlHelpers
//{
//  public static class Minification
//  {
//    private const string cssPath = "/Content/Minified";
//    private const string jsPath = "/Scripts/Minified";

//    public static HtmlString MinifyJs(this HtmlHelper Html, string packageName)
//    {
//      string path = jsPath;
//      path += "/" + packageName;
//#if DEBUG
//      path += ".debug";
//#endif
//      path += ".js";
//      return new HtmlString(string.Format("<script type=\"text/javascript\" src=\"{0}\"></script>\n", Html.Encode(path)));
//    }

//    public static HtmlString MinifyCss(this HtmlHelper Html, string packageName)
//    {
//      string path = cssPath;
//      path += "/" + packageName;
//#if DEBUG
//      path += ".debug";
//#endif
//      path += ".css";
//      return new HtmlString(string.Format("<link rel=\"stylesheet\" type=\"text/css\" href=\"{0}\">\n", Html.Encode(path)));
//    }
//  }
//}