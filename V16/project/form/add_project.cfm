<cfsetting showdebugoutput="no">
<cf_xml_page_edit fuseact="project.addpro">
<cfscript>
	CreateCompenent = createObject("component", "/V16/workdata/get_branches");
	get_branches = CreateCompenent.get_branches_fnc(is_comp_branch : 1, is_pos_branch: 1);
</cfscript>

<cfif isdefined("attributes.opp_id") and len(attributes.opp_id)>
	<cfquery name="GET_OPP" datasource="#DSN3#">
		SELECT PARTNER_ID,CONSUMER_ID,COMPANY_ID FROM OPPORTUNITIES WHERE OPP_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.opp_id#">
	</cfquery>
	<cfset attributes.partner_id = get_opp.partner_id>
	<cfset attributes.consumer_id = get_opp.consumer_id>
	<cfset attributes.company_id = get_opp.company_id>
</cfif>
<cfif isdefined("attributes.partner_id") and len(attributes.partner_id)><!--- Eğer Kurumsal Üye detayından proje ekleniyorsa cari bilgileri seçili olarak gelsin. --->
	<cfquery name="GET_PARTNER" datasource="#DSN#">
		SELECT 
			CP.PARTNER_ID,
			CP.COMPANY_PARTNER_NAME,
			CP.COMPANY_PARTNER_SURNAME,
			C.COMPANY_ID,
			C.NICKNAME			
		FROM 
			COMPANY_PARTNER CP,
			COMPANY C
		WHERE 
			CP.PARTNER_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.partner_id#"> AND 
			CP.COMPANY_ID = C.COMPANY_ID
	</cfquery>
<cfelseif isdefined("attributes.consumer_id") and len(attributes.consumer_id)>
	<cfquery name="GET_CONSUMER" datasource="#DSN#">
		SELECT CONSUMER_ID, CONSUMER_NAME, CONSUMER_SURNAME FROM CONSUMER WHERE CONSUMER_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.consumer_id#">
	</cfquery>
</cfif>
<cfset cmp = createObject("component","V16.settings.cfc.setupCountry") />
<cfset get_country = cmp.getCountry()>


<cfset project_head = "">
<cfif isDefined("camp_id") and len(camp_id)>
	<cfinclude template="../../campaign/query/get_campaign.cfm">
	<cfset project_head = campaign.camp_head>
</cfif>
<cf_catalystHeader>
<cf_box id="FormAddProject_" >
    <cf_box_data asname="data_workgroups" function="V16.project.cfc.project:GET_WORKGROUPS">
    <cf_box_data asname="data_priorty" function="V16.project.cfc.project:GET_PRIORITY"> 
    <cf_box_data asname="data_branches" function="V16.project.cfc.project:get_branches_fnc"> 
    <cf_box_data asname="data_zones" function="V16.project.cfc.project:GET_ZONES"> 
    <cf_box_data asname="get_special" function="V16.project.cfc.project:get_special_def">
    <cfform name="add_project_form" method="post" action="#request.self#?fuseaction=project.emptypopup_add_pro">
        <cfif isdefined("attributes.opp_id") and len(attributes.opp_id)>
            <input type="hidden" name="opp_id" id="opp_id" value="<cfoutput>#attributes.opp_id#</cfoutput>">
        </cfif>
        <!--- bu hidden parametresini silmeyiniz display ve action file dosyalarında gerekli kontroller icin kullanilmaktadır.--->
        <input type="hidden" name="is_control" id="is_control" value="" />
        <cf_box_elements>
            <div class="col col-6 col-md-6 col-sm-6 col-xs-12" type="column" index="1" sort="true">
                <cf_duxi label='57486' name="process_cat" hint="kategori"><cf_workcube_main_process_cat main_process_cat='' slct_width='150' ></cf_duxi>  
                <cf_duxi  name="process_stage" label="58859" hint="süreç">
                    <cf_workcube_process is_upd='0' process_cat_width='150' is_detail='0'>
                </cf_duxi>   
                <cf_duxi type="hidden" name="dictionary_id" id="dictionary_id">
                <cfif xml_project_name_autocomplete eq 1>
                    <cf_duxi name="project_head" type="text" onchange="dictionary_id.value='';" data="" hint="proje adı" icon="icon-book btnPointer" icon_boxhref="#request.self#?fuseaction=settings.popup_list_lang_settings&is_use_send&lang_dictionary_id=add_project_form.dictionary_id&lang_item_name=add_project_form.project_head"  label="38244" required="yes" onFocus="AutoComplete_Create('PROJECT_HEAD','PROJECT_HEAD','PROJECT_HEAD','get_project','','PROJECT_ID','project_id','','3','200');"   maxlength="100">
                <cfelse>
                    <cf_duxi name="project_head" type="text" onchange="dictionary_id.value='';" data="" hint="proje adı" threepoint="#request.self#?fuseaction=settings.popup_list_lang_settings&is_use_send&lang_dictionary_id=add_project_form.dictionary_id&lang_item_name=add_project_form.project_head"  label="38244" required="yes"    maxlength="100">
                </cfif>
                <cf_duxi name="project_number" type="text" data=""  label="57416+57487" hint="proje no" maxlength="20">  
                <cf_duxi name="priority_cat" type="selectbox" value="data_priorty.priority_id"  option="data_priorty.priority" data="" hint="öncelik" label="57485">
                <div class="form-group" id="item-pro_h_start" >
                    <label class="col col-4 col-md-4 col-sm-4 col-xs-12"><cf_get_lang dictionary_id='58053.Başlangıç Tarihi'>*</label>
                    <div class="col col-8 col-md-8 col-sm-8 col-xs-12">
                        <div class="col col-6 col-md-6 col-sm-6 col-xs-12">
                            <div class="input-group">
                                <cfsavecontent variable="message"><cf_get_lang dictionary_id="58194.Zorunlu Alan"> : <cf_get_lang dictionary_id='58053.Başlangıç Tarihi'></cfsavecontent>
                                <cfinput type="text" name="pro_h_start" id="pro_h_start" value="" validate="#validate_style#" maxlength="10" required="Yes" message="#message#" > 
                                <span class="input-group-addon"><cf_wrk_date_image date_field="pro_h_start"></span>
                            </div>
                        </div>
                        <div class="col col-3 col-md-3 col-sm-3 col-xs-12">
                            <cf_wrkTimeFormat name="start_hour" value="0" > 
                        </div>
                        <div class="col col-3 col-md-3 col-sm-3 col-xs-12">
                            <cf_wrkTimeFormat name="start_minute" value="0" > 
                        </div>      
                    </div>   
                </div>
                <div class="form-group" id="item-pro_h_finish" >
                    <label class="col col-4 col-md-4 col-sm-4 col-xs-12"><cf_get_lang dictionary_id='57700.Bitiş Tarihi'>*</label>
                    <div class="col col-8 col-md-8 col-sm-8 col-xs-12">
                        <div class="col col-6 col-md-6 col-sm-6 col-xs-12">
                            <div class="input-group">
                                <cfsavecontent variable="message"><cf_get_lang dictionary_id="58194.Zorunlu Alan"> : <cf_get_lang dictionary_id='57700.Bitiş Tarihi'></cfsavecontent>
                                <cfinput type="text" name="pro_h_finish" id="pro_h_finish" value="" validate="#validate_style#" required="Yes" maxlength="10" message="#message#"> 
                                <span class="input-group-addon"><cf_wrk_date_image date_field="pro_h_finish"></span>
                            </div>
                        </div>
                            <div class="col col-3 col-md-3 col-sm-3 col-xs-12">
                                <cf_wrkTimeFormat name="finish_hour" value="0" >  
                            </div>                                 
                            <div class="col col-3 col-md-3 col-sm-3 col-xs-12">
                                <cf_wrkTimeFormat name="finish_minute" value="0" > 
                            </div>                  
                    </div>
                </div>
                <cf_duxi name="special_definition" type="selectbox" value="get_special.special_definition_id"  option="get_special.SPECIAL_DEFINITION" placeholder="57734" label="38125" hint="Özel Tanım"  data=""> 
                <cf_duxi name="agreement_no" type="text" data="" label="30044" hint="sözleşme no"  maxlength="20">
                <!--- <cf_duxi name="project_folder" type="text" data="" hint="Proje Klasörü" label="38313" maxlength="250"> --->
                <div class="form-group" id="item-project_folder" >
                    <label class="col col-4 col-md-4 col-sm-4 col-xs-12"><cf_get_lang dictionary_id='38313.Proje Klasörü'></label>
                    <div class="col col-8 col-md-8 col-sm-8 col-xs-12">
                        <div class="col col-11 col-md-11 col-sm-11 col-xs-12">
                            <cfinput type="text" name="project_folder" id="project_folder" value="" maxlength="250">
                            <cfinput name="projectFolderId" id="projectFolderId" type="hidden">
                        </div>
                        <div class="col col-1 col-md-1 col-sm-1 col-xs-12">
                            <svg id="gDriveIcon" width="100%" height="30px" viewBox="0 0 50 50" style="cursor:pointer;" onClick="driveInit()">
                                <image id="gDriveIconImg" href= "css/assets/icons/catalyst-icon-svg/google-drive.svg" data-toggle="tooltip" title="<cf_get_lang dictionary_id='64438.Google Driveda Klasör Oluştur.'>"/>
                            </svg>
                        </div>
                    </div>
                </div>
                <cf_duxi name="project_detail" type="textarea" data="" hint="açıklama"  label="57629">  
                <cf_duxi name="project_target" type="textarea" data="" hint="hedef"  label="57951" id="project_target"   maxlength="250" onkeyup="return ismaxlength(this)" onblur="return ismaxlength(this);">
                <div class="form-group" id="item-workgroup_id">
                    <label class="col col-4 col-md-4 col-sm-4 col-xs-12"><cf_get_lang dictionary_id='58140.İş Grubu'></label>
                    <div class="col col-8 col-md-8 col-sm-8 col-xs-12">
                        <select name="workgroup_id" id="workgroup_id">
                        <option value=""><cf_get_lang dictionary_id='57734.Seçiniz'></option>
                            <cfoutput query="data_workgroups">
                                <option value="#workgroup_id#">#WORKGROUP_NAME#</option>
                            </cfoutput>
                        </select>                 	
                    </div>
                </div>
                <cf_duxi name="expense_code" type="hidden" id="expense_code"  data="">
                <cf_duxi name="expense_code_name" id="expense_code_name" type="text" value="" hint="masraf gelir merekezi" label="58235" threepoint="#request.self#?fuseaction=objects.popup_expense_center&field_code=add_project_form.expense_code&field_name=add_project_form.expense_code_name">
            </div>
            <div class="col col-6 col-md-6 col-sm-6 col-xs-12" type="column" index="2" sort="true">
                <input type="hidden" name="consumer_id" id="consumer_id"  value="<cfif isdefined('attributes.consumer_id') and len(attributes.consumer_id)><cfoutput>#attributes.consumer_id#</cfoutput></cfif>">
                <input type="hidden" name="company_id" id="company_id" value="<cfif isdefined("attributes.partner_id") and len(attributes.partner_id)><cfoutput>#get_partner.company_id#</cfoutput></cfif>" >
                <cf_duxi name="about_company" id="about_company" type="text" data="" hint="şirket" label="57574" threepoint="#request.self#?fuseaction=objects.popup_list_pars&field_comp_id=add_project_form.company_id&is_period_kontrol=0&field_comp_name=add_project_form.about_company&field_partner=add_project_form.partner_id&field_id=add_project_form.consumer_id&field_name=add_project_form.about_par_name&par_con=1&select_list=2,3">
                <div class="form-group" id="item-about_par_name">
                    <label class="col col-4 col-md-4 col-sm-4 col-xs-12"><cf_get_lang dictionary_id='57578.Yetkili'></label>
                    <div class="col col-8 col-md-8 col-sm-8 col-xs-12">
                        <input type="hidden" name="partner_id" id="partner_id" value="<cfif isdefined("attributes.partner_id") and len(attributes.partner_id)><cfoutput>#attributes.partner_id#</cfoutput></cfif>">
                        <input type="text" name="about_par_name" id="about_par_name"   value="<cfif isdefined("attributes.partner_id") and len(attributes.partner_id)><cfoutput>#get_partner.company_partner_name# #get_partner.company_partner_surname#</cfoutput><cfelseif isdefined("attributes.consumer_id")><cfoutput>#get_consumer.consumer_name# #get_consumer.consumer_surname#</cfoutput></cfif>">
                    </div>
                </div>
                <cf_duxi type="hidden" name="project_emp_id" id="project_emp_id" value="">
                <cf_duxi type="hidden" name="project_pos_code" id="project_pos_code" value="">
                <cf_duxi type="hidden" name="task_company_id" id="task_company_id" value="">
                <cf_duxi type="hidden" name="task_partner_id" id="task_partner_id" value="">
                <cf_duxi name="responsable_name" label="57569" hint="Görevli" required="yes" value="" threepoint="#request.self#?fuseaction=objects.popup_list_positions&field_partner=add_project_form.task_partner_id&field_emp_id=add_project_form.project_emp_id&field_code=add_project_form.project_pos_code&field_comp_id=add_project_form.task_company_id&field_name=add_project_form.responsable_name&select_list=1,2" > 
                <cf_duxi name="related_project_id" type="hidden" data="">
                <cf_duxi name="related_project_head" type="text" data="" placeholder="58459" label="34997" threepoint= "#request.self#?fuseaction=objects.popup_list_projects&project_head=add_project_form.related_project_head&project_id=add_project_form.related_project_id">  
                <cf_duxi name="department" label="38485" hint="Depo- Lokasyon">
                    <cf_wrkdepartmentlocation 
                    returnInputValue="location_id,department,department_id"
                    returnQueryValue="LOCATION_ID,LOCATION_NAME,DEPARTMENT_ID"
                    fieldName="department"
                    fieldid="location_id"
                    department_fldId="department_id"
                    department_id=""
                    location_id=""
                    user_level_control="#session.ep.OUR_COMPANY_INFO.IS_LOCATION_FOLLOW#"
                    branch_fldId ="branchId"
                    width="150">
                </cf_duxi>
                <cf_duxi name="expected_budget" type="text" data_control="money" currencyname="BUDGET_CURRENCY" currencyvalue="data_project.BUDGET_CURRENCY"  data="" hint="Tahmini Bütçe"  label="38175"> 
                <cf_duxi name="expected_cost" type="text" data_control="money" currencyname="COST_CURRENCY" currencyvalue="data_project.COST_CURRENCY"   data="" hint="Tahmini Maliyet" label="38300">
                <cf_duxi name="product_id" type="hidden" data="">  
                <cf_duxi name="product_name" type="text" data="" hint="ilişkili ürün" label="38484" threepoint="#request.self#?fuseaction=objects.popup_product_names&product_id=add_project_form.product_id&field_name=add_project_form.product_name"> 
                <cf_duxi name="branch_id" type="selectbox" value="get_branches.BRANCH_ID"  option="get_branches.BRANCH_NAME" placeholder="57453" hint="şube" label="57453" onChange="LoadDepLoc(this.value,'department')" data="">
                <div class="form-group" id="item-sales_zone_id">
                    <label class="col col-4 col-md-4 col-sm-4 col-xs-12"><cf_get_lang dictionary_id='57659.Satış Bölgesi'></label>
                    <div class="col col-8 col-md-8 col-sm-8 col-xs-12">
                        <select name="sales_zone_id" id="sales_zone_id">
                        <option value=""><cf_get_lang dictionary_id='57734.Seçiniz'></option>
                            <cfoutput query="data_zones">
                                <option value="#SZ_ID#">#SZ_NAME#</option>
                            </cfoutput>
                        </select>                 	
                    </div>
                </div>
                <div class="form-group" id="item-country_id">
                    <label class="col col-4 col-md-4 col-sm-4 col-xs-12"><cf_get_lang dictionary_id ='58219.Ulke'></label>
                    <div class="col col-8 col-md-8 col-sm-8 col-xs-12">
                        <select name="country_id" id="country_id"  onchange="<cfif isDefined('xml_auto_sales_zone') and xml_auto_sales_zone eq 1>auto_sales_zone(); </cfif>LoadCity(this.value,'city_id','county_id',0);">
                        <option value=""><cf_get_lang dictionary_id='57734.Seçiniz'></option>
                            <cfoutput query="get_country">
                                <option value="#country_id#">#country_name#</option>
                            </cfoutput>
                        </select>                 	
                    </div>
                </div>
                <div class="form-group" id="item-city">
                    <label class="col col-4 col-md-4 col-sm-4 col-xs-12"><cf_get_lang dictionary_id="58608.İl"></label>
                    <div class="col col-8 col-md-8 col-sm-8 col-xs-12">
                        <select name="city_id" id="city_id"  onchange="LoadCounty(this.value,'county_id')">
                            <option value=""><cf_get_lang dictionary_id='57734.Seçiniz'></option>
                        </select>               	
                    </div>
                </div>
                <div class="form-group" id="item-county">
                    <label class="col col-4 col-md-4 col-sm-4 col-xs-12"><cf_get_lang dictionary_id="58638.İlçe"></label>
                    <div class="col col-8 col-md-8 col-sm-8 col-xs-12">
                        <select name="county_id" id="county_id" >
                            <option value=""><cf_get_lang dictionary_id='57734.Seçiniz'></option>						
                        </select>              	
                    </div>
                </div>
                <div class="form-group" id="item-coordinate">
                    <label class="col col-4 col-md-4 col-sm-4 col-xs-12"><cf_get_lang dictionary_id="58549.Koordinatlar"></label>
                    <div class="col col-8 col-md-8 col-sm-8 col-xs-12">
                        <div class="input-group">
                            <span class="input-group-addon bold"><cf_get_lang dictionary_id='58553.E'></span>
                            <cfsavecontent variable="message"><cf_get_lang dictionary_id='59875.Lütfen enlem değerini -90 ile 90 arasında giriniz'></cfsavecontent>
                            <cfinput type="text" name="coordinate_1" id="coordinate_1" maxlength="10" range="-90,90" message="#message#" > 
                            <span class="input-group-addon bold"><cf_get_lang dictionary_id='58591.B'></span>
                            <cfsavecontent variable="message"><cf_get_lang dictionary_id='59894.Lütfen boylam değerini -180 ile 180 arasında giriniz'></cfsavecontent>
                            <cfinput type="text" name="coordinate_2" id="coordinate_2" maxlength="10" range="-180,180" message="#message#" >
                        </div>
                    </div>
                </div> 
                <cf_duxi name="" label="57810" hint="Ek Bilgi">
                    <cf_wrk_add_info info_type_id="-10" upd_page = "0" colspan="9">
                </cf_duxi>  
            </div>
        </cf_box_elements>
        <cf_box_footer>
            <div class="col col-12"><cf_workcube_buttons is_upd='0' is_cancel="0" add_function='unformat_fields()'></div>
        </cf_box_footer> 
    </cfform>
</cf_box>
<cfset googleapi = createObject("component","WEX.google.cfc.google_api")>
<cfset get_api_key = googleapi.get_api_key()>
<script type="text/javascript">
    $('[data-toggle="tooltip"]').tooltip();
    var googleActivated = false;
    var projectName = '';
    // Client ID and API key from the Developer Console
    var CLIENT_ID = '<cfoutput>#get_api_key.GOOGLE_CLIENT_ID#</cfoutput>';
    var API_KEY = '<cfoutput>#get_api_key.GOOGLE_API_KEY#</cfoutput>';

    // Array of API discovery doc URLs for APIs used by the quickstart
    var DISCOVERY_DOC = ["https://www.googleapis.com/discovery/v1/apis/drive/v3/rest"];

    // Birden fazla scope boşluk ile ayrılarak yazılmalı.
    var SCOPES = 'https://www.googleapis.com/auth/drive.metadata.readonly https://www.googleapis.com/auth/drive';
    let tokenClient;
    let gapiInited = false;
    let gisInited = false;

    function gapiLoaded() {
        gapi.load('client', initializeGapiClient);
    }

    async function initializeGapiClient() {
        await gapi.client.init({
            apiKey: API_KEY,
            discoveryDocs: DISCOVERY_DOC,
        });
        gapiInited = true;
        //maybeEnableButtons();
    }

    function gisLoaded() {
        tokenClient = google.accounts.oauth2.initTokenClient({
            client_id: CLIENT_ID,
            scope: SCOPES,
            callback: '',
        });
        gisInited = true;    
    }

    function getDifference(date1, date2) {
        var date1 = new Date(date1);
        var date2 = new Date(date2);
        var diff = date1.getTime() - date2.getTime();
        return diff / 1000;
    }

    function handleClientLoad() {
        if ((!localStorage.getItem('gat') || getDifference(localStorage.getItem('expires_last_date'), new Date()) <= 0)) {
            gisLoaded();
            tokenClient.requestAccessToken({ prompt: 'consent' });
            tokenClient.callback = async (resp) => {
                if (resp.error !== undefined) {
                    throw (resp);
                }
                // console.log('resp: ', resp); // giriş yapan google hesabından access token vb. bilgileri getiriyor.
                localStorage.setItem('gat', resp.access_token); // access_token değeri localStorage ile saklanıyor.
                let expires_time = resp.expires_in; // access_token değerinin geçerlilik süresi
                var today = new Date();
                today.setSeconds(today.getSeconds() + expires_time);
                localStorage.setItem('expires_last_date', today);
                listFolders();
            };
        } else {
            gisLoaded();
            tokenClient.requestAccessToken({ prompt: '' });
            tokenClient.callback = async (resp) => {
                if (resp.error !== undefined) {
                    throw (resp);
                }
                listFolders();
            };
        }   
    }

    function listFolders() {
        if (googleActivated == false) {return false;}
        gapi.client.drive.files.list({
            q: "mimeType='application/vnd.google-apps.folder'",
            fields: 'nextPageToken, files(id, name)',
            spaces: 'drive'
        }).then(function(response) {
            /* console.log("folder response:", response.result.files); */
            var folderName = response.result.files;
            const found = folderName.find(element => element == projectName);
            if (typeof found == "undefined" || found == "undefined"){
                createFolder();
            }else{
                alert("<cf_get_lang dictionary_id='64437.Bu klasör daha önce oluşturulmuş.'>");
            }
        });
    }

    function createFolder(){
        if (googleActivated == false) {return false;}
        var fileMetadata = {
            'name': projectName,
            'mimeType': 'application/vnd.google-apps.folder'
        };
        gapi.client.drive.files.create({
            resource: fileMetadata,
            fields: 'id'
        }).then(function(response) {
            /* console.log('response: ', response.result.id); */
            document.getElementById("projectFolderId").value = response.result.id;
            alert("<cf_get_lang dictionary_id='42300.Klasör'><cf_get_lang dictionary_id='36458.Oluşturuldu'>!");
            $("#project_folder").val($("#project_head").val());
            $("#project_head").attr('readonly', true);
            $("#project_folder").attr('readonly', true);
            $("#gDriveIcon").attr( "onclick", "window.open('https://drive.google.com/drive/u/0/folders/"+response.result.id+"')" );
            $("#gDriveIconImg").attr( "title", "<cf_get_lang dictionary_id='61793.Projenin Google Drive klasörüne erişmek için tıklayınız.'>" );
        });
    }

    function driveInit(){
        if($("#project_head").val() == ''){
            alert("<cf_get_lang dictionary_id='38137.Proje Adı Girmelisiniz'>!");
        }else{
            projectName = $("#project_head").val();
            googleActivated = true;
            handleClientLoad();
        }
    }

	function LoadDepLoc(branch_id,field_select_object)
	{
		var district_len = eval("document.all." + field_select_object + ".options.length");
		for(j=district_len;j>=0;j--)
			eval("document.all." + field_select_object).options[j] = null;
		//Ilçe secili degilse
		if(branch_id != '')
		{
			var deger = workdata('get_department_location_id',branch_id);
			//alert(deger);
			eval("document.all." + field_select_object).options[0]=new Option('Seçiniz','');
			for(var jj=0;jj < deger.recordcount;jj++)
			{
				eval("document.all." + field_select_object).options[jj+1]=new Option(deger.DEPARTMENT_NAME[jj],deger.DEPARTMENT_ID[jj]+'-'+deger.LOCATION_ID[jj]);
			}
		}
		else
		{
			eval("document.all." + field_select_object).options[0]=new Option('Seçiniz','');
		}
    }
    function get_company()
    {
        var emp=document.getElementById('project_emp_id').value;
        if(emp != '')
        {
            var GET_COMP=wrk_safe_query('prj_get_comp','dsn',0,emp);
            document.getElementById('task_company_id').value=GET_COMP.COMPANY_ID;
        }
    }
	function unformat_fields()
	{
		<cfif x_is_required_member eq 1>
			if(document.getElementById('company_id').value == '' && document.getElementById('partner_id').value == '' && document.getElementById('consumer_id').value == '')
			{
				alert("<cf_get_lang dictionary_id='58194.Zorunlu Alan'> : <cf_get_lang dictionary_id='57574.Şirket'>");
				return false;
			}
		</cfif>
        date_format="<cfoutput>#dateformat_style#</cfoutput>";
		if(date_format == "dd/mm/yyyy"){
            tarih1_ = document.getElementById('pro_h_start').value.substr(6,4) +document.getElementById('pro_h_start').value.substr(3,2) + document.getElementById('pro_h_start').value.substr(0,2);
		    tarih3_ = document.getElementById('pro_h_finish').value.substr(6,4) + document.getElementById('pro_h_finish').value.substr(3,2) + document.getElementById('pro_h_finish').value.substr(0,2);
            if(tarih1_ > tarih3_ || (tarih1_ == tarih3_ && (parseInt(document.getElementById('start_hour').value) >= parseInt(document.getElementById('finish_hour').value))))
            {
                alert("<cf_get_lang dictionary_id ='38353.Başlangıç Tarihi ile Bitiş Tarihi Kontrol Ediniz'> !");
                return false;
            }
        }else{
            tarih1_ = document.getElementById('pro_h_start').value.substr(6,4) + document.getElementById('pro_h_start').value.substr(0,2) + document.getElementById('pro_h_start').value.substr(3,2) ;
		    tarih3_ = document.getElementById('pro_h_finish').value.substr(6,4) + document.getElementById('pro_h_finish').value.substr(0,2) + document.getElementById('pro_h_finish').value.substr(3,2);
            if(tarih1_ > tarih3_ || (tarih1_ == tarih3_ && (parseInt(document.getElementById('start_hour').value) >= parseInt(document.getElementById('finish_hour').value))))
            {
                alert("<cf_get_lang dictionary_id ='38353.Başlangıç Tarihi ile Bitiş Tarihi Kontrol Ediniz'> !");
                return false;
            }
        }

		if (!chk_process_cat('add_project_form',1)) return false;
		return process_cat_control();
	}
	
    <cfif isDefined('xml_auto_sales_zone') and xml_auto_sales_zone eq 1>
      
		function auto_sales_zone()
		{
            var get_sales_zone_id = wrk_safe_query("get_sales_zone_id",'dsn',0,document.getElementById('country_id').value);
			if(get_sales_zone_id.recordcount == 1)
			{
				document.getElementById('sales_zone_id').value = get_sales_zone_id.SZ_ID;
				return false;
			}
			else if(get_sales_zone_id.recordcount == 0)
			{
				alert('<cf_get_lang dictionary_id="40952.Ülke ile İlişkili Satış Bölgesi Bulunamadı"> !');
				return false;
			}
			else if(get_sales_zone_id.recordcount > 1)
			{
				alert('<cf_get_lang dictionary_id="40955.Ülke ile İlişkili Birden Fazla Satış Bölgesi Bulunmaktadır"> !');
				return false;
			}
        }
  
	</cfif>
</script>
<script async defer src="https://apis.google.com/js/api.js" onload="gapiLoaded()"></script>
<script async defer src="https://accounts.google.com/gsi/client" onload="gisLoaded()"></script>
<cfsetting showdebugoutput="yes">