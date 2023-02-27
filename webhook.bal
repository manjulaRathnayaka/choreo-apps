import ballerinax/trigger.asgardeo;
import ballerina/http;

configurable asgardeo:ListenerConfig config = ?;

listener http:Listener httpListener = new(8090);
listener asgardeo:Listener webhookListener =  new(config,httpListener);

service asgardeo:NotificationService on webhookListener {
  
    remote function onSmsOtp(asgardeo:SmsOtpNotificationEvent event ) returns error? {
      //Not Implemented
    }
}

service /ignore on httpListener {}