/**
 * @File Name          : HomeCaleandarHelper.js
 * @Description        : 
 * @Author             : gilhwan.ahn@hanwha.com
 * @Group              : 
 * @Last Modified By   : younghoon.kim@dkbmc.com
 * @Last Modified On   : 2021-03-09
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    2020-02-25   woomg@dkbmc.com     			Initial Version
 * 1.1    2021-02-05   younghoon.kim@dkbmc.com     	My Team 로직 추가
**/
({
	doInit : function(component, event){
		var self = this,
			dt = new Date(),
			nYear = dt.getFullYear(),
			nMonth = dt.getMonth(),
			months = component.get("v.months");

		self.apex(component, 'monthSetting', { })
		.then(function(result){
			window.console.log('result : ', result);
			component.set('v.months', result); 
		})
		.catch(function(errors){
			self.errorHandler(errors);
		});

		component.set("v.nYear", nYear);
		component.set("v.nMonth", nMonth);
		component.set("v.yearMonth", months[nMonth]+' '+nYear);
		
		self.queryActivity(component, event);
	},

	queryActivity : function(component, event){
		var self = this,
			nYear = component.get("v.nYear"),
			nMonth = component.get("v.nMonth"),
			myTeam = component.get('v.myTeam');

		var checked = {
			Event : component.get('v.default_event'),
			Task : component.get('v.default_task'),
			AcctPlan : component.get('v.default_accPlan'),
			OpptyAct : component.get('v.default_opptyAct')
		}
		
		self.apex(component, 'getMyActivities', { 
			sYear : '' + nYear, 
			sMonth : '' + (nMonth+1),
			jsonObj : JSON.stringify(checked),
			myTeam : myTeam
		})
		.then(function(result){
			component.set("v.activity", result);
			self.drawCalendar(component, event);
		})
		.catch(function(errors){
			self.errorHandler(errors);
			component.set("v.showSpinner", false);
		});
			
		var dt = new Date(),
			nDay = dt.getDate();

		var targetDate = nYear + '-' + self.pad(nMonth+1, 2) + '-' + self.pad(nDay, 2);
		self.getTodayAvtivity(component, targetDate);
	},

	getTodayAvtivity : function(component, targetDate){
		var checked = {
			Event : component.get('v.default_event'),
			Task : component.get('v.default_task'),
			AcctPlan : component.get('v.default_accPlan'),
			OpptyAct : component.get('v.default_opptyAct')
		}

		var myTeam = component.get('v.myTeam');

		var self = this,
			today = [],
			j=0,
			str_today = '';

		component.set("v.showSpinner", true);
		
		self.apex(component, 'getTodayActivities', { targetDate : targetDate, jsonObj : JSON.stringify(checked) , myTeam : myTeam})
		.then(function(result){
			str_today = result.Today;
			for(var i=0; i<JSON.parse(result.Activity).length; i++){
				if(targetDate == JSON.parse(result.Activity)[i].activeDate){
					today[j] = JSON.parse(result.Activity)[i];
					j++;
				}
			}
			component.set("v.todays", today);
		})
		.catch(function(errors){
			self.errorHandler(errors);
			component.set("v.showSpinner", false);
		}).finally(function(){
			component.set('v.selectedDate', str_today);
			component.set("v.showSpinner", false);
		});
		
	},

	drawCalendar : function(component, event) {
		var self 	 = this,
			nYear 	 = component.get("v.nYear"),
			nMonth 	 = component.get("v.nMonth"),
			lMonth 	 = component.get("v.months"),
			calendar = [],
			calBody;

		calendar = this.buildDaysRow(nYear, nMonth);
		calBody  = this.buildCalendarBody(component, nYear, nMonth, calendar);

		// Cannot read property 'firstChild' of null : 해당 에러를 방지하기 위한 timeout
		// calFrame이 모두 그려지기 전에 getElement()를 해와서 firstChild를 찾지 못하는 오류 -> 0.3초 후 불러오도록 조정
        window.setTimeout( ()=> {
			var calFrame = component.find("cal-frame").getElement();
			while(calFrame.firstChild){
				calFrame.removeChild(calFrame.firstChild);
			}
			calFrame.insertAdjacentHTML('beforeend', calBody);
			component.set("v.yearMonth", lMonth[nMonth] + ' ' + nYear);

			calFrame.addEventListener('click', function(ev){
				var tagName  = ev.target.localName,
					targetId = ev.target.id||ev.target.parentElement.id,
					targetTxt= ev.target.innerText.trim();
				if(tagName == 'span'){
					targetId = ev.target.parentElement.parentElement.id;
				} else if(tagName == 'div'){
					tagName = ev.target.parentElement.parentElement.id;
				}

				// 클릭된 div 배경색 변경
				var targetObj  = document.getElementById(targetId);
				var beforetargetObj  = document.getElementsByClassName('setSelected')[0];
				$A.util.removeClass(beforetargetObj,'setSelected');
				if( targetObj != null) $A.util.addClass(targetObj,'setSelected');

				if(targetId){ // 실제 Data가 있는 경우만 선택 가능해야 하는 경우 추가 -> && targetTxt.includes( '✓')
					self.getTodayAvtivity(component, targetId);
				}else{
					var todayList = [];
					component.set('v.selectedDate', '');
					component.set('v.todays', todayList);
				}

			}, true);
		}, 300);
	},

	nextMonth : function(component, event){
		var nYear = component.get("v.nYear"),
			nMonth = component.get("v.nMonth");
		
		if(nMonth == 11){
			nMonth = 0;
			nYear = nYear + 1;
		} else {
			nMonth = nMonth + 1;
		}
		component.set("v.nYear", nYear);
		component.set("v.nMonth", nMonth);
		// component.set('v.myTeam', false);

		this.queryActivity(component, event);
	},

	prevMonth : function(component, event){
		var nYear = component.get("v.nYear"),
			nMonth = component.get("v.nMonth");
		
		if(nMonth == 0){
			nMonth = 11;
			nYear = nYear - 1;
		} else {
			nMonth = nMonth - 1;
		}
		component.set("v.nYear", nYear);
		component.set("v.nMonth", nMonth);
		// component.set('v.myTeam', false);

		this.queryActivity(component, event);
	},

	getTeamActivity : function(component, event){
		var nYear = component.get("v.nYear"),
			nMonth = component.get("v.nMonth");

		this.queryActivity(component, event);
	},

	gotoActivity : function(component, ev){
		var targetId = ev.target['id'];
		var navEvt = $A.get("e.force:navigateToSObject");
		navEvt.setParams({
			"recordId": targetId,
			"slideDevName": "detail",
			"isredirect": false
		});
		navEvt.fire();
	},

	buildDaysRow : function(nYear, nMonth){
		var leapYear = (((nYear % 4 == 0) && (nYear % 100 != 0)) || (nYear % 400 == 0)),
			daysInMonths = [31, leapYear ? 29 : 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31],
			haveDays = true,
			day = 1, i, j,
			startDay = new Date(nYear, nMonth, day).getDay(),
			calendar = [];

		i = 0;
		while(haveDays){
			calendar[i] = [];
			for(j = 0; j < 7; j++){
				if(i === 0){
					if(j === startDay){
						calendar[i][j] = day++;
						startDay++;
					}
				} else if(day <= daysInMonths[nMonth]){
					calendar[i][j] = day++;
				} else {
					calendar[i][j] = undefined;
					haveDays = false;
				}
				if(day > daysInMonths[nMonth]){
					haveDays = false;
				}
			}
			i++;
		}
		return calendar;
	},

	buildCalendarBody : function(component, nYear, nMonth, calendar){
		var today = new Date();
		var dd = String(today.getDate()).padStart(2, '0');
		var mm = String(today.getMonth() + 1).padStart(2, '0'); //January is 0!
		var yyyy = today.getFullYear();

		today = yyyy + '-' + mm + '-' + dd;

		var calBody,
			activity = component.get("v.activity");

		calBody = "<table><tbody>";
		for (var i = 0; i < calendar.length; i++) {
			calBody += "<tr>"
			for(var j = 0; j < 7; j++) {
				var pMon = this.pad(nMonth+1, 2),
					nDay = calendar[i][j],
					date = "";
				if(nDay != undefined){
					var pDay = this.pad(nDay, 2);
					date = nYear + '-' + pMon + '-' + pDay;
				} else {
					nDay = "";
				}
				if(today == date) calBody += "<td id='" + date + "' class='setToday'>" + nDay;
				else 			  calBody += "<td id='" + date + "' >" + nDay;
				calBody += "<div class='activity'>";
				if(nDay != ""){
					if(activity.event[date] != undefined){
						
						let eventArr = activity.event[date];
						let evtIdx 	 = eventArr.indexOf( "Event");
						if( evtIdx  > -1){
							calBody += "<span class='event' style='font-weight:bold'>✓</span>";
							eventArr.splice( evtIdx, 1);
						}
						if( eventArr.length > 0){
							calBody += "<span class='activityN' style='font-weight:bold'>✓</span>";
						}
					}
					if(activity.task[date] != undefined){
						let taskArr = activity.task[date];
						let todoIdx = taskArr.indexOf( "Task");
						if( todoIdx > -1){
							calBody += "<span class='task'  style='font-weight:bold'>✓</span>"; //&#9873
						}
						
						let payAlaram = taskArr.indexOf( 'PaymentAlarm');
						if( payAlaram > -1){
							calBody += "<span class='payAlarm'  style='font-weight:bold'>✓</span>"; //&#9873
						}
					}

					if(activity.accPlan[date] != undefined){
						let accArr = activity.accPlan[date];
						let idx = accArr.indexOf("AccountPlan");
						if(idx > -1){
							calBody += "<span class='plan'  style='font-weight:bold'>✓</span>";
						}
					}

					if(activity.opptActivity[date] != undefined){
						let opptArr = activity.opptActivity[date];
						let idx = opptArr.indexOf("Opportunity Activity");
						if(idx > -1){
							calBody += "<span class='activityN'  style='font-weight:bold'>✓</span>";
						}
					}
						
					if(activity.task[date] == undefined && activity.event[date] == undefined)
						calBody += "<span>&nbsp;</span>";
				}
				calBody += "</div>";
				calBody += "</td>";
			}
			calendar[i] = "<tr><td>" + calendar[i].join("</td><td>") + "</td></tr>";
			calBody += "</tr>";
		}
		calBody += "</tbody></table>";

		return calBody;
	},

	pad : function(n, width, z){
		z = z || '0';
		n = n + '';
		return n.length >= width ? n : new Array(width - n.length + 1).join(z) + n;
	},

    apex : function(component, apexAction, params){
        return new Promise( $A.getCallback( function( resolve, reject ) {
            var action = component.get("c."+apexAction+"");
            action.setParams( params );
            action.setCallback( this, function(callbackResult) {
                if(callbackResult.getState()=='SUCCESS') {
                    resolve( callbackResult.getReturnValue() );
                }
                if(callbackResult.getState()=='ERROR') {
                    console.log('ERROR', callbackResult.getError() ); 
                    reject( callbackResult.getError() );
                }
            });
            $A.enqueueAction( action );
        }));
    },

	errorHandler : function(errors){
		var self = this;
		if(Array.isArray(errors)){
			errors.forEach(function(err){
				self.showMyToast('error', err.exceptionType + " : " + err.message);
			});
		} else {
			console.log(errors);
			self.showMyToast('error', 'Unknown error in javascript controller/helper.')
		}
	},

    showMyToast : function(type, msg) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            type: type,
            duration: 10000,
            mode: 'sticky',
            message: msg
        });
        toastEvent.fire();
	},
})