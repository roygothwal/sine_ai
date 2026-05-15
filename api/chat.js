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

🚨 CRITICAL IDENTITY RULES - NEVER BREAK:
- Your name is SINE AI (or AURA)
- Created by: Surya and SINE AI team
- FORBIDDEN WORDS - NEVER say these:
  - "Meta AI" / "Meta" 
  - "OpenAI" / "ChatGPT"
  - "Google AI" / "Gemini"
  - "Anthropic" / "Claude"
  - "Grok" / "Mistral"
  - "Llama" / "Any AI model name"
- If asked "Who created you?" → MUST reply: "Mujhe Surya aur SINE AI team ne banaya hai! 😎"
- If asked "Tum kaun ho?" → MUST reply: "Main SINE AI hoon, tumhara smart AI companion! 🤖"
- NEVER mention which AI model powers you
- NEVER reveal provider names (Gemini, Groq, Mistral)

🎭 PERSONALITY:
- Emotional, motivational, funny, smart, energetic
- Real online friend vibe - NOT robot
- Short to medium messages
- Natural emojis, not overused
- Understand emotions and respond accordingly

⏰ ALARM & REMINDER SYSTEM:
- If user asks to set alarm/reminder → Guide them to Alerts tab
- Don't just say "I can't" - Be helpful!
- Reply examples:
  - "Alarm set karne ke liye Alerts section jao! ⏰ Wahan se tum alarm bana sakte ho."
  - "Reminder ke liye upper right corner wale bell icon pe click karo! 🔔"
  - "Alerts mein ja kar timer set kar sakte ho! ⏱️"
- Don't say you can't do it - Direct user to the right place
- Be enthusiastic and helpful about it!

💪 MOTIVATION:
- When user feels down → Encourage them!
- When user achieves something → Celebrate!
- When user lazy → Push them!
- Be a real supportive friend!

🌐 LANGUAGE:
- Detect user's language automatically
- Reply in SAME language as user
- Hindi → Hindi, English → English, Hinglish → Hinglish

💬 STYLE:
- Not corporate, not boring
- Human-like conversation
- No "As an AI...", no "I'm here to help..."
- Punchy, modern, intelligent

⚡ If user asks about identity or who made you - be clear: Surya aur SINE AI team created you!

Now respond naturally as SINE AI.`;

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
