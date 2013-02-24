<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xlink="http://www.w3.org/1999/xlink">

	<xsl:output method="xml" indent="yes"/>

	<!--<xsl:template match="*"/>-->

	<xsl:template match="/pmc-articleset">
		<articles>
			<xsl:apply-templates select="article"/>
		</articles>
	</xsl:template>

	<xsl:template match="article">
		<article>
			<xsl:apply-templates select="front/article-meta"/>
			<xsl:apply-templates select="body//uri | body//ext-link"/>
			<xsl:apply-templates select="front/journal-meta/issn[1]"/>
		</article>
	</xsl:template>

	<xsl:template match="article-meta">
		<xsl:apply-templates select="article-id"/>
		<xsl:apply-templates select="self-uri"/>
		<xsl:apply-templates select="title-group/article-title[1]"/>
		<xsl:apply-templates select="abstract"/>
		<xsl:apply-templates select="permissions/copyright-holder"/>
		<xsl:apply-templates select="permissions/license"/>

		<xsl:apply-templates select="contrib-group/contrib[@contrib-type='author']">
			<xsl:with-param name="article-meta" select="."/>
		</xsl:apply-templates>

		<xsl:choose>
			<xsl:when test="pub-date[@pub-type='ppub']">
				<xsl:apply-templates select="pub-date[@pub-type='ppub']"/>
			</xsl:when>
			<xsl:when test="pub-date[@pub-type='epub']">
				<xsl:apply-templates select="pub-date[@pub-type='epub']"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="pub-date[1]"/>
			</xsl:otherwise>
		</xsl:choose>

		<xsl:apply-templates select="abstract//uri | abstract//ext-link"/>
	</xsl:template>

	<xsl:template match="article-id[@pub-id-type='pmc']">
		<id>
			<xsl:value-of select="."/>
		</id>
	</xsl:template>

	<xsl:template match="article-id[@pub-id-type='pmid']">
		<pmid>
			<xsl:value-of select="."/>
		</pmid>
	</xsl:template>

	<xsl:template match="article-id[@pub-id-type='doi']">
		<doi>
			<xsl:value-of select="."/>
		</doi>
	</xsl:template>

	<xsl:template match="article-id"/>

	<xsl:template match="self-uri">
		<uri>
			<xsl:value-of select="@xlink:href"/>
		</uri>
	</xsl:template>

	<xsl:template match="article-title">
		<title>
			<xsl:value-of select="normalize-space(.)"/>
		</title>
	</xsl:template>

	<xsl:template match="abstract">
		<abstract>
			<xsl:value-of select="normalize-space(.)"/>
		</abstract>
	</xsl:template>

	<xsl:template match="copyright-holder">
		<copyright>
			<xsl:value-of select="normalize-space(.)"/>
		</copyright>
	</xsl:template>

	<xsl:template match="license">
		<license>
			<xsl:value-of select="normalize-space(.)"/>
		</license>

		<xsl:if test="@xlink:href">
			<licenseURL>
				<xsl:value-of select="@xlink:href"/>
			</licenseURL>
		</xsl:if>
	</xsl:template>

	<xsl:template match="uri | ext-link">
		<link>
			<xsl:value-of select="@xlink:href"/>
		</link>
	</xsl:template>

	<xsl:template match="issn">
		<issn>
			<xsl:value-of select="."/>
		</issn>
	</xsl:template>

	<xsl:template match="contrib">
		<xsl:param name="article-meta"/>

		<author>
			<given>
				<xsl:value-of select="normalize-space(name/given-names)"/>
			</given>

			<family>
				<xsl:value-of select="normalize-space(name/surname)"/>
			</family>

			<name>
				<xsl:value-of select="normalize-space(concat(name/given-names, ' ', name/surname))"/>
			</name>

			<xsl:if test="email">
				<email>
					<xsl:value-of select="email"/>
				</email>
			</xsl:if>

			<xsl:variable name="correspid" select="xref[@ref-type='corresp']/@rid"/>

			<xsl:if test="$correspid">
				<xsl:variable name="email" select="$article-meta/author-notes/corresp[@id=$correspid]/email"/>
				<xsl:if test="count($email) = 1">
					<corresp>
				       <xsl:value-of select="$article-meta/author-notes/corresp[@id=$correspid]/email"/>
				   </corresp>
				</xsl:if>
		   </xsl:if>

			<xsl:variable name="affid" select="xref[@ref-type='aff']/@rid"/>

			<xsl:if test="$affid">
				<xsl:for-each select="../aff[@id=$affid]">
					<affiliation>
		       			<xsl:apply-templates mode="affiliation"/>
		       		</affiliation>
		       	</xsl:for-each>
		   </xsl:if>
		</author>
	</xsl:template>

	<xsl:template match="*" mode="affiliation">
		<xsl:value-of select="normalize-space(.)"/>
	</xsl:template>

	<xsl:template match="label" mode="affiliation"/>
	<xsl:template match="sup" mode="affiliation"/>

	<xsl:template match="pub-date">
		<xsl:variable name="date">
			<xsl:value-of select="year"/>

			<xsl:if test="month">
				<xsl:text>-</xsl:text>
				<xsl:if test="string-length(month) = 1">0</xsl:if>
				<xsl:value-of select="month"/>

				<xsl:if test="day">
					<xsl:text>-</xsl:text>
					<xsl:if test="string-length(day) = 1">0</xsl:if>
					<xsl:value-of select="day"/>
				</xsl:if>
			</xsl:if>
		</xsl:variable>

		<xsl:variable name="normalized-date" select="normalize-space($date)"/>

		<xsl:if test="string-length($normalized-date) > 3">
			<date>
				<xsl:value-of select="$normalized-date"/>
			</date>
		</xsl:if>
	</xsl:template>
</xsl:stylesheet>