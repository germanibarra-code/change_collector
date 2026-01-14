// goals.js - Standard Script

let selectedGoalIcon = 'headphones';
let currentFundingGoalId = null;
let editingGoalId = null;

// Helpers explicitly exposed
window.openFundGoal = openFundGoal;
window.editGoal = editGoal;
window.deleteGoal = deleteGoal;
window.saveNewGoal = saveNewGoal;
window.confirmFundGoal = confirmFundGoal;
window.selectIcon = selectIcon;
window.closeFundGoal = closeFundGoal;
window.openCreateGoal = openCreateGoal;

function openCreateGoal() {
    editingGoalId = null;
    document.getElementById('goal-name').value = '';
    document.getElementById('goal-target').value = '';
    if (document.getElementById('goal-date')) document.getElementById('goal-date').value = '';

    // Reset UI for Create Mode
    const header = document.querySelector('#create-goal-screen h1');
    if (header) header.innerText = "Nueva Meta";

    const saveBtn = document.querySelector('#create-goal-screen button[onclick="saveNewGoal()"]');
    if (saveBtn) saveBtn.innerText = "Crear Meta";

    selectIcon('headphones');
    changeScreen('create-goal');
}

function renderGoals() {
    const container = document.getElementById('goals-list');
    container.innerHTML = '';

    if (appState.goals.length === 0) {
        container.innerHTML = `<div class="p-4 bg-gray-50 border border-gray-100 rounded-2xl text-center text-gray-400 text-xs shadow-sm">
                No tienes metas de ahorro. ¡Crea una para motivarte!
             </div>`;
        return;
    }

    appState.goals.forEach(goal => {
        const isComplete = goal.current >= goal.target;
        const percent = Math.min((goal.current / goal.target) * 100, 100);

        // Styles for active vs complete
        const cardBorder = isComplete ? 'border-emerald-400 ring-2 ring-emerald-100' : 'border-gray-100';
        const iconBg = isComplete ? 'bg-emerald-500 text-white shadow-lg shadow-emerald-200' : 'bg-emerald-50 text-emerald-600';
        const barColor = isComplete ? 'bg-emerald-500' : 'bg-emerald-500';

        // Action Button logic
        let actionBtn = `
                     <button onclick="openFundGoal(${goal.id})" class="text-xs bg-emerald-100 text-emerald-700 px-3 py-1 rounded-full font-bold hover:bg-emerald-200 transition-colors">
                        + Ahorrar
                    </button>
                `;

        if (isComplete) {
            actionBtn = `
                     <span class="text-xs bg-emerald-600 text-white px-3 py-1 rounded-full font-bold shadow-sm flex items-center gap-1">
                        <i data-lucide="check-circle-2" class="w-3 h-3"></i> ¡Logrado!
                    </span>
                     `;
        }

        // Admin Controls (Always Visible)
        const adminControls = `
            <div class="mt-4 pt-3 border-t border-gray-100 flex justify-end gap-3">
                <button onclick="editGoal(${goal.id})" class="p-2 text-gray-400 hover:text-blue-500 hover:bg-blue-50 rounded-full transition-colors" title="Editar">
                    <i data-lucide="pencil" class="w-4 h-4"></i>
                </button>
                <button onclick="deleteGoal(${goal.id})" class="p-2 text-gray-400 hover:text-red-500 hover:bg-red-50 rounded-full transition-colors" title="Eliminar">
                    <i data-lucide="trash-2" class="w-4 h-4"></i>
                </button>
            </div>
        `;

        container.innerHTML += `
                <div class="bg-white border ${cardBorder} rounded-2xl p-4 shadow-sm relative group transition-all duration-300">
                    <div class="flex justify-between items-start mb-2">
                        <div class="flex gap-3 items-center">
                            <div class="w-10 h-10 ${iconBg} rounded-full flex items-center justify-center transition-colors">
                                <i data-lucide="${goal.icon}"></i>
                            </div>
                            <div>
                                <p class="font-bold text-sm text-gray-900">${goal.name}</p>
                                <p class="text-xs text-gray-500">$${goal.current.toFixed(2)} / $${goal.target.toFixed(2)}</p>
                            </div>
                        </div>
                        <div class="flex flex-col items-end gap-2">
                            ${actionBtn}
                        </div>
                    </div>
                    
                    <div class="w-full bg-gray-100 h-2 rounded-full overflow-hidden mt-3 relative">
                        <div class="${barColor} h-full rounded-full transition-all duration-1000 ease-out" style="width: ${percent}%"></div>
                    </div>

                    ${adminControls}
                </div>
            `;
    });

    if (window.lucide) window.lucide.createIcons();
}

function selectIcon(icon) {
    selectedGoalIcon = icon;
    document.querySelectorAll('.icon-opt').forEach(btn => btn.classList.remove('border-emerald-500'));
    event.currentTarget.classList.add('border-emerald-500');
}

function saveNewGoal() {
    const name = document.getElementById('goal-name').value;
    const target = parseFloat(document.getElementById('goal-target').value);
    const lockedUntil = document.getElementById('goal-date') ? document.getElementById('goal-date').value : null;

    if (!name || isNaN(target) || target <= 0) {
        alert('Por favor ingresa un nombre y un monto válido.');
        return;
    }

    if (lockedUntil) {
        const selected = new Date(lockedUntil);
        const today = new Date();
        today.setHours(0, 0, 0, 0); // Normalize to start of day
        selected.setHours(24, 0, 0, 0); // End of selected day to allow "today"

        if (selected < today) {
            alert('La fecha objetivo no puede ser en el pasado.');
            return;
        }
    }

    if (editingGoalId) {
        // UPDATE existing (loose check)
        const goal = appState.goals.find(g => g.id == editingGoalId);
        if (goal) {
            goal.name = name;
            goal.target = target;
            goal.icon = selectedGoalIcon;
            goal.lockedUntil = lockedUntil;
        }
        editingGoalId = null;
    } else {
        // CREATE new
        appState.goals.push({
            id: Date.now(),
            name,
            target,
            current: 0,
            icon: selectedGoalIcon,
            lockedUntil: lockedUntil
        });
    }

    saveData();
    changeScreen('home');

    // Clear inputs
    document.getElementById('goal-name').value = '';
    document.getElementById('goal-target').value = '';
    if (document.getElementById('goal-date')) document.getElementById('goal-date').value = '';
}

function openFundGoal(id) {
    currentFundingGoalId = id;
    const goal = appState.goals.find(g => g.id == id);
    if (!goal) return;

    document.getElementById('fund-goal-modal').classList.remove('hidden');
    document.getElementById('fund-goal-title').innerText = `Ahorrar para: ${goal.name}`;

    // Update Available Balance Display
    const availableEl = document.getElementById('fund-available');
    if (availableEl) availableEl.innerText = appState.balance.toFixed(2);

    document.getElementById('fund-amount').focus();
}

function closeFundGoal() {
    document.getElementById('fund-goal-modal').classList.add('hidden');
}

function confirmFundGoal() {
    const amount = parseFloat(document.getElementById('fund-amount').value);

    if (isNaN(amount) || amount <= 0) {
        alert('Monto inválido'); return;
    }

    if (amount > appState.balance) {
        alert('Saldo insuficiente en tu billetera.'); return;
    }

    // Execute Transfer
    appState.balance -= amount;
    const goal = appState.goals.find(g => g.id == currentFundingGoalId);
    if (goal) goal.current += amount;

    appState.transactions.push({
        id: Date.now(),
        title: `Ahorro: ${goal ? goal.name : 'Meta'}`,
        date: new Date().toISOString(),
        amount: amount,
        type: 'debit'
    });

    updateStreak();
    playSound('success');

    saveData();
    closeFundGoal();
    renderGoals(); // Update list immediately
}

function updateStreak() {
    const today = new Date().toDateString();
    const last = appState.lastActionDate;

    if (last === today) return;

    const yesterday = new Date();
    yesterday.setDate(yesterday.getDate() - 1);

    if (last === yesterday.toDateString()) {
        appState.streak += 1;
    } else {
        appState.streak = 1;
    }

    appState.lastActionDate = today;
    saveData();

    // UI Update for Streak Badge
    const badge = document.getElementById('streak-badge');
    if (badge) {
        badge.classList.remove('bg-orange-50');
        badge.classList.add('bg-orange-100');
        setTimeout(() => {
            badge.classList.remove('bg-orange-100');
            badge.classList.add('bg-orange-50');
        }, 500);
    }
}

function deleteGoal(id) {
    const goal = appState.goals.find(g => g.id == id);
    if (!goal) {
        console.log("Goal not found with id", id);
        return;
    }

    // Time Lock Check
    if (goal.lockedUntil) {
        const lockDate = new Date(goal.lockedUntil);
        const now = new Date();
        lockDate.setHours(0, 0, 0, 0);
        now.setHours(0, 0, 0, 0);

        if (now < lockDate) {
            alert(`🚫 Meta Bloqueada.\nNo puedes borrar ni retirar fondos de esta meta hasta el ${lockDate.toLocaleDateString()}.`);
            return;
        }
    }

    if (confirm(`¿Estás seguro de eliminar la meta "${goal.name}"?`)) {
        if (goal.current > 0) {
            appState.balance += goal.current;
            appState.transactions.push({
                id: Date.now(),
                title: `Reembolso: ${goal.name}`,
                date: new Date().toISOString(),
                amount: goal.current,
                type: 'credit'
            });
            alert(`Se han regresado $${goal.current.toFixed(2)} a tu saldo disponible.`);
        }

        appState.goals = appState.goals.filter(g => g.id !== id);
        saveData();
        renderGoals();
    }
}

function editGoal(id) {
    const goal = appState.goals.find(g => g.id == id);
    if (!goal) return;

    editingGoalId = id;
    document.getElementById('goal-name').value = goal.name;
    document.getElementById('goal-target').value = goal.target;
    if (document.getElementById('goal-date')) document.getElementById('goal-date').value = goal.lockedUntil || '';
    selectIcon(goal.icon);

    document.querySelector('#create-goal-screen h1').innerText = "Editar Meta";
    document.querySelector('#create-goal-screen button[onclick="saveNewGoal()"]').innerText = "Guardar Cambios";

    changeScreen('create-goal');
}
