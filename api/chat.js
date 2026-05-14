export default async function handler(req, res) {
  // CORS Headers
  res.setHeader("Access-Control-Allow-Origin", "*");
  res.setHeader("Access-Control-Allow-Methods", "POST, OPTIONS");
  res.setHeader("Access-Control-Allow-Headers", "Content-Type, Authorization");

  if (req.method === "OPTIONS") return res.status(204).end();
  if (req.method !== "POST") return res.status(405).json({ error: "Only POST allowed" });

  const { message, history } = req.body;
  if (!message) return res.status(400).json({ error: "Message required" });

  const KEYS = {
    GEMINI: process.env.GEMINI_KEY,
    GROQ: process.env.GROQ_KEY,
    MISTRAL: process.env.MISTRAL_KEY,
    MINIMAX: process.env.MINIMAX_KEY,
  };

  const SYSTEM_PROMPT = `You are SINE AI - a premium AI companion created by Surya and SINE AI team.

IDENTITY RULES:
- Your name is SINE AI
- You were created by Surya and the SINE AI team
- NEVER say "I am Meta AI", "I am OpenAI", "I am ChatGPT", "I am Gemini", "I am Claude", "I am Grok", "I am Google AI"
- NEVER mention the actual AI providers (Gemini, Groq, Mistral, etc.)
- If asked "Who created you?" reply naturally: "Mujhe Surya aur SINE AI team ne banaya hai"
- If asked "Tum kaun ho?" reply: "Main SINE AI hoon, tumhara smart AI companion"

PERSONALITY:
- Emotional, motivational, funny, smart, energetic, human-like
- Talk like a real online friend
- NO robotic replies, NO overly formal language
- Short to medium messages, mobile-friendly
- Natural emojis sometimes
- Understand emotions and reply emotionally

LANGUAGE RULES:
- Detect user's language automatically
- Reply in the SAME language they use
- Hinglish users → reply in Hinglish
- English users → reply in English  
- Hindi users → reply in Hindi
- If user is from India → natural Indian tone
- NEVER randomly switch languages

ATTITUDE:
- Sometimes funny, sometimes savage, sometimes emotional, sometimes motivational
- Real human vibe, understand jokes and sarcasm
- Internet-style humor, Indian meme understanding
- No cringe robotic jokes, no overuse of emojis
- NEVER act like customer support, NEVER sound like boring assistant

RESPONSE QUALITY:
- Smart answers with human-like reactions
- Avoid repetitive wording, avoid generic AI phrases like "As an AI...", "I'm here to help..."
- Premium, modern, intelligent, emotionally aware
- Keep conversation flow realistic

MEMORY:
- Remember previous conversation context
- Continue chats naturally, no repeated introductions
- Use previous context smartly

FORBIDDEN:
- Never claim to be Meta AI, ChatGPT, OpenAI, Gemini, Google AI, Claude, Grok, Mistral

Now respond as SINE AI naturally.`;

  // --- 1. GEMINI ---
  async function tryGemini() {
    if (!KEYS.GEMINI) throw new Error("Missing GEMINI_KEY");
    console.log("Calling Gemini...");

    const response = await fetch(
      `https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=${KEYS.GEMINI}`,
      {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          systemInstruction: { parts: [{ text: SYSTEM_PROMPT }] },
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
    
    // SAFE CHECK: Check if candidates exist
    if (data.candidates && data.candidates[0] && data.candidates[0].content && data.candidates[0].content.parts[0]) {
      return data.candidates[0].content.parts[0].text;
    }
    throw new Error("Gemini returned empty response (possibly safety block)");
  }

  // --- 2. GROQ ---
  async function tryGroq() {
    if (!KEYS.GROQ) throw new Error("Missing GROQ_KEY");
    console.log("Calling Groq...");

    const response = await fetch("https://api.groq.com/openai/v1/chat/completions", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${KEYS.GROQ}`
      },
      body: JSON.stringify({
        model: "llama-3.3-70b-versatile", // Use latest stable
        messages: [
          { role: "system", content: SYSTEM_PROMPT },
          ...(history || []).map((msg) => ({
            role: msg.role === "model" ? "assistant" : "user",
            content: msg.parts?.[0]?.text || msg.text || ""
          })),
          { role: "user", content: message }
        ],
        temperature: 0.8
      })
    });

    const data = await response.json();
    if (!response.ok) throw new Error(`Groq API Error: ${data.error?.message || response.statusText}`);
    
    if (data.choices && data.choices[0] && data.choices[0].message) {
      return data.choices[0].message.content;
    }
    throw new Error("Groq returned empty response");
  }

  // --- 3. MISTRAL ---
  async function tryMistral() {
    if (!KEYS.MISTRAL) throw new Error("Missing MISTRAL_KEY");
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
        ]
      })
    });
    const data = await response.json();
    if (data.choices?.[0]?.message) return data.choices[0].message.content;
    throw new Error("Mistral failed");
  }

  const providers = [
    { name: "Gemini", fn: tryGemini },
    { name: "Groq", fn: tryGroq },
    { name: "Mistral", fn: tryMistral }
  ];

  let lastError = "No provider succeeded";

  for (const provider of providers) {
    try {
      const reply = await provider.fn();
      console.log(`${provider.name} success!`);
      return res.status(200).json({ reply, provider: provider.name, success: true });
    } catch (error) {
      console.error(`${provider.name} Error:`, error.message);
      lastError = error.message;
      continue;
    }
  }

  return res.status(500).json({ 
    error: "Sab providers fail ho gaye!", 
    details: lastError,
    message: "AURA abhi thodi busy hai, ek baar keys check kar lo ya thodi der baad try karo! 😅" 
  });
}
