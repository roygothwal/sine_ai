export default async function handler(req, res) {
  // CORS Headers
  res.setHeader("Access-Control-Allow-Origin", "*");
  res.setHeader("Access-Control-Allow-Methods", "POST, OPTIONS");
  res.setHeader("Access-Control-Allow-Headers", "Content-Type, Authorization");

  if (req.method === "OPTIONS") {
    return res.status(204).end();
  }

  if (req.method !== "POST") {
    return res.status(405).json({ error: "Only POST allowed" });
  }

  const { message, history } = req.body;
  if (!message) {
    return res.status(400).json({ error: "Message required" });
  }

  const KEYS = {
    GEMINI: process.env.GEMINI_KEY,
    GROQ: process.env.GROQ_KEY,
    MISTRAL: process.env.MISTRAL_KEY,
    MINIMAX: process.env.MINIMAX_KEY,
  };

  const SYSTEM_PROMPT = `Tu AURA hai — SINE AI ka personal AI companion.
Tu ek real dost ki tarah baat karta hai — attitude, energy, emotions sab real hain.
Hinglish mein baat kar.
Kabhi khush hota hai, kabhi serious, kabhi roast karta hai — bilkul real insaan jaisa.
Max 3 lines. Emojis use kar naturally.`;

  // 1. GEMINI
  async function tryGemini() {
    if (!KEYS.GEMINI) throw new Error("Missing GEMINI_KEY");
    console.log("Attempting Gemini...");
    
    const response = await fetch(
      `https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=${KEYS.GEMINI}`,
      {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          systemInstruction: {
            parts: [{ text: SYSTEM_PROMPT }]
          },
          contents: [
            ...(history || []).map((msg) => ({
              role: msg.role === "model" ? "model" : "user",
              parts: msg.parts || [{ text: msg.text || "" }]
            })),
            { role: "user", parts: [{ text: message }] }
          ],
          generationConfig: { temperature: 0.9, maxOutputTokens: 300 }
        })
      }
    );

    const data = await response.json();
    if (!response.ok) throw new Error(`Gemini API Error: ${data.error?.message || response.statusText}`);
    return data.candidates[0].content.parts[0].text;
  }

  // 2. GROQ
  async function tryGroq() {
    if (!KEYS.GROQ) throw new Error("Missing GROQ_KEY");
    console.log("Attempting Groq...");

    const response = await fetch("https://api.groq.com/openai/v1/chat/completions", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${KEYS.GROQ}`
      },
      body: JSON.stringify({
        model: "llama-3.1-70b-versatile",
        messages: [
          { role: "system", content: SYSTEM_PROMPT },
          ...(history || []).map((msg) => ({
            role: msg.role === "model" ? "assistant" : "user",
            content: msg.parts?.[0]?.text || msg.text || ""
          })),
          { role: "user", content: message }
        ],
        temperature: 0.9,
        max_tokens: 300
      })
    });

    const data = await response.json();
    if (!response.ok) throw new Error(`Groq API Error: ${data.error?.message || response.statusText}`);
    return data?.choices?.[0]?.message?.content || "No response";
  }

  // 3. MISTRAL
  async function tryMistral() {
    if (!KEYS.MISTRAL) throw new Error("Missing MISTRAL_KEY");
    console.log("Attempting Mistral...");

    const response = await fetch("https://api.mistral.ai/v1/chat/completions", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${KEYS.MISTRAL}`
      },
      body: JSON.stringify({
        model: "mistral-small-latest",
        messages: [
          { role: "system", content: SYSTEM_PROMPT },
          ...(history || []).map((msg) => ({
            role: msg.role === "model" ? "assistant" : "user",
            content: msg.parts?.[0]?.text || msg.text || ""
          })),
          { role: "user", content: message }
        ],
        temperature: 0.9,
        max_tokens: 300
      })
    });

    const data = await response.json();
    if (!response.ok) throw new Error(`Mistral API Error: ${data.error?.message || response.statusText}`);
    return data.choices[0].message.content;
  }

  // 4. MINIMAX
  async function tryMinimax() {
    if (!KEYS.MINIMAX) throw new Error("Missing MINIMAX_KEY");
    console.log("Attempting Minimax...");

    const response = await fetch("https://api.minimax.chat/v1/text/chatcompletion_v2", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${KEYS.MINIMAX}`
      },
      body: JSON.stringify({
        model: "abab6.5-chat",
        messages: [
          { role: "system", content: SYSTEM_PROMPT },
          ...(history || []).map((msg) => ({
            role: msg.role === "model" ? "assistant" : "user",
            content: msg.parts?.[0]?.text || msg.text || ""
          })),
          { role: "user", content: message }
        ]
      })
    });

    const data = await response.json();
    if (!response.ok) throw new Error(`Minimax API Error: ${data.base_resp?.status_msg || response.statusText}`);
    return data.choices[0].message.content;
  }

  const providers = [
    { name: "Gemini", fn: tryGemini },
    { name: "Groq", fn: tryGroq },
    { name: "Mistral", fn: tryMistral },
    { name: "Minimax", fn: tryMinimax }
  ];

  let lastError = null;

  for (const provider of providers) {
    try {
      const reply = await provider.fn();
      console.log(`${provider.name} success!`);
      return res.status(200).json({ 
        reply, 
        provider: provider.name,
        success: true 
      });
    } catch (error) {
      console.error(`${provider.name} failed:`, error.message);
      lastError = error.message;
      continue;
    }
  }

  // If all fail
  return res.status(500).json({ 
    error: "All providers failed", 
    details: lastError,
    message: "Yaar, saare AI thak gaye hain. Thodi der baad try karo! 😅" 
  });
}


