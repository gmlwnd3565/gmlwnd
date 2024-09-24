const https = require('https');

// 환경변수에서 Slack Webhook URL 가져오기
const ENV = process.env;
if (!ENV.SLACK_WEBHOOK_URL) throw new Error('Missing environment variable: SLACK_WEBHOOK_URL');
const webhook = ENV.SLACK_WEBHOOK_URL;

// 상태에 따른 Slack 메시지의 색상과 메시지
const statusColorsAndMessage = {
    ALARM: { "color": "danger", "message": "위험" },
    INSUFFICIENT_DATA: { "color": "warning", "message": "데이터 부족" },
    OK: { "color": "good", "message": "정상" }
};

// SQS 이벤트 처리 함수
exports.handler = async (event) => {
    console.log("Received SQS event:", JSON.stringify(event, null, 2));

    for (const record of event.Records) {
        try {
            // SQS 메시지의 body 추출 및 파싱
            const sqsMessage = JSON.parse(record.body);
            console.log("Parsed SQS message:", JSON.stringify(sqsMessage, null, 2));

            // SQS 메시지에서 필요한 정보 추출 (alarmName, NewStateValue, etc.)
            const parsedMessage = {
                AlarmName: sqsMessage.alarmName || "No Alarm Name",
                NewStateValue: sqsMessage.newState || "Unknown",
                OldStateValue: sqsMessage.oldState || "Unknown",
                StateChangeTime: sqsMessage.stateChangeTime || "Unknown",
                AlarmDescription: sqsMessage.description || "No Description",
                Trigger: sqsMessage.Trigger || {}
            };

            // Slack 메시지 생성
            const postData = exports.buildSlackMessage(parsedMessage);

            // Slack에 메시지 전송
            await exports.postSlack(postData, webhook);
            console.log('Slack message sent successfully');
        } catch (error) {
            console.error("Error processing SQS message:", error);
        }
    }
};

// SQS 메시지 데이터를 기반으로 Slack 메시지 생성
exports.buildSlackMessage = (data) => {
    const newState = statusColorsAndMessage[data.NewStateValue] || { color: "gray", message: "Unknown" };
    const oldState = statusColorsAndMessage[data.OldStateValue] || { color: "gray", message: "Unknown" };
    const executeTime = exports.toYyyymmddhhmmss(data.StateChangeTime);
    const description = data.AlarmDescription || "No Description";
    const cause = exports.getCause(data);

    const alarmName = data.AlarmName || "alarm";  // 기본값 설정

    return {
        attachments: [
            {
                title: `[${alarmName}]`,
                color: newState.color,
                fields: [
                    {
                        title: '상태 변경 시간',
                        value: executeTime
                    },
                    {
                        title: '알람 설명',
                        value: description
                    },
                    {
                        title: '알람 원인',
                        value: cause
                    },
                    {
                        title: '이전 상태',
                        value: oldState.message,
                        short: true
                    },
                    {
                        title: '현재 상태',
                        value: `*${newState.message}*`,
                        short: true
                    },
                    {
                        title: 'CloudWatch에서 확인',
                        value: exports.createLink(data)
                    }
                ],
                footer: !data.AlarmName ? "AlarmName 필드가 누락되었습니다" : ""
            }
        ]
    };
};

// CloudWatch 알람 바로 가기 링크 생성
exports.createLink = (data) => {
    return `https://console.aws.amazon.com/cloudwatch/home?region=${exports.exportRegionCode(data.AlarmArn)}#alarm:alarmFilter=ANY;name=${encodeURIComponent(data.AlarmName)}`;
};

exports.exportRegionCode = (arn) => {
    return arn.replace("arn:aws:cloudwatch:", "").split(":")[0];
};

// 알람의 원인 파악
exports.getCause = (data) => {
    const trigger = data.Trigger;
    const evaluationPeriods = trigger.EvaluationPeriods;
    const minutes = Math.floor(trigger.Period / 60);
    if (data.Trigger.Metrics) {
        return exports.buildAnomalyDetectionBand(data, evaluationPeriods, minutes);
    }
    return exports.buildThresholdMessage(data, evaluationPeriods, minutes);
};

// 이상 지표 중 Band를 벗어나는 경우
exports.buildAnomalyDetectionBand = (data, evaluationPeriods, minutes) => {
    const metrics = data.Trigger.Metrics;
    const metric = metrics.find(metric => metric.Id === 'm1').MetricStat.Metric.MetricName;
    const expression = metrics.find(metric => metric.Id === 'ad1').Expression;
    const width = expression.split(',')[1].replace(')', '').trim();
    return `${evaluationPeriods * minutes} 분 동안 ${evaluationPeriods} 회 ${metric} 지표가 범위(약 ${width}배)를 벗어났습니다.`;
};

// 이상 지표 중 Threshold 벗어나는 경우
exports.buildThresholdMessage = (data, evaluationPeriods, minutes) => {
    const trigger = data.Trigger;
    const threshold = trigger.Threshold;
    const metric = trigger.MetricName;
    const operator = comparisonOperator[trigger.ComparisonOperator];
    return `${evaluationPeriods * minutes} 분 동안 ${evaluationPeriods} 회 ${metric} ${operator} ${threshold}`;
};

// UTC 시간을 KST로 변환하는 함수
exports.toYyyymmddhhmmss = (timeString) => {
    if (!timeString) {
        return '';
    }
    const kstDate = new Date(new Date(timeString).getTime() + 32400000); // 9시간(한국 시간) 더함
    function pad2(n) { return n < 10 ? '0' + n : n }
    return kstDate.getFullYear().toString()
        + '-' + pad2(kstDate.getMonth() + 1)
        + '-' + pad2(kstDate.getDate())
        + ' ' + pad2(kstDate.getHours())
        + ':' + pad2(kstDate.getMinutes())
        + ':' + pad2(kstDate.getSeconds());
};

// Slack에 메시지를 POST로 전송하는 함수
exports.postSlack = async (message, slackUrl) => {
    return await request(exports.options(slackUrl), message);
};

exports.options = (slackUrl) => {
    const { host, pathname } = new URL(slackUrl);
    return {
        hostname: host,
        path: pathname,
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
    };
};

// HTTP 요청을 보내는 함수
function request(options, data) {
    return new Promise((resolve, reject) => {
        const req = https.request(options, (res) => {
            res.setEncoding('utf8');
            let responseBody = '';
            res.on('data', (chunk) => {
                responseBody += chunk;
            });
            res.on('end', () => {
                resolve(responseBody);
            });
        });

        req.on('error', (err) => {
            reject(err);
        });

        req.write(JSON.stringify(data));
        req.end();
    });
}
