// auth.js - Standard Script

let currentPin = "";
// Explicitly expose to window to guarantee availability
window.enterPin = enterPin;
window.completeRegistration = completeRegistration;
window.registerBiometric = registerBiometric;
window.loginWithBiometric = loginWithBiometric;

function enterPin(num) {
    if (currentPin.length < 4) {
        currentPin += num;
        updatePinDots();
    }

    if (currentPin.length === 4) {
        setTimeout(() => {
            // Check against STORED PIN
            if (currentPin === appState.user.pin) {
                changeScreen('home');
                currentPin = "";
                resetPinDots();

                // Trigger Tour (Check Global)
                if (window.startTour && !appState.tourDone) setTimeout(window.startTour, 500);
            } else {
                alert('PIN Incorrecto');
                currentPin = "";
                updatePinDots();
                shakePad();
            }
        }, 300);
    }
}

function updatePinDots() {
    document.querySelectorAll('.pin-dot').forEach((dot, idx) => {
        if (idx < currentPin.length) dot.classList.add('active');
        else dot.classList.remove('active');
    });
}

function resetPinDots() {
    document.querySelectorAll('.pin-dot').forEach(dot => dot.classList.remove('active'));
}

function shakePad() {
    const pad = document.getElementById('pin-pad');
    pad.classList.add('shake');
    setTimeout(() => pad.classList.remove('shake'), 500);
}

function completeRegistration() {
    const name = document.getElementById('reg-name').value;
    const email = document.getElementById('reg-email').value;
    const pin = document.getElementById('reg-pin').value;

    if (!name || !email || pin.length !== 4) {
        alert("Por favor completa todos los campos correctamente.");
        return;
    }

    appState.user = { name, email, pin };
    saveData();
    changeScreen('home');
    alert("¡Registro Exitoso! Bienvenido.");

    // Trigger Tour (Check Global)
    if (window.startTour && !appState.tourDone) setTimeout(window.startTour, 500);
}

// --- BIOMETRIC AUTHENTICATION (WebAuthn) ---
async function registerBiometric() {
    if (!window.PublicKeyCredential) {
        alert('Tu navegador no soporta autenticación biométrica.');
        return;
    }

    try {
        const challenge = new Uint8Array(32);
        window.crypto.getRandomValues(challenge);

        const publicKeyOptions = {
            challenge: challenge,
            rp: {
                name: "Change Collector",
                id: window.location.hostname
            },
            user: {
                id: new Uint8Array(16),
                name: appState.user.email,
                displayName: appState.user.name
            },
            pubKeyCredParams: [{ alg: -7, type: "public-key" }],
            authenticatorSelection: {
                authenticatorAttachment: "platform",
                userVerification: "required"
            },
            timeout: 60000,
            attestation: "none"
        };

        const credential = await navigator.credentials.create({ publicKey: publicKeyOptions });

        // Store credential ID
        localStorage.setItem('biometricCredentialId', btoa(String.fromCharCode(...new Uint8Array(credential.rawId))));
        appState.biometricEnabled = true;
        saveData();

        alert('✅ Huella/Face ID configurado correctamente.');

        // Show button on login screen
        const biometricBtn = document.getElementById('biometric-btn');
        if (biometricBtn) biometricBtn.classList.remove('hidden');
    } catch (error) {
        console.error('Biometric registration error:', error);
        alert('No se pudo configurar la autenticación biométrica. Asegúrate de tener configurada tu huella o Face ID en el dispositivo.');
    }
}

async function loginWithBiometric() {
    if (!window.PublicKeyCredential) {
        alert('Tu navegador no soporta autenticación biométrica.');
        return;
    }

    const credentialId = localStorage.getItem('biometricCredentialId');
    if (!credentialId) {
        alert('No tienes configurada la autenticación biométrica. Usa tu PIN para entrar y actívala en Seguridad.');
        return;
    }

    try {
        const challenge = new Uint8Array(32);
        window.crypto.getRandomValues(challenge);

        // Convert stored ID back to BufferSource
        const rawId = Uint8Array.from(atob(credentialId), c => c.charCodeAt(0));

        const publicKeyOptions = {
            challenge: challenge,
            allowCredentials: [{
                id: rawId,
                type: 'public-key',
                transports: ['internal']
            }],
            userVerification: 'required',
            timeout: 60000
        };

        const assertion = await navigator.credentials.get({ publicKey: publicKeyOptions });

        // In real app, verify assertion on server. Here we trust the successful local promise.
        changeScreen('home');
        currentPin = "";
        resetPinDots();

        // Trigger Tour (Check Global)
        if (window.startTour && !appState.tourDone) setTimeout(window.startTour, 500);
    } catch (error) {
        console.error('Biometric login error:', error);
        alert('Autenticación fallida. Usa tu PIN para entrar.');
    }
}
