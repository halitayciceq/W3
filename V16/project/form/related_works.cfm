<cfparam name="attributes.work_head" default="">
<cfif isdefined("attributes.project_id") and len(attributes.project_id)>
	<cfquery name="GET_PROJECT_DETAIL" datasource="#DSN#">
    	SELECT PROJECT_HEAD FROM PRO_PROJECTS WHERE PROJECT_ID = #attributes.project_id#
    </cfquery>
</cfif>
<cfparam name="attributes.modal_id" default="">
<!--- <cfquery name="GET_WORK_NAME" datasource="#DSN#">
	SELECT WORK_HEAD FROM PRO_WORKS WHERE WORK_ID = #attributes.work_id#
</cfquery> --->
<cfif isdefined("attributes.rel_work") and len(attributes.rel_work)>
    <cfset work_id_list = "">
    <cfif attributes.rel_work contains(";")>
        <cfloop list="#attributes.rel_work#" delimiters=";" index="i">
        	<cfif find(" ",i) gt 0>
                <cfset work_id = left(i,find(" ",i)-3)>
            <cfelse>
                <cfset work_id = left(i,len(i)-2)>
            </cfif>
            <cfif find(" ",i) gt 0>
				<cfset "lag#work_id#" = mid(i,find(" ",i),find("days",i)-find(" ",i))><!--- Bekleme Miktarini buluyor --->
			</cfif>
            <cfset work_id_list = listappend(work_id_list,work_id,',')>
        </cfloop>
    <cfelse>
	    <cfset work_id_list = attributes.rel_work>
    </cfif>
	<cfquery name="GET_RELATED_WORKS" datasource="#DSN#">
		SELECT 
		   WORK_ID,
		   WORK_HEAD 
		FROM 
			PRO_WORKS 
		WHERE 
			WORK_ID IN (#work_id_list#)
	</cfquery>
<cfelse>
	<cfset get_related_works.recordcount=0>
</cfif>
<script>
row_count=<cfoutput>#get_related_works.recordcount#</cfoutput>;

function pencere_detail_work(no)
{
	windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=project.works&event=det&id='+no,'list');
}
function pencere_ac_work(no)
{
	windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_add_work<cfif isdefined("attributes.work_id")>&rel_workid=<cfoutput>#attributes.work_id#</cfoutput></cfif>&field_id=related_work.related_work_id' + no +'&field_name=related_work.work_head'+ no<cfif isdefined("attributes.project_id") and len(attributes.project_id)>+'&project_head=<cfoutput>#GET_PROJECT_DETAIL.PROJECT_HEAD#&project_id=#attributes.project_id#</cfoutput>'</cfif>,'list');
}
function sil(sy)
	{
		var my_element=document.getElementById('row_kontrol'+sy);
		my_element.value=0;
		var my_element=eval("frm_row"+sy);
		my_element.style.display="none";
	}

function add_row()
{
    row_count++;
    var newRow;
    var newCell;
    newRow = document.getElementById("table1").insertRow(document.getElementById("table1").rows.length);
    newRow.setAttribute("name","frm_row" + row_count);
    newRow.setAttribute("id","frm_row" + row_count);
    newRow.setAttribute("NAME","frm_row" + row_count);
    newRow.setAttribute("ID","frm_row" + row_count);
    newRow.className = 'color-row';
	document.getElementById('record_num').value = row_count;
    newCell = newRow.insertCell(newRow.cells.length);
	newCell.innerHTML = '<input type="hidden" value="" id="time_cost_id' + row_count +'" name="time_cost_id' + row_count +'"><input type="hidden" value="1" id="row_kontrol' + row_count +'" name="row_kontrol' + row_count +'"><a href="javascript://" onclick="sil(' + row_count + ');"><i class="fa fa-minus"></i></a>';
	newCell = newRow.insertCell(newRow.cells.length);
	newCell.innerHTML = '<cfoutput>#attributes.WORK_HEAD#</cfoutput>';
    newCell = newRow.insertCell(newRow.cells.length);
	<cfoutput>
	newCell.innerHTML = '<div class="form-group"><select name="work_relation_type' + row_count +'" id="work_relation_type' + row_count +'" style="width:95px;text-align:right;"><option value="FS" title="#attributes.WORK_HEAD# İsimli İş Bittiğinde İlişkili İş Başlar">Finish to Start</option><option value="SF" title="#attributes.WORK_HEAD# İsimli İşin Bitmesi İçin İlişkili İş Başlamalıdır">Start to Finish</option><option value="SS" title="#attributes.WORK_HEAD# İsimli İşin Başlaması İçin İlişkili İş Başlamalıdır">Start to Start</option><option value="FF" title="#attributes.WORK_HEAD# İsimli İşin Bitmesi İçin İlişkili İş Bitmelidir">Finish to Finish</option></select></div>';
    </cfoutput>
	newCell = newRow.insertCell(newRow.cells.length);
<cfoutput>
	newCell.innerHTML = '<div class="form-group"><div class="input-group"><input type="hidden" name="related_work_id' + row_count +'" id="related_work_id' + row_count +'" value=""><input type="text" name="work_head' + row_count +'" id="work_head' + row_count +'" value="" onFocus="AutoComplete_Create(\'work_head'+ row_count +'\',\'WORK_HEAD\',\'WORK_HEAD\',\'get_work\',\'#attributes.project_id#\',\'WORK_ID\',\'related_work_id'+ row_count +'\',\'\',3,110);" style="width:128px;">&nbsp;<span class="input-group-addon icon-ellipsis btnPointer" onClick="pencere_ac_work('+ row_count +');"></span></div></div>';
</cfoutput>	
	newCell = newRow.insertCell(newRow.cells.length);
	newCell.innerHTML = '<div class="form-group"><input type="text" name="lag' + row_count +'" id="lag' + row_count +'" value=""  onkeyup="formatcurrency(this,0);"  style="width:50px;text-align:right"></div>';
}
</script>
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
	<cf_box title="#getLang('project',64)#" popup_box="1">
	<cfform name="related_work" method="post" action="#request.self#?fuseaction=project.popup_related_works" onsubmit="newRows()">
		<cf_grid_list>
			<thead>
				<tr>
					<th width="20">
						<input name="record_num" id="record_num" type="hidden" value="<cfoutput>#get_related_works.recordcount#</cfoutput>">
						<a href="javascript://" onClick="add_row();" title="<cf_get_lang dictionary_id='57582.Ekle'>"><i class="fa fa-plus"></i></a>
					</th>
					<th><cf_get_lang dictionary_id='58445.Is'></th>
					<th><cf_get_lang dictionary_id='58830.Iliski Sekli'></th>
					<th><cf_get_lang dictionary_id='38187.Iliskili İs'></th>
					<th><cf_get_lang dictionary_id='49900.Bekleme'> (<cf_get_lang dictionary_id='57490.Gün'>)</th>
				</tr>
			</thead>
			<tbody id="table1">
				<cfif get_related_works.recordcount>
					<cfoutput query="get_related_works">
						<tr id="frm_row#currentrow#" >
							<td>
								<input type="hidden" name="time_cost_id#currentrow#" id="time_cost_id#currentrow#" value="#get_related_works.work_id#">
								<input type="hidden" name="row_kontrol#currentrow#" id="row_kontrol#currentrow#" value="1">
								<a href="javascript://" onClick="sil('#currentrow#');"><i class="fa fa-minus"></i></a>
							</td>
							<td>#attributes.WORK_HEAD#</td>
							<td>
								<cfset i = listgetat(attributes.rel_work,currentrow,';')>
								<cfif find(" ",i) gt 0>
									<cfset work_relation_type = mid(i,find(" ",i)-2,2)>
								<cfelse>
									<cfset work_relation_type = right(i,2)>
								</cfif>
								<div class="form-group">
									<select name="work_relation_type#currentrow#" id="work_relation_type#currentrow#" style="width:95px;">
										<option value="FS" title="#attributes.WORK_HEAD# İsimli İş Bittiğinde İlişkili İş Başlar" <cfif work_relation_type eq "FF">selected="selected"</cfif>>Finish to Start</option>
										<option value="SF" title="#attributes.WORK_HEAD# İsimli İşin Bitmesi İçin İlişkili İş Başlamalıdır" <cfif work_relation_type eq "SF">selected="selected"</cfif>>Start to Finish</option>
										<option value="SS" title="#attributes.WORK_HEAD# İsimli İşin Başlaması İçin İlişkili İş Başlamalıdır" <cfif work_relation_type eq "SS">selected="selected"</cfif>>Start to Start</option>
										<option value="FF" title="#attributes.WORK_HEAD# İsimli İşin Bitmesi İçin İlişkili İş Bitmelidir" <cfif work_relation_type eq "FF">selected="selected"</cfif>>Finish to Finish</option>
									</select>
								</div>
							</td>
							<td>
								<div class="form-group">
									<div class="input-group">
										<input type="hidden" name="related_work_id#currentrow#" id="related_work_id#currentrow#" value="#WORK_ID#">
										<input name="work_head#currentrow#" id="work_head#currentrow#" type="text" style="width:118px;" value="#WORK_HEAD#" onFocus="AutoComplete_Create('work_head#currentrow#','WORK_HEAD','WORK_HEAD','get_work','#attributes.project_id#','WORK_ID','related_work_id#currentrow#','','3','110')">
										<cfif len(work_id)>
											<span class="input-group-addon btnPointer" onclick="pencere_detail_work(#WORK_ID#);"><i class="fa fa-cube" title="<cf_get_lang dictionary_id='55061.is detayi'> "></i></span>
										</cfif>
										<span class="input-group-addon icon-ellipsis btnPointer" onClick="pencere_ac_work('#currentrow#');"title="<cf_get_lang dictionary_id='58691.is listesi'>" ></span>
									</div>
								</div>
							</td>
							<td>
								<div class="form-group">
									<input type="text" name="lag#currentrow#" id="lag#currentrow#" onkeyup="formatcurrency(this,0);" value="<cfif isdefined("lag#work_id#")>#trim(evaluate('lag#work_id#'))#</cfif>" class="text-right"/>
								</div>
							</td>
						</tr>
					</cfoutput>
				</cfif>
			</tbody>
		</cf_grid_list>
		<div class="ui-info-bottom flex-end">
			<cf_workcube_buttons type_format="1" is_upd='0' add_function='kontrol_et()' insert_alert='' search_function="#iif(isdefined("attributes.draggable"),DE("loadPopupBox('related_work' , #attributes.modal_id#)"),DE(""))#">				
		</div>
	</cfform>
	</cf_box>
</div>
<script type="text/javascript">
	function call(dd)
	{
		for(yy=1;yy<=dd;yy++)
		{
			add_row();
		}
	}

	var loop_count = 5-<cfoutput>#get_related_works.recordcount#</cfoutput>;
	call(loop_count);
	
	function kontrol_et()
	{
		related_work_head =";";
		related_work_name = "";
		for(yy=1;yy<=document.getElementById('record_num').value;yy++)
		{
			for(zz=1;zz<=document.getElementById('record_num').value;zz++)
			{
				if(document.getElementById('related_work_id'+yy).value == document.getElementById('related_work_id'+zz).value && yy != zz && document.getElementById('related_work_id'+yy).value != '')
				{
					alert(yy+'. Satirdaki Is '+ zz +'.Satirda Kullanilmistir !');
					return false;
				}
			}
			
			if(document.getElementById('work_head'+yy).value != "" && document.getElementById('frm_row'+yy).style.display!="none")
			{
				related_work_head = related_work_head + document.getElementById('related_work_id'+yy).value+document.getElementById('work_relation_type'+yy).value;
				related_work_name = related_work_name +  document.getElementById('work_head'+yy).value + ";";
				if(document.getElementById('lag'+yy).value != "" )
				{
					related_work_head = related_work_head + "+" + document.getElementById('lag'+yy).value + " days;";
				}
				else
				{
					related_work_head = related_work_head + ";";
				}
			}
		}
		function relationWorkDate(type,row_number)
		{
			if(document.getElementById('related_work_id'+row_number).value=='' && document.getElementById('related_work_id'+row_number).value==0)
			{
				alert("<cf_get_lang dictionary_id='38266.Önce Iliskili Is Belirlemelisiniz!'>");
				document.upd_work.work_relation_date.value='';
				return false;
			}
			if(type==1)
			{
				if(document.upd_work.relfinishdate.value != '')
				{
					document.upd_work.startdate_plan.value = date_add('d',1,document.upd_work.relfinishdate.value);
				}
				document.upd_work.finishdate_plan.value = '';
				return false;
			}
			if(type==2)
			{
				if(document.upd_work.relfinishdate.value != '')
				{
					document.upd_work.finishdate_plan.value = date_add('d',-1,document.upd_work.relstartdate.value);
				}
				document.upd_work.startdate_plan.value = '';
				return false;
			}
			if(type==3)
			{
				document.upd_work.startdate_plan.value = document.upd_work.relstartdate.value;
				document.upd_work.finishdate_plan.value = '';
				return false;
			}
			if(type==4)
			{
				document.upd_work.finishdate_plan.value = document.upd_work.relfinishdate.value;
				document.upd_work.startdate_plan.value = '';
				return false;
			}
		}
		if(related_work_head == ';')
		{
			related_work_head = '';
		}
		<cfif isdefined("attributes.draggable")>document<cfelse>window.opener.document</cfif>.getElementById('rel_work').value = related_work_head;
		<cfif isdefined("attributes.draggable")>document<cfelse>window.opener.document</cfif>.getElementById('rel_work_name').value  = related_work_name;
		<cfif not isdefined("attributes.draggable")>window.close();<cfelse>closeBoxDraggable( '<cfoutput>#attributes.modal_id#</cfoutput>' );</cfif>
		return false;
	}
</script>
