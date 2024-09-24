const AWS = require('aws-sdk');

// SQS 클라이언트 생성
const sqs = new AWS.SQS({ region: 'ap-northeast-2' });

exports.handler = async (event) => {
    console.log("Received CloudWatch Alarm event:", JSON.stringify(event, null, 2));

    try {
        // CloudWatch 경보 데이터를 처리
        const alarmName = event.AlarmName || "알람 이름 없음";

        // SQS에 전송할 메시지 구성 (alarmName만 포함)
        const sqsMessage = {
            alarmName: alarmName
        };

        // SQS Queue URL (환경 변수로 설정하는 것을 권장)
        const queueUrl = process.env.SQS_ENV;

        // SQS에 보낼 메시지 설정
        const params = {
            QueueUrl: queueUrl,
            MessageBody: JSON.stringify(sqsMessage)
        };

        // SQS로 메시지 전송
        const result = await sqs.sendMessage(params).promise();
        console.log("SQS 메시지 전송 완료:", result.MessageId);

        return { statusCode: 200, body: "SQS 메시지 처리 완료" };
    } catch (error) {
        console.error("CloudWatch 경보 처리 중 오류 발생:", error);
        return {
            statusCode: 500,
            body: JSON.stringify({
                error: 'CloudWatch 경보 처리 중 오류가 발생했습니다.',
                details: error.message
            })
        };
    }
};
