XProc XSpec
==

Run XSpec XSLT and XSpec Schematron in an XProc pipeline.

Usage
--

Import the step library into your pipeline. 

### run:xspec-xslt

```xproc
<p:declare-step type="run:xspec-xslt">

  <p:input  port="source" primary="true" sequence="false"/> <!-- XSpec test case -->
  <p:output port="result" primary="true" sequence="false"/> <!-- XSpec report -->
  <p:option name="XSpecHome" required="true"/>              <!-- URI of the XSpec library -->

</p:declare-step>
```

### run:xspec-schematron

This step depends on the XProc extension step [pxf:delete](http://exproc.org/proposed/steps/fileutils.html) and the Calabash extension attribute [cx:depend-on](http://xmlcalabash.com/docs/reference/extattr.html#cx-depends-on). The URIs of the Schematron compiler default to the [Schematron "skeleton" XSLT implementation](https://github.com/Schematron/schematron) installed in ```$XSpecHome/src/schematron/iso-schematron```.

```xproc
<p:declare-step type="run:xspec-schematron">

  <p:input  port="source" primary="true" sequence="false"/>  <!-- XSpec test case -->
  <p:output port="result" primary="true" sequence="false"/>  <!-- XSpec report -->

  <p:option name="XSpecHome" required="true"/>               <!-- URI of the XSpec library -->
  <p:option name="SchematronXsltInclude"/>                   <!-- URI of Schematron compiler, phase include XSLT -->
  <p:option name="SchematronXsltExpand"/>                    <!-- URI of Schematron compiler, phase expand XSLT -->
  <p:option name="SchematronXsltCompile"/>                   <!-- URI of Schematron compiler, phase compile XSLT -->

</p:declare-step>

```

### run:compile-schematron

This helper compiles the Schematron arriving at the primary input port `source` by subsequently applying the XSL templates `SchematronXsltInclude`, `SchematronXsltExpand`, and `SchematronXsltCompile`.

```xproc
<p:declare-step name="compile-schematron" type="run:compile-schematron">
  <p:input  port="source" primary="true" sequence="false"/>  <!-- Schematron -->
  <p:output port="result" primary="true" sequence="false"/>  <!-- Compiled XSLT -->

  <p:option name="SchematronXsltInclude" required="true"/>   <!-- URI of Schematron compiler, phase include XSLT -->
  <p:option name="SchematronXsltExpand"  required="true"/>   <!-- URI of Schematron compiler, phase expand XSLT -->
  <p:option name="SchematronXsltCompile" required="true"/>   <!-- URI of Schematron compiler, phase compile XSLT -->
</p:declare-step>

```

## License

XProc XSpec is Copyright (C) 2018 by David Maus and released under the MIT License.
