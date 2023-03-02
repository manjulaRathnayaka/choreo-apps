import ballerinax/trigger.asgardeo;
import ballerina/http;
import ballerina/log;
import wso2/choreo.sendsms;

configurable asgardeo:ListenerConfig config = ?;

listener http:Listener httpListener = new(8090);
listener asgardeo:Listener webhookListener =  new(config,httpListener);

sendsms:Client sendSmsClient = check new ();

service asgardeo:NotificationService on webhookListener {
    
    remote function onSmsOtp(asgardeo:SmsOtpNotificationEvent event) returns error? {
      
      //logging the event.
      log:printInfo(event.toJsonString());

      //read required data from the event.
      asgardeo:SmsOtpNotificationData? eventData = event.eventData;
      string toNumber = <string> check eventData.toJson().sendTo;
      string message = <string> check eventData.toJson().messageBody;

      string response = check sendSmsClient -> sendSms(toNumber, message);
      log:printInfo(response);
    } 
}

service /ignore on httpListener {}
