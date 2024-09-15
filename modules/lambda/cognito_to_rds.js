// 'mysql2' 패키지를 사용하여 RDS(MySQL)에 연결
const mysql = require('mysql2/promise');

// Lambda 함수 핸들러
exports.handler = async (event) => {
    // 환경 변수에서 RDS 접속 정보 불러오기
    const RDS_HOST = process.env.RDS_ENDPOINT;
    const RDS_USER = process.env.RDS_USERNAME;
    const RDS_PASSWORD = process.env.RDS_PASSWORD;
    const RDS_DATABASE = process.env.RDS_DB_NAME;
    
    // Cognito 이벤트에서 사용자 정보 추출
    const userAttributes = event.request.userAttributes;
    const email = userAttributes.email;
    const sub = userAttributes.sub; // 사용자 고유 ID

    // MySQL 연결 설정
    let connection;
    try {
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

    } catch (error) {
        console.error("Error connecting to RDS or executing query: ", error);
        throw new Error("Failed to insert user into database.");
    } finally {
        // 연결 종료
        if (connection) {
            await connection.end();
        }
    }

    // Lambda 함수가 정상적으로 실행되었음을 반환
    return {
        statusCode: 200,
        body: JSON.stringify({
            message: "User successfully inserted into the database",
            user: {
                email: email,
                sub: sub
            }
        })
    };
};
