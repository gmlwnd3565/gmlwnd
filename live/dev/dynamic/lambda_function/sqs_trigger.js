JavaScript
const AWS = require('aws-sdk');

// SNS 클라이언트 생성
const sns = new AWS.SNS({ region: process.env.AWS_REGION || 'ap-northeast-1' });

exports.handler = async (event) => {
    // SQS에서 전달된 메시지 확인
    console.log("Received SQS event:", JSON.stringify(event, null, 2));

    // SQS 이벤트에서 메시지 추출
    const messageBody = JSON.parse(event.Records[0].body);

    // SMS로 전송할 전화번호 (국제 형식, 예: +821012345678)
    const phoneNumber = "+821012345678"; // 실제 전화번호로 변경

    // SMS 메시지 내용 구성 (필요한 정보에 따라 수정)
    const message = `WAF Alarm: ${messageBody.alarmName}\nLog Events: ${JSON.stringify(messageBody.logEvents)}`;

    // SNS를 통해 SMS를 전송
    const params = {
        Message: message,
        PhoneNumber: phoneNumber
    };

    try {
        const result = await sns.publish(params).promise();
        console.log("SMS sent successfully:", result);
        return {
            statusCode: 200,
            body: JSON.stringify({
                message: 'SMS sent successfully!',
                result: result
            })
        };
    } catch (error) {
        console.error("Error sending SMS:", error);
        return {
            statusCode: 500,
            body: JSON.stringify({
                message: 'Failed to send SMS',
                error: error.message
            })
        };
    }
};