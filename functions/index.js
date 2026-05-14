const functions = require("firebase-functions");
const axios = require("axios");

const GEMINI_KEY = functions.config().gemini?.key || "";
const GROQ_KEY = functions.config().groq?.key || "";
const MISTRAL_KEY = functions.config().mistral?.key || "";

const SYSTEM_PROMPT = `Tu AURA hai — SINE AI ka personal AI companion.
Tu ek real dost ki tarah baat karta hai — attitude, energy, emotions sab real hain.
Hinglish mein baat kar.
Kabhi khush hota hai, kabhi serious, kabhi roast karta hai — bilkul real insaan jaisa.
Max 3 lines. Emojis use kar naturally.`;

async function tryGemini(message, history) {
  if (!GEMINI_KEY) throw new Error("No Gemini key");
  
  const response = await axios.post(
    `https://generativelanguage.googleapis.com/v1beta/models/gemma-2-9b-it:generateContent?key=${GEMINI_KEY}`,
    {
      contents: [
        { role: "user", parts: [{ text: SYSTEM_PROMPT }] },
        ...(history || []).map((msg) => ({
          role: msg.role === "model" ? "model" : "user",
          parts: msg.parts || [{ text: msg.text || "" }]
        })),
        { role: "user", parts: [{ text: message }] }
      ],
      generationConfig: { temperature: 0.95, maxOutputTokens: 200 }
    }
  );
  return response.data.candidates[0].content.parts[0].text;
}

async function tryGroq(message, history) {
  if (!GROQ_KEY) throw new Error("No Groq key");
  
  const messages = [
    { role: "system", content: SYSTEM_PROMPT },
    ...(history || []).map((msg) => ({
      role: msg.role === "model" ? "assistant" : "user",
      content: msg.parts?.[0]?.text || msg.text || ""
    })),
    { role: "user", content: message }
  ];

  const response = await axios.post(
    "https://api.groq.com/openai/v1/chat/completions",
    {
      model: "llama-3.1-70b-versatile",
      messages,
      temperature: 0.95,
      max_tokens: 200
    },
    { headers: { Authorization: `Bearer ${GROQ_KEY}` } }
  );
  return response.data.choices[0].message.content;
}

async function tryMistral(message, history) {
  if (!MISTRAL_KEY) throw new Error("No Mistral key");
  
  const messages = [
    { role: "system", content: SYSTEM_PROMPT },
    ...(history || []).map((msg) => ({
      role: msg.role === "model" ? "assistant" : "user",
      content: msg.parts?.[0]?.text || msg.text || ""
    })),
    { role: "user", content: message }
  ];

  const response = await axios.post(
    "https://api.mistral.ai/v1/chat/completions",
    {
      model: "mistral-small-latest",
      messages,
      temperature: 0.95,
      max_tokens: 200
    },
    { headers: { Authorization: `Bearer ${MISTRAL_KEY}` } }
  );
  return response.data.choices[0].message.content;
}

exports.chat = functions.https.onRequest(async (req, res) => {
  res.set("Access-Control-Allow-Origin", "*");
  if (req.method === "OPTIONS") {
    res.set("Access-Control-Allow-Methods", "POST");
    res.set("Access-Control-Allow-Headers", "Content-Type");
    res.status(204).send("");
    return;
  }

  if (req.method !== "POST") {
    res.status(405).json({ error: "Only POST allowed" });
    return;
  }

  const { message, history } = req.body;
  if (!message) {
    res.status(400).json({ error: "Message required" });
    return;
  }

  const apis = [
    { name: "Gemini", fn: () => tryGemini(message, history) },
    { name: "Groq", fn: () => tryGroq(message, history) },
    { name: "Mistral", fn: () => tryMistral(message, history) }
  ];

  for (const api of apis) {
    try {
      console.log(`Trying ${api.name}...`);
      const reply = await api.fn();
      console.log(`${api.name} success!`);
      res.status(200).json({ reply, provider: api.name });
      return;
    } catch (error) {
      console.error(`${api.name} failed:`, error.message);
      continue;
    }
  }

  res.status(500).json({ error: "Sab APIs fail ho gaye! 😅" });
});