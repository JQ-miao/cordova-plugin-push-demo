cordova.define('cordova/plugin_list', function(require, exports, module) {
module.exports = [
    {
        "id": "cordova-plugin-push.PushNotification",
        "file": "plugins/cordova-plugin-push/www/push.js",
        "pluginId": "cordova-plugin-push",
        "clobbers": [
            "PushNotification"
        ]
    }
];
module.exports.metadata = 
// TOP OF METADATA
{
    "cordova-plugin-whitelist": "1.3.1",
    "cordova-plugin-push": "0.0.1"
};
// BOTTOM OF METADATA
});