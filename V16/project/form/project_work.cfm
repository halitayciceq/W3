<cf_xml_page_edit fuseact="project.popup_project_work">
<cfquery name="GET_PROCURRENCY" datasource="#DSN#">
	SELECT
		PTR.PROCESS_ID,
		PTR.STAGE,
		PTR.PROCESS_ROW_ID 
	FROM
		PROCESS_TYPE_ROWS PTR,
		PROCESS_TYPE_OUR_COMPANY PTO,
		PROCESS_TYPE PT
	WHERE
		PT.IS_ACTIVE = 1 AND
		PT.PROCESS_ID = PTR.PROCESS_ID AND
		PT.PROCESS_ID = PTO.PROCESS_ID AND
		PTO.OUR_COMPANY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.company_id#"> AND
		PT.FACTION LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%project.works%">
	ORDER BY
		PTR.LINE_NUMBER
</cfquery>
<cfquery name="process" datasource="#DSN#">
	SELECT PROCESS_ID,WORK_CAT_ID FROM PRO_WORK_CAT
</cfquery>
<cfquery name="get_work_xml" datasource="#dsn#">
	SELECT 
		PROPERTY_VALUE,
		PROPERTY_NAME
	FROM
		FUSEACTION_PROPERTY
	WHERE
		OUR_COMPANY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#session_base.company_id#"> AND
		FUSEACTION_NAME = <cfqueryparam cfsqltype="cf_sql_varchar" value="project.addwork"> AND
		PROPERTY_NAME = <cfqueryparam cfsqltype="cf_sql_varchar" value="xml_is_stage_cat">
</cfquery>
<cfif get_work_xml.recordcount>
	<cfset xml_is_stage_cat = get_work_xml.PROPERTY_VALUE>
<cfelse>
	<cfset xml_is_stage_cat = 0>
</cfif>
<cfparam name="attributes.modal_id" default="">
<cfif not ((isdefined("attributes.project_id") and len(attributes.project_id)) or (isdefined("attributes.uploaded_file") and len(attributes.uploaded_file)))>
    <cfsavecontent variable="title"><cf_get_lang dictionary_id='55773.Görev'><cf_get_lang dictionary_id='45836.Aktarım'></cfsavecontent>
        <cfif not isDefined("attributes.is_submit") and not isDefined("attributes.is_submit_2")>
        <cf_box title="#title#" scroll="1" collapsable="1" resize="1"popup_box="#iif(isdefined("attributes.draggable"),1,0)#">
  
        <cfform name="search_project" id="search_project" enctype="multipart/form-data" method="post"  action="#request.self#?fuseaction=project.popup_project_work&main_project_id=#attributes.main_project_id#">
        <cf_box_elements>
            <cfinput type="hidden" name="modal_id" id="modal_id" value="#attributes.modal_id#">
            <input type="hidden" name="is_submit" value="1">
            <div class='col col-4 col-md-6 col-sm-6 col-xs-12'>
                <div class="form-group">            
					<label class="col col-4  col-md-4 col-sm-4 col-xs-12"><cf_get_lang dictionary_id='36068.Import Tipi'></label> 
                    <div class='col col-7 col-md-7 col-sm-7 col-xs-12'>
						<select name="import_type" id="import_type" onchange="imp_type();">
                            <option value="1" selected="selected"><cf_get_lang dictionary_id='58445.İş'> <cf_get_lang dictionary_id ='52718.Import'></option>
                            <option value="2"<cfif isDefined('attributes.import_type') and attributes.import_type eq import_type>selected</cfif>><cf_get_lang dictionary_id='38268.İş İlişki'> <cf_get_lang dictionary_id ='52718.Import'></option>                                
                        </select>
					</div>
				</div>
                <div class="form-group" id="form_ul_project" style="display:">            
					<label class="col col-4  col-md-4 col-sm-4 col-xs-12"><cf_get_lang dictionary_id='57416.Proje'></label> 
					<div class='col col-7 col-md-7 col-sm-7 col-xs-12'>
                        <div class="input-group">
                            <input type="hidden" name="is_page" id="is_page" value="" checked="checked">
                            <input type="hidden" name="main_project_id" id="main_project_id" value="<cfoutput>#url.main_project_id#</cfoutput>">
                            <input type="hidden" name="project_id" id="project_id" value="">
                            <input type="text" name="project_head" id="project_head" value="" onchange="delete_1();" onfocus="AutoComplete_Create('project_head','PROJECT_HEAD','PROJECT_HEAD','get_project','','PROJECT_ID','project_id','list_works','3','250');"  autocomplete="off"/>
                            <span class="input-group-addon icon-ellipsis btnPointer" onclick="openBoxDraggable('<cfoutput>#request.self#?fuseaction=objects.popup_list_projects&project_head=search_project.project_head&project_id=search_project.project_id</cfoutput>');"></span>
                        </div>
					</div>
				</div>
                <div class="form-group">            
					<label class="col col-4  col-md-4 col-sm-4 col-xs-12"><cf_get_lang dictionary_id='57468.Belge'></label> 
                    <div class='col col-7 col-md-7 col-sm-7 col-xs-12'>
						<input type="file" name="uploaded_file" id="uploaded_file" style="width:210px;" onfocus="">
					</div>
				</div>
                <div class="form-group" id="form_ul_no_id_type" style="display:none">            
					<label class="col col-4  col-md-4 col-sm-4 col-xs-12"><cf_get_lang dictionary_id='59088.Tip'></label> 
                    <div class='col col-7 col-md-7 col-sm-7 col-xs-12'>
						<select name="no_id_type" id="no_id_type" >
                            <option value="1" selected="selected"><cf_get_lang dictionary_id='58445.İş'> <cf_get_lang dictionary_id='34702.IDye göre'></option>
                            <option value="2"<cfif isDefined('attributes.no_id_type') and attributes.no_id_type eq no_id_type>selected</cfif>><cf_get_lang dictionary_id='60619.İş Noya göre'></option>                                
                        </select>
					</div>
				</div>
            </div>
            <div class='col col-8 col-md-8 col-sm-8 col-xs-12'>
                <div class="form-group" id="form_ul_help_file_work">
                  
                        <cftry>
                            <cfinclude template="#file_web_path#templates/import_example/copy_work_#session.ep.language#.html">
                            <cfcatch>
                                <script type="text/javascript">
                                    alert("<cf_get_lang dictionary_id='29760.Yardım Dosyası Bulunamadı Lutfen Kontrol Ediniz'>");
                                </script>
                            </cfcatch>
                        </cftry>
                    
                <div class="form-group" id="form_ul_help_file_related_work" style="display:none">
                    <label class="col col-12 col-xs-12"></label>
                    <div class="col col-12 col-xs-12">
                        <cftry>
                            <cfinclude template="#file_web_path#templates/import_example/copy_related_work_tr.html">
                            <cfcatch>
                                <script type="text/javascript">
                                    alert("<cf_get_lang dictionary_id='29760.Yardım Dosyası Bulunamadı Lutfen Kontrol Ediniz'>");
                                </script>
                            </cfcatch>
                        </cftry>
                    </div>
                </div>
            </div>
        </cf_box_elements>
        <cf_box_footer><cf_workcube_buttons type_format="1" is_upd='0'   add_function="#iif(isdefined("attributes.draggable"),DE("kontrol_1() && loadPopupBox('search_project' , #attributes.modal_id#)"),DE(""))#"></cf_box_footer>
    </cfform>

    </cf_box>
</cfif>
	<script type="text/javascript">
	function imp_type()
	{
		if(document.search_project.import_type.value == 2){
			form_ul_no_id_type.style.display = '';
			form_ul_project.style.display = 'none';
			form_ul_help_file_work.style.display = 'none';
			form_ul_help_file_related_work.style.display = '';
		}
		else{
			form_ul_no_id_type.style.display = 'none';
			form_ul_project.style.display = '';
			form_ul_help_file_work.style.display = '';
			form_ul_help_file_related_work.style.display = 'none';
		}
	}
	function kontrol_1()
	{
		if((document.getElementById('project_id').value == "" || document.getElementById('project_head').value== "") && document.getElementById('uploaded_file').value == "")
		{
			alert("<cf_get_lang dictionary_id='57471.Eksik Veri'> : <cf_get_lang dictionary_id='57416.Proje'> / <cf_get_lang dictionary_id='57691.Dosya'>");
			return false;
		}
		else
			return true;
	}
	function delete_1()
	{
		document.getElementById('project_id').value='';
	}
	</script>
<cfelseif isdefined("attributes.uploaded_file") and len(attributes.uploaded_file)>
	<cfset upload_folder_ = "#upload_folder#temp#dir_seperator#">
    <cftry>   
        <cffile action = "upload" 
                filefield = "uploaded_file" 
                destination = "#upload_folder_#"
                nameconflict = "MakeUnique"  
                mode="777" charset="utf-8">
        <cfset file_name = "#createUUID()#.#cffile.serverfileext#">	
        <cffile action="rename" source="#upload_folder_##cffile.serverfile#" destination="#upload_folder_##file_name#" charset="utf-8" mode="777">
        <cfset file_size = cffile.filesize>
     <cfcatch type="Any">
		<script language="JavaScript">
			alert("<cf_get_lang dictionary_id='57455.Dosyanız Upload Edilemedi ! Dosyanızı Kontrol Ediniz '>!");
            window.location = "<cfoutput>#request.self#?fuseaction=project.popup_project_work&main_project_id=#attributes.main_project_id#</cfoutput>";
        </script>
        <cfabort>
    </cfcatch>  
    </cftry>   
    <cfset error_flag=0>
    <cfset row_error_flag = 0>
    <cftry>
        <cffile action="read" file="#upload_folder_##file_name#" variable="dosya" charset="utf-8" mode="777">
        <cffile action="delete" file="#upload_folder_##file_name#" mode="777">
    <cfcatch>
        <script language="javascript">
            alert("<cf_get_lang dictionary_id='29450.Dosya Okunamadı Karakter Seti Yanlış Seçilmiş Olabilir'>!");
            history.back();
        </script>
        <cfabort>
    </cfcatch>
    </cftry>
    <cfscript>
        CRLF = Chr(13) & Chr(10);// satır atlama karakteri
        dosya = Replace(dosya,',,',', ,','all');
        dosya = Replace(dosya,',,',', ,','all');
		dosya = Replace(dosya,';;','; ;','all');
		dosya = Replace(dosya,';;','; ;','all');
        dosya = ListToArray(dosya,CRLF);
        line_count = ArrayLen(dosya);
        liste = "";
    </cfscript>
	<cfset aktarim_proje_id = attributes.main_project_id>   
    <cfset related_works_all = ''>  <!---  related_works_all format: 18@;19FS+3 days;25SF+5 days; £ 21@;234FS+5,4 days;675SF+1 days;--->
    <cfset work_relations = ''>
    <cfloop from="2" to="#line_count#" index="k">
    	 <cftry> 
        	<cfscript>				
				if(attributes.import_type == 1)
				{
					unique_id = Listgetat(dosya[k],1,";");
					unique_id = trim(unique_id);
					
					is_kategorisi = Listgetat(dosya[k],2,";");
					is_kategorisi = trim(is_kategorisi);
					
					asama = Listgetat(dosya[k],3,";");
					asama = trim(asama);
					
					oncelik = Listgetat(dosya[k],4,";");
					oncelik = trim(oncelik);
					
					gorevli = Listgetat(dosya[k],5,";");
					gorevli = trim(gorevli);
					
					isno = Listgetat(dosya[k],6,";");
					isno = trim(isno);
					
					konu = Listgetat(dosya[k],7,";");
					konu = trim(konu);
					
					pbskodu = Listgetat(dosya[k],8,";");
					pbskodu = trim(pbskodu);
					
					aciklama = Listgetat(dosya[k],9,";");
					aciklama = trim(aciklama);
					
					ongorulen_sure = Listgetat(dosya[k],10,";");
					ongorulen_sure = trim(ongorulen_sure);
					
					sure = Listgetat(dosya[k],11,";");
					sure = trim(sure);
					
					baslama_tarihi = Listgetat(dosya[k],12,";");
					baslama_tarihi = trim(baslama_tarihi);
					
					bitis_tarihi = Listgetat(dosya[k],13,";");
					bitis_tarihi = trim(bitis_tarihi);
					
					tahmini_miktar = Listgetat(dosya[k],14,";");
					tahmini_miktar = trim(tahmini_miktar);
					
					milestone = Listgetat(dosya[k],15,";");
					milestone = trim(milestone);
					
					is_grubu = Listgetat(dosya[k],16,";");
					is_grubu = trim(is_grubu);
					
					is_active = Listgetat(dosya[k],17,";");
					is_active = trim(is_active);
                    
                    if (listlen(dosya[k],';') gte 18){
						proje_no = Listgetat(dosya[k],18,";");
						proje_no = trim(proje_no);
					}
					else
						proje_no = '';
						
                    if (listlen(dosya[k],';') gte 19){
                        to_complete = Listgetat(dosya[k],19,";");
                        to_complete = trim(to_complete);
                    }
                    if (listlen(dosya[k],';') gte 20){
                        unit = Listgetat(dosya[k],20,";");
                        unit = trim(unit);
                    }
                    if (listlen(dosya[k],';') gte 21){ 
                        purchase_unit_price = Listgetat(dosya[k],21,";");
                        purchase_unit_price = trim(purchase_unit_price);										
                    }
                    if (listlen(dosya[k],';') gte 22){
                        sale_unit_price = Listgetat(dosya[k],22,";");
                        sale_unit_price = trim(sale_unit_price);
                    }
					if (listlen(dosya[k],';') gte 23){
						currency = Listgetat(dosya[k],23,";");
						currency = trim(currency);
					}
					else
						currency = '';	
				}
				else if(attributes.import_type == 2)
				{	
					if(attributes.no_id_type == 1){						
						main_work_id = Listgetat(dosya[k],1,";");
						main_work_id = trim(main_work_id);
					}
					else if(attributes.no_id_type == 2){
						main_work_no = Listgetat(dosya[k],1,";");
						main_work_no = trim(main_work_no);
					}					
					relation_type = Listgetat(dosya[k],2,";");
					relation_type = trim(relation_type);
					
					if(attributes.no_id_type == 1){
						related_work_id = Listgetat(dosya[k],3,";");
						related_work_id = trim(related_work_id);
					}
					else if(attributes.no_id_type == 2){
						related_work_no = Listgetat(dosya[k],3,";");
						related_work_no = trim(related_work_no);
					}
					if (listlen(dosya[k],';') gte 4){
						lag = Listgetat(dosya[k],4,";");
						lag = trim(lag);
					}
					else
						lag = '';
									
					if(relation_type == 1)
						rel_type = 'FS'; // finish-to-start
					else if(relation_type == 2) 
						rel_type = 'SF'; // start-to-finish
					else if(relation_type == 3)
						rel_type = 'SS'; // start-to-start
					else if(relation_type == 4)
						rel_type = 'FF'; // finish-to-finish			
					
					if(isdefined("main_work_id")){ // iş id verilmişse
						m_work_id = main_work_id;
					}
					else if(isdefined("main_work_no")) // iş no verilmişse verilen iş no'ya ait iş id tablodan çekilir.
					{						
						queryService = new query();
						queryService.setDatasource(dsn); 
						queryService.setName("get_work_id"); 
						queryService.addParam(name="m_work_no", value=main_work_no, cfsqltype="cf_sql_varchar");
						queryService.addParam(name="m_project_id", value=main_project_id, cfsqltype="cf_sql_varchar");
						result = queryService.execute(sql="SELECT TOP 1 WORK_ID FROM PRO_WORKS WHERE WORK_NO = :m_work_no AND PROJECT_ID =:m_project_id"); 
						get_work_id = result.getResult(); 
						m_work_id = get_work_id.work_id;	
					}
															
					if(isdefined("related_work_id")){ // ilişkili iş id verilmişse
						rel_work_id = related_work_id;
					}
					else if(isdefined("related_work_no")) // ilişkili iş no verilmişse verilen no'ya ait iş id tablodan çekilir.
					{						 
						queryService2 = new query(); 
						queryService2.setDatasource(dsn); 
						queryService2.setName("get_work_id2"); 
						queryService2.addParam(name="work_no", value=related_work_no, cfsqltype="cf_sql_varchar");
						queryService2.addParam(name="m_project_id", value=main_project_id, cfsqltype="cf_sql_varchar");
						result2 = queryService2.execute(sql="SELECT TOP 1 WORK_ID FROM PRO_WORKS WHERE WORK_NO = :work_no AND PROJECT_ID =:m_project_id"); 
						get_work_id2 = result2.getResult(); 
						rel_work_id = get_work_id2.work_id;
					}
													 	
					related_works_all_item = ''; // related_works_all_item format: 19FS+3 days;			
					related_works_all_item = related_works_all_item & rel_work_id & rel_type;
	
					if(isdefined("lag") && lag != '')
					{
						related_works_all_item = related_works_all_item & "+" & lag & " days;";
					}
					else
					{
						related_works_all_item = related_works_all_item & ";";
					}
					
					// related_works_all listi PRO_WORKS tablosuna insert etmek için kullanılıyor
					// liste formatı: workid1 @ ; relid1 reltype1 + lag1 ; relid2 reltype2 + lag2 ; £ workid2 @ ; relid3 reltype3 + lag3 ; => 18@;19FS+3 days;25SF+5,2 days; £ 131@;435FS+1,2 days;53SF+4 days;
					exists1=0;									
					related_works_all_row=''; // related_works_all_row format: 18@;19FS+3 days;25SF+5 days;									
					for(p=1; p lte listlen(related_works_all,'£'); p=p+1)
					{
						if(listgetat(listgetat(related_works_all,p,'£'),1,'@') eq m_work_id)
						{
							exists1=1;
							related_works_all_row = listgetat(related_works_all,p,'£') & related_works_all_item;
							related_works_all = listsetat(related_works_all,p,related_works_all_row,'£');	
						}									
					}
					if(exists1 neq 1){
						related_works_all_item = ";" & related_works_all_item;
						related_works_all_row = listappend(m_work_id,related_works_all_item,'@');
						related_works_all = listappend(related_works_all,related_works_all_row,'£');	
					}
										
					if(len(lag))
						lag_int =  listgetat(lag,1,','); //PRO_WORK_RELATIONS tablosunda lag int olarak tutulduğu için virgülden önceki kısmını alıyoruz
					else
						lag_int = '';
					// work_relations listi PRO_WORK_RELATIONS tablosu için kullanılıyor
					// liste formatı: workid1 $ relworkid1 $ reltype1 $ lag1 @ workid2 $ relworkid2 $ reltype2 $ lag2
					exists2=0;
					work_relation_row = '';
					for(m=1; m lte listlen(work_relations,'@'); m=m+1){						
						if(listgetat(listgetat(listgetat(work_relations,m,'@'),1,'*'),1,'$') eq m_work_id){	//aynı work idye ait relation work_relationsa önceden eklenmişse aynı satırın sonuna ilgili relationı ekle					
							exists2=1;
							work_relation_row = listgetat(work_relations,m,'@');						
							work_relation_row_item = '';
							work_relation_row_item = listappend(work_relation_row_item,m_work_id,'$');
							work_relation_row_item = listappend(work_relation_row_item,rel_work_id,'$');
							work_relation_row_item = listappend(work_relation_row_item,rel_type,'$');
							if(len(lag_int)) work_relation_row_item = listappend(work_relation_row_item,lag_int,'$');	
							work_relation_row = listappend(work_relation_row,work_relation_row_item,'*');
							work_relations = listsetat(work_relations,m,work_relation_row,'@');														
						}
					}
					if(exists2 neq 1){ // aynı work idye ait relation work_relationsa önceden eklenmemişse work_relationsın sonuna append et
						work_relation_row_item = '';											
						work_relation_row_item = listappend(work_relation_row_item,m_work_id,'$');
						work_relation_row_item = listappend(work_relation_row_item,rel_work_id,'$');
						work_relation_row_item = listappend(work_relation_row_item,rel_type,'$');
						if(len(lag_int)) work_relation_row_item = listappend(work_relation_row_item,lag_int,'$');
						work_relation_row = listappend(work_relation_row,work_relation_row_item,'*');
						work_relations = listappend(work_relations,work_relation_row,'@');
					}					
				}
            	</cfscript>  
         <cfcatch type="Any">
            <cfset liste=ListAppend(liste,#k#&'. satırda okuma sırasında hata oldu <br />',',')>
            <cfset error_flag=1>
        </cfcatch>  
        </cftry>   
        
      <cfif attributes.import_type eq 1>  
		<cfif isDefined("proje_no") and len(proje_no)>
			<cfquery name="get_pro" datasource="#DSN#">
				SELECT PROJECT_ID FROM PRO_PROJECTS WHERE PROJECT_NUMBER = '#proje_no#'
			</cfquery>
			<cfif get_pro.recordcount>
			    <cfset attributes.main_project_id = get_pro.project_id>
			<cfelse>
				<cfset attributes.main_project_id = aktarim_proje_id>
		    </cfif>
		<cfelse>
			<cfset attributes.main_project_id = aktarim_proje_id>
		</cfif>
        <cfquery name="GET_MS_UNIQUE_ID" datasource="#DSN#">
            SELECT COUNT(MS_UNIQUE_ID) COUNT FROM PRO_WORKS WHERE PROJECT_ID = #attributes.main_project_id# AND MS_UNIQUE_ID = '#unique_id#'
        </cfquery>
        <cfif isdefined("pbskodu") and len(pbskodu)>
            <cfquery name="GET_PBS_CODE_ID" datasource="#DSN3#">
                SELECT PBS_ID FROM SETUP_PBS_CODE WHERE PBS_CODE = '#pbskodu#'
            </cfquery>
        </cfif>
        <cf_date tarih='baslama_tarihi'>
        <cf_date tarih='bitis_tarihi'>           
        <cfif isdefined("baslama_tarihi") and len(baslama_tarihi) and isdate(baslama_tarihi) and len(bitis_tarihi) and isdate(bitis_tarihi) and len(konu)  and ((isdefined("to_complete") and len(to_complete) and to_complete lte 100 and to_complete gte 0) or (not (isdefined("to_complete") and len(to_complete)))) >
            <cfif get_ms_unique_id.count eq 0>
                  <cftry>    
                    <cfquery name="INS_WORK" datasource="#DSN#">
                        INSERT INTO
                            PRO_WORKS
                            (
                                MS_UNIQUE_ID,
                                WORK_CAT_ID,
                                WORK_CURRENCY_ID,
                                WORK_PRIORITY_ID,
                                PROJECT_EMP_ID,
                                WORK_NO,
                                WORK_HEAD,
                                PBS_ID,
                                WORK_DETAIL,
                                ESTIMATED_TIME,
                                DURATION,
                                TARGET_START,
                                TARGET_FINISH,
                                AVERAGE_AMOUNT,
                                IS_MILESTONE,
                                PROJECT_ID,
                                RECORD_IP,
                                RECORD_DATE,
                                RECORD_AUTHOR,
                                WORK_STATUS,
                                WORKGROUP_ID,
                                OUR_COMPANY_ID,
                                ACTIVITY_ID,
                                TO_COMPLETE,
                                AVERAGE_AMOUNT_UNIT,
                                PURCHASE_CONTRACT_AMOUNT,
                                SALE_CONTRACT_AMOUNT,
                                EXPECTED_BUDGET_MONEY
                             )
                             VALUES
                             (
                                '#unique_id#',
                                <cfif len(is_kategorisi) and is_kategorisi neq 0>#is_kategorisi#<cfelse>#xml_work_cat_id#</cfif>,
                                <cfif len(asama) and asama neq 0>#asama#<cfelse>#xml_work_currency_id#</cfif>,
                                <cfif len(oncelik) and oncelik neq 0>#oncelik#<cfelse>#xml_work_priority_id#</cfif>,
                                <cfif len(gorevli) and gorevli neq 0>#gorevli#<cfelse>#xml_project_emp_id#</cfif>,
                                <cfif len(isno)>'#isno#'<cfelse>NULL</cfif>,
                                '#konu#',
                                <cfif isdefined("pbskodu") and isdefined("get_pbs_code_id.pbs_id") and len(get_pbs_code_id.pbs_id)>#get_pbs_code_id.pbs_id#<cfelse>NULL</cfif>,
                                '#aciklama#',
                                <cfif len(ongorulen_sure)>#replace(ongorulen_sure,',','.')*60#<cfelse>NULL</cfif>,
                                <cfif len(sure)>'#replace(replace(sure,' gün',''),',','.')#'<cfelse>NULL</cfif>,
                                #baslama_tarihi#,
                                #bitis_tarihi#,
                                <cfif len(tahmini_miktar) and isNumeric(tahmini_miktar)>#tahmini_miktar#<cfelse>NULL</cfif>,
                                <cfif milestone eq 'HAYIR' or  milestone eq '0' or milestone eq ''>0<cfelse>1</cfif>,
                                #attributes.main_project_id#,
                                '#cgi.remote_addr#',
                                #now()#,
                                #session.ep.userid#,
                                <cfif is_active neq 1>0<cfelse>1</cfif>,
                                <cfif is_grubu eq 'HAYIR' and len(xml_workgroup_id)>#xml_workgroup_id#<cfelseif len(is_grubu)>#is_grubu#<cfelse>NULL</cfif>,
                                #session.ep.company_id#,
                                <cfif isdefined("activity_id") and len(activity_id)>#activity_id#<cfelse>NULL</cfif>,
                                <cfif isdefined("to_complete") and len(to_complete)>#to_complete#<cfelse>100</cfif>,
                                <cfif isdefined("unit") and len(unit)>#unit#<cfelse>NULL</cfif>,
								<cfif isdefined("purchase_unit_price") and len(purchase_unit_price)>#purchase_unit_price#<cfelse>NULL</cfif>,
                                <cfif isdefined("sale_unit_price") and len(sale_unit_price)>#sale_unit_price#<cfelse>NULL</cfif>,
                                <cfif isdefined("currency") and len(currency)>'#currency#'<cfelse>NULL</cfif>                                    
                             )  
                    </cfquery>
                     <cfcatch>
						<cfset error_flag = 1>
                        <cfset row_error_flag = 1>
                        <cfset liste=ListAppend(liste,#k#&'. satırda'&#konu#&' adlı işte database e yazma sırasında hata oldu <br />',',')>
                    </cfcatch> 
                    </cftry>    
            <cfelse>
            	 <cftry>   
                     <cfquery name="UPD_WORK" datasource="#DSN#">
                        UPDATE 
                            PRO_WORKS
                        SET
                            WORK_CAT_ID = <cfif len(is_kategorisi) and is_kategorisi neq 0>#is_kategorisi#<cfelse>#xml_work_cat_id#</cfif>,
                            WORK_CURRENCY_ID = <cfif len(asama) and asama neq 0>#asama#<cfelse>#xml_work_currency_id#</cfif>,
                            WORK_PRIORITY_ID = <cfif len(oncelik) and oncelik neq 0>#oncelik#<cfelse>#xml_work_priority_id#</cfif>,
                            PROJECT_EMP_ID = <cfif len(gorevli) and gorevli neq 0>#gorevli#<cfelse>#xml_project_emp_id#</cfif>,
                            WORK_NO = <cfif len(isno)>'#isno#'<cfelse>NULL</cfif>,
                            WORK_HEAD = '#konu#',
                            PBS_ID = <cfif isdefined("pbskodu") and isdefined("get_pbs_code_id.pbs_ids") and len(get_pbs_code_id.pbs_id)>#get_pbs_code_id.pbs_id#<cfelse>NULL</cfif>,
                            WORK_DETAIL = '#aciklama#',
                            ESTIMATED_TIME = <cfif len(ongorulen_sure)>#replace(ongorulen_sure,',','.')*60#<cfelse>NULL</cfif>,
                            DURATION = <cfif len(sure)>'#replace(replace(sure,' gün',''),',','.')#'<cfelse>NULL</cfif>,
                            TARGET_START = <cfif len(baslama_tarihi)>#baslama_tarihi#<cfelse>NULL</cfif>,
                            TARGET_FINISH = <cfif len(bitis_tarihi)>#bitis_tarihi#<cfelse>NULL</cfif>,
                            AVERAGE_AMOUNT = <cfif len(tahmini_miktar) and isNumeric(tahmini_miktar)>#tahmini_miktar#<cfelse>NULL</cfif>,
                            IS_MILESTONE = <cfif milestone eq 'HAYIR' or milestone eq '0' or milestone eq ''>0<cfelse>1</cfif>,
                            UPDATE_DATE = #now()#,
                            UPDATE_IP = '#cgi.remote_addr#',
                            UPDATE_AUTHOR = #session.ep.userid#,
                            WORK_STATUS = <cfif is_active neq 1>0<cfelse>1</cfif>,
                            WORKGROUP_ID = <cfif is_grubu eq 'HAYIR' and len(xml_workgroup_id)>#xml_workgroup_id#<cfelseif len(is_grubu)>#is_grubu#<cfelse>NULL</cfif>,
                            OUR_COMPANY_ID = #session.ep.company_id#,
                            ACTIVITY_ID = <cfif isdefined("activity_id") and len(activity_id)>#activity_id#<cfelse>NULL</cfif>,
                            TO_COMPLETE = <cfif isdefined("to_complete") and len(to_complete)>#to_complete#<cfelse>100</cfif>,
                            AVERAGE_AMOUNT_UNIT = <cfif isdefined("unit") and len(unit)>#unit#<cfelse>NULL</cfif>,
                            PURCHASE_CONTRACT_AMOUNT = <cfif isdefined("purchase_unit_price") and len(purchase_unit_price)>#purchase_unit_price#<cfelse>NULL</cfif>,
                            SALE_CONTRACT_AMOUNT = <cfif isdefined("sale_unit_price") and len(sale_unit_price)>#sale_unit_price#<cfelse>NULL</cfif>,
                            EXPECTED_BUDGET_MONEY = <cfif isdefined("currency") and len(currency)>'#currency#'<cfelse>NULL</cfif>
                        WHERE 
                            PROJECT_ID = #attributes.main_project_id# AND
                            MS_UNIQUE_ID = '#unique_id#'
                     </cfquery>
                 <cfcatch>
                     <cfset error_flag = 1>
                     <cfset row_error_flag = 1>
                     <cfset liste=ListAppend(liste,#k#&'. satırda '&#konu#&' database e yazma sırasında hata oldu <br />',',')>
                </cfcatch> 
                </cftry>   
            </cfif>
            <cfif row_error_flag eq 0>
                <cfquery name="GET_MAX_ID" datasource="#DSN#">
                    SELECT WORK_ID FROM PRO_WORKS WHERE MS_UNIQUE_ID = '#unique_id#' AND PROJECT_ID = #attributes.main_project_id# 
                </cfquery>
                <cfquery name="ADD_WORK_HISTORY" datasource="#DSN#">
                    INSERT INTO 
                        PRO_WORKS_HISTORY
                    ( 
                        MS_UNIQUE_ID,
                        WORK_CAT_ID,
                        WORK_CURRENCY_ID,
                        WORK_PRIORITY_ID,
                        PROJECT_EMP_ID,
                        WORK_NO,
                        WORK_HEAD,
                        PBS_ID,
                        WORK_DETAIL,
                        ESTIMATED_TIME,
                        DURATION,
                        TARGET_START,
                        TARGET_FINISH,
                        AVERAGE_AMOUNT,
                        IS_MILESTONE,
                        PROJECT_ID,
                        WORK_ID,
                        UPDATE_AUTHOR,
                        UPDATE_DATE,
                        WORK_STATUS,
                        WORKGROUP_ID,
                        ACTIVITY_ID,
                        TO_COMPLETE,
                        AVERAGE_AMOUNT_UNIT,
                        EXPECTED_BUDGET_MONEY 
                    ) 
                    VALUES
                    ( 
                        '#unique_id#',
                        <cfif len(is_kategorisi) and is_kategorisi neq 0>#is_kategorisi#<cfelse>#xml_work_cat_id#</cfif>,
                        <cfif len(asama) and asama neq 0>#asama#<cfelse>#xml_work_currency_id#</cfif>,
                        <cfif len(oncelik) and oncelik neq 0>#oncelik#<cfelse>#xml_work_priority_id#</cfif>,
                        <cfif len(gorevli) and gorevli neq 0>#gorevli#<cfelse>#xml_project_emp_id#</cfif>,
                        <cfif len(isno)>'#isno#'<cfelse>NULL</cfif>,
                        <cfif len(konu)>'#konu#'<cfelse>'#konu#'</cfif>,
                        <cfif isdefined("pbskodu") and isdefined("get_pbs_code_id.pbs_id") and len(get_pbs_code_id.pbs_id)>#get_pbs_code_id.pbs_id#<cfelse>NULL</cfif>,
                        '<P>#aciklama#</P>',
                        <cfif len(ongorulen_sure) and isNumeric(ongorulen_sure)>#ongorulen_sure#<cfelse>NULL</cfif>,
                        <cfif len(sure) and isNumeric(sure)>#replace(replace(sure,' gün',''),',','.')#<cfelse>NULL</cfif>,
                        #baslama_tarihi#,
                        #bitis_tarihi#,
                        <cfif len(tahmini_miktar) and isNumeric(tahmini_miktar)>#tahmini_miktar#<cfelse>NULL</cfif>,
                        <cfif milestone eq 'HAYIR' or  milestone eq '0' or milestone eq ''>0<cfelse>1</cfif>,
                        #attributes.main_project_id#,
                        #get_max_id.work_id#,
                        #session.ep.userid#,
                        #now()#,
                        <cfif isdefined("is_active") and is_active neq 1>0<cfelse>1</cfif>,
                        <cfif isdefined("is_grubu") and is_grubu eq 'HAYIR' and len(xml_workgroup_id)>#xml_workgroup_id#<cfelseif len(is_grubu)>#is_grubu#<cfelse>NULL</cfif>,
                        <cfif isdefined("activity_id") and len(activity_id)>#activity_id#<cfelse>NULL</cfif>,
                        <cfif isdefined("to_complete") and  len(to_complete)>#to_complete#<cfelse>100</cfif>,
						<cfif isdefined("unit") and len(unit)>#unit#<cfelse>NULL</cfif>,
                        <cfif isdefined("currency") and len(currency)>'#currency#'<cfelse>NULL</cfif> 
                    )
                </cfquery>
                
            <cfelse>
            	<cfset row_error_flag = 0>
            </cfif>
        <cfelse>
            <cfset error_flag = 1>
            <cfset liste=ListAppend(liste,#k#&'. satırda konu, başlangıç tarihi, bitiş tarihi ya da işin yüzdesi alanlarını kontrol ediniz<br />',',')>
        </cfif>
      
      </cfif> <!--- import_type ---> 
        
    </cfloop>
    
    <cfif attributes.import_type eq 2>
        <cfloop index = "n" from="1" to="#listlen(related_works_all,'£')#">
            <cfquery name="upd_rel_work" datasource="#dsn#">
                UPDATE
                    PRO_WORKS
                SET
                    RELATED_WORK_ID = '#listgetat(listgetat(related_works_all,n,"£"),2,"@")#'    
                WHERE 
                    WORK_ID = #listgetat(listgetat(related_works_all,n,"£"),1,"@")#	
                    <cfif isdefined("main_project_id") and len(main_project_id)>AND PROJECT_ID = #main_project_id#</cfif>
            </cfquery>
        </cfloop> 
        
        <cfloop index="relation_row" list="#work_relations#" delimiters="@">             	
            <cfquery name="del_work_relations" datasource="#dsn#">
                DELETE FROM
                    PRO_WORK_RELATIONS
                WHERE
                    WORK_ID = #listgetat(listgetat(relation_row,1,'*'),1,'$')#              
            </cfquery>
               
            <cfloop index="relation_item" list="#relation_row#" delimiters="*">   
                <cfquery name="ins_work_relations" datasource="#dsn#">        
                    INSERT INTO
                        PRO_WORK_RELATIONS
                        (
                            WORK_ID,
                            PRE_ID,
                            RELATION_TYPE,
                            LAG
                        )
                        VALUES
                        (
                            #listgetat(relation_item,1,'$')#,
                            #listgetat(relation_item,2,'$')#,
                            '#listgetat(relation_item,3,"$")#',
                            <cfif listfind(relation_item,4,'$')>#listgetat(relation_item,4,'$')#<cfelse>NULL</cfif>
                        )
                </cfquery>
            </cfloop>        
        </cfloop>
    </cfif>
    
    <cfif error_flag neq 1>
		<script type="text/javascript">
			alert("Import Edildi ");
            <cfif  isdefined("attributes.modal_id") and len(attributes.modal_id)>
                location.href = document.referrer;
            <cfelse>
                wrk_opener_reload();
                window.close();
            </cfif>
        </script>
    <cfelse>
        <br /><br />        
        <cfloop list="#liste#" index="i">
    		<cfoutput>#i#</cfoutput>
        </cfloop>
	</cfif>
<cfelse>	
	<cfquery name="GET_PRO_PROJECTS" datasource="#DSN#">
		SELECT TARGET_START,TARGET_FINISH,PARTNER_ID,COMPANY_ID FROM PRO_PROJECTS WHERE PROJECT_ID = #attributes.main_project_id#
	</cfquery>
	<!--- arkada sayfadaki baslangıc ve bitis --->
	<cfscript>
		main_sdate=date_add('h', session.ep.time_zone, get_pro_projects.target_start);
		main_fdate=date_add('h', session.ep.time_zone, get_pro_projects.target_finish);
		main_shour=datepart('h',main_sdate);
		main_fhour=datepart('h',main_fdate);
	</cfscript>

	<cfquery name="GET_PROJECT" datasource="#DSN#">
		SELECT
			PROJECT_HEAD,
			TARGET_START,
			TARGET_FINISH			
		FROM
			PRO_PROJECTS
		WHERE
			PROJECT_ID = #attributes.project_id#
	</cfquery>
	<cfscript>
		sdate=date_add('h', session.ep.time_zone, get_project.target_start);
		fdate=date_add('h', session.ep.time_zone, get_project.target_finish);
		shour=datepart('h',sdate);
		fhour=datepart('h',fdate);
		fark =datediff('d',sdate,main_sdate);
	</cfscript>	
	<cfinclude template="../query/get_priority.cfm">
	<cfinclude template="../query/get_pro_work_cat.cfm">
	<cfquery name="GET_PRO_WORKS" datasource="#DSN#">
		SELECT
			 CASE 
				WHEN IS_MILESTONE = 1 THEN WORK_ID
				WHEN IS_MILESTONE <> 1 THEN ISNULL(MILESTONE_WORK_ID,0)
			END AS NEW_WORK_ID,
			CASE 
				WHEN IS_MILESTONE = 1 THEN 0
				WHEN IS_MILESTONE <> 1 THEN 1
			END AS TYPE,
			*
		FROM
			PRO_WORKS
		WHERE
			PROJECT_ID = #attributes.project_id#
		ORDER BY
			<!--- WORK_HEAD, ---> 
			NEW_WORK_ID, 
			TYPE,
			TARGET_START 
	</cfquery>
	
	<cfset project_stage_list = "">
	<cfif listlen(project_stage_list)>
		<cfset project_stage_list = listsort(project_stage_list,'numeric','ASC',',')>
		<cfquery name="get_currency_name" datasource="#dsn#">
			SELECT PROCESS_ROW_ID,STAGE FROM PROCESS_TYPE_ROWS WHERE PROCESS_ROW_ID IN (#project_stage_list#) ORDER BY PROCESS_ROW_ID
		</cfquery>
	</cfif>
    <cfsavecontent variable="title1"><cf_get_lang dictionary_id='38213.Is'> <cf_get_lang dictionary_id='57476.Kopyala'>(<cf_get_lang dictionary_id='57416.Proje'> : <cfoutput>#get_project.project_head#</cfoutput>)</cfsavecontent>

        <cfif not isDefined("attributes.is_submit_2")>
        <cf_box title="#title1#" scroll="1" collapsable="1" resize="1" popup_box="#iif(isdefined("attributes.draggable"),1,0)#">
        <cfform name="add_project_work" method="post" action="#request.self#?fuseaction=project.emptypopup_add_project_work">
            <cfinput type="hidden" name="modal_id" id="modal_id" value="#attributes.modal_id#">	
            <input type="hidden" name="is_submit_2" value="1">	
            <input type="hidden" name="main_project_id" id="main_project_id" value="<cfoutput>#attributes.main_project_id#</cfoutput>">
            <input type="hidden" name="project_id" id="project_id" value="<cfoutput>#attributes.project_id#</cfoutput>">
            <input type="hidden" name="record_num" id="record_num" value="<cfoutput>#get_pro_works.recordcount#</cfoutput>">
            <!--- Proje baslangic ve bitis --->
            <input type="hidden" name="p_sdate" id="p_sdate" value="<cfoutput>#dateformat(get_pro_projects.target_start,dateformat_style)#</cfoutput>">
            <input type="hidden" name="p_fdate" id="p_fdate" value="<cfoutput>#dateformat(get_pro_projects.target_finish,dateformat_style)#</cfoutput>">           
            <cf_grid_list>
                <thead>
                    <tr>
                        <th class="form-title" style="width:20px;"><cf_get_lang dictionary_id='57487.No'></th>
                        <th class="form-title"><cf_get_lang dictionary_id='57480.Başlık'></th>
                        <th class="form-title" style="width:112px;"><cf_get_lang dictionary_id='57569.Görevli'></th>
                        <th class="form-title" style="width:100px;"><cf_get_lang dictionary_id='57485.Öncelik'></th>
                        <th class="form-title" style="width:170px;"><cf_get_lang dictionary_id='57501.Baslangıc'></th>
                        <th class="form-title" style="width:170px;"><cf_get_lang dictionary_id='57502.Bitiş'></th>
                        <th class="form-title" style="width:100px;"><cf_get_lang dictionary_id='57482.Aşama'></th>
                        <th class="form-title" style="width:100px;"><cf_get_lang dictionary_id='57486.Kategori'></th>
                        <th class="form-title" style="width:150px;">Milestone</th>
                        <th class="form-title" style="width:50px;">CC <cf_get_lang dictionary_id='57476.Kopyala'></th>
                        <th class="form-title" style="width:30px;"><cf_get_lang dictionary_id='36212.Mail'></th>
                        <th class="form-title" style="width:30px;"><cfif get_pro_works.recordcount><input type="checkbox" name="all_work" id="all_work" value="1" onclick="hepsini_sec();" checked></cfif></th>
                    </tr>
                    </thead>
                <cfif get_pro_works.recordcount>
                    <cfoutput query="get_pro_works">
                        <cfscript>
                            row_sdate=date_add('h',session.ep.time_zone, date_add('d',fark,get_pro_works.target_start));
                            row_fdate=date_add('h',session.ep.time_zone, date_add('d',fark,get_pro_works.target_finish));
                            row_shour=datepart('h',row_sdate);
                            row_fhour=datepart('h',row_fdate);
                        </cfscript>
                        <tr id="frm_row#currentrow#" onmouseover="this.className='color-light';" onmouseout="this.className='color-row';" class="color-row">                        
                            <td><div class="form-group">#currentrow#</div></td>
                            <td>
                                <div class="form-group">
                                    <input type="text" class="boxtext" name="work_head#currentrow#" id="work_head#currentrow#" <cfif type eq 0>style="color:red;font-weight:bold;width:250px;"<cfelse></cfif> value='<cfif type eq 0>(M) #work_head#<cfelse>#work_head#</cfif>'>
                                </div>
                            </td>
                            <td>
                                <div class="form-group">
                                    <div class="input-group">
                                        <cfif get_pro_works.project_emp_id neq 0 and len(get_pro_works.project_emp_id)>
                                            <cfset person="#get_emp_info(get_pro_works.project_emp_id,0,0)#">
                                        <cfelseif get_pro_works.outsrc_partner_id neq 0 and len(get_pro_works.outsrc_partner_id)>
                                            <cfset person="#get_par_info(get_pro_works.outsrc_partner_id,0,0,0)#">
                                        <cfelse>
                                            <cfset person="">
                                        </cfif>
                                        <input type="hidden" name="task_company_id#currentrow#" id="task_company_id#currentrow#" value="#get_pro_works.outsrc_cmp_id#">
                                        <input type="hidden" name="task_partner_id#currentrow#" id="task_partner_id#currentrow#" value="#get_pro_works.outsrc_partner_id#">
                                        <input type="hidden" name="project_emp_id#currentrow#" id="project_emp_id#currentrow#" value="#get_pro_works.project_emp_id#">
                                        <input type="text" class="boxtext" name="responsable_name#currentrow#" id="responsable_name#currentrow#" value="#person#" onfocus="AutoComplete_Create('responsable_name#currentrow#','MEMBER_NAME','MEMBER_NAME','get_member_autocomplete','\'1,2,3\'','EMPLOYEE_ID,COMPANY_ID,PARTNER_ID','project_emp_id#currentrow#,task_company_id#currentrow#,task_partner_id#currentrow#','add_project_work',3,'150')" style="width:90px;">
                                        <span class="input-group-addon" href="javascript://" onclick="windowopen('#request.self#?fuseaction=objects.popup_list_positions&field_partner=add_project_work.task_partner_id#currentrow#&field_comp_id=add_project_work.task_company_id#currentrow#&field_emp_id=add_project_work.project_emp_id#currentrow#&field_name=add_project_work.responsable_name#currentrow#&field_comp_name=add_project_work.responsable_name#currentrow#&select_list=1,7','list');"></span>
                                    </div>
                                </div>
                            </td>
                            <td>
                                <div class="form-group">
                                    <select name="priority_cat#currentrow#" id="priority_cat#currentrow#" style="width:100px;">
                                        <cfloop query="get_cats">
                                            <option value="#priority_id#" <cfif get_pro_works.work_priority_id is priority_id>selected</cfif>>#priority#</option>
                                        </cfloop>
                                    </select>
                                </div>
                            </td>
                            <td>
                                <div class="form-group">
                                    <div class="input-group">
                                        <input type="text" name="work_h_start#currentrow#" id="work_h_start#currentrow#" value="#dateformat(row_sdate,dateformat_style)#" maxlength="10"  style="width:80px!important;">
                                        <span class="input-group-addon"><cf_wrk_date_image date_field="work_h_start#currentrow#"></span>
                                        <select name="start_hour#currentrow#" id="start_hour#currentrow#" style="width:65px!important;">
                                            <cfloop from="0" to="23" index="i">
                                                <option value="#i#" <cfif i eq row_shour>selected</cfif>>#i#:00</option>
                                            </cfloop>
                                        </select>
                                    </div>                          
                                </div>
                            </td>
                            <td>
                                <div class="form-group">
                                    <div class="input-group">
                                         <input type="text" name="work_h_finish#currentrow#" id="work_h_finish#currentrow#" value="#dateformat(row_fdate,dateformat_style)#" maxlength="10" style="width:80px!important;">
                                        <span class="input-group-addon"><cf_wrk_date_image date_field="work_h_finish#currentrow#"></span>
                                        <select name="finish_hour#currentrow#" id="finish_hour#currentrow#" style="width:65px!important;">
                                            <cfloop from="0" to="23" index="i">
                                                <option value="#i#" <cfif i eq row_fhour>selected</cfif>>#i#:00</option>
                                            </cfloop>
                                        </select>
                                    </div>
                                </div>
                            </td>
                            <td>
                                <cfif xml_is_stage_cat>
                                    <cfquery name="process_" dbtype="query">
                                        SELECT PROCESS_ID FROM process WHERE WORK_CAT_ID = #get_pro_works.work_cat_id#
                                    </cfquery>
                                    <cfif process_.recordcount and len(process_.PROCESS_ID)>
                                        <cfquery name="get_procurrency_" dbtype="query">
                                            SELECT * FROM get_procurrency WHERE PROCESS_ROW_ID IN (#process_.PROCESS_ID#)
                                        </cfquery>
                                    </cfif>
                                </cfif>
                                <div class="form-group">
                                    <select name="work_currency_id#currentrow#" id="work_currency_id#currentrow#" style="width:120px; height:17px;">
                                        <option value=""><cf_get_lang dictionary_id='57482.Asama'></option>
                                        <cfif isdefined("get_procurrency_")>
                                            <cfloop query="get_procurrency_">
                                                <option value="#PROCESS_ROW_ID#" <cfif get_pro_works.work_currency_id eq PROCESS_ROW_ID>selected</cfif>>#STAGE#</option>
                                            </cfloop>
                                        <cfelse>
                                            <cfloop query="get_procurrency">
                                                <option value="#PROCESS_ROW_ID#" <cfif get_pro_works.work_currency_id eq PROCESS_ROW_ID>selected</cfif>>#STAGE#</option>
                                            </cfloop>
                                        </cfif>
                                    </select>
                                </div>
                            </td> 
                            <td>
                                <div class="form-group">
                                    <select name="pro_work_cat#currentrow#" id="pro_work_cat#currentrow#" style="width:100px;">
                                        <cfloop query="get_work_cat">
                                            <option value="#work_cat_id#"<cfif get_pro_works.work_cat_id eq work_cat_id>selected</cfif>>#work_cat#</option>
                                        </cfloop>
                                    </select>
                                </div>			
                            </td>
                            <td style="text-align:right;">
                                <div class="form-group">
                                    <div class="input-group">
                                        <input type="checkbox" value="1" name="is_milestone#currentrow#" id="is_milestone#currentrow#" <cfif get_pro_works.is_milestone eq 1>checked</cfif>>
                                         <span class="input-group-addon"></span>
                                        <select name="milestone_work_id#currentrow#" id="milestone_work_id#currentrow#" style="width:120px;">
                                            <option value=""><cf_get_lang dictionary_id='57734.Seçiniz'></option>
                                            <cfif len(get_pro_works.project_id)>
                                                <cfquery name="GET_WORK_MILESTONE" datasource="#DSN#">
                                                    SELECT 
                                                        WORK_ID,
                                                        WORK_HEAD 
                                                    FROM 
                                                        PRO_WORKS 
                                                    WHERE 
                                                        PROJECT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#get_pro_works.project_id#"> AND
                                                        IS_MILESTONE = 1 AND
                                                        WORK_ID <> #get_pro_works.work_id#
                                                </cfquery>
                                                <cfloop query="get_work_milestone">
                                                    <option value="#work_id#"<cfif get_pro_works.milestone_work_id eq work_id>selected</cfif>>#work_head#</option>
                                                </cfloop>
                                            </cfif>
                                        </select>
                                    </div>	
                                </div>
                            </td>
                            <td style="text-align:right;"><div class="form-group"><input type="checkbox" value="1" name="copy_cc#currentrow#" id="copy_cc#currentrow#"></div></td>
                            <td style="text-align:right;"><div class="form-group"><input type="checkbox" value="1" name="mail#currentrow#" id="mail#currentrow#"></div></td>
                            <td style="width:20px;">
                                <div class="form-group">
                                    <input type="hidden" name="work_id#currentrow#" id="work_id#currentrow#" value="#work_id#">
                                    <input type="hidden" name="related_work_id#currentrow#" id="related_work_id#currentrow#" value="#related_work_id#">
                                    <input type="hidden" name="our_company_id#currentrow#" id="our_company_id#currentrow#" value="#our_company_id#" />
                                    <input type="checkbox" name="work_select#currentrow#" id="work_select#currentrow#" checked>
                                    <input type="hidden" name="purchase_contract_amount#currentrow#" id="purchase_contract_amount#currentrow#" value="#purchase_contract_amount#">
                                    <input type="hidden" name="sale_contract_amount#currentrow#" id="sale_contract_amount#currentrow#" value="#sale_contract_amount#">
                                </div>
                            </td>
                        </tr>
                    </cfoutput>                
                <cfelse>
                    <tr class="color-row">
                        <td colspan="12"><cf_get_lang dictionary_id='57484.Kayıt Yok'> !</td>
                    </tr>
                </cfif>
            </cf_grid_list>
            <cfif get_pro_works.recordcount>
                <div class="ui-info-bottom flex-end"><cf_workcube_buttons is_upd='0' add_function='kontrol()'></div>
            </cfif>               
        </cfform>
	 </cf_box>
   
	<script type="text/javascript">
    function kontrol()
    {
		debugger;
        row_count = document.add_project_work.record_num.value;
    
        if(row_count == 0)
        {
            alert("<cf_get_lang dictionary_id ='38438.Seçilen Projede İş Kaydı Bulunmamaktadır'> !");
            return false;
        }
        
        tarih2_ = document.add_project_work.p_sdate.value.substr(6,4) + document.add_project_work.p_sdate.value.substr(3,2) + document.add_project_work.p_sdate.value.substr(0,2);
        tarih4_ = document.add_project_work.p_fdate.value.substr(6,4) + document.add_project_work.p_fdate.value.substr(3,2) + document.add_project_work.p_fdate.value.substr(0,2);
        
        kontrol_ = 0;
        
        if(row_count != 0)
        {
			appendString1 = '';
			appendString2 = '';
            for(i=1;i<=row_count;i++)
            {	
                deger_work_select = eval("document.add_project_work.work_select"+i);
                deger_work_head = eval("document.add_project_work.work_head"+i);
                deger_work_h_start = eval("document.add_project_work.work_h_start"+i);
                deger_start_hour = eval("document.add_project_work.start_hour"+i);
                deger_work_h_finish = eval("document.add_project_work.work_h_finish"+i);
                deger_finish_hour = eval("document.add_project_work.finish_hour"+i);
                deger_work_currency = eval("document.add_project_work.work_currency_id"+i);		
                
            
                if(deger_work_select.checked==true)
                {
                    if(deger_work_head.value == "")
                    {
                        alert (i + ".<cf_get_lang dictionary_id='57471.Eksik Veri'> : <cf_get_lang dictionary_id ='58820.Başlık'>");
                        return false;
                    }
    
                    if (deger_work_h_start.value == "")
                    {
                        alert (i + ".<cf_get_lang dictionary_id='57471.Eksik Veri'> : <cf_get_lang dictionary_id ='58053.Başlangıç Tarihi'>");
                        return false;
                    }
    
                    if (deger_work_h_finish.value == "")
                    {
                        alert (i + ".<cf_get_lang dictionary_id='57471.Eksik Veri'> : <cf_get_lang dictionary_id ='57700.Bitiş Tarihi'>");
                        return false;
                    }
                    if (deger_work_currency.value == "")
                    {
                        alert (i + ".<cf_get_lang dictionary_id='57471.Eksik Veri'> : <cf_get_lang dictionary_id ='57482.Aşama'>");
                        return false;
                    }
                    
                    fix_date(deger_work_h_start,deger_work_h_start.name);
                    fix_date(deger_work_h_finish,deger_work_h_finish.name);
                    
                    tarih1_ = deger_work_h_start.value.substr(6,4) + deger_work_h_start.value.substr(3,2) + deger_work_h_start.value.substr(0,2);
                    tarih3_ = deger_work_h_finish.value.substr(6,4) + deger_work_h_finish.value.substr(3,2) + deger_work_h_finish.value.substr(0,2);
    
                    if(tarih1_ < tarih2_)
                    {
						appendString1 += i + ". ";
                        	
                    }
                    
                    if(tarih3_ > tarih4_)
                    {	
						appendString2 += i + ". ";		
                    }
                     
                    if(tarih1_ > tarih3_ || (tarih1_ == tarih3_ && (parseInt(deger_start_hour.value) >= parseInt(deger_finish_hour.value))))
                    {
                        alert(i + ". <cf_get_lang dictionary_id ='38436.Satır Başlangıç Tarihi ile Bitiş Tarihi Kontrol Ediniz'>!");
                        return false;			
                    }
                    
                    kontrol_++;			
                }						
            }
			if(appendString1 != '')
			alert(appendString1 + " " + "<cf_get_lang dictionary_id ='38250.Satır/Satırlarında Başlangıç Tarihi Projenin Başlangıç Tarihinden Küçük'>!!!");
			if(appendString2 != '')
			alert(appendString2 + " " + "<cf_get_lang dictionary_id ='38255.Satır/Satırlarında Başlangıç Tarihi Projenin Bitiş Tarihinden Büyük'>!!!");
        }
        
        if(kontrol_ == 0)
        {
            alert("<cf_get_lang dictionary_id='57471.Eksik Veri'> : <cf_get_lang dictionary_id ='58445.İş '>");
            return false;
        }
    }
    function hepsini_sec()
    {	
        if (document.add_project_work.all_work.checked)
        {
            <cfoutput query="get_pro_works">
              document.add_project_work.work_select#currentrow#.checked = true;
            </cfoutput>
        }
        else
        {
            <cfoutput query="get_pro_works">
              document.add_project_work.work_select#currentrow#.checked = false;
            </cfoutput>
        }
    }
    </script>
</cfif>
</cfif>
