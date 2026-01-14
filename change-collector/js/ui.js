// ui.js - Standard Script

// Helpers to expose explicitly if needed, but they are global by default in scripts
// window.togglePrivacyMode = togglePrivacyMode; // Redundant if function is global

function updateUI() {
    // Calculate Totals
    const totalSavedInGoals = appState.goals.reduce((acc, g) => acc + g.current, 0);

    // Update Balance Card
    const mainBalance = document.getElementById('main-balance');
    const payBalance = document.getElementById('pay-balance-display');
    if (mainBalance) mainBalance.innerText = appState.balance.toFixed(2);
    if (payBalance) payBalance.innerText = '$' + appState.balance.toFixed(2);

    // Streak Init
    const streakEl = document.getElementById('streak-count');
    if (streakEl) streakEl.innerText = appState.streak || 0;

    const totalSavedLabel = document.getElementById('total-saved-label');
    if (totalSavedLabel) totalSavedLabel.innerText = '$' + totalSavedInGoals.toFixed(2);

    // Update Profile
    if (appState.user && document.getElementById('home-greeting')) {
        document.getElementById('home-greeting').innerText = `Hola, ${appState.user.name.split(' ')[0]} 👋`;
        document.getElementById('profile-name').innerText = appState.user.name;
        document.getElementById('profile-email').innerText = appState.user.email;
    }

    if (typeof renderGoals === 'function') renderGoals();
    if (typeof renderHistory === 'function') renderHistory();
}

function togglePrivacyMode() {
    appState.privacyMode = !appState.privacyMode;
    saveData();

    // Toggle blur on sensitive data
    document.querySelectorAll('.sensitive-data').forEach(el => {
        if (appState.privacyMode) {
            el.classList.add('blur-text');
        } else {
            el.classList.remove('blur-text');
        }
    });

    // Update Toggle UI if visible (Security Screen)
    const dot = document.getElementById('privacy-mode-dot');
    const track = document.getElementById('privacy-mode-toggle');
    if (dot && track) {
        if (appState.privacyMode) {
            track.classList.remove('bg-gray-200');
            track.classList.add('bg-emerald-500');
            dot.style.transform = "translateX(24px)";
        } else {
            track.classList.add('bg-gray-200');
            track.classList.remove('bg-emerald-500');
            dot.style.transform = "translateX(0)";
        }
    }

    // Update Eye Icon (Home Screen) - Direct approach
    const iconContainer = document.getElementById('privacy-icon');
    if (iconContainer) {
        const newIcon = appState.privacyMode ? 'eye' : 'eye-off';
        iconContainer.outerHTML = `<i data-lucide="${newIcon}" class="w-4 h-4 text-white" id="privacy-icon"></i>`;
        if (window.lucide) window.lucide.createIcons();
    }
}

function toggleDarkMode() {
    appState.darkMode = !appState.darkMode;
    saveData();
    applyTheme();
}

function applyTheme() {
    // Apply to HTML tag for Tailwind
    const root = document.documentElement;
    if (appState.darkMode) {
        root.classList.add('dark');
    } else {
        root.classList.remove('dark');
    }

    // Update Toggle UI
    const dot = document.getElementById('dark-mode-dot');
    const track = document.getElementById('dark-mode-toggle');
    if (dot && track) {
        if (appState.darkMode) {
            track.classList.remove('bg-gray-200');
            track.classList.add('bg-emerald-500');
            dot.style.transform = "translateX(24px)";
        } else {
            track.classList.add('bg-gray-200');
            track.classList.remove('bg-emerald-500');
            dot.style.transform = "translateX(0)";
        }
    }
}
window.toggleDarkMode = toggleDarkMode;
window.applyTheme = applyTheme;

// --- ONBOARDING LOGIC ---
let currentSlide = 1;

function nextSlide() {
    if (currentSlide < 3) {
        document.getElementById(`slide-${currentSlide}`).classList.remove('active');
        currentSlide++;
        document.getElementById(`slide-${currentSlide}`).classList.add('active');

        document.querySelectorAll(`.dot-${currentSlide}`).forEach(d => { d.classList.remove('bg-gray-300'); d.classList.add('bg-emerald-600'); });

        if (currentSlide === 3) {
            document.getElementById('btn-next').innerText = "Comenzar";
        }
    } else {
        document.getElementById('onboarding-overlay').style.display = 'none';
        appState.onboardingDone = true;
        saveData();
        if (!appState.user) changeScreen('register');
    }
}

// --- NAVIGATION ---
function changeScreen(screenId) {
    const navbar = document.getElementById('navbar');
    // Hide navbar on modals or creation screens too now
    const noNavScreens = ['login', 'scan', 'success', 'register', 'create-goal'];
    if (noNavScreens.includes(screenId)) {
        navbar.classList.add('hidden');
        navbar.classList.remove('flex');
    } else {
        navbar.classList.remove('hidden');
        navbar.classList.add('flex');
    }

    document.querySelectorAll('.screen').forEach(s => s.classList.remove('active'));
    document.getElementById(screenId + '-screen').classList.add('active');

    document.querySelectorAll('.tab-btn').forEach(btn => {
        btn.classList.add('text-gray-400');
        btn.classList.remove('tab-active');
    });

    if (document.getElementById('btn-' + screenId)) {
        document.getElementById('btn-' + screenId).classList.add('tab-active');
        document.getElementById('btn-' + screenId).classList.remove('text-gray-400');
    }

    if (window.lucide) window.lucide.createIcons();
}

// --- MINI TOUR LOGIC ---
let tourStepIndex = 0;
const tourSteps = [
    {
        id: 'btn-scan-action',
        title: '¡Empieza Aquí!',
        text: 'Toca el botón verde para escanear tu primer código QR y sumar saldo a tu cuenta.'
    },
    {
        id: 'goals-section',
        title: 'Crea una Meta',
        text: 'Define para qué estás ahorrando. Un viaje, un regalo o un gustito. ¡Visualízalo!'
    },
    {
        id: 'btn-action-analytics',
        title: 'Mira tu Progreso',
        text: 'Consulta gráficas detalladas de cuánto has ahorrado y tus hábitos de gasto.'
    }
];

function startTour() {
    if (appState.tourDone) return;

    // Ensure we are on home screen
    changeScreen('home');

    tourStepIndex = 0;
    document.getElementById('tour-overlay').style.display = 'block';

    // Slight delay to allow fade in
    setTimeout(() => {
        document.getElementById('tour-overlay').classList.add('visible');
        showTourStep(0);
    }, 100);
}

function showTourStep(index) {
    // Cleanup previous
    document.querySelectorAll('.tour-highlight').forEach(el => el.classList.remove('tour-highlight'));

    const step = tourSteps[index];
    const el = document.getElementById(step.id);
    const tooltip = document.getElementById('tour-tooltip');

    // Find container for relative calc
    const container = document.querySelector('.phone-container') || document.body;

    if (el) {
        el.classList.add('tour-highlight');
        el.scrollIntoView({ behavior: 'smooth', block: 'center' });

        // Calculate Relative Position
        const elRect = el.getBoundingClientRect();
        const containerRect = container.getBoundingClientRect();

        // Vertical offsets within the container
        const relativeTop = elRect.top - containerRect.top;
        const relativeBottom = elRect.bottom - containerRect.top;

        // Determine Position (Above or Below)
        // If element is in lower half of container, put tooltip above.
        const isLow = relativeTop > (containerRect.height / 2);

        if (isLow) {
            // Tooltip Above Element
            tooltip.style.top = 'auto';
            tooltip.style.bottom = (containerRect.height - relativeTop + 15) + 'px';
        } else {
            // Tooltip Below Element
            tooltip.style.top = (relativeBottom + 15) + 'px';
            tooltip.style.bottom = 'auto';
        }

        // Reset legacy transforms
        tooltip.style.left = '50%';
        tooltip.style.transform = 'translateX(-50%)';
        tooltip.style.position = 'absolute';

        // Content
        document.getElementById('tour-title').innerText = step.title;
        document.getElementById('tour-text').innerText = step.text;
        document.getElementById('tour-step-count').innerText = `${index + 1}/${tourSteps.length}`;

        if (index === tourSteps.length - 1) {
            document.getElementById('tour-next-btn').innerText = '¡Listo!';
        } else {
            document.getElementById('tour-next-btn').innerText = 'Siguiente';
        }

        tooltip.classList.remove('hidden');
    }
}

function nextTourStep() {
    tourStepIndex++;
    if (tourStepIndex < tourSteps.length) {
        showTourStep(tourStepIndex);
    } else {
        endTour();
    }
}

function endTour() {
    document.getElementById('tour-overlay').classList.remove('visible');
    document.getElementById('tour-tooltip').classList.add('hidden');
    document.querySelectorAll('.tour-highlight').forEach(el => el.classList.remove('tour-highlight'));

    setTimeout(() => {
        document.getElementById('tour-overlay').style.display = 'none';
        appState.tourDone = true;
        saveData();
    }, 300);
}

// --- AVATAR LOGIC ---
function openAvatarSelector() {
    const modal = document.getElementById('avatar-modal');
    modal.classList.remove('hidden');
    // Force reflow for transition
    void modal.offsetWidth;
    modal.classList.remove('opacity-0');
}

function closeAvatarSelector() {
    const modal = document.getElementById('avatar-modal');
    modal.classList.add('opacity-0');
    setTimeout(() => modal.classList.add('hidden'), 300);
}

function saveAvatar(avatarChar) {
    appState.avatar = avatarChar;
    // Helper to check if it's an image URL or emoji
    appState.avatarType = 'emoji';
    saveData();
    renderAvatar();
    closeAvatarSelector();
}

function handleAvatarUpload(input) {
    if (input.files && input.files[0]) {
        const reader = new FileReader();
        reader.onload = function (e) {
            // WARNING: Storing base64 images in localStorage is heavy. 
            // Ideally we'd resize this or use IndexedDB, but for simplicity:
            const base64Image = e.target.result;

            // Basic compression check (truncate if huge) could happen here
            appState.avatar = base64Image;
            appState.avatarType = 'image';
            saveData();
            renderAvatar();
            closeAvatarSelector();
        };
        reader.readAsDataURL(input.files[0]);
    }
}

function renderAvatar() {
    const display = document.getElementById('profile-avatar-display');
    const homeIcon = document.querySelector('header i[data-lucide="user"]')?.parentElement;

    if (!display) return;

    if (appState.avatarType === 'image') {
        // Profile Screen
        display.innerHTML = `<img src="${appState.avatar}" class="w-full h-full rounded-full object-cover">`;

        // Home Screen Icon (Replace user icon with image)
        if (homeIcon) {
            homeIcon.innerHTML = `<img src="${appState.avatar}" class="w-full h-full rounded-full object-cover">`;
        }
    } else {
        // Emoji
        display.innerHTML = appState.avatar || '👤';
        // Reset Home Icon if it was an image
        if (homeIcon) {
            // If we want to show emoji on home too:
            homeIcon.innerHTML = `<span class="text-xl">${appState.avatar || '👤'}</span>`;
        }
    }
}

// Hook renderAvatar into updateUI or wherever screen changes
// We'll append a call to it in global init or ui update
window.openAvatarSelector = openAvatarSelector;
window.closeAvatarSelector = closeAvatarSelector;
window.saveAvatar = saveAvatar;
window.handleAvatarUpload = handleAvatarUpload;
// --- EDIT PROFILE LOGIC ---
function openEditProfile() {
    const modal = document.getElementById('edit-profile-modal');

    // Pre-fill
    document.getElementById('edit-profile-name').value = appState.user.name || '';
    document.getElementById('edit-profile-email').value = appState.user.email || '';

    modal.classList.remove('hidden');
    void modal.offsetWidth; // Force reflow
    modal.classList.remove('opacity-0');
}

function closeEditProfile() {
    const modal = document.getElementById('edit-profile-modal');
    modal.classList.add('opacity-0');
    setTimeout(() => modal.classList.add('hidden'), 300);
}

function saveProfileChanges() {
    const name = document.getElementById('edit-profile-name').value.trim();
    const email = document.getElementById('edit-profile-email').value.trim();

    if (!name || !email) {
        alert("Por favor completa ambos campos.");
        return;
    }

    // Update State
    appState.user.name = name;
    appState.user.email = email;

    saveData();
    updateUI(); // Refreshes profile screen display

    // Update greeting specifically if on home
    const greeting = document.getElementById('home-greeting');
    if (greeting) greeting.innerText = `Hola, ${name.split(' ')[0]} 👋`;

    closeEditProfile();
    // Optional Success Feedback
    const btn = document.querySelector('button[onclick="openEditProfile()"]');
    if (btn) {
        const originalText = btn.innerText;
        btn.innerText = "¡Guardado!";
        btn.classList.add('text-emerald-700', 'bg-emerald-200');
        setTimeout(() => {
            btn.innerText = originalText;
            btn.classList.remove('text-emerald-700', 'bg-emerald-200');
        }, 1500);
    }
}

window.openEditProfile = openEditProfile;
window.closeEditProfile = closeEditProfile;
window.saveProfileChanges = saveProfileChanges;

function renderAvatar() {
    const display = document.getElementById('profile-avatar-display');
    const homeIcon = document.getElementById('home-avatar-container');

    // Always update render if element exists

    if (appState.avatarType === 'image') {
        // Profile Screen
        if (display) display.innerHTML = `<img src="${appState.avatar}" class="w-full h-full rounded-full object-cover">`;

        // Home Screen Icon
        if (homeIcon) {
            homeIcon.innerHTML = `<img src="${appState.avatar}" class="w-full h-full rounded-full object-cover">`;
        }
    } else {
        // Emoji
        if (display) display.innerHTML = appState.avatar || '👤';
        // Reset Home Icon
        if (homeIcon) {
            // Show emoji on home too
            homeIcon.innerHTML = `<span class="text-xl">${appState.avatar || '👤'}</span>`;
        }
    }
}
window.startTour = startTour;
window.nextTourStep = nextTourStep;
