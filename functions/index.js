/**
 * Cloud Functions for Student Face Recognition - Node.js 22 + Functions v2
 * Enhanced Version with Better Face Embeddings
 */

const {onRequest, onCall} = require("firebase-functions/v2/https");
const {onObjectFinalized} = require("firebase-functions/v2/storage");
const {setGlobalOptions} = require("firebase-functions/v2");
const admin = require("firebase-admin");

// Initialize Firebase Admin
admin.initializeApp();

// Set global options for Cloud Functions v2
setGlobalOptions({
  region: "us-central1",
  maxInstances: 10,
  timeoutSeconds: 60,
  memory: "256MB",
});

// ============================================================
// 🔧 TURN OFF App Check for all Cloud Functions
// ============================================================
process.env.FIREBASE_APPCHECK_DEBUG_TOKEN = true;

// ============================================================
// 🔥 STORAGE TRIGGER - Process uploaded student face images
// ============================================================
exports.processStudentFace = onObjectFinalized(
  {
    memory: "512MB",
    timeoutSeconds: 120,
    enforceAppCheck: false, // ✅ disable App Check
  },
  async (event) => {
    const filePath = event.data.name;
    const bucketName = event.data.bucket;

    if (!filePath || !filePath.startsWith("student_faces/")) {
      console.log("Not a student face image, skipping...");
      return null;
    }

    try {
      console.log(`🔄 Processing face image: ${filePath}`);

      const imageUri = `gs://${bucketName}/${filePath}`;
      const faceDetection = await detectFaces(imageUri);

      if (faceDetection.faces.length === 0) {
        throw new Error("No face detected in the image");
      }

      if (faceDetection.faces.length > 1) {
        throw new Error("Multiple faces detected - please use single face image");
      }

      const face = faceDetection.faces[0];
      const embedding = createEnhancedEmbeddingFromFace(face);

      const pathParts = filePath.split("/");
      const studentId = pathParts[1];

      if (!studentId) {
        throw new Error("Could not extract studentId from file path");
      }

      await admin.firestore().collection("students").doc(studentId).set({
        studentId: studentId,
        faceImageUrl: `https://storage.googleapis.com/${bucketName}/${encodeURIComponent(filePath)}`,
        faceEmbedding: embedding,
        faceBounds: face.bounds,
        confidence: face.detectionConfidence,
        landmarks: face.landmarks,
        embeddingVersion: "v2-enhanced",
        embeddingDimensions: embedding.length,
        processedAt: admin.firestore.FieldValue.serverTimestamp(),
        status: "registered",
      }, { merge: true });

      console.log(`✅ Enhanced face embedding (${embedding.length}D) saved for student: ${studentId}`);

      return {
        success: true,
        studentId: studentId,
        embeddingLength: embedding.length,
        embeddingVersion: "v2-enhanced",
      };
    } catch (error) {
      console.error("❌ Error processing face:", error);

      const pathParts = filePath.split("/");
      const studentId = pathParts[1];

      if (studentId) {
        await admin.firestore().collection("processingErrors").add({
          studentId: studentId,
          filePath: filePath,
          error: error.message,
          timestamp: admin.firestore.FieldValue.serverTimestamp(),
        });
      }

      return {
        success: false,
        error: error.message,
      };
    }
  }
);

// ============================================================
// 🔥 Callable function - Compare two face embeddings
// ============================================================
exports.compareFaces = onCall(
  {
    memory: "256MB",
    timeoutSeconds: 30,
    enforceAppCheck: false, // ✅ disable App Check
  },
  async (request) => {
    try {
      const {embedding1, embedding2} = request.data;

      if (!embedding1 || !embedding2) {
        throw new Error("Both embeddings are required");
      }

      const similarityResult = calculateEnhancedSimilarity(embedding1, embedding2);

      return {
        success: true,
        similarity: similarityResult.similarity,
        isMatch: similarityResult.isMatch,
        matchPercentage: similarityResult.matchPercentage,
        thresholdUsed: similarityResult.thresholdUsed,
        confidenceLevel: similarityResult.confidenceLevel,
      };
    } catch (error) {
      console.error("Error comparing faces:", error);
      throw new Error(error.message);
    }
  }
);

// ============================================================
// 🔥 Callable function - Extract face embedding from an image URL
// ============================================================
exports.extractFaceEmbedding = onCall(
  {
    memory: "512MB",
    timeoutSeconds: 60,
    enforceAppCheck: false, // ✅ disable App Check
  },
  async (request) => {
    try {
      const {imageUrl} = request.data;

      if (!imageUrl) {
        throw new Error("imageUrl is required");
      }

      const tempFileName = `temp/${Date.now()}_${Math.random().toString(36).substring(7)}.jpg`;

      const axios = require("axios");
      const response = await axios.get(imageUrl, {responseType: "arraybuffer"});

      const bucket = admin.storage().bucket();
      const file = bucket.file(tempFileName);
      await file.save(Buffer.from(response.data), {
        metadata: {contentType: "image/jpeg"},
      });

      const imageUri = `gs://${bucket.name}/${tempFileName}`;
      const faceDetection = await detectFaces(imageUri);

      await file.delete();

      if (faceDetection.faces.length === 0) {
        throw new Error("No face detected in the image");
      }

      if (faceDetection.faces.length > 1) {
        throw new Error("Multiple faces detected - please use single face image");
      }

      const face = faceDetection.faces[0];
      const embedding = createEnhancedEmbeddingFromFace(face);

      return {
        success: true,
        embedding: embedding,
        confidence: face.detectionConfidence,
        embeddingLength: embedding.length,
        embeddingVersion: "v2-enhanced",
        faceBounds: face.bounds,
      };
    } catch (error) {
      console.error("Error extracting embedding:", error);
      throw new Error(error.message);
    }
  }
);

// ============================================================
// 🔥 Callable function - Find student by face embedding
// ============================================================
exports.findStudentByFace = onCall(
  {
    memory: "512MB",
    timeoutSeconds: 30,
    enforceAppCheck: false, // ✅ disable App Check
  },
  async (request) => {
    try {
      const {embedding, threshold = 0.75} = request.data;

      if (!embedding) {
        throw new Error("Face embedding is required");
      }

      const studentsSnapshot = await admin.firestore()
        .collection("students")
        .where("status", "==", "registered")
        .get();

      if (studentsSnapshot.empty) {
        return {
          success: true,
          matches: [],
          message: "No registered students found"
        };
      }

      const matches = [];
      
      for (const doc of studentsSnapshot.docs) {
        const studentData = doc.data();
        const studentEmbedding = studentData.faceEmbedding;
        
        if (studentEmbedding && studentEmbedding.length === embedding.length) {
          const similarityResult = calculateEnhancedSimilarity(embedding, studentEmbedding);
          
          if (similarityResult.similarity >= threshold) {
            matches.push({
              studentId: studentData.studentId,
              similarity: similarityResult.similarity,
              matchPercentage: similarityResult.matchPercentage,
              confidence: similarityResult.confidenceLevel,
              faceImageUrl: studentData.faceImageUrl,
            });
          }
        }
      }

      // Sort by similarity score (descending)
      matches.sort((a, b) => b.similarity - a.similarity);

      return {
        success: true,
        matches: matches,
        totalMatches: matches.length,
        bestMatch: matches.length > 0 ? matches[0] : null,
        thresholdUsed: threshold,
      };
    } catch (error) {
      console.error("Error finding student by face:", error);
      throw new Error(error.message);
    }
  }
);

// ============================================================
// 🌐 HTTP function - For testing server health
// ============================================================
exports.helloWorld = onRequest(
  {
    enforceAppCheck: false, // ✅ disable App Check
  },
  (req, res) => {
    console.log("Hello logs!");
    res.json({
      message: "Hello from Firebase Cloud Functions V2!",
      timestamp: new Date().toISOString(),
      status: "active",
      nodeVersion: process.version,
      features: {
        faceRecognition: true,
        enhancedEmbeddings: true,
        appCheckDisabled: true
      }
    });
  }
);

// ============================================================
// 🌐 HTTP function - Get function statistics
// ============================================================
exports.getStats = onRequest(
  {
    enforceAppCheck: false,
  },
  async (req, res) => {
    try {
      const studentsSnapshot = await admin.firestore()
        .collection("students")
        .where("status", "==", "registered")
        .get();

      const errorsSnapshot = await admin.firestore()
        .collection("processingErrors")
        .orderBy("timestamp", "desc")
        .limit(10)
        .get();

      const stats = {
        totalStudents: studentsSnapshot.size,
        embeddingDimensions: studentsSnapshot.size > 0 ? 
          studentsSnapshot.docs[0].data().faceEmbedding?.length || 0 : 0,
        recentErrors: errorsSnapshot.size,
        lastErrors: errorsSnapshot.docs.map(doc => doc.data()),
      };

      res.json({
        success: true,
        stats: stats,
        timestamp: new Date().toISOString(),
      });
    } catch (error) {
      console.error("Error getting stats:", error);
      res.status(500).json({
        success: false,
        error: error.message,
      });
    }
  }
);

// ============================================================
// 🧩 ENHANCED HELPER FUNCTIONS
// ============================================================

// Google Vision API - Detect faces
async function detectFaces(imageUri) {
  try {
    const vision = require("@google-cloud/vision");
    const client = new vision.ImageAnnotatorClient();
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
          landmarks: (face.landmarks || []).map((landmark) => ({
            type: landmark.type || "UNKNOWN_LANDMARK",
            x: landmark.position?.x || 0,
            y: landmark.position?.y || 0,
            z: landmark.position?.z || 0,
          })),
          // Additional face features
          joy: face.joyLikelihood,
          sorrow: face.sorrowLikelihood,
          anger: face.angerLikelihood,
          surprise: face.surpriseLikelihood,
          underExposed: face.underExposedLikelihood,
          blurred: face.blurredLikelihood,
          headwear: face.headwearLikelihood,
        };
      }),
    };
  } catch (error) {
    console.error("Vision API error:", error);
    throw new Error("Face detection failed: " + error.message);
  }
}

// Create ENHANCED embedding vector from face landmarks (45-50 dimensions)
function createEnhancedEmbeddingFromFace(face) {
  const embedding = [];

  // 1. Basic face bounds and confidence (5 dimensions)
  embedding.push(normalizeValue(face.bounds.x, 0, 2000));
  embedding.push(normalizeValue(face.bounds.y, 0, 2000));
  embedding.push(normalizeValue(face.bounds.width, 0, 1000));
  embedding.push(normalizeValue(face.bounds.height, 0, 1000));
  embedding.push(face.detectionConfidence || 0);

  // 2. Comprehensive facial landmarks (30+ dimensions)
  const importantLandmarks = [
    "LEFT_EYE", "RIGHT_EYE", 
    "LEFT_EYE_TOP_BOUNDARY", "LEFT_EYE_RIGHT_CORNER", "LEFT_EYE_BOTTOM_BOUNDARY", "LEFT_EYE_LEFT_CORNER",
    "RIGHT_EYE_TOP_BOUNDARY", "RIGHT_EYE_RIGHT_CORNER", "RIGHT_EYE_BOTTOM_BOUNDARY", "RIGHT_EYE_LEFT_CORNER",
    "LEFT_EYEBROW_UPPER_MIDPOINT", "RIGHT_EYEBROW_UPPER_MIDPOINT",
    "NOSE_TIP", "NOSE_BOTTOM_RIGHT", "NOSE_BOTTOM_LEFT", "NOSE_BOTTOM_CENTER",
    "UPPER_LIP", "LOWER_LIP", "MOUTH_LEFT", "MOUTH_RIGHT", "MOUTH_CENTER",
    "LEFT_EAR_TRAGION", "RIGHT_EAR_TRAGION",
    "FOREHEAD_GLABELLA", "CHIN_GNATHION", "LEFT_CHEEK_CENTER", "RIGHT_CHEEK_CENTER"
  ];

  importantLandmarks.forEach((landmarkType) => {
    const landmark = (face.landmarks || []).find((l) => l.type === landmarkType);
    if (landmark) {
      embedding.push(normalizeValue(landmark.x, 0, 2000));
      embedding.push(normalizeValue(landmark.y, 0, 2000));
      embedding.push(normalizeValue(landmark.z || 0, -1000, 1000));
    } else {
      embedding.push(0, 0, 0); // Padding for missing landmarks
    }
  });

  // 3. Face proportions and geometric features (8 dimensions)
  if (face.landmarks && face.landmarks.length >= 3) {
    const leftEye = face.landmarks.find((l) => l.type === "LEFT_EYE");
    const rightEye = face.landmarks.find((l) => l.type === "RIGHT_EYE");
    const nose = face.landmarks.find((l) => l.type === "NOSE_TIP");
    const mouth = face.landmarks.find((l) => l.type === "MOUTH_CENTER");

    if (leftEye && rightEye) {
      // Eye distance ratio
      const eyeDistance = calculateDistance(leftEye, rightEye);
      const eyeDistanceRatio = eyeDistance / face.bounds.width;
      embedding.push(normalizeValue(eyeDistanceRatio, 0.1, 0.8));

      // Eye level symmetry
      const eyeLevelDiff = Math.abs(leftEye.y - rightEye.y) / face.bounds.height;
      embedding.push(normalizeValue(eyeLevelDiff, 0, 0.2));
    }

    if (nose && leftEye && rightEye) {
      // Nose position relative to eyes
      const eyeCenterX = ((leftEye.x + rightEye.x) / 2);
      const eyeCenterY = ((leftEye.y + rightEye.y) / 2);
      
      const noseOffsetX = Math.abs(nose.x - eyeCenterX) / face.bounds.width;
      const noseOffsetY = (nose.y - eyeCenterY) / face.bounds.height;
      
      embedding.push(normalizeValue(noseOffsetX, 0, 0.3));
      embedding.push(normalizeValue(noseOffsetY, 0.1, 0.5));
    }

    if (mouth && nose) {
      // Mouth-nose distance ratio
      const mouthNoseDistance = calculateDistance(mouth, nose);
      const mouthNoseRatio = mouthNoseDistance / face.bounds.height;
      embedding.push(normalizeValue(mouthNoseRatio, 0.1, 0.4));
    }

    // Face aspect ratio
    const faceAspectRatio = face.bounds.width / face.bounds.height;
    embedding.push(normalizeValue(faceAspectRatio, 0.5, 1.5));

    // Face area (normalized)
    const faceArea = (face.bounds.width * face.bounds.height) / 1000000; // Normalize
    embedding.push(normalizeValue(faceArea, 0.01, 0.5));
  } else {
    // Padding if not enough landmarks
    embedding.push(0, 0, 0, 0, 0, 0, 0, 0);
  }

  // 4. Emotional and quality features (6 dimensions)
  embedding.push(emotionalLikelihoodToNumber(face.joy));
  embedding.push(emotionalLikelihoodToNumber(face.sorrow));
  embedding.push(emotionalLikelihoodToNumber(face.anger));
  embedding.push(emotionalLikelihoodToNumber(face.surprise));
  embedding.push(qualityLikelihoodToNumber(face.blurred));
  embedding.push(qualityLikelihoodToNumber(face.underExposed));

  console.log(`🎯 Created ENHANCED embedding with ${embedding.length} dimensions`);
  return embedding;
}

// Enhanced similarity calculation with confidence levels
function calculateEnhancedSimilarity(vecA, vecB) {
  if (!vecA || !vecB || vecA.length !== vecB.length) {
    return {
      similarity: 0,
      isMatch: false,
      matchPercentage: "0.0",
      thresholdUsed: 0.75,
      confidenceLevel: "very_low"
    };
  }

  let dotProduct = 0;
  let normA = 0;
  let normB = 0;

  for (let i = 0; i < vecA.length; i++) {
    dotProduct += vecA[i] * vecB[i];
    normA += vecA[i] * vecA[i];
    normB += vecB[i] * vecB[i];
  }

  const magnitude = Math.sqrt(normA) * Math.sqrt(normB);
  const similarity = magnitude > 0 ? dotProduct / magnitude : 0;
  
  // Dynamic threshold based on embedding complexity
  const adjustedThreshold = vecA.length > 30 ? 0.75 : 0.6;
  const isMatch = similarity >= adjustedThreshold;
  
  // Confidence level based on similarity score
  let confidenceLevel = "low";
  if (similarity >= 0.85) confidenceLevel = "very_high";
  else if (similarity >= 0.75) confidenceLevel = "high";
  else if (similarity >= 0.65) confidenceLevel = "medium";
  else if (similarity >= 0.5) confidenceLevel = "low";
  else confidenceLevel = "very_low";

  return {
    similarity: similarity,
    isMatch: isMatch,
    matchPercentage: (similarity * 100).toFixed(1),
    thresholdUsed: adjustedThreshold,
    confidenceLevel: confidenceLevel
  };
}

// ============================================================
// 🧮 UTILITY FUNCTIONS
// ============================================================

function normalizeValue(value, min, max) {
  return Math.max(0, Math.min(1, (value - min) / (max - min)));
}

function calculateDistance(point1, point2) {
  return Math.sqrt(
    Math.pow(point2.x - point1.x, 2) + 
    Math.pow(point2.y - point1.y, 2)
  );
}

function emotionalLikelihoodToNumber(likelihood) {
  const mapping = {
    "VERY_LIKELY": 0.9,
    "LIKELY": 0.7,
    "POSSIBLE": 0.4,
    "UNLIKELY": 0.1,
    "VERY_UNLIKELY": 0.0,
  };
  return mapping[likelihood] || 0.0;
}

function qualityLikelihoodToNumber(likelihood) {
  const mapping = {
    "VERY_LIKELY": 0.1, // Lower score for bad quality
    "LIKELY": 0.3,
    "POSSIBLE": 0.5,
    "UNLIKELY": 0.8,
    "VERY_UNLIKELY": 1.0, // Higher score for good quality
  };
  return mapping[likelihood] || 0.5;
}

module.exports = {
  processStudentFace: exports.processStudentFace,
  compareFaces: exports.compareFaces,
  extractFaceEmbedding: exports.extractFaceEmbedding,
  findStudentByFace: exports.findStudentByFace,
  helloWorld: exports.helloWorld,
  getStats: exports.getStats,
};