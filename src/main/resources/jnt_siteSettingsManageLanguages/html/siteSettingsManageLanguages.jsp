<%@ page import="org.jahia.services.render.Resource,
                 org.jahia.utils.LanguageCodeConverters" %>
<%@ page import="org.jahia.services.content.decorator.JCRSiteNode" %>
<%@ page import="java.util.*" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="functions" uri="http://www.jahia.org/tags/functions" %>
<%@ taglib prefix="jcr" uri="http://www.jahia.org/tags/jcr" %>
<%@ taglib prefix="s" uri="http://www.jahia.org/tags/search" %>
<%@ taglib prefix="template" uri="http://www.jahia.org/tags/templateLib" %>
<c:set var="site" value="${renderContext.mainResource.node.resolveSite}"/>
<c:set var="uiLocale" value="${renderContext.UILocale}"/>
<c:set var="siteKey" value="${site.name}"/>
<c:set var="installedModules" value="${site.installedModules}"/>
<c:set var="templatePackageName" value="${site.templatePackageName}"/>

<template:addResources type="javascript" resources="jquery.min.js"/>
<template:addResources type="javascript" resources="managesites.js"/>
<template:addResources type="javascript" resources="jquery.form.min.js"/>

<script type="text/javascript">

    var defaultLang;
    var mandatoryLanguages;
    var inactiveLanguages;
    var inactiveLiveLanguages;

    function removeAll(src, remove) {
      for (var i = 0; i < remove.length; i++) {
          if (src.indexOf(remove[i]) >= 0) {
              src.splice(src.indexOf(remove[i]), 1);
          }
      }
      return src;
    }

    function updateSite() {
        showLoading();
        inactiveLiveLanguages = inactiveLiveLanguages.concat($("#updateSiteForm #language_list").fieldValue());
        currentLocale = '${currentResource.locale}';

        var data = {
            'j:languages': $("#updateSiteForm [name='activeLanguages']").fieldValue().concat(defaultLang != currentLocale ? [defaultLang,currentLocale] : defaultLang).concat($("#updateSiteForm #language_list").fieldValue()),
            'j:mandatoryLanguages': (mandatoryLanguages.length == 0) ? ['jcrClearAllValues'] : mandatoryLanguages,
            'j:inactiveLanguages': (inactiveLanguages.length == 0) ? ['jcrClearAllValues'] : inactiveLanguages,
            'j:inactiveLiveLanguages': (inactiveLiveLanguages.length == 0) ? ['jcrClearAllValues'] : inactiveLiveLanguages,
            'j:mixLanguage': $("#mixLanguages").prop('checked'),
            'j:allowsUnlistedLanguages': $("#allowsUnlistedLanguages").prop('checked')
        };
        $('#updateSiteForm').ajaxSubmit({
            data: data,
            dataType: "json",
            success: function(response) {
                hideLoading();
                if (response.warn != undefined) {
                    alert(response.warn);
                }
                // Always reload the full page to reload the language switchers
                top.location.reload();
            },
            error: function(response) {
                hideLoading();
            }
        });
        return true;
    }

    function updateBoxes() {
        $("#updateSiteForm input").enable(true);

        defaultLang = $("#updateSiteForm [name='j:defaultLanguage']").fieldValue()[0]
        $("#updateSiteForm [name='activeLanguages'][value='"+defaultLang+"']").enable(false);
        $("#updateSiteForm [name='activeLiveLanguages'][value='"+defaultLang+"']").enable(false);

        inactiveLanguages = removeAll($("#updateSiteForm [name='allLanguages']").fieldValue(), $("#updateSiteForm [name='activeLanguages']").fieldValue());
        inactiveLiveLanguages = removeAll($("#updateSiteForm [name='allLanguages']").fieldValue(), $("#updateSiteForm [name='activeLiveLanguages']").fieldValue());
        inactiveLanguages = removeAll(inactiveLanguages, [defaultLang]);
        inactiveLiveLanguages = removeAll(inactiveLiveLanguages, [defaultLang]);

        $.each(inactiveLanguages, function(i,v) {
            $("#updateSiteForm [type='checkbox'][value='"+v+"']").enable(false);
            $("#updateSiteForm [name='activeLanguages'][value='"+v+"']").enable(true);
        })
        $.each(inactiveLiveLanguages, function(i,v) {
            $("#updateSiteForm [name='j:defaultLanguage'][value='"+v+"']").enable(false);
        })

        mandatoryLanguages = $("#updateSiteForm [name='mandatoryLanguages']").fieldValue();
//

        $("#updateSiteForm [name='activeLanguages'][value='${currentResource.locale}']").enable(false);
        mix = $("#mixLanguages").prop("checked");
        $("#allowsUnlistedLanguages").prop("disabled", !mix);
    }

    $(document).ready(function() {
        updateBoxes();
    })

</script>

<h2><fmt:message key="siteSettings.label.manageLanguages"/> - ${fn:escapeXml(site.displayableName)}</h2>

<%
    JCRSiteNode site = (JCRSiteNode) pageContext.getAttribute("site");
    Resource r = (Resource) request.getAttribute("currentResource");
    final Locale currentLocale = (Locale) pageContext.getAttribute("uiLocale");
    Set<Locale> siteLocales = new TreeSet<Locale>(new Comparator<Locale>() {
        public int compare(Locale o1, Locale o2) {
            return o1.getDisplayName(currentLocale).compareTo(o2.getDisplayName(currentLocale));
        }
    });
    siteLocales.addAll(site.getLanguagesAsLocales());
    siteLocales.addAll(site.getInactiveLanguagesAsLocales());

    request.setAttribute("siteLocales", siteLocales);

    request.setAttribute("availableLocales", LanguageCodeConverters.getSortedLocaleList(currentLocale));
%>


<form id="updateSiteForm" action="<c:url value='${url.base}${renderContext.mainResource.node.resolveSite.path}'/>" method="post">
    <input type="hidden" name="jcrMethodToCall" value="put"/>
    <input type="hidden" name="jcrRedirectTo" value="<c:url value='${url.base}${renderContext.mainResource.node.path}'/>"/>
    <table class="table table-bordered table-striped table-hover" >
        <thead>
        <tr>
            <th><fmt:message key="siteSettings.label.language"/></th>
            <th><fmt:message key="siteSettings.label.language.default"/></th>
            <th><fmt:message key="siteSettings.label.language.mandatory"/></th>
            <th><fmt:message key="siteSettings.label.language.active.edit"/></th>
            <th><fmt:message key="siteSettings.label.language.active.live"/></th>
        </tr>
        </thead>
        <tbody>
        <c:forEach var="locale" items="${siteLocales}" varStatus="status">
            <tr>
                <td><c:set var="langAsString">${locale}</c:set>
                    <input type="hidden" name="allLanguages" value="${locale}" class="language"/>
                    <%= ((Locale) pageContext.getAttribute("locale")).getDisplayName(currentLocale)%> (${locale})</td>
                <td><input type="radio" name="j:defaultLanguage" value="${locale}" onchange="updateBoxes()"
                           <c:if test="${site.defaultLanguage eq locale}">checked="checked"</c:if> /></td>
                <td><input type="checkbox" name="mandatoryLanguages" value="${locale}"  onchange="updateBoxes()"
                           <c:if test="${functions:contains(site.mandatoryLanguages, langAsString)}">checked="checked"</c:if>/></td>
                <td><input type="checkbox" name="activeLanguages" value="${locale}"  onchange="updateBoxes()"
                           <c:if test="${functions:contains(site.languages, langAsString)}">checked="checked"</c:if>/></td>
                <td><input type="checkbox" name="activeLiveLanguages" value="${locale}" onchange="updateBoxes()"
                           <c:if test="${functions:contains(site.activeLiveLanguages, langAsString)}">checked="checked"</c:if>/></td>
            </tr>
        </c:forEach>
        </tbody>
    </table>


   <label for="mixLanguages" class="checkbox">
 <input type="checkbox" name="mixLanguage" id="mixLanguages" value="true"${site.mixLanguagesActive ? ' checked="checked"' : ''} onchange="updateBoxes()"/> &nbsp;<fmt:message
            key="siteSettings.locale.mixLanguages"/>
</label>


    <label class="checkbox" for="allowsUnlistedLanguages">
<input type="checkbox" name="allowsUnlistedLanguages" id="allowsUnlistedLanguages" value="true"${site.allowsUnlistedLanguages ? ' checked="checked"' : ''} />&nbsp;<fmt:message
            key="siteSettings.locale.allowsUnlistedLanguages"/>
</label>
      <hr/>

       <h2><fmt:message key="siteSettings.locale.addLanguages"/></h2>

        <h3><fmt:message key="siteSettings.locale.availableLanguages"/></h3>
        <select name="language_list" id="language_list" multiple="multiple" size="10">
            <c:forEach var="locale" items="${availableLocales}">
                <c:set var="langAsString">${locale}</c:set>
                <c:if test="${not functions:contains(siteLocales, locale)}">
                <option value="${locale}"><%= ((Locale) pageContext.getAttribute("locale")).getDisplayName(currentLocale)%> (${locale})</option>
                </c:if>
            </c:forEach>
        </select>

    <button class="btn btn-primary" type="button" id="updateSite_button" onclick="updateSite()"><i class="icon-plus-sign icon-white"></i> <fmt:message key="label.submit"/></button>

</form>

<div style="display:none;" class="loading">
    <div class="alert alert-info">
        <strong><fmt:message key="label.workInProgressTitle"/></strong>
    </div>
</div>
