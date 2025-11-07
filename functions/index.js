/**
 * 🔍 Cloud Functions cho hệ thống Nhận diện khuôn mặt sinh viên
 * ✅ Đã đồng bộ hoá với Flutter Models
 */

const { onRequest, onCall } = require("firebase-functions/v2/https");
const { onObjectFinalized } = require("firebase-functions/v2/storage");
const { setGlobalOptions } = require("firebase-functions/v2");
const admin = require("firebase-admin");

// ✅ Khởi tạo Firebase Admin SDK
admin.initializeApp();

// ✅ Cấu hình mặc định cho toàn bộ Function
setGlobalOptions({
    region: "us-central1",
    maxInstances: 10,
    timeoutSeconds: 60,
    memory: "256MB",
});

// =======================================================
// 🔹 Constants - Đồng bộ với Flutter Models
// =======================================================
const COLLECTIONS = {
    USERS: 'users',
    FACE_DATA: 'face_data',
    ATTENDANCE: 'attendances',
    SESSIONS: 'sessions',
    CLASSES: 'classes',
    COURSES: 'courses',
    PROCESSING_ERRORS: 'processing_errors'
};

// =======================================================
// 🔹 FUNCTION MỚI: Xử lý ảnh khuôn mặt
// =======================================================
exports.processFaceImage = onObjectFinalized(
    {
        memory: "512MB",
        timeoutSeconds: 120,
    },
    async (event) => {
        const filePath = event.data.name;
        const bucketName = event.data.bucket;

        if (!filePath || !filePath.startsWith("face_images/")) {
            console.log("⚠️ Không phải ảnh khuôn mặt, bỏ qua...");
            return null;
        }

        try {
            console.log(`🔄 Đang xử lý ảnh: ${filePath}`);
            // ... implementation của bạn ...
            return { success: true, filePath };
        } catch (error) {
            console.error("❌ Lỗi:", error);
            return { success: false, error: error.message };
        }
    }
);

// =======================================================
// 🔹 FUNCTION MỚI: So sánh khuôn mặt
// =======================================================
exports.compareFaces = onCall(
    {
        memory: "256MB",
        timeoutSeconds: 30,
        enforceAppCheck: false,
    },
    async (request) => {
        try {
            const { embedding1, embedding2 } = request.data;
            const similarity = calculateCosineSimilarity(embedding1, embedding2);
            
            return {
                success: true,
                similarity: Number(similarity.toFixed(4)),
                isMatch: similarity > 0.6,
            };
        } catch (error) {
            throw new Error(`Lỗi so sánh: ${error.message}`);
        }
    }
);

// =======================================================
// 🔹 FUNCTION MỚI: Trích xuất embedding
// =======================================================
exports.extractFaceEmbedding = onCall(
    {
        memory: "512MB",
        timeoutSeconds: 60,
        enforceAppCheck: false,
    },
    async (request) => {
        try {
            const { bucketName, filePath } = request.data;
            // ... implementation của bạn ...
            return { success: true, embedding: [0.1, 0.2, 0.3] };
        } catch (error) {
            throw new Error(`Lỗi trích xuất: ${error.message}`);
        }
    }
);

// =======================================================
// 🔹 FUNCTION MỚI: Điểm danh nhận diện khuôn mặt
// =======================================================
exports.faceRecognitionAttendance = onCall(
    {
        memory: "512MB",
        timeoutSeconds: 60,
        enforceAppCheck: false,
    },
    async (request) => {
        try {
            const { sessionId, studentId, capturedEmbedding } = request.data;
            // ... implementation của bạn ...
            return { success: true, isMatch: true, confidence: 0.85 };
        } catch (error) {
            throw new Error(`Lỗi điểm danh: ${error.message}`);
        }
    }
);

// =======================================================
// 🔹 FUNCTION MỚI: Health check
// =======================================================
exports.healthCheck = onRequest(
    { enforceAppCheck: false },
    async (req, res) => {
        res.json({
            status: "healthy",
            service: "Face Recognition API",
            timestamp: new Date().toISOString(),
        });
    }
);

// =======================================================
// 🔹 FUNCTION CŨ: Giữ lại để tránh lỗi
// =======================================================
exports.helloWorld = onRequest(
    { enforceAppCheck: false },
    (req, res) => {
        res.json({
            message: "Hello từ Firebase Cloud Functions!",
            timestamp: new Date().toISOString(),
            status: "active",
        });
    }
);

// =======================================================
// 🔹 FUNCTION CŨ: Giữ lại để tránh lỗi
// =======================================================
exports.processStudentFace = onObjectFinalized(
    {
        memory: "512MB",
        timeoutSeconds: 120,
    },
    async (event) => {
        console.log("⚠️ Function processStudentFace cũ được gọi");
        return { 
            success: false, 
            message: "Function này đã được thay thế bằng processFaceImage",
            newFunction: "processFaceImage"
        };
    }
);

// =======================================================
// 🔹 Helper Functions
// =======================================================
function calculateCosineSimilarity(vecA, vecB) {
    if (!vecA || !vecB || vecA.length !== vecB.length) return 0;
    let dot = 0, normA = 0, normB = 0;
    for (let i = 0; i < vecA.length; i++) {
        dot += vecA[i] * vecB[i];
        normA += vecA[i] ** 2;
        normB += vecB[i] ** 2;
    }
    return normA > 0 && normB > 0 ? dot / (Math.sqrt(normA) * Math.sqrt(normB)) : 0;
}