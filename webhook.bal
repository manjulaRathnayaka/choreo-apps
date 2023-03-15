import ballerinax/trigger.asgardeo;
import ballerina/http;
import ballerina/log;
import wso2/choreo.sendsms;
import ballerinax/googleapis.gmail;

configurable asgardeo:ListenerConfig config = ?;

configurable string googleClientId = ?;
configurable string googleClientSecret = ?;
configurable string googleRefreshToken = ?;
configurable string senderEmail = ?;
configurable string receiverEmail = ?;

listener http:Listener httpListener = new(8090);
listener asgardeo:Listener webhookListener =  new(config,httpListener);

sendsms:Client sendSmsClient = check new ();

service asgardeo:NotificationService on webhookListener {
    
    remote function onSmsOtp(asgardeo:SmsOtpNotificationEvent event) returns error? {
      
      //logging the event.
      log:printInfo(event.toJsonString());

      //read required data from the event.
      asgardeo:SmsOtpNotificationData? eventData = event.eventData;
      string message = <string> check eventData.toJson().messageBody;

      log:printInfo(event.toJsonString());
        error? err = sendMail(receiverEmail, message);
        if (err is error) {
            log:printInfo(err.message());
        }
    } 
}

service /ignore on httpListener {}

function sendMail(string recipientEmail, string body) returns error? {
    gmail:ConnectionConfig gmailConfig = {
        auth: {
            refreshUrl: gmail:REFRESH_URL,
            refreshToken: googleRefreshToken,
            clientId: googleClientId,
            clientSecret: googleClientSecret
        }
    };
    gmail:Client gmailClient = check trap new (gmailConfig);
    string userId = "me";
    gmail:MessageRequest messageRequest = {
        recipient: recipientEmail,
        subject: "Here is your SMS OTP for login",
        messageBody: body,
        contentType: gmail:TEXT_HTML,
        sender: senderEmail
    };
    gmail:Message m = check gmailClient->sendMessage(messageRequest, userId = userId);
    log:printInfo(m.toJsonString());
}
