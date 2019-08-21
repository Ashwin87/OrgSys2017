Enter the following (or equivalent) into your Post-build event command line of the web project.
This will ensure that after a build event, your LESS files get compiled to CSS files, and your packages are generated.

if $(ConfigurationName) == Debug exit
"$(SolutionDir)packages\DotLessMinification.0.42.1\Tools\dotless.Compiler.exe" "$(ProjectDir)Content\*.less"
"$(SolutionDir)packages\DotLessMinification.0.42.1\Tools\minify2.exe" -input "$(ProjectDir)App_Data\DotLessMinification\js.packages.xml" -base "$(ProjectDir)\" -output Scripts\Minified
"$(SolutionDir)packages\DotLessMinification.0.42.1\Tools\minify2.exe" -input "$(ProjectDir)App_Data\DotLessMinification\css.packages.xml" -base "$(ProjectDir)\" -output Content\Minified
"$(SolutionDir)packages\DotLessMinification.0.42.1\Tools\minify2.exe" -debug -input "$(ProjectDir)App_Data\DotLessMinification\js.packages.xml" -base "$(ProjectDir)\" -output Scripts\Minified
"$(SolutionDir)packages\DotLessMinification.0.42.1\Tools\minify2.exe" -debug -input "$(ProjectDir)App_Data\DotLessMinification\css.packages.xml" -base "$(ProjectDir)\" -output Content\Minified



To use in an ASP.NET forms project, use:
<%: Html.MinifyCss("global") %>
<%: Html.MinifyJs("global") %>

or, in razor syntax:

@Html.MinifyCss("global")
@Html.MinifyJs("global")






Questions, comments, feature requests?
lukas@q42.nl :)





More information on the used Minify2:


-- Contents --
minify2.exe
AjaxMin.exe (v 4.0)
AjaxMin.dll (v 4.0)

-- Parameters --
[-debug]
[-ie6]
-input PATHTOXML
- base BASEDIR
-output OUTPUTDIR

PATHTOXML: Absoluut pad naar een package.xml file (hoeft niet in je www-root te staan, mag wel).
           -input PATHTOXML mag meedere keren worden opgegeven. De xml files worden gemerged!
           
BASEDIR:   Pad naar je www-root
OUTPUTDIR: Relatief pad naar de directory waar geminify'de files komen. 
           BASEDIR wordt gebruikt als rootdir.

-ie6:      Deze optie is alleen te gebruiken icm CSS files. De CSS files worden gestript op child selectors ">"
           Alle gt ">" in een css file worden vervangen met een spatie " "

-debug:    Ipv minify'en wordt er een javascript bestand (ook in geval van CSS) weggeschreven met daarin:
           JS: document.write('<script type="text/javascript" src="{0}"></script>');
           CSS: document.write('<link rel="stylesheet" type="text/css" href="{0}">');

-- Output filename --
Files worden weggeschreven in BASEDIR\OUTPUTDIR\$packagename.$ext
Bij -ie6: $packagename => $packagename + '.ie6'
Bij -debug: $packagename => $packagename + '.debug'
Bij -debug & CSS: $ext => '.css.js'

Er worden nooit files weggegooid, wel overschreven.

-- Buildevent installeren --
Hang minify2.exe binnen je solution folder (zet de AjaxMin map naast de exe).
Open de property view van je web project in visual studio.
Op het tabje "Build Events", event de "POST-build even command line:" waarde naar iets als dit:

 "$(SolutionDir)tools\minify2.exe" -input "$(ProjectDir)App_Data\minify\js.packages.xml" -base "$(ProjectDir)\" -output js\minify
 "$(SolutionDir)tools\minify2.exe" -input "$(ProjectDir)App_Data\minify\css.packages.xml" -base "$(ProjectDir)\" -output css\minify
 "$(SolutionDir)tools\minify2.exe" -debug -input "$(ProjectDir)App_Data\minify\js.packages.xml" -base "$(ProjectDir)\" -output js\minify-debug
 "$(SolutionDir)tools\minify2.exe" -debug -input "$(ProjectDir)App_Data\minify\css.packages.xml" -base "$(ProjectDir)\" -output css\minify-debug

 IMPORTANT vergeet niet quotjes om je filenames heen, voor het geval er een spatie in staat
           $(ProjectDir) eindigt met een \, die escaped dus de " die er na komt. Vandaar de \ achter $(ProjectDir)!

 
Het is niet verplict om App_Data te gebruiken, je kan de xml net zo goed buiten je webroot houden. Makkelijk is het wel!
In dit voorbeeld zie je dat er alleen maar backslashes worden gebruikt.

-- Inchecken? --
Niet nodig, iederen kan de files builden als hij/zij de solution uitcheckt en netjes build.
Directory's worden gecreate waar nodig.

-- Include in project --
Ja, althans de final geminify'de files (dus niet de .debug files). 
Je kan voor het gemak de -debug minify files in een aparte dir laten zetten (zoals in het voorbeeld)

-- Package xml --
Ziet er zo uit:
<packages>
  <package name="global">
    <add path="/css/base.css"/>
    <add path="/css/base2.css"/>
  </package>
  
  <package name="global2">
    <include name="global"/>
    <add path="/css/base3.css"/>
  </package>
  
  <package name="core">
    <add path="/js/app.js"/>
  </package>
</package>

Zorg ervoor dat:
* path's met een forward slash beginnen, dus relatief aan je www-root
* je geen cycles maakt, de tool detecteert dat overigens netjes ;)

-- In je HTML hangen --
Niet zo moeilijk je weet waar de files terecht komen, toch?
Anyway, een aantal tips:
<config>/<system.web>/<compilation debug="true"> is uit te lezen in ASPX en in C#:
ASPX: <% #if DEBUG %> ... <% #endif %>
C#:   Html.ViewContext.HttpContext.IsDebuggingEnabled