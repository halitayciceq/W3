<cfset getComponent = createObject('component','V16.project.cfc.get_project_detail')>
<cfset GET_GOOGLE_PROJECT_FOLDER_ID = getComponent.GET_GOOGLE_PROJECT_FOLDER_ID(project_id : attributes.id)>
<cfset GET_PROJECT_FOLDER = getComponent.GET_PROJECT_FOLDER(project_id : attributes.id)>
<cf_catalystHeader>
<cf_xml_page_edit fuseact="project.projects">
<cfsavecontent variable="message"><cf_get_lang dictionary_id='57416.proje'>: <cfoutput>#attributes.id#</cfoutput></cfsavecontent> 
    <cf_box id="FormAddProject" <!--- closable="0" collapsable="0" title="#message#"  --->> 
        <cf_box_data asname="data_workgroups" function="V16.project.cfc.project:GET_WORKGROUPS">
        <cf_box_data asname="data_priorty" function="V16.project.cfc.project:GET_PRIORITY"> 
        <cf_box_data asname="data_country" function="V16.project.cfc.project:GET_COUNTRY"> 
        <cf_box_data asname="data_branches" function="V16.project.cfc.project:get_branches_fnc"> 
        <cf_box_data asname="data_city" function="V16.project.cfc.project:GET_CITY"> 
        <cf_box_data asname="data_zones" function="V16.project.cfc.project:GET_ZONES"> 
        <cf_box_data asname="get_departman_" function="V16.project.cfc.project:GET_DEPARTMAN"> 
        <cf_box_data asname="get_special" function="V16.project.cfc.project:get_special_def">
        <cf_box_data asname="data_project" function="V16.project.cfc.project:select" conditions="id=url.id">
        <cfform method="post" name="update_project" id="update_project">
            <cf_box_elements addcol="1">
                <cf_duxi name="id" type="hidden" data="attributes.id">
                <cf_duxi name="project_status" type="checkbox"  data="data_project.project_status" value="1" label="57493" hint="aktif">
                <cfif xml_is_stepbystep_imp eq 1>
                    <cf_duxi name="is_stepbystep_imp" type="checkbox" data="data_project.is_stepbystep_imp" value="1" label="44149" hint="implementation">
                </cfif>
                <cf_duxi label='57486' name="process_cat"><cf_workcube_main_process_cat main_process_cat='#data_project.process_cat#' slct_width='150' ></cf_duxi>  
                <cf_duxi  name="process_stage" label="58859" hint="süreç">
                    <cf_workcube_process is_upd='0' select_value = '#data_project.pro_currency_id#' is_detail='1' process_cat_width='150'>
                </cf_duxi>   
                <cf_duxi name="priority_id" type="selectbox" value="data_priorty.priority_id"  option="data_priorty.priority" data="data_project.PRO_PRIORITY_ID" label="57485">
                <div class="form-group" id="item-workgroup_id">
                    <label class="col col-4 col-md-4 col-sm-4 col-xs-12"><cf_get_lang dictionary_id='58140.İş Grubu'></label>
                    <div class="col col-8 col-md-8 col-sm-8 col-xs-12">
                        <select name="workgroup_id" id="workgroup_id">
                        <option value=""><cf_get_lang dictionary_id='57734.Seçiniz'></option>
                            <cfoutput query="data_workgroups">
                                <option value="#workgroup_id#" <cfif data_project.workgroup_id eq workgroup_id>selected</cfif>>#WORKGROUP_NAME#</option>
                            </cfoutput>
                        </select>                 	
                    </div>
                </div>  
                <cf_duxi name="project_number" type="text" data="data_project.project_number"  label="57416+57487">  
                <cf_duxi name="agreement_no" type="text" data="data_project.agreement_no" label="30044">
                <cf_duxi name="partner_id" type="hidden" data="data_project.partner_id"> 
                <cf_duxi name="consumer_id" type="hidden" data="data_project.consumer_id">
                <cf_duxi name="company_id" type="hidden" data="data_project.company_id"> 
                <cf_duxi name="project_pos_code" type="hidden" data="data_project.project_pos_code">
                <cf_duxi name="outsrc_cmp_id" type="hidden" value="data_project.outsrc_cmp_id">
                <cf_duxi name="outsrc_partner_id" type="hidden" data="data_project.outsrc_partner_id">
                <cf_duxi name="project_emp_id" type="hidden" data="data_project.project_emp_id">
                <cfif len(data_project.company_id)>
                  
                    <cf_duxi name="company_name" id="company_name" type="text" data="data_project.fullname" hint="şirket" label="57574"  threepoint="#request.self#?fuseaction=objects.popup_list_pars&field_comp_id=update_project.company_id&is_period_kontrol=0&field_comp_name=update_project.company_name&field_partner=update_project.partner_id&field_id=update_project.consumer_id&field_name=update_project.partner_name&par_con=1&select_list=2,3">
                        <cf_duxi name="partner_name" id="partner_name" type="text" value="#data_project.company_partner_name##data_project.company_partner_surname#" hint="şirket yetkili" label="30291">
                <cfelseif len(data_project.consumer_id)>
                    <cf_duxi name="company_name" id="company_name" type="text"  value="#data_project.consumer_name# #data_project.consumer_surname#" hint="şirket" label="57574"  threepoint="#request.self#?fuseaction=objects.popup_list_pars&field_comp_id=update_project.company_id&is_period_kontrol=0&field_comp_name=update_project.company_name&field_partner=update_project.partner_id&field_id=update_project.consumer_id&field_name=update_project.partner_name&par_con=1&select_list=2,3">
                        <cf_duxi name="partner_name" id="partner_name" type="text" value="#data_project.consumer_name# #data_project.consumer_surname#" hint="şirket yetkili" label="30291">   
                <cfelse>
                    <cf_duxi name="company_name" id="company_name" type="text" data="" hint="şirket" label="57574" threepoint="#request.self#?fuseaction=objects.popup_list_pars&field_comp_id=update_project.company_id&is_period_kontrol=0&field_comp_name=update_project.company_name&field_partner=update_project.partner_id&field_id=update_project.consumer_id&field_name=update_project.partner_name&par_con=1&select_list=2,3">
                    <cf_duxi name="partner_name" id="partner_name" type="text" value="" hint="şirket yetkili" label="30291">   
                 </cfif>
                <cf_duxi type="hidden" name="dictionary_id" id="dictionary_id" value="#data_project.language_id#">
                <cfif len(data_project.language_id)>
                    <cfset project_head=get_project_name(attributes.id,0)>
                <cfelse>
                    <cfset project_head=data_project.project_head>
                </cfif>
                <cf_duxi name="project_head" type="text" icon="icon-book btnPointer" onchange="dictionary_id.value='';" value="#project_head#" hint="proje adı" icon_boxhref="#request.self#?fuseaction=settings.popup_list_lang_settings&is_use_send&lang_dictionary_id=update_project.dictionary_id&lang_item_name=update_project.project_head" label="38244">
                <cfset project_detail = replace(data_project.project_detail,'<p>','','all')>
                <cfset project_detail_ = replace(project_detail,'</p>','','all')>     
                <cf_duxi name="project_detail" type="textarea" data="project_detail_" hint="açıklama"  label="57629">  
                <cf_duxi name="project_target" type="textarea" data="data_project.project_target" maxlength="250" onblur="return ismaxlength(this);" hint="ilişkili proje"  label="57951">
                <cf_duxi name="related_project_id" type="hidden" data="data_project.related_project_id">
                <cfif len(data_project.related_project_id) > 
                    <cf_duxi name="related_project_head" type="text" data="data_project.related_project_head" hint="ilişkili proje"  label="34997" threepoint= "#request.self#?fuseaction=objects.popup_list_projects&project_head=update_project.related_project_head&project_id=update_project.related_project_id">   
                <cfelse>  
                    <cf_duxi name="related_project_head" type="text" data="" placeholder="58459" label="34997" threepoint= "#request.self#?fuseaction=objects.popup_list_projects&project_head=update_project.related_project_head&project_id=update_project.related_project_id">  
                </cfif>     
                <cf_duxi name="expected_budget" type="text" data_control="money" currencyname="BUDGET_CURRENCY" currencyvalue="data_project.BUDGET_CURRENCY"  value="#tlformat(data_project.expected_budget)#" hint="Tahmini Bütçe"  label="38175"> 
                <cf_duxi name="expected_cost" type="text" data_control="money" currencyname="COST_CURRENCY" currencyvalue="data_project.COST_CURRENCY"    value="#tlformat(data_project.expected_cost)#" hint="Tahmini Maliyet" label="38300">
                <cf_duxi name="start" type="text" data_control="datetime"  data="data_project.TARGET_START"  hint="Başlangıç Tarihi *" label="58053">   
                <cf_duxi name="finish" type="text" data_control="datetime"  data="data_project.TARGET_FINISH" hint="Bitiş Tarihi " label="57700">  
                <cf_duxi name="product_id" type="hidden" data="data_project.product_id">  
                <cf_duxi name="product_name" type="text" data="data_project.product_name" hint="ilişkili ürün" label="38484" threepoint="#request.self#?fuseaction=objects.popup_product_names&product_id=update_project.product_id&field_name=update_project.product_name"> 
                    <cfif isDefined('xml_auto_sales_zone') and xml_auto_sales_zone eq 1>
                    <cf_duxi name="country_id" type="selectbox" value="data_country.country_id"  option="data_country.country_name" onchange="auto_sales_zone();LoadCity(this.value,'city_id','county_id',0);" label="58219"  data="data_project.country_id"> 
                <cfelse>
                    <cf_duxi name="country_id" type="selectbox" value="data_country.country_id" onchange="LoadCity(this.value,'city_id','county_id',0);" option="data_country.country_name"  label="58219"  data="data_project.country_id">    
                </cfif> 
                <cfif xml_coordinate >
                    <cf_duxi name="city_id" type="selectbox" value="data_city.city_id"  option="data_city.city_name" onchange="LoadCounty(this.value,'county_id')" placeholder="57734" hint="il" label="58608"  data="data_project.city_id"> 
                        <cfquery name="GET_CITY" datasource="#DSN#">
                            SELECT CITY_ID,CITY_NAME FROM SETUP_CITY <cfif len(data_project.country_id)>WHERE COUNTRY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#data_project.country_id#"></cfif>
                        </cfquery> 
                        <cfif len(data_project.city_id)> 
                        <cfquery name="GET_COUNTY" datasource="#DSN#">
                            SELECT COUNTY_ID,COUNTY_NAME FROM SETUP_COUNTY WHERE CITY = <cfqueryparam cfsqltype="cf_sql_integer" value="#data_project.city_id#"> ORDER BY COUNTY_NAME
                        </cfquery>
                        <cf_duxi name="county_id" type="selectbox" value="get_county.county_id"  option="get_county.county_name" data="data_project.county_id" onchange="LoadCounty(this.value,'county_id')" placeholder="57734" hint="ilçe" label="58638"  > 
                    </cfif>
                </cfif>
                <div class="form-group" id="item-project_folder">
                    <label class="col col-4 col-md-4 col-sm-4 col-xs-12"><cf_get_lang dictionary_id='38313.Proje Klasörü'></label>
                    <div class="col col-8 col-md-8 col-sm-8 col-xs-12">
                        <div class="col col-11 col-md-11 col-sm-11 col-xs-12">
                            <cfinput type="text" name="project_folder" id="project_folder" value="#data_project.project_folder#" maxlength="250">
                        </div>
                    <cfif len(GET_GOOGLE_PROJECT_FOLDER_ID.GOOGLE_PROJECT_FOLDER_ID) and not GET_PROJECT_FOLDER.PROJECT_FOLDER contains 'drive.google'>
                        <cfinput name="projectFolderId" id="projectFolderId" type="hidden" value="#GET_GOOGLE_PROJECT_FOLDER_ID.GOOGLE_PROJECT_FOLDER_ID#">
                        <div class="col col-1 col-md-1 col-sm-1 col-xs-12">
                            <svg id="gDriveIcon" width="100%" height="30px" viewBox="0 0 50 50" style="cursor:pointer;" onClick="window.open('https://drive.google.com/drive/u/0/folders/<cfoutput>#GET_GOOGLE_PROJECT_FOLDER_ID.GOOGLE_PROJECT_FOLDER_ID#</cfoutput>')">
                                <image id="gDriveIconImg" href= "css/assets/icons/catalyst-icon-svg/google-drive.svg" data-toggle="tooltip" title="<cf_get_lang dictionary_id='61793.Projenin Google Drive klasörüne erişmek için tıklayınız.'>"/>
                            </svg>
                        </div>
                    <cfelseif len(GET_PROJECT_FOLDER.PROJECT_FOLDER) and GET_PROJECT_FOLDER.PROJECT_FOLDER contains 'drive.google'>
                        <cfinput name="projectFolderId" id="projectFolderId" type="hidden" value="">
                        <div class="col col-1 col-md-1 col-sm-1 col-xs-12">
                            <svg id="gDriveIcon" width="100%" height="30px" viewBox="0 0 50 50" style="cursor:pointer;" onClick="window.open('<cfoutput>#GET_PROJECT_FOLDER.PROJECT_FOLDER#</cfoutput>')">
                                <image id="gDriveIconImg" href= "css/assets/icons/catalyst-icon-svg/google-drive.svg" data-toggle="tooltip" title="<cf_get_lang dictionary_id='61793.Projenin Google Drive klasörüne erişmek için tıklayınız.'>"/>
                            </svg>
                        </div>
                    <cfelse>
                        <cfinput name="projectFolderId" id="projectFolderId" type="hidden" value="">
                        <div class="col col-1 col-md-1 col-sm-1 col-xs-12">
                            <svg id="gDriveIcon" width="100%" height="30px" viewBox="0 0 50 50" style="cursor:pointer;" onClick="driveInit()">
                                <image id="gDriveIconImg" href= "css/assets/icons/catalyst-icon-svg/google-drive.svg" data-toggle="tooltip" title="<cf_get_lang dictionary_id='64438.Google Driveda Klasör Oluştur.'>"/>
                            </svg>
                        </div>
                    </cfif> 
                    </div>
                </div> 
                <cf_duxi name="expense_code" type="hidden" id="expense_code"  data="data_project.expense_code">
                <cf_duxi name="expense_code_name" id="expense_code_name" type="text" value="#data_project.expense_code#- #data_project.expense#" hint="masraf gelir merekezi" label="58235" threepoint="#request.self#?fuseaction=objects.popup_expense_center&field_code=update_project.expense_code&field_name=update_project.expense_code_name">
                <cf_duxi name="branch_id" type="selectbox" value="data_branches.branch_id"  option="data_branches.BRANCH_NAME" placeholder="57453" hint="şube" label="57453" <!---  onChange="LoadDepLoc(this.value,'department','#data_project.department_id#-#data_project.location_id#')" ---> data="data_project.branch_id">
                <cf_duxi name="department" label="38485" hint="Depo- Lokasyon">
                    <cf_wrkdepartmentlocation 
                    returnInputValue="location_id,department,department_id"
                    returnQueryValue="LOCATION_ID,LOCATION_NAME,DEPARTMENT_ID"
                    fieldName="department"
                    fieldid="location_id"
                    department_fldId="department_id"
                    department_id="#data_project.department_id#"
                    location_id="#data_project.location_id#"
                    user_level_control="#session.ep.OUR_COMPANY_INFO.IS_LOCATION_FOLLOW#"
                    branch_fldId ="branchId"
                    width="150">
                </cf_duxi>
                <cfif  len(data_project.PROJECT_EMP_ID)>
                    <cf_duxi name="employee_name" label="57569" hint="Görevli" value="#data_project.employee_name# #data_project.EMPLOYEE_SURNAME#" threepoint="#request.self#?fuseaction=objects.popup_list_positions&field_partner=update_project.outsrc_partner_id&field_emp_id=update_project.project_emp_id&field_code=update_project.project_pos_code&field_comp_id=update_project.outsrc_cmp_id&field_name=update_project.employee_name&select_list=1,2" > 
                <cfelseif  len(data_project.outsrc_cmp_id)>
                    <cf_duxi name="employee_name" label="57569" hint="Görevli" value="#get_par_info(data_project.outsrc_partner_id,0,2,0)#-#get_par_info(data_project.outsrc_partner_id,0,1,0)#" threepoint="#request.self#?fuseaction=objects.popup_list_positions&field_partner=update_project.outsrc_partner_id&field_emp_id=update_project.project_emp_id&field_code=update_project.project_pos_code&field_comp_id=update_project.outsrc_cmp_id&field_name=update_project.employee_name&select_list=1,2" > 
                <cfelse>
                    <cf_duxi name="employee_name" label="57569" hint="Görevli" value="" threepoint="#request.self#?fuseaction=objects.popup_list_positions&field_partner=update_project.outsrc_partner_id&field_emp_id=update_project.project_emp_id&field_code=update_project.project_pos_code&field_comp_id=update_project.outsrc_cmp_id&field_name=update_project.employee_name&select_list=1,2" >    
                </cfif> 
                <cfif xml_coordinate>
                    <cf_duxi name="coordinate_1" type="text" data="data_project.coordinate_1" hint="Koordinatlar" label="58549" > 
                        <div class="input-group">
                                <span class="input-group-addon"><cf_get_lang dictionary_id="63580.Enlem"></span>
                                <input name="coordinate_1" type="text" maxlength="10" style="width:62px;" id="coordinate_1" value="<cfoutput>#data_project.coordinate_1#</cfoutput>"> 
                                <span class="input-group-addon"><cf_get_lang dictionary_id="63581.Boylam"></span>
                                <input name="coordinate_2" type="text" maxlength="10" style="width:62px;" id="coordinate_2" value="<cfoutput>#data_project.coordinate_2#</cfoutput>">
                        </div>
                </cf_duxi> 
                </cfif>                
                <cf_duxi name="special_definition" type="selectbox" value="get_special.SPECIAL_DEFINITION_ID"  option="get_special.SPECIAL_DEFINITION" placeholder="57734" label="38125" hint="Özel Tanım"  data="data_project.special_definition_id"> 
                <div class="form-group" id="item-sales_zone_id">
                    <label class="col col-4 col-md-4 col-sm-4 col-xs-12"><cf_get_lang dictionary_id='57659.Satış Bölgesi'></label>
                    <div class="col col-8 col-md-8 col-sm-8 col-xs-12">
                        <select name="sales_zone_id" id="sales_zone_id">
                        <option value=""><cf_get_lang dictionary_id='57734.Seçiniz'></option>
                            <cfoutput query="data_zones">
                                <option value="#SZ_ID#" <cfif data_project.SALES_ZONE_ID eq SZ_ID>selected</cfif>>#SZ_NAME#</option>
                            </cfoutput>
                        </select>                 	
                    </div>
                </div>
                <cf_duxi name="" label="57810" hint="Ek Bilgi">
                    <cf_wrk_add_info info_type_id="-10" info_id="#attributes.id#" upd_page = "1" colspan="9">
                </cf_duxi>
            </cf_box_elements>
            <cf_box_footer>   
                <cf_record_info query_name="data_project" record_emp="RECORD_EMP" update_emp="UPDATE_EMP">
                <cf_workcube_buttons is_upd='1' add_function='kontrol()'>
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
        var SCOPES = 'https://www.googleapis.com/auth/drive.metadata.readonly';
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
                alert("<cf_get_lang dictionary_id='64457.Lütfen, sayfayı güncelleyin.'>");
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

        function kontrol()
        {
        if(project_head.value == '')
        {
            alertObject({message: "Lütfen Proje ismini doldurunuz!"});
            return false;
        }
        
            return true;
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