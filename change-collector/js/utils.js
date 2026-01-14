function updateTime() {
    const now = new Date();
    document.getElementById('clock').innerText = now.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
}

const sounds = {
    coin: new Audio('https://assets.mixkit.co/active_storage/sfx/2000/2000-preview.mp3'),
    success: new Audio('https://assets.mixkit.co/active_storage/sfx/1435/1435-preview.mp3'),
    pop: new Audio('https://assets.mixkit.co/active_storage/sfx/2578/2578-preview.mp3')
};

function playSound(type) {
    if (sounds[type]) {
        sounds[type].currentTime = 0;
        sounds[type].play().catch(e => console.log('Audio play failed:', e));
    }
}
