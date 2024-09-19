// 'mysql2' 패키지를 사용하여 RDS(MySQL)에 연결
const mysql = require('mysql2/promise');

// Lambda 함수 핸들러
exports.handler = async (event) => {
    // 환경 변수에서 RDS 접속 정보 불러오기
    const RDS_HOST = process.env.RDS_ENDPOINT;
    const RDS_USER = process.env.RDS_USERNAME;
    const RDS_PASSWORD = process.env.RDS_PASSWORD;
    const RDS_DATABASE = process.env.RDS_DB_NAME;

    // 트리거 소스 확인 (PreSignUp, PostConfirmation, PreAuthentication, PostAuthentication 등)
    const triggerSource = event.triggerSource;

    // 사용자 속성 초기화
    let email = null;
    let sub = null;

    // Cognito 트리거에 따라 필요한 userAttributes 처리
    switch (triggerSource) {
        case 'PreSignUp_SignUp':
            // PreSignUp 단계에서는 sub가 아직 없음, email만 처리
            email = event.request.userAttributes.email || null;
            console.log("PreSignUp: email:", email);
            // PreSignUp 트리거의 기대 응답
            event.response.autoConfirmUser = true; // 자동으로 사용자 확인
            break;

        case 'PreSignUp_AdminCreateUser':
            // 관리자가 사용자를 생성할 때 발생하는 트리거
            email = event.request.userAttributes.email || null;
            console.log("PreSignUp_AdminCreateUser: email:", email);
            // PreSignUp_AdminCreateUser 트리거의 기대 응답
            event.response.autoConfirmUser = true; // 자동으로 사용자 확인
            break;

        case 'PostConfirmation_ConfirmSignUp':
            // PostConfirmation 단계에서는 sub와 email 모두 존재함
            email = event.request.userAttributes.email || null;
            sub = event.request.userAttributes.sub || null;
            console.log("PostConfirmation: email:", email, "sub:", sub);
            break;

        case 'PreAuthentication_Authentication':
            // PreAuthentication 단계에서는 기본적으로 sub가 필요
            sub = event.request.userAttributes.sub || null;
            console.log("PreAuthentication: sub:", sub);
            break;

        case 'PostAuthentication_Authentication':
            // PostAuthentication 단계에서는 인증 후 sub가 존재함
            sub = event.request.userAttributes.sub || null;
            console.log("PostAuthentication: sub:", sub);
            break;

        default:
            console.error("Unhandled trigger source:", triggerSource);
            throw new Error(`Trigger source ${triggerSource} not handled.`);
    }

    // PreSignUp 단계에서는 데이터베이스에 저장할 필요 없음
    if (triggerSource === 'PreSignUp_SignUp' || triggerSource === 'PreSignUp_AdminCreateUser') {
        // PreSignUp에서 사용자를 데이터베이스에 저장하지 않고 응답을 Cognito에 반환
        return event; // Cognito가 예상하는 응답 형식으로 event를 반환
    }

    // MySQL 연결 설정 (PostConfirmation, PreAuthentication 및 PostAuthentication에서만 필요)
    let connection;
    try {
        if (sub && email) {
            // MySQL 연결 생성
            connection = await mysql.createConnection({
                host: RDS_HOST,
                user: RDS_USER,
                password: RDS_PASSWORD,
                database: RDS_DATABASE
            });

            // 사용자 정보를 RDS에 저장하는 SQL 쿼리
            const insertUserQuery = `
                INSERT INTO users (user_id, email)
                VALUES (?, ?)
            `;

            // SQL 쿼리 실행
            await connection.execute(insertUserQuery, [sub, email]);

            console.log(`User with email: ${email} has been added to the database.`);
        } else if (sub) {
            // PostAuthentication 단계에서는 email이 필요하지 않을 수 있음
            console.log(`User with sub: ${sub} authenticated.`);
        } else {
            console.error("Missing user attributes (sub or email).");
            throw new Error("User attributes (sub or email) are missing.");
        }
    } catch (error) {
        console.error("Error connecting to RDS or executing query: ", error);
        throw new Error("Failed to insert user into database.");
    } finally {
        // 연결 종료
        if (connection) {
            await connection.end();
        }
    }

    // Lambda 함수가 정상적으로 실행되었음을 반환 (PostConfirmation, PreAuthentication, PostAuthentication)
    return event; // Cognito가 예상하는 응답 형식으로 event를 반환
};
