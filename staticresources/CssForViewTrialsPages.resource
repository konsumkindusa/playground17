 #toPopup {
	font-family: "lucida grande", tahoma, verdana, arial, sans-serif;
	background: none repeat scroll 0 0 #FFFFFF;
	border: 10px solid #707070;
	border-radius: 2px 2px 2px 2px;
	color: #333333;
	display: none;
	font-size: 12px;
	left: 38%;
	margin-left: -450px;
	position: fixed;
	top: 10%;
	width: 700;
	z-index: 9999;
	display: inline-block;
	max-width: 1200px;
}

div.loader {
	background: url("../img/loading.gif") no-repeat scroll 0 0 transparent;
	height: 32px;
	width: 32px;
	display: none;
	z-index: 9999;
	top: 40%;
	left: 50%;
	position: absolute;
	margin-left: -10px;
}

div.close {
	background: url("../img/closebox.png") no-repeat scroll 0 0 transparent;
	cursor: pointer;
	height: 30px;
	position: absolute;
	right: -27px;
	top: -24px;
	width: 30px;
}

div#popup_content {
	margin: 4px 7px;
	overflow-y: scroll;
	height: 400px;
}