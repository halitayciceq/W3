<!--- yorumlar--->
<div class="row">
    <div class="col col-12 col-md-10 col-sm-12 border-left-no" >
        <div  class="active" id="tab_workCorrespondence">
            <cfif attributes.action_section is 'WORK_ID'>
                <cf_commentProcess action_Section="WORK_ID" action_id="#attributes.id#">
            <cfelseif attributes.action_section is 'ASSET_ID'>
                <cf_commentProcess action_Section="ASSET_ID" action_id="#attributes.id#">
            </cfif>
        </div>
    </div>			
</div>

