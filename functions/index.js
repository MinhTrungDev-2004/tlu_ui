/**
 * 🔍 Cloud Functions cho hệ thống Nhận diện khuôn mặt sinh viên
 * Môi trường: Node.js 22 + Firebase Functions v2
 * ✅ Đã tắt App Check để test dễ dàng
 */

const { onRequest, onCall } = require("firebase-functions/v2/https");
const { onObjectFinalized } = require("firebase-functions/v2/storage");
const { setGlobalOptions } = require("firebase-functions/v2");
const admin = require("firebase-admin");
const axios = require("axios");

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
// 🔹 Xử lý ảnh khuôn mặt sinh viên khi upload lên Storage
// =======================================================
exports.processStudentFace = onObjectFinalized(
    {
        memory: "512MB",
        timeoutSeconds: 120,
    },
    async (event) => {
        const filePath = event.data.name;
        const bucketName = event.data.bucket;

        // Bỏ qua nếu không phải thư mục student_faces/
        if (!filePath || !filePath.startsWith("student_faces/")) {
            console.log("⚠️ Không phải ảnh khuôn mặt sinh viên, bỏ qua...");
            return null;
        }

        try {
            console.log(`🔄 Đang xử lý ảnh: ${filePath}`);

            // 1️⃣ Chuẩn bị URL ảnh cho Google Vision API
            const imageUri = `gs://${bucketName}/${filePath}`;

            // 2️⃣ Gọi Google Vision API để phát hiện khuôn mặt
            const faceDetection = await detectFaces(imageUri);

            if (faceDetection.faces.length === 0)
                throw new Error("Không phát hiện khuôn mặt trong ảnh!");

            if (faceDetection.faces.length > 1)
                throw new Error("Phát hiện nhiều hơn 1 khuôn mặt — chỉ dùng ảnh 1 người!");

            const face = faceDetection.faces[0];

            // 3️⃣ Tạo vector đặc trưng (embedding)
            const embedding = createEmbeddingFromFace(face);

            // 4️⃣ Lấy studentId từ đường dẫn file
            const studentId = filePath.split("/")[1];
            if (!studentId) throw new Error("Không lấy được studentId từ đường dẫn!");

            // 5️⃣ Lưu vào Firestore
            await admin.firestore().collection("students").doc(studentId).set(
                {
                    studentId,
                    faceImageUrl: `https://storage.googleapis.com/${bucketName}/${encodeURIComponent(filePath)}`,
                    faceEmbedding: embedding,
                    faceBounds: face.bounds,
                    confidence: face.detectionConfidence,
                    landmarks: face.landmarks,
                    processedAt: admin.firestore.FieldValue.serverTimestamp(),
                    status: "registered",
                },
                { merge: true }
            );

            console.log(`✅ Đã lưu embedding cho sinh viên: ${studentId}`);

            return { success: true, studentId, embeddingLength: embedding.length };
        } catch (error) {
            console.error("❌ Lỗi khi xử lý ảnh:", error);

            const studentId = filePath.split("/")[1];
            if (studentId) {
                await admin.firestore().collection("processingErrors").add({
                    studentId,
                    filePath,
                    error: error.message,
                    timestamp: admin.firestore.FieldValue.serverTimestamp(),
                });
            }

            return { success: false, error: error.message };
        }
    }
);

// =======================================================
// 🔹 So sánh hai embedding khuôn mặt
// =======================================================
exports.compareFaces = onCall(
    {
        memory: "256MB",
        timeoutSeconds: 30,
        enforceAppCheck: false, // ⚠️ Tắt App Check để test
    },
    async (request) => {
        try {
            const { embedding1, embedding2 } = request.data;
            if (!embedding1 || !embedding2)
                throw new Error("Thiếu dữ liệu embedding để so sánh!");

            const similarity = calculateCosineSimilarity(embedding1, embedding2);

            return {
                success: true,
                similarity,
                isMatch: similarity > 0.6,
                matchPercentage: (similarity * 100).toFixed(1),
            };
        } catch (error) {
            console.error("❌ Lỗi khi so sánh khuôn mặt:", error);
            // Quan trọng: Phải ném ra lỗi để client Flutter bắt được mã lỗi
            throw new Error(error.message); 
        }
    }
);

// =======================================================
// 🔹 Trích xuất embedding từ URL ảnh (Vision API)
// =======================================================
exports.extractFaceEmbedding = onCall(
    {
        memory: "512MB",
        timeoutSeconds: 60,
        enforceAppCheck: false, // ⚠️ Tắt App Check để test
    },
    async (request) => {
        // Thay vì imageUrl, chúng ta nhận bucket và path từ client
        const { bucketName, filePath } = request.data;
        
        // Kiểm tra đầu vào mới
        if (!bucketName || !filePath) {
            throw new Error("Thiếu bucketName hoặc filePath!");
        }

        try {
            // KHÔNG cần tải ảnh bằng axios nữa
            
            // 1. Chuẩn bị URI nội bộ cho Vision API
            // Vision API có thể truy cập nội bộ Storage qua URI này
            const imageUri = `gs://${bucketName}/${filePath}`;
            console.log(`🔄 Trích xuất embedding từ URI nội bộ: ${imageUri}`);

            // 2. Gọi Vision API để nhận dạng
            const faceDetection = await detectFaces(imageUri);
            
            // 3. Xử lý kết quả Vision API
            if (faceDetection.faces.length === 0)
                throw new Error("Không phát hiện khuôn mặt trong ảnh!");

            const face = faceDetection.faces[0];
            const embedding = createEmbeddingFromFace(face);

            return {
                success: true,
                embedding,
                confidence: face.detectionConfidence,
                embeddingLength: embedding.length,
            };
        } catch (error) {
            console.error("❌ Lỗi khi trích xuất embedding:", error);
            // Quan trọng: Ném ra lỗi để client Flutter bắt được mã lỗi
            throw new Error(`Cloud Function Error: ${error.message}`);
        }
    }
);

// =======================================================
// 🔹 Hàm test đơn giản (HTTP endpoint)
// =======================================================
exports.helloWorld = onRequest(
    { enforceAppCheck: false }, // ⚠️ Tắt App Check để test nhanh
    (req, res) => {
        console.log("🌐 Hello logs!");
        res.json({
            message: "Hello từ Firebase Cloud Functions V2 (AppCheck OFF)!",
            timestamp: new Date().toISOString(),
            nodeVersion: process.version,
            status: "active",
        });
    }
);

// =======================================================
// 🔹 Các hàm phụ trợ (Helper Functions)
// =======================================================

// 🧠 Gọi Google Vision API để phát hiện khuôn mặt
async function detectFaces(imageUri) {
    try {
        // Đảm bảo module Vision đã được khai báo trong package.json
        const vision = require("@google-cloud/vision"); 
        const client = new vision.ImageAnnotatorClient();
        
        // Gọi API với URI nội bộ (gs://...)
        const [result] = await client.faceDetection(imageUri); 
        const faces = result.faceAnnotations || [];

        return {
            faces: faces.map((face) => {
                const vertices = face.boundingPoly.vertices || [];
                return {
                    detectionConfidence: face.detectionConfidence || 0,
                    bounds: {
                        x: vertices[0]?.x || 0,
                        y: vertices[0]?.y || 0,
                        width: (vertices[1]?.x || 0) - (vertices[0]?.x || 0),
                        height: (vertices[2]?.y || 0) - (vertices[1]?.y || 0),
                    },
                    landmarks: (face.landmarks || []).map((l) => ({
                        type: l.type || "UNKNOWN",
                        x: l.position?.x || 0,
                        y: l.position?.y || 0,
                        z: l.position?.z || 0,
                    })),
                };
            }),
        };
    } catch (error) {
        console.error("❌ Vision API error:", error);
        // Ném lỗi để được bắt ở hàm gọi
        throw new Error("Lỗi khi gọi Vision API: " + error.message);
    }
}

// 🧩 Tạo embedding từ đặc trưng khuôn mặt
function createEmbeddingFromFace(face) {
    const embedding = [];

    embedding.push((face.bounds.x || 0) / 1000);
    embedding.push((face.bounds.y || 0) / 1000);
    embedding.push((face.bounds.width || 0) / 1000);
    embedding.push((face.bounds.height || 0) / 1000);
    embedding.push(face.detectionConfidence || 0);

    const importantLandmarks = ["LEFT_EYE", "RIGHT_EYE", "NOSE_TIP", "MOUTH_LEFT", "MOUTH_RIGHT"];

    importantLandmarks.forEach((type) => {
        const landmark = (face.landmarks || []).find((l) => l.type === type);
        if (landmark) {
            embedding.push((landmark.x || 0) / 1000);
            embedding.push((landmark.y || 0) / 1000);
        } else {
            embedding.push(0, 0);
        }
    });

    console.log(`📊 Đã tạo embedding ${embedding.length} chiều`);
    return embedding;
}

// 🔢 Tính toán độ tương đồng Cosine
function calculateCosineSimilarity(vecA, vecB) {
    if (!vecA || !vecB || vecA.length !== vecB.length) return 0;

    let dot = 0,
        normA = 0,
        normB = 0;
    for (let i = 0; i < vecA.length; i++) {
        dot += vecA[i] * vecB[i];
        normA += vecA[i] ** 2;
        normB += vecB[i] ** 2;
    }

    const magnitude = Math.sqrt(normA) * Math.sqrt(normB);
    return magnitude > 0 ? dot / magnitude : 0;
}