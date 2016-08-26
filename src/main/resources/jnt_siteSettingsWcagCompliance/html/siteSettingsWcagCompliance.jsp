<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="jcr" uri="http://www.jahia.org/tags/jcr" %>
<%@ taglib prefix="s" uri="http://www.jahia.org/tags/search" %>
<%@ taglib prefix="functions" uri="http://www.jahia.org/tags/functions" %>
<%@ taglib prefix="template" uri="http://www.jahia.org/tags/templateLib" %>
<fmt:message key="label.changeSaved" var="i18nSaved"/><c:set var="i18nSaved" value="${functions:escapeJavaScript(i18nSaved)}"/>

<template:addResources type="javascript" resources="jquery.min.js,jquery.form.min.js"/>
<template:addResources>
<script type="text/javascript">
function updateSiteWcagCompliance(btn) {
	btn.attr('disabled', 'disabled');
    $('#updateSiteForm').ajaxSubmit({
        data: {'j:wcagCompliance':$('#activateWcagCompliance').is(':checked')},
        dataType: "json",
        success: function(response) {
            if (response.warn != undefined) {
                $.snackbar({
                    content: response.warn,
                    style: "warning"
                });
            } else {
                $.snackbar({
                    content: "${i18nSaved}",
                });
            }
            btn.removeAttr('disabled');
        },
        error: function() {
            btn.removeAttr('disabled');
        }
    });
}
</script>
</template:addResources>
<c:set var="site" value="${renderContext.mainResource.node.resolveSite}"/>

<c:set var="propActivated" value="${site.properties['j:wcagCompliance']}"/>

<div class="page-header">
    <h2><fmt:message key="label.htmlSettings.wcagCompliance"/> - ${fn:escapeXml(site.displayableName)}</h2>
</div>


<div class="row">
    <div class="col-md-offset-3 col-md-6">
        <div class="panel panel-default">
            <div class="panel-heading">
                <fmt:message key="label.htmlSettings.wcagCompliance.description"/>
            </div>
            <div class="panel-body">
                <form id="updateSiteForm" action="<c:url value='${url.base}${renderContext.mainResource.node.resolveSite.path}'/>" method="post">
                    <input type="hidden" name="jcrMethodToCall" value="put"/>
                    <input type="hidden" name="jcr:mixinTypes" value="jmix:htmlSettings"/>

                    <div class="togglebutton">
                        <label for="activateWcagCompliance">
                            <input type="checkbox" name="activateWcagCompliance" id="activateWcagCompliance" onclick="updateSiteWcagCompliance($(this)); return true;"${not empty propActivated && propActivated.boolean ? ' checked="checked"' : ''}/>
                            <fmt:message key="label.active"/>
                        </label>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>
