var agent;
var isMajor;
var isIe;
var isIe6;
var isIe7;
var isIe8;
var isFirefox;
var isWindows;
var flashMoviesOnPage = 0;
var silverlightPlayersOnPage = 0;
var debugLog = false;
var equalizeGrid = false;
var slideshowImageDetails = [];
var globalObj = {};

var siteConfig = {
	equalize:{
		main:{
			active:true,
			offset:6
		},
		committees:{
			active:true,
			offset:6
		},
		mlo:{
			active:true,
			offset:6
		},
		education:{
			active:true,
			offset:-9
		},
		popvox:{
			active:false
		},
		woa:{
			active:true,
			offset:6
		}
	}
}

var subSiteJavaScript = {
	srcPath:'/assets/scripts/sub-sites/',
	sites:{
		committees:true,
		main:true,	
		woa:true,
		education:true,
		mlo:false,
		popvox:true
	}
}

var silverlightConfiguration = {
	localWebServiceUrl: 'http://dev.parliament.uk/AJAX/SilverlightEmbed.ashx'
}

var websiteFeaturesConfig = {
	defaultFlashVersion:'9.0.0',
	initialLoad:1,
	rotationEnabled:false,
	rotationTime:2000
}

var toggleConfig = {
	slideTime: 1000
}

var whatsOnConfig = {
	autoSelect: 'current'
}

var educationToggleConfig = {
	slideTime: 1000
}

var advancedSearchConfig = {
	autoFill:true,
	max:30,
	scroll:true,
	scrollHeight:150,
	width:402
}

var popvoxToggleConfig = {
	slideTime: 500
}

var tracking = {
	accountID: 'UA-15845045-1',
	enabled: true
}

var websiteFeatures= [];

//plugins
var calendarConfig = {
	cssFile:'/assets/css/datepicker.css',
	javascriptFiles:{
		file1:'/assets/scripts/jquery.date.js',
		file2:'/assets/scripts/jquery.datepicker.js'
	}
}

var shadowBoxConfig = {
	cssFile:'/assets/css/shadowbox.css',
	javascriptFiles:{
		file1:'/assets/scripts/shadowbox.js'
	}
}

var WoAZoomConfig = {
	javascriptFiles:{
		file1:'/assets/scripts/jquery.mousewheel.min.js'
	}
}

var educationPictureViewerConfig = {
	javascriptFiles:{
		file1:'/assets/scripts/jquery.imageviewer.js',
		file2:'/assets/scripts/jquery.scrollTo.js'
	},
	slideTime:1000
}

var advancedSearchMembersConfig = {
	cssFile:'/assets/css/jquery.autocomplete.css',	
	javascriptFiles: {
		file1:'/assets/scripts/jquery.autocomplete.js',
		file2:'/assets/scripts/jquery.bgiframe.js'
	}
}

parliamentUK = {
	init:function(obj){		
		//handle page specific initializations
		$.extend(obj,{site:$(document.body).attr('class')});
		
		//extend init object to global scope
		$.extend(globalObj,obj);
		
		//check to see if colour debugging needs to be loaded
		top.location.href.indexOf('show-colours') != -1 ? $('BODY').addClass('show-colours') : $('BODY').attr('class',$(this).attr('class'));
		
		//check to see if debug logging needs to be loaded
		top.location.href.indexOf('debug') != -1 ? debugLog = true : debugLog = false;
		
		//prepare external document links
		$('.document').each(function(){
		    $('<img />').attr({'class':'new-window-icon','src':'/assets/images/new-window-icon.gif','alt':'Opens in a new window'}).appendTo(this);
		});

		//assign _blank targets in order to meet Strict doctype markup restrictions
		$('A[rel="external"]').attr('target','_blank');
	
		//run browser-sniffer for a rare case where custom JavaScript requires variance between browsers		
		parliamentUK.browserSniffer();

		//add alternate row colouring for <table>s (global site scope)
		$('.alternate-table TABLE TBODY').each(function(){
			parliamentUK.alternateHighlight({wrapper:$(this),selector:'TR',siblingShowHideSelector:'TD'});
		});

		//initialize page specific functionality
		parliamentUK.page.init(obj);

		//equalize grid columns to ensure grey tramlines run consistently to full page depth (three-wide template only)
		if(obj.pageType != 'main-start'){
			parliamentUK.equalizeGrid();
		}
	},

	//dynamically load plugins into the DOM
	pluginLoader: function(pluginName){
		switch(pluginName){
			case 'woaZoom':
				parliamentUK.createElement({type:'SCRIPT',appendTo:$('head'),other:{src:WoAZoomConfig.javascriptFiles.file1,type:'text/javascript'},insertMode:'insertAfter'});
				
				break;
			case 'calendar':
				parliamentUK.createElement({type:'LINK',appendTo:$('HEAD'),other:{rel:'stylesheet',type:'text/css',media:'projection,screen',href:calendarConfig.cssFile},insertMode:'insertAfter'});
				parliamentUK.createElement({type:'SCRIPT',appendTo:$('HEAD'),other:{src:calendarConfig.javascriptFiles.file1,type:'text/javascript'},insertMode:'insertAfter'});
				parliamentUK.createElement({type:'SCRIPT',appendTo:$('HEAD'),other:{src:calendarConfig.javascriptFiles.file2,type:'text/javascript'},insertMode:'insertAfter'});
				
				break;
			case 'advancedSearchMembers':
				parliamentUK.createElement({type:'LINK',appendTo:$('HEAD'),other:{rel:'stylesheet',type:'text/css',media:'projection,screen',href:advancedSearchMembersConfig.cssFile},insertMode:'insertAfter'});
				parliamentUK.createElement({type:'SCRIPT',appendTo:$('HEAD'),other:{src:advancedSearchMembersConfig.javascriptFiles.file1,type:'text/javascript'},insertMode:'insertAfter'});
				parliamentUK.createElement({type:'SCRIPT',appendTo:$('HEAD'),other:{src:advancedSearchMembersConfig.javascriptFiles.file2,type:'text/javascript'},insertMode:'insertAfter'});
				
				break;
			case 'woaPictureViewer':
				parliamentUK.createElement({type:'SCRIPT',appendTo:$('HEAD'),other:{src:educationPictureViewerConfig.javascriptFiles.file1,type:'text/javascript'},insertMode:'insertAfter'});
				parliamentUK.createElement({type:'SCRIPT',appendTo:$('HEAD'),other:{src:educationPictureViewerConfig.javascriptFiles.file2,type:'text/javascript'},insertMode:'insertAfter'});
				
				break;
			case 'educationShadowbox':
				parliamentUK.createElement({type:'LINK',appendTo:$('HEAD'),other:{rel:'stylesheet',type:'text/css',media:'projection,screen',href:shadowBoxConfig.cssFile},insertMode:'insertAfter'});
				parliamentUK.createElement({type:'SCRIPT',appendTo:$('HEAD'),other:{src:shadowBoxConfig.javascriptFiles.file1,type:'text/javascript'},insertMode:'insertAfter'});
				
				Shadowbox.init();
				
				if(isIe6){DD_belatedPNG.fix('#sb-nav-close');}
				
				break;
		}
	},
	
	//load any sub-site JavaScript files (if required)
	loadSubSiteJavaScript: function(site){
		if(subSiteJavaScript.sites[site]){
			//add sub-site JavaScript file to the DOM
			parliamentUK.createElement({type:'SCRIPT',appendTo:$('head'),other:{src:subSiteJavaScript.srcPath + site + '.js',type:'text/javascript'},insertMode:'insertAfter'});
		}
	},	
	
	//initialize all Flash movies
	flashMovieInit: function(obj){
		if(debugLog){parliamentUK.logEvent('[FLASH MOVIE]: initialize');}
				
		//iterate global counter for movies on current page
		flashMoviesOnPage++;

		var flashParent = $('.flash:eq(' + (flashMoviesOnPage-1) + ')');
		$(flashParent).attr('id','flash-container-' + flashMoviesOnPage);

		//assign an id to the original no-flash <div>
		$('.no-flash',$(flashParent)).attr('id','inner-' + flashMoviesOnPage + '-swfobject');

		//apply any CSS individual alterations here
		if(obj.additionalSettings != undefined){
			$('#inner-' + flashMoviesOnPage + '-swfobject').parent().css(obj.additionalSettings.css);
		}

		swfobject.embedSWF(obj.configuration.src,'inner-' + flashMoviesOnPage + '-swfobject',obj.configuration.width,obj.configuration.height,obj.configuration.version != undefined ? obj.configuration.version : websiteFeaturesConfig.defaultFlashVersion,obj.configuration.expressInstallSrc,obj.flashvars,obj.params);

		var flashvarsDebug = '';
		var paramsDebug = '';

		for(x in obj.flashvars){flashvarsDebug += x + '=' + obj.flashvars[x] + ', ';}		
		for(x in obj.params){paramsDebug += x + '=' + obj.params[x] + ', ';}

		flashvarsDebug = flashvarsDebug.substr(0,flashvarsDebug.length-2);		
		paramsDebug = paramsDebug.substr(0,paramsDebug.length-2);

		if(debugLog){parliamentUK.logEvent('[FLASH MOVIE (settings)]: src=' + obj.configuration.src + ', div=' + 'inner-' + flashMoviesOnPage + '-swfobject' + ', width=' + obj.configuration.width + ', height=' + obj.configuration.height + ', flashvars={' + flashvarsDebug + '} params={' + paramsDebug + '}');}

		if(obj.buildWoAControls){
			//ensure mousewheel JavaScript library is dynamically loaded
			parliamentUK.pluginLoader('woaZoom');			

			//initialize mousewheel handler to ensure scrolling of page content doesn't occur whilst scrolling inside flash (artwork) swf
			$('.flash').mousewheel(function(event, delta){
				return false;
			});	

			$('<ul />').appendTo($(flashParent))
				.append($('<li />').attr({'id':'pan-left'}).append($('<a />').html('Pan left').attr({'href':'#'})))
				.append($('<li />').attr({'id':'pan-right'}).append($('<a />').html('Pan right').attr({'href':'#'})))
				.append($('<li />').attr({'id':'pan-up'}).append($('<a />').html('Pan up').attr({'href':'#'})))
				.append($('<li />').attr({'id':'pan-down'}).append($('<a />').html('Pan down').attr({'href':'#'})))
				.append($('<li />').attr({'id':'zoom-in'}).append($('<a />').html('Zoom in').attr({'href':'#'})))
				.append($('<li />').attr({'id':'zoom-out'}).append($('<a />').html('zoom-out').attr({'href':'#'})))
			
			$('#pan-left').bind('click',function(){$('#inner-' + flashMoviesOnPage + '-swfobject')[0].executeExternalCall('moveLeft');return false;})
				.next().bind('click',function(){$('#inner-' + flashMoviesOnPage + '-swfobject')[0].executeExternalCall('moveRight');return false;})
				.next().bind('click',function(){$('#inner-' + flashMoviesOnPage + '-swfobject')[0].executeExternalCall('moveUp');return false;})
				.next().bind('click',function(){$('#inner-' + flashMoviesOnPage + '-swfobject')[0].executeExternalCall('moveDown');return false;})
				.next().bind('click',function(){$('#inner-' + flashMoviesOnPage + '-swfobject')[0].executeExternalCall('zoomIn');return false;})
				.next().bind('click',function(){$('#inner-' + flashMoviesOnPage + '-swfobject')[0].executeExternalCall('zoomOut');return false;})
			
		}
	},
	
	//equalize grid columns to ensure grey tramlines run consistently to full page depth (three-wide template only)
	equalizeGrid: function(){
		//only equalize if the specific site has been configured to
		if(siteConfig.equalize[$('BODY').attr('class')].active){
			if(debugLog){parliamentUK.logEvent('[EQUALIZE GRID]: initialize');}
			
			//ensure only the grid elements which exist are equalled
			var equalizeElements = '';
			if($('#secondary-navigation').size() == 1){equalizeElements += '#secondary-navigation,';}
			if($('#content-small').size() == 1){equalizeElements += '#content-small,';}
			if($('#panel').size() == 1){equalizeElements += '#panel,';}
			equalizeElements = equalizeElements.substr(0,equalizeElements.length-1);
			
			if($(document.body).attr('id') != 'grid' && globalObj.pageType != 'education-education-home' && equalizeElements != ''){
				$(equalizeElements).equalHeight({objectToAppend:$('#content-small'),height:siteConfig.equalize[$('BODY').attr('class')].offset});
				
				if(debugLog){parliamentUK.logEvent('[EQUALIZE GRID]: #secondary-navigation (height=' + (isIe6 ? $('#secondary-navigation').height() : $('#secondary-navigation').css('minHeight')) + '), #content-small (height=' + (isIe6 ? $('#content-small').height() : $('#content-small').css('minHeight')) + '), #panel (height=' + (isIe6 ? $('#panel').height() : $('#panel').css('minHeight')) + ')');}
			}
		}
	},	
	
	//run a reset before initializing (tabs-specific)
	resetGrid: function(){
		if(debugLog){parliamentUK.logEvent('[RESIZE GRID]: #secondary-navigation (height=' + (isIe6 ? $('#secondary-navigation').height() : $('#secondary-navigation').css('minHeight')) + '), #content-small (height=' + (isIe6 ? $('#content-small').height() : $('#content-small').css('minHeight')) + '), #panel (height=' + (isIe6 ? $('#content-small').height() : $('#content-small').css('minHeight')) + ')');}
	
		$('#secondary-navigation').css(isIe6 ? {'height':'1px'} : {'min-height':'1px'});
		$('#content-small').css(isIe6 ? {'height':'1px'} : {'min-height':'1px'});
		$('#panel').css(isIe6 ? {'height':'1px'} : {'min-height':'1px'});
		
		parliamentUK.equalizeGrid();
	},
	
	//append an 'alternate' class for alternate elements	
	alternateHighlight: function(obj){
		var debug = '';		
		for(x in obj){debug += x + '=' + obj[x] + ', ';}		
		debug = debug.substr(0,debug.length-2);
	
		if(debugLog){parliamentUK.logEvent('[ALTERNANTE HIGHLIGHT]: ' + debug);}
				
		$(obj.selector,$(obj.wrapper)).each(function(index){
			if(obj.initialShow != undefined){
				if(index >= (obj.initialShow)){
					$(obj.siblingShowHideSelector,$(this)).css('display','none');
				}
			}

			//handle any exceptions here, such as sibling highlights/ignoring initial elements etc
			if(obj.ignoreInitial == undefined || (obj.ignoreInitial != undefined) && ((index) > obj.ignoreInitial)){
				if(obj.siblingShowHideSelector != undefined){
					$(obj.siblingShowHideSelector,$(this)).addClass((index%2 == 0) ? '' : 'alternate');
				}
				else{				
					$(this).addClass((index%2 == 0) ? '' : 'alternate');
				}
			}		
		});	
	},
		
	//initialize all sliding toggle groups
	initToggleSlides: function(obj){
		var debug = '';		
		for(x in obj){debug += x + '=' + obj[x] + ', ';}		
		debug = debug.substr(0,debug.length-2);
		
		if(debugLog){parliamentUK.logEvent('[INIT TOGGLE SLIDES]: ' + debug);}
		
		//before initalizing any animations, inject all relevant triggers
		switch(obj.reference){
			case 'newsListing':
				$('<h4 />').insertAfter($('.thumbnail-image-list',$(obj.wrapper)))
					.append($('<a />').attr({'href':'#'})
							.append($('<img />').attr({'alt':'','src':'/assets/images/plus-blue.gif'}))
							.append($('<span />').html('View all'))
					)

				break;
		}
				
		obj.wrapper.each(function(){
			$(obj.trigger,$(this)).each(function(){
				//create and bind event handlers
				$('A',$(this)).bind('click',function(){					
					//recurse to the correct parent whilst at the correct scope level
					switch(obj.reference){
						case '':
							var toggleChild = '';
							break;
						default:
							var toggleChild = $(this).parent().next();
							break;
					}
					
					$(toggleChild).css('display') == 'block' ? $(toggleChild).slideUp(toggleConfig.slideTime,parliamentUK.completedToggle({obj:this,reference:obj.reference})) : $(toggleChild).slideDown(toggleConfig.slideTime,parliamentUK.completedToggle({obj:this,reference:obj.reference}));
					return false;
				});
				
				$(this).next().css('display','none');
			});
		});	
	},
	
	//onComplete trigger for completed toggle animation
	completedToggle:function(obj){
		if(debugLog){parliamentUK.logEvent('[COMPLETED TOGGLE]: ' + obj.obj + ', ' + obj.reference);}
		
		switch(obj.reference){
			case 'newsListing':
				$('SPAN',$(obj.obj)).html($(obj.obj).parent().next().css('display') == 'block' ? 'View all' : 'Hide all');
				$('IMG',$(obj.obj)).attr('src',$(obj.obj).parent().next().css('display') == 'block' ? '/assets/images/plus-blue.gif' : '/assets/images/minus-blue.gif');
				break;
			case 'educationSubLanding':
				obj.toggleMode == 'show' ? $(obj.obj).parent().addClass('expanded') : $(obj.obj).parent().removeClass('expanded');
				break;
		}
	},
		
	//initialize tab group(s)
	tabsInit: function(){
		if($('.tabs-wrapper.parent').length > 0){
			parliamentUK.initTabGroups();
		}
	},
	
	//manipulate the original code to be non-semantically ordered (for toggling purposes)
	initTabGroups:function(){
		if(debugLog){parliamentUK.logEvent('[TAB GROUP]: initialize');}
		
		//run generic site functionality
		$('TABLE.alternate TR:odd TD').addClass('alternate');
		
		var runningOnHomepage = ($('#content').hasClass('homepage') ? true : false);
		var firstLevel = runningOnHomepage ? 1 : 2;
		var secondLevel = runningOnHomepage ? 2 : 3;
		var thirdLevel = runningOnHomepage ? 3 : 0;
		var firstLevelActiveClass = false;
		var firstLevelActiveIndex = 0;
		var secondLevelActiveClass = false;
		var secondLevelActiveIndex = 0;
		var thirdLevelActiveClass = false;
		var thirdLevelActiveIndex = 0;

		//for each identified tab group, manipulate the DOM to convert HTML markup into post DOM-ready structure
		$('.tabs-wrapper.parent').each(function(index){
			$('<div />').attr({'id':'tabs-container-' + (index+1),'class':'tabs-wrapper tabs-injected'}).insertBefore($(this));
			
			//level 1 tabs
			$('<div />').attr({'class':'triggers level-' + firstLevel}).appendTo($('#tabs-container-' + (index+1)));
			$('<div />').attr({'class':'inner level-' + firstLevel}).appendTo($('#tabs-container-' + (index+1)))
			
			var parentWrapperId = '#tabs-container-' + (index+1);
			
			$(this).children('H4').clone().appendTo($('.triggers:eq(0)',$(parentWrapperId)));
			$(this).children('DIV').clone().appendTo($('.inner:eq(0)',$(parentWrapperId)));

			$('.inner:eq(0)',$(parentWrapperId)).children('DIV').each(function(level1Index){
				//check for active class index
				if($(this).hasClass('active')){
					firstLevelActiveClass = true;
					firstLevelActiveIndex = level1Index;
				}
				
				//level 2 tabs
				if($('DIV.tabs-wrapper',$(this)).length > 0){
					var suffixListLevel1 = $('> .list-suffix',$(this));
					var suffixListExistsLevel1 = $(suffixListLevel1).length > 0 ? true : false;
					var positionInjectionLevel1 = suffixListExistsLevel1 ? 'injectBefore' : 'insertAfter';
					var appendElementLevel1 = suffixListExistsLevel1 ? $('> .list-suffix',$(this)) : $(this);

					switch(positionInjectionLevel1){
						case 'injectBefore':
							$('<div />').attr({'class':'triggers level-' + secondLevel}).insertBefore(appendElementLevel1);
							break;
						case 'insertAfter':
							$('<div />').attr({'class':'triggers level-' + secondLevel}).appendTo(appendElementLevel1);
							break;
					}
					
					//clone headings
					$('.tabs-wrapper:eq(0)',$(this)).children('H4').clone().appendTo($('.triggers.level-' + secondLevel,$(this)));
					
					$('<div />').attr({'class':'inner level-' + secondLevel}).insertAfter($('.triggers.level-' + secondLevel));
					
					//clone content <div>s
					$('.tabs-wrapper:eq(0)',$(this)).children('DIV').clone().appendTo($('.inner:eq(0)',$(this)));
					
					$('.level-' + secondLevel + '.inner',$(this)).children('DIV').each(function(level2Index){
						if($(this).hasClass('active')){
							secondLevelActiveClass = true;
							secondLevelActiveIndex = level2Index;							
						}
					});
					
					//ensure the first tab is selected for level 2 (if not active state was supplied)
					if(!secondLevelActiveClass){$('.level-' + secondLevel + '.inner',$(this)).children('DIV:eq(0)').addClass('active').parent().prev().children('H4:eq(0)').addClass('active');}
					
					//reset auto-selection states for tabs where an active state has not been pre-supplied in the markup
					secondLevelActiveClass = false;
					secondLevelActiveIndex = 0;
					
					//level 3 tabs
					$('.inner:eq(0)',$(this)).children('div').each(function(level3Index){
						if($('DIV.tabs-wrapper',$(this)).length > 0){
							var suffixListLevel2 = $('> .list-suffix',$(this));
							var suffixListExistsLevel2 = $(suffixListLevel2).length > 0 ? true : false;
							var positionInjectionLevel2 = suffixListExistsLevel2 ? 'injectBefore' : 'insertAfter';
							var appendElementLevel2 = suffixListExistsLevel2 ? $('> .list-suffix',$(this)) : $(this);

							switch(positionInjectionLevel2){
								case 'injectBefore':
									$('<div />').attr({'class':'triggers level-' + thirdLevel}).insertBefore(appendElementLevel2);
									break;
								case 'insertAfter':
									$('<div />').attr({'class':'triggers level-' + thirdLevel}).appendTo(appendElementLevel2);
									break;
							}
							
							//clone headings
							$('.tabs-wrapper:eq(0)',$(this)).children('H4').clone().appendTo($('.triggers:eq(0)',$(this)));

							$('<div />').attr({'class':'inner level-' + thirdLevel}).insertAfter($('.triggers.level-' + thirdLevel,$(this)));
							
							//clone content <div>s
							$('.tabs-wrapper:eq(0)',$(this)).children('DIV').clone().appendTo($('.inner:eq(0)',$(this)));
							
							$('.level-' + thirdLevel + '.inner',$(this)).children('DIV').each(function(level3Index){
								if($(this).hasClass('active')){
									thirdLevelActiveClass = true;
									thirdLevelActiveIndex = level3Index;
								}
							});
							
							//ensure the first tab is selected for level 3 (if not active state was supplied)
							if(!thirdLevelActiveClass){$('.level-' + thirdLevel + '.inner',$(this)).children('DIV:eq(0)').addClass('active').parent().prev().children('H4:eq(0)').addClass('active');}
							
							//reset auto-selection states for tabs where an active state has not been pre-supplied in the markup
							thirdLevelActiveClass = false;
							thirdLevelActiveIndex = 0;							
						}
					});
					
					//remove all instances of the original tab wrappers
					$('.tabs-wrapper',$(this)).remove();
				}
			});
			
			//ensure the first tab is selected for level 1 (if not active state was supplied)
			if(!firstLevelActiveClass){$('.level-' + firstLevel + '.inner',$(parentWrapperId)).children('DIV:eq(0)').addClass('active').parent().prev().children('H4:eq(0)').addClass('active');}
			
			//reset auto-selection states for tabs where an active state has not been pre-supplied in the markup
			firstLevelActiveClass = false;
			firstLevelActiveIndex = 0;
			
			//assign last class to all last trigger elements, at levels 1, 2 and 3
			$('.triggers').each(function(){
				$('H4:last',$(this)).addClass('last');
			});
			
			//assign necesary event handlers and run initial toggle state
			parliamentUK.tabEventHandlers({tabsWrapper:$(parentWrapperId)});
		}).remove();		
	},
	
	//handle eventHandlers for toggle tab switching
	toggleTabs: function(tabsObj){
		var debug = '';		
		for(x in tabsObj){debug += x + '=' + tabsObj[x] + ', ';}		
		debug = debug.substr(0,debug.length-2);
		
		if(debugLog){parliamentUK.logEvent('[TOGGLE TABS]: ' + debug);}
		
		//re-assign "active" class to the newly selected h4 tab heading		
		$('H4',tabsObj.triggerObj.parent().parent()).each(function(index){
			(tabsObj.toggleId == index) ? $(this).addClass('active') : $(this).removeClass('active');
		});
		
		//re-assign "display" types to the newly selected sub-tab content block
		tabsObj.triggerObj.parent().parent().next().children('DIV').each(function(index){
			(tabsObj.toggleId == index) ? $(this).addClass('active') : $(this).removeClass('active');
		});
	},
	
	tabEventHandlers:function(tabsObj){
		var debug = '';		
		for(x in tabsObj){debug += x + '=' + tabsObj[x] + ', ';}		
		debug = debug.substr(0,debug.length-2);
		
		if(debugLog){parliamentUK.logEvent('[TAB EVENT HANDLERS]: ' + debug);}
		
		//initialize all nevessary eventHandlers for tab headings (irrespective of tab depth
		$('.triggers',tabsObj.tabsWrapper).each(function(){
			$('H4 A',$(this)).each(function(index){
				$(this).bind('click',function(){
					parliamentUK.toggleTabs({toggleId:index,triggerObj:$(this)});
					
					//reset and re-initialize page grid after each tab toggle
					parliamentUK.resetGrid();
					return false;
				});
			});
		});	
	},
	
	//handle events sent out from Flash movies
	//todo:
	//	- subtitles (identify between subtitles-on and subtitles-off)
	//	- duration (update from every 10ms to every 1%, fix but which always sends 0 value as params.position)
	//	- volume (update so it only sends a tracking request on mouseUp)
	flashTracking: function(playerID,playerType,eventType,params){
		switch(eventType){
			case 'play':
				if(debugLog){parliamentUK.logEvent('[FLASH TRACKING]: Event type=' + eventType + ', playerID: ' + playerID + ', playerType:' + playerType);}
				if(tracking.enabled){pageTracker._trackEvent(playerType,'play',playerID);}
				
				break;
			case 'pause':
				if(debugLog){parliamentUK.logEvent('[FLASH TRACKING]: Event type=' + eventType + ', playerID: ' + playerID + ', playerType: ' + playerType);}
				if(tracking.enabled){pageTracker._trackEvent(playerType,'pause',playerID);}
				
				break;
			case 'subtitles':
				//todo
				if(debugLog){parliamentUK.logEvent('[FLASH TRACKING]: Event type=' + eventType + ', playerID=' + playerID + ', playerType=' + playerType);}
								
				break;
			case 'fullscreen':
				if(debugLog){parliamentUK.logEvent('[FLASH TRACKING]: Event type=' + eventType + ', playerID=' + playerID + ', playerType=' + playerType);}
				if(tracking.enabled){pageTracker._trackEvent(playerType,'fullscreen',playerID);}				
				
				break;
			case 'duration':
				//todo
				if(debugLog){parliamentUK.logEvent('[FLASH TRACKING]: Event type=' + eventType + ', playerID=' + playerID + ', playerType=' + playerType + ', position=' + params.position);}
				
				break;
			case 'quality':
				if(debugLog){parliamentUK.logEvent('[FLASH TRACKING]: Event type=' + eventType + ', playerID=' + playerID + ', playerType=' + playerType + ', quality=' + params.quality);}
				if(tracking.enabled){pageTracker._trackEvent(playerType,'quality (' + params.quality + ')',playerID);}
				
				break;
			case 'info':
				if(debugLog){parliamentUK.logEvent('[FLASH TRACKING]: Event type=' + eventType + ', playerID=' + playerID + ', playerType=' + playerType);}
				if(tracking.enabled){pageTracker._trackEvent(playerType,'info',playerID);}
				
				break;
			case 'volume':
				//todo
				if(debugLog){parliamentUK.logEvent('[FLASH TRACKING]: Event type=' + eventType + ', playerID=' + playerID + ', playerType=' + playerType + ', volume=' + params.volume);}
								
				break;
			default:
				if(debugLog){parliamentUK.logEvent('[FLASH TRACKING]: Event type=' + eventType + ' not recognised');}
				break;
		}
	},
		
	//handle left floated images, in order to force the widths of the floated <div>s
	floatedImageWrapInit: function(obj){
		if(isIe6 || isIe7){
			$(obj.floatWrapperClass).each(function(){
				var currentFloat = $(this);
				
				//set left floated width dimension
				var embeddedImage = $('IMG',$(this));
				if($(embeddedImage).size() == 1){
					$(this).css('width',$(embeddedImage).width());
				}
				
				//update the parent anchor tag
				var parentAnchor = $(this).parent().is('A');
				if(parentAnchor){
					$(embeddedImage)
						.css({'cursor':'pointer'})
						.bind('click',function(){
							top.location.href=$(currentFloat).parent().attr('href');
						});
				}
			});
		}
	},

	//dynamic DOM element creation
	createElement: function(obj){
		//obj.type
		//obj.id
		//obj.className
		//obj.appendTo
		//obj.innerHTML
		//obj.other
		//obj.insertMode
		//parliamentUK.createElement({type:'',id:'',className:'',appendTo:'',innerHTML:'',other:'',insertMode:''});	
		
		var debug = '';		
		for(x in obj){debug += x + '=' + obj[x] + ', ';}		
		debug = debug.substr(0,debug.length-2);
		
		if(debugLog){parliamentUK.logEvent('[CREATE ELEMENT]: ' + debug);}
		
		//due to IE6 not supporting DOM manipulation for CSS files at runtime, use native Javascript code to append to the document head
		if(isIe && obj.type == 'LINK'){
			var objCSS = document.createElement('link');
			objCSS.type = 'text/css';
			objCSS.href = obj.other.href;
			objCSS.rel = 'stylesheet';
			objCSS.media = 'screen';
			document.getElementsByTagName('HEAD')[0].appendChild(objCSS);
			
			return;
		}
		
		$newDOMElement = $('<' + obj.type + '>'); 
		if(obj.id != undefined){$newDOMElement.attr('id',obj.id);}
		if(obj.className != undefined){$newDOMElement.attr('class',obj.className);}
		if(obj.innerHTML != undefined){$newDOMElement.html(obj.innerHTML);}

		//loop through additional properties of object for dynamically adding via dot notation
		if(obj.other != undefined){
			if(typeof(obj.other) == "object"){
				for(property in obj.other){
					$newDOMElement.attr(property,obj.other[property]);
				}
			}		
		}

		switch(obj.insertMode){
			case "insertAfter":
				$(obj.appendTo).append($newDOMElement);
				break;
			case "injectBefore":
				$newDOMElement.insertBefore($(obj.appendTo));
				break;
			case "injectAfter":
				$newDOMElement.insertAfter($(obj.appendTo));
				break;
			case "insertBefore":
				$(obj.appendTo).prepend($newDOMElement);
				break;
		}		
	},

	//global mechanism for tracking events to the console	
	logEvent: function(event){
		if(window.console && window.console.log){
			console.log(event);
		}
	},
	
	//required browser sniffer for XmlHttp() Rss retrieval
	browserSniffer: function(){
		agent = navigator.userAgent.toLowerCase();
		isMajor = parseInt(navigator.appVersion);
		
		isIe = (agent.indexOf('msie') != -1);
		isIe6 = (isIe && (isMajor == 4) && agent.indexOf("msie 6.")!=-1);
		isIe7 = (isIe && (isMajor == 4) && agent.indexOf("msie 7.")!=-1);
		isIe8 = (isIe && (isMajor == 4) && agent.indexOf("msie 8.")!=-1);
		isFirefox = ((agent.indexOf('firefox')!=-1));
		isOpera = ((agent.indexOf('opera')!=-1));
		isWindows = ((agent.indexOf('win')!=-1) || (agent.indexOf('16bit')!=-1));
		
		if(debugLog){parliamentUK.logEvent('[BROWSER DETAILS]: agent=' + agent + ', IE=' + isIe + ', IE6=' + isIe6 + ', IE7=' + isIe7 + ', IE8=' + isIe8 + ', Firefox=' + isFirefox, Opera=' + isOpera');}
	}
}

//handle page specific init() on a site AND page-by-page basis for any non-global init() routines
parliamentUK.page = {
	//obj.site == '' OR 'committees' OR 'mlo' OR 'woa'
	//obj.pageId
	init: function(obj){
		//run an global site functionality
		//add alternate row colouring for <table>s within the inquiries module (committees landing page)
		parliamentUK.alternateHighlight({wrapper:'.rte TBODY',selector:'TR',siblingShowHideSelector:'TD'});
								
		switch(obj.site){
			//Committees site: page specific init()
			case 'committees':
				switch(obj.pageType){
					case 'committee-landing':
						//add alternate row colouring for <table>s within the inquiries module (committees landing page)
						parliamentUK.alternateHighlight({wrapper:'.inquiries-a-to-z TBODY',selector:'TR',siblingShowHideSelector:'TD'});
						
						//initialize tab group(s)
						parliamentUK.tabsInit();
						
						break;
					case 'committees-previous-inquiry':
						//create alternate row colouring for "previous enquiry" table
						parliamentUK.alternateHighlight({wrapper:'TABLE.publications-records TBODY',selector:'TR',siblingShowHideSelector:'TD'});
						
						break;
					case 'committee-inquiry-detail':
						//initialize all sliding toggle groups
						parliamentUK.initToggleSlides({wrapper:$('.news-listing.toggle'),trigger:'H4',reference:'newsListing'});

						//create toggle triggers for 'What's on' events <table>
						parliamentUK.committees.whatsOnEventsTriggerInit();
						
						//create alternate row colouring as well as toggling event handlers for 'Publications and records' <table>
						parliamentUK.committees.publicationsAndRecordsInit(obj.main.publicationsAndRecordsInitialShow);
												
						break;
					case 'committee-detail':
						//initialize all sliding toggle groups
						parliamentUK.initToggleSlides({wrapper:$('.news-listing.toggle'),trigger:'H4',reference:'newsListing'});

						//create toggle triggers for 'What's on' events <table>
						parliamentUK.committees.whatsOnEventsTriggerInit();
						
						//create alternate row colouring as well as toggling event handlers for 'Publications and records' <table>
						parliamentUK.committees.publicationsAndRecordsInit(obj.main.publicationsAndRecordsInitialShow);
												
						break;
				}
				break;
			//MLO site: page specific init()
			case 'mlo':
				switch(obj.pageType){
					case 'mlo-members-filter-listing':
					case 'complete-ssi-template':
						//add alternate	row colouring for all <table>s within members filter list (results page)
						$('#members-filter-listing TBODY').each(function(){
							parliamentUK.alternateHighlight({wrapper:$(this),selector:'TR',siblingShowHideSelector:'TD'});
						});
						break;
				}
				break;
			//WoA site: page specific init()
			case 'woa':
				//re-define page heading depths
				var pageHeading = $('#page-heading');
				if($(pageHeading).length == 1){
					var additionalSpacing = $('H1',$(pageHeading)).height() > $('FIELDSET',$(pageHeading)).height() ? 0 : 10;
					$(pageHeading).css('height',($('H1',$(pageHeading)).height() + additionalSpacing) + 'px');
				}
								
				switch(obj.pageType){
					case 'woa-start':
						//fire this event on window load rather than DOM ready as images need to exist and be downloaded before calculating offsets
						$(window).load(function(){
							parliamentUK.woa.highlightImageEqualize({pageType:'woa-start',equalizeObj:'EM A'});					
						});
						
						break;
					case 'woa-image-unpack':
						//assign event handlers to trigger points for all 'in-the-picture' pages						
						parliamentUK.woa.inThePictureInit();
						
						break;
					case 'woa-email-a-friend':
						//add alternate row colouring for <li>s within the 'Send a Friend' page
						parliamentUK.alternateHighlight({wrapper:'#send-a-friend FIELDSET:eq(0) OL',selector:'LI'});
						parliamentUK.alternateHighlight({wrapper:'#send-a-friend FIELDSET:eq(1) OL',selector:'LI'});
						
						break;
					case 'woa-compare-contrast-detail':
						//fire this event on window load rather than DOM ready as images need to exist and be downloaded before calculating offsets
						$(window).load(function(){
							parliamentUK.woa.highlightImageEqualize({pageType:'woa-compare-contrast-detail',equalizeObj:'EM'});
						});
						
						break;
					case 'woa-search-listings':
						parliamentUK.alternateHighlight({wrapper:$('#search-results UL:first'),selector:'>LI'});
						
						break;
					case 'woa-collection-highlights':
						//fire this event on window load rather than DOM ready as images need to exist and be downloaded before calculating offsets
						$(window).load(function(){
							parliamentUK.woa.highlightImageEqualize({pageType:'woa-collection-highlights',equalizeObj:'EM A'});
						});						
						
						break;
					case 'woa-artwork':
						//remove 'zoom' option from markup as JavaScript will handle the zooming feature
						if($('#artwork-options LI#zoom').size() == 1){
							$('#artwork-options LI#zoom').remove();
						}
						
						//add alternate row colouring for artwork overview table rows
						parliamentUK.alternateHighlight({wrapper:$('.alternate-rows'),selector:'>LI'});
						
						break;
					case 'woa-advanced-search':
						parliamentUK.alternateHighlight({wrapper:$('#advanced-search OL'),selector:'>LI'});
						
						//initialize advanced search form
						parliamentUK.woa.advancedSearchInit();
						
						break;
				}
				
				break;
			case 'popvox':
				//create and assign event handlers for theme switcher
				$('#theme-switcher #default').unbind('click').bind('click',function(){$('#wrapper').attr('class','');return false;});
				$('#theme-switcher #green').unbind('click').bind('click',function(){$('#wrapper').attr('class','green');return false;});
				$('#theme-switcher #orange').unbind('click').bind('click',function(){$('#wrapper').attr('class','orange');return false;});
				$('#theme-switcher #pink').unbind('click').bind('click',function(){$('#wrapper').attr('class','pink');return false;});
				
				switch(obj.pageType){
					case 'popvox-generic-content':
						//initialize 'more/less' toggle elements (in panel)
						parliamentUK.popvox.panelToggleInit();
						
						break;
				}
				
				break;
			case 'education':
				//create and assign event handlers for theme switcher
				$('#theme-switcher #default').unbind('click').bind('click',function(){$('#wrapper').attr('class','');return false;});
				$('#theme-switcher #green').unbind('click').bind('click',function(){$('#wrapper').attr('class','green');return false;});
				$('#theme-switcher #orange').unbind('click').bind('click',function(){$('#wrapper').attr('class','orange');return false;});
				$('#theme-switcher #pink').unbind('click').bind('click',function(){$('#wrapper').attr('class','pink');return false;});
				
				switch(obj.pageType){
					case 'education-education-home':
						//equalize the heights of the homepage secondary navigation groups
						$('#secondary-navigation UL').equalHeight({objectToAppend:$('#secondary-navigation UL'),height:-50});						
						$('#secondary-navigation UL H4').equalHeight({objectToAppend:$('#secondary-navigation UL H4'),height:-20});
						
						break;
					case 'education-picture-viewer':
						//load in the required JavaScript plugin for the image viewer
						parliamentUK.pluginLoader('woaPictureViewer');
						
						//run init for image viewer, creating all animation
						$('#picture-viewer').imageViewer({slideTime:educationPictureViewerConfig.slideTime});					

						break;
					case 'education-sub-landing':
					case 'education-tabbed-content':
					case 'education-tabbed-content-item':
						if(obj.pageType == 'education-tabbed-content' || obj.pageType == 'education-tabbed-content-item'){
							//initialize tab group(s)
							parliamentUK.tabsInit();
						}

						//initialize resource toggle groups (inside and outside of tab groups)
						parliamentUK.education.resourceToggleInit(obj);
												
						//initialize Shadowbox/Lightbox functionality for interactive layer "popups"
						parliamentUK.pluginLoader('educationShadowbox');
												
						break;
					case 'main-generic-content':
						//handle left floated images, in order to force the widths of the floated <div>s
						parliamentUK.floatedImageWrapInit({floatWrapperClass:'.left'});
						
						break;
				}

			//Main site: page specific init()
			default:
				switch(obj.pageType){
					case 'main-start':
						//initialize tab group(s)
						parliamentUK.tabsInit();
						
						break;
					case 'main-gallery-artwork':
						//add alternate row colouring for gallery details
						parliamentUK.alternateHighlight({wrapper:$('.alternate-rows'),selector:'>LI'});
						
						break;
					case 'main-news-landing':
					case 'main-news-topic':
						//add alternate row colouring for <table>s within the 'News Topic' page (which uses the news-listing uid)
						parliamentUK.alternateHighlight({wrapper:$('#news-landing TABLE TBODY'),selector:'TR',siblingShowHideSelector:'TD'});
						
						break;
					case 'main-publications-calendar-listing':
						//initialize events calendars
						parliamentUK.main.calendarInit({ajaxUrl:obj.main.calendarListingAjaxUrl,pageInstanceId:obj.pageInstanceId});
						
						//despite asynchronous setings, IE6 requires a grid reset once the calendar has been initialized
						if(isIe6){setTimeout("parliamentUK.resetGrid()",1);}
						
						break;
					case 'main-send-a-friend':
						//add alternate row colouring for <li>s within the 'Send a Friend' page
						parliamentUK.alternateHighlight({wrapper:'#send-a-friend FIELDSET:eq(0) OL',selector:'LI'});
						parliamentUK.alternateHighlight({wrapper:'#send-a-friend FIELDSET:eq(1) OL',selector:'LI'});
						
						break;
					case 'main-advanced-search':
					case 'main-search-results':	
						//initialize advanced search form
						parliamentUK.main.advancedSearchInit(obj);
			
						break;
					case 'main-landing-advanced':
						//initialize tab group(s)
						parliamentUK.tabsInit();
						
						break;
					case 'main-generic-content':
						//handle left floated images, in order to force the widths of the floated <div>s
						parliamentUK.floatedImageWrapInit({floatWrapperClass:'.left'});
						
						break;
				}
				break;
		}
	}
}