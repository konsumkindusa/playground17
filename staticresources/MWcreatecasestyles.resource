html { min-height:100%; margin-bottom:1px; }
html body { height:100%; padding:0px; margin:0px; font-family:Arial, Helvetica, sans-serif; font-size:62.5%; color:#3C3C3C; line-height:140%;  overflow-y:scroll; -webkit-font-smoothing: antialiased; }

.content_container { 
    width: 93.75%; 
    padding: 0px 0px 10px 30px; 
    font-size: 1.2em;
    line-height: 160%;
    float: left;
}

.content_container h1.mwheader {
    padding-top: 18px;
    margin: 0px 0px 18px 0px;
    font-size: 17px;
    font-family: 'futura-pt-n5', 'futura-pt', 'Arial', 'Helvetica', sans-serif;
    color: #d55000;
    display: block;
}

.form_module h4 { width: auto; padding: 0px 15px; margin: 0px 0px 10px 0px; color: #000; line-height: 120%; display: block; }
.form_module h4.emphasize_color { color: #d55000; }

a { color:#005fce; text-decoration:none; }
a:hover { color:#005fce; text-decoration:underline; }
a:visited { color:#004aa0; text-decoration:none; }
a:hover { text-decoration:underline; }
a:focus, a:active { outline:none } /* Removes FF 3 Image Link Outline */


p { padding:0px; margin:0px 0px 20px 0px; }

ul { padding:0px; margin:0px 0px 20px 0px; list-style:none; }
ul li { padding:0px 0px 0px 12px; margin:0px 0px 7px 0px; list-style-type:none; background:transparent url(https://www.mathworks.com/images/nextgen/global/pic_global_bullet.gif) no-repeat 0px 7px; }
ul li ul { padding:5px 0px 0px; margin:0px 0px 7px 0px; }
ul li ul li { background:transparent url(https://www.mathworks.com/images/nextgen/global/pic_global_bullet_dash.gif) no-repeat 0px 9px;}
ol { padding:0px; margin:0px 0px 20px 0px; list-style:decimal; }
ol li { padding:0px; margin:0px 0px 7px 23px; list-style-type:decimal; background:none; }
ol li ol li { list-style-type:lower-alpha; }
ol li ul { padding-top:7px; }
ol li ul li { padding:0px 0px 0px 12px; margin:0px 0px 7px 0px; list-style-type:none; background:transparent url(https://www.mathworks.com/images/nextgen/global/pic_global_bullet.gif) no-repeat 0px 7px; }

.clear { clear: both; }

.bottom_ruled { border-bottom:1px solid #cbcbcb; }


/* link callout containers */
.callout_container {
    width: 50%; margin: 15px 0px 15px 15px;
    color: #000;
    border: 1px solid #c2c2c2;
    background-color:#F2F2F2;
}
.callout_container .bg_center_center { margin: 15px 13px; }
.callout_content { line-height:140%; overflow:hidden; background-repeat:no-repeat;}
.upsize { font-size:12px; }

.margined_10 { margin-bottom:10px !important; }
.margined_20 { margin-bottom:20px !important; }

/* Messaging: Warning */
.warning { min-height:40px; color:#3c3c3c;width:523px; padding:15px 15px 15px 62px; margin:0px 0px 20px 30px; font-size:11px; border:2px solid #aa0e13; background:transparent url(https://www.mathworks.com/images/nextgen/global/ico-error-32.png) no-repeat 15px 15px; }
.warning h3 { padding:0px; margin:0px 0px 10px; font-size:12px; color:#aa0e13;display:block; }
.warning p { padding:0px; margin:0px 0px 15px; font-weight:normal;}
.warning ul { padding:0px; margin:0px 0px 25px; list-style:none;font-weight:normal; }
.warning li { padding:0px 0px 0px 10px; margin:0px 0px 7px; list-style-type:none; background:transparent url(https://www.mathworks.com/images/nextgen/global/pic_global_bullet.gif) no-repeat 0px 5px; }
            
/* Messaging: Alert */
.alert { padding:15px 15px 15px 62px; color:#3c3c3c;width:523px; margin:0px 0px 20px 30px; min-height:40px; font-size:11px; border:2px solid #D79C40; background:transparent url(https://www.mathworks.com/images/nextgen/global/ico-alert-32.png) no-repeat 15px 15px; }
.alert h3 { padding:0px; margin:0px 0px 10px; font-size:12px; color:#D79C40; display:block;}
.alert p { padding:0px; margin:0px 0px 15px; font-weight:normal;}
.alert ul { padding:0px; margin:0px 0px 25px; list-style:none; font-weight:normal;}
.alert li { padding:0px 0px 0px 10px; margin:0px 0px 7px; list-style-type:none; background:transparent url(https://www.mathworks.com/images/nextgen/global/pic_global_bullet.gif) no-repeat 0px 5px; }
            
/* Messaging: Info */
.info { padding:15px 15px 15px 62px; color:#3c3c3c;width:523px; margin:0px 0px 20px 30px; min-height:40px; font-size:11px; border:2px solid #558bae; background:transparent url(images/ico-info-32.png) no-repeat 15px 15px; }
.info h3 { padding:0px; margin:0px 0px 10px; font-size:12px; color:#558bae; display:block;}
.info p { padding:0px; margin:0px 0px 15px; font-weight:normal;}
.info ul { padding:0px; margin:0px 0px 25px; list-style:none; font-weight:normal;}
.info li { padding:0px 0px 0px 10px; margin:0px 0px 7px; list-style-type:none; background:transparent url(https://www.mathworks.com/images/nextgen/global/pic_global_bullet.gif) no-repeat 0px 5px; }

/* Messaging: Success */
.success { padding: 15px 15px 15px 62px; color:#3c3c3c;width:523px; margin: 0px 0px 20px 30px; min-height: 40px; font-size: 11px; border: 2px solid #69a145; background: transparent url(https://www.mathworks.com/images/nextgen/global/ico-check-32.png) no-repeat 15px 15px; }
.success h3 { padding:0px; margin:0px 0px 10px; font-size:12px; color:#69a145; display:block;}
.success p { padding:0px; margin:0px 0px 15px; font-weight:normal;}
.success ul { padding:0px; margin:0px 0px 25px; list-style:none; font-weight:normal;}
.success li { padding:0px 0px 0px 10px; margin:0px 0px 7px; list-style-type:none; background:transparent url(https://www.mathworks.com/images/nextgen/global/pic_global_bullet.gif) no-repeat 0px 5px; }


/* Form Styles */
form { font-family:Arial, Helvetica, sans-serif; font-size: 11px; }
            
.wide { width:100%; background-color:#fff; display:table; }
.req { color:#FF0000; }
            
.form_container { margin-bottom:10px; border: 1px solid #d6d4d4;}
.form_container form { padding:0px; margin:0px; }
.form_container h1.form_title { width:auto; padding:10px 10px 10px 10px; margin:0px; font-size:12px; color:#000; line-height:100%; background-color:#ebf4ff; border:1px solid #d3d3d3; border-bottom:0px; display:block; }

.form_container h2 { padding:0px; margin:0px 0px 5px 0px;}
            
.form_container a { text-decoration:none; }
/* icon styles */
.form_container a.help { padding:3px 0px 3px 20px; background:transparent url(https://www.mathworks.com/images/nextgen/global/ico-help.png) no-repeat 0px 2px; display:block;line-height:normal;}
p a.request {padding: 3px 0px 3px 20px; width:230px;margin-left:370px;background:url(https://www.mathworks.com/images/nextgen/global/ico-request-16.png) 0 1px no-repeat; display: block; line-height:normal; }
a.view_all { padding-left:14px; font-size: 11px; background:transparent url(https://www.mathworks.com/images/nextgen/global/back_arrows.gif) no-repeat 0px 50%; display:block; color: #ed8000; }



.form_module { clear:both; }
.form_module p { padding:0px; margin:0px 15px 15px 15px; }
.form_module .form_element p { margin-left: 0px; }
.form_module p.field_note { padding:0px; margin:3px 0px 0px 0px; }
    
.form_module ul { padding:0px 15px 0px 15px; margin:0px 0px 15px 0px; list-style:none; }
.form_module li { padding:0px 0px 0px 12px; margin:0px 0px 7px 0px; background:transparent url(https://www.mathworks.com/images/nextgen/global/pic_global_bullet.gif) no-repeat 0px 7px; }
.form_module ol { padding:0px 15px 0px 15px; margin:0px 0px 15px 0px; list-style:decimal; }
.form_module ol li { padding:0px; margin:0px 0px 7px 20px; background:transparent none; }

.form_module h3 { padding:7px 5px 5px; margin:0px 0px 15px; color:#000; font-size:11px; text-align:left; line-height:100%; border-bottom:1px solid #99b4d2; display:block;
    background:#bbcbdf url(https://www.mathworks.com/images/nextgen/global/bg-datatable-header.png) repeat-x 0px 0px;
    background:-moz-linear-gradient(top, #cdd9e6 0%, #bbcbdf 100%); /* FF3.6+ */
    background:-webkit-gradient(linear, left top, left bottom, color-stop(0%,#cdd9e6), color-stop(100%,#bbcbdf)); /* Chrome,Safari4+ */
    background:-webkit-linear-gradient(top, #cdd9e6 0%,#bbcbdf 100%); /* Chrome10+,Safari5.1+ */
    background:-o-linear-gradient(top, #cdd9e6 0%,#bbcbdf 100%); /* Opera 11.10+ */
    background:-ms-linear-gradient(top, #cdd9e6 0%,#bbcbdf 100%); /* IE10+ */
}

.form_element { padding:0px 15px 15px 15px; margin:0px; display:block; }
.form_element label { padding:0px; margin:0px; font-weight:bold; line-height:120%; display:block; }
.form_element label.hidden { position:absolute; top:-1000px; }
            
/* Element: input-Text */
.form_element .textfield { width:244px; padding:2px; margin:0px; font-family:Arial, Helvetica, sans-serif; font-size:12px; border:1px solid #bbbbbb; }
.form_element .textfield.medium { width:150px; }
.form_element .textfield.small { width:150px; }
.form_element .field_fullwidth, .field_fullwidth { width:100%; }

/* Element: input-Radio */
.form_element .radio { padding:0px; margin:0px 0px -3px 0px; }
.radio_group { padding-bottom:15px; }
.radio_group .form_element { width:90%; padding-bottom:5px; display:table; clear:none; }
.radio_group .radio { width:12px; height:12px; margin:1px 10px 0px 0px; padding:0px; display:block; float:left; }
.radio_group label { width:90%; margin:0px; font-weight:normal; display:block; line-height:130%; float:left; clear:right; }
.radio_group .form_element p.field_note { padding-left:22px; float:none; display:block; clear:both; }

/* Element: input-Checkbox */
.form_element .checkbox { padding:0px; margin:0px 0px -3px 0px; }
.check_group { padding-bottom:15px; }
.check_group .form_element { width:90%; padding-bottom:7px; margin-bottom:1px; display:table; clear:none; }
.check_group .checkbox { width:13px; height:13px; padding:0px; margin:1px 10px 0px 0px; display:block; float:left; }
.check_group label { width:80%; margin:0px; font-weight:normal; line-height:130%; float:left; clear:right; }
.check_group .form_element p.field_note { padding-left:23px; float:none; display:block; clear:both; }
.check_group .indented { margin-left:23px; }

/* Element: button-Submit, button-Browse, button-Cancel */
.form_element .browse { width:320px; padding:2px; margin:0px; font-size:11px; }
.submit_module { padding:20px 15px; border-top:0px; font-family:Arial, Helvetica, sans-serif; background:#fff url(https://www.mathworks.com/images/forms/bg_table.gif) repeat-x bottom left; clear:both; }
.submit_module .submit { margin-bottom:15px; font-size:12px; }
.submit_module .cancel { margin-bottom:15px; margin-right:10px; font-size:12px; }

.submit_module p { padding:0px; margin:0px 0px 15px 0px; }

/* Element: Textarea */
.form_element .textarea { width:324px; height:150px; padding:2px; margin:0px; font-family:Arial, Helvetica, sans-serif; font-size:12px; }
            
/* Element: Dropdown */
.form_element .dropdown, .dropdown { width:250px; padding:1px; margin:0px; font-size:11px; border:1px solid #bbbbbb; }
.form_element .dropdown_freeform { padding:1px; margin:0px; font-size:11px; border:1px solid #bbbbbb; }

.form_element .multiselect { width:250px; height:125px; padding:2px; margin:0px; font-size:11px; border:1px solid #bbbbbb; }
            
.form_module .submit_module { float:right; background:transparent none; border-left:0px; border-right:0px; }
.form_footnote { padding:10px; font-family:Arial, Helvetica, sans-serif; font-size:11px; clear:both; }

/* Buttons */
.mwbutton, .btn { padding:0px 0px 1px 0px; line-height:130%;font-size:11px; font-weight:normal;color:#005FCE; border:1px solid #aeaeae; display:block; float:left;
	background: #ffffff; /* Old browsers */
	background: #ffffff url(https://www.mathworks.com/images/nextgen/global/bg-button-default.png) center left repeat-x; /* fallback */ /* IE6-9 */
	background: -moz-linear-gradient(top, #FFFFFF 0%, #E6E6E6 100%); /* FF3.6+ */	
	background: -webkit-gradient(linear, left top, left bottom, color-stop(0%,#FFFFFF), color-stop(100%,#E6E6E6)); /* Chrome,Safari4+ */
	background: -webkit-linear-gradient(top, #FFFFFF 0%,#E6E6E6 100%); /* Chrome10+,Safari5.1+ */
	background: -o-linear-gradient(top,  #ffffff 0%,#e6e6e6 100%); /* Opera 11.10+ */
	background: -ms-linear-gradient(top,  #ffffff 0%,#e6e6e6 100%); /* IE10+ */
	background: linear-gradient(top,  #ffffff 0%,#e6e6e6 100%); /* W3C */	
}

.mwbutton:hover, .btn:hover {
	background: #f3f3f3; /* Old browsers */
	background: #f3f3f3 url(https://www.mathworks.com/images/nextgen/global/bg-button-default-hover.png) center left repeat-x; /* fallback */ /* IE6-9 */
	background: -moz-linear-gradient(top, #f3f3f3 0%, #d7d7d7 100%); /* FF3.6+ */	
	background: -webkit-gradient(linear, left top, left bottom, color-stop(0%,#f3f3f3), color-stop(100%,#d7d7d7)); /* Chrome,Safari4+ */
	background: -webkit-linear-gradient(top, #f3f3f3 0%,#d7d7d7 100%); /* Chrome10+,Safari5.1+ */
	background: -o-linear-gradient(top,  #f3f3f3 0%,#d7d7d7 100%); /* Opera 11.10+ */
	background: -ms-linear-gradient(top,  #f3f3f3 0%,#d7d7d7 100%); /* IE10+ */
	background: linear-gradient(top,  #f3f3f3 0%,#d7d7d7 100%); /* W3C */
	color:#000;
} 

/*.mwbutton h2, .mwbutton h3, .mwbutton h4 {margin-bottom: 0;}*/
input.mwbutton, input.btn, .mwbutton a { padding:6px 10px; line-height:130%; text-decoration:none; display:block; float:left; }

.mwbutton.secondary {
	background: #275f9e; /* Old browsers */
	background: #275f9e url(https://www.mathworks.com/images/nextgen/global/bg-button-secondary.png) center left repeat-x; /* fallback */ /* IE6-9 */
	background: -moz-linear-gradient(top, #275f9e 0%, #002755 100%); /* FF3.6+ */	
	background: -webkit-gradient(linear, left top, left bottom, color-stop(0%,#275f9e), color-stop(100%,#002755)); /* Chrome,Safari4+ */
	background: -webkit-linear-gradient(top, #275f9e 0%,#002755 100%); /* Chrome10+,Safari5.1+ */
	background: -o-linear-gradient(top, #275f9e 0%,#002755 100%); /* Opera 11.10+ */
	background: -ms-linear-gradient(top, #275f9e 0%,#002755 100%); /* IE10+ */
	background: linear-gradient(top, #275f9e 0%,#002755 100%); /* W3C */
	border:1px solid #034462;
	color:#fff;
}

.mwbutton.secondary:hover {
	background: #3b68a7; /* Old browsers */
	background: #3b68a7 url(https://www.mathworks.com/images/nextgen/global/bg-button-secondary-hover.png) center left repeat-x; /* fallback */ /* IE6-9 */
	background: -moz-linear-gradient(top, #3b68a7 0%, #274166 100%); /* FF3.6+ */	
	background: -webkit-gradient(linear, left top, left bottom, color-stop(0%,#3b68a7), color-stop(100%,#274166)); /* Chrome,Safari4+ */
	background: -webkit-linear-gradient(top, #3b68a7 0%,#274166 100%); /* Chrome10+,Safari5.1+ */
	background: -o-linear-gradient(top, #3b68a7 0%,#274166 100%); /* Opera 11.10+ */
	background: -ms-linear-gradient(top, #3b68a7 0%,#274166 100%); /* IE10+ */
	background: linear-gradient(top, #3b68a7 0%,#274166 100%); /* W3C */
	color:#fff;
}

.mwbutton.secondary a, .mwbutton.secondary a:hover, .mwbutton.secondary a:visited, .mwbutton.secondary h2, .mwbutton.secondary h3, .mwbutton.secondary h4 { color:#fff; }
.rounded { border-radius:5px; -moz-border-radius:5px; -webkit-border-radius:5px; }


/* Form Errors */
.error { color:#783232; font-weight:bold; }
            
div.field_error label { padding-top:3px; padding-bottom:3px; padding-left:20px; background:transparent url(https://www.mathworks.com/images/nextgen/global/ico-error-16.png) no-repeat 0px 0px; }
div.field_error .textfield { border:1px solid #800000; background:#dfbfbf; }