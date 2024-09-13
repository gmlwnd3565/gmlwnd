const AWS = require('aws-sdk');

// Initialize the SNS service
const sns = new AWS.SNS('ap-northeast-1');

exports.handler = async (event) => {
    // SQS에서 전달된 메시지 확인
    console.log("Received SQS event:", JSON.stringify(event, null, 2));

    // SQS 이벤트에서 메시지 추출
    const messageBody = event.Records[0].body;

    // SMS로 전송할 전화번호 (국제 형식, 예: +821012345678)
    const phoneNumber = '+821051097148';  // 한국 전화번호 예시

    // SNS를 통해 SMS를 전송
    const params = {
        Message: messageBody,  // 메시지 본문
        PhoneNumber: phoneNumber,  // 전송할 전화번호
    };

    try {
        // SNS Publish를 이용해 SMS 전송
        const result = await sns.publish(params).promise();
        console.log("SMS sent successfully:", result);
        return {
            statusCode: 200,
            body: JSON.stringify({
                message: 'SMS sent successfully!',
                result: result
            }),
        };
    } catch (error) {
        console.error("Error sending SMS:", error);
        return {
            statusCode: 500,
            body: JSON.stringify({
                message: 'Failed to send SMS',
                error: error.message
            }),
        };
    }
};