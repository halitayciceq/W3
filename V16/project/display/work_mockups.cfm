<cfset model = createObject("component","WDO.catalogs.designers.mockupdesigner.model") />
<cfset getByWorkId = model.getByWorkId( work_id: attributes.work_id ) />

<cf_flat_list>
    <thead>
        <tr>
            <th><cf_get_lang dictionary_id='57487.No'></th>
            <th><cf_get_lang dictionary_id='61326.Mockup'></th>
            <th><cf_get_lang dictionary_id='55065.Tasarlayan'></th>
            <th><cf_get_lang dictionary_id='57627.Kayıt Tarihi'></th>
            <th><cf_get_lang dictionary_id='36234.Güncelleme Tarihi'></th>
            <th class="text-right"><i class="fa fa-eye"></i></th>
            <th class="text-right"><i class="fa fa-pencil"></i></th>
        </tr>
    </thead>
    <tbody>
        <cfif getByWorkId.recordcount>
            <cfoutput query = "getByWorkId">
                <tr>
                    <td>#currentrow#</td>
                    <td><a href="#request.self#?fuseaction=dev.mockup&event=upd&id=#MOCKUP_ID#&work_id=#attributes.work_id#" target="_blank">#MOCKUP_NAME#</a></td>
                    <td>#EMPLOYEE_FULL_NAME#</td>
                    <td>#dateformat(RECORD_DATE,dateformat_style)#</td>
                    <td>#dateformat(UPDATE_DATE,dateformat_style)#</td>
                    <td class="text-right"><a href="#request.self#?fuseaction=dev.mockup&event=det&id=#MOCKUP_ID#&work_id=#attributes.work_id#" target="_blank"><i class="fa fa-eye"></i></a></td>
                    <td class="text-right"><a href="#request.self#?fuseaction=dev.mockup&event=upd&id=#MOCKUP_ID#&work_id=#attributes.work_id#" target="_blank"><i class="fa fa-pencil"></i></a></td>
                </tr>
            </cfoutput>
        <cfelse>
            <tr>
                <td colspan = "8"><cf_get_lang dictionary_id='57484.Kayıt Yok'></td>
            </tr>
        </cfif>
    </tbody>
</cf_flat_list>