; swal.ahk v0.1.1
; Copyright (c) 2021 Dillon DeRosa (known also as DMDComposer), Neutron & CJSON forked from G33kdude
; https://github.com/DMDComposer/SweetAlert2-AHK
;
; MIT License
;
; Permission is hereby granted, free of charge, to any person obtaining a copy
; of this software and associated documentation files (the "Software"), to deal
; in the Software without restriction, including without limitation the rights
; to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
; copies of the Software, and to permit persons to whom the Software is
; furnished to do so, subject to the following conditions:
;
; The above copyright notice and this permission notice shall be included in all
; copies or substantial portions of the Software.
;
; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
; AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
; OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
; SOFTWARE.
;
; -----------------------Great SweetAlert2 References---------------------------
; Variables list for Stylessheet https://github.com/sweetalert2/sweetalert2/blob/master/src/variables.scss
; Homepage with bunch of examples https://sweetalert2.github.io/

; SweetAlert2 10.16.7
; Swal2 stopped support for legacy JS so for the time being with neutron being 
; limited to only legacy JS, we are stuck with this version.

; Swal Speed Statistics
; 129.41 ms Maestrith Msgbox "m()"
; 220.55 ms without FontAwesome Pro / Free (52.08% increase from m() function)
; 265.75 ms with FontAwesome Free (18.59% increase from without)
; 586.64 ms with FontAwesome Pro (90.71% increase from without)
; the more stylesheets you load (especially from Web not Local) will increase time delay
; --------------------------SweetAlert2------------------------------
; ------------------------Info & Resources---------------------------
; the following is just a quick way to always access swal msgbox without
; the need to have an #Include <swal>. Just make sure the swal.ahk is still
; within your ahk lib folder.

; SweetAlert2 Custom Hotkeys if using DefaultActions / CustomClass
; "Esc" will close Swal2 Msgbox and return to the next line in AHK script.
; "Enter" will confirm on the focused button
; "Ctrl+C" will click Clipboard button (or denied button)
; "Ctrl+X" will ExitApp

; --- Neutron ---
; Updated Neutron to allow communication to Swal2
; in the __New method & Load method within neutron's class I added 
; the same line to each to allow sending a new instance command to the swal2 class
; "this.wnd.swal := new SweetAlert2()"
;
swal := swal()
swal() {
	static newSwal2Instance := new SweetAlert2()
	return newSwal2Instance
}
; swal := new SweetAlert2()
class SweetAlert2 {
    __New(options) {
        return this
		FileInstall, SweetAlert2\index.html, SweetAlert2\index.html
		; The built in GuiClose, GuiEscape, and GuiDropFiles event handlers will work
		; with Neutron GUIs. Using them is the current best practice for handling these
		; types of events. Here, we're using the name NeutronClose because the GUI was
		; given a custom label prefix up in the auto-execute section.
		NeutronClose:
		ExitApp
		return
    }
    __Delete() {
        this.Quit()
    }
    ; Methods
    Fire(msg,options := "",wait := "1",defaultActions := "1", customClass := "0") {
		static oOptions := {icon:"success"
						   ,timer:"1500"
						   ,iconColor:""
						   ,showCloseButton:true
						   ,theme:""
						   ,colored:false}
		
		oPositions := [ "top", "top-start", "top-end", "top-left", "top-right", "center", "center-start", "center-end", "center-left", "center-right", "bottom", "bottom-start", "bottom-end", "bottom-left", "bottom-right"]
		oIconTypes := ["success", "warning", "info", "question", "error"]
		
		; if user set options then update the oOptions object
		this.setUserOptions(options, oOptions)
		
		; msg
		vCustomClass = ; Custom Class Options https://sweetalert2.github.io/#customClass
	    	(LTrim Join`n
				className: "swal-css",
				showClass: {
	    			backdrop: "rgba(0,0,0,0.0);swal2-noanimation",
	    			popup: "",
				}
	    	)
		vDefaultActions =
	    	(LTrim Join`n
	    		.then(function (result) {
	    			if (result.isConfirmed) {
	    				//ahk.showSwalMsg(result.value)
						ahk.exitSwal()
	    			}
	    			if (result.isDenied) {
	    				ahk.setClipboard(result.value)
						ahk.exitSwal()
	    			}
					if (result.isDismissed) {
						ahk.exitApp()
					}
	    		})
	    	)
		if (!IsObject(msg)) {
			if (SubStr(msg, 1, 4) ~= "i)Swal") {
				event :=  this.cleanMsg(msg)
				; Split event and update oOptions programatically from msg even if user didn't specify in options
				for key,valueA in StrSplit(event,"`n","`n`r") {
					if (valueA ~= ":") {
						valueB := StrSplit(valueA,":")
						; need to grab valueB.2 without quotes
						oOptions[valueB.1] := valueB.2 
					}
				}
				; vFront := SubStr(event, 1, StrLen(event)-2)
   				event  := RTrim(event,"`n") (customClass ? vCustomClass ",})" : "") (defaultActions ? vDefaultActions : "")
			}
			else if (msg ~= "," && (msg ~= ",") <= 2) {
				oMsg := []
				for key,value in StrSplit(msg,",") {
					oMsg.push(LTrim(value))
				}
				msgTitle := oMsg.1
				msgHtml  := oMsg.2
				msgIcon  := oMsg.3
				; event := "Swal.fire(" vMsg ")" vDefaultActions
				event = 
	    			(LTrim Join`n
	    				Swal.fire({
	    						title: "%msgTitle%",
								html: "%msgHtml%",
	    						icon: "%msgIcon%",
								allowEscapeKey: false,
								showDenyButton: true,
								showCancelButton: true,
								confirmButtonText: this.getFaIcon("check-square") + ' Ok',
								cancelButtonText: this.getFaIcon("window-close") + ' ExitApp',
								cancelButtonColor: '#d33',
								denyButtonText: this.getFaIcon("edit") + ' Clipboard',
								denyButtonColor: "#D0A548"
	    					})
	    			) 
   				vFront := SubStr(event, 1, StrLen(event)-2)
   				event  := vFront "," (customClass ? vCustomClass : "") "})" (defaultActions ? vDefaultActions : "")
			}
			else {
				msg    := (!msg ? oOptions.html : msg)
				vTitle := oOptions.title
				vIcon  := Format("{:L}", oOptions.icon)
				event = 
	    			(LTrim Join`n
	    				Swal.fire({
	    						title: "%vTitle%",
								html: "%msg%",
	    						icon: "%vIcon%",
								allowEscapeKey: false,
								showDenyButton: true,
								showCancelButton: true,
								confirmButtonText: this.getFaIcon("check-square") + ' Ok',
								cancelButtonText: this.getFaIcon("window-close") + ' ExitApp',
								cancelButtonColor: '#d33',
								denyButtonText: this.getFaIcon("edit") + ' Clipboard',
								denyButtonColor: "#D0A548"
	    					})
	    			)
   				vFront := SubStr(event, 1, StrLen(event)-2)
   				event  := vFront "," (customClass ? vCustomClass : "") "})" (defaultActions ? vDefaultActions : "")
			}
		}
	    if (IsObject(msg)) {
			msg := this.getObj2String(msg)
			msg := this.getEscapedJS(msg)
			msg := StrReplace(msg, "\n", "<br>")
			event = 
	    			(LTrim Join`n
	    				Swal.fire({
	    						title: "%msg%",
								html: "",
	    						icon: "question",
								allowEscapeKey: false,
								showDenyButton: true,
								showCancelButton: true,
								confirmButtonText: this.getFaIcon("check-square") + ' Ok',
								cancelButtonText: this.getFaIcon("window-close") + ' ExitApp',
								cancelButtonColor: '#d33',
								denyButtonText: this.getFaIcon("edit") + ' Clipboard',
								denyButtonColor: "#D0A548"
	    					})
	    			) 
			vFront := SubStr(event, 1, StrLen(event)-2)
			event  := vFront "," (customClass ? vCustomClass : "") "})" (defaultActions ? vDefaultActions : "")
			/* 
			vFront := SubStr(cJSON.Dumps(msg), 1, StrLen(cJSON.Dumps(msg))-1)
	    	msg := vFront "," (customClass ? vCustomClass : "") "}"
	    	msg := cJSON.Loads(msg)
	    	event := "Swal.fire(" cJSON.Dumps(msg) ")" (defaultActions ? vDefaultActions : "")  
			*/
	    }
		; if something falls short in parsing through the continuation and updating oOptions
		; then the continuation will default to itself without alterations
		try
		{
			for key,value in oOptions { ; Creating a unqiue variable for each key in the oOptions
				%key% := oOptions[key]
			}
		} 
		catch e
		{
			if (e) {
				event := msg
			}
		}
		; if value of position isn't in the allowed params of position, then ignore and place in default position
		vYingYang := this.getCurrentTime()        ; if sun is not out then dark mode
		theme     := (!theme ? vYingYang : theme) ; if user hasn't set theme then fallback to ligh/dark mode
		icon      := !this.HasVal(oIconTypes, icon) ? "question" : icon
		position  := !this.HasVal(oPositions, position) ? "center" : position
		iconColor := (colored ? "white" : "")
		neutron   := this.createNeutronWindow(event,1,1,position,[icon,colored],theme,color,titleColor,stack)
		this.setSwalIcons()
		this.swalPause(wait)
	    return
    }
    Toast(msg,options := "",wait := "0",sleep := "0") {
		static oOptions := {icon:"success",timer:"1500",iconColor:"",colored:false,focus:0}
		oPositions := [ "top", "top-start", "top-end", "top-left", "top-right", "center", "center-start", "center-end", "center-left", "center-right", "bottom", "bottom-start", "bottom-end", "bottom-left", "bottom-right"]
		oIconTypes := ["success", "warning", "info", "question", "error"]

		; if user set options then update the oOptions object
		this.setUserOptions(options, oOptions)

		for key,value in oOptions { ; Creating a unqiue variable for each key in the oOptions
			%key% := oOptions[key]
		}
		; if value of position isn't in the allowed params of position, then ignore and place in default position
		icon      := !this.HasVal(oIconTypes, icon) ? "question" : icon
		position  := !this.HasVal(oPositions, position) ? "bottom-right" : position
		iconColor := (colored ? "white" : "")
		popup     := (colored ? "colored-toast" : "")
		wndStack  := (stack = 0 ? stack : 1)
		; Creating Toast defaults and timerClose, communicating with ahkTimer as well
		vAHKTimer =
		(
			var ahkTimer
    		function ahkExitTimer() {
				ahkTimer = setTimeout(function () {
					ahk.exitSwal()
				}, (Swal.getTimerLeft() ? Swal.getTimerLeft() : %timer%))
    		}
			ahkExitTimer()
		)
		event =
		(
			const Toast = Swal.mixin({
					toast: true,
					position: "%position%",
					iconColor: "%iconColor%",
					showConfirmButton: false,
					timer: %timer%,
					timerProgressBar: true,
					didOpen: function (toast) {
						toast.addEventListener("mouseenter", function () {
							Swal.stopTimer()
							if (ahkTimer) {
								clearTimeout(ahkTimer)
								ahkTimer = Swal.getTimerLeft()
							}
						})
						toast.addEventListener("mouseleave", function () {
							Swal.resumeTimer()
							ahkExitTimer()
						})
					},
					customClass: {
						popup: "%popup%",
						backdrop: "rgba(0,0,0,0.0);",
						container: "swal-toast-container"
					}
			})
			Toast.fire({
					icon: "%icon%",
					title: "%title%",
					html: "%msg%",
			})
		)
		this.createNeutronWindow(vAHKTimer "`n" event,2,0,position,[icon,colored],theme,color,titleColor,wndStack,focus)
		Sleep, % sleep
		this.swalPause(wait)
        return this.resultValue
    }
	createNeutronWindow(event,type,focus := "1",wndPosition := "bottom-right",toastColored := "", theme := "light", color := "", titleColor := "", wndStack := 1) {
		neutron := new NeutronWindow()         ; Create a new NeutronWindow and navigate to our HTML page
		neutron.Load("SweetAlert2\index.html")
		neutron.wnd.onReady(event)             ; Sending the Swal Msg Params for the Popup Msg
		neutron.Gui("+LabelSwal2MsgBox")       ; Use the Gui method to set a custom label prefix for GUI events. This code is equivalent to the line `Gui, name:+LabelNeutron` for a normal GUI.
		this.getSwalUID(neutron.UID())         ; Create UID

		; I used inspector window on Swal popups to figure out what classes/id's to target to figure out width/height params
		fireW  := this.fireWidth(neutron)
		fireH  := this.fireHeight(neutron)
		toastW := this.toastWidth(neutron)
		toastH := this.toastHeight(neutron)

		; if set theme change from default
		this.getTheme(neutron,theme)
		; m(neutron.wnd.eval("$("".swal2-container"").width()"))
		(type = 1 ? neutron.Show(this.getSwalWndPos(fireW,fireH,wndPosition)) : neutron.Show(this.getSwalWndPos(toastW,toastH,wndPosition,wndStack) " NA"))

		; Colored background for Toasts (for some reason code must be placed in this function to work)
		if (toastColored.2) {
			iconColors := {success:"#a5dc86",error:"#f27474",warning:"#f8bb86",info:"#3fc3ee",question:"#87adbd"}
			if (type = 1) {
				neutron.wnd.eval("$("".swal-html-container"").attr(""style"", ""background-color: " iconColors[toastColored.1] " !important;"")")
			}
			else if (type = 2) {
				neutron.wnd.eval("$("".swal-toast-container"").attr(""style"", ""background-color: " iconColors[toastColored.1] " !important;"")")
			}
		}

		if (color && !this.oldUID) {
			js = $(".swal2-html-container").css({ color: "%color%" })
			neutron.wnd.eval(js)
		}
		
		if (titleColor && !this.oldUID) {
			js = $(".swal2-title").css({ color: "%titleColor%" })
			neutron.wnd.eval(js)
		}

		; Focus Submit Key for Swal, so if focus is true then I can use hotkeys (Enter) to hit submit etc
		(focus ? neutron.wnd.eval("$(document).focus()") : "")
		return neutron
	}

	; static variables for targeting swal2 instances
	static newUID := ""
	static oldUID := ""
	static wnd    := "" ; shorthand to grab current window

	getSwalUID(UID := "") {
		; Wanted to figure out a way to give each swal msg a unique ID
		this.oldUID := (this.newUID ? this.newUID : "")
		this.newUID := (UID ? UID : this.newUID)
		this.wnd    := "ahk_id " this.newUID
		return UID
	}
	getTheme(neutron,theme) {
		oThemes := ["default"
				   ,"bootstrap-4"
				   ,"borderless"
				   ,"bulma"
				   ,"material-ui"
				   ,"dark"
				   ,"minimal"
				   ,"wordpress-admin"]
		if (theme = "default" || theme = "") {
			neutron.wnd.eval("$(document.body).css({ background: ""rgba(0,0,0,0.0)"" })")
			return
		}
		if (theme = "bootstrap-4") {
			js =
			(
				$('<link>')
  				.appendTo('head')
  				.attr({
  				    type: 'text/css', 
  				    rel: 'stylesheet',
  				    href: './includes/sweetalert2/themes/bootstrap-4/bootstrap-4.min.css'
  				})
			)
		}
		if (theme = "borderless") {
			js =
			(
				$('<link>')
  				.appendTo('head')
  				.attr({
  				    type: 'text/css', 
  				    rel: 'stylesheet',
  				    href: './includes/sweetalert2/themes/borderless/borderless.min.css'
  				})
				$(document.body).css({ background: "#38485F" })
				$(".swal2-timer-progress-bar").css({ background: "rgba(255, 255, 255, 0.9)" })
			)
		}
		if (theme = "bulma") {
			js =
			(
				$('<link>')
  				.appendTo('head')
  				.attr({
  				    type: 'text/css', 
  				    rel: 'stylesheet',
  				    href: './includes/sweetalert2/themes/bulma/bulma.min.css'
  				})
			)
		}
		if (theme = "material-ui") {
			js =
			(
				$('<link>')
  				.appendTo('head')
  				.attr({
  				    type: 'text/css', 
  				    rel: 'stylesheet',
  				    href: './includes/sweetalert2/themes/material-ui/material-ui.min.css'
  				})
			)
		}
		if (theme = "dark") {
			js =
			(
				$('<link>')
  				.appendTo('head')
  				.attr({
  				    type: 'text/css', 
  				    rel: 'stylesheet',
  				    href: './includes/sweetalert2/themes/dark/dark.min.css'
  				})
				$(document.body).css({ background: "#19191A" })
				$(".swal2-success-fix,.swal2-success-circular-line-left,.swal2-success-circular-line-right").css({ background: "#19191A" })
			)
		}
		if (theme = "minimal") {
			js =
			(
				$('<link>')
  				.appendTo('head')
  				.attr({
  				    type: 'text/css', 
  				    rel: 'stylesheet',
  				    href: './includes/sweetalert2/themes/minimal/minimal.min.css'
  				})
			)
		}
		if (theme = "wordpress-admin") {
			js =
			(
				$('<link>')
  				.appendTo('head')
  				.attr({
  				    type: 'text/css', 
  				    rel: 'stylesheet',
  				    href: './includes/sweetalert2/themes/wordpress-admin/wordpress-admin.min.css'
  				})
				$(document.body).css({ background: "#32373C" })
			)
		}
		neutron.wnd.eval(js)
	}
	fireWidth(neutron) {
		; m(this.getSwalCSSProperties(neutron,".swal2-contentwrapper"))
		; m(neutron.wnd.eval("$("".swal2-contentwrapper"").height()"))
		; get Width of Popup before showing
		fwTitle  := neutron.wnd.eval("$("".swal2-title"").width()")
		fwHeader := neutron.wnd.eval("$("".swal2-header"").width()")
		fwPopup  := neutron.wnd.eval("$("".swal2-popup"").width()")
		fwModal  := neutron.wnd.eval("$("".swal2-modal"").width()")
		; m(neutron.wnd.eval("$("".swal2-modal"").width()"))
		return fwPopup
	}
	fireHeight(neutron) {
		; get Height of Popup before showing
		; m(this.getSwalCSSProperties(neutron,".swal2-popup")["height"])
		fhContainer := neutron.wnd.eval("$("".swal2-container"").height()")
		fhTitle     := neutron.wnd.eval("$("".swal2-title"").height()")
		fhHeader    := neutron.wnd.eval("$("".swal2-header"").height()")
		fhPopup     := neutron.wnd.eval("$("".swal2-popup"").height()")
		fhActions   := neutron.wnd.eval("$("".swal2-actions"").height()")
		fhTimer     := neutron.wnd.eval("$("".swal2-timer-progress-bar-container"").height()")
		if (!fhTitle) {
			neutron.wnd.eval("$("".swal2-header"").height(" fhHeader - 42 ")")
		}
		; m(neutron.wnd.eval("$("".swal2-footer"").height()"))
		; m(neutron.wnd.eval("$("".swal2-html-container"").height()"))
		return fhPopup + 42
	}
	toastWidth(neutron) {
		; get Width of Popup before showing
		; m(neutron.wnd.eval("$("".swal2-html-container"").val()"))
		return neutron.wnd.eval("$("".swal2-container"").width()")
			;  + 29.01 ; Not sure why this number but from measuring final output of gui width this was the difference
			; + neutron.wnd.eval("$("".swal2-toast"").width()")
			; + neutron.wnd.eval("$("".swal2-title"").width()")
	}
	toastHeight(neutron) {
		; get Height of Popup before showing
		; if there is no title, then we must raise the header by a min to keep smooth-rounded square
		if (!neutron.wnd.eval("$("".swal2-title"").height()")) {
			x := neutron.wnd.eval("$("".swal2-header"").height()")
			y := 42
			neutron.wnd.eval("$("".swal2-header"").height(" x+y ")") 
		}
		return neutron.wnd.eval("$("".swal-toast-container"").height()") 
			 + neutron.wnd.eval("$("".swal2-timer-progress-bar-container"").height()")
			 + 17.17 ; not sure why this number
			;  + neutron.wnd.eval("$("".swal2-header"").height()")
			;  + neutron.wnd.eval("$("".swal2-content"").height()")
			;  + neutron.wnd.eval("$("".swal2-container"").height()")
	}
	getSwalWndPos(w,h,pos := "bottom-right",wndStack := 1) {
		Gui +LastFound +OwnDialogs +AlwaysOnTop ; keep toast messages always on top
		WinGetPos,,,,vTaskbarHeight, ahk_class Shell_TrayWnd ; Get Height of Windows Taskbar
		WinGetPos, , , vAltWidth,, % "ahk_id " this.newUID
		; if width from this.toastWidth() is less than 136, than grab the width from WinGetPos "vWidth"
		if (w <= 136) {
			w := vAltWidth
		}

		;set all the variables for positions/heights of the Toast Msg
		vW := w
		vH := h
		vX := ((pos = "bottom-right" || pos = "top-right" || pos = "center-right") ? A_ScreenWidth - vW : 0)
		vY := ((pos = "bottom-left" || pos = "bottom-right") ? A_ScreenHeight - (vH + vTaskbarHeight) : 0)
		if (pos = "center-left" || pos = "center-right") {
			vY := ((A_ScreenHeight - vH)/2) - vTaskbarHeight
		}
		if (pos = "center") {
			vX := (A_ScreenWidth - vW)/2
			vY := ((A_ScreenHeight - vH)/2) - vTaskbarHeight
		}
		if (this.previousSwalWnd() && wndStack) { ; if prevWnd X is the same as new X, then move wndY above prevY
			WinGetPos,vPrevX, vPrevY,vPrevW, vPrevH, % "ahk_id " this.oldUID
			; m(vPrevX,vPrevY,vPrevW,vPrevH,"new:",vX,vY,vW,vH)
			; vY := (vPrevX != vX ? vY : (vPrevY - vH))
			vY := vPrevY - vH
		}
		vPos := "w" vW " h" vH " x" vX " y" vY
		return vPos
	}
	HasVal(haystack, needle) {
		if !(IsObject(haystack)) || (haystack.Length() = 0)
			return 0
		for index, value in haystack
			if (value = needle)
				return index
		return 0
	}
	previousSwalWnd() {
		return (WinExist("ahk_id " this.oldUID) ? true : false)
	}
	swalPause(wait) {
		if (wait) {
			Gui, +hwndGuiHWND
			this.HWND := GuiHWND
	    	WinWaitClose, % "ahk_id" this.HWND ; waiting for gui to close
		}
	}
	getFaIcon(icon) {
		return "<i class='fa fa-" icon "''></i>  "
	}
	getGif(gif) {
		return "<img src='" gif "' alt='description of gif' /> "
	}
	cleanMsg(msg) {
		for key,value in StrSplit(msg,"`n","`n`r") {
			value := LTrim(value)

			; replace arrow functions
			if (value ~= "=>") {
    			vArrow := StrSplit(value,"(",,2)
				vStr   := RTrim(vArrow.1) " function (" vArrow.2
    			value  := RegExReplace(vStr, "=>" , "")
			}
			; fix .then promises from above arrow fix
			if (value ~= "i)then\sfunction") {
				value := RegExReplace(value, "\s", "(",,1)
				value := RegExReplace(value, "i)function\s\(\(", "function (")
			}
			vCleanMsg .= value "`n"
		}
		return vCleanMsg
	}
	getCurrentTime() {
		; if current time is after 7pm OR before 7am then dark, otherwise default
		return ((A_Hour >= 19 || A_Hour <= 7) ? "dark" : "default")
	}
	getRandomFaIcon() {
		; FileRead, vFaIcons, % "D:\Users\Dillon\Dropbox\AHK Scripts\Lib\SweetAlert2\includes\fontawesome-free\allIconsList.txt"
		vFaIcons := "ad,address-book,address-card,adjust,air-freshener,align-center,align-justify,align-left,align-right,allergies,ambulance,american-sign-language-interpreting,anchor,angle-double-down,angle-double-left,angle-double-right,angle-double-up,angle-down,angle-left,angle-right,angle-up,angry,ankh,apple-alt,archive,archway,arrow-alt-circle-down,arrow-alt-circle-left,arrow-alt-circle-right,arrow-alt-circle-up,arrow-circle-down,arrow-circle-left,arrow-circle-right,arrow-circle-up,arrow-down,arrow-left,arrow-right,arrow-up,arrows-alt,arrows-alt-h,arrows-alt-v,assistive-listening-systems,asterisk,at,atlas,atom,audio-description,award,baby,baby-carriage,backspace,backward,bacon,bacteria,bacterium,bahai,balance-scale,balance-scale-left,balance-scale-right,ban,band-aid,barcode,bars,baseball-ball,basketball-ball,bath,battery-empty,battery-full,battery-half,battery-quarter,battery-three-quarters,bed,beer,bell,bell-slash,bezier-curve,bible,bicycle,biking,binoculars,biohazard,birthday-cake,blender,blender-phone,blind,blog,bold,bolt,bomb,bone,bong,book,book-dead,book-medical,book-open,book-reader,bookmark,border-all,border-none,border-style,bowling-ball,box,box-open,box-tissue,boxes,braille,brain,bread-slice,briefcase,briefcase-medical,broadcast-tower,broom,brush,bug,building,bullhorn,bullseye,burn,bus,bus-alt,business-time,calculator,calendar,calendar-alt,calendar-check,calendar-day,calendar-minus,calendar-plus,calendar-times,calendar-week,camera,camera-retro,campground,candy-cane,cannabis,capsules,car,car-alt,car-battery,car-crash,car-side,caravan,caret-down,caret-left,caret-right,caret-square-down,caret-square-left,caret-square-right,caret-square-up,caret-up,carrot,cart-arrow-down,cart-plus,cash-register,cat,certificate,chair,chalkboard,chalkboard-teacher,charging-station,chart-area,chart-bar,chart-line,chart-pie,check,check-circle,check-double,check-square,cheese,chess,chess-bishop,chess-board,chess-king,chess-knight,chess-pawn,chess-queen,chess-rook,chevron-circle-down,chevron-circle-left,chevron-circle-right,chevron-circle-up,chevron-down,chevron-left,chevron-right,chevron-up,child,church,circle,circle-notch,city,clinic-medical,clipboard,clipboard-check,clipboard-list,clock,clone,closed-captioning,cloud,cloud-download-alt,cloud-meatball,cloud-moon,cloud-moon-rain,cloud-rain,cloud-showers-heavy,cloud-sun,cloud-sun-rain,cloud-upload-alt,cocktail,code,code-branch,coffee,cog,cogs,coins,columns,comment,comment-alt,comment-dollar,comment-dots,comment-medical,comment-slash,comments,comments-dollar,compact-disc,compass,compress,compress-alt,compress-arrows-alt,concierge-bell,cookie,cookie-bite,copy,copyright,couch,credit-card,crop,crop-alt,cross,crosshairs,crow,crown,crutch,cube,cubes,cut,database,deaf,democrat,desktop,dharmachakra,diagnoses,dice,dice-d20,dice-d6,dice-five,dice-four,dice-one,dice-six,dice-three,dice-two,digital-tachograph,directions,disease,divide,dizzy,dna,dog,dollar-sign,dolly,dolly-flatbed,donate,door-closed,door-open,dot-circle,dove,download,drafting-compass,dragon,draw-polygon,drum,drum-steelpan,drumstick-bite,dumbbell,dumpster,dumpster-fire,dungeon,edit,egg,eject,ellipsis-h,ellipsis-v,envelope,envelope-open,envelope-open-text,envelope-square,equals,eraser,ethernet,euro-sign,exchange-alt,exclamation,exclamation-circle,exclamation-triangle,expand,expand-alt,expand-arrows-alt,external-link-alt,external-link-square-alt,eye,eye-dropper,eye-slash,fan,fast-backward,fast-forward,faucet,fax,feather,feather-alt,female,fighter-jet,file,file-alt,file-archive,file-audio,file-code,file-contract,file-csv,file-download,file-excel,file-export,file-image,file-import,file-invoice,file-invoice-dollar,file-medical,file-medical-alt,file-pdf,file-powerpoint,file-prescription,file-signature,file-upload,file-video,file-word,fill,fill-drip,film,filter,fingerprint,fire,fire-alt,fire-extinguisher,first-aid,fish,fist-raised,flag,flag-checkered,flag-usa,flask,flushed,folder,folder-minus,folder-open,folder-plus,font,football-ball,forward,frog,frown,frown-open,funnel-dollar,futbol,gamepad,gas-pump,gavel,gem,genderless,ghost,gift,gifts,glass-cheers,glass-martini,glass-martini-alt,glass-whiskey,glasses,globe,globe-africa,globe-americas,globe-asia,globe-europe,golf-ball,gopuram,graduation-cap,greater-than,greater-than-equal,grimace,grin,grin-alt,grin-beam,grin-beam-sweat,grin-hearts,grin-squint,grin-squint-tears,grin-stars,grin-tears,grin-tongue,grin-tongue-squint,grin-tongue-wink,grin-wink,grip-horizontal,grip-lines,grip-lines-vertical,grip-vertical,guitar,h-square,hamburger,hammer,hamsa,hand-holding,hand-holding-heart,hand-holding-medical,hand-holding-usd,hand-holding-water,hand-lizard,hand-middle-finger,hand-paper,hand-peace,hand-point-down,hand-point-left,hand-point-right,hand-point-up,hand-pointer,hand-rock,hand-scissors,hand-sparkles,hand-spock,hands,hands-helping,hands-wash,handshake,handshake-alt-slash,handshake-slash,hanukiah,hard-hat,hashtag,hat-cowboy,hat-cowboy-side,hat-wizard,hdd,head-side-cough,head-side-cough-slash,head-side-mask,head-side-virus,heading,headphones,headphones-alt,headset,heart,heart-broken,heartbeat,helicopter,highlighter,hiking,hippo,history,hockey-puck,holly-berry,home,horse,horse-head,hospital,hospital-alt,hospital-symbol,hospital-user,hot-tub,hotdog,hotel,hourglass,hourglass-end,hourglass-half,hourglass-start,house-damage,house-user,hryvnia,i-cursor,ice-cream,icicles,icons,id-badge,id-card,id-card-alt,igloo,image,images,inbox,indent,industry,infinity,info,info-circle,italic,jedi,joint,journal-whills,kaaba,key,keyboard,khanda,kiss,kiss-beam,kiss-wink-heart,kiwi-bird,landmark,language,laptop,laptop-code,laptop-house,laptop-medical,laugh,laugh-beam,laugh-squint,laugh-wink,layer-group,leaf,lemon,less-than,less-than-equal,level-down-alt,level-up-alt,life-ring,lightbulb,link,lira-sign,list,list-alt,list-ol,list-ul,location-arrow,lock,lock-open,long-arrow-alt-down,long-arrow-alt-left,long-arrow-alt-right,long-arrow-alt-up,low-vision,luggage-cart,lungs,lungs-virus,magic,magnet,mail-bulk,male,map,map-marked,map-marked-alt,map-marker,map-marker-alt,map-pin,map-signs,marker,mars,mars-double,mars-stroke,mars-stroke-h,mars-stroke-v,mask,medal,medkit,meh,meh-blank,meh-rolling-eyes,memory,menorah,mercury,meteor,microchip,microphone,microphone-alt,microphone-alt-slash,microphone-slash,microscope,minus,minus-circle,minus-square,mitten,mobile,mobile-alt,money-bill,money-bill-alt,money-bill-wave,money-bill-wave-alt,money-check,money-check-alt,monument,moon,mortar-pestle,mosque,motorcycle,mountain,mouse,mouse-pointer,mug-hot,music,network-wired,neuter,newspaper,not-equal,notes-medical,object-group,object-ungroup,oil-can,om,otter,outdent,pager,paint-brush,paint-roller,palette,pallet,paper-plane,paperclip,parachute-box,paragraph,parking,passport,pastafarianism,paste,pause,pause-circle,paw,peace,pen,pen-alt,pen-fancy,pen-nib,pen-square,pencil-alt,pencil-ruler,people-arrows,people-carry,pepper-hot,percent,percentage,person-booth,phone,phone-alt,phone-slash,phone-square,phone-square-alt,phone-volume,photo-video,piggy-bank,pills,pizza-slice,place-of-worship,plane,plane-arrival,plane-departure,plane-slash,play,play-circle,plug,plus,plus-circle,plus-square,podcast,poll,poll-h,poo,poo-storm,poop,portrait,pound-sign,power-off,pray,praying-hands,prescription,prescription-bottle,prescription-bottle-alt,print,procedures,project-diagram,pump-medical,pump-soap,puzzle-piece,qrcode,question,question-circle,quidditch,quote-left,quote-right,quran,radiation,radiation-alt,rainbow,random,receipt,record-vinyl,recycle,redo,redo-alt,registered,remove-format,reply,reply-all,republican,restroom,retweet,ribbon,ring,road,robot,rocket,route,rss,rss-square,ruble-sign,ruler,ruler-combined,ruler-horizontal,ruler-vertical,running,rupee-sign,sad-cry,sad-tear,satellite,satellite-dish,save,school,screwdriver,scroll,sd-card,search,search-dollar,search-location,search-minus,search-plus,seedling,server,shapes,share,share-alt,share-alt-square,share-square,shekel-sign,shield-alt,shield-virus,ship,shipping-fast,shoe-prints,shopping-bag,shopping-basket,shopping-cart,shower,shuttle-van,sign,sign-in-alt,sign-language,sign-out-alt,signal,signature,sim-card,sink,sitemap,skating,skiing,skiing-nordic,skull,skull-crossbones,slash,sleigh,sliders-h,smile,smile-beam,smile-wink,smog,smoking,smoking-ban,sms,snowboarding,snowflake,snowman,snowplow,soap,socks,solar-panel,sort,sort-alpha-down,sort-alpha-down-alt,sort-alpha-up,sort-alpha-up-alt,sort-amount-down,sort-amount-down-alt,sort-amount-up,sort-amount-up-alt,sort-down,sort-numeric-down,sort-numeric-down-alt,sort-numeric-up,sort-numeric-up-alt,sort-up,spa,space-shuttle,spell-check,spider,spinner,splotch,spray-can,square,square-full,square-root-alt,stamp,star,star-and-crescent,star-half,star-half-alt,star-of-david,star-of-life,step-backward,step-forward,stethoscope,sticky-note,stop,stop-circle,stopwatch,stopwatch-20,store,store-alt,store-alt-slash,store-slash,stream,street-view,strikethrough,stroopwafel,subscript,subway,suitcase,suitcase-rolling,sun,superscript,surprise,swatchbook,swimmer,swimming-pool,synagogue,sync,sync-alt,syringe,table,table-tennis,tablet,tablet-alt,tablets,tachometer-alt,tag,tags,tape,tasks,taxi,teeth,teeth-open,temperature-high,temperature-low,tenge,terminal,text-height,text-width,th,th-large,th-list,theater-masks,thermometer,thermometer-empty,thermometer-full,thermometer-half,thermometer-quarter,thermometer-three-quarters,thumbs-down,thumbs-up,thumbtack,ticket-alt,times,times-circle,tint,tint-slash,tired,toggle-off,toggle-on,toilet,toilet-paper,toilet-paper-slash,toolbox,tools,tooth,torah,torii-gate,tractor,trademark,traffic-light,trailer,train,tram,transgender,transgender-alt,trash,trash-alt,trash-restore,trash-restore-alt,tree,trophy,truck,truck-loading,truck-monster,truck-moving,truck-pickup,tshirt,tty,tv,umbrella,umbrella-beach,underline,undo,undo-alt,universal-access,university,unlink,unlock,unlock-alt,upload,user,user-alt,user-alt-slash,user-astronaut,user-check,user-circle,user-clock,user-cog,user-edit,user-friends,user-graduate,user-injured,user-lock,user-md,user-minus,user-ninja,user-nurse,user-plus,user-secret,user-shield,user-slash,user-tag,user-tie,user-times,users,users-cog,users-slash,utensil-spoon,utensils,vector-square,venus,venus-double,venus-mars,vest,vest-patches,vial,vials,video,video-slash,vihara,virus,virus-slash,viruses,voicemail,volleyball-ball,volume-down,volume-mute,volume-off,volume-up,vote-yea,vr-cardboard,walking,wallet,warehouse,water,wave-square,weight,weight-hanging,wheelchair,wifi,wind,window-close,window-maximize,window-minimize,window-restore,wine-bottle,wine-glass,wine-glass-alt,won-sign,wrench,x-ray,yen-sign,yin-yan"
		oFaIcons := []
		for key,value in StrSplit(vFaIcons,",") {
			oFaIcons.push(value)
		}
		Random, vRandomIcon, oFaIcons.MinIndex(), oFaIcons.MaxIndex()
		return oFaIcons[vRandomIcon]
	}
	getObj2String(Obj,FullPath := 1,BottomBlank := 0){
		static String,Blank
		if (FullPath=1)
			String := FullPath := Blank := ""
		if (IsObject(Obj)&&!Obj.XML){
			for a,b in Obj{
				if (IsObject(b) && b.OuterHtml)
					String .= FullPath "." a " = " b.OuterHtml
				else if (IsObject(b) && !b.XML)
					this.getObj2String(b, FullPath "." a, BottomBlank)
				else{
					if (BottomBlank = 0)
						String .= FullPath "." a " = " (b.XML ? b.XML : b) "`n"
					else if (b != "")
						String .= FullPath "." a " = " (b.XML ? b.XML : b) "`n"
					else
						Blank .= FullPath "." a " =`n"
				}
			}
		}
		else if (Obj.XML)
			String .= FullPath Obj.XML "`n"
		return String Blank
	}
	getEscapedJS(Str) {
	   Static EscapeChars := { 8: "\b"        ; Backspace is replaced with \b
	                        ,  9: "\t"        ; Horizontal Tab is replaced with \t
	                        , 10: "\n"        ; Newline is replaced with \n
	                        , 11: "\v"        ; Horizontal Tab is replaced with \t
	                        , 12: "\f"        ; Form feed is replaced with \f
	                        , 13: "\r"        ; Carriage return is replaced with \r
	                        , 34: "\"""       ; Double quote is replaced with \"
	                        , 39: "\'"}       ; Single quote is replaced with \'
	   Escaped := StrReplace(Str, "\", "\\")  ; Backslash is replaced with \\ first
	   For I, V In EscapeChars
	      Escaped := StrReplace(Escaped, Chr(I), V)
	   Return Escaped
	}
	getSwalInput(neutron,event) {
		; Get the input DOM node, this method works with the input parameter.
		return neutron.wnd.eval("Swal.getInput()")
	}
	getErrors(neutron,event) {
		m(event)
	}
	getSwalCSSProperties(neutron,event) {
		vStr := neutron.wnd.getStyleById("" event "")
		oCSSProps := {}
		for key,value in StrSplit(vStr,";","`n`r") {
			prop := StrSplit(value, ":","`n`r")
			oCSSProps[prop.1] := prop.2
		}
		; m(oCSSProps["font-size"])

		; returns all cssProps as an object
		return oCSSProps
	}
	setSwalIcons() { ; Set Icon of Script in Taskbar & Tray Icon if Swal exists
		If WinExist(this.wnd) {
			Ico   := A_LineFile "\..\SweetAlert2\includes\sweetalert2\pictures\swal2Icon.ico"
			Menu, Tray, Icon, % Ico, 1 ; Set Icon of Script in Taskbar
			hIcon := DllCall( "LoadImage", UInt,0, Str,Ico, UInt,1, UInt,0, UInt,0, UInt,0x10 )
			SendMessage, 0x80, 0, hIcon ,, % this.wnd  ; Small Icon
			SendMessage, 0x80, 1, hIcon ,, % this.wnd  ; Big Icon
		}
	}
	getTimerLeft(neutron) {
		return neutron.wnd.eval("Swal.getTimerLeft()")
	}
	setUserOptions(options, oOptions) {
		for key,value in options { ; if user set options then update the oOptions object
				(key = "time" ? key := "timer" : key) ; in case user mispells timer
				(key = "pos" ? key := "position" : key) ; in case user shortens Position
				(key = "icon" ? value := this.stringCase(value).l : key) ; in case user miscapitlizes icons
				oOptions[key] := value
		}
		return oOptions
	}
	stringCase(Text) {
		StringLower, l, Text 
		StringUpper, u, Text
		StringUpper, t, Text, T
		; To return use as object, for example m(Text.l) will produce lowercase text
		return Object("L",l,"U",u,"T",t)
	}
}
testing(neutron,event) {
	m("you've made it")
	return neutron.wnd.eval(event)
}
swalEscapeKey(neutron,event) {
	neutron.Destroy()
	return
}
; --- Trigger AHK by page events ---
getSwalMsg(neutron, event) { ; this has to be here to communicate on startup
	return neutron.wnd.eval(event)
}
setClipboard(neutron,event) {
	; might need to add an option if msg was obj then use innerText otherwise use text()
	vTitle := neutron.wnd.eval("$("".swal2-title"").innerText()")
	vHtml  := neutron.wnd.eval("$("".swal2-html-container"").innerText()")
	; Clipboard := event ? event : neutron.wnd.eval("$("".swal2-title"").innerText()")
	Clipboard := event ? event : (vHtml = "" ? vTitle : vHtml)
	ClipWait, 1
}
showSwalMsg(neutron, event) {
	neutron.Destroy()
	neutron := new NeutronWindow()         ; Create a new NeutronWindow and navigate to our HTML page
  	neutron.Load("SweetAlert2\index.html")
  	neutron.wnd.onReady(event)             ; Sending the Swal Msg Params for the Popup Msg
	neutron.Gui("+LabelSwal2MsgBox")       ; Use the Gui method to set a custom label prefix for GUI events. This code is equivalent to the line `Gui, name:+LabelNeutron` for a normal GUI.
	neutron.Show(swal.getSwalWndPos(390,140))
	vTimer := 3500
	JSAlert =
	(
		const Toast = Swal.mixin({
				toast: true,
				position: "bottom-end",
				showConfirmButton: false,
				timer: %vTimer%,
				timerProgressBar: true,
				didOpen: function (toast) {
					toast.addEventListener("mouseenter", Swal.stopTimer)
					toast.addEventListener("mouseleave", Swal.resumeTimer)
				},
		})
		Toast.fire({
				icon: "success",
				html: "Updated <i>TITLE MESSAGE</i> to <b>BLAGRG!!!!</b> in the database.",
		})
		setTimeout(function() {
				ahk.exitSwal()
		}, %vTimer%);
	)
	return neutron.wnd.eval(JSAlert)
}
exitApp(neutron) {
	neutron.Destroy()
	ExitApp
	return
}
exitSwal(neutron) {
	neutron.Destroy()
}
runAHKScript(neutron,event) {
	m(event)
	; FileAppend, % event, % A_LineFile "\..\SweetAlert2\temp_runAHKScript"
}
runIEChooser(neutron,event) { ; with F12 open debug options for neutron
	Run % A_ComSpec "\..\F12\IEChooser.exe",
	WinWaitActive, ahk_exe IEChooser.exe
	WinSet, AlwaysOnTop, On, ahk_exe IEChooser.exe
}

;
; Neutron.ahk v1.0.0
; Copyright (c) 2020 Philip Taylor (known also as GeekDude, G33kDude)
; https://github.com/G33kDude/Neutron.ahk
;
; MIT License
;
; Permission is hereby granted, free of charge, to any person obtaining a copy
; of this software and associated documentation files (the "Software"), to deal
; in the Software without restriction, including without limitation the rights
; to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
; copies of the Software, and to permit persons to whom the Software is
; furnished to do so, subject to the following conditions:
;
; The above copyright notice and this permission notice shall be included in all
; copies or substantial portions of the Software.
;
; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
; AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
; OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
; SOFTWARE.
;

class NeutronWindow
{
	static TEMPLATE := "
	( ; html
		<!DOCTYPE html><html>
		<head>

		<meta http-equiv='X-UA-Compatible' content='IE=edge'>
		<style>
		html, body {
			width: 100%; height: 100%;
			margin: 0; padding: 0;
			font-family: sans-serif;
		}

		body {
			display: flex;
			flex-direction: column;
		}

		header {
			width: 100%;
			display: flex;
			background: silver;
			font-family: Segoe UI;
			font-size: 9pt;
		}

		.title-bar {
			padding: 0.35em 0.5em;
			flex-grow: 1;
		}

		.title-btn {
			padding: 0.35em 1.0em;
			cursor: pointer;
			vertical-align: bottom;
			font-family: Webdings;
			font-size: 11pt;
		}

		.title-btn:hover {
			background: rgba(0, 0, 0, .2);
		}

		.title-btn-close:hover {
			background: #dc3545;
		}

		.main {
			flex-grow: 1;
			padding: 0.5em;
			overflow: auto;
		}
		</style>
		<style>{}</style>

		</head>
		<body>

		<header>
		<span class='title-bar' onmousedown='neutron.DragTitleBar()'>{}</span>
		<span class='title-btn' onclick='neutron.Minimize()'>0</span>
		<span class='title-btn' onclick='neutron.Maximize()'>1</span>
		<span class='title-btn title-btn-close' onclick='neutron.Close()'>r</span>
		</header>

		<div class='main'>{}</div>

		<script>{}</script>

		</body>
		</html>
	)"

	; --- Constants ---

	static VERSION := "1.0.0"

	; Windows Messages
	, WM_DESTROY := 0x02
	, WM_SIZE := 0x05
	, WM_NCCALCSIZE := 0x83
	, WM_NCHITTEST := 0x84
	, WM_NCLBUTTONDOWN := 0xA1
	, WM_KEYDOWN := 0x100
	, WM_KEYUP := 0x101
	, WM_SYSKEYDOWN := 0x104
	, WM_SYSKEYUP := 0x105
	, WM_MOUSEMOVE := 0x200
	, WM_LBUTTONDOWN := 0x201

	; Virtual-Key Codes
	, VK_TAB := 0x09
	, VK_SHIFT := 0x10
	, VK_CONTROL := 0x11
	, VK_MENU := 0x12
	, VK_F5 := 0x74

	; Non-client hit test values (WM_NCHITTEST)
	, HT_VALUES := [[13, 12, 14], [10, 1, 11], [16, 15, 17]]

	; Registry keys
	, KEY_FBE := "HKEY_CURRENT_USER\Software\Microsoft\Internet Explorer\MAIN"
	. "\FeatureControl\FEATURE_BROWSER_EMULATION"

	; Undoucmented Accent API constants
	; https://withinrafael.com/2018/02/02/adding-acrylic-blur-to-your-windows-10-apps-redstone-4-desktop-apps/
	, ACCENT_ENABLE_BLURBEHIND := 3
	, WCA_ACCENT_POLICY := 19

	; Other constants
	, EXE_NAME := A_IsCompiled ? A_ScriptName : StrSplit(A_AhkPath, "\").Pop()

	; --- Instance Variables ---

	LISTENERS := [this.WM_DESTROY, this.WM_SIZE, this.WM_NCCALCSIZE
	, this.WM_KEYDOWN, this.WM_KEYUP, this.WM_SYSKEYDOWN, this.WM_SYSKEYUP
	, this.WM_LBUTTONDOWN]

	; Maximum pixel inset for sizing handles to appear
	border_size := 6

	; The window size
	w := 800
	h := 600

	; Modifier keys as seen by neutron
	MODIFIER_BITMAP := {this.VK_SHIFT: 1<<0, this.VK_CONTROL: 1<<1
	, this.VK_MENU: 1<<2}
	modifiers := 0

	; Shortcuts to not pass on to the web control
	disabled_shortcuts :=
	( Join ; ahk
		{
			0: {
				this.VK_F5: true
			},
			this.MODIFIER_BITMAP[this.VK_CONTROL]: {
				GetKeyVK("F"): true,
				GetKeyVK("L"): true,
				GetKeyVK("N"): true,
				GetKeyVK("O"): true,
				GetKeyVK("P"): true
			}
		}
	)

	; --- Properties ---

	; Get the JS DOM object
	doc[]
	{
		get
		{
			return this.wb.Document
		}
	}

	; Get the JS Window object
	wnd[]
	{
		get
		{
			return this.wb.Document.parentWindow
		}
	}

	; --- Construction, Destruction, Meta-Functions ---

	__New(html:="", css:="", js:="", title:="Neutron")
	{
		static wb

		; Create necessary circular references
		this.bound := {}
		this.bound._OnMessage := this._OnMessage.Bind(this)

		; Bind message handlers
		for i, message in this.LISTENERS
			OnMessage(message, this.bound._OnMessage)

		; Create and save the GUI
		; TODO: Restore previous default GUI
		Gui, New, +hWndhWnd +Resize -DPIScale
		this.hWnd := hWnd

		; Enable shadow
		VarSetCapacity(margins, 16, 0)
		NumPut(1, &margins, 0, "Int")
		DllCall("Dwmapi\DwmExtendFrameIntoClientArea"
			, "UPtr", hWnd ; HWND hWnd
		, "UPtr", &margins) ; MARGINS *pMarInset

		; When manually resizing a window, the contents of the window often "lag
		; behind" the new window boundaries. Until they catch up, Windows will
		; render the border and default window color to fill that area. On most
		; windows this will cause no issue, but for borderless windows this can
		; cause rendering artifacts such as thin borders or unwanted colors to
		; appear in that area until the rest of the window catches up.
		;
		; When creating a dark-themed application, these artifacts can cause
		; jarringly visible bright areas. This can be mitigated some by changing
		; the window settings to cause dark/black artifacts, but it's not a
		; generalizable approach, so if I were to do that here it could cause
		; issues with light-themed apps.
		;
		; Some borderless window libraries, such as rossy's C implementation
		; (https://github.com/rossy/borderless-window) hide these artifacts by
		; playing with the window transparency settings which make them go away
		; but also makes it impossible to show certain colors (in rossy's case,
		; Fuchsia/FF00FF).
		;
		; Luckly, there's an undocumented Windows API function in user32.dll
		; called SetWindowCompositionAttribute, which allows you to change the
		; window accenting policies. This tells the DWM compositor how to fill
		; in areas that aren't covered by controls. By enabling the "blurbehind"
		; accent policy, Windows will render a blurred version of the screen
		; contents behind your window in that area, which will not be visually
		; jarring regardless of the colors of your application or those behind
		; it.
		;
		; Because this API is undocumented (and unavailable in Windows versions
		; below 10) it's not a one-size-fits-all solution, and could break with
		; future system updates. Hopefully a better soultion for the problem
		; this hack addresses can be found for future releases of this library.
		;
		; https://withinrafael.com/2018/02/02/adding-acrylic-blur-to-your-windows-10-apps-redstone-4-desktop-apps/
		; https://github.com/melak47/BorderlessWindow/issues/13#issuecomment-309154142
		; http://undoc.airesoft.co.uk/user32.dll/SetWindowCompositionAttribute.php
		; https://gist.github.com/riverar/fd6525579d6bbafc6e48
		; https://vhanla.codigobit.info/2015/07/enable-windows-10-aero-glass-aka-blur.html

		Gui, Color, 0, 0
		VarSetCapacity(wcad, A_PtrSize+A_PtrSize+4, 0)
		NumPut(this.WCA_ACCENT_POLICY, &wcad, 0, "Int")
		VarSetCapacity(accent, 16, 0)
		NumPut(this.ACCENT_ENABLE_BLURBEHIND, &accent, 0, "Int")
		NumPut(&accent, &wcad, A_PtrSize, "Ptr")
		NumPut(16, &wcad, A_PtrSize+A_PtrSize, "Int")
		DllCall("SetWindowCompositionAttribute", "UPtr", hWnd, "UPtr", &wcad)

		; Creating an ActiveX control with a valid URL instantiates a
		; WebBrowser, saving its object to the associated variable. The "about"
		; URL scheme allows us to start the control on either a blank page, or a
		; page with some HTML content pre-loaded by passing HTML after the
		; colon: "about:<!DOCTYPE html><body>...</body>"

		; Read more about the WebBrowser control here:
		; http://msdn.microsoft.com/en-us/library/aa752085

		; For backwards compatibility reasons, the WebBrowser control defaults
		; to IE7 emulation mode. The standard method of mitigating this is to
		; include a compatibility meta tag in the HTML, but this requires
		; tampering to the HTML and does not solve all compatibility issues.
		; By tweaking the registry before and after creation of the control we
		; can opt-out of the browser emulation feature altogether with minimal
		; impact on the rest of the system.

		; Read more about browser compatibility modes here:
		; https://docs.microsoft.com/en-us/archive/blogs/patricka/controlling-webbrowser-control-compatibility

		RegRead, fbe, % this.KEY_FBE, % this.EXE_NAME
		RegWrite, REG_DWORD, % this.KEY_FBE, % this.EXE_NAME, 0
		Gui, Add, ActiveX, vwb hWndhWB x0 y0 w800 h600, about:blank
		if (fbe = "")
			RegDelete, % this.KEY_FBE, % this.EXE_NAME
		else
			RegWrite, REG_DWORD, % this.KEY_FBE, % this.EXE_NAME, % fbe

		; Save the WebBrowser control to reference later
		this.wb := wb
		this.hWB := hWB

		; Connect the web browser's event stream to a new event handler object
		ComObjConnect(this.wb, new this.WBEvents(this))

		; Compute the HTML template if necessary
		if !(html ~= "i)^<!DOCTYPE")
			html := Format(this.TEMPLATE, css, title, html, js)

		; Write the given content to the page
		this.doc.write(html)
		this.doc.close()

		; Inject the AHK objects into the JS scope
		this.wnd.neutron := this
		this.wnd.ahk := new this.Dispatch(this)
		this.wnd.swal := new SweetAlert2() ; - DMD for SweetAlert2 Enabled

		; Wait for the page to finish loading
		while wb.readyState < 4
			Sleep, 50

		; Subclass the rendered Internet Explorer_Server control to intercept
		; its events, including WM_NCHITTEST and WM_NCLBUTTONDOWN.
		; Read more here: https://forum.juce.com/t/_/27937
		; And in the AutoHotkey documentation for RegisterCallback (Example 2)

		dhw := A_DetectHiddenWindows
		DetectHiddenWindows, On
		ControlGet, hWnd, hWnd,, Internet Explorer_Server1, % "ahk_id" this.hWnd
		this.hIES := hWnd
		ControlGet, hWnd, hWnd,, Shell DocObject View1, % "ahk_id" this.hWnd
		this.hSDOV := hWnd
		DetectHiddenWindows, %dhw%

		this.pWndProc := RegisterCallback(this._WindowProc, "", 4, &this)
		this.pWndProcOld := DllCall("SetWindowLong" (A_PtrSize == 8 ? "Ptr" : "")
			, "Ptr", this.hIES ; HWND     hWnd
			, "Int", -4 ; int      nIndex (GWLP_WNDPROC)
			, "Ptr", this.pWndProc ; LONG_PTR dwNewLong
		, "Ptr") ; LONG_PTR

		; Stop the WebBrowser control from consuming file drag and drop events
		this.wb.RegisterAsDropTarget := False
		DllCall("ole32\RevokeDragDrop", "UPtr", this.hIES)
	}

	; Show an alert for debugging purposes when the class gets garbage collected
	; __Delete()
	; {
	; 	MsgBox, __Delete
	; }

	; --- Event Handlers ---

	_OnMessage(wParam, lParam, Msg, hWnd)
	{
		if (hWnd == this.hWnd)
		{
			; Handle messages for the main window

			if (Msg == this.WM_NCCALCSIZE)
			{
				; Size the client area to fill the entire window.
				; See this project for more information:
				; https://github.com/rossy/borderless-window

				; Fill client area when not maximized
				if !DllCall("IsZoomed", "UPtr", hWnd)
					return 0
				; else crop borders to prevent screen overhang

				; Query for the window's border size
				VarSetCapacity(windowinfo, 60, 0)
				NumPut(60, windowinfo, 0, "UInt")
				DllCall("GetWindowInfo", "UPtr", hWnd, "UPtr", &windowinfo)
				cxWindowBorders := NumGet(windowinfo, 48, "Int")
				cyWindowBorders := NumGet(windowinfo, 52, "Int")

				; Inset the client rect by the border size
				NumPut(NumGet(lParam+0, "Int") + cxWindowBorders, lParam+0, "Int")
				NumPut(NumGet(lParam+4, "Int") + cyWindowBorders, lParam+4, "Int")
				NumPut(NumGet(lParam+8, "Int") - cxWindowBorders, lParam+8, "Int")
				NumPut(NumGet(lParam+12, "Int") - cyWindowBorders, lParam+12, "Int")

				return 0
			}
			else if (Msg == this.WM_SIZE)
			{
				; Extract size from LOWORD and HIWORD (preserving sign)
				this.w := w := lParam<<48>>48
				this.h := h := lParam<<32>>48

				DllCall("MoveWindow", "UPtr", this.hWB, "Int", 0, "Int", 0, "Int", w, "Int", h, "UInt", 0)

				return 0
			}
			else if (Msg == this.WM_DESTROY)
			{
				; Clean up all our circular references so that the object may be
				; garbage collected.

				for i, message in this.LISTENERS
					OnMessage(message, this.bound._OnMessage, 0)
				ComObjConnect(this.wb)
				this.bound := []
			}
		}
		else if (hWnd == this.hIES || hWnd == this.hSDOV)
		{
			; Handle messages for the rendered Internet Explorer_Server

			pressed := (Msg == this.WM_KEYDOWN || Msg == this.WM_SYSKEYDOWN)
			released := (Msg == this.WM_KEYUP || Msg == this.WM_SYSKEYUP)

			if (pressed || released)
			{
				; Track modifier states
				if (bit := this.MODIFIER_BITMAP[wParam])
					this.modifiers := (this.modifiers & ~bit) | (pressed * bit)

				; Block disabled key combinations
				if (this.disabled_shortcuts[this.modifiers, wParam])
					return 0

				; When you press tab with the last tabbable item in the
				; document already selected, focus will be taken from the IES
				; control and moved to the SDOV control. The accelerator code
				; from the AutoHotkey installer uses a conditional loop in an
				; attempt to work around this behavior, but as implemented it
				; did not work correctly on my system. Instead, listen for the
				; tab up event on the SDOV and swap it for a tab down before
				; translating it. This should prevent the user from tabbing to
				; the SDOV in most cases, though there may still be some way to
				; tab to it that I am not aware of. A more elegant solution may
				; be to subclass the SDOV like was done for the IES, then
				; forward the WM_SETFOCUS message back to the IES control.
				; However, given the relative complexity of subclassing and the
				; fact that this message substution approach appears to work
				; just as well, we will use the message substitution. Consider
				; implementing the other approach if it turns out that the
				; undesirable behavior continues to manifest under some
				; circumstances.
				Msg := hWnd == this.hSDOV ? this.WM_KEYDOWN : Msg

				; Modified accelerator handling code from AutoHotkey Installer
				Gui +OwnDialogs ; For threadless callbacks which interrupt this.
				pipa := ComObjQuery(this.wb, "{00000117-0000-0000-C000-000000000046}")
				VarSetCapacity(kMsg, 48), NumPut(A_GuiY, NumPut(A_GuiX
					, NumPut(A_EventInfo, NumPut(lParam, NumPut(wParam
					, NumPut(Msg, NumPut(hWnd, kMsg)))), "uint"), "int"), "int")
					r := DllCall(NumGet(NumGet(1*pipa)+5*A_PtrSize), "ptr", pipa, "ptr", &kMsg)
					ObjRelease(pipa)

					if (r == 0) ; S_OK: the message was translated to an accelerator.
						return 0
					return
				}
			}
		}

		_WindowProc(Msg, wParam, lParam)
		{
			Critical
			hWnd := this
			this := Object(A_EventInfo)

			if (Msg == this.WM_NCHITTEST)
			{
				; Check to see if the cursor is near the window border, which
				; should be treated as the "non-client" drag-to-resize area.
				; https://autohotkey.com/board/topic/23969-/#entry155480

				; Extract coordinates from LOWORD and HIWORD (preserving sign)
				x := lParam<<48>>48, y := lParam<<32>>48

				; Get the window position for comparison
				WinGetPos, wX, wY, wW, wH, % "ahk_id" this.hWnd

				; Calculate positions in the lookup tables
				row := (x < wX + this.BORDER_SIZE) ? 1 : (x >= wX + wW - this.BORDER_SIZE) ? 3 : 2
				col := (y < wY + this.BORDER_SIZE) ? 1 : (y >= wY + wH - this.BORDER_SIZE) ? 3 : 2

				return this.HT_VALUES[col, row]
			}
			else if (Msg == this.WM_NCLBUTTONDOWN)
			{
				; Hoist nonclient clicks to main window
				return DllCall("SendMessage", "Ptr", this.hWnd, "UInt", Msg, "UPtr", wParam, "Ptr", lParam, "Ptr")
			}

			; Otherwise (since above didn't return), pass all unhandled events to the original WindowProc.
			Critical, Off
			return DllCall("CallWindowProc"
				, "Ptr", this.pWndProcOld ; WNDPROC lpPrevWndFunc
				, "Ptr", hWnd ; HWND    hWnd
				, "UInt", Msg ; UINT    Msg
				, "UPtr", wParam ; WPARAM  wParam
				, "Ptr", lParam ; LPARAM  lParam
			, "Ptr") ; LRESULT
		}

		; --- Instance Methods ---

		; Triggers window dragging. Call this on mouse click down. Best used as your
		; title bar's onmousedown attribute.
		DragTitleBar()
		{
			PostMessage, this.WM_NCLBUTTONDOWN, 2, 0,, % "ahk_id" this.hWnd
		}

		; Minimizes the Neutron window. Best used in your title bar's minimize
		; button's onclick attribute.
		Minimize()
		{
			Gui, % this.hWnd ":Minimize"
		}

		; Maximize the Neutron window. Best used in your title bar's maximize
		; button's onclick attribute.
		Maximize()
		{
			if DllCall("IsZoomed", "UPtr", this.hWnd)
				Gui, % this.hWnd ":Restore"
			else
				Gui, % this.hWnd ":Maximize"
		}

		; Closes the Neutron window. Best used in your title bar's close
		; button's onclick attribute.
		Close()
		{
			WinClose, % "ahk_id" this.hWnd
		}

		; Hides the Nuetron window.
		Hide()
		{
			Gui, % this.hWnd ":Hide"
		}

		; Return hWnd
		UID()
		{
			DetectHiddenWindows, On
			return this.hWnd
			DetectHiddenWindows, Off
		}

		; Destroys the Neutron window. Do this when you would no longer want to
		; re-show the window, as it will free the memory taken up by the GUI and
		; ActiveX control. This method is best used either as your title bar's close
		; button's onclick attribute, or in a custom window close routine.
		Destroy()
		{
			Gui, % this.hWnd ":Destroy"
		}

		; Shows a hidden Neutron window.
		Show(options:="")
		{
			w := RegExMatch(options, "w\s*\K\d+", match) ? match : this.w
			h := RegExMatch(options, "h\s*\K\d+", match) ? match : this.h

			; AutoHotkey sizes the window incorrectly, trying to account for borders
			; that aren't actually there. Call the function AHK uses to offset and
			; apply the change in reverse to get the actual wanted size.
			VarSetCapacity(rect, 16, 0)
			DllCall("AdjustWindowRectEx"
				, "Ptr", &rect ;  LPRECT lpRect
				, "UInt", 0x80CE0000 ;  DWORD  dwStyle
				, "UInt", 0 ;  BOOL   bMenu
				, "UInt", 0 ;  DWORD  dwExStyle
			, "UInt") ; BOOL
			w += NumGet(&rect, 0, "Int")-NumGet(&rect, 8, "Int")
			h += NumGet(&rect, 4, "Int")-NumGet(&rect, 12, "Int")

			Gui, % this.hWnd ":Show", %options% w%w% h%h%
		}

		; Loads an HTML file by name (not path). When running the script uncompiled,
		; looks for the file in the local directory. When running the script
		; compiled, looks for the file in the EXE's RCDATA. Files included in your
		; compiled EXE by FileInstall are stored in RCDATA whether they get
		; extracted or not. An easy way to get your Neutron resources into a
		; compiled script, then, is to put FileInstall commands for them right below
		; the return at the bottom of your AutoExecute section.
		;
		; Parameters:
		;   fileName - The name of the HTML file to load into the Neutron window.
		;              Make sure to give just the file name, not the full path.
		;
		; Returns: nothing
		;
		; Example:
		;
		; ; AutoExecute Section
		; neutron := new NeutronWindow()
		; neutron.Load("index.html")
		; neutron.Show()
		; return
		; FileInstall, index.html, index.html
		; FileInstall, index.css, index.css
		;
		Load(fileName)
		{
			; Complete the path based on compiled state
			if A_IsCompiled
				url := "res://" this.wnd.encodeURIComponent(A_ScriptFullPath) "/10/" fileName
			else {
				SplitPath,A_LineFile,,vDir
				url := vDir "\" fileName
			/*
				Clipboard := url
				msgbox % url

			*/
			}

			; Navigate to the calculated file URL
			this.wb.Navigate(url)

			; Wait for the page to finish loading
			while this.wb.readyState < 3
				Sleep, 50

			; Inject the AHK objects into the JS scope
			this.wnd.neutron := this
			this.wnd.ahk := new this.Dispatch(this)
			this.wnd.swal := new SweetAlert2() ; - DMD for SweetAlert2 Enabled

			; Wait for the page to finish loading
			while this.wb.readyState < 4
				Sleep, 50
		}

		; Shorthand method for document.querySelector
		qs(selector)
		{
			return this.doc.querySelector(selector)
		}

		; Shorthand method for document.querySelectorAll
		qsa(selector)
		{
			return this.doc.querySelectorAll(selector)
		}

		; Passthrough method for the Gui command, targeted at the Neutron Window
		; instance
		Gui(subCommand, value1:="", value2:="", value3:="")
		{
			Gui, % this.hWnd ":" subCommand, %value1%, %value2%, %value3%
		}

		; --- Static Methods ---

		; Given an HTML Collection (or other JavaScript array), return an enumerator
		; that will iterate over its items.
		;
		; Parameters:
		;     htmlCollection - The JavaScript array to be iterated over
		;
		; Returns: An Enumerable object
		;
		; Example:
		;
		; neutron := new NeutronWindow("<body><p>A</p><p>B</p><p>C</p></body>")
		; neutron.Show()
		; for i, element in neutron.Each(neutron.body.children)
		;     MsgBox, % i ": " element.innerText
		;
		Each(htmlCollection)
		{
			return new this.Enumerable(htmlCollection)
		}

		; Given an HTML Form Element, construct a FormData object
		;
		; Parameters:
		;   formElement - The HTML Form Element
		;   useIdAsName - When a field's name is blank, use it's ID instead
		;
		; Returns: A FormData object
		;
		; Example:
		;
		; neutron := new NeutronWindow("<form>"
		; . "<input type='text' name='field1' value='One'>"
		; . "<input type='text' name='field2' value='Two'>"
		; . "<input type='text' name='field3' value='Three'>"
		; . "</form>")
		; neutron.Show()
		; formElement := neutron.doc.querySelector("form") ; Grab 1st form on page
		; formData := neutron.GetFormData(formElement) ; Get form data
		; MsgBox, % formData.field2 ; Pull a single field
		; for name, element in formData ; Iterate all fields
		;     MsgBox, %name%: %element%
		;
		GetFormData(formElement, useIdAsName:=True)
		{
			formData := new this.FormData()

			for i, field in this.Each(formElement.elements)
			{
				; Discover the field's name
				name := ""
				try ; fieldset elements error when reading the name field
				name := field.name
				if (name == "" && useIdAsName)
					name := field.id

				; Filter against fields which should be omitted
				if (name == "" || field.disabled
					|| field.type ~= "^file|reset|submit|button$")
				continue

				; Handle select-multiple variants
				if (field.type == "select-multiple")
				{
					for j, option in this.Each(field.options)
						if (option.selected)
						formData.add(name, option.value)
					continue
				}

				; Filter against unchecked checkboxes and radios
				if (field.type ~= "^checkbox|radio$" && !field.checked)
					continue

				; Return the field values
				formData.add(name, field.value)
			}

			return formData
		}

		; Given a potentially HTML-unsafe string, return an HTML safe string
		; https://stackoverflow.com/a/6234804
		EscapeHTML(unsafe)
		{
			unsafe := StrReplace(unsafe, "&", "&amp;")
				unsafe := StrReplace(unsafe, "<", "&lt;")
					unsafe := StrReplace(unsafe, ">", "&gt;")
						unsafe := StrReplace(unsafe, """", "&quot;")
							unsafe := StrReplace(unsafe, "''", "&#039;")
								return unsafe
							}

							; Wrapper for Format that applies EscapeHTML to each value before passing
							; them on. Useful for dynamic HTML generation.
							FormatHTML(formatStr, values*)
							{
								for i, value in values
									values[i] := this.EscapeHTML(value)
								return Format(formatStr, values*)
							}

							; --- Nested Classes ---

							; Proxies method calls to AHK function calls, binding a given value to the
							; first parameter of the target function.
							;
							; For internal use only.
							;
							; Parameters:
							;   parent - The value to bind
							;
							class Dispatch
							{
								__New(parent)
								{
									this.parent := parent
								}

								__Call(params*)
								{
									; Make sure the given name is a function
									if !(fn := Func(params[1]))
										throw Exception("Unknown function: " params[1])

									; Make sure enough parameters were given
									if (params.length() < fn.MinParams)
										throw Exception("Too few parameters given to " fn.Name ": " params.length())

									; Make sure too many parameters weren't given
									if (params.length() > fn.MaxParams && !fn.IsVariadic)
										throw Exception("Too many parameters given to " fn.Name ": " params.length())

									; Change first parameter from the function name to the neutron instance
									params[1] := this.parent

									; Call the function
									return fn.Call(params*)
								}
							}

							; Handles Web Browser events
							; https://docs.microsoft.com/en-us/previous-versions/windows/internet-explorer/ie-developer/platform-apis/aa768283%28v%3dvs.85%29
							;
							; For internal use only
							;
							; Parameters:
							;   parent - An instance of the Neutron class
							;
							class WBEvents
							{
								__New(parent)
								{
									this.parent := parent
								}

								DocumentComplete(wb)
								{
									; Inject the AHK objects into the JS scope
									wb.document.parentWindow.neutron := this.parent
									wb.document.parentWindow.ahk := new this.parent.Dispatch(this.parent)
								}
							}

							; Enumerator class that enumerates the items of an HTMLCollection (or other
							; JavaScript array).
							;
							; Best accessed through the .Each() helper method.
							;
							; Parameters:
							;   htmlCollection - The HTMLCollection to be enumerated.
							;
							class Enumerable
							{
								i := 0

								__New(htmlCollection)
								{
									this.collection := htmlCollection
								}

								_NewEnum()
								{
									return this
								}

								Next(ByRef i, ByRef elem)
								{
									if (this.i >= this.collection.length)
										return False
									i := this.i
									elem := this.collection.item(this.i++)
									return True
								}
							}

							; A collection similar to an OrderedDict designed for holding form data.
							; This collection allows duplicate keys and enumerates key value pairs in
							; the order they were added.
							class FormData
							{
								names := []
								values := []

								; Add a field to the FormData structure.
								;
								; Parameters:
								;   name - The form field name associated with the value
								;   value - The value of the form field
								;
								; Returns: Nothing
								;
								Add(name, value)
								{
									this.names.Push(name)
									this.values.Push(value)
								}

								; Get an array of all values associated with a name.
								;
								; Parameters:
								;   name - The form field name associated with the values
								;
								; Returns: An array of values
								;
								; Example:
								;
								; fd := new NeutronWindow.FormData()
								; fd.Add("foods", "hamburgers")
								; fd.Add("foods", "hotdogs")
								; fd.Add("foods", "pizza")
								; fd.Add("colors", "red")
								; fd.Add("colors", "green")
								; fd.Add("colors", "blue")
								; for i, food in fd.All("foods")
								;     out .= i ": " food "`n"
								; MsgBox, %out%
								;
								All(name)
								{
									values := []
									for i, v in this.names
										if (v == name)
										values.Push(this.values[i])
									return values
								}

								; Meta-function to allow direct access of field values using either dot
								; or bracket notation. Can retrieve the nth item associated with a given
								; name by passing more than one value in when bracket notation.
								;
								; Example:
								;
								; fd := new NeutronWindow.FormData()
								; fd.Add("foods", "hamburgers")
								; fd.Add("foods", "hotdogs")
								; MsgBox, % fd.foods ; hamburgers
								; MsgBox, % fd["foods", 2] ; hotdogs
								;
								__Get(name, n := 1)
								{
									for i, v in this.names
										if (v == name && !--n)
										return this.values[i]
								}

								; Allow iteration in the order fields were added, instead of a normal
								; object's alphanumeric order of iteration.
								;
								; Example:
								;
								; fd := new NeutronWindow.FormData()
								; fd.Add("z", "3")
								; fd.Add("y", "2")
								; fd.Add("x", "1")
								; for name, field in fd
								;     out .= name ": " field ","
								; MsgBox, %out% ; z: 3, y: 2, x: 1
								;
								_NewEnum()
								{
									return {"i": 0, "base": this}
								}
								Next(ByRef name, ByRef value)
								{
									if (++this.i > this.names.length())
										return False
									name := this.names[this.i]
									value := this.values[this.i]
									return True
								}
							}
						}
#Include <cJSON>