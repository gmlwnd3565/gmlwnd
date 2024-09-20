const AWS = require('aws-sdk');
const axios = require('axios');

const sqs = new AWS.SQS();
const sns = new AWS.SNS({ region: process.env.AWS_REGION || 'ap-northeast-2' });

exports.handler = async (event) => {
    try {
        // SQS 큐에서 메시지 가져오기
        const queueUrl = process.env.SQS_QUEUE_URL;
        const params = {
            QueueUrl: queueUrl,
            MaxNumberOfMessages: 1,
            VisibilityTimeout: 30, 
        };
        const data = await sqs.receiveMessage(params).promise();

        // 메시지 존재 여부 확인
        if (!data.Messages || data.Messages.length === 0) {
            console.log('SQS에서 메시지를 받지 못했습니다.');
            return;
        }

        const message = data.Messages[0];
        const messageBody = JSON.parse(message.Body); 

        // Slack 알림 메시지 생성
        const slackMessage = {
            text: `새로운 데이터 수신: ${messageBody.data}`, 
        };

        // SNS 메시지 (Slack) 생성
        const slackSnsMessage = {
            default: JSON.stringify(slackMessage), 
        };

        // SNS 주제 (Slack)에 메시지 발행
        const slackTopicArn = process.env.SLACK_SNS_TOPIC_ARN; 
        await sns.publish({
            TopicArn: slackTopicArn,
            Message: JSON.stringify(slackSnsMessage),
            MessageStructure: 'json' 
        }).promise();

        // SQS 메시지 삭제
        const deleteParams = {
            QueueUrl: queueUrl,
            ReceiptHandle: message.ReceiptHandle,
        };
        await sqs.deleteMessage(deleteParams).promise();

        console.log('메시지 처리 완료 (Slack).');

    } catch (error) {
        console.error('메시지 처리 중 오류 발생:', error);
    }
};