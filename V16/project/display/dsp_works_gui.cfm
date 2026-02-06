<cfparam name="attributes.CURRENCY" default="">
<cfparam name="attributes.keyword" default="">
<cfparam name="attributes.rency" default="">
<cfparam name="attributes.priority_cat" default="">
<cfparam name="attributes.work_cat" default="">
<cfparam name="attributes.comp_name" default="">
<cfparam name="attributes.comp_id" default="">
<cfparam name="attributes.startdate" default="">
<cfparam name="attributes.finishdate" default="">
<cfparam name="attributes.work_status" default="1">
<cfparam name="attributes.project_head" default="">
<cfparam name="attributes.project_id" default="">
<cfparam name="attributes.recorder_id" default="">
<cfparam name="attributes.recorder_name" default="">
<cfparam name="attributes.upd_by_id" default="">
<cfparam name="attributes.upd_by_name" default="">
<cfparam name="attributes.task_company_id" default="">
<cfparam name="attributes.outsrc_partner_id" default="">
<cfparam name="attributes.workgroup_id" default="">
<cfparam name="attributes.cc_emp_id" default="">
<cfparam name="attributes.cc_par_id" default="">
<cfparam name="attributes.cc_name" default="">
<cfparam name="attributes.show_milestone" default="1">
<cfparam name="attributes.special_definition" default="">
<cfparam name="attributes.to_complete" default="">
<cfparam name="attributes.is_form_submitted" default="1">
<cfparam name="attributes.activity_id" default="">
<cfif isdefined('xml_work_sort_type') and len(xml_work_sort_type)>
	<cfparam name="attributes.ordertype" default="#xml_work_sort_type#">
</cfif>
	<cfparam name="attributes.expense_code" default="">
	<cfparam name="attributes.expense_code_name" default="">
	<cfparam name="attributes.contract_id" default="">
	<cfparam name="attributes.contract_no" default="">
<cfif session.ep.our_company_info.workcube_sector is 'tersane'>
	<cfparam name="attributes.pbs_id" default="">
	<cfparam name="attributes.pbs_code" default="">
</cfif>
<cfif not isdefined("attributes.project_emp_id")>
	<cfset attributes.project_emp_id = session.ep.userid>
	<cfset attributes.emp_name = get_emp_info(session.ep.userid,0,0)>
</cfif>
<cfif len(attributes.startdate)><cf_date tarih="attributes.startdate"></cfif>
<cfif len(attributes.finishdate)><cf_date tarih="attributes.finishdate"></cfif>
<cfquery name="GET_BRANCHES" datasource="#DSN#">
	SELECT
		BRANCH.BRANCH_STATUS,
		BRANCH.HIERARCHY,
		BRANCH.HIERARCHY2,
		BRANCH.BRANCH_ID,
		BRANCH.BRANCH_NAME,
		OUR_COMPANY.COMP_ID,
		OUR_COMPANY.COMPANY_NAME,
		OUR_COMPANY.NICK_NAME
	FROM
		BRANCH,
		OUR_COMPANY
	WHERE
		BRANCH.BRANCH_ID IS NOT NULL
		AND BRANCH.COMPANY_ID = OUR_COMPANY.COMP_ID
		AND BRANCH.BRANCH_STATUS = 1
	ORDER BY
		OUR_COMPANY.NICK_NAME,
		BRANCH.BRANCH_NAME
</cfquery>
<cfquery name="GET_WORKGROUPS" datasource="#DSN#">
	SELECT 
		WORKGROUP_ID,
		WORKGROUP_NAME
	FROM 
		WORK_GROUP
	WHERE
		STATUS = 1 AND
		HIERARCHY IS NOT NULL
	ORDER BY 
		WORKGROUP_NAME
</cfquery>
<cfif isdefined("attributes.is_form_submitted")>
	<cfinclude template="../query/get_works.cfm">
<cfelse>
	<cfset get_works.recordcount=1>
</cfif>
<cfif isdefined("xml_is_stage_cat") and xml_is_stage_cat eq 1 and len(attributes.work_cat)>
	<cfquery name="list_process" datasource="#dsn#">
    	SELECT PROCESS_ID FROM PRO_WORK_CAT WHERE WORK_CAT_ID = #attributes.work_cat#
    </cfquery>
</cfif>
<cfquery name="GET_PROCURRENCY" datasource="#DSN#">
	SELECT
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
       <cfif isdefined("xml_is_stage_cat") and xml_is_stage_cat eq 1 and isdefined("list_process") and len(list_process.process_id)>
       		PTR.PROCESS_ROW_ID IN (#valuelist(list_process.process_id,',')#)
       <cfelse>
            PT.FACTION LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%project.works%">
        </cfif>
	ORDER BY
		PTR.LINE_NUMBER
</cfquery>
<cfquery name="GET_SPECIAL_DEFINITION" datasource="#dsn#">
	SELECT SPECIAL_DEFINITION_ID,SPECIAL_DEFINITION FROM SETUP_SPECIAL_DEFINITION WHERE SPECIAL_DEFINITION_TYPE = 7
</cfquery>
<cfquery name="GET_ACTIVITY" datasource="#DSN#">
	SELECT ACTIVITY_ID, ACTIVITY_NAME FROM SETUP_ACTIVITY WHERE ACTIVITY_STATUS = 1 ORDER BY ACTIVITY_NAME
</cfquery>
<cfparam name="attributes.page" default=1>
<cfparam name="attributes.maxrows" default='#session.ep.maxrows#'>
<cfparam name="attributes.totalrecords" default="#get_works.recordcount#">
<cfset attributes.startrow=((attributes.page-1)*attributes.maxrows)+1>
<link rel="stylesheet" type="text/css" href="/documents/todo.css"/>
<div class="row myhomeBox">
 	<div class="col col-2">
    	<div class="row">
            <div class="col col-12 divBox">
                <div class="row divBox-Head text-left font-green-sharp">Aşamalar</div>
                <div class="row">  
                    <div class="col col-12 ">
                    	<ul class="hoverList">
							<cfif not (isdefined("xml_is_stage_cat") and xml_is_stage_cat eq 1 and not len(attributes.work_cat))>
								<cfoutput query="get_procurrency">
									<li>
									<a href="javascript:;" onclick="filterCurrency(#process_row_id#);">
									<span class="badge color-#UCase(left(stage,1))#"> 6 </span>#stage#</a>
									</li>
								</cfoutput>
							</cfif>
                        </ul>
                    </div>               
                </div><!--row-->
            </div>
        </div>
        <div class="row">
            <div class="col col-12 divBox">
                <div class="row divBox-Head text-left font-green-sharp">Bilgi Verilecekler</div>
                <div class="row">  
                    <div class="col col-12">
                        <ul class="hoverList"> 
                           <li><strong>Emin Yaşartürk</strong><i class="icon-minus btnPointer pull-right"></i></li>                                                 
                           <li><strong>Fatih Ayık</strong><i class="icon-minus btnPointer pull-right"></i></li>                            
                        </ul> 
                    </div>               
                </div><!--row-->
            </div>
        </div>
        <div class="row">
            <div class="col col-12 divBox">
                <div class="row divBox-Head text-left font-green-sharp">Developmet Notlar</div>
                <div class="row">  
                    <div class="col col-12">
                        <div class="form-group" style="margin:0;"> 
                            <textarea rows="4">dev ortamındaki xyz şablonunun aynısıdır.</textarea>
                        </div>
                    </div>               
                </div><!--row-->
            </div>
        </div>
    </div>
    <div class="col col-10" style=" height:500px;">    
        <div class="row">
            <div class="col col-12 divBox">
                <div class="row divBox-Head text-left font-green-sharp"><span class="headHelper">93840&nbsp;:&nbsp;</span>Catalyst Görsel tasarım düzenlemeleri</div>
                <div class="row">  
                    <div class="col col-12" style="">
                    	<div class="row">
                       		<div class="col col-5">
                            	<div class="todo-tasklist">
									<cfif get_works.recordcount>
										<cfoutput query="get_works" startrow="#attributes.startrow#" maxrows="#attributes.maxrows#">
											<cfif isdefined("attributes.project_emp_id") and len(attributes.project_emp_id) and len(attributes.emp_name) and attributes.project_emp_id neq project_emp_id><cfset _row_font_color_ ='FF6633'><cfelse><cfset _row_font_color_ =''></cfif>
												<div class="todo-tasklist-item todo-tasklist-item-border-green">
													<img class="todo-userpic pull-left" src="../documents/hr/BC3FC5D8-95C1-1540-B1BE9C32445E1BAF.jpg" width="27px" height="27px">
													<div class="todo-tasklist-item-title" onclick="detailWork(#work_id#);">#work_id# - #work_head# <cfif len(get_works.project_id)><span class="projectName">#project_head#</span></cfif></div>
													<div class="todo-tasklist-item-text">Merhaba <br> #work_head#<br> işi ile ilgilenir misin? <br> kolay gelsin.</div>
													<div class="todo-tasklist-controls pull-left">
														<span class="todo-tasklist-date">
															<i class="fa fa-calendar"></i> #dateformat(TARGET_FINISH,dateformat_style)# </span>
														<span class="todo-tasklist-badge badge  color-#UCase(left(stage,1))#">#stage#</span>
													</div>
												</div>
										</cfoutput>
									</cfif>
                                	<div class="todo-tasklist-item todo-tasklist-item-border-green">
                                        <img class="todo-userpic pull-left" src="../documents/hr/BC3FC5D8-95C1-1540-B1BE9C32445E1BAF.jpg" width="27px" height="27px">
                                        <div class="todo-tasklist-item-title">Şablon Analizi</div>
                                        <div class="todo-tasklist-item-text">İrsaliyeli satış faturası için dürekli forma uygun şablon yapılması gerekiyor.</div>
                                        <div class="todo-tasklist-controls pull-left">
                                            <span class="todo-tasklist-date">
                                                <i class="fa fa-calendar"></i> 17 Ocak 2016 </span>
                                            <span class="todo-tasklist-badge badge badge-roundless">Analiz</span>
                                        </div>
                                    </div>
                                   	<div class="todo-tasklist-item todo-tasklist-item-border-green">
                                        <img class="todo-userpic pull-left" src="../documents/hr/C0D5E0F9-155D-13CC-95B2FF51DE28147E.jpg" width="27px" height="27px">
                                        <div class="todo-tasklist-item-title">Teklif</div>
                                        <div class="todo-tasklist-item-text">Fatih ekteki şablon için müşteriye teklif verirmisin.</div>
                                        <div class="todo-tasklist-controls pull-left">
                                            <span class="todo-tasklist-date">
                                                <i class="fa fa-calendar"></i> 18 Ocak 2016 </span>
                                            <span class="todo-tasklist-badge badge badge-success">Teklif</span>
                                        </div>
                                    </div>
                                    <div class="todo-tasklist-item todo-tasklist-item-border-green">
                                        <img class="todo-userpic pull-left" src="../documents/hr/D18FC0ED-155D-1601-320CE7E9B72778F1.jpg" width="27px" height="27px">
                                        <div class="todo-tasklist-item-title">Şablon tasarımı </div>
                                        <div class="todo-tasklist-item-text">Semih ekteki şablonunu html tasarımını çıkartır mısın?</div>
                                        <div class="todo-tasklist-controls pull-left">
                                            <span class="todo-tasklist-date">
                                                <i class="fa fa-calendar"></i> 21 Ocak 2016 </span>
                                            <span class="todo-tasklist-badge badge badge-info">Kodlama</span>
                                        </div>
                                    </div> 
                                  	<div class="todo-tasklist-item todo-tasklist-item-border-yellow">
                                        <img class="todo-userpic pull-left" src="../documents/hr/5CF29DFD-155D-1601-26DC747222A5FAEE.jpg" width="27px" height="27px">
                                        <div class="todo-tasklist-item-title">Şablon Kodlama </div>
                                        <div class="todo-tasklist-item-text">Fatma şablon tasarımı hazır verileri çekermisin.?</div>
                                        <div class="todo-tasklist-controls pull-left">
                                            <span class="todo-tasklist-date">
                                                <i class="fa fa-calendar"></i> 23 Ocak 2016 </span>
                                            <span class="todo-tasklist-badge badge badge-warning">Kodlama</span>
                                        </div>
                                    </div>
                                </div>
                            </div>  
                        	<div class="col col-7">
                            	<div class="row">
                                	<div class="col col-7">
                                        <img class="todo-userpic pull-left" src="../documents/hr/D18FC0ED-155D-1601-320CE7E9B72778F1.jpg" width="50px" height="50px">
                                        <span class="todo-username pull-left">Semih AKARTUNA</span>
                                        <button type="button" class="todo-username-btn btn btn-default btn-sm">&nbsp;edit&nbsp;</button>
                                    </div>
                                    <div class="col col-5 pull-right text-right">
                                        <div class="todo-taskbody-date pull-right">
                                            <button type="button" class="todo-username-btn btn btn-default btn-sm">&nbsp; Tamamla &nbsp;</button>
                                        </div>
                                    </div>
                                </div>
                                <div class="row workDescription">
                                   <div class="col col-12 workDescription">
                                        Semih,<br />
                                        Yetki gurubu sayfasında <strong>Report solution</strong>'ını açıyorum. Altında <strong>Executive</strong>, Standart şeklinde geliyor. Sonra altında yer alan CMS'deki İçerik Yönetimi'ni açıyorum. Üst tarafta Rapor altındaki Tümünü Görsün checkbox'ını tıkladığım zaman altında yer alan checkbox'lar ile CMS'nin altında yer alan checkbox'ları da seçiyor. Buradaki JS sorununu düzeltir misin. Diğer yapmış olduğun düzenlemeleri aktardım.
                                        Kullanıcılar ekranında sil butonuna pointer tanımını da yaparsın. 
                                    </div>
                                </div>
                                <div class="row">
                                	<div class="col col-4">
                                    	<div class="row">
                                        	<div class="col col-12 workInfo">
                                            	<ul class="hoverList">                                                	
                                                    <li><strong>Güncelleyen&nbsp;:&nbsp;</strong>Emrah Kumru</li>  
                                                    <li><strong>Güncelleme Tarihi&nbsp;:&nbsp;</strong>12/01/2016 09:36</li>  
                                                    <li><strong>Başlama Tarihi&nbsp;:&nbsp;</strong>12/01/2016 09:36</li>  
                                                    <li><strong>Bitiş Tarihi&nbsp;:&nbsp;</strong>12/01/2016 09:36</li>                                                     	                                                                                                                                                    
                                                </ul>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="col col-4">
                                    	<div class="row">
                                        	<div class="col col-12 workInfo">
                                           		<ul class="hoverList"> 
                                                   <li><strong>Termin&nbsp;:&nbsp;</strong>12/01/2016 09:36</li>                                                 
                                                   <li><strong>Öngörülen Süre&nbsp;:&nbsp;</strong>5 Saat</li> 
                                                   <li><strong>Öncelik&nbsp;:&nbsp;</strong>Düşük</li> 
                                                   <li><strong>Tamamlanma Yüzdesi&nbsp;:&nbsp;</strong>% 85</li>  
                                                </ul> 
                                            </div>
                                        </div>
                                    </div>  
                                    <div class="col col-4">
                                    	<div class="row">
                                        	<div class="col col-12 workInfo" >
                                            	<ul class="hoverList">
                                              		<li><strong>Harcanan Zaman&nbsp;:&nbsp;</strong>0 Saat 5 Dk.</li> 
                                                	<li><strong>İş Kategorisi&nbsp;:&nbsp;</strong>Tasarım</li>
                                                    <li><strong>Aktivite Tipi&nbsp;:&nbsp;</strong>Kodlama</li> 
                                                    <li><strong>Aşama&nbsp;:&nbsp;</strong>Test Kontrol</li>                                                     
                                                </ul>
                                            </div>
                                        </div>
                                    </div>                                      
                                </div>
                           		<div class="row">
                                    <div id="tab-container" class="tabTodo">
                                        <div id="tab-head">
                                            <ul class="tabNav">
                                                <li class="active"><a href="#workMsg">Mesajlar</a></li>
                                                <li><a href="#workFile">Belgeler</a></li>
                                                <li><a href="#workHistory">Tarihçe</a></li>                               
                                            </ul>
                                        </div>
                                        <div style="clear:both;"></div>
                                        <div id="tab-content"> 
                                            <div id="workMsg" class="content">    
                                                <div class="form-group">
                                                                        <div class="col-md-12">
                                                                            <ul class="media-list">
                                                                                <li class="media">
                                                                                    <a class="pull-left" href="javascript:;">
                                                                                        <img class="todo-userpic" src="../documents/hr/D18FC0ED-155D-1601-320CE7E9B72778F1.jpg" width="27px" height="27px"> </a>
                                                                                    <div class="media-body todo-comment">
                                                                                        <button type="button" class="todo-comment-btn btn btn-circle btn-default btn-sm">&nbsp; Cevapla  &nbsp;</button>
                                                                                        <p class="todo-comment-head">
                                                                                            <span class="todo-comment-username">Semih Akartuna</span> &nbsp;
                                                                                            <span class="todo-comment-date">17 Sep 2014 at 2:05pm</span>
                                                                                        </p>
                                                                                        <p class="todo-text-color"> Tasarım çalışmalarına başlandı.
                                                                                            </p>
                                                                                        <!-- Nested media object -->
                                                                                        <div class="media">
                                                                                            <a class="pull-left" href="javascript:;">
                                                                                                <img class="todo-userpic" src="../documents/hr/7E2CD946-155D-1309-599E2E9706706C1E.jpg" width="27px" height="27px"> </a>
                                                                                            <div class="media-body">
                                                                                                <p class="todo-comment-head">
                                                                                                    <span class="todo-comment-username">Sevda Kurt</span> &nbsp;
                                                                                                    <span class="todo-comment-date">17 Sep 2014 at 4:30pm</span>
                                                                                                </p>
                                                                                                <p class="todo-text-color"> ekteki belgede logo var onuda eklermisin. </p>
                                                                                            </div>
                                                                                        </div>
                                                                                    </div>
                                                                                </li>
                                                                                <li class="media">
                                                                                    <a class="pull-left" href="javascript:;">
                                                                                        <img class="todo-userpic" src="../documents/hr/547C85C3-08C2-270A-949B968DE2946BBC.jpg" width="27px" height="27px"> </a>
                                                                                    <div class="media-body todo-comment">
                                                                                        <button type="button" class="todo-comment-btn btn btn-circle btn-default btn-sm">&nbsp; Cevapla &nbsp;</button>
                                                                                        <p class="todo-comment-head">
                                                                                            <span class="todo-comment-username">Emrah Kumru</span> &nbsp;
                                                                                            <span class="todo-comment-date">18 Sep 2014 at 9:22am</span>
                                                                                        </p>
                                                                                        <p class="todo-text-color"> Şablonun html hali hazır olnuca devappsrv da ilgili klasöre at.
                                                                                            Kolay gelsin.
                                                                                            <br> </p>
                                                                                    </div>
                                                                                </li>
                                                                                <li class="media">
                                                                                    <a class="pull-left" href="javascript:;">
                                                                                        <img class="todo-userpic" src="../documents/hr/D18FC0ED-155D-1601-320CE7E9B72778F1.jpg" width="27px" height="27px"> </a>
                                                                                    <div class="media-body todo-comment">
                                                                                        <button type="button" class="todo-comment-btn btn btn-circle btn-default btn-sm">&nbsp; Cevapla &nbsp;</button>
                                                                                        <p class="todo-comment-head">
                                                                                            <span class="todo-comment-username">Semih Akartuna</span> &nbsp;
                                                                                            <span class="todo-comment-date">18 Sep 2014 at 11:50am</span>
                                                                                        </p>
                                                                                        <p class="todo-text-color"> Tasarım çalışmaları tamamlandı. dosya abcd_fatura.cfm adı ile devappsrv/template/aa_sirketi/ altına atıldı
                                                                                            kodlama yapılabilir.
                                                                                            <br> </p>
                                                                                    </div>
                                                                                </li>
                                                                            </ul>
                                                                        </div>
                                                                    </div>  
                                            </div>
                                            <div id="workFile" class="content"> 
                                            	<div class="row">
                                                	<div class="col col-6">
                                                        <ul class="hoverList"> 
                                                            <li><strong>Orjinal Şablon Tasalğı</strong><i class="icon-minus btnPointer pull-right"></i></li>                                                 
                                                            <li><strong>Logo</strong><i class="icon-minus btnPointer pull-right"></i></li>                            
                                                        </ul>  
                                                    </div>
                                                </div>                                                   
                                            </div>
                                            <div id="workHistory" class="content">    
                                            	<div class="row">
                                                	<div class="col col-12">
                                                        <ul class="hoverList"> 
                                                            <li><strong>Görev Kaydı Yapıldı</strong><span class="pull-right">14.01.2016 / Perşembe</span></li>                                                
                                                            <li><strong>Belge Eklendi</strong><span class="pull-right">15.01.2016 / Cuma</span></li>  
                                                            <li><strong>Belge Eklendi</strong><span class="pull-right">15.01.2016 / Cuma</span></li>  
                                                            <li><strong>Görev Tammalandı</strong><span class="pull-right">18.01.2016 / Pazartesi</span></li>                         
                                                        </ul>  
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>  
                                </div>
                            </div>                                                      
                        </div>
                    </div>               
                </div><!--row-->
            </div> 
        </div>       
    </div>    
</div>



