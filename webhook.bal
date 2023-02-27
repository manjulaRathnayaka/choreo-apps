
import wso2/choreo.sendsms;
import ballerinax/trigger.asgardeo;
import ballerina/http;
import ballerina/log;

configurable asgardeo:ListenerConfig config = ?;

listener http:Listener httpListener = new(8090);
listener asgardeo:Listener webhookListener =  new(config,httpListener);

service asgardeo:NotificationService on webhookListener {
  
    remote function onSmsOtp(asgardeo:SmsOtpNotificationEvent event ) returns error? {
        
        //logging the event.
        log:printInfo(event.toJsonString());

        //read data from the event.
        asgardeo:SmsOtpNotificationData? eventData = event.eventData;
        string toNumber = <string> check eventData.toJson().sendTo;
        string message = <string> check eventData.toJson().messageBody;

        //Configure twilio account.
        sendsms:Client sendSmsClient = check new ();

        string response = check sendSmsClient -> sendSms(toNumber, message);

        log:printInfo(response);
    }
}

service /ignore on httpListener {}