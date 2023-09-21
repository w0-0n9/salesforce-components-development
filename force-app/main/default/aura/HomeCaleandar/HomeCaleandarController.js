/**
 * @author            : younghoon.kim@dkbmc.com
 * @group             : 
 * @description       : 
 * @last modified on  : 2021-02-24
 * @last modified by  : younghoon.kim@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author                    Modification
 * 1.0   2020-11-09   younghoon.kim@dkbmc.com   Initial Version
 * 1.1   2021-02-05   younghoon.kim@dkbmc.com   My Team 로직 추가
**/
({
	doInit : function(component, event, helper){
		var device = $A.get( "$Browser.formFactor");
		if( device != "DESKTOP") component.set( "v.isMobile", true);

		helper.doInit(component, event);
	},

	prevMonth : function(component, event, helper){
		helper.prevMonth(component);
	},

	nextMonth : function(component, event, helper){
		helper.nextMonth(component);
	},
	
	gotoActivity : function(component, event, helper){
		helper.gotoActivity(component, event);
	},

	getMyTeam : function(component, event, helper){
		helper.getTeamActivity(component, event);
	},

	handleChange : function(component, event, helper){
		helper.queryActivity(component, event);
	}
})