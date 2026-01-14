// app.js - Main Entry Point

// --- INITIALIZATION ---

// Register Service Worker
if ('serviceWorker' in navigator) {
    window.addEventListener('load', () => {
        navigator.serviceWorker.register('./sw.js')
            .then(reg => console.log('SW Registered'))
            .catch(err => console.log('SW Error:', err));
    });
}

// Initial Load
document.addEventListener('DOMContentLoaded', () => {
    if (typeof lucide !== 'undefined') lucide.createIcons();

    loadData();
    updateTime();
    if (typeof updateUI === 'function') updateUI(); // Force UI Render
    setInterval(updateTime, 60000); // UI Clock

    // --- ROUTING LOGIC PHASE 4 ---
    if (!appState.onboardingDone) {
        document.getElementById('onboarding-overlay').style.display = 'flex';
        document.getElementById('onboarding-overlay').classList.remove('hidden');
    } else {
        document.getElementById('onboarding-overlay').classList.add('hidden');
        if (!appState.user) {
            changeScreen('register');
        } else {
            changeScreen('login');
            try {
                document.getElementById('login-welcome-text').innerText = `Hola de nuevo, ${appState.user.name.split(' ')[0]}. Ingresa tu PIN.`;
            } catch (e) {
                // Fallback if data is corrupted
                changeScreen('register');
            }
        }
    }

    if (appState.darkMode) {
        document.documentElement.classList.add('dark');
    }

    // Privacy Mode (Init)
    if (appState.privacyMode) {
        document.querySelectorAll('.sensitive-data').forEach(el => el.classList.add('blur-text'));
    }

    // Check WebAuthn availability
    if (window.PublicKeyCredential) {
        const biometricBtn = document.getElementById('biometric-btn');
        if (biometricBtn && appState.biometricEnabled) {
            biometricBtn.classList.remove('hidden');
        }
    }
});

// --- SIMULATION LOGIC (Restored) ---
function simulateScan() {
    // 1. Loading UI
    const btn = document.querySelector('#scan-screen button[onclick="simulateScan()"]');
    const originalText = btn.innerText;
    btn.innerText = "Procesando...";
    btn.disabled = true;

    setTimeout(() => {
        // 2. Generate Random Change (e.g. $5.50 - $42.00)
        const amount = (Math.random() * (42 - 5) + 5);

        // Random Merchant
        const merchants = ['Oxxo', '7-Eleven', 'Starbucks', 'Walmart', 'Farmacia Guadalajara', 'Uber', 'Cinépolis', 'McDonald\'s'];
        const merchant = merchants[Math.floor(Math.random() * merchants.length)];

        // 3. Update State
        appState.balance += amount;
        appState.transactions.push({
            id: Date.now(),
            title: `Cambio en ${merchant}`,
            date: new Date().toISOString(),
            amount: amount,
            type: 'credit'
        });

        // Save & UI
        saveData(); // Will trigger updateUI() if linked, or we call it
        updateUI(); // Ensure UI is fresh
        if (typeof playSound === 'function') playSound('coin');

        // 4. Show Success
        document.getElementById('captured-amount').innerText = amount.toFixed(2);
        changeScreen('success');

        // Reset Button
        btn.innerText = originalText;
        btn.disabled = false;

    }, 1500); // Fake delay
}

function simulateSpend() {
    const amount = 5.00;

    if (appState.balance < amount) {
        alert("Saldo insuficiente para realizar esta prueba.");
        return;
    }

    if (confirm(`¿Simular un pago de $${amount.toFixed(2)}?`)) {
        // Deduct
        appState.balance -= amount;

        // Add Transaction
        appState.transactions.push({
            id: Date.now(),
            title: 'Pago en Comercio (Demo)',
            date: new Date().toISOString(),
            amount: amount,
            type: 'debit'
        });

        // Save & UI (Round up logic logic could go here, but kept simple for now)
        saveData();
        updateUI();
        if (typeof playSound === 'function') playSound('pop');

        alert(`Pago realizado. Nuevo saldo: $${appState.balance.toFixed(2)}`);
    }
}

// Expose to window
window.simulateScan = simulateScan;
window.simulateSpend = simulateSpend;
