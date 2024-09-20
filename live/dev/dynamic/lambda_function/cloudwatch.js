const AWS = require('aws-sdk');

// SQS 및 SNS 클라이언트 생성
const sqs = new AWS.SQS({ region: 'ap-northeast-1' });

exports.handler = async (event) => {
    // CloudWatch 경보 이벤트 확인
    console.log("Received CloudWatch Alarm event:", JSON.stringify(event, null, 2));

    // CloudWatch 이벤트에서 WAF 정보 추출 (필요한 정보에 따라 수정)
    const alarmName = event.detail.alarmName;
    const logEvents = event.detail.state.reasonData.recentDatapoints; // 로그 이벤트 데이터 (CloudWatch Logs Insights 쿼리 결과 등)

    // SQS Queue URL (환경 변수로 설정하는 것을 권장)
    const queueUrl = process.env.SQS_QUEUE_URL;

    // SQS에 보낼 메시지 설정
    const params = {
        QueueUrl: queueUrl,
        MessageBody: JSON.stringify({
            alarmName: alarmName,
            logEvents: logEvents // 필요한 정보만 포함하도록 수정 가능
        })
    };

    try {
        // SQS로 메시지 전송
        const result = await sqs.sendMessage(params).promise();
        console.log("SQS 메시지 전송 완료:", result.MessageId);
        return { statusCode: 200, body: "SQS 메시지 전송 완료" };
    } catch (error) {
        console.error("SQS 전송 중 오류 발생:", error);
        return { 
            statusCode: 500, 
            body: JSON.stringify({
                error: 'SQS 메시지 전송 중 오류가 발생했습니다.',
                details: error.message
            })
        };
    }
};