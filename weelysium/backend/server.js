// WeeLysium Backend Server (v1.0)
// This script manages the transition from "In-Game Credits" to "Real-World Impact"

const express = require('express');
const jwt = require('jsonwebtoken');
const app = express();
const PORT = 3000;

// Middleware to read JSON data from the Unity Game
app.use(express.json());

// A Mock Database of Local Charities (Section 8.3 of Design Doc)
const charityCache = [
    { zip: "30308", name: "Atlanta Humane Society", id: "charity_001" },
    { zip: "90210", name: "Beverly Hills Wildlife Fund", id: "charity_002" },
    { zip: "default", name: "WeeLysium Global Sustainability Fund", id: "charity_global" }
];

/**
 * Endpoint: /api/v1/session/terminate
 * This is where the Unity Bridge sends the "End of Session" report.
 */
app.post('/api/v1/session/terminate', (req, res) => {
    const { user_id, session_zip_code, credits_spent } = req.body;

    console.log(`[SERVER] Received session from User: ${user_id} in Zip: ${session_zip_code}`);

    // 1. Find the local charity based on the player's Zip Code
    const targetCharity = charityCache.find(c => c.zip === session_zip_code) || charityCache[2];

    // 2. Calculate the fiat value ($1.00 USD per 100 Wee-Credits)
    const impactAmountUsd = (credits_spent / 100).toFixed(2);

    // 3. Generate a Secure JWT Token (Section 7.2)
    // In a real app, 'SECRET_KEY' would be a hidden environment variable
    const token = jwt.sign({
        userId: user_id,
        amount: impactAmountUsd,
        charity: targetCharity.name
    }, 'WEELYSIUM_SECRET_KEY', { expiresIn: '15m' });

    // 4. Send the Secure Redirect Link back to Unity
    // This URL bypasses the 30% App Store fee by moving to a web browser
    res.json({
        message: "Session Validated.",
        checkout_url: `https://weelysium.org/checkout?auth=${token}`,
        summary: {
            credits: credits_spent,
            impact_usd: `$${impactAmountUsd}`,
            beneficiary: targetCharity.name
        }
    });
});

app.listen(PORT, () => {
    console.log(`================================================`);
    console.log(`   WEELYSIUM BACKEND ONLINE: http://localhost:${PORT} `);
    console.log(`================================================`);
});