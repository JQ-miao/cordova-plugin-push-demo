/*
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */
var app = {
    // Application Constructor
    initialize: function() {
        this.bindEvents();
    },
    // Bind Event Listeners
    //
    // Bind any events that are required on startup. Common events are:
    // 'load', 'deviceready', 'offline', and 'online'.
    bindEvents: function() {
        document.addEventListener('deviceready', this.onDeviceReady, false);

    },
    // deviceready Event Handler
    //
    // The scope of 'this' is the event. In order to call the 'receivedEvent'
    // function, we must explicitly call 'app.receivedEvent(...);'
    onDeviceReady: function() {
        app.receivedEvent('deviceready');
    },
    // Update DOM on a Received Event
    receivedEvent: function(id) {
        var parentElement = document.getElementById(id);
        var listeningElement = parentElement.querySelector('.listening');
        var receivedElement = parentElement.querySelector('.received');

        listeningElement.setAttribute('style', 'display:none;');
        receivedElement.setAttribute('style', 'display:block;');
        console.log('Received Event: ' + id);
        
        var options = {
            autoClearBadge:"true",
            
            url: "https://mobile.ng.bluemix.net/imfpush/v1/apps/7db9d2a8-5b87-456c-a537-d0a6199256ef/devices/",
            clientSecret:"8a277a34-7516-45c2-87a6-555bd91d6a42",
            applicationMode:"PRODUCTION",
            platform:"A",
            deviceID: "miaotest02",
            userID: "miaotest02"
        }

        var push = PushNotification.init(options);
        push.notificationsListener(function(data){
            alert(data);
        });
        push.getBadgeNumber(function(number){
            console.log('getBadgeNumber' + number);
        });
        push.reduceBadgeNumber(5);
        
        var aa = {
            url: "https://mobile.ng.bluemix.net/imfpush/v1/apps/7db9d2a8-5b87-456c-a537-d0a6199256ef/devices/",
            deviceID: "miaotest02"
        }
        push.deleteDeviceRegistered(aa);
        
    }
};

app.initialize();
