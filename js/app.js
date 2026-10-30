// Инициализация Telegram Web App
// В начале js файла
const tg = window.Telegram.WebApp;
tg.ready(); // Сообщаем что приложение готово
tg.expand(); // Разворачиваем на весь экран

// Эмуляция загрузки ресурсов
const loadingSteps = [
    { percent: 20, text: "Загрузка спрайтов..." },
    { percent: 45, text: "Генерация мира..." },
    { percent: 70, text: "Загрузка музыки..." },
    { percent: 90, text: "Почти готово..." },
    { percent: 100, text: "Добро пожаловать!" }
];

async function simulateLoading() {
    const progress = document.getElementById('progress');
    const hint = document.getElementById('hint');

    for (const step of loadingSteps) {
        await new Promise(r => setTimeout(r, 600)); // Имитация задержки
        progress.style.width = step.percent + '%';
        hint.textContent = step.text;
    }

    // Загрузка завершена — переходим на главный экран
    await new Promise(r => setTimeout(r, 500));
    document.getElementById('loading-screen').classList.remove('active');
    document.getElementById('main-screen').classList.add('active');

    // Сообщаем Телеграму что приложение готово
    tg.ready();
}

// Запускаем загрузку
simulateLoading();