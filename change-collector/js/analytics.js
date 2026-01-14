// analytics.js - Standard Script

let balanceChartInstance = null;
let sourcesChartInstance = null;
let trendChartInstance = null;

function renderCharts() {
    const txns = [...appState.transactions].sort((a, b) => new Date(a.date) - new Date(b.date));

    // 1. Data Aggregation
    const credits = txns.filter(t => t.type === 'credit');
    const debits = txns.filter(t => t.type === 'debit');

    const totalCredit = credits.reduce((acc, t) => acc + t.amount, 0);

    // Split Debits (Spending vs Savings)
    const savings = debits.filter(t => t.title.startsWith('Ahorro:'));
    const spending = debits.filter(t => !t.title.startsWith('Ahorro:'));

    const totalSaved = savings.reduce((acc, t) => acc + t.amount, 0);
    const totalSpent = spending.reduce((acc, t) => acc + t.amount, 0);

    const collectedEl = document.getElementById('analytics-total-collected');
    if (collectedEl) collectedEl.innerText = '$' + totalCredit.toFixed(2);

    // 2. KPI Calculations
    const avgTicket = credits.length > 0 ? totalCredit / credits.length : 0;
    const avgEl = document.getElementById('kpi-avg-ticket');
    if (avgEl) avgEl.innerText = '$' + avgTicket.toFixed(2);

    const days = ['Dom', 'Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb'];
    const dayCounts = new Array(7).fill(0);
    credits.forEach(t => {
        const d = new Date(t.date).getDay();
        dayCounts[d] += t.amount;
    });
    const maxDayIndex = dayCounts.indexOf(Math.max(...dayCounts));
    const bestDayEl = document.getElementById('kpi-best-day');
    if (bestDayEl) bestDayEl.innerText = totalCredit > 0 ? days[maxDayIndex] : '-';

    // 3. Trend Data
    let currentBal = 0;
    const trendLabels = [];
    const trendData = [];

    txns.forEach(t => {
        if (t.type === 'credit') currentBal += t.amount;
        else currentBal -= t.amount;

        const d = new Date(t.date).toLocaleDateString('es-MX', { day: 'numeric', month: 'short' });
        trendLabels.push(d);
        trendData.push(currentBal);
    });

    // 4. Render Trend
    const ctxTrend = document.getElementById('trendChart')?.getContext('2d');
    if (ctxTrend) {
        if (trendChartInstance) trendChartInstance.destroy();

        trendChartInstance = new Chart(ctxTrend, {
            type: 'line',
            data: {
                labels: trendLabels,
                datasets: [{
                    label: 'Saldo',
                    data: trendData,
                    borderColor: '#10B981',
                    backgroundColor: (context) => {
                        const ctx = context.chart.ctx;
                        const gradient = ctx.createLinearGradient(0, 0, 0, 200);
                        gradient.addColorStop(0, 'rgba(16, 185, 129, 0.2)');
                        gradient.addColorStop(1, 'rgba(16, 185, 129, 0)');
                        return gradient;
                    },
                    fill: true,
                    tension: 0.4,
                    pointRadius: 0,
                    pointHoverRadius: 6
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: { legend: { display: false }, tooltip: { mode: 'index', intersect: false } },
                scales: {
                    x: { display: false },
                    y: { display: false }
                },
                interaction: {
                    mode: 'nearest',
                    axis: 'x',
                    intersect: false
                }
            }
        });
    }

    // 5. Render Breakdown (Bar)
    const ctxBalance = document.getElementById('balanceChart')?.getContext('2d');
    if (ctxBalance) {
        if (balanceChartInstance) balanceChartInstance.destroy();

        balanceChartInstance = new Chart(ctxBalance, {
            type: 'bar',
            data: {
                labels: ['Entradas', 'Gastos', 'Ahorros'],
                datasets: [{
                    label: 'Monto ($)',
                    data: [totalCredit, totalSpent, totalSaved],
                    backgroundColor: ['#10B981', '#EF4444', '#F59E0B'],
                    borderRadius: 8,
                    barThickness: 40
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: { legend: { display: false } },
                scales: { y: { beginAtZero: true, grid: { display: false } }, x: { grid: { display: false } } }
            }
        });
    }

    // 6. Sources
    const ctxSources = document.getElementById('sourcesChart')?.getContext('2d');
    if (ctxSources) {
        const sources = {};
        credits.forEach(t => sources[t.title] = (sources[t.title] || 0) + t.amount);
        const sourceLabels = Object.keys(sources);
        const sourceValues = Object.values(sources);

        if (sourcesChartInstance) sourcesChartInstance.destroy();

        sourcesChartInstance = new Chart(ctxSources, {
            type: 'doughnut',
            data: {
                labels: sourceLabels,
                datasets: [{
                    data: sourceValues,
                    backgroundColor: ['#34D399', '#6EE7B7', '#10B981', '#059669', '#047857', '#065F46'],
                    borderWidth: 0
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: { legend: { position: 'right', labels: { boxWidth: 10, font: { size: 10 } } } },
                cutout: '70%'
            }
        });
    }
}

function calculateDream() {
    const amount = parseFloat(document.getElementById('dream-amount').value);
    const daily = parseFloat(document.getElementById('dream-daily').value);
    const resultBox = document.getElementById('dream-result');

    if (!amount || !daily || amount <= 0 || daily <= 0) {
        alert('Por favor ingresa montos válidos.');
        return;
    }

    const daysNeeded = Math.ceil(amount / daily);
    const targetDate = new Date();
    targetDate.setDate(targetDate.getDate() + daysNeeded);

    const options = { year: 'numeric', month: 'long', day: 'numeric' };
    document.getElementById('dream-date-result').innerText = targetDate.toLocaleDateString('es-ES', options);
    document.getElementById('dream-days-left').innerText = `(en ${daysNeeded} días)`;

    resultBox.classList.remove('hidden');
    resultBox.classList.add('flex', 'flex-col');
}

let currentHistoryFilter = 'all';

function renderHistory(filter) {
    if (filter) currentHistoryFilter = filter;

    const listContainer = document.getElementById('full-history-list');
    const recentContainer = document.getElementById('recent-activity-list');
    const searchVal = document.getElementById('history-search') ? document.getElementById('history-search').value.toLowerCase() : '';

    // Update Filter UI
    document.querySelectorAll('.filter-chip').forEach(btn => {
        btn.classList.remove('bg-gray-900', 'text-white');
        btn.classList.add('bg-gray-100', 'text-gray-500');
    });
    const activeBtn = document.getElementById(`filter-${currentHistoryFilter}`);
    if (activeBtn) {
        activeBtn.classList.remove('bg-gray-100', 'text-gray-500');
        activeBtn.classList.add('bg-gray-900', 'text-white');
    }

    listContainer.innerHTML = '';

    // Only clear recent if we are in default state (no filter, no search)
    if (currentHistoryFilter === 'all' && searchVal === '') recentContainer.innerHTML = '';

    let txns = [...appState.transactions];
    txns.sort((a, b) => new Date(b.date) - new Date(a.date));

    // Populate Recent (Home) - Only if default state
    const recentTxns = txns.slice(0, 3);
    if (currentHistoryFilter === 'all' && searchVal === '') {
        recentTxns.forEach(txn => {
            recentContainer.innerHTML += createTxnHTML(txn, false);
        });
    }

    // FILTERING (Type)
    if (currentHistoryFilter !== 'all') {
        txns = txns.filter(t => t.type === currentHistoryFilter);
    }

    // FILTERING (Search)
    if (searchVal) {
        txns = txns.filter(t => t.title.toLowerCase().includes(searchVal) || t.amount.toString().includes(searchVal));
    }

    if (txns.length === 0) {
        document.getElementById('empty-history').classList.remove('hidden');
        return;
    } else {
        document.getElementById('empty-history').classList.add('hidden');
    }

    // GROUPING Implementation
    let lastDateLabel = '';

    txns.forEach((txn, index) => {
        const dateObj = new Date(txn.date);
        const label = getDateLabel(dateObj);

        if (label !== lastDateLabel) {
            listContainer.innerHTML += `
                        <div class="sticky top-0 bg-white z-10 py-2 pt-4">
                            <h3 class="text-xs font-bold text-gray-400 uppercase tracking-wider">${label}</h3>
                        </div>
                    `;
            lastDateLabel = label;
        }

        listContainer.innerHTML += createTxnHTML(txn, true);
    });

    if (window.lucide) window.lucide.createIcons();
}

function getDateLabel(dateObj) {
    const today = new Date();
    const yesterday = new Date();
    yesterday.setDate(today.getDate() - 1);

    if (dateObj.toDateString() === today.toDateString()) return 'Hoy';
    if (dateObj.toDateString() === yesterday.toDateString()) return 'Ayer';

    return dateObj.toLocaleDateString('es-ES', { day: 'numeric', month: 'short' });
}

function createTxnHTML(txn, detailed) {
    const dateObj = new Date(txn.date);
    const timeStr = dateObj.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });

    const isCredit = txn.type === 'credit';
    const icon = isCredit ? 'shopping-bag' : 'zap';
    const colorClass = isCredit ? 'text-emerald-600 dark:text-emerald-400' : 'text-red-500 dark:text-red-400';
    const bgClass = isCredit ? 'bg-emerald-50 dark:bg-emerald-900/30' : 'bg-red-50 dark:bg-red-900/30';
    const sign = isCredit ? '+' : '-';

    let displayIcon = icon;
    if (txn.title.includes('Ahorro')) displayIcon = 'piggy-bank';

    return `
                <div class="flex items-center justify-between p-4 bg-white dark:bg-slate-800 border border-gray-100 dark:border-slate-700 rounded-2xl shadow-sm mb-2 hover:bg-gray-50 dark:hover:bg-slate-700 transition-colors">
                    <div class="flex gap-4 items-center">
                        <div class="w-12 h-12 ${bgClass} rounded-xl flex items-center justify-center">
                            <i data-lucide="${displayIcon}" class="${colorClass.replace('text-', 'text-opacity-80 ')} w-5 h-5"></i>
                        </div>
                        <div>
                            <p class="font-semibold text-sm text-gray-900 dark:text-gray-100">${txn.title}</p>
                            <p class="text-xs text-gray-400 dark:text-gray-500">${timeStr}</p>
                        </div>
                    </div>
                    <p class="font-bold ${colorClass}">${sign}$${txn.amount.toFixed(2)}</p>
                </div>
            `;
}
