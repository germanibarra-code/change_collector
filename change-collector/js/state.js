// --- APP STATE & INITIALIZATION ---
// No imports needed for global scope, assuming dependencies loaded

let appState = {
    user: null,
    balance: 0.00,
    goals: [], // { id, name, target, current, icon }
    transactions: [],
    onboardingDone: false,
    darkMode: false,
    streak: 0,
    lastActionDate: null,
    privacyMode: false,
    biometricEnabled: false,
    tourDone: false,
    avatar: '👤',
    avatarType: 'emoji'
};

// --- PERSISTENCE ---
function loadData() {
    const saved = localStorage.getItem('changeCollectorData_v5');
    if (saved) {
        appState = JSON.parse(saved);
        if (!appState.goals) appState.goals = [];
    } else {
        const v4 = localStorage.getItem('changeCollectorData_v4');
        if (v4) {
            const old = JSON.parse(v4);
            appState.balance = old.balance;
            appState.transactions = old.transactions;
            appState.onboardingDone = old.onboardingDone;
            appState.tourDone = old.tourDone || false;
            appState.avatar = old.avatar || '👤';
            appState.darkMode = old.darkMode;
            appState.user = old.user;
            appState.goals = [];
        }
    }
}

function saveData() {
    localStorage.setItem('changeCollectorData_v5', JSON.stringify(appState));
    if (typeof updateUI === 'function') updateUI();
}

function resetData() {
    if (confirm('¿Estás seguro de borrar tu cuenta y todos los datos? Esto reiniciará la app.')) {
        localStorage.removeItem('changeCollectorData_v5');
        localStorage.removeItem('changeCollectorData_v4');
        location.reload();
    }
}

function exportData() {
    const dataStr = JSON.stringify(appState, null, 2);
    const blob = new Blob([dataStr], { type: "application/json" });
    const url = URL.createObjectURL(blob);

    const a = document.createElement('a');
    a.href = url;
    a.download = `change_collector_backup_${new Date().toISOString().split('T')[0]}.json`;
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);
    URL.revokeObjectURL(url);
}
window.exportData = exportData;
