<p:library version="1.0"
           xmlns:cx="http://xmlcalabash.com/ns/extensions"
           xmlns:p="http://www.w3.org/ns/xproc"
           xmlns:pxf="http://exproc.org/proposed/steps/file"
           xmlns:run="tag:maus@hab.de,2018:xproc-xspec"
           xmlns:xspec="http://www.jenitennison.com/xslt/xspec">

  <p:declare-step name="xspec-xslt" type="run:xspec-xslt">

    <p:option name="XSpecHome" required="true"/>

    <p:input  port="source" primary="true" sequence="false"/>
    <p:output port="result" primary="true" sequence="false"/>

    <p:load name="load-compiler">
      <p:with-option name="href" select="resolve-uri('src/compiler/generate-xspec-tests.xsl', $XSpecHome)"/>
    </p:load>

    <p:load name="load-reporter">
      <p:with-option name="href" select="resolve-uri('src/reporter/format-xspec-report.xsl', $XSpecHome)"/>
    </p:load>

    <p:xslt name="compile">
      <p:input port="source">
        <p:pipe port="source" step="xspec-xslt"/>
      </p:input>
      <p:input port="stylesheet">
        <p:pipe port="result" step="load-compiler"/>
      </p:input>
      <p:input port="parameters">
        <p:empty/>
      </p:input>
    </p:xslt>

    <p:xslt name="run" template-name="xspec:main">
      <p:input port="source">
        <p:empty/>
      </p:input>
      <p:input port="stylesheet">
        <p:pipe step="compile" port="result"/>
      </p:input>
      <p:input port="parameters">
        <p:empty/>
      </p:input>
    </p:xslt>

    <p:xslt name="report">
      <p:input port="source">
        <p:pipe step="run" port="result"/>
      </p:input>
      <p:input port="stylesheet">
        <p:pipe step="load-reporter" port="result"/>
      </p:input>
      <p:input port="parameters">
        <p:empty/>
      </p:input>
    </p:xslt>

  </p:declare-step>

  <p:declare-step name="compile-schematron" type="run:compile-schematron">
    <p:input  port="source" primary="true" sequence="false"/>
    <p:output port="result" primary="true" sequence="false"/>

    <p:option name="SchematronXsltInclude" required="true"/>
    <p:option name="SchematronXsltExpand"  required="true"/>
    <p:option name="SchematronXsltCompile" required="true"/>

    <p:load name="load-include">
      <p:with-option name="href" select="$SchematronXsltInclude"/>
    </p:load>

    <p:load name="load-expand">
      <p:with-option name="href" select="$SchematronXsltExpand"/>
    </p:load>

    <p:load name="load-compile">
      <p:with-option name="href" select="$SchematronXsltCompile"/>
    </p:load>

    <p:xslt name="include">
      <p:input port="source">
        <p:pipe step="compile-schematron" port="source"/>
      </p:input>
      <p:input port="stylesheet">
        <p:pipe step="load-include" port="result"/>
      </p:input>
      <p:input port="parameters">
        <p:empty/>
      </p:input>
    </p:xslt>

    <p:xslt name="expand">
      <p:input port="source">
        <p:pipe step="include" port="result"/>
      </p:input>
      <p:input port="stylesheet">
        <p:pipe step="load-expand" port="result"/>
      </p:input>
      <p:input port="parameters">
        <p:empty/>
      </p:input>
    </p:xslt>

    <p:xslt name="compile">
      <p:input port="source">
        <p:pipe step="expand" port="result"/>
      </p:input>
      <p:input port="stylesheet">
        <p:pipe step="load-compile" port="result"/>
      </p:input>
      <p:input port="parameters">
        <p:empty/>
      </p:input>
    </p:xslt>
  </p:declare-step>

  <p:declare-step name="xspec-schematron" type="run:xspec-schematron">

    <p:input  port="source" primary="true" sequence="false"/>

    <p:output port="result" primary="true" sequence="false">
      <p:pipe step="run" port="result"/>
    </p:output>

    <p:option name="XSpecHome" required="true"/>

    <p:option name="SchematronXsltInclude" select="resolve-uri('src/schematron/iso-schematron/iso_dsdl_include.xsl', $XSpecHome)"/>
    <p:option name="SchematronXsltExpand" select="resolve-uri('src/schematron/iso-schematron/iso_abstract_expand.xsl', $XSpecHome)"/>
    <p:option name="SchematronXsltCompile" select="resolve-uri('src/schematron/iso-schematron/iso_svrl_for_xslt2.xsl', $XSpecHome)"/>

    <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>

    <p:variable name="compiledSchematronUri" select="resolve-uri(concat(/xspec:description/@schematron, '.xsl'), base-uri(/))"/>

    <p:load name="load-schematron-compiler">
      <p:with-option name="href" select="resolve-uri('src/schematron/schut-to-xspec.xsl', $XSpecHome)"/>
    </p:load>

    <p:load name="load-schematron">
      <p:with-option name="href" select="resolve-uri(/xspec:description/@schematron, base-uri(/))">
        <p:pipe step="xspec-schematron" port="source"/>
      </p:with-option>
    </p:load>

    <run:compile-schematron name="compile-schematron">
      <p:with-option name="SchematronXsltInclude" select="$SchematronXsltInclude"/>
      <p:with-option name="SchematronXsltExpand" select="$SchematronXsltExpand"/>
      <p:with-option name="SchematronXsltCompile" select="$SchematronXsltCompile"/>
      <p:input port="source">
        <p:pipe step="load-schematron" port="result"/>
      </p:input>
    </run:compile-schematron>

    <p:store name="store-compiled-schematron" method="xml">
      <p:with-option name="href" select="$compiledSchematronUri"/>
      <p:input port="source">
        <p:pipe step="compile-schematron" port="result"/>
      </p:input>
    </p:store>

    <p:xslt name="compile-xspec">
      <p:with-param name="stylesheet" select="$compiledSchematronUri"/>
      <p:with-param name="test_dir" select="resolve-uri('xspec', $compiledSchematronUri)"/>
      <p:input port="stylesheet">
        <p:pipe step="load-schematron-compiler" port="result"/>
      </p:input>
      <p:input port="source">
        <p:pipe step="xspec-schematron" port="source"/>
      </p:input>
    </p:xslt>

    <p:for-each name="store-context">
      <p:iteration-source select="/*">
        <p:pipe step="compile-xspec" port="secondary"/>
      </p:iteration-source>
      <p:store method="xml">
        <p:with-option name="href" select="base-uri(/)"/>
      </p:store>
    </p:for-each>

    <run:xspec-xslt cx:depend-on="store-compiled-schematron store-context" name="run">
      <p:with-option name="XSpecHome" select="$XSpecHome"/>
      <p:input port="source">
        <p:pipe step="compile-xspec" port="result"/>
      </p:input>
    </run:xspec-xslt>

    <pxf:delete recursive="true" fail-on-error="false" cx:depend-on="run">
      <p:with-option name="href" select="resolve-uri('xspec', $compiledSchematronUri)"/>
    </pxf:delete>

    <pxf:delete recursive="false" fail-on-error="false" cx:depend-on="run">
      <p:with-option name="href" select="$compiledSchematronUri"/>
    </pxf:delete>

  </p:declare-step>

</p:library>