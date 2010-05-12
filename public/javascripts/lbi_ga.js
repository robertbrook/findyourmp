// JavaScript Document///////
// lbi_ga.js//
/*
 * @fileoverview Wrapper for lbi_ga
 */
var bUseEventForOutbound = true; // Set to false to use trackPageview for outbount links
var bUseEventForDownload = true; // Set to false to use trackPageview for downloads
var gaA_fileTypes = new RegExp(/\.(docx*|xlsx*|pptx*|exe|zip|pdf|xpi|dot|mht|pps|wma|wmv)$/i);
// Indicate each file extension that needs to be tracked, gaA_fileTypes is the regular expression that matches downloadable files
var gaA_pageTracker = pageTracker; // Should be set to the name of your tracker variable

/// No need to change anything below this line
/**
 * @class lbi_ga component.
 *     This class encapsulates all logic for the Google Analytics addons
 * @constructor
 */
var lbi_ga = function(){
    /**
     * startListening: add a new listner for onclick event, handle Mozilla or IE methods
     * @param {Object} obj HREF object to listen to
     * @param {String} evnt event type (usually "click")
     * @param {Object} func Function to call when evnt is triggered
     */
    var startListening = function(obj, evnt, func){
        if (obj.addEventListener) 
            obj.addEventListener(evnt, func, false);
        else 
            if (obj.attachEvent) 
                obj.attachEvent("on" + evnt, func);
    }
    
    /**
     * trackDocument: make GA call when downloading one of detected file extension, use trackEvent() or trackPageView() methods
     * @param {Object} evnt Object where the event happened
     */
    var trackDocument = function(evnt){
		evnt=evnt||event;
		var elmnt = evnt.srcElement||evnt.target;
		var pathname = ("/" + elmnt.pathname).replace(/\/\//,'');
        bUseEventForDownload ? gaA_pageTracker._trackEvent("download", "click", pathname) : gaA_pageTracker._trackPageview("/download" + pathname);
    }
    
    /**
     * trackExternalLink: make GA call when clicking an outbound link, use trackEvent() or trackPageView() methods
     * @param {Object} evnt Object where the event happened
     */
    var trackExternalLink = function(evnt){
		evnt=evnt||event;
        var elmnt = evnt.srcElement||evnt.target;
        if (elmnt) {
            while (elmnt.tagName != "A") 
                elmnt = elmnt.parentNode;
            if (/http/.test(elmnt.protocol)) {
				url = elmnt.href.substr(elmnt.href.indexOf('//')+2,Infinity);
				bUseEventForOutbound ? gaA_pageTracker._trackEvent("outbound", "click", url) : gaA_pageTracker._trackPageview(("/outbound/" + url));
			}
            if (elmnt.protocol == "mailto:") 
                bUseEventForOutbound ? gaA_pageTracker._trackEvent("mailto", "click", elmnt.href.replace(/mailto:/, "")) : gaA_pageTracker._trackPageview("/mailto/" + elmnt.href.replace(/mailto:/));
        }
        else {
            if (/http/.test(this.protocol)) {
				url = this.href.substr(this.href.indexOf('//')+2,Infinity);
				bUseEventForOutbound ? gaA_pageTracker._trackEvent("outbound", "click", url) : gaA_pageTracker._trackPageview("/outbound/" + url);
			}
            if (this.protocol == "mailto:") 
                bUseEventForOutbound ? gaA_pageTracker._trackEvent("mailto", "click", this.href.replace(/mailto:/, "")) : gaA_pageTracker._trackPageview("/mailto/" + this.href.replace(/mailto:/));
        }
    }

    /**
     * Initialize lbi_ga
     */
    if (document.getElementsByTagName && typeof gaA_pageTracker == "object") {
        var hrefs = document.getElementsByTagName('a');
        for (var l = 0, m = hrefs.length; l < m; l++) 
            if (gaA_fileTypes.test(hrefs[l].pathname)) 
                startListening(hrefs[l], "click", trackDocument);
            else 
                if (hrefs[l].hostname != location.hostname) 
                    startListening(hrefs[l], "click", trackExternalLink);
    }
}

if (window.addEventListener) // Standard
    window.addEventListener('load', lbi_ga, false);
else 
    if (window.attachEvent) // old IE
        window.attachEvent('onload', lbi_ga);
/// EOF ///