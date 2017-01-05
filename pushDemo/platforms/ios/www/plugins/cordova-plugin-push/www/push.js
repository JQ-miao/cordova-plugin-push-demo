cordova.define("cordova-plugin-push.PushNotification", function(require, exports, module) {

/* A bridge that put notifications on bluemix server.
*/           
  var exec = require('cordova/exec'); 

  var PushNotification = function(options){
    if (typeof options === 'undefined') {
          throw new Error('The options argument is required.');
      }

      var successCallback = function(token){
         console.log("---TOKEN--- :" + token);
        //alert("--TOKEN-- :" + token);
      }

      var errorCallback = function(error){
         console.log("---GET-TOKEN-ERROR--- :" + error);
        //alert("--GET-TOKEN-ERROR-- :" + error);
      }
      exec(successCallback, errorCallback, 'PushNotification', 'init', [options]);
  };

  PushNotification.prototype.notificationsListener = function(callback){
    if (typeof callback !== 'function')  {
          console.log('PushNotification.notificationsListener failure: parameter must be a function');
          return;
      }
    exec(callback, null, 'PushNotification', 'notificationsListener', []);
  };

  PushNotification.prototype.getBadgeNumber = function(callback){
    if (typeof callback !== 'function')  {
          console.log('PushNotification.getBadgeNumber failure: parameter must be a function');
          return;
      }
    exec(callback, null, 'PushNotification', 'getBadgeNumber', []);
  };

  PushNotification.prototype.reduceBadgeNumber = function(count){
    exec(null, null, 'PushNotification', 'reduceBadgeNumber', [count]);
  };

  PushNotification.prototype.deleteDeviceRegistered = function(options){
    exec(null, null, 'PushNotification', 'deleteDeviceRegistered', [options]);
  };

  //Provides API.
  module.exports = {

    init: function(options) {
          return new PushNotification(options);
      }              
                 
  };



});
