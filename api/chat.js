export default async function handler(req, res) {
  res.setHeader("Access-Control-Allow-Origin", "*");
  if (req.method === "OPTIONS") {
    res.setHeader("Access-Control-Allow-Methods", "POST");
    res.setHeader("Access-Control-Allow-Headers", "Content-Type");
    return res.status(204).end();
  }

  if (req.method !== "POST") {
    return res.status(405).json({ error: "Only POST allowed" });
  }

  const { message, history } = req.body;
  if (!message) {
    return res.status(400).json({ error: "Message required" });
  }

  const GEMINI_KEY = process.env.GEMINI_KEY || "";
  const GROQ_KEY = process.env.GROQ_KEY || "";
  const MISTRAL_KEY = process.env.MISTRAL_KEY || "";

  const SYSTEM_PROMPT = `Tu AURA hai — SINE AI ka personal AI companion.
Tu ek real dost ki tarah baat karta hai — attitude, energy, emotions sab real hain.
Hinglish mein baat kar.
Kabhi khush hota hai, kabhi serious, kabhi roast karta hai — bilkul real insaan jaisa.
Max 3 lines. Emojis use kar naturally.`;

  async function tryGemini() {
    if (!GEMINI_KEY) throw new Error("No Gemini key");
    const response = await fetch(
      `https://generativelanguage.googleapis.com/v1beta/models/gemma-2-9b-it:generateContent?key=${GEMINI_KEY}`,
      {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          contents: [
            { role: "user", parts: [{ text: SYSTEM_PROMPT }] },
            ...(history || []).map((msg) => ({
              role: msg.role === "model" ? "model" : "user",
              parts: msg.parts || [{ text: msg.text || "" }]
            })),
            { role: "user", parts: [{ text: message }] }
          ],
          generationConfig: { temperature: 0.95, maxOutputTokens: 200 }
        })
      }
    );
    const data = await response.json();
    return data.candidates[0].content.parts[0].text;
  }

  async function tryGroq() {
    if (!GROQ_KEY) throw new Error("No Groq key");
    const response = await fetch("https://api.groq.com/openai/v1/chat/completions", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${GROQ_KEY}`
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
        temperature: 0.95,
        max_tokens: 200
      })
    });
    const data = await response.json();
    return data.choices[0].message.content;
  }

  async function tryMistral() {
    if (!MISTRAL_KEY) throw new Error("No Mistral key");
    const response = await fetch("https://api.mistral.ai/v1/chat/completions", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${MISTRAL_KEY}`
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
        temperature: 0.95,
        max_tokens: 200
      })
    });
    const data = await response.json();
    return data.choices[0].message.content;
  }

  const apis = [
    { name: "Gemini", fn: tryGemini },
    { name: "Groq", fn: tryGroq },
    { name: "Mistral", fn: tryMistral }
  ];

  for (const api of apis) {
    try {
      console.log(`Trying ${api.name}...`);
      const reply = await api.fn();
      console.log(`${api.name} success!`);
      return res.status(200).json({ reply, provider: api.name });
    } catch (error) {
      console.error(`${api.name} failed:`, error.message);
      continue;
    }
  }

  return res.status(500).json({ error: "Sab APIs fail ho gaye! 😅" });
}